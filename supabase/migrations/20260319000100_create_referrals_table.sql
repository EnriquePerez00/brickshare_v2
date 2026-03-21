-- Migration: create_referrals_table
-- Purpose:   Referral program — users generate unique referral codes and earn
--            credits when referred users subscribe. Rewards are tracked as
--            discount credits applied to next billing cycle.
-- Fixed:     Use auth.users(id) for referrer/referee FKs instead of profiles(id)
--            Ensure profiles table exists before modifying it
-- ─────────────────────────────────────────────────────────────────────────────

-- ── Ensure profiles table exists (Supabase standard: id = auth.uid()) ─────────
CREATE TABLE IF NOT EXISTS public.profiles (
    id              UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name       TEXT,
    avatar_url      TEXT,
    sub_status      TEXT DEFAULT 'free',
    impact_points   INTEGER DEFAULT 0,
    referral_code   TEXT UNIQUE,
    referred_by     UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    referral_credits INTEGER NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Add referral fields if table already existed without them ─────────────────
ALTER TABLE public.profiles
    ADD COLUMN IF NOT EXISTS referral_code      TEXT,
    ADD COLUMN IF NOT EXISTS referred_by        UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS referral_credits   INTEGER NOT NULL DEFAULT 0;

-- Unique index on referral_code (case-insensitive lookup)
CREATE UNIQUE INDEX IF NOT EXISTS profiles_referral_code_lower
    ON public.profiles (LOWER(referral_code))
    WHERE referral_code IS NOT NULL;

-- ── Referrals table ───────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.referrals (
    id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,

    -- Who shared the code (auth user id)
    referrer_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    -- Who used the code (auth user id)
    referee_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    -- Reward tracking
    status          TEXT NOT NULL DEFAULT 'pending'
                        CHECK (status IN ('pending', 'credited', 'rejected')),
    -- 'pending'  → referee signed up but hasn't activated subscription yet
    -- 'credited' → reward has been applied to referrer's credits
    -- 'rejected' → referee cancelled before qualifying

    reward_credits  INTEGER NOT NULL DEFAULT 1,
    -- Number of months/credits awarded. Default = 1 free month equivalent.

    stripe_coupon_id TEXT,
    -- Stripe coupon applied to referrer's next invoice (optional)

    credited_at     TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- One referral record per referred user
    UNIQUE (referee_id)
);

-- ── Indexes ───────────────────────────────────────────────────────────────────

CREATE INDEX IF NOT EXISTS referrals_referrer_id_idx
    ON public.referrals (referrer_id, status, created_at DESC);

-- ── Auto-update updated_at ────────────────────────────────────────────────────

-- Ensure set_updated_at function exists (created in 20260319000000)
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS referrals_updated_at ON public.referrals;
CREATE TRIGGER referrals_updated_at
    BEFORE UPDATE ON public.referrals
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS profiles_updated_at ON public.profiles;
CREATE TRIGGER profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ── Auto-generate referral code on profile insert ────────────────────────────

CREATE OR REPLACE FUNCTION public.generate_referral_code()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    new_code TEXT;
    attempts INTEGER := 0;
BEGIN
    -- Only generate if not already set
    IF NEW.referral_code IS NULL THEN
        LOOP
            -- 6-char uppercase alphanumeric code
            new_code := UPPER(SUBSTRING(MD5(RANDOM()::TEXT || NEW.id::TEXT) FROM 1 FOR 6));

            -- Check uniqueness
            IF NOT EXISTS (
                SELECT 1 FROM public.profiles WHERE LOWER(referral_code) = LOWER(new_code)
            ) THEN
                NEW.referral_code := new_code;
                EXIT;
            END IF;

            attempts := attempts + 1;
            IF attempts > 10 THEN
                -- Fallback: use longer hash
                NEW.referral_code := UPPER(SUBSTRING(MD5(NEW.id::TEXT) FROM 1 FOR 8));
                EXIT;
            END IF;
        END LOOP;
    END IF;
    RETURN NEW;
END;
$$;

-- Apply to new profile inserts
DROP TRIGGER IF EXISTS profiles_generate_referral_code ON public.profiles;
CREATE TRIGGER profiles_generate_referral_code
    BEFORE INSERT ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.generate_referral_code();

-- Backfill existing profiles that don't have a code yet
UPDATE public.profiles
SET referral_code = UPPER(SUBSTRING(MD5(id::TEXT) FROM 1 FOR 6))
WHERE referral_code IS NULL;

-- ── Function: apply referral when subscription activates ─────────────────────

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

    -- Award credits to referrer
    UPDATE public.profiles
    SET referral_credits = referral_credits + v_referral.reward_credits
    WHERE id = v_referrer_id;

    -- Mark referral as credited
    UPDATE public.referrals
    SET status = 'credited',
        credited_at = NOW()
    WHERE id = v_referral.id;
END;
$$;

-- ── Row Level Security ────────────────────────────────────────────────────────

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Users can view and edit their own profile
DROP POLICY IF EXISTS "profiles_select_own" ON public.profiles;
CREATE POLICY "profiles_select_own"
    ON public.profiles FOR SELECT
    TO authenticated
    USING (id = auth.uid());

DROP POLICY IF EXISTS "profiles_update_own" ON public.profiles;
CREATE POLICY "profiles_update_own"
    ON public.profiles FOR UPDATE
    TO authenticated
    USING (id = auth.uid());

DROP POLICY IF EXISTS "profiles_insert_own" ON public.profiles;
CREATE POLICY "profiles_insert_own"
    ON public.profiles FOR INSERT
    TO authenticated
    WITH CHECK (id = auth.uid());

ALTER TABLE public.referrals ENABLE ROW LEVEL SECURITY;

-- Users can see referrals where they are the referrer
DROP POLICY IF EXISTS "referrals_select_own" ON public.referrals;
CREATE POLICY "referrals_select_own"
    ON public.referrals
    FOR SELECT
    TO authenticated
    USING (referrer_id = auth.uid());

-- Users can see their own incoming referral (to know who referred them)
DROP POLICY IF EXISTS "referrals_select_referee" ON public.referrals;
CREATE POLICY "referrals_select_referee"
    ON public.referrals
    FOR SELECT
    TO authenticated
    USING (referee_id = auth.uid());

-- Only admin/operador can manage all referrals
DROP POLICY IF EXISTS "referrals_admin_all" ON public.referrals;
CREATE POLICY "referrals_admin_all"
    ON public.referrals
    FOR ALL
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.user_roles
            WHERE user_id = auth.uid()
            AND role IN ('admin', 'operador')
        )
    );

-- ── Trigger: create profile on auth.users insert ─────────────────────────────

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, avatar_url)
    VALUES (
        NEW.id,
        NEW.raw_user_meta_data ->> 'full_name',
        NEW.raw_user_meta_data ->> 'avatar_url'
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ── Comments ──────────────────────────────────────────────────────────────────

COMMENT ON TABLE public.referrals IS 'Referral program: tracks who referred whom and reward status';
COMMENT ON COLUMN public.referrals.status IS 'pending=signup done, credited=reward applied, rejected=did not qualify';
COMMENT ON COLUMN public.referrals.reward_credits IS 'Credits awarded (1 = 1 free month equivalent)';
COMMENT ON COLUMN public.profiles.referral_code IS 'Unique shareable code (6 chars, auto-generated)';
COMMENT ON COLUMN public.profiles.referred_by IS 'auth.users.id of the user who referred this one';
COMMENT ON COLUMN public.profiles.referral_credits IS 'Accumulated credits from successful referrals';