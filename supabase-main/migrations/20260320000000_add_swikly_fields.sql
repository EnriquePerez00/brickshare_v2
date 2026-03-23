-- Add Swikly deposit fields to assignments table
-- swikly_status flow: pending → wish_created → accepted → released | captured | expired | cancelled

ALTER TABLE envios ADD COLUMN IF NOT EXISTS swikly_wish_id TEXT;
ALTER TABLE envios ADD COLUMN IF NOT EXISTS swikly_wish_url TEXT;
ALTER TABLE envios ADD COLUMN IF NOT EXISTS swikly_status TEXT DEFAULT 'pending';
ALTER TABLE envios ADD COLUMN IF NOT EXISTS swikly_deposit_amount INTEGER; -- stored in cents (€ × 100)

-- Check constraint on swikly_status
ALTER TABLE envios DROP CONSTRAINT IF EXISTS envios_swikly_status_check;
ALTER TABLE envios ADD CONSTRAINT envios_swikly_status_check
  CHECK (swikly_status IN ('pending', 'wish_created', 'accepted', 'released', 'captured', 'expired', 'cancelled'));

-- Index for fast wish_id lookups (used by swikly-webhook)
CREATE INDEX IF NOT EXISTS envios_swikly_wish_id_idx ON envios(swikly_wish_id);
