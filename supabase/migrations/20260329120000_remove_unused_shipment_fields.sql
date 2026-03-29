-- Migration: Remove 7 unused shipment fields
-- Date: 2026-03-29
-- Impact: Drops unused columns from shipments table that were never populated or used
-- Fields removed: carrier, additional_notes, return_request_date, pickup_provider, label_url, pickup_id, brickshare_metadata

ALTER TABLE public.shipments 
DROP COLUMN IF EXISTS carrier,
DROP COLUMN IF EXISTS additional_notes,
DROP COLUMN IF EXISTS return_request_date,
DROP COLUMN IF EXISTS pickup_provider,
DROP COLUMN IF EXISTS label_url,
DROP COLUMN IF EXISTS pickup_id,
DROP COLUMN IF EXISTS brickshare_metadata;

COMMENT ON TABLE public.shipments IS 'Stores shipment records with tracking, delivery status, and PUDO location information';