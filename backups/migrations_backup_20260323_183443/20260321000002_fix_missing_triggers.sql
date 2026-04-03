-- =========================================
-- Fix: Recreate missing triggers after profiles migration
-- =========================================
-- Purpose: Recreate triggers that were dropped in CASCADE when
--          dropping the set_updated_at function from profiles
-- =========================================

-- Recreate set_updated_at function
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

-- Recreate trigger for reviews
DROP TRIGGER IF EXISTS reviews_updated_at ON public.reviews;
CREATE TRIGGER reviews_updated_at
    BEFORE UPDATE ON public.reviews
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- Recreate trigger for referrals  
DROP TRIGGER IF EXISTS referrals_updated_at ON public.referrals;
CREATE TRIGGER referrals_updated_at
    BEFORE UPDATE ON public.referrals
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- Sync existing auth.users to public.users (if any were created before migration)
INSERT INTO public.users (user_id, email, full_name)
SELECT 
    u.id,
    u.email,
    u.raw_user_meta_data->>'full_name'
FROM auth.users u
WHERE NOT EXISTS (
    SELECT 1 FROM public.users pu WHERE pu.user_id = u.id
)
ON CONFLICT (user_id) DO NOTHING;