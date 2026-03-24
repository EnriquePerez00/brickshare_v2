-- Migration: Add PUDO validation to assignment confirmation
-- Users must have a configured PUDO point before being assigned sets

-- Drop the old function
DROP FUNCTION IF EXISTS public.confirm_assign_sets_to_users(UUID[]);

-- Recreate with PUDO validation
CREATE OR REPLACE FUNCTION public.confirm_assign_sets_to_users(user_ids UUID[])
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    user_id UUID,
    set_id UUID
) AS $$
DECLARE
    v_user_id UUID;
    v_set_id UUID;
    v_has_pudo BOOLEAN;
BEGIN
    -- Validate all users have PUDO configured
    FOR v_user_id IN SELECT unnest(user_ids) LOOP
        -- Check if user has PUDO configured
        SELECT EXISTS(
            SELECT 1 FROM public.users 
            WHERE users.user_id = v_user_id 
            AND pudo_type IS NOT NULL 
            AND pudo_id IS NOT NULL
        ) INTO v_has_pudo;
        
        IF NOT v_has_pudo THEN
            RETURN QUERY SELECT 
                FALSE,
                'User does not have a PUDO point configured',
                v_user_id,
                NULL::UUID;
            CONTINUE;
        END IF;
        
        -- Get the proposed set for this user
        SELECT proposed_set_id INTO v_set_id
        FROM public.users
        WHERE users.user_id = v_user_id;
        
        IF v_set_id IS NULL THEN
            RETURN QUERY SELECT 
                FALSE,
                'No set proposed for this user',
                v_user_id,
                NULL::UUID;
            CONTINUE;
        END IF;
        
        -- Create shipment
        INSERT INTO public.shipments (
            user_id,
            set_id,
            set_ref,
            shipment_status,
            shipment_type,
            created_at,
            updated_at
        )
        SELECT 
            v_user_id,
            v_set_id,
            s.set_ref,
            'pending',
            'outbound',
            NOW(),
            NOW()
        FROM public.sets s
        WHERE s.id = v_set_id
        RETURNING shipments.id INTO v_set_id; -- Reusing variable for shipment_id
        
        -- Update inventory
        UPDATE public.inventory_sets
        SET 
            available_stock = available_stock - 1,
            in_transit = in_transit + 1,
            updated_at = NOW()
        WHERE set_id = (SELECT proposed_set_id FROM public.users WHERE users.user_id = v_user_id);
        
        -- Clear proposed_set_id
        UPDATE public.users
        SET 
            proposed_set_id = NULL,
            updated_at = NOW()
        WHERE users.user_id = v_user_id;
        
        RETURN QUERY SELECT 
            TRUE,
            'Assignment confirmed successfully',
            v_user_id,
            v_set_id;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION public.confirm_assign_sets_to_users IS 'Confirms set assignments for users. Validates that each user has a PUDO point configured before proceeding.';