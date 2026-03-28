-- Migration: Fix PUDO IDs Format
-- Description: Normalize brickshare_pudo_locations IDs from BS-PUDO-XXX to brickshare-XXX
-- This ensures alignment with the Brickshare API format and prevents hardcoded values

-- 1. Delete incorrect hardcoded data with old format
DELETE FROM public.brickshare_pudo_locations 
WHERE id IN ('BS-PUDO-001', 'BS-PUDO-002');

-- 2. Insert correct data with new format (brickshare-XXX)
INSERT INTO public.brickshare_pudo_locations (
  id, name, address, city, postal_code, province, 
  latitude, longitude, contact_email, is_active
) VALUES 
  ('brickshare-001', 'Brickshare Madrid Centro', 'Calle Gran Vía 28', 'Madrid', '28013', 'Madrid', 40.4200, -3.7038, 'madrid.centro@brickshare.com', true),
  ('brickshare-002', 'Brickshare Barcelona Eixample', 'Passeig de Gràcia 100', 'Barcelona', '08008', 'Barcelona', 41.3926, 2.1640, 'barcelona.eixample@brickshare.com', true)
ON CONFLICT (id) DO NOTHING;

-- 3. Update users with old PUDO IDs to new format
UPDATE public.users
SET pudo_id = 'brickshare-001'
WHERE pudo_id IN ('BS-PUDO-001', 'BS-PUDO-002')
  AND pudo_type = 'brickshare';

-- 4. Update users_brickshare_dropping table
UPDATE public.users_brickshare_dropping
SET brickshare_pudo_id = 'brickshare-001'
WHERE brickshare_pudo_id IN ('BS-PUDO-001', 'BS-PUDO-002');

-- 5. Update shipments with old PUDO IDs to new format
UPDATE public.shipments
SET brickshare_pudo_id = 'brickshare-001'
WHERE brickshare_pudo_id IN ('BS-PUDO-001', 'BS-PUDO-002');

-- Verify migration results (commented as informational only)
-- Users with brickshare PUDO IDs updated
-- Dropping records updated
-- Shipments updated
-- PUDO locations with brickshare-* format created

-- Update table comment to document the format
COMMENT ON TABLE public.brickshare_pudo_locations IS 
'Brickshare PUDO locations. IDs MUST follow format: brickshare-XXX (never hardcode like BS-PUDO-001)';

-- Update column comment
COMMENT ON COLUMN public.brickshare_pudo_locations.id IS 
'Unique identifier in format brickshare-XXX (e.g., brickshare-001). IMPORTANT: Use dynamic values from API, never hardcode.';