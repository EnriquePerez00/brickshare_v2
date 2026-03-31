-- ============================================================================
-- Migration: Refactor shipment_status values
-- Date: 2026-03-22
-- Description: 
--   - in_transit → in_transit_pudo
--   - assigned → in_transit_pudo (merged)
--   - delivered → delivered_user
--   - NEW: delivered_pudo
--   - return_in_transit → in_return_pudo
--   - NEW: (no in_return — removed by design)
--   - returned stays as returned (deposited at central office)
-- ============================================================================

-- ============================================================================
-- STEP 1: Drop old constraint
-- ============================================================================

ALTER TABLE public.shipments DROP CONSTRAINT IF EXISTS check_shipment_status;

-- ============================================================================
-- STEP 2: Migrate existing data
-- ============================================================================

UPDATE public.shipments SET shipment_status = 'in_transit_pudo' WHERE shipment_status = 'assigned';
UPDATE public.shipments SET shipment_status = 'in_transit_pudo' WHERE shipment_status = 'in_transit';
UPDATE public.shipments SET shipment_status = 'delivered_user' WHERE shipment_status = 'delivered';
UPDATE public.shipments SET shipment_status = 'in_return_pudo' WHERE shipment_status = 'return_in_transit';

-- ============================================================================
-- STEP 3: Add new constraint with updated values
-- ============================================================================

ALTER TABLE public.shipments ADD CONSTRAINT check_shipment_status
  CHECK (shipment_status IN (
    'pending',
    'preparation',
    'in_transit_pudo',
    'delivered_pudo',
    'delivered_user',
    'in_return_pudo',
    'returned',
    'cancelled'
  ));

-- ============================================================================
-- STEP 4: Drop and recreate triggers (to avoid issues with function replacement)
-- ============================================================================

DROP TRIGGER IF EXISTS on_shipment_delivered ON public.shipments;
DROP TRIGGER IF EXISTS on_shipment_warehouse_received ON public.shipments;
DROP TRIGGER IF EXISTS on_shipment_return_user_status ON public.shipments;
DROP TRIGGER IF EXISTS on_shipment_return_transit_inv ON public.shipments;

-- ============================================================================
-- STEP 5: Update functions
-- ============================================================================

-- 5a: handle_shipment_delivered — now triggers on 'delivered_user'
CREATE OR REPLACE FUNCTION public.handle_shipment_delivered()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    IF NEW.shipment_status = 'delivered_user' AND OLD.shipment_status != 'delivered_user' THEN
        UPDATE public.users SET user_status = 'has_set' WHERE user_id = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$;

-- 5b: handle_shipment_return_transit_inventory — now triggers on 'in_return_pudo'
CREATE OR REPLACE FUNCTION public.handle_shipment_return_transit_inventory()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    IF NEW.shipment_status = 'in_return_pudo' AND OLD.shipment_status != 'in_return_pudo' THEN
        UPDATE public.inventory_sets
        SET in_return = COALESCE(in_return, 0) + 1, updated_at = now()
        WHERE set_id = NEW.set_id;
    END IF;
    RETURN NEW;
END;
$$;

-- 5c: handle_return_user_status — now triggers on 'in_return_pudo'
CREATE OR REPLACE FUNCTION public.handle_return_user_status()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    IF NEW.shipment_status = 'in_return_pudo' AND OLD.shipment_status != 'in_return_pudo' THEN
        UPDATE public.users SET user_status = 'no_set' WHERE user_id = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$;

-- 5d: delete_assignment_and_rollback — update status check from 'in_transit' to 'in_transit_pudo'
CREATE OR REPLACE FUNCTION public.delete_assignment_and_rollback(p_envio_id uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public' AS $$
DECLARE
    v_user_id UUID;
    v_set_id UUID;
BEGIN
    SELECT user_id, set_id INTO v_user_id, v_set_id FROM public.shipments WHERE id = p_envio_id;
    IF v_user_id IS NULL THEN RAISE EXCEPTION 'Shipment with ID % not found', p_envio_id; END IF;

    DELETE FROM public.shipments WHERE id = p_envio_id;

    UPDATE public.inventory_sets
    SET inventory_set_total_qty = inventory_set_total_qty + 1, in_shipping = GREATEST(in_shipping - 1, 0)
    WHERE set_id = v_set_id;

    INSERT INTO public.wishlist (user_id, set_id) VALUES (v_user_id, v_set_id) ON CONFLICT (user_id, set_id) DO NOTHING;

    UPDATE public.users
    SET user_status = CASE 
        WHEN EXISTS (SELECT 1 FROM public.shipments WHERE user_id = v_user_id AND shipment_status IN ('preparation', 'in_transit_pudo'))
        THEN user_status ELSE 'no_set' END
    WHERE user_id = v_user_id;
END;
$$;

-- 5e: confirm_qr_validation — update 'delivered' to 'delivered_user' (NO change to QR logic per user request)
-- NOTE: Not modifying QR logic, just updating the status value it writes
CREATE OR REPLACE FUNCTION public.confirm_qr_validation(p_qr_code text, p_validated_by text DEFAULT NULL)
RETURNS TABLE(success boolean, message text, shipment_id uuid) LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_validation RECORD;
    v_new_status TEXT;
BEGIN
    SELECT * INTO v_validation FROM validate_qr_code(p_qr_code);
    IF NOT v_validation.is_valid THEN
        RETURN QUERY SELECT false, v_validation.error_message, v_validation.shipment_id; RETURN;
    END IF;

    IF v_validation.validation_type = 'delivery' THEN
        v_new_status := 'delivered_user';
        UPDATE shipments SET delivery_validated_at = now(), shipment_status = v_new_status, updated_at = now() WHERE id = v_validation.shipment_id;
    ELSIF v_validation.validation_type = 'return' THEN
        v_new_status := 'returned';
        UPDATE shipments SET return_validated_at = now(), shipment_status = v_new_status, updated_at = now() WHERE id = v_validation.shipment_id;
    END IF;

    INSERT INTO qr_validation_logs (shipment_id, qr_code, validation_type, validated_by, validation_status, metadata)
    VALUES (v_validation.shipment_id, p_qr_code, v_validation.validation_type, p_validated_by, 'success', jsonb_build_object('validated_at', now()));

    RETURN QUERY SELECT true, format('Shipment successfully %s', CASE WHEN v_validation.validation_type = 'delivery' THEN 'delivered' ELSE 'returned' END), v_validation.shipment_id;
END;
$$;

-- ============================================================================
-- STEP 6: Recreate triggers
-- ============================================================================

CREATE TRIGGER on_shipment_delivered AFTER UPDATE ON public.shipments FOR EACH ROW EXECUTE FUNCTION public.handle_shipment_delivered();
CREATE TRIGGER on_shipment_warehouse_received BEFORE UPDATE ON public.shipments FOR EACH ROW EXECUTE FUNCTION public.handle_shipment_warehouse_received();
CREATE TRIGGER on_shipment_return_user_status AFTER UPDATE ON public.shipments FOR EACH ROW EXECUTE FUNCTION public.handle_return_user_status();
CREATE TRIGGER on_shipment_return_transit_inv AFTER UPDATE ON public.shipments FOR EACH ROW EXECUTE FUNCTION public.handle_shipment_return_transit_inventory();

-- ============================================================================
-- STEP 7: Update RLS policy for user returns (was 'return_in_transit', now 'in_return_pudo')
-- ============================================================================

DROP POLICY IF EXISTS "Users can update own shipment status" ON public.shipments;

CREATE POLICY "Users can update own shipment status" ON public.shipments
    FOR UPDATE TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id AND shipment_status = 'in_return_pudo');