-- ============================================================================
-- Migration: Make QR Codes Permanent (Remove Expiration)
-- Date: 2026-03-25
-- Description: Remove QR code expiration validation to make codes permanent
--              QR codes remain single-use via validated_at timestamps
-- ============================================================================

-- ============================================================================
-- STEP 1: Update validate_qr_code function to remove expiration checks
-- ============================================================================

CREATE OR REPLACE FUNCTION public.validate_qr_code(p_qr_code text)
RETURNS TABLE(
    shipment_id uuid, 
    validation_type text, 
    is_valid boolean, 
    error_message text, 
    shipment_info jsonb
)
LANGUAGE plpgsql 
SECURITY DEFINER 
AS $$
DECLARE
    v_shipment RECORD;
    v_is_valid BOOLEAN := false;
    v_error_message TEXT := NULL;
    v_validation_type TEXT := NULL;
    v_shipment_info JSONB;
BEGIN
    -- Fetch shipment by QR code
    SELECT 
        s.id, 
        s.user_id,
        s.set_id,
        s.set_ref,
        s.shipment_status as status, 
        s.pudo_type,
        s.delivery_qr_code, 
        s.delivery_qr_expires_at, 
        s.delivery_validated_at,
        s.return_qr_code, 
        s.return_qr_expires_at, 
        s.return_validated_at,
        s.brickshare_pudo_id,
        st.set_name, 
        st.set_ref as set_number, 
        st.theme
    INTO v_shipment
    FROM shipments s 
    LEFT JOIN sets st ON s.set_id = st.id
    WHERE s.delivery_qr_code = p_qr_code OR s.return_qr_code = p_qr_code;

    -- QR code not found
    IF NOT FOUND THEN
        RETURN QUERY SELECT 
            NULL::UUID, 
            NULL::TEXT, 
            false, 
            'QR code not found'::TEXT, 
            NULL::JSONB;
        RETURN;
    END IF;

    -- Only Brickshare PUDO shipments use QR validation
    IF v_shipment.pudo_type != 'brickshare' THEN
        RETURN QUERY SELECT 
            v_shipment.id, 
            NULL::TEXT, 
            false, 
            'This shipment is not for Brickshare pickup point'::TEXT, 
            NULL::JSONB;
        RETURN;
    END IF;

    -- Validate delivery QR
    IF v_shipment.delivery_qr_code = p_qr_code THEN
        v_validation_type := 'delivery';
        
        IF v_shipment.delivery_validated_at IS NOT NULL THEN
            v_error_message := 'QR code already used';
        -- REMOVED: expiration check
        -- ELSIF v_shipment.delivery_qr_expires_at < now() THEN
        --     v_error_message := 'QR code has expired';
        ELSE
            v_is_valid := true;
        END IF;
        
    -- Validate return QR
    ELSIF v_shipment.return_qr_code = p_qr_code THEN
        v_validation_type := 'return';
        
        IF v_shipment.return_validated_at IS NOT NULL THEN
            v_error_message := 'QR code already used';
        -- REMOVED: expiration check
        -- ELSIF v_shipment.return_qr_expires_at < now() THEN
        --     v_error_message := 'QR code has expired';
        ELSIF v_shipment.delivery_validated_at IS NULL THEN
            v_error_message := 'Cannot return a set that has not been delivered yet';
        ELSE
            v_is_valid := true;
        END IF;
    END IF;

    -- Build shipment info JSON
    v_shipment_info := jsonb_build_object(
        'user_id', v_shipment.user_id,
        'set_id', v_shipment.set_id,
        'set_name', v_shipment.set_name,
        'set_number', v_shipment.set_number,
        'set_ref', v_shipment.set_ref,
        'theme', v_shipment.theme,
        'status', v_shipment.status,
        'brickshare_pudo_id', v_shipment.brickshare_pudo_id,
        'validation_type', v_validation_type
    );

    RETURN QUERY SELECT 
        v_shipment.id, 
        v_validation_type, 
        v_is_valid, 
        v_error_message, 
        v_shipment_info;
END;
$$;

COMMENT ON FUNCTION public.validate_qr_code(text) IS 
'Validates Brickshare QR codes for delivery/return. QR codes are permanent (no expiration) but single-use (validated_at timestamps).';

-- ============================================================================
-- STEP 2: Update generate_delivery_qr to not set expiration (optional)
-- ============================================================================

CREATE OR REPLACE FUNCTION public.generate_delivery_qr(p_shipment_id uuid)
RETURNS TABLE(qr_code text, expires_at timestamptz) 
LANGUAGE plpgsql 
SECURITY DEFINER 
AS $$
DECLARE
    v_qr_code TEXT;
    v_expires_at TIMESTAMPTZ;
    v_max_attempts INTEGER := 10;
    v_attempt INTEGER := 0;
BEGIN
    -- Set expires_at to NULL for permanent codes
    v_expires_at := NULL;
    
    -- Generate unique QR code
    LOOP
        v_qr_code := generate_qr_code();
        v_attempt := v_attempt + 1;
        
        IF NOT EXISTS (
            SELECT 1 FROM shipments 
            WHERE delivery_qr_code = v_qr_code OR return_qr_code = v_qr_code
        ) THEN
            EXIT;
        END IF;
        
        IF v_attempt >= v_max_attempts THEN
            RAISE EXCEPTION 'Unable to generate unique QR code after % attempts', v_max_attempts;
        END IF;
    END LOOP;
    
    -- Update shipment with QR code (no expiration)
    UPDATE shipments 
    SET 
        delivery_qr_code = v_qr_code,
        delivery_qr_expires_at = v_expires_at,
        updated_at = now()
    WHERE id = p_shipment_id;
    
    RETURN QUERY SELECT v_qr_code, v_expires_at;
END;
$$;

COMMENT ON FUNCTION public.generate_delivery_qr(uuid) IS 
'Generates a permanent (non-expiring) delivery QR code for a shipment.';

-- ============================================================================
-- STEP 3: Update generate_return_qr to not set expiration (optional)
-- ============================================================================

CREATE OR REPLACE FUNCTION public.generate_return_qr(p_shipment_id uuid)
RETURNS TABLE(qr_code text, expires_at timestamptz) 
LANGUAGE plpgsql 
SECURITY DEFINER 
AS $$
DECLARE
    v_qr_code TEXT;
    v_expires_at TIMESTAMPTZ;
    v_max_attempts INTEGER := 10;
    v_attempt INTEGER := 0;
BEGIN
    -- Set expires_at to NULL for permanent codes
    v_expires_at := NULL;
    
    -- Generate unique QR code
    LOOP
        v_qr_code := generate_qr_code();
        v_attempt := v_attempt + 1;
        
        IF NOT EXISTS (
            SELECT 1 FROM shipments 
            WHERE delivery_qr_code = v_qr_code OR return_qr_code = v_qr_code
        ) THEN
            EXIT;
        END IF;
        
        IF v_attempt >= v_max_attempts THEN
            RAISE EXCEPTION 'Unable to generate unique QR code after % attempts', v_max_attempts;
        END IF;
    END LOOP;
    
    -- Update shipment with QR code (no expiration)
    UPDATE shipments 
    SET 
        return_qr_code = v_qr_code,
        return_qr_expires_at = v_expires_at,
        updated_at = now()
    WHERE id = p_shipment_id;
    
    RETURN QUERY SELECT v_qr_code, v_expires_at;
END;
$$;

COMMENT ON FUNCTION public.generate_return_qr(uuid) IS 
'Generates a permanent (non-expiring) return QR code for a shipment.';

-- ============================================================================
-- STEP 4: Clear existing expiration dates (optional - makes existing QR permanent)
-- ============================================================================

-- This will make all existing QR codes permanent
UPDATE public.shipments 
SET 
    delivery_qr_expires_at = NULL,
    return_qr_expires_at = NULL,
    updated_at = now()
WHERE 
    delivery_qr_expires_at IS NOT NULL 
    OR return_qr_expires_at IS NOT NULL;

-- ============================================================================
-- NOTES
-- ============================================================================
-- 
-- QR codes are now permanent (no expiration) but remain single-use:
-- - delivery_validated_at: timestamp when delivery QR was scanned
-- - return_validated_at: timestamp when return QR was scanned
-- 
-- Security is maintained through:
-- 1. Single-use validation (validated_at timestamps)
-- 2. Unique QR codes (unique constraints on delivery_qr_code/return_qr_code)
-- 3. Brickshare PUDO validation (pudo_type = 'brickshare')
-- 4. Return logic (can't return before delivery)
-- 
-- ============================================================================