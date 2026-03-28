# Fix: confirm_assign_sets_to_users Function - 404 Error

**Fecha:** 25 de marzo de 2026  
**Migración:** `20260325120000_fix_confirm_function_remove_orders.sql`

## Problema Detectado

Al asignar sets a usuarios desde el panel de administración, se producía un **error 404**:

```
POST http://localhost:54331/rest/v1/rpc/confirm_assign_sets_to_users 404 (Not Found)
```

Seguido de errores en el frontend:
- "Database operation failed after payment. Manual cleanup may be needed"
- "Payment IntentIDs: {depositId: undefined, transportId: undefined}"

## Causa Raíz

La función `confirm_assign_sets_to_users` tenía una **discrepancia crítica** entre lo que retornaba y lo que esperaba el frontend:

### Estado Anterior (INCORRECTO)

```sql
RETURNS TABLE(
    envio_id uuid,      -- ❌ Nombre en español
    order_id uuid,      -- ❌ Referencia a tabla eliminada
    user_id uuid,
    set_id uuid,
    ...
)
```

La función también intentaba insertar en la tabla `orders`:
```sql
INSERT INTO public.orders (user_id, set_id, status)
VALUES (r.user_id, target_set_id, 'pending')
RETURNING id INTO new_order_id;
```

**Pero la tabla `orders` fue eliminada** en la migración `20260324200730_remove_orders_table_references.sql`.

### Frontend Esperaba

```typescript
interface AssignmentResult {
  shipment_id: uuid;  // ✅ Nombre en inglés
  user_id: uuid;
  set_id: uuid;
  // NO espera order_id
  ...
}
```

El frontend (SetAssignment.tsx línea 188) accedía:
```typescript
shipment.shipment_id  // ❌ UNDEFINED porque la función retornaba "envio_id"
```

## Solución Implementada

### Cambios en la Función

1. **Eliminada referencia a tabla `orders`:**
   - Removido el `INSERT INTO public.orders`
   - Removida variable `new_order_id`
   - Removido campo `order_id` del RETURN

2. **Renombrado de campos:**
   - `envio_id` → `shipment_id`
   - `new_envio_id` → `new_shipment_id`

3. **Estructura del RETURN actualizada:**

```sql
RETURNS TABLE(
    shipment_id uuid,    -- ✅ Nombre correcto
    user_id uuid,
    set_id uuid,
    user_name text,
    user_email text,
    user_phone text,
    set_name text,
    set_ref text,
    set_weight numeric,
    pudo_id text,
    pudo_name text,
    pudo_address text,
    pudo_cp text,
    pudo_city text,
    pudo_province text,
    created_at timestamp with time zone
)
```

### Lógica Conservada

La función mantiene toda su lógica de negocio:
- ✅ Validación de usuarios elegibles (`no_set`, `set_returning`)
- ✅ Comprobación de wishlist activa
- ✅ Selección del primer set disponible
- ✅ Actualización de inventario (decrementa total, incrementa `in_shipping`)
- ✅ Creación de shipment con estado `assigned`
- ✅ Actualización de `user_status` a `set_shipping`
- ✅ Marcado de item en wishlist como asignado
- ✅ Soporte para PUDO Correos y Brickshare

## Verificación

```bash
# Verificar que la función existe con la estructura correcta
psql postgresql://postgres:postgres@127.0.0.1:5433/postgres \
  -c "\df confirm_assign_sets_to_users"

# Resultado esperado:
# RETURNS TABLE(shipment_id uuid, user_id uuid, ...)
```

## Impacto

- ✅ **Sin pérdida de datos:** Solo se modifica la definición de la función
- ✅ **Sin cambios en frontend:** El código ya esperaba `shipment_id`
- ✅ **Compatibilidad completa:** Eliminada dependencia obsoleta de `orders`
- ✅ **Fix inmediato:** No requiere reinicio de servicios

## Testing

Para probar la asignación:

1. Accede al panel admin: http://localhost:5173/admin/operations
2. Ve a la pestaña "Set Assignment"
3. Ejecuta "Preview Assignment"
4. Confirma la asignación
5. Verifica que:
   - ✅ No aparece error 404
   - ✅ Los shipments se crean correctamente
   - ✅ El inventario se actualiza
   - ✅ Los usuarios cambian a estado `set_shipping`

## Archivos Relacionados

- **Migración:** `supabase/migrations/20260325120000_fix_confirm_function_remove_orders.sql`
- **Frontend:** `apps/web/src/components/admin/operations/SetAssignment.tsx`
- **Documentación previa:** `docs/SHIPMENTS_TABLE_CLEANUP.md`
- **Documentación previa:** `docs/STRIPE_PAYMENT_REFACTOR.md`

## Notas

Esta migración completa la limpieza del refactor que eliminó la tabla `orders`. La función `confirm_assign_sets_to_users` era la última dependencia que quedaba por actualizar.