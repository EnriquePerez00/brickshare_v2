-- ============================================================================
-- Test: Verificar asignación de set para usuario 4
-- Description: Prueba completa de la función confirm_assign_sets_to_users
-- ============================================================================

-- Ver información del usuario 4
SELECT 
  user_id,
  email,
  subscription_status,
  subscription_plan
FROM users 
WHERE user_id = 4;

-- Ver asignaciones previas del usuario 4 (si existen)
SELECT 
  id,
  user_id,
  set_id,
  shipment_status,
  created_at
FROM shipments 
WHERE user_id = 4
ORDER BY created_at DESC;

-- Ejecutar preview para ver qué se asignaría
SELECT * FROM preview_assign_sets_to_users();

-- Si el preview muestra al usuario 4, ejecutar confirmación
-- (Comentado por seguridad, descomentar cuando estés listo)
-- SELECT confirm_assign_sets_to_users(ARRAY[4]);

-- Verificar que se creó el shipment con status 'assigned'
-- (Ejecutar después de confirm_assign_sets_to_users)
-- SELECT 
--   id,
--   user_id,
--   set_id,
--   shipment_status,
--   delivery_address,
--   pudo_location_id,
--   created_at
-- FROM shipments 
-- WHERE user_id = 4
-- ORDER BY created_at DESC
-- LIMIT 1;