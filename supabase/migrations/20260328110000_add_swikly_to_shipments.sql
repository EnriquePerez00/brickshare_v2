-- ═══════════════════════════════════════════════════════════════
-- Add Swikly deposit fields to shipments table
-- This allows tracking Swikly guarantees at the shipment level
-- (previously only tracked on assignments)
-- ═══════════════════════════════════════════════════════════════

ALTER TABLE shipments
ADD COLUMN IF NOT EXISTS swikly_wish_id TEXT,
ADD COLUMN IF NOT EXISTS swikly_wish_url TEXT,
ADD COLUMN IF NOT EXISTS swikly_status TEXT DEFAULT 'pending',
ADD COLUMN IF NOT EXISTS swikly_deposit_amount INTEGER;

-- Index for webhook lookups by wish_id
CREATE INDEX IF NOT EXISTS idx_shipments_swikly_wish_id
ON shipments(swikly_wish_id)
WHERE swikly_wish_id IS NOT NULL;

COMMENT ON COLUMN shipments.swikly_wish_id IS 'Swikly wish ID for the deposit guarantee';
COMMENT ON COLUMN shipments.swikly_wish_url IS 'URL for the user to complete the deposit guarantee';
COMMENT ON COLUMN shipments.swikly_status IS 'Deposit status: pending, wish_created, accepted, declined, cancelled, expired, released, captured';
COMMENT ON COLUMN shipments.swikly_deposit_amount IS 'Deposit amount in cents, based on sets.set_pvp_release';