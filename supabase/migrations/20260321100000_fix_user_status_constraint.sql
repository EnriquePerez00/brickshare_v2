-- Fix: Add 'con set' to check_user_status constraint
-- The trigger handle_envio_entregado sets user_status = 'con set' when a shipment
-- is delivered, but this value was missing from the CHECK constraint.
-- This causes ANY update to a user row with status 'con set' to fail,
-- including profile updates (name, address, phone, etc.)

ALTER TABLE public.users DROP CONSTRAINT IF EXISTS check_user_status;

ALTER TABLE public.users
ADD CONSTRAINT check_user_status
CHECK (user_status IN (
  'set en envio',
  'sin set',
  'recibido',
  'con set',
  'set en devolucion',
  'suspendido',
  'cancelado'
));

COMMENT ON COLUMN public.users.user_status IS 'Allowed values: set en envio, sin set, recibido, con set, set en devolucion, suspendido, cancelado';