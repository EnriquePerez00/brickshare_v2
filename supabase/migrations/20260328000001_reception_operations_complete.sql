-- ═══════════════════════════════════════════════════════════════════════════════
-- RECEPTION OPERATIONS: Enhancements & Weight Tracking
-- ═══════════════════════════════════════════════════════════════════════════════
-- Esta migración complementa la estructura existente de reception_missing_pieces:
-- 1. Agrega columnas faltantes a reception_missing_pieces si es necesario
-- 2. Crea tabla reception_set_weight - Peso de sets devueltos
-- 3. Actualiza RPC process_set_return_with_weight para trabajar con la estructura existente
-- 4. Agrega función mark_repairs_complete para completar reparaciones

-- ═══════════════════════════════════════════════════════════════════════════════
-- 1. ENHANCEMENTS: reception_missing_pieces
-- ═══════════════════════════════════════════════════════════════════════════════
-- La tabla ya existe desde la migración anterior 20260328000000_reception_improvements.sql
-- Aquí simplemente agregamos índices adicionales si es necesario
CREATE INDEX IF NOT EXISTS idx_reception_missing_pieces_status ON public.reception_missing_pieces(status);

-- ═══════════════════════════════════════════════════════════════════════════════
-- 2. TABLA: reception_set_weight
-- ═══════════════════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.reception_set_weight (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    set_id UUID NOT NULL UNIQUE REFERENCES public.sets(id) ON DELETE CASCADE,
    set_ref TEXT NOT NULL,
    weight_kg NUMERIC(10, 3) NOT NULL,
    expected_weight_kg NUMERIC(10, 3),
    weight_variance_percentage NUMERIC(10, 2),
    recorded_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    notes TEXT
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_reception_set_weight_set_id ON public.reception_set_weight(set_id);
CREATE INDEX IF NOT EXISTS idx_reception_set_weight_created_at ON public.reception_set_weight(created_at DESC);

-- RLS
ALTER TABLE public.reception_set_weight ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Operadores can view and manage set weights"
    ON public.reception_set_weight
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.user_roles
            WHERE user_id = auth.uid() AND role = 'operador'::app_role
        )
        OR
        EXISTS (
            SELECT 1 FROM public.user_roles
            WHERE user_id = auth.uid() AND role = 'admin'::app_role
        )
    );

-- ═══════════════════════════════════════════════════════════════════════════════
-- 3. RPC: mark_repairs_complete
-- ═══════════════════════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION public.mark_repairs_complete(
    p_set_id UUID,
    p_notes TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_set_ref TEXT;
    v_missing_pieces_count INTEGER;
BEGIN
    -- Obtener información del set
    SELECT set_ref INTO v_set_ref
    FROM public.sets
    WHERE id = p_set_id;

    IF v_set_ref IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Set not found'
        );
    END IF;

    -- Contar piezas faltantes aún registradas
    SELECT COUNT(*) INTO v_missing_pieces_count
    FROM public.reception_missing_pieces
    WHERE set_id = p_set_id;

    -- Cambiar estado a disponible
    UPDATE public.sets
    SET set_status = 'active',
        updated_at = NOW()
    WHERE id = p_set_id;

    -- Actualizar inventario si existe
    UPDATE public.inventory_sets
    SET en_stock = en_stock + 1,
        en_reparacion = CASE WHEN en_reparacion > 0 THEN en_reparacion - 1 ELSE 0 END,
        updated_at = NOW()
    WHERE set_id = p_set_id;

    RETURN jsonb_build_object(
        'success', true,
        'message', 'Repairs marked as complete',
        'set_ref', v_set_ref,
        'missing_pieces_recorded', v_missing_pieces_count,
        'status', 'active'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ═══════════════════════════════════════════════════════════════════════════════
-- DOCUMENTACIÓN
-- ═══════════════════════════════════════════════════════════════════════════════
COMMENT ON TABLE public.reception_set_weight IS 'Registro del peso de sets devueltos. Usado para detectar automáticamente piezas faltantes mediante varianza de peso.';
COMMENT ON FUNCTION public.mark_repairs_complete(UUID, TEXT) IS 'Marca un set como reparado y lo devuelve al inventario disponible.';
