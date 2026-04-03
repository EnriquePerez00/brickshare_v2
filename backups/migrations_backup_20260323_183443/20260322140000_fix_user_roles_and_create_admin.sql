-- ============================================================================
-- Migration: Fix user roles assignment on signup + backfill + create admin
-- Created: 2026-03-22
-- Description:
--   1. Update handle_new_user() to also insert 'user' role in user_roles
--   2. Backfill 'user' role for existing users without any role
--   3. Create admin@brickshare.com user with 'admin' role
-- ============================================================================

-- ─── 1. Update handle_new_user trigger to assign default 'user' role ─────────

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
    -- Create record in users table
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

    -- Assign default 'user' role
    INSERT INTO public.user_roles (user_id, role)
    VALUES (NEW.id, 'user'::app_role)
    ON CONFLICT (user_id, role) DO NOTHING;

    RETURN NEW;
END;
$$;

-- ─── 2. Backfill: assign 'user' role to existing users without any role ──────

INSERT INTO public.user_roles (user_id, role)
SELECT u.user_id, 'user'::app_role
FROM public.users u
WHERE NOT EXISTS (
    SELECT 1 FROM public.user_roles ur
    WHERE ur.user_id = u.user_id
)
ON CONFLICT (user_id, role) DO NOTHING;