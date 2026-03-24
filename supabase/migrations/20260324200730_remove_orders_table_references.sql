-- Migration: Remove orders table references from confirm_assign_sets_to_users
-- The orders table is deprecated - shipments now handle everything directly

DROP FUNCTION IF EXISTS public.confirm_assign_sets_to_users(UUID[]);

CREATE OR REPLACE FUNCTION public.confirm_assign_sets_to_users(p_user_ids uuid[])
RETURNS TABLE(
    shipment_id uuid,
    user_id uuid,
    set_id uuid,
    user_name text,
    user_email text,
    user_phone text,
    set_name text,
    set_ref text,
    set_price numeric,
    set_weight numeric,
    pudo_id text,
    pudo_name text,
    pudo_address text,
    pudo_cp text,
    pudo_city text,
    pudo_province text,
    created_at timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
    r RECORD;
    target_set_id UUID;
    new_shipment_id UUID;
    v_set_name TEXT;
    v_set_ref TEXT;
    v_set_price NUMERIC;
    v_set_weight NUMERIC;
    v_pudo_id TEXT;
    v_pudo_name TEXT;
    v_pudo_address TEXT;
    v_pudo_cp TEXT;
    v_pudo_city TEXT;
    v_pudo_province TEXT;
    v_created_at TIMESTAMPTZ;
    v_pudo_type TEXT;
BEGIN
    -- Loop through each user to confirm their assignment
    FOR r IN (
        SELECT 
            u.user_id,
            u.full_name,
            u.email,
            u.phone,
            u.pudo_type,
            -- Correos PUDO data
            ucd.correos_id_pudo,
            ucd.correos_name,
            ucd.correos_full_address,
            ucd.correos_zip_code,
            ucd.correos_city,
            ucd.correos_province,
            -- Brickshare PUDO data
            bp.id as brickshare_pudo_id,
            bp.name as brickshare_pudo_name,
            bp.address as brickshare_address,
            bp.postal_code as brickshare_postal_code,
            bp.city as brickshare_city,
            bp.province as brickshare_province
        FROM public.users u
        LEFT JOIN public.users_correos_dropping ucd ON u.user_id = ucd.user_id
        LEFT JOIN public.brickshare_pudo_locations bp ON u.pudo_id = bp.id AND u.pudo_type = 'brickshare'
        WHERE u.user_id = ANY(p_user_ids)
          AND u.user_status IN ('no_set', 'set_returning')
          AND EXISTS (
              SELECT 1 
              FROM public.wishlist w 
              WHERE w.user_id = u.user_id 
                AND w.status = true
          )
    ) LOOP
        -- Store pudo_type for later use
        v_pudo_type := r.pudo_type;
        
        -- Determine PUDO data based on type
        IF v_pudo_type = 'correos' THEN
            v_pudo_id := r.correos_id_pudo;
            v_pudo_name := r.correos_name;
            v_pudo_address := r.correos_full_address;
            v_pudo_cp := r.correos_zip_code;
            v_pudo_city := r.correos_city;
            v_pudo_province := r.correos_province;
        ELSIF v_pudo_type = 'brickshare' THEN
            v_pudo_id := r.brickshare_pudo_id;
            v_pudo_name := r.brickshare_pudo_name;
            v_pudo_address := r.brickshare_address;
            v_pudo_cp := r.brickshare_postal_code;
            v_pudo_city := r.brickshare_city;
            v_pudo_province := r.brickshare_province;
        ELSE
            -- Skip user if no PUDO configured
            CONTINUE;
        END IF;
        
        -- Find the first available set from user's wishlist
        SELECT 
            w.set_id,
            s.set_name,
            s.set_ref,
            s.set_price,
            s.set_weight
        INTO 
            target_set_id,
            v_set_name,
            v_set_ref,
            v_set_price,
            v_set_weight
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        JOIN public.sets s ON w.set_id = s.id
        WHERE w.user_id = r.user_id
          AND w.status = true
          AND i.inventory_set_total_qty > 0
        ORDER BY w.created_at ASC
        LIMIT 1;

        IF target_set_id IS NOT NULL THEN
            -- Update inventory
            UPDATE public.inventory_sets
            SET 
                inventory_set_total_qty = inventory_set_total_qty - 1,
                in_shipping = in_shipping + 1
            WHERE inventory_sets.set_id = target_set_id;

            -- Create shipment directly (NO orders table)
            INSERT INTO public.shipments (
                user_id,
                set_id,
                set_ref,
                shipment_status,
                shipping_address,
                shipping_city,
                shipping_zip_code,
                shipping_country
            )
            VALUES (
                r.user_id,
                target_set_id,
                v_set_ref,
                'assigned',
                COALESCE(v_pudo_address, 'Pending assignment'),
                COALESCE(v_pudo_city, 'Pending'),
                COALESCE(v_pudo_cp, '00000'),
                'España'
            )
            RETURNING shipments.id, shipments.created_at
            INTO new_shipment_id, v_created_at;

            -- Update user status to 'set_shipping'
            UPDATE public.users
            SET user_status = 'set_shipping'
            WHERE users.user_id = r.user_id;

            -- Mark wishlist item as assigned
            UPDATE public.wishlist
            SET 
                status = false,
                status_changed_at = now()
            WHERE wishlist.user_id = r.user_id
              AND wishlist.set_id = target_set_id;

            -- Populate return record (NO order_id field)
            confirm_assign_sets_to_users.shipment_id := new_shipment_id;
            confirm_assign_sets_to_users.user_id := r.user_id;
            confirm_assign_sets_to_users.set_id := target_set_id;
            confirm_assign_sets_to_users.user_name := r.full_name;
            confirm_assign_sets_to_users.user_email := r.email;
            confirm_assign_sets_to_users.user_phone := r.phone;
            confirm_assign_sets_to_users.set_name := v_set_name;
            confirm_assign_sets_to_users.set_ref := v_set_ref;
            confirm_assign_sets_to_users.set_price := v_set_price;
            confirm_assign_sets_to_users.set_weight := v_set_weight;
            confirm_assign_sets_to_users.pudo_id := v_pudo_id;
            confirm_assign_sets_to_users.pudo_name := v_pudo_name;
            confirm_assign_sets_to_users.pudo_address := v_pudo_address;
            confirm_assign_sets_to_users.pudo_cp := v_pudo_cp;
            confirm_assign_sets_to_users.pudo_city := v_pudo_city;
            confirm_assign_sets_to_users.pudo_province := v_pudo_province;
            confirm_assign_sets_to_users.created_at := v_created_at;
            
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$;

COMMENT ON FUNCTION public.confirm_assign_sets_to_users IS 'Confirms set assignments for users. Creates shipments directly (NO orders table), sets user_status to set_shipping, and copies PUDO address data. Requires PUDO point configured.';