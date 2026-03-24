-- Migration: Remove foreign key constraint from users_brickshare_dropping
-- This allows saving any Brickshare PUDO ID without requiring it to exist in brickshare_pudo_locations
-- Rationale: The endpoint /api/locations-local may return dynamic locations that aren't pre-registered

-- ============================================================================
-- 1. Drop the foreign key constraint
-- ============================================================================
ALTER TABLE public.users_brickshare_dropping 
DROP CONSTRAINT IF EXISTS users_brickshare_dropping_brickshare_pudo_id_fkey;

-- ============================================================================
-- 2. Make brickshare_pudo_id nullable to handle edge cases
-- ============================================================================
-- Keep it NOT NULL since we still require an ID, just without the FK constraint
-- ALTER TABLE public.users_brickshare_dropping ALTER COLUMN brickshare_pudo_id DROP NOT NULL;

-- ============================================================================
-- 3. Add comments
-- ============================================================================
COMMENT ON COLUMN public.users_brickshare_dropping.brickshare_pudo_id IS 
'Reference to Brickshare PUDO location ID. No FK constraint to allow dynamic locations from external APIs.';

-- ============================================================================
-- Note: If in the future you want to re-add the constraint after populating 
-- brickshare_pudo_locations, you can run:
-- ALTER TABLE public.users_brickshare_dropping 
--     ADD CONSTRAINT users_brickshare_dropping_brickshare_pudo_id_fkey 
--     FOREIGN KEY (brickshare_pudo_id) 
--     REFERENCES public.brickshare_pudo_locations(id) 
--     ON DELETE RESTRICT;
-- ============================================================================