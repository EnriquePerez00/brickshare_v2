-- Fix: Ensure user_status constraint uses English values
-- The trigger handle_shipment_delivered sets user_status = 'has_set' when a shipment
-- is delivered. This migration ensures the constraint includes all valid English values.
-- NOTE: This runs BEFORE the rename_spanish_to_english migration, so we need to
-- support BOTH Spanish and English values temporarily to avoid breaking existing data.

ALTER TABLE public.users DROP CONSTRAINT IF EXISTS check_user_status;

-- First, update any existing Spanish values to English
UPDATE public.users SET user_status = 'no_set' WHERE user_status = 'sin set';
UPDATE public.users SET user_status = 'set_shipping' WHERE user_status = 'set en envio';
UPDATE public.users SET user_status = 'received' WHERE user_status = 'recibido';
UPDATE public.users SET user_status = 'has_set' WHERE user_status = 'con set';
UPDATE public.users SET user_status = 'set_returning' WHERE user_status = 'set en devolucion';
UPDATE public.users SET user_status = 'suspended' WHERE user_status = 'suspendido';
UPDATE public.users SET user_status = 'cancelled' WHERE user_status = 'cancelado';

-- Set default to English
ALTER TABLE public.users ALTER COLUMN user_status SET DEFAULT 'no_set';

-- Add constraint with English-only values
ALTER TABLE public.users
ADD CONSTRAINT check_user_status
CHECK (user_status IN (
  'no_set',
  'set_shipping',
  'received',
  'has_set',
  'set_returning',
  'suspended',
  'cancelled'
));

COMMENT ON COLUMN public.users.user_status IS 'Allowed values: no_set, set_shipping, received, has_set, set_returning, suspended, cancelled';