-- ============================================================================
-- RPC: mark_pieces_as_ordered
-- Marca piezas faltantes pendientes como "ordered" para la sección Comprar Piezas
-- ============================================================================

CREATE OR REPLACE FUNCTION public.mark_pieces_as_ordered(
    p_piece_refs TEXT[]
)
RETURNS JSON AS $$
DECLARE
    v_updated_count INTEGER := 0;
BEGIN
    -- Validar que hay piece_refs
    IF array_length(p_piece_refs, 1) IS NULL OR array_length(p_piece_refs, 1) = 0 THEN
        RETURN json_build_object(
            'success', false,
            'error', 'No piece references provided',
            'updated_count', 0
        );
    END IF;

    -- Actualizar todas las piezas pending que coincidan con los piece_refs
    UPDATE public.reception_missing_pieces
    SET status = 'ordered',
        updated_at = NOW()
    WHERE piece_ref = ANY(p_piece_refs)
    AND status = 'pending';

    GET DIAGNOSTICS v_updated_count = ROW_COUNT;

    RETURN json_build_object(
        'success', true,
        'updated_count', v_updated_count,
        'piece_refs_processed', array_length(p_piece_refs, 1)
    );
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'success', false,
        'error', SQLERRM,
        'updated_count', 0
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION public.mark_pieces_as_ordered(TEXT[]) IS 'Marca piezas faltantes con status pending como ordered. Usado desde la sección Comprar Piezas del panel admin.';