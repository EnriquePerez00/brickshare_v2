# Error de Asignación: Falta de `pudo_type` - FIX

## Problema

Cuando intentabas asignar un set a "Enrique Perez", recibías el error:
```
Error en el Procesamiento de Pago
Edge Function returned a non-2xx status code
```

## Causa Raíz

La migración `20260324074025_fix_preview_assign_user_status_values.sql` corrigió los valores de `user_status` pero **eliminó accidentalmente** el campo `pudo_type` de la función `preview_assign_sets_to_users()`.

El frontend necesita `pudo_type` para determinar si debe ejecutar la preregistración de Correos. Sin este campo, la función `process-assignment-payment` recibía parámetros incompletos y fallaba.

## Solución

Se creó una nueva migración: `20260326100000_restore_pudo_type_to_preview_function.sql`

Esta migración:
1. Restaura el campo `pudo_type` en la tabla de retorno de la función
2. Incluye la lógica para obtener `u.pudo_type` del usuario
3. Retorna `pudo_type` junto con el resto de datos de asignación

### Cambios en la Función

**Antes (incompleto):**
```sql
RETURNS TABLE (
    user_id UUID,
    user_name TEXT,
    set_id UUID,
    set_name TEXT,
    set_ref TEXT,
    set_price DECIMAL,
    current_stock INTEGER,
    matches_wishlist BOOLEAN
    -- ❌ FALTA: pudo_type
)
```

**Después (completo):**
```sql
RETURNS TABLE (
    user_id UUID,
    user_name TEXT,
    set_id UUID,
    set_name TEXT,
    set_ref TEXT,
    set_price DECIMAL,
    current_stock INTEGER,
    matches_wishlist BOOLEAN,
    pudo_type TEXT  -- ✅ RESTAURADO
)
```

## Aplicación

La migración fue aplicada manualmente a la BD local:
```bash
psql postgresql://postgres:postgres@127.0.0.1:5433/postgres \
  -f supabase/migrations/20260326100000_restore_pudo_type_to_preview_function.sql
```

**Estado**: ✅ Completada

## Verificación

```bash
psql postgresql://postgres:postgres@127.0.0.1:5433/postgres -c "\df+ public.preview_assign_sets_to_users"
```

Resultado esperado:
```
Result data type: TABLE(user_id uuid, user_name text, set_id uuid, set_name text, set_ref text, set_price numeric, current_stock integer, matches_wishlist boolean, pudo_type text)
```

## Próximos Pasos

1. Recargar la página del frontend (http://localhost:8081)
2. Intentar asignar un set a "Enrique Perez" nuevamente
3. La asignación debe completarse sin errores

## Notas

- Esta es una corrección de regresión introducida en la migración anterior
- El campo `pudo_type` es crítico para el flujo de logística de Correos
- La función incluye protecciones para usuarios con roles admin/operador (se excluyen de asignaciones)