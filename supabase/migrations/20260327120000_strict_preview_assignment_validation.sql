-- Migration: Add strict validation to preview_assign_sets_to_users
-- Date: 2026-03-27
-- Description: Only show users who are 100% ready for assignment:
--   1. Have PUDO configured (pudo_id IS NOT NULL)
--   2. Have payment method configured (stripe_payment_method_id IS NOT NULL)
--   3. Have active subscription (subscription_status = 'active')

DROP FUNCTION IF EXISTS public.preview_assign_sets_to_users();

CREATE OR REPLACE FUNCTION public.preview_assign_sets_to_users()
RETURNS TABLE (
    user_id UUID,
    user_name TEXT,
    set_id UUID,
    set_name TEXT,
    set_ref TEXT,
    set_price DECIMAL,
    current_stock INTEGER,
    matches_wishlist BOOLEAN,
    pudo_type TEXT
) AS $$
DECLARE
    r RECORD;
    v_set_id UUID;
    v_set_name TEXT;
    v_set_ref TEXT;
    v_set_price DECIMAL;
    v_current_stock INTEGER;
    v_matches_wishlist BOOLEAN;
    v_pudo_type TEXT;
BEGIN
    -- Loop through ONLY eligible users who meet ALL requirements:
    -- 1. Status: no_set or set_returning
    -- 2. NOT admin or operador
    -- 3. PUDO configured (pudo_id IS NOT NULL)
    -- 4. Payment method configured (stripe_payment_method_id IS NOT NULL)
    -- 5. Active subscription (subscription_status = 'active')
    FOR r IN (
        SELECT u.user_id, u.full_name, u.pudo_type
        FROM public.users u
        WHERE u.user_status IN ('no_set', 'set_returning')
          -- Only include users who don't have admin or operador roles
          AND NOT EXISTS (
              SELECT 1 FROM public.user_roles ur
              WHERE ur.user_id = u.user_id
              AND ur.role IN ('admin', 'operador')
          )
          -- STRICT VALIDATION: PUDO must be configured
          AND u.pudo_id IS NOT NULL
          -- STRICT VALIDATION: Payment method must be configured
          AND u.stripe_payment_method_id IS NOT NULL
          -- STRICT VALIDATION: Subscription must be active
          AND u.subscription_status = 'active'
    ) LOOP
        v_set_id := NULL;
        v_matches_wishlist := FALSE;
        v_pudo_type := r.pudo_type;
        
        -- Try to find set from user's wishlist that they haven't had before
        SELECT w.set_id, s.set_name, s.set_ref, 
               COALESCE(s.set_price, 100.00), i.inventory_set_total_qty
        INTO v_set_id, v_set_name, v_set_ref, v_set_price, v_current_stock
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        JOIN public.sets s ON w.set_id = s.id
        WHERE w.user_id = r.user_id
          AND w.status = true
          AND i.inventory_set_total_qty > 0
          -- Check if user has NOT had this set before
          AND NOT EXISTS (
              SELECT 1 FROM public.shipments e
              WHERE e.user_id = r.user_id 
                AND e.set_id = w.set_id
          )
        ORDER BY w.created_at ASC  -- Prioritize by wishlist order
        LIMIT 1;
        
        -- If found in wishlist, mark as match
        IF v_set_id IS NOT NULL THEN
            v_matches_wishlist := TRUE;
        ELSE
            -- No valid wishlist match, choose random available set
            SELECT s.id, s.set_name, s.set_ref, 
                   COALESCE(s.set_price, 100.00), i.inventory_set_total_qty
            INTO v_set_id, v_set_name, v_set_ref, v_set_price, v_current_stock
            FROM public.sets s
            JOIN public.inventory_sets i ON s.id = i.set_id
            WHERE i.inventory_set_total_qty > 0
            ORDER BY RANDOM()
            LIMIT 1;
            
            v_matches_wishlist := FALSE;
        END IF;
        
        -- Return assignment if a set was found
        IF v_set_id IS NOT NULL THEN
            preview_assign_sets_to_users.user_id := r.user_id;
            preview_assign_sets_to_users.user_name := r.full_name;
            preview_assign_sets_to_users.set_id := v_set_id;
            preview_assign_sets_to_users.set_name := v_set_name;
            preview_assign_sets_to_users.set_ref := v_set_ref;
            preview_assign_sets_to_users.set_price := v_set_price;
            preview_assign_sets_to_users.current_stock := v_current_stock;
            preview_assign_sets_to_users.matches_wishlist := v_matches_wishlist;
            preview_assign_sets_to_users.pudo_type := v_pudo_type;
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

COMMENT ON FUNCTION public.preview_assign_sets_to_users IS 
'Shows proposed set assignments ONLY for users who are 100% ready. Strict validation ensures:
- User status is no_set or set_returning
- PUDO point is configured (pudo_id IS NOT NULL)
- Payment method is configured (stripe_payment_method_id IS NOT NULL)
- Subscription is active (subscription_status = ''active'')
Users missing ANY of these requirements will NOT appear in the preview.';