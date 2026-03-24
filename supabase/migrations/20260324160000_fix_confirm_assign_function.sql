-- Migration: Fix confirm_assign_sets_to_users function
-- Restores the correct function signature and logic that was broken in 20260324100000
-- This version maintains compatibility with the frontend and includes full business logic

-- Drop the incorrect version
DROP FUNCTION IF EXISTS public.confirm_assign_sets_to_users(UUID[]);

-- Recreate with correct signature and full logic from 20260322110000
CREATE OR REPLACE FUNCTION public.confirm_assign_sets_to_users(p_user_ids uuid[])
RETURNS TABLE(
    envio_id uuid,
    user_id uuid,
    set_id uuid,
    order_id uuid,
    user_name text,
    user_email text,
    user_phone text,
    set_name text,
    set_ref text,
    set_weight numeric,
    set_dim text,
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
    new_order_id UUID;
    new_envio_id UUID;
    v_set_name TEXT;
    v_set_ref TEXT;
    v_set_weight NUMERIC;
    v_set_dim TEXT;
    v_user_email TEXT;
    v_user_phone TEXT;
    v_pudo_id TEXT;
    v_pudo_name TEXT;
    v_pudo_address TEXT;
    v_pudo_cp TEXT;
    v_pudo_city TEXT;
    v_pudo_province TEXT;
    v_created_at TIMESTAMPTZ;
BEGIN
    -- Loop through each user to confirm their assignment
    FOR r IN (
        SELECT 
            u.user_id,
            u.full_name,
            u.email,
            u.phone,
            p.correos_id_pudo,
            p.correos_name,
            p.correos_full_address,
            p.correos_zip_code,
            p.correos_city,
            p.correos_province
        FROM public.users u
        LEFT JOIN public.users_correos_dropping p ON u.user_id = p.user_id
        WHERE u.user_id = ANY(p_user_ids)
          AND u.user_status IN ('no_set', 'set_returning')
          AND EXISTS (
              SELECT 1 
              FROM public.wishlist w 
              WHERE w.user_id = u.user_id 
                AND w.status = true
          )
    ) LOOP
        -- Find the first available set from user's wishlist
        SELECT 
            w.set_id,
            s.set_name,
            s.set_ref,
            s.set_weight,
            s.set_dim
        INTO 
            target_set_id,
            v_set_name,
            v_set_ref,
            v_set_weight,
            v_set_dim
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

            -- Create order
            INSERT INTO public.orders (user_id, set_id, status)
            VALUES (r.user_id, target_set_id, 'pending')
            RETURNING id INTO new_order_id;

            -- Create shipment
            INSERT INTO public.shipments (
                order_id,
                user_id,
                shipment_status,
                shipping_address,
                shipping_city,
                shipping_zip_code,
                shipping_country
            )
            VALUES (
                new_order_id,
                r.user_id,
                'pending',
                COALESCE(r.correos_full_address, 'Pending assignment'),
                COALESCE(r.correos_city, 'Pending'),
                COALESCE(r.correos_zip_code, '00000'),
                'España'
            )
            RETURNING shipments.id, shipments.created_at
            INTO new_envio_id, v_created_at;

            -- Update user status
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

            -- Populate return record
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

COMMENT ON FUNCTION public.confirm_assign_sets_to_users IS 'Confirms set assignments for users. Creates orders, shipments, updates inventory and wishlist. Requires PUDO point configured (enforced by frontend validation).';