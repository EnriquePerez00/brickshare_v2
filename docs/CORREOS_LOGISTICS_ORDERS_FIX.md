# Fix: Correos Logistics Edge Function - Eliminación de referencias a tabla `orders`

**Fecha**: 25 de marzo de 2026  
**Afectado**: `supabase/functions/correos-logistics/index.ts`  
**Error**: "Edge Function returned a non-2xx status code" al generar etiquetas

## 🔍 Problema

La Edge Function `correos-logistics` estaba intentando acceder a la tabla `orders` que fue eliminada en la refactorización del sistema (migración `20260324200730_remove_orders_table_references.sql`).

### Error específico

Al intentar generar una etiqueta para un envío, la función fallaba en el caso `preregister` con un error de base de datos porque:

```typescript
// ❌ Código antiguo (incorrecto)
order_id,
orders (
    set_id,
    sets (
        set_name,
        set_ref,
        set_weight,
        set_dim
    )
)
```

La tabla `orders` ya no existe. Los datos del set ahora están directamente en la tabla `shipments`.

## ✅ Solución

Se actualizaron **tres casos** en la Edge Function para usar la nueva estructura:

### 1. Caso `preregister`

**Antes:**
```typescript
.select(`
    id, 
    shipping_address, 
    shipping_city, 
    shipping_postal_code, 
    user_id,
    order_id,              // ❌
    orders (               // ❌
        set_id,
        sets (...)
    ),
    users:user_id (...)
`)
```

**Después:**
```typescript
.select(`
    id, 
    shipping_address, 
    shipping_city, 
    shipping_postal_code, 
    user_id,
    set_id,                // ✅ Directamente en shipments
    sets:set_id (          // ✅ Relación directa
        set_name,
        set_ref,
        set_weight,
        set_dim
    ),
    users:user_id (...)
`)
```

**Acceso a datos:**
```typescript
// Antes: shipment.orders?.sets?.set_weight
// Después: shipment.sets?.set_weight
```

### 2. Caso `return_preregister`

Se aplicaron los mismos cambios:
- Eliminado `order_id` y `orders ()`
- Añadido `set_id` y `sets:set_id ()`
- Actualizado acceso a datos del set
- Actualizado email HTML para usar `shipment.sets?.set_name`

### 3. Caso `request_pickup`

No requiere cambios porque no accede a datos de sets, solo usa `*` para obtener datos del shipment y usuario.

## 📋 Cambios realizados

| Línea | Cambio |
|-------|--------|
| ~240-255 | Query de preregister: eliminado `order_id`, `orders ()`, añadido `set_id`, `sets:set_id ()` |
| ~287 | Acceso a peso: `shipment.orders?.sets?.set_weight` → `shipment.sets?.set_weight` |
| ~288 | Acceso a dimensiones: `shipment.orders?.sets?.set_dim` → `shipment.sets?.set_dim` |
| ~326-341 | Query de return_preregister: mismo cambio que preregister |
| ~380 | Acceso a peso en return: mismo cambio |
| ~381 | Acceso a dimensiones en return: mismo cambio |
| ~424 | Email HTML: `shipment.orders?.sets?.set_name` → `shipment.sets?.set_name` |

## 🧪 Testing

Para verificar que la corrección funciona:

1. **Acceder al panel de operaciones** en http://localhost:5173/operations
2. **Ir a la pestaña "Generación de Etiquetas"**
3. **Seleccionar un envío asignado** (debe estar en estado `assigned`)
4. **Hacer clic en "Generar Etiqueta"**
5. **Verificar que**:
   - Para envíos Correos: se crea el preregistro, se genera el PDF, se abre en nueva ventana
   - Para envíos Brickshare: se envía el email con código QR
   - El estado del shipment se actualiza a `in_transit_pudo`
   - No hay errores en la consola del navegador

## 🔗 Contexto

Esta corrección es consecuencia de:

- **Migración**: `20260324200730_remove_orders_table_references.sql`
- **Documentación**: `docs/SHIPMENTS_TABLE_CLEANUP.md`
- **Ticket relacionado**: Error de generación de etiqueta para usuario "Enrique Perez"

## ⚠️ Importante

- **NO requiere reset de base de datos** - Solo es un cambio de código
- **Los datos siguen intactos** - Solo cambia cómo se accede a ellos
- **Funciona en local automáticamente** - Supabase detecta el cambio
- **Para producción**: Se debe hacer `supabase functions deploy correos-logistics`

## 📝 Notas adicionales

- Los errores de TypeScript en VS Code son **normales** para Edge Functions (runtime Deno)
- La función se ejecuta correctamente a pesar de los errores de linter
- Si se añaden más casos a esta función en el futuro, recordar usar `set_id` y `sets:set_id ()` en lugar de `order_id` y `orders ()`