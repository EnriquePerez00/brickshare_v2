-- Rename remaining Spanish column names to English
-- Table: users_correos_dropping (Correos PUDO integration)

-- correos_ prefix is kept as it refers to the "Correos" brand (proper noun)
-- but the descriptive parts are translated to English

ALTER TABLE users_correos_dropping RENAME COLUMN correos_nombre TO correos_name;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_tipo_punto TO correos_point_type;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_direccion_calle TO correos_street;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_direccion_numero TO correos_street_number;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_codigo_postal TO correos_zip_code;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_ciudad TO correos_city;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_provincia TO correos_province;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_pais TO correos_country;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_direccion_completa TO correos_full_address;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_latitud TO correos_latitude;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_longitud TO correos_longitude;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_horario_apertura TO correos_opening_hours;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_horario_estructurado TO correos_structured_hours;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_disponible TO correos_available;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_telefono TO correos_phone;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_codigo_interno TO correos_internal_code;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_capacidad_lockers TO correos_locker_capacity;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_servicios_adicionales TO correos_additional_services;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_accesibilidad TO correos_accessibility;
ALTER TABLE users_correos_dropping RENAME COLUMN correos_fecha_seleccion TO correos_selection_date;

-- Rename old foreign key constraints that still reference old Spanish table names
DO $$
BEGIN
  -- inventory_sets: rename old FK if it exists with old name
  IF EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'inventario_sets_set_id_fkey') THEN
    ALTER TABLE inventory_sets RENAME CONSTRAINT inventario_sets_set_id_fkey TO inventory_sets_set_id_fkey;
  END IF;
END $$;

-- ============================================================================
-- Recreate confirm_assign_sets_to_users to use new correos column names
-- ============================================================================

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
               p.correos_id_pudo, p.correos_name, p.correos_full_address,
               p.correos_zip_code, p.correos_city, p.correos_province
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
                    COALESCE(r.correos_full_address, 'Pending assignment'),
                    COALESCE(r.correos_city, 'Pending'),
                    COALESCE(r.correos_zip_code, '00000'), 'España')
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
            confirm_assign_sets_to_users.pudo_name := r.correos_name;
            confirm_assign_sets_to_users.pudo_address := r.correos_full_address;
            confirm_assign_sets_to_users.pudo_cp := r.correos_zip_code;
            confirm_assign_sets_to_users.pudo_city := r.correos_city;
            confirm_assign_sets_to_users.pudo_province := r.correos_province;
            confirm_assign_sets_to_users.created_at := v_created_at;
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$;
