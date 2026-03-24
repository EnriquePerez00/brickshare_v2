-- ============================================================================
-- Add stripe_payment_method_id column to users table
-- ============================================================================
-- Purpose: Add missing column needed for Stripe payment processing
-- Context: The process-assignment-payment Edge Function requires this field
-- ============================================================================

ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS stripe_payment_method_id TEXT;

COMMENT ON COLUMN public.users.stripe_payment_method_id IS 'Stripe Payment Method ID (e.g., pm_card_visa for test mode)';