-- Migration: create_referrals_table
-- Purpose:   Referral program — users generate unique referral codes and earn
--            credits when referred users subscribe. Rewards are tracked as
--            discount credits applied to next billing cycle.
-- Fixed:     Use auth.users(id) for referrer/referee FKs instead of users (id)
--            Ensure profiles table exists before modifying it
-- ─────────────────────────────────────────────────────────────────────────────

-- ── Ensure users table has referral fields ───────────────────────────────────
ALTER TABLE public.users
    ADD COLUMN IF NOT EXISTS referral_code      TEXT,
    ADD COLUMN IF NOT EXISTS referred_by        UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS referral_credits   INTEGER NOT NULL DEFAULT 0;

-- Unique index on referral_code (case-insensitive lookup)
CREATE UNIQUE INDEX IF NOT EXISTS users_referral_code_lower
    ON public.users (LOWER(referral_code))
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

DROP TRIGGER IF EXISTS users_updated_at ON public.users;
CREATE TRIGGER users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ── Auto-generate referral code on user insert ────────────────────────────────

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
            new_code := UPPER(SUBSTRING(MD5(RANDOM()::TEXT || NEW.user_id::TEXT) FROM 1 FOR 6));

            -- Check uniqueness
            IF NOT EXISTS (
                SELECT 1 FROM public.users WHERE LOWER(referral_code) = LOWER(new_code)
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

-- Apply to new user inserts
DROP TRIGGER IF EXISTS users_generate_referral_code ON public.users;
CREATE TRIGGER users_generate_referral_code
    BEFORE INSERT ON public.users
    FOR EACH ROW EXECUTE FUNCTION public.generate_referral_code();

-- Backfill existing users that don't have a code yet
UPDATE public.users
SET referral_code = UPPER(SUBSTRING(MD5(user_id::TEXT) FROM 1 FOR 6))
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

-- ── Row Level Security ────────────────────────────────────────────────────────

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Users can view and edit their own profile
DROP POLICY IF EXISTS "users_select_own" ON public.users;
CREATE POLICY "users_select_own"
    ON public.users FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

DROP POLICY IF EXISTS "users_update_own" ON public.users;
CREATE POLICY "users_update_own"
    ON public.users FOR UPDATE
    TO authenticated
    USING (user_id = auth.uid());

DROP POLICY IF EXISTS "users_insert_own" ON public.users;
CREATE POLICY "users_insert_own"
    ON public.users FOR INSERT
    TO authenticated
    WITH CHECK (user_id = auth.uid());

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

-- ── Trigger: create user record on auth.users insert ──────────────────────────

CREATE OR REPLACE FUNCTION public.handle_new_auth_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
    INSERT INTO public.users (user_id, full_name, avatar_url)
    VALUES (
        NEW.id,
        NEW.raw_user_meta_data ->> 'full_name',
        NEW.raw_user_meta_data ->> 'avatar_url'
    )
    ON CONFLICT (user_id) DO NOTHING;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created_for_referral ON auth.users;
CREATE TRIGGER on_auth_user_created_for_referral
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_auth_user();

-- ── Comments ──────────────────────────────────────────────────────────────────

COMMENT ON TABLE public.referrals IS 'Referral program: tracks who referred whom and reward status';
COMMENT ON COLUMN public.referrals.status IS 'pending=signup done, credited=reward applied, rejected=did not qualify';
COMMENT ON COLUMN public.referrals.reward_credits IS 'Credits awarded (1 = 1 free month equivalent)';
COMMENT ON COLUMN public.users.referral_code IS 'Unique shareable code (6 chars, auto-generated)';
COMMENT ON COLUMN public.users.referred_by IS 'auth.users.id of the user who referred this one';
COMMENT ON COLUMN public.users.referral_credits IS 'Accumulated credits from successful referrals';
