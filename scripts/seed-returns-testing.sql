--
-- Seed de Datos para Testing de Devoluciones y Reparaciones
-- Brickshare Operations Panel
-- Para user2@brickshare.com y user3@brickshare.com
--
-- NOTA: Este seed usa el esquema actual de la BD
-- Estados válidos: pending, assigned, preparation, in_transit_pudo, delivered_pudo, 
--                  delivered_user, in_return_pudo, in_return, returned, cancelled
--

-- ===================================================================
-- 1. DATOS DE USUARIOS
-- ===================================================================
-- user2@brickshare.com (ID: 56402ebf-4740-43b6-984b-200bbcf06f27)
-- user3@brickshare.com (ID: ddeb8bef-314e-45d3-b9f2-3631a2733dcc)
-- admin@brickshare.com (ID: 37429d55-1c03-420e-a721-1eadeda71576)

-- ===================================================================
-- 2. CREAR SHIPMENT EN DEVOLUCIÓN (para sección "Devoluciones")
-- ===================================================================
INSERT INTO public.shipments (
  id,
  user_id,
  set_id,
  set_ref,
  shipment_status,
  shipping_address,
  shipping_city,
  shipping_zip_code,
  shipping_country,
  carrier,
  tracking_number,
  pickup_provider,
  delivery_qr_code,
  return_qr_code,
  brickshare_pudo_id,
  assigned_date,
  user_delivery_date,
  warehouse_reception_date,
  created_at,
  updated_at
)
VALUES (
  gen_random_uuid(),
  '56402ebf-4740-43b6-984b-200bbcf06f27',  -- user2@brickshare.com
  'b57d69db-36af-4654-a11e-9a8a6621096d',  -- Set 2824 (LEGO City Advent Calendar)
  '2824',
  'returned',                                -- Estado: devuelto, pendiente de procesamiento
  'Calle Principal 123, 28001 Madrid',
  'Madrid',
  '28001',
  'Spain',
  'correos',
  'CORREOS123456789',
  'correos',
  'QR-RET-001-2026',
  'QR-RET-001-2026-RETURN',
  'BS-PUDO-001',
  NOW() - INTERVAL '3 days',
  NOW() - INTERVAL '2 days',
  NOW() - INTERVAL '1 hour',
  NOW() - INTERVAL '3 days',
  NOW() - INTERVAL '1 hour'
)
ON CONFLICT DO NOTHING;

-- ===================================================================
-- 3. REGISTRAR PESO DEL SET DEVUELTO (validación de peso correcto)
-- ===================================================================
INSERT INTO public.reception_set_weight (
  id,
  set_id,
  weight_kg,
  expected_weight_kg,
  weight_variance_percentage,
  recorded_by,
  created_at,
  updated_at
)
SELECT
  gen_random_uuid(),
  'b57d69db-36af-4654-a11e-9a8a6621096d',  -- Set 2824
  0.4050,                                   -- Peso medido: 405g (dentro de tolerancia)
  0.4300,                                   -- Peso esperado: 430g
  ((0.4050 - 0.4300) / 0.4300) * 100,      -- Varianza: -5.81%
  '37429d55-1c03-420e-a721-1eadeda71576',  -- admin@brickshare.com
  NOW() - INTERVAL '1 hour',
  NOW() - INTERVAL '1 hour'
)
WHERE NOT EXISTS (
  SELECT 1 FROM public.reception_set_weight 
  WHERE set_id = 'b57d69db-36af-4654-a11e-9a8a6621096d'
);

-- ===================================================================
-- 4. REGISTRAR OPERACIÓN DE RECEPCIÓN (Devolución procesada)
-- ===================================================================
INSERT INTO public.reception_operations (
  id,
  event_id,
  user_id,
  set_id,
  weight_measured,
  reception_completed,
  created_at,
  updated_at
)
SELECT
  gen_random_uuid(),
  s.id,
  '37429d55-1c03-420e-a721-1eadeda71576',  -- admin@brickshare.com (operador)
  'b57d69db-36af-4654-a11e-9a8a6621096d',  -- Set 2824
  0.4050,
  true,
  NOW() - INTERVAL '1 hour',
  NOW() - INTERVAL '1 hour'
FROM public.shipments s
WHERE s.shipment_status = 'returned'
  AND s.set_id = 'b57d69db-36af-4654-a11e-9a8a6621096d'
  AND s.user_id = '56402ebf-4740-43b6-984b-200bbcf06f27'
  AND NOT EXISTS (
    SELECT 1 FROM public.reception_operations 
    WHERE event_id = s.id
  );

-- ===================================================================
-- 5. CREAR SEGUNDO SHIPMENT EN REPARACIÓN (para sección "Reparaciones")
-- ===================================================================
INSERT INTO public.shipments (
  id,
  user_id,
  set_id,
  set_ref,
  shipment_status,
  shipping_address,
  shipping_city,
  shipping_zip_code,
  shipping_country,
  carrier,
  tracking_number,
  pickup_provider,
  delivery_qr_code,
  return_qr_code,
  brickshare_pudo_id,
  assigned_date,
  user_delivery_date,
  warehouse_reception_date,
  created_at,
  updated_at
)
VALUES (
  gen_random_uuid(),
  'ddeb8bef-314e-45d3-b9f2-3631a2733dcc',  -- user3@brickshare.com
  '0b80731a-1e5a-4112-97f4-6b0d48424ed4',  -- Set 2928
  '2928',
  'returned',                                -- Estado: devuelto con piezas faltantes
  'Avenida del Parque 45, 28002 Madrid',
  'Madrid',
  '28002',
  'Spain',
  'correos',
  'CORREOS987654321',
  'correos',
  'QR-REP-002-2026',
  'QR-REP-002-2026-RETURN',
  'BS-PUDO-001',
  NOW() - INTERVAL '5 days',
  NOW() - INTERVAL '4 days',
  NOW() - INTERVAL '2 hours',
  NOW() - INTERVAL '5 days',
  NOW() - INTERVAL '2 hours'
)
ON CONFLICT DO NOTHING;

-- ===================================================================
-- 6. REGISTRAR PESO CON VARIANZA (detectar piezas faltantes)
-- ===================================================================
INSERT INTO public.reception_set_weight (
  id,
  set_id,
  weight_kg,
  expected_weight_kg,
  weight_variance_percentage,
  recorded_by,
  created_at,
  updated_at
)
SELECT
  gen_random_uuid(),
  '0b80731a-1e5a-4112-97f4-6b0d48424ed4',  -- Set 2928
  0.3500,                                   -- Peso medido: 350g (por debajo de esperado)
  0.4000,                                   -- Peso esperado: 400g
  ((0.3500 - 0.4000) / 0.4000) * 100,      -- Varianza: -12.5%
  '37429d55-1c03-420e-a721-1eadeda71576',  -- admin@brickshare.com
  NOW() - INTERVAL '2 hours',
  NOW() - INTERVAL '2 hours'
)
WHERE NOT EXISTS (
  SELECT 1 FROM public.reception_set_weight 
  WHERE set_id = '0b80731a-1e5a-4112-97f4-6b0d48424ed4'
);

-- ===================================================================
-- 7. REGISTRAR OPERACIÓN DE RECEPCIÓN (Set en reparación)
-- ===================================================================
INSERT INTO public.reception_operations (
  id,
  event_id,
  user_id,
  set_id,
  weight_measured,
  reception_completed,
  created_at,
  updated_at
)
SELECT
  gen_random_uuid(),
  s.id,
  '37429d55-1c03-420e-a721-1eadeda71576',  -- admin@brickshare.com (operador)
  '0b80731a-1e5a-4112-97f4-6b0d48424ed4',  -- Set 2928
  0.3500,
  false,  -- No completada (requiere reparación)
  NOW() - INTERVAL '2 hours',
  NOW() - INTERVAL '2 hours'
FROM public.shipments s
WHERE s.shipment_status = 'returned'
  AND s.set_id = '0b80731a-1e5a-4112-97f4-6b0d48424ed4'
  AND s.user_id = 'ddeb8bef-314e-45d3-b9f2-3631a2733dcc'
  AND NOT EXISTS (
    SELECT 1 FROM public.reception_operations 
    WHERE event_id = s.id
  );

-- ===================================================================
-- 8. REGISTRAR PIEZAS FALTANTES (Diferentes estados)
-- ===================================================================
INSERT INTO public.reception_missing_pieces (
  id,
  set_id,
  piece_ref,
  quantity,
  status,
  created_at,
  updated_at
)
VALUES
  -- Pieza 1: En estado pending (pendiente de solicitar)
  (
    gen_random_uuid(),
    '0b80731a-1e5a-4112-97f4-6b0d48424ed4',
    '3001',
    3,
    'pending',
    NOW() - INTERVAL '2 hours',
    NOW() - INTERVAL '2 hours'
  ),
  -- Pieza 2: En estado ordered (ya solicitada)
  (
    gen_random_uuid(),
    '0b80731a-1e5a-4112-97f4-6b0d48424ed4',
    '3005',
    5,
    'ordered',
    NOW() - INTERVAL '1 hour 45 minutes',
    NOW() - INTERVAL '1 hour 45 minutes'
  ),
  -- Pieza 3: En estado received (ya recibida)
  (
    gen_random_uuid(),
    '0b80731a-1e5a-4112-97f4-6b0d48424ed4',
    '4740',
    2,
    'received',
    NOW() - INTERVAL '1 hour 30 minutes',
    NOW() - INTERVAL '30 minutes'
  ),
  -- Pieza 4: Otra pieza pending
  (
    gen_random_uuid(),
    '0b80731a-1e5a-4112-97f4-6b0d48424ed4',
    '3622',
    1,
    'pending',
    NOW() - INTERVAL '2 hours',
    NOW() - INTERVAL '2 hours'
  )
ON CONFLICT DO NOTHING;

-- ===================================================================
-- CONFIRMACIÓN
-- ===================================================================
SELECT 'Seed de devoluciones completado exitosamente' as resultado;