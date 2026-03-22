-- ============================================================================
-- Migration: Set Subscription Status Default and Finalize Table Rename
-- Created: 2026-03-22
-- Description: Standardizes subscription_status default to 'inactive' and
--              ensures the users table is used exclusively.
-- ============================================================================

-- 1. Update column defaults for public.users
ALTER TABLE public.users 
  ALTER COLUMN subscription_status SET DEFAULT 'inactive',
  ALTER COLUMN user_status SET DEFAULT 'no_set';

-- 2. Update existing NULL or incorrect statuses for local dev consistency
UPDATE public.users 
SET 
  subscription_status = 'inactive' 
WHERE 
  subscription_status IS NULL 
  OR subscription_status = 'active'; -- Resetting all to inactive for testing purposes

-- 3. Add or update the check constraint for subscription_status
-- We drop it first to be sure we are using the latest set of allowed values
ALTER TABLE public.users DROP CONSTRAINT IF EXISTS users_subscription_status_check;
ALTER TABLE public.users ADD CONSTRAINT users_subscription_status_check 
  CHECK (subscription_status IN ('active', 'inactive', 'trialing', 'past_due', 'canceled'));

-- 4. Re-verify the handle_new_user function to ensure it doesn't override defaults
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
