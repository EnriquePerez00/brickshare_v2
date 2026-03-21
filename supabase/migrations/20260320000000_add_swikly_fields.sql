-- Add Swikly deposit fields to assignments table
-- swikly_status flow: pending → wish_created → accepted → released | captured | expired | cancelled

ALTER TABLE assignments ADD COLUMN IF NOT EXISTS swikly_wish_id TEXT;
ALTER TABLE assignments ADD COLUMN IF NOT EXISTS swikly_wish_url TEXT;
ALTER TABLE assignments ADD COLUMN IF NOT EXISTS swikly_status TEXT DEFAULT 'pending';
ALTER TABLE assignments ADD COLUMN IF NOT EXISTS swikly_deposit_amount INTEGER; -- stored in cents (€ × 100)

-- Check constraint on swikly_status
ALTER TABLE assignments DROP CONSTRAINT IF EXISTS assignments_swikly_status_check;
ALTER TABLE assignments ADD CONSTRAINT assignments_swikly_status_check
  CHECK (swikly_status IN ('pending', 'wish_created', 'accepted', 'released', 'captured', 'expired', 'cancelled'));

-- Index for fast wish_id lookups (used by swikly-webhook)
CREATE INDEX IF NOT EXISTS assignments_swikly_wish_id_idx ON assignments(swikly_wish_id);