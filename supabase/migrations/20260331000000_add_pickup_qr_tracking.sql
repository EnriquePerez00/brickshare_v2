-- Migration: Pickup QR Code Tracking
-- Description: Add fields to track reception and pickup validation at Brickshare PUDO points
-- This enables the PUDO staff to differentiate between:
--   - delivery_qr_code: Used when the logistics company delivers the package to the PUDO
--   - pickup_qr_code: Used when the user picks up their set at the PUDO

-- Add pickup tracking columns to shipments table
-- These are placed after delivery_validated_at for logical grouping
ALTER TABLE shipments
ADD COLUMN IF NOT EXISTS pickup_qr_code TEXT UNIQUE,
ADD COLUMN IF NOT EXISTS pickup_validated_at TIMESTAMPTZ;

-- Create index for pickup QR code lookups (for PUDO staff scanning)
CREATE INDEX IF NOT EXISTS idx_shipments_pickup_qr 
ON shipments(pickup_qr_code) 
WHERE pickup_qr_code IS NOT NULL;

-- Add comments explaining the fields
COMMENT ON COLUMN shipments.pickup_qr_code IS 
'QR code sent to the user via email for pickup at the Brickshare PUDO point. PUDO staff can scan this to validate that the user has picked up their set. This is different from delivery_qr_code which is used by logistics to deliver the package.';

COMMENT ON COLUMN shipments.pickup_validated_at IS 
'Timestamp when the PUDO staff scanned the pickup_qr_code and validated that the user successfully picked up their LEGO set. Set automatically when pickup QR code is scanned.';
