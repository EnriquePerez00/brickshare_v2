# Fix: Eliminación Completa de `set_dim`

**Fecha**: 2026-03-25  
**Problema**: Error "Edge Function returned a non-2xx status code" al confirmar asignación de sets  
**Usuario afectado**: user2@brickshare.com y potencialmente otros

## Problema

Al intentar confirmar la asignación de un set a un usuario, se producía un error 500 en la Edge Function `process-assignment-payment`. La causa raíz era que la función RPC `confirm_assign_sets_to_users()` intentaba leer la columna `s.set_dim` de la tabla `sets`, pero esta columna **ya no existe**.

### Error Original
```
Error en el Procesamiento de Pago
Usuario: User Two
Email: user2@brickshare.com
Error: Edge Function returned a non-2xx status code
```

### Contexto Histórico
La columna `set_dim` fue eliminada en la migración `20260203190000_drop_set_dim.sql`, pero algunas migraciones posteriores reintrodujeron referencias a ella en funciones RPC sin que la columna existiera en la tabla.

## Solución

### 1. Migración Creada: `20260325110000_remove_set_dim_completely.sql`

Esta migración:
- Elimina `set_dim` del tipo de retorno de la función
- Elimina la variable local `v_set_dim`
- Elimina `s.set_dim` del SELECT que consulta la wishlist
- Elimina la asignación de `set_dim` en el return record

### 2. Cambios Específicos

**ANTES** (función con error):
```sql
RETURNS TABLE(
    ...
    set_weight numeric,
    set_dim text,  -- ❌ Columna que no existe
    pudo_id text,
    ...
)
...
DECLARE
    v_set_dim TEXT;  -- ❌ Variable innecesaria
...
SELECT 
    w.set_id,
    s.set_name,
    s.set_ref,
    s.set_weight,
    s.set_dim  -- ❌ SELECT de columna inexistente
INTO 
    target_set_id,
    v_set_name,
    v_set_ref,
    v_set_weight,
    v_set_dim
...
confirm_assign_sets_to_users.set_dim := v_set_dim;  -- ❌ Asignación innecesaria
```

**DESPUÉS** (función corregida):
```sql
RETURNS TABLE(
    ...
    set_weight numeric,
    pudo_id text,  -- ✅ Sin set_dim
    ...
)
...
DECLARE
    -- ✅ Sin v_set_dim
...
SELECT 
    w.set_id,
    s.set_name,
    s.set_ref,
    s.set_weight  -- ✅ Sin s.set_dim
INTO 
    target_set_id,
    v_set_name,
    v_set_ref,
    v_set_weight
...
-- ✅ Sin asignación de set_dim
```

## Verificación

Para verificar que el fix funciona correctamente:

```bash
# 1. Verificar que la función existe y no tiene set_dim
psql postgresql://postgres:postgres@127.0.0.1:5433/postgres -c "\sf confirm_assign_sets_to_users"

# 2. Verificar estructura de la tabla sets
psql postgresql://postgres:postgres@127.0.0.1:5433/postgres -c "\d sets"

# 3. Probar asignación desde el frontend
# - Login como admin
# - Ir a Admin → Operations → Set Assignment
# - Preview assignment para user2@brickshare.com
# - Confirm assignment
# - Debería funcionar sin errores
```

## Impacto

### Backend
- ✅ Función RPC corregida
- ✅ No afecta a otras funciones (preview_assign_sets_to_users no usa set_dim)
- ✅ Compatible con todos los flujos existentes

### Frontend
- ⚠️ Verificar que `SetAssignment.tsx` y `process-assignment-payment` no dependan de `set_dim`
- ⚠️ El campo `set_dim` ya no se retorna en el resultado de la confirmación

### Base de Datos
- ✅ La columna `set_dim` nunca existió en producción reciente
- ✅ No hay datos que migrar

## Prevención Futura

Para evitar que esto vuelva a ocurrir:

1. **Antes de eliminar columnas**, buscar todas las referencias:
   ```bash
   grep -r "set_dim" supabase/migrations/
   ```

2. **Testear funciones RPC** después de cambios de esquema:
   ```sql
   SELECT * FROM confirm_assign_sets_to_users(ARRAY['<user_id>']::uuid[]);
   ```

3. **Regenerar tipos TypeScript** después de cada migración:
   ```bash
   supabase gen types typescript --local > src/types/supabase.ts
   ```

## Archivos Modificados

- `supabase/migrations/20260325110000_remove_set_dim_completely.sql` (NUEVO)
- `docs/SET_DIM_REMOVAL_FIX.md` (NUEVO - este archivo)

## Referencias

- Migración que eliminó originalmente `set_dim`: `20260203190000_drop_set_dim.sql`
- Migraciones que reintrodujeron referencias erróneas:
  - `20260225133500_update_confirm_assignment_rpc.sql`
  - `20260322110000_rename_remaining_spanish_columns.sql`
  - `20260324160000_fix_confirm_assign_function.sql`
  - `20260324170000_fix_assignment_shipment_creation.sql`
  - `20260325100000_cleanup_shipments_unused_fields.sql`