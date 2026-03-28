-- ============================================================================
-- Migration: Fix Brickshare PUDO IDs to use standard format
-- Date: 2026-03-26
-- Description: Update all users with pudo_type='brickshare' to use 
--              'brickshare-001' as pudo_id (matching remote API format)
-- ============================================================================

BEGIN;

-- ============================================================================
-- 1. Update users table with standardized Brickshare PUDO ID
-- ============================================================================

UPDATE public.users
SET pudo_id = 'brickshare-001'
WHERE pudo_type = 'brickshare'
  AND (pudo_id IS NULL OR pudo_id != 'brickshare-001');

-- ============================================================================
-- 2. Update users_brickshare_dropping table
-- ============================================================================

UPDATE public.users_brickshare_dropping
SET brickshare_pudo_id = 'brickshare-001'
WHERE brickshare_pudo_id IS NULL 
   OR brickshare_pudo_id != 'brickshare-001';

-- ============================================================================
-- 3. Log the changes for verification
-- ============================================================================

DO $$
DECLARE
    v_users_updated INTEGER;
    v_dropping_updated INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_users_updated
    FROM public.users
    WHERE pudo_type = 'brickshare' AND pudo_id = 'brickshare-001';
    
    SELECT COUNT(*) INTO v_dropping_updated
    FROM public.users_brickshare_dropping
    WHERE brickshare_pudo_id = 'brickshare-001';
    
    RAISE NOTICE '✅ Updated % users with brickshare-001 pudo_id', v_users_updated;
    RAISE NOTICE '✅ Updated % brickshare_dropping records', v_dropping_updated;
END $$;

COMMIT;

-- ============================================================================
-- 4. Update column comments for clarity
-- ============================================================================

COMMENT ON COLUMN public.users.pudo_id IS 
'Reference to the active PUDO point ID. For Brickshare deposits, this matches the ID from the remote API (e.g., brickshare-001, brickshare-002). For Correos PUDOs, this is the correos_id_pudo.';

COMMENT ON COLUMN public.users_brickshare_dropping.brickshare_pudo_id IS
'ID of the Brickshare PUDO location from remote API. Format: brickshare-XXX. No FK constraint to allow dynamic locations from external API.';

-- ============================================================================
-- Migration complete
-- ============================================================================
-- This migration ensures all existing users with Brickshare deposits use
-- the standardized 'brickshare-001' ID format that matches the remote API.
-- New selections will automatically use the correct ID from the remote API.
-- ============================================================================