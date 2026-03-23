-- ============================================================================
-- Migration: Rename all Spanish table/column names to English
-- Date: 2026-03-22
-- Description: Standardize all database identifiers to English
-- ============================================================================

-- ============================================================================
-- STEP 1: Rename tables
-- ============================================================================

ALTER TABLE public.envios RENAME TO shipments;
ALTER TABLE public.operaciones_recepcion RENAME TO reception_operations;

-- ============================================================================
-- STEP 2: Rename columns in shipments (formerly envios)
-- ============================================================================

ALTER TABLE public.shipments RENAME COLUMN estado_envio TO shipment_status;
ALTER TABLE public.shipments RENAME COLUMN estado_manipulacion TO handling_processed;
ALTER TABLE public.shipments RENAME COLUMN direccion_envio TO shipping_address;
ALTER TABLE public.shipments RENAME COLUMN ciudad_envio TO shipping_city;
ALTER TABLE public.shipments RENAME COLUMN codigo_postal_envio TO shipping_zip_code;
ALTER TABLE public.shipments RENAME COLUMN pais_envio TO shipping_country;
ALTER TABLE public.shipments RENAME COLUMN proveedor_envio TO shipping_provider;
ALTER TABLE public.shipments RENAME COLUMN proveedor_recogida TO pickup_provider;
ALTER TABLE public.shipments RENAME COLUMN numero_seguimiento TO tracking_number;
ALTER TABLE public.shipments RENAME COLUMN transportista TO carrier;
ALTER TABLE public.shipments RENAME COLUMN notas_adicionales TO additional_notes;
ALTER TABLE public.shipments RENAME COLUMN fecha_asignada TO assigned_date;
ALTER TABLE public.shipments RENAME COLUMN fecha_entrega TO estimated_delivery_date;
ALTER TABLE public.shipments RENAME COLUMN fecha_entrega_real TO actual_delivery_date;
ALTER TABLE public.shipments RENAME COLUMN fecha_entrega_usuario TO user_delivery_date;
ALTER TABLE public.shipments RENAME COLUMN fecha_recepcion_almacen TO warehouse_reception_date;
ALTER TABLE public.shipments RENAME COLUMN fecha_recogida_almacen TO warehouse_pickup_date;
ALTER TABLE public.shipments RENAME COLUMN fecha_solicitud_devolucion TO return_request_date;
ALTER TABLE public.shipments RENAME COLUMN fecha_devolucion_estimada TO estimated_return_date;
ALTER TABLE public.shipments RENAME COLUMN direccion_proveedor_recogida TO pickup_provider_address;

-- ============================================================================
-- STEP 3: Rename columns in reception_operations (formerly operaciones_recepcion)
-- ============================================================================

ALTER TABLE public.reception_operations RENAME COLUMN status_recepcion TO reception_completed;

-- ============================================================================
-- STEP 4: Rename columns in inventory_sets
-- ============================================================================

ALTER TABLE public.inventory_sets RENAME COLUMN en_envio TO in_shipping;
ALTER TABLE public.inventory_sets RENAME COLUMN en_uso TO in_use;
ALTER TABLE public.inventory_sets RENAME COLUMN en_devolucion TO in_return;
ALTER TABLE public.inventory_sets RENAME COLUMN en_reparacion TO in_repair;

-- ============================================================================
-- STEP 5: Rename columns in donations
-- ============================================================================

ALTER TABLE public.donations RENAME COLUMN nombre TO name;
ALTER TABLE public.donations RENAME COLUMN telefono TO phone;
ALTER TABLE public.donations RENAME COLUMN direccion TO address;
ALTER TABLE public.donations RENAME COLUMN peso_estimado TO estimated_weight;
ALTER TABLE public.donations RENAME COLUMN metodo_entrega TO delivery_method;
ALTER TABLE public.donations RENAME COLUMN recompensa TO reward;
ALTER TABLE public.donations RENAME COLUMN ninos_beneficiados TO children_benefited;
ALTER TABLE public.donations RENAME COLUMN co2_evitado TO co2_avoided;

-- ============================================================================
-- STEP 6: Drop duplicate Spanish columns in users table
-- ============================================================================

ALTER TABLE public.users DROP COLUMN IF EXISTS direccion;
ALTER TABLE public.users DROP COLUMN IF EXISTS codigo_postal;
ALTER TABLE public.users DROP COLUMN IF EXISTS ciudad;
ALTER TABLE public.users DROP COLUMN IF EXISTS telefono;

-- ============================================================================
-- STEP 7: Update shipment_status enum values (Spanish → English)
-- ============================================================================

-- Drop old constraint
ALTER TABLE public.shipments DROP CONSTRAINT IF EXISTS check_estado_envio;

-- Update existing data
UPDATE public.shipments SET shipment_status = 'preparation' WHERE shipment_status = 'preparacion';
UPDATE public.shipments SET shipment_status = 'in_transit' WHERE shipment_status = 'ruta_envio';
UPDATE public.shipments SET shipment_status = 'delivered' WHERE shipment_status = 'entregado';
UPDATE public.shipments SET shipment_status = 'returned' WHERE shipment_status = 'devuelto';
UPDATE public.shipments SET shipment_status = 'return_in_transit' WHERE shipment_status = 'ruta_devolucion';
UPDATE public.shipments SET shipment_status = 'cancelled' WHERE shipment_status = 'cancelado';
UPDATE public.shipments SET shipment_status = 'pending' WHERE shipment_status = 'pendiente';
UPDATE public.shipments SET shipment_status = 'assigned' WHERE shipment_status = 'asignado';

-- Add new constraint with English values
ALTER TABLE public.shipments ADD CONSTRAINT check_shipment_status 
  CHECK (shipment_status IN ('pending', 'preparation', 'assigned', 'in_transit', 'delivered', 'returned', 'return_in_transit', 'cancelled'));

-- ============================================================================
-- STEP 8: Update set_status enum values (Spanish → English)
-- ============================================================================

ALTER TABLE public.sets DROP CONSTRAINT IF EXISTS check_set_status_spanish;

UPDATE public.sets SET set_status = 'active' WHERE set_status = 'activo';
UPDATE public.sets SET set_status = 'inactive' WHERE set_status = 'inactivo';
UPDATE public.sets SET set_status = 'in_repair' WHERE set_status = 'en reparacion';

ALTER TABLE public.sets ADD CONSTRAINT check_set_status 
  CHECK (set_status IN ('active', 'inactive', 'in_repair'));

-- Update default
ALTER TABLE public.sets ALTER COLUMN set_status SET DEFAULT 'inactive';

-- ============================================================================
-- STEP 9: Update user_status enum values (Spanish → English)
-- ============================================================================

ALTER TABLE public.users DROP CONSTRAINT IF EXISTS check_user_status;

UPDATE public.users SET user_status = 'no_set' WHERE user_status = 'sin set';
UPDATE public.users SET user_status = 'set_shipping' WHERE user_status = 'set en envio';
UPDATE public.users SET user_status = 'received' WHERE user_status = 'recibido';
UPDATE public.users SET user_status = 'has_set' WHERE user_status = 'con set';
UPDATE public.users SET user_status = 'set_returning' WHERE user_status = 'set en devolucion';
UPDATE public.users SET user_status = 'suspended' WHERE user_status = 'suspendido';
UPDATE public.users SET user_status = 'cancelled' WHERE user_status = 'cancelado';

ALTER TABLE public.users ADD CONSTRAINT check_user_status 
  CHECK (user_status IN ('no_set', 'set_shipping', 'received', 'has_set', 'set_returning', 'suspended', 'cancelled'));

ALTER TABLE public.users ALTER COLUMN user_status SET DEFAULT 'no_set';

-- ============================================================================
-- STEP 10: Update donation enum values
-- ============================================================================

ALTER TABLE public.donations DROP CONSTRAINT IF EXISTS donations_metodo_entrega_check;
ALTER TABLE public.donations DROP CONSTRAINT IF EXISTS donations_recompensa_check;

UPDATE public.donations SET delivery_method = 'pickup-point' WHERE delivery_method = 'punto-recogida';
UPDATE public.donations SET delivery_method = 'home-pickup' WHERE delivery_method = 'recogida-domicilio';
UPDATE public.donations SET reward = 'economic' WHERE reward = 'economica';

ALTER TABLE public.donations ADD CONSTRAINT donations_delivery_method_check 
  CHECK (delivery_method IN ('pickup-point', 'home-pickup'));
ALTER TABLE public.donations ADD CONSTRAINT donations_reward_check 
  CHECK (reward IN ('economic', 'social'));

-- ============================================================================
-- STEP 11: Drop and recreate the brickshare_pudo_shipments VIEW
-- ============================================================================

DROP VIEW IF EXISTS public.brickshare_pudo_shipments;

CREATE OR REPLACE VIEW public.brickshare_pudo_shipments AS
SELECT 
    id,
    user_id,
    shipment_status AS status,
    pickup_type,
    brickshare_pudo_id,
    brickshare_package_id,
    delivery_qr_code,
    delivery_validated_at AS delivery_qr_validated_at,
    return_qr_code,
    return_validated_at AS return_qr_validated_at,
    tracking_number,
    created_at,
    updated_at
FROM public.shipments s
WHERE pickup_type = 'brickshare' AND brickshare_pudo_id IS NOT NULL;

-- ============================================================================
-- STEP 12: Drop triggers first, then drop and recreate functions
-- ============================================================================

-- Drop ALL triggers on shipments and reception_operations FIRST (before dropping functions)
DROP TRIGGER IF EXISTS on_envio_entregado ON public.shipments;
DROP TRIGGER IF EXISTS on_envio_recibido_almacen ON public.shipments;
DROP TRIGGER IF EXISTS on_envio_return_update ON public.shipments;
DROP TRIGGER IF EXISTS on_envio_ruta_devolucion_inv ON public.shipments;
DROP TRIGGER IF EXISTS update_envios_updated_at ON public.shipments;
DROP TRIGGER IF EXISTS on_shipment_delivered ON public.shipments;
DROP TRIGGER IF EXISTS on_shipment_warehouse_received ON public.shipments;
DROP TRIGGER IF EXISTS on_shipment_return_user_status ON public.shipments;
DROP TRIGGER IF EXISTS on_shipment_return_transit_inv ON public.shipments;
DROP TRIGGER IF EXISTS update_shipments_updated_at ON public.shipments;
DROP TRIGGER IF EXISTS on_recepcion_completada ON public.reception_operations;
DROP TRIGGER IF EXISTS update_operaciones_recepcion_updated_at ON public.reception_operations;
DROP TRIGGER IF EXISTS on_reception_completed ON public.reception_operations;
DROP TRIGGER IF EXISTS update_reception_operations_updated_at ON public.reception_operations;

-- Now drop all functions (safe since triggers are gone)
DROP FUNCTION IF EXISTS public.preview_assign_sets_to_users();
DROP FUNCTION IF EXISTS public.confirm_assign_sets_to_users(uuid[]);
DROP FUNCTION IF EXISTS public.assign_sets_to_users();
DROP FUNCTION IF EXISTS public.delete_assignment_and_rollback(uuid);
DROP FUNCTION IF EXISTS public.update_set_status_from_return(uuid, text, uuid);
DROP FUNCTION IF EXISTS public.confirm_qr_validation(text, text);
DROP FUNCTION IF EXISTS public.validate_qr_code(text);
DROP FUNCTION IF EXISTS public.generate_delivery_qr(uuid);
DROP FUNCTION IF EXISTS public.generate_return_qr(uuid);
DROP FUNCTION IF EXISTS public.uses_brickshare_pudo(uuid);
DROP FUNCTION IF EXISTS public.handle_envio_entregado();
DROP FUNCTION IF EXISTS public.handle_envio_recibido_almacen();
DROP FUNCTION IF EXISTS public.handle_envio_ruta_devolucion_inventory();
DROP FUNCTION IF EXISTS public.handle_return_status_update();
DROP FUNCTION IF EXISTS public.handle_cierre_recepcion();
DROP FUNCTION IF EXISTS public.handle_shipment_delivered();
DROP FUNCTION IF EXISTS public.handle_shipment_warehouse_received();
DROP FUNCTION IF EXISTS public.handle_shipment_return_transit_inventory();
DROP FUNCTION IF EXISTS public.handle_return_user_status();
DROP FUNCTION IF EXISTS public.handle_reception_close();

-- 12a: handle_envio_entregado → handle_shipment_delivered
CREATE OR REPLACE FUNCTION public.handle_shipment_delivered()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    IF NEW.shipment_status = 'delivered' AND OLD.shipment_status != 'delivered' THEN
        UPDATE public.users SET user_status = 'has_set' WHERE user_id = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$;

-- 12b: handle_envio_recibido_almacen → handle_shipment_warehouse_received
CREATE OR REPLACE FUNCTION public.handle_shipment_warehouse_received()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    IF NEW.shipment_status = 'returned' AND OLD.shipment_status != 'returned' THEN
        INSERT INTO public.reception_operations (event_id, user_id, set_id)
        VALUES (NEW.id, NEW.user_id, NEW.set_id);
        NEW.warehouse_reception_date = now();
    END IF;
    RETURN NEW;
END;
$$;

-- 12c: handle_envio_ruta_devolucion_inventory → handle_shipment_return_transit_inventory
CREATE OR REPLACE FUNCTION public.handle_shipment_return_transit_inventory()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    IF NEW.shipment_status = 'return_in_transit' AND OLD.shipment_status != 'return_in_transit' THEN
        UPDATE public.inventory_sets
        SET in_return = COALESCE(in_return, 0) + 1, updated_at = now()
        WHERE set_id = NEW.set_id;
    END IF;
    RETURN NEW;
END;
$$;

-- 12d: handle_return_status_update → handle_return_user_status
CREATE OR REPLACE FUNCTION public.handle_return_user_status()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    IF NEW.shipment_status = 'return_in_transit' AND OLD.shipment_status != 'return_in_transit' THEN
        UPDATE public.users SET user_status = 'no_set' WHERE user_id = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$;

-- 12e: handle_cierre_recepcion → handle_reception_close
CREATE OR REPLACE FUNCTION public.handle_reception_close()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    IF NEW.reception_completed = TRUE AND OLD.reception_completed = FALSE THEN
        UPDATE public.inventory_sets
        SET in_return = GREATEST(0, COALESCE(in_return, 0) - 1), updated_at = now()
        WHERE set_id = NEW.set_id;

        IF NEW.missing_parts IS NOT NULL AND TRIM(NEW.missing_parts) != '' THEN
            UPDATE public.inventory_sets SET in_repair = COALESCE(in_repair, 0) + 1 WHERE set_id = NEW.set_id;
            UPDATE public.sets SET set_status = 'in_repair', updated_at = now() WHERE id = NEW.set_id;
        ELSE
            UPDATE public.sets SET set_status = 'active', updated_at = now() WHERE id = NEW.set_id;
        END IF;

        UPDATE public.shipments SET handling_processed = TRUE, updated_at = now() WHERE id = NEW.event_id;
    END IF;
    RETURN NEW;
END;
$$;

-- 12f: delete_assignment_and_rollback
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
        WHEN EXISTS (SELECT 1 FROM public.shipments WHERE user_id = v_user_id AND shipment_status IN ('preparation', 'in_transit'))
        THEN user_status ELSE 'no_set' END
    WHERE user_id = v_user_id;
END;
$$;

-- 12g: preview_assign_sets_to_users
CREATE OR REPLACE FUNCTION public.preview_assign_sets_to_users()
RETURNS TABLE(user_id uuid, user_name text, set_id uuid, set_name text, set_ref text, set_price numeric, current_stock integer, matches_wishlist boolean)
LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public' AS $$
DECLARE
    r RECORD;
    v_set_id UUID; v_set_name TEXT; v_set_ref TEXT; v_set_price DECIMAL; v_current_stock INTEGER; v_matches_wishlist BOOLEAN;
BEGIN
    FOR r IN (
        SELECT u.user_id, u.full_name FROM public.users u
        WHERE u.user_status IN ('no_set', 'set_returning') AND u.user_type = 'user'
    ) LOOP
        v_set_id := NULL; v_matches_wishlist := FALSE;
        
        SELECT w.set_id, s.set_name, s.set_ref, COALESCE(s.set_price, 100.00), i.inventory_set_total_qty
        INTO v_set_id, v_set_name, v_set_ref, v_set_price, v_current_stock
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        JOIN public.sets s ON w.set_id = s.id
        WHERE w.user_id = r.user_id AND w.status = true AND i.inventory_set_total_qty > 0
          AND NOT EXISTS (SELECT 1 FROM public.shipments e WHERE e.user_id = r.user_id AND e.set_id = w.set_id)
        ORDER BY w.created_at ASC LIMIT 1;
        
        IF v_set_id IS NOT NULL THEN v_matches_wishlist := TRUE;
        ELSE
            SELECT s.id, s.set_name, s.set_ref, COALESCE(s.set_price, 100.00), i.inventory_set_total_qty
            INTO v_set_id, v_set_name, v_set_ref, v_set_price, v_current_stock
            FROM public.sets s JOIN public.inventory_sets i ON s.id = i.set_id
            WHERE i.inventory_set_total_qty > 0 ORDER BY RANDOM() LIMIT 1;
            v_matches_wishlist := FALSE;
        END IF;
        
        IF v_set_id IS NOT NULL THEN
            preview_assign_sets_to_users.user_id := r.user_id;
            preview_assign_sets_to_users.user_name := r.full_name;
            preview_assign_sets_to_users.set_id := v_set_id;
            preview_assign_sets_to_users.set_name := v_set_name;
            preview_assign_sets_to_users.set_ref := v_set_ref;
            preview_assign_sets_to_users.set_price := v_set_price;
            preview_assign_sets_to_users.current_stock := v_current_stock;
            preview_assign_sets_to_users.matches_wishlist := v_matches_wishlist;
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$;

-- 12h: confirm_assign_sets_to_users
CREATE OR REPLACE FUNCTION public.confirm_assign_sets_to_users(p_user_ids uuid[])
RETURNS TABLE(envio_id uuid, user_id uuid, set_id uuid, order_id uuid, user_name text, user_email text, user_phone text, set_name text, set_ref text, set_weight numeric, set_dim text, pudo_id text, pudo_name text, pudo_address text, pudo_cp text, pudo_city text, pudo_province text, created_at timestamptz)
LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public' AS $$
DECLARE
    r RECORD;
    target_set_id UUID; new_order_id UUID; new_envio_id UUID;
    v_set_name TEXT; v_set_ref TEXT; v_set_weight NUMERIC; v_set_dim TEXT;
    v_user_email TEXT; v_user_phone TEXT;
    v_pudo_id TEXT; v_pudo_name TEXT; v_pudo_address TEXT; v_pudo_cp TEXT; v_pudo_city TEXT; v_pudo_province TEXT;
    v_created_at TIMESTAMPTZ;
BEGIN
    FOR r IN (
        SELECT u.user_id, u.full_name, u.email, u.phone,
               p.correos_id_pudo, p.correos_nombre, p.correos_direccion_completa,
               p.correos_codigo_postal, p.correos_ciudad, p.correos_provincia
        FROM public.users u
        LEFT JOIN public.users_correos_dropping p ON u.user_id = p.user_id
        WHERE u.user_id = ANY(p_user_ids)
          AND u.user_status IN ('no_set', 'set_returning')
          AND EXISTS (SELECT 1 FROM public.wishlist w WHERE w.user_id = u.user_id AND w.status = true)
    ) LOOP
        SELECT w.set_id, s.set_name, s.set_ref, s.set_weight, s.set_dim
        INTO target_set_id, v_set_name, v_set_ref, v_set_weight, v_set_dim
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        JOIN public.sets s ON w.set_id = s.id
        WHERE w.user_id = r.user_id AND w.status = true AND i.inventory_set_total_qty > 0
        ORDER BY w.created_at ASC LIMIT 1;

        IF target_set_id IS NOT NULL THEN
            UPDATE public.inventory_sets SET inventory_set_total_qty = inventory_set_total_qty - 1, in_shipping = in_shipping + 1
            WHERE inventory_sets.set_id = target_set_id;

            INSERT INTO public.orders (user_id, set_id, status) VALUES (r.user_id, target_set_id, 'pending') RETURNING id INTO new_order_id;

            INSERT INTO public.shipments (order_id, user_id, shipment_status, shipping_address, shipping_city, shipping_zip_code, shipping_country)
            VALUES (new_order_id, r.user_id, 'pending',
                    COALESCE(r.correos_direccion_completa, 'Pending assignment'),
                    COALESCE(r.correos_ciudad, 'Pending'),
                    COALESCE(r.correos_codigo_postal, '00000'), 'España')
            RETURNING shipments.id, shipments.created_at INTO new_envio_id, v_created_at;

            UPDATE public.users SET user_status = 'set_shipping' WHERE users.user_id = r.user_id;

            UPDATE public.wishlist SET status = false, status_changed_at = now()
            WHERE wishlist.user_id = r.user_id AND wishlist.set_id = target_set_id;

            confirm_assign_sets_to_users.envio_id := new_envio_id;
            confirm_assign_sets_to_users.user_id := r.user_id;
            confirm_assign_sets_to_users.set_id := target_set_id;
            confirm_assign_sets_to_users.order_id := new_order_id;
            confirm_assign_sets_to_users.user_name := r.full_name;
            confirm_assign_sets_to_users.user_email := r.email;
            confirm_assign_sets_to_users.user_phone := r.phone;
            confirm_assign_sets_to_users.set_name := v_set_name;
            confirm_assign_sets_to_users.set_ref := v_set_ref;
            confirm_assign_sets_to_users.set_weight := v_set_weight;
            confirm_assign_sets_to_users.set_dim := v_set_dim;
            confirm_assign_sets_to_users.pudo_id := r.correos_id_pudo;
            confirm_assign_sets_to_users.pudo_name := r.correos_nombre;
            confirm_assign_sets_to_users.pudo_address := r.correos_direccion_completa;
            confirm_assign_sets_to_users.pudo_cp := r.correos_codigo_postal;
            confirm_assign_sets_to_users.pudo_city := r.correos_ciudad;
            confirm_assign_sets_to_users.pudo_province := r.correos_provincia;
            confirm_assign_sets_to_users.created_at := v_created_at;
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$;

-- 12i: update_set_status_from_return
CREATE OR REPLACE FUNCTION public.update_set_status_from_return(p_set_id uuid, p_new_status text, p_envio_id uuid DEFAULT NULL)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    IF p_new_status NOT IN ('active', 'inactive', 'in_repair') THEN
        RAISE EXCEPTION 'Invalid status: %', p_new_status;
    END IF;

    UPDATE public.sets SET set_status = p_new_status, updated_at = now() WHERE id = p_set_id;

    UPDATE public.inventory_sets SET in_return = in_return - 1, updated_at = now() WHERE set_id = p_set_id;

    IF p_new_status = 'in_repair' THEN
        UPDATE public.inventory_sets SET in_repair = in_repair + 1 WHERE set_id = p_set_id;
    END IF;

    IF p_new_status = 'active' THEN NULL; END IF;

    IF p_envio_id IS NOT NULL THEN
        UPDATE public.shipments SET warehouse_reception_date = now(), handling_processed = TRUE, updated_at = now() WHERE id = p_envio_id;
    END IF;
END;
$$;

-- 12j: confirm_qr_validation
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
        v_new_status := 'delivered';
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

-- 12k: validate_qr_code
CREATE OR REPLACE FUNCTION public.validate_qr_code(p_qr_code text)
RETURNS TABLE(shipment_id uuid, validation_type text, is_valid boolean, error_message text, shipment_info jsonb)
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_shipment RECORD;
    v_is_valid BOOLEAN := false; v_error_message TEXT := NULL; v_validation_type TEXT := NULL; v_shipment_info JSONB;
BEGIN
    SELECT s.id, s.order_id, s.shipment_status as status, s.pickup_type,
        s.delivery_qr_code, s.delivery_qr_expires_at, s.delivery_validated_at,
        s.return_qr_code, s.return_qr_expires_at, s.return_validated_at,
        s.brickshare_pudo_id, o.set_id, st.set_name, st.set_ref as set_number, st.set_theme as theme
    INTO v_shipment
    FROM shipments s JOIN orders o ON s.order_id = o.id LEFT JOIN sets st ON o.set_id = st.id
    WHERE s.delivery_qr_code = p_qr_code OR s.return_qr_code = p_qr_code;

    IF NOT FOUND THEN
        RETURN QUERY SELECT NULL::UUID, NULL::TEXT, false, 'QR code not found'::TEXT, NULL::JSONB; RETURN;
    END IF;

    IF v_shipment.pickup_type != 'brickshare' THEN
        RETURN QUERY SELECT v_shipment.id, NULL::TEXT, false, 'This shipment is not for Brickshare pickup point'::TEXT, NULL::JSONB; RETURN;
    END IF;

    IF v_shipment.delivery_qr_code = p_qr_code THEN
        v_validation_type := 'delivery';
        IF v_shipment.delivery_validated_at IS NOT NULL THEN v_error_message := 'QR code already used';
        ELSIF v_shipment.delivery_qr_expires_at < now() THEN v_error_message := 'QR code has expired';
        ELSE v_is_valid := true; END IF;
    ELSIF v_shipment.return_qr_code = p_qr_code THEN
        v_validation_type := 'return';
        IF v_shipment.return_validated_at IS NOT NULL THEN v_error_message := 'QR code already used';
        ELSIF v_shipment.return_qr_expires_at < now() THEN v_error_message := 'QR code has expired';
        ELSIF v_shipment.delivery_validated_at IS NULL THEN v_error_message := 'Cannot return a set that has not been delivered yet';
        ELSE v_is_valid := true; END IF;
    END IF;

    v_shipment_info := jsonb_build_object('order_id', v_shipment.order_id, 'set_id', v_shipment.set_id, 'set_name', v_shipment.set_name,
        'set_number', v_shipment.set_number, 'theme', v_shipment.theme, 'status', v_shipment.status,
        'brickshare_pudo_id', v_shipment.brickshare_pudo_id, 'validation_type', v_validation_type);

    RETURN QUERY SELECT v_shipment.id, v_validation_type, v_is_valid, v_error_message, v_shipment_info;
END;
$$;

-- 12l: generate_delivery_qr
CREATE OR REPLACE FUNCTION public.generate_delivery_qr(p_shipment_id uuid)
RETURNS TABLE(qr_code text, expires_at timestamptz) LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_qr_code TEXT; v_expires_at TIMESTAMPTZ; v_max_attempts INTEGER := 10; v_attempt INTEGER := 0;
BEGIN
    v_expires_at := now() + interval '30 days';
    LOOP
        v_qr_code := generate_qr_code(); v_attempt := v_attempt + 1;
        IF NOT EXISTS (SELECT 1 FROM shipments WHERE delivery_qr_code = v_qr_code OR return_qr_code = v_qr_code) THEN EXIT; END IF;
        IF v_attempt >= v_max_attempts THEN RAISE EXCEPTION 'Unable to generate unique QR code after % attempts', v_max_attempts; END IF;
    END LOOP;
    UPDATE shipments SET delivery_qr_code = v_qr_code, delivery_qr_expires_at = v_expires_at, updated_at = now() WHERE id = p_shipment_id;
    RETURN QUERY SELECT v_qr_code, v_expires_at;
END;
$$;

-- 12m: generate_return_qr
CREATE OR REPLACE FUNCTION public.generate_return_qr(p_shipment_id uuid)
RETURNS TABLE(qr_code text, expires_at timestamptz) LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_qr_code TEXT; v_expires_at TIMESTAMPTZ; v_max_attempts INTEGER := 10; v_attempt INTEGER := 0;
BEGIN
    v_expires_at := now() + interval '30 days';
    LOOP
        v_qr_code := generate_qr_code(); v_attempt := v_attempt + 1;
        IF NOT EXISTS (SELECT 1 FROM shipments WHERE delivery_qr_code = v_qr_code OR return_qr_code = v_qr_code) THEN EXIT; END IF;
        IF v_attempt >= v_max_attempts THEN RAISE EXCEPTION 'Unable to generate unique QR code after % attempts', v_max_attempts; END IF;
    END LOOP;
    UPDATE shipments SET return_qr_code = v_qr_code, return_qr_expires_at = v_expires_at, updated_at = now() WHERE id = p_shipment_id;
    RETURN QUERY SELECT v_qr_code, v_expires_at;
END;
$$;

-- 12n: uses_brickshare_pudo
CREATE OR REPLACE FUNCTION public.uses_brickshare_pudo(shipment_id uuid)
RETURNS boolean LANGUAGE sql STABLE AS $$
    SELECT pickup_type = 'brickshare' AND brickshare_pudo_id IS NOT NULL FROM shipments WHERE id = shipment_id;
$$;

-- ============================================================================
-- STEP 13: Drop old triggers and create new ones on renamed tables
-- ============================================================================

DROP TRIGGER IF EXISTS on_envio_entregado ON public.shipments;
DROP TRIGGER IF EXISTS on_envio_recibido_almacen ON public.shipments;
DROP TRIGGER IF EXISTS on_envio_return_update ON public.shipments;
DROP TRIGGER IF EXISTS on_envio_ruta_devolucion_inv ON public.shipments;
DROP TRIGGER IF EXISTS update_envios_updated_at ON public.shipments;
DROP TRIGGER IF EXISTS on_recepcion_completada ON public.reception_operations;
DROP TRIGGER IF EXISTS update_operaciones_recepcion_updated_at ON public.reception_operations;

CREATE TRIGGER on_shipment_delivered AFTER UPDATE ON public.shipments FOR EACH ROW EXECUTE FUNCTION public.handle_shipment_delivered();
CREATE TRIGGER on_shipment_warehouse_received BEFORE UPDATE ON public.shipments FOR EACH ROW EXECUTE FUNCTION public.handle_shipment_warehouse_received();
CREATE TRIGGER on_shipment_return_user_status AFTER UPDATE ON public.shipments FOR EACH ROW EXECUTE FUNCTION public.handle_return_user_status();
CREATE TRIGGER on_shipment_return_transit_inv AFTER UPDATE ON public.shipments FOR EACH ROW EXECUTE FUNCTION public.handle_shipment_return_transit_inventory();
CREATE TRIGGER update_shipments_updated_at BEFORE UPDATE ON public.shipments FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER on_reception_completed AFTER UPDATE ON public.reception_operations FOR EACH ROW EXECUTE FUNCTION public.handle_reception_close();
CREATE TRIGGER update_reception_operations_updated_at BEFORE UPDATE ON public.reception_operations FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================================
-- STEP 14: Update RLS policies to use new names
-- ============================================================================

-- Drop all old policies on shipments (they reference old table/column names)
DROP POLICY IF EXISTS "Access for operators and admins" ON public.shipments;
DROP POLICY IF EXISTS "Admins and Operadores can view all shipments" ON public.shipments;
DROP POLICY IF EXISTS "Admins can manage all shipments" ON public.shipments;
DROP POLICY IF EXISTS "Operadores can create shipments" ON public.shipments;
DROP POLICY IF EXISTS "Operadores can update shipments" ON public.shipments;
DROP POLICY IF EXISTS "Users can update their own envios status" ON public.shipments;
DROP POLICY IF EXISTS "Users can view own envios" ON public.shipments;
DROP POLICY IF EXISTS "Users can view own shipments" ON public.shipments;

-- Recreate policies on shipments
CREATE POLICY "Admins and operators full access" ON public.shipments
    USING (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'operador'));

CREATE POLICY "Operators can create shipments" ON public.shipments
    FOR INSERT WITH CHECK (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'operador'));

CREATE POLICY "Operators can update shipments" ON public.shipments
    FOR UPDATE USING (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'operador'));

CREATE POLICY "Users can view own shipments" ON public.shipments
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own shipment status" ON public.shipments
    FOR UPDATE TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id AND shipment_status = 'return_in_transit');

-- Drop old policies on reception_operations
DROP POLICY IF EXISTS "Enable insert for admins and operators" ON public.reception_operations;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.reception_operations;
DROP POLICY IF EXISTS "Enable update for admins and operators" ON public.reception_operations;

-- Recreate policies on reception_operations
CREATE POLICY "Admins and operators can insert" ON public.reception_operations
    FOR INSERT TO authenticated
    WITH CHECK (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'operador'));

CREATE POLICY "Authenticated users can read" ON public.reception_operations
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Admins and operators can update" ON public.reception_operations
    FOR UPDATE TO authenticated
    USING (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'operador'))
    WITH CHECK (public.has_role(auth.uid(), 'admin') OR public.has_role(auth.uid(), 'operador'));

-- Update qr_validation_logs policy that references envios
DROP POLICY IF EXISTS "Users can view their own validation logs" ON public.qr_validation_logs;
CREATE POLICY "Users can view their own validation logs" ON public.qr_validation_logs
    FOR SELECT TO authenticated
    USING (shipment_id IN (SELECT s.id FROM public.shipments s WHERE s.user_id = auth.uid()));

-- ============================================================================
-- STEP 15: Drop old functions (cleanup)
-- ============================================================================

DROP FUNCTION IF EXISTS public.handle_envio_entregado();
DROP FUNCTION IF EXISTS public.handle_envio_recibido_almacen();
DROP FUNCTION IF EXISTS public.handle_envio_ruta_devolucion_inventory();
DROP FUNCTION IF EXISTS public.handle_return_status_update();
DROP FUNCTION IF EXISTS public.handle_cierre_recepcion();
DROP FUNCTION IF EXISTS public.assign_sets_to_users();