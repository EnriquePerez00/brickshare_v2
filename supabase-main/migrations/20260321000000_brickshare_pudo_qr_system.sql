-- Migration: Brickshare PUDO and QR Code System
-- Description: Add support for Brickshare pickup points with QR code validation

-- Add new columns to envios table for Brickshare PUDO flow
ALTER TABLE envios
ADD COLUMN IF NOT EXISTS pickup_type TEXT CHECK (pickup_type IN ('correos', 'brickshare')) DEFAULT 'correos',
ADD COLUMN IF NOT EXISTS brickshare_pudo_id TEXT,
ADD COLUMN IF NOT EXISTS delivery_qr_code TEXT UNIQUE,
ADD COLUMN IF NOT EXISTS delivery_qr_expires_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS delivery_validated_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS return_qr_code TEXT UNIQUE,
ADD COLUMN IF NOT EXISTS return_qr_expires_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS return_validated_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS brickshare_metadata JSONB DEFAULT '{}'::jsonb;

-- Create index for QR code lookups
CREATE INDEX IF NOT EXISTS idx_envios_delivery_qr ON envios(delivery_qr_code) WHERE delivery_qr_code IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_envios_return_qr ON envios(return_qr_code) WHERE return_qr_code IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_envios_pickup_type ON envios(pickup_type);

-- Create table for Brickshare PUDO locations
CREATE TABLE IF NOT EXISTS brickshare_pudo_locations (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    city TEXT NOT NULL,
    postal_code TEXT NOT NULL,
    province TEXT NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    contact_phone TEXT,
    contact_email TEXT,
    opening_hours JSONB,
    is_active BOOLEAN DEFAULT true,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Create index for geolocation searches
CREATE INDEX IF NOT EXISTS idx_brickshare_pudo_location ON brickshare_pudo_locations(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_brickshare_pudo_active ON brickshare_pudo_locations(is_active) WHERE is_active = true;

-- Create table for QR validation logs
CREATE TABLE IF NOT EXISTS qr_validation_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shipment_id UUID NOT NULL REFERENCES envios(id) ON DELETE CASCADE,
    qr_code TEXT NOT NULL,
    validation_type TEXT NOT NULL CHECK (validation_type IN ('delivery', 'return')),
    validated_by TEXT, -- Could be user_id or pudo_location_id
    validated_at TIMESTAMPTZ DEFAULT now(),
    validation_status TEXT NOT NULL CHECK (validation_status IN ('success', 'expired', 'invalid', 'already_used')),
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_qr_validation_shipment ON qr_validation_logs(shipment_id);
CREATE INDEX IF NOT EXISTS idx_qr_validation_code ON qr_validation_logs(qr_code);

-- Function to generate unique QR code
CREATE OR REPLACE FUNCTION generate_qr_code()
RETURNS TEXT AS $$
DECLARE
    chars TEXT := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    result TEXT := 'BS-';
    i INTEGER;
BEGIN
    FOR i IN 1..16 LOOP
        result := result || substr(chars, floor(random() * length(chars) + 1)::integer, 1);
    END LOOP;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Function to generate delivery QR code
CREATE OR REPLACE FUNCTION generate_delivery_qr(p_shipment_id UUID)
RETURNS TABLE(qr_code TEXT, expires_at TIMESTAMPTZ) AS $$
DECLARE
    v_qr_code TEXT;
    v_expires_at TIMESTAMPTZ;
    v_max_attempts INTEGER := 10;
    v_attempt INTEGER := 0;
BEGIN
    v_expires_at := now() + interval '30 days';
    
    LOOP
        v_qr_code := generate_qr_code();
        v_attempt := v_attempt + 1;
        
        -- Check if QR code is unique
        IF NOT EXISTS (
            SELECT 1 FROM envios 
            WHERE delivery_qr_code = v_qr_code OR return_qr_code = v_qr_code
        ) THEN
            EXIT;
        END IF;
        
        IF v_attempt >= v_max_attempts THEN
            RAISE EXCEPTION 'Unable to generate unique QR code after % attempts', v_max_attempts;
        END IF;
    END LOOP;
    
    UPDATE envios
    SET 
        delivery_qr_code = v_qr_code,
        delivery_qr_expires_at = v_expires_at,
        updated_at = now()
    WHERE id = p_shipment_id;
    
    RETURN QUERY SELECT v_qr_code, v_expires_at;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to generate return QR code
CREATE OR REPLACE FUNCTION generate_return_qr(p_shipment_id UUID)
RETURNS TABLE(qr_code TEXT, expires_at TIMESTAMPTZ) AS $$
DECLARE
    v_qr_code TEXT;
    v_expires_at TIMESTAMPTZ;
    v_max_attempts INTEGER := 10;
    v_attempt INTEGER := 0;
BEGIN
    v_expires_at := now() + interval '30 days';
    
    LOOP
        v_qr_code := generate_qr_code();
        v_attempt := v_attempt + 1;
        
        -- Check if QR code is unique
        IF NOT EXISTS (
            SELECT 1 FROM envios 
            WHERE delivery_qr_code = v_qr_code OR return_qr_code = v_qr_code
        ) THEN
            EXIT;
        END IF;
        
        IF v_attempt >= v_max_attempts THEN
            RAISE EXCEPTION 'Unable to generate unique QR code after % attempts', v_max_attempts;
        END IF;
    END LOOP;
    
    UPDATE envios
    SET 
        return_qr_code = v_qr_code,
        return_qr_expires_at = v_expires_at,
        updated_at = now()
    WHERE id = p_shipment_id;
    
    RETURN QUERY SELECT v_qr_code, v_expires_at;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to validate QR code and get shipment info (no personal data)
CREATE OR REPLACE FUNCTION validate_qr_code(p_qr_code TEXT)
RETURNS TABLE(
    shipment_id UUID,
    validation_type TEXT,
    is_valid BOOLEAN,
    error_message TEXT,
    shipment_info JSONB
) AS $$
DECLARE
    v_shipment RECORD;
    v_is_valid BOOLEAN := false;
    v_error_message TEXT := NULL;
    v_validation_type TEXT := NULL;
    v_shipment_info JSONB;
BEGIN
    -- Find shipment by QR code
    SELECT 
        s.id,
        s.order_id,
        s.estado_envio as status,
        s.pickup_type,
        s.delivery_qr_code,
        s.delivery_qr_expires_at,
        s.delivery_validated_at,
        s.return_qr_code,
        s.return_qr_expires_at,
        s.return_validated_at,
        s.brickshare_pudo_id,
        o.set_id,
        st.set_name,
        st.set_ref as set_number,
        st.theme
    INTO v_shipment
    FROM envios s
    JOIN orders o ON s.order_id = o.id
    LEFT JOIN sets st ON o.set_id = st.id
    WHERE s.delivery_qr_code = p_qr_code OR s.return_qr_code = p_qr_code;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT 
            NULL::UUID,
            NULL::TEXT,
            false,
            'QR code not found'::TEXT,
            NULL::JSONB;
        RETURN;
    END IF;
    
    -- Check if it's a Brickshare PUDO shipment
    IF v_shipment.pickup_type != 'brickshare' THEN
        RETURN QUERY SELECT 
            v_shipment.id,
            NULL::TEXT,
            false,
            'This shipment is not for Brickshare pickup point'::TEXT,
            NULL::JSONB;
        RETURN;
    END IF;
    
    -- Determine validation type and check validity
    IF v_shipment.delivery_qr_code = p_qr_code THEN
        v_validation_type := 'delivery';
        
        IF v_shipment.delivery_validated_at IS NOT NULL THEN
            v_error_message := 'QR code already used';
        ELSIF v_shipment.delivery_qr_expires_at < now() THEN
            v_error_message := 'QR code has expired';
        ELSE
            v_is_valid := true;
        END IF;
        
    ELSIF v_shipment.return_qr_code = p_qr_code THEN
        v_validation_type := 'return';
        
        IF v_shipment.return_validated_at IS NOT NULL THEN
            v_error_message := 'QR code already used';
        ELSIF v_shipment.return_qr_expires_at < now() THEN
            v_error_message := 'QR code has expired';
        ELSIF v_shipment.delivery_validated_at IS NULL THEN
            v_error_message := 'Cannot return a set that has not been delivered yet';
        ELSE
            v_is_valid := true;
        END IF;
    END IF;
    
    -- Build shipment info (excluding personal data)
    v_shipment_info := jsonb_build_object(
        'order_id', v_shipment.order_id,
        'set_id', v_shipment.set_id,
        'set_name', v_shipment.set_name,
        'set_number', v_shipment.set_number,
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to confirm QR validation
CREATE OR REPLACE FUNCTION confirm_qr_validation(
    p_qr_code TEXT,
    p_validated_by TEXT DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    shipment_id UUID
) AS $$
DECLARE
    v_validation RECORD;
    v_new_status TEXT;
BEGIN
    -- Validate QR code first
    SELECT * INTO v_validation
    FROM validate_qr_code(p_qr_code);
    
    IF NOT v_validation.is_valid THEN
        RETURN QUERY SELECT 
            false,
            v_validation.error_message,
            v_validation.shipment_id;
        RETURN;
    END IF;
    
    -- Update shipment based on validation type
    IF v_validation.validation_type = 'delivery' THEN
        v_new_status := 'delivered';
        
        UPDATE envios
        SET 
            delivery_validated_at = now(),
            estado_envio = v_new_status,
            updated_at = now()
        WHERE id = v_validation.shipment_id;
        
    ELSIF v_validation.validation_type = 'return' THEN
        v_new_status := 'returned';
        
        UPDATE envios
        SET 
            return_validated_at = now(),
            estado_envio = v_new_status,
            updated_at = now()
        WHERE id = v_validation.shipment_id;
    END IF;
    
    -- Log validation
    INSERT INTO qr_validation_logs (
        shipment_id,
        qr_code,
        validation_type,
        validated_by,
        validation_status,
        metadata
    ) VALUES (
        v_validation.shipment_id,
        p_qr_code,
        v_validation.validation_type,
        p_validated_by,
        'success',
        jsonb_build_object('validated_at', now())
    );
    
    RETURN QUERY SELECT 
        true,
        format('Shipment successfully %s', 
            CASE 
                WHEN v_validation.validation_type = 'delivery' THEN 'delivered'
                ELSE 'returned'
            END
        ),
        v_validation.shipment_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Insert sample Brickshare PUDO locations (you can modify these)
INSERT INTO brickshare_pudo_locations (id, name, address, city, postal_code, province, latitude, longitude, contact_email, is_active)
VALUES 
    ('BS-PUDO-001', 'Brickshare Madrid Centro', 'Calle Gran Vía 28', 'Madrid', '28013', 'Madrid', 40.4200, -3.7038, 'madrid.centro@brickshare.com', true),
    ('BS-PUDO-002', 'Brickshare Barcelona Eixample', 'Passeig de Gràcia 100', 'Barcelona', '08008', 'Barcelona', 41.3926, 2.1640, 'barcelona.eixample@brickshare.com', true)
ON CONFLICT (id) DO NOTHING;

-- Grant necessary permissions
GRANT SELECT ON brickshare_pudo_locations TO authenticated;
GRANT SELECT ON qr_validation_logs TO authenticated;
GRANT EXECUTE ON FUNCTION validate_qr_code(TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION confirm_qr_validation(TEXT, TEXT) TO authenticated;

-- Add RLS policies
ALTER TABLE brickshare_pudo_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE qr_validation_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read of active PUDO locations"
    ON brickshare_pudo_locations FOR SELECT
    TO public
    USING (is_active = true);

CREATE POLICY "Users can view their own validation logs"
    ON qr_validation_logs FOR SELECT
    TO authenticated
    USING (
        shipment_id IN (
            SELECT s.id FROM envios s
            WHERE s.user_id = auth.uid()
        )
    );

-- Add comment
COMMENT ON TABLE brickshare_pudo_locations IS 'Brickshare pickup and drop-off locations';
COMMENT ON TABLE qr_validation_logs IS 'Logs of QR code validations for deliveries and returns';
COMMENT ON FUNCTION validate_qr_code(TEXT) IS 'Validates a QR code and returns shipment info without personal data';
COMMENT ON FUNCTION confirm_qr_validation(TEXT, TEXT) IS 'Confirms a QR validation and updates shipment status';