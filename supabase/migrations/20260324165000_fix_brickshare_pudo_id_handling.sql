-- Migration: Fix Brickshare PUDO ID handling
-- Problem: When selecting a Brickshare deposit, the id_correos_pudo from PudoSelector
-- needs to be properly stored as brickshare_pudo_id

-- The issue is that PudoSelector uses 'id_correos_pudo' field for all point types,
-- but when it's a Deposito/Brickshare point, this ID should be stored in brickshare_pudo_id
-- in users_brickshare_dropping table.

-- No schema changes needed - the issue is in the frontend logic
-- This migration just adds documentation and ensures consistency

-- Add comment to clarify the field usage
COMMENT ON COLUMN public.users_brickshare_dropping.brickshare_pudo_id IS 
'ID of the Brickshare PUDO location. Can be any string identifier from the /api/locations-local endpoint or the brickshare_pudo_locations table. The id_correos_pudo field from PudoSelector is mapped to this field when tipo_punto is Deposito.';

-- Ensure the table has the right structure
-- (This is idempotent - won't fail if already correct)
DO $$ 
BEGIN
    -- Verify brickshare_pudo_id is NOT NULL
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'users_brickshare_dropping' 
        AND column_name = 'brickshare_pudo_id' 
        AND is_nullable = 'NO'
    ) THEN
        ALTER TABLE public.users_brickshare_dropping 
        ALTER COLUMN brickshare_pudo_id SET NOT NULL;
    END IF;
END $$;