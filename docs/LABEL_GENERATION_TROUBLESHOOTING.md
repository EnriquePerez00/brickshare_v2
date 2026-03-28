# Label Generation Troubleshooting Guide

## Problema Reportado

**Error**: "Edge Function returned a non-2xx status code" al intentar generar etiqueta para usuario "Enrique Perez"

**Fecha**: 25/03/2026

## Causa Raíz Identificada

La Edge Function `correos-logistics` contenía referencias a la tabla `orders` que fue eliminada en migraciones anteriores. Esto causaba errores en los casos `preregister` y `return_preregister`.

## Corrección Aplicada

✅ **Actualizada** `supabase/functions/correos-logistics/index.ts`:
- Removidas todas las referencias a la tabla `orders`
- Actualizada lógica para usar directamente campos de `shipments`:
  - `set_ref` (identificador del set)
  - `set_id` (FK a tabla sets)
- Casos corregidos: `preregister`, `return_preregister`

✅ **Reiniciado** Supabase local para cargar la función actualizada

## Cómo Monitorear Logs en Tiempo Real

Si el error vuelve a ocurrir, sigue estos pasos:

### 1. Monitorear logs del contenedor Edge Runtime

```bash
# Ver logs en tiempo real
docker logs -f supabase_edge_runtime_tevoogkifiszfontzkgd

# O filtrar solo errores
docker logs -f supabase_edge_runtime_tevoogkifiszfontzkgd 2>&1 | grep -i error
```

### 2. Capturar logs específicos de correos-logistics

```bash
# Logs de las últimas invocaciones
docker logs supabase_edge_runtime_tevoogkifiszfontzkgd --tail 100 | grep -A 20 "correos-logistics"
```

### 3. Verificar estado de shipments en BD

```bash
# Listar shipments pendientes de etiqueta
psql postgresql://postgres:postgres@127.0.0.1:5433/postgres -c \
  "SELECT s.id, s.shipment_status, s.pudo_type, s.set_ref, u.full_name 
   FROM shipments s 
   JOIN users u ON s.user_id = u.id 
   WHERE s.shipment_status = 'assigned' 
   ORDER BY s.created_at DESC;"
```

### 4. Probar función manualmente con curl

```bash
# Obtener token JWT del usuario admin
# (Desde la consola de desarrollo del navegador en la app)
TOKEN="your-jwt-token"

# Probar preregister
curl -X POST http://127.0.0.1:54331/functions/v1/correos-logistics \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "preregister",
    "p_shipment_id": "shipment-uuid-aqui"
  }'
```

## Verificación Post-Corrección

### Estado Actual
- ❌ No hay shipments de "Enrique Perez" en BD actualmente
- ✅ Función `correos-logistics` corregida y actualizada
- ✅ Supabase reiniciado con nueva versión de la función

### Próximos Pasos para Verificar
1. Crear un nuevo shipment en estado `assigned`
2. Intentar generar etiqueta desde el panel de operaciones
3. Verificar que:
   - No aparece el error "non-2xx status"
   - La etiqueta se genera correctamente
   - El status se actualiza a `in_transit_pudo`

## Testing Rápido

### Crear shipment de prueba
```sql
-- Desde psql
INSERT INTO shipments (
  user_id,
  set_id,
  set_ref,
  shipment_type,
  shipment_status,
  pudo_type,
  brickshare_pudo_id
) VALUES (
  (SELECT id FROM users WHERE email = 'enriqueperezbcn1973@gmail.com'),
  (SELECT id FROM sets WHERE set_ref = '21005' LIMIT 1),
  '21005',
  'delivery',
  'assigned',
  'brickshare',
  (SELECT id FROM brickshare_pudo_locations LIMIT 1)
) RETURNING id;
```

### Generar etiqueta
1. Ir a http://localhost:5173 → Panel de Operaciones → Generación de Etiquetas
2. Buscar el shipment recién creado
3. Clic en "Generar Etiqueta"
4. Verificar resultado

## Documentos Relacionados

- [CORREOS_LOGISTICS_ORDERS_FIX.md](./CORREOS_LOGISTICS_ORDERS_FIX.md) - Detalles técnicos de la corrección
- [EXTERNAL_LOGISTICS_API.md](./EXTERNAL_LOGISTICS_API.md) - Documentación de la API de logística
- [LABEL_GENERATION_FEATURE.md](./LABEL_GENERATION_FEATURE.md) - Feature completa de generación de etiquetas

## Notas Importantes

⚠️ **El mensaje genérico "non-2xx status"** no indica la causa real del error. Siempre revisar logs del contenedor para obtener el stack trace completo.

⚠️ **Reiniciar Supabase** es necesario después de modificar Edge Functions para que los cambios se apliquen.

⚠️ **Verificar puerto correcto**: BD está en puerto `5433` (no 54322)