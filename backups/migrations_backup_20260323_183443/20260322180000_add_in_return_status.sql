-- ============================================================================
-- Migration: Add 'in_return' shipment status
-- Date: 2026-03-22
-- Description:
--   Adds 'in_return' status = set en tránsito entre PUDO y oficina central
--   Flow: in_return_pudo → in_return → returned
-- ============================================================================

-- Drop and recreate constraint with new value
ALTER TABLE public.shipments DROP CONSTRAINT IF EXISTS check_shipment_status;

ALTER TABLE public.shipments ADD CONSTRAINT check_shipment_status
  CHECK (shipment_status IN (
    'pending',
    'preparation',
    'in_transit_pudo',
    'delivered_pudo',
    'delivered_user',
    'in_return_pudo',
    'in_return',
    'returned',
    'cancelled'
  ));