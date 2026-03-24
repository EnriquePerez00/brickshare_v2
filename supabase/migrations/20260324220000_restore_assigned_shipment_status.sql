-- ============================================================================
-- Migration: Restore 'assigned' shipment status
-- Date: 2026-03-24
-- Description:
--   Restore 'assigned' status to check_shipment_status constraint.
--   This status is used when a set has been assigned to a user and payment
--   has been processed, but physical preparation has not yet started.
--
-- Flow after this change:
--   assigned → preparation → in_transit_pudo → delivered_pudo → delivered_user
--
-- Context:
--   Migration 20260322170000 removed 'assigned' by merging it with 'in_transit_pudo'
--   However, subsequent migrations (20260324170000, 20260324200730) reintroduced
--   the use of 'assigned' in confirm_assign_sets_to_users function.
--   This migration restores 'assigned' to maintain semantic clarity.
-- ============================================================================

-- Drop existing constraint
ALTER TABLE public.shipments 
  DROP CONSTRAINT IF EXISTS check_shipment_status;

-- Recreate constraint with 'assigned' restored
ALTER TABLE public.shipments 
  ADD CONSTRAINT check_shipment_status
  CHECK (shipment_status IN (
    'pending',        -- Initial state
    'assigned',       -- ✨ RESTORED: Assigned after payment confirmation
    'preparation',    -- Being prepared in warehouse
    'in_transit_pudo', -- In transit to PUDO point
    'delivered_pudo',  -- Delivered at PUDO, waiting for user pickup
    'delivered_user',  -- User picked up from PUDO
    'in_return_pudo',  -- User returned to PUDO
    'in_return',       -- In transit from PUDO to warehouse
    'returned',        -- Returned to warehouse
    'cancelled'        -- Cancelled
  ));

-- Add comment explaining the status flow
COMMENT ON CONSTRAINT check_shipment_status ON public.shipments IS 
  'Valid shipment status values. Delivery flow: assigned → preparation → in_transit_pudo → delivered_pudo → delivered_user. Return flow: in_return_pudo → in_return → returned';