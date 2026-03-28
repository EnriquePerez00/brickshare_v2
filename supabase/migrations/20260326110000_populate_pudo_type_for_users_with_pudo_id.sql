-- ============================================================================
-- Migration: Populate pudo_type for users with pudo_id
-- Date: 2026-03-26
-- Description: Ensure all users with a pudo_id have pudo_type set to 'brickshare'
-- This prevents errors in preview_assign_sets_to_users() after server restart
-- ============================================================================

-- Update users who have a pudo_id but pudo_type is NULL
UPDATE public.users
SET pudo_type = 'brickshare'
WHERE pudo_id IS NOT NULL
  AND pudo_type IS NULL;

-- Add comment explaining the fix
COMMENT ON COLUMN public.users.pudo_type IS 'Type of PUDO point: correos (Correos API PUDO) or brickshare (Brickshare deposit). Must be set if user has pudo_id.';