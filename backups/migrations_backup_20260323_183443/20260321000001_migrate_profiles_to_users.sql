-- =========================================
-- Migration: Migrate profiles to users
-- =========================================
-- Purpose: Consolidate all user profile functionality into the 'users' table
--          and remove the conflicting 'profiles' table.
--
-- This migration:
-- 1. Adds referral fields to users table
-- 2. Migrates data from profiles to users
-- 3. Updates all triggers and functions to use users
-- 4. Removes profiles table and its dependencies
-- =========================================

-- =========================================
-- STEP 1: Add referral fields to users
-- =========================================

ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS referral_code TEXT,
  ADD COLUMN IF NOT EXISTS referred_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS referral_credits INTEGER NOT NULL DEFAULT 0;

-- Create unique index on referral_code (case-insensitive)
CREATE UNIQUE INDEX IF NOT EXISTS users_referral_code_lower
  ON public.users (LOWER(referral_code))
  WHERE referral_code IS NOT NULL;

COMMENT ON COLUMN public.users.referral_code IS 'Unique shareable code (6 chars, auto-generated)';
COMMENT ON COLUMN public.users.referred_by IS 'auth.users.id of the user who referred this one';
COMMENT ON COLUMN public.users.referral_credits IS 'Accumulated credits from successful referrals';

-- =========================================
-- STEP 2: Migrate data from profiles to users (if profiles exists)
-- =========================================

-- Only migrate if profiles table exists
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles' AND table_schema = 'public') THEN
        UPDATE public.users u
        SET 
          referral_code = p.referral_code,
          referred_by = p.referred_by,
          referral_credits = COALESCE(p.referral_credits, 0),
          full_name = COALESCE(u.full_name, p.full_name),
          avatar_url = COALESCE(u.avatar_url, p.avatar_url),
          impact_points = COALESCE(u.impact_points, p.impact_points, 0)
        FROM public.profiles p
        WHERE u.user_id = p.id;
    END IF;
END $$;

-- =========================================
-- STEP 3: Update handle_new_user trigger
-- =========================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
    INSERT INTO public.users (
        user_id,
        full_name,
        avatar_url,
        email
    )
    VALUES (
        NEW.id,
        NEW.raw_user_meta_data ->> 'full_name',
        NEW.raw_user_meta_data ->> 'avatar_url',
        NEW.email
    )
    ON CONFLICT (user_id) DO NOTHING;
    RETURN NEW;
END;
$$;

-- =========================================
-- STEP 4: Create trigger to auto-generate referral_code for users
-- =========================================

CREATE OR REPLACE FUNCTION public.generate_referral_code_users()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    new_code TEXT;
    attempts INTEGER := 0;
BEGIN
    -- Only generate if not already set
    IF NEW.referral_code IS NULL THEN
        LOOP
            -- 6-char uppercase alphanumeric code
            new_code := UPPER(SUBSTRING(MD5(RANDOM()::TEXT || NEW.user_id::TEXT) FROM 1 FOR 6));

            -- Check uniqueness
            IF NOT EXISTS (
                SELECT 1 FROM public.users 
                WHERE LOWER(referral_code) = LOWER(new_code)
            ) THEN
                NEW.referral_code := new_code;
                EXIT;
            END IF;

            attempts := attempts + 1;
            IF attempts > 10 THEN
                -- Fallback: use longer hash
                NEW.referral_code := UPPER(SUBSTRING(MD5(NEW.user_id::TEXT) FROM 1 FOR 8));
                EXIT;
            END IF;
        END LOOP;
    END IF;
    RETURN NEW;
END;
$$;

-- Apply trigger to users table
DROP TRIGGER IF EXISTS users_generate_referral_code ON public.users;
CREATE TRIGGER users_generate_referral_code
    BEFORE INSERT ON public.users
    FOR EACH ROW EXECUTE FUNCTION public.generate_referral_code_users();

-- =========================================
-- STEP 5: Update process_referral_credit function
-- =========================================

CREATE OR REPLACE FUNCTION public.process_referral_credit(p_referee_user_id UUID)
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_referral    public.referrals%ROWTYPE;
    v_referrer_id UUID;
BEGIN
    -- Find pending referral for this user
    SELECT * INTO v_referral
    FROM public.referrals
    WHERE referee_id = p_referee_user_id
      AND status = 'pending';

    IF NOT FOUND THEN
        RETURN; -- No pending referral, nothing to do
    END IF;

    v_referrer_id := v_referral.referrer_id;

    -- Award credits to referrer in USERS table
    UPDATE public.users
    SET referral_credits = referral_credits + v_referral.reward_credits
    WHERE user_id = v_referrer_id;

    -- Mark referral as credited
    UPDATE public.referrals
    SET status = 'credited',
        credited_at = NOW()
    WHERE id = v_referral.id;
END;
$$;

-- =========================================
-- STEP 6: Update increment_referral_credits function
-- =========================================

CREATE OR REPLACE FUNCTION public.increment_referral_credits(
    p_user_id UUID,
    p_amount INTEGER DEFAULT 1
)
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    UPDATE public.users
    SET referral_credits = referral_credits + p_amount
    WHERE user_id = p_user_id;
END;
$$;

-- =========================================
-- STEP 7: Backfill referral codes for existing users
-- =========================================

UPDATE public.users
SET referral_code = UPPER(SUBSTRING(MD5(user_id::TEXT) FROM 1 FOR 6))
WHERE referral_code IS NULL;

-- =========================================
-- STEP 8: Update RLS policies for users (if needed)
-- =========================================

-- Users can view their referral info
DROP POLICY IF EXISTS "users_select_own_referral" ON public.users;
CREATE POLICY "users_select_own_referral"
    ON public.users FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

-- =========================================
-- STEP 9: Clean up profiles table and dependencies (if profiles exists)
-- =========================================

DO $$
BEGIN
    -- Drop triggers on profiles if they exist
    IF EXISTS (SELECT 1 FROM information_schema.triggers WHERE trigger_name = 'profiles_generate_referral_code' AND event_object_schema = 'public') THEN
        DROP TRIGGER profiles_generate_referral_code ON public.profiles;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.triggers WHERE trigger_name = 'profiles_updated_at' AND event_object_schema = 'public') THEN
        DROP TRIGGER profiles_updated_at ON public.profiles;
    END IF;
    
    -- Drop functions specific to profiles
    DROP FUNCTION IF EXISTS public.generate_referral_code() CASCADE;
    DROP FUNCTION IF EXISTS public.set_updated_at() CASCADE;
    
    -- Drop RLS policies on profiles (if the table exists)
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles' AND table_schema = 'public') THEN
        DROP POLICY IF EXISTS "profiles_select_own" ON public.profiles;
        DROP POLICY IF EXISTS "profiles_update_own" ON public.profiles;
        DROP POLICY IF EXISTS "profiles_insert_own" ON public.profiles;
        
        -- Drop the profiles table
        DROP TABLE IF EXISTS public.profiles CASCADE;
    END IF;
END $$;

-- Drop old trigger on auth.users and recreate it (we'll recreate it to point to handle_new_user)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Recreate trigger on auth.users pointing to handle_new_user (which now inserts into users)
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- =========================================
-- VERIFICATION QUERIES (commented out)
-- =========================================

-- Uncomment to verify the migration:

-- Check users table structure
-- SELECT column_name, data_type, is_nullable, column_default
-- FROM information_schema.columns
-- WHERE table_name = 'users' AND table_schema = 'public'
-- ORDER BY ordinal_position;

-- Check that referral codes were generated
-- SELECT user_id, email, referral_code, referral_credits
-- FROM public.users
-- ORDER BY created_at DESC
-- LIMIT 10;

-- Verify profiles table is gone
-- SELECT table_name 
-- FROM information_schema.tables 
-- WHERE table_schema = 'public' AND table_name = 'profiles';

-- Check triggers on auth.users
-- SELECT trigger_name, event_manipulation, action_statement
-- FROM information_schema.triggers
-- WHERE event_object_table = 'users' AND event_object_schema = 'auth';