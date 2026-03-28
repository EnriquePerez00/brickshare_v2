-- ============================================================================
-- Reception Improvements: Missing Pieces Tracking & Weight-Based Processing
-- ============================================================================

-- 1. Create reception_missing_pieces table
CREATE TABLE IF NOT EXISTS public.reception_missing_pieces (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    set_id UUID REFERENCES public.sets(id) ON DELETE CASCADE NOT NULL,
    time TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    piece_ref TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'ordered', 'received')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- 2. Create indices for performance
CREATE INDEX IF NOT EXISTS idx_reception_missing_pieces_set_id ON public.reception_missing_pieces(set_id);
CREATE INDEX IF NOT EXISTS idx_reception_missing_pieces_status ON public.reception_missing_pieces(status);
CREATE INDEX IF NOT EXISTS idx_reception_missing_pieces_time ON public.reception_missing_pieces(time DESC);

-- 3. Enable RLS
ALTER TABLE public.reception_missing_pieces ENABLE ROW LEVEL SECURITY;

-- 4. Create RLS Policies
DROP POLICY IF EXISTS "Authenticated users can read missing pieces" ON public.reception_missing_pieces;
CREATE POLICY "Authenticated users can read missing pieces"
    ON public.reception_missing_pieces
    FOR SELECT TO authenticated
    USING (true);

DROP POLICY IF EXISTS "Admins and operators can insert missing pieces" ON public.reception_missing_pieces;
CREATE POLICY "Admins and operators can insert missing pieces"
    ON public.reception_missing_pieces
    FOR INSERT TO authenticated
    WITH CHECK (
        public.has_role(auth.uid(), 'admin'::public.app_role) OR 
        public.has_role(auth.uid(), 'operador'::public.app_role)
    );

DROP POLICY IF EXISTS "Admins and operators can update missing pieces" ON public.reception_missing_pieces;
CREATE POLICY "Admins and operators can update missing pieces"
    ON public.reception_missing_pieces
    FOR UPDATE TO authenticated
    USING (
        public.has_role(auth.uid(), 'admin'::public.app_role) OR 
        public.has_role(auth.uid(), 'operador'::public.app_role)
    )
    WITH CHECK (
        public.has_role(auth.uid(), 'admin'::public.app_role) OR 
        public.has_role(auth.uid(), 'operador'::public.app_role)
    );

DROP POLICY IF EXISTS "Admins and operators can delete missing pieces" ON public.reception_missing_pieces;
CREATE POLICY "Admins and operators can delete missing pieces"
    ON public.reception_missing_pieces
    FOR DELETE TO authenticated
    USING (
        public.has_role(auth.uid(), 'admin'::public.app_role) OR 
        public.has_role(auth.uid(), 'operador'::public.app_role)
    );

-- 5. Create trigger for updated_at
DROP TRIGGER IF EXISTS update_reception_missing_pieces_updated_at ON public.reception_missing_pieces;
CREATE TRIGGER update_reception_missing_pieces_updated_at
    BEFORE UPDATE ON public.reception_missing_pieces
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- 6. Add comments
COMMENT ON TABLE public.reception_missing_pieces IS 'Registro de piezas faltantes detectadas en sets en reparación durante el proceso de devolución y recepción.';
COMMENT ON COLUMN public.reception_missing_pieces.set_id IS 'Referencia al set LEGO que le faltan piezas.';
COMMENT ON COLUMN public.reception_missing_pieces.piece_ref IS 'Referencia LEGO de la pieza faltante (ej: "3001").';
COMMENT ON COLUMN public.reception_missing_pieces.quantity IS 'Cantidad de piezas faltantes de este tipo.';
COMMENT ON COLUMN public.reception_missing_pieces.status IS 'Estado del pedido de reemplazo: pending (registrada), ordered (pedida), received (recibida).';

-- ============================================================================
-- RPC Functions
-- ============================================================================

-- Function: process_set_return_with_weight
-- Procesa la devolución de un set con validación de peso basada en tolerancia
DROP FUNCTION IF EXISTS public.process_set_return_with_weight(UUID, UUID, UUID, NUMERIC, NUMERIC);
CREATE OR REPLACE FUNCTION public.process_set_return_with_weight(
    p_shipment_id UUID,
    p_set_id UUID,
    p_user_id UUID,
    p_weight_measured NUMERIC,
    p_weight_tolerance NUMERIC DEFAULT 0.05
)
RETURNS JSON AS $$
DECLARE
    v_expected_weight NUMERIC;
    v_min_weight NUMERIC;
    v_max_weight NUMERIC;
    v_new_status TEXT;
    v_weight_ok BOOLEAN;
    v_result JSON;
BEGIN
    -- Validar parámetros
    IF p_weight_measured <= 0 THEN
        RAISE EXCEPTION 'Weight measured must be greater than 0';
    END IF;

    -- Obtener peso esperado del set
    SELECT set_weight INTO v_expected_weight
    FROM public.sets
    WHERE id = p_set_id;

    IF v_expected_weight IS NULL THEN
        RAISE EXCEPTION 'Set weight not found for set_id: %', p_set_id;
    END IF;

    -- Calcular rango de tolerancia
    v_min_weight := v_expected_weight * (1 - p_weight_tolerance);
    v_max_weight := v_expected_weight * (1 + p_weight_tolerance);
    v_weight_ok := p_weight_measured BETWEEN v_min_weight AND v_max_weight;
    v_new_status := CASE WHEN v_weight_ok THEN 'active' ELSE 'in_repair' END;

    -- Insertar registro en reception_operations
    INSERT INTO public.reception_operations (
        event_id,
        user_id,
        set_id,
        weight_measured,
        reception_completed,
        missing_parts
    ) VALUES (
        p_shipment_id,
        p_user_id,
        p_set_id,
        p_weight_measured,
        true,
        CASE 
            WHEN NOT v_weight_ok THEN 
                format('Peso fuera de tolerancia: %s g (esperado: %s g, rango: %s-%s g)', 
                    p_weight_measured, v_expected_weight, v_min_weight, v_max_weight)
            ELSE NULL
        END
    );

    -- Actualizar estado del set
    UPDATE public.sets
    SET set_status = v_new_status
    WHERE id = p_set_id;

    -- Actualizar inventario
    IF v_new_status = 'active' THEN
        UPDATE public.inventory_sets
        SET inventory_set_total_qty = COALESCE(inventory_set_total_qty, 0) + 1
        WHERE set_id = p_set_id;
    ELSE
        -- Si entra en reparación, no modificar el inventario aquí
        -- Se gestionará mediante la tabla reception_operations
        NULL;
    END IF;

    -- Marcar shipment como procesado
    UPDATE public.shipments
    SET handling_processed = true
    WHERE id = p_shipment_id;

    -- Retornar resultado
    v_result := json_build_object(
        'success', true,
        'new_status', v_new_status,
        'weight_ok', v_weight_ok,
        'measured_weight', p_weight_measured,
        'expected_weight', v_expected_weight,
        'tolerance_range', json_build_object('min', v_min_weight, 'max', v_max_weight)
    );

    RETURN v_result;
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'success', false,
        'error', SQLERRM
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: add_missing_pieces_batch
-- Registra múltiples piezas faltantes de un set
DROP FUNCTION IF EXISTS public.add_missing_pieces_batch(UUID, JSON);
CREATE OR REPLACE FUNCTION public.add_missing_pieces_batch(
    p_set_id UUID,
    p_pieces JSON
)
RETURNS JSON AS $$
DECLARE
    v_piece RECORD;
    v_inserted_count INTEGER := 0;
    v_error_count INTEGER := 0;
BEGIN
    -- Validar que el set existe
    IF NOT EXISTS (SELECT 1 FROM public.sets WHERE id = p_set_id) THEN
        RAISE EXCEPTION 'Set not found: %', p_set_id;
    END IF;

    -- Insertar cada pieza del JSON array
    FOR v_piece IN 
        SELECT 
            (elem::jsonb->>'piece_ref') AS piece_ref,
            (elem::jsonb->>'quantity')::INTEGER AS quantity
        FROM json_array_elements(p_pieces) AS elem
    LOOP
        BEGIN
            INSERT INTO public.reception_missing_pieces (
                set_id,
                piece_ref,
                quantity,
                status
            ) VALUES (
                p_set_id,
                v_piece.piece_ref,
                v_piece.quantity,
                'pending'
            );
            v_inserted_count := v_inserted_count + 1;
        EXCEPTION WHEN OTHERS THEN
            v_error_count := v_error_count + 1;
        END;
    END LOOP;

    RETURN json_build_object(
        'success', v_error_count = 0,
        'inserted_count', v_inserted_count,
        'error_count', v_error_count
    );
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'success', false,
        'error', SQLERRM,
        'inserted_count', v_inserted_count
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;