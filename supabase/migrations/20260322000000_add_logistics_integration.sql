-- ============================================================
-- BRICKSHARE — Migration: Integración con Brickshare_logistics
-- Añade campo para conectar shipments con packages del sistema de logistics
-- ============================================================

-- Añadir campo para almacenar el ID del package en Brickshare_logistics
ALTER TABLE shipments
  ADD COLUMN brickshare_package_id TEXT;

COMMENT ON COLUMN shipments.brickshare_package_id IS
  'ID del package en Brickshare_logistics. Usado cuando pickup_type="brickshare" para sincronización con el sistema de PUDO.';

-- Crear índice para consultas rápidas
CREATE INDEX idx_shipments_brickshare_package_id 
  ON shipments(brickshare_package_id) 
  WHERE brickshare_package_id IS NOT NULL;

-- ============================================================
-- Función helper para validar si un shipment usa Brickshare PUDO
-- ============================================================

CREATE OR REPLACE FUNCTION public.uses_brickshare_pudo(shipment_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
AS $$
  SELECT pickup_type = 'brickshare' AND brickshare_pudo_id IS NOT NULL
  FROM shipments
  WHERE id = shipment_id;
$$;

COMMENT ON FUNCTION public.uses_brickshare_pudo IS
  'Retorna true si el shipment usa el sistema de PUDO de Brickshare_logistics';

-- ============================================================
-- Vista para shipments que usan Brickshare PUDO
-- ============================================================

CREATE OR REPLACE VIEW public.brickshare_pudo_shipments AS
SELECT
  s.id,
  s.assignment_id,
  s.direction,
  s.status,
  s.pickup_type,
  s.brickshare_pudo_id,
  s.brickshare_package_id,
  s.delivery_qr_code,
  s.delivery_qr_validated_at,
  s.return_qr_code,
  s.return_qr_validated_at,
  s.tracking_number,
  s.created_at,
  s.updated_at,
  a.user_id,
  a.product_id
FROM shipments s
JOIN assignments a ON a.id = s.assignment_id
WHERE s.pickup_type = 'brickshare'
  AND s.brickshare_pudo_id IS NOT NULL;

COMMENT ON VIEW public.brickshare_pudo_shipments IS
  'Vista de shipments que utilizan puntos PUDO de Brickshare_logistics';

-- ============================================================
-- FIN DE MIGRACIÓN
-- ============================================================