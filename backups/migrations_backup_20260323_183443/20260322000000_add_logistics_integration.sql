-- ============================================================
-- BRICKSHARE — Migration: Integración con Brickshare_logistics
-- Añade campo para conectar shipments con packages del sistema de logistics
-- ============================================================

-- Añadir campo para almacenar el ID del package en Brickshare_logistics
ALTER TABLE envios
  ADD COLUMN brickshare_package_id TEXT;

COMMENT ON COLUMN envios.brickshare_package_id IS
  'ID del package en Brickshare_logistics. Usado cuando pickup_type="brickshare" para sincronización con el sistema de PUDO.';

-- Crear índice para consultas rápidas
CREATE INDEX idx_envios_brickshare_package_id 
  ON envios(brickshare_package_id) 
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
  FROM envios
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
  s.user_id,
  s.estado_envio as status,
  s.pickup_type,
  s.brickshare_pudo_id,
  s.brickshare_package_id,
  s.delivery_qr_code,
  s.delivery_validated_at as delivery_qr_validated_at,
  s.return_qr_code,
  s.return_validated_at as return_qr_validated_at,
  s.numero_seguimiento as tracking_number,
  s.created_at,
  s.updated_at
FROM envios s
WHERE s.pickup_type = 'brickshare'
  AND s.brickshare_pudo_id IS NOT NULL;

COMMENT ON VIEW public.brickshare_pudo_shipments IS
  'Vista de shipments que utilizan puntos PUDO de Brickshare_logistics';

-- ============================================================
-- FIN DE MIGRACIÓN
-- ============================================================