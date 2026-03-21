# Script de Limpieza de Datos para Testing

## Propósito

Este script resetea la base de datos de Brickshare para permitir pruebas del flujo completo de envíos desde cero.

## Qué hace el script

1. **Elimina todos los envíos** - Limpia completamente la tabla `envios`
2. **Limpia wishlists** - Elimina todas las wishlists existentes
3. **Asegura inventario** - Crea/actualiza entradas en `inventory_sets` con stock mínimo de 5 unidades
4. **Repuebla wishlists** - Asigna 10 sets aleatorios (con stock) a cada usuario regular
5. **Resetea estados** - Cambia el estado de todos los usuarios regulares a `sin set`
6. **Verifica** - Confirma que los datos están listos para testing

## Usuarios afectados

- ✅ **Usuarios regulares**: Reseteados completamente
- ❌ **Admin/Operador**: NO afectados (mantienen su estado)

## Cómo ejecutar

### Opción 1: Supabase CLI (Recomendado)

```bash
# Desde la raíz del proyecto
supabase db execute --file scripts/reset-test-data.sql
VERIFICACIÓN FINAL
Envíos en base de datos: 0
Items en wishlist: [número]
Usuarios regulares: [número]
Usuarios con estado "sin set": [número]
✓ Base de datos lista para pruebas de envíos
```
```
VERIFICACIÓN FINAL
Envíos en base de datos: 0
Items en wishlist: [número]
Sets con stock en inventario: [número]
Usuarios regulares: [número]
Usuarios con estado "sin set": [número]
✓ Base de datos lista para pruebas de envíos
```

### Opción 2: SQL Editor en Supabase Dashboard

1. Accede a tu proyecto en Supabase Dashboard
2. Ve a `SQL Editor`
3. Copia el contenido de `scripts/reset-test-data.sql`
4. Pégalo en el editor
5. Ejecuta el script

### Opción 3: psql (CLI de PostgreSQL)

```bash
psql -h <tu-host> -U postgres -d postgres -f scripts/reset-test-data.sql
```

## Verificación

El script incluye verificación automática al final. Deberías ver:

```
========================================
VERIFICACIÓN FINAL
========================================
Envíos en base de datos: 0
Items en wishlist: [número]
Usuarios regulares: [número]
Usuarios con estado "sin set": [número]
========================================
✓ Base de datos lista para pruebas de envíos
```

## Qué esperar después de ejecutar

Después de ejecutar este script:

- ✅ Todos los usuarios regulares tendrán 10 sets en su wishlist
- ✅ Todos los sets tendrán stock disponible en `inventory_sets` (mínimo 5 unidades)
- ✅ No habrá envíos activos en el sistema
- ✅ Todos los usuarios regulares tendrán estado `sin set`
- ✅ Los usuarios admin/operador no se verán afectados
- ✅ Podrás empezar a probar el flujo de asignación y envío desde cero

## Flujo de prueba recomendado

1. **Ejecutar este script** para limpiar datos
2. **Ir al panel de Operaciones** (como operador/admin)
3. **Preview de asignaciones** - Ver qué usuarios recibirán sets
4. **Confirmar asignaciones** - Crear envíos para los usuarios
5. **Verificar en Dashboard de usuario** - Ver la sección "Set en curso"
6. **Probar flujo completo** - Desde asignación hasta devolución

## Seguridad

- ✅ El script usa transacciones (BEGIN/COMMIT)
- ✅ Si algo falla, se revierte automáticamente
- ✅ No afecta a usuarios admin/operador
- ✅ Se puede ejecutar múltiples veces sin problemas (idempotente)

## Troubleshooting

### Error: "relation does not exist"

Si ves errores sobre tablas que no existen, verifica que:
- Todas las migraciones de Supabase estén aplicadas
- Estás ejecutando el script en la base de datos correcta

### No se insertan items en wishlist

Verifica que:
- Existan sets con `set_status = 'available'` en la tabla `sets`
- Existan entradas en `inventory_sets` con `inventory_set_total_qty > 0`
- Los usuarios tengan `user_role = 'user'` o no tengan rol de admin/operador

### Error: "No se encontraron asignaciones posibles"

Este error en el panel de Operaciones significa que:
- No hay stock en `inventory_sets` para los sets en las wishlists
- O los usuarios no tienen estado `sin set` o `set en devolucion`

**Solución**: Ejecuta este script para asegurar que hay stock disponible

### El script no hace nada

Si no ves cambios, verifica:
- Que existan usuarios regulares en la base de datos
- Que el usuario de la base de datos tenga permisos de escritura

## Archivo relacionado

- Script SQL: `scripts/reset-test-data.sql`
- Dashboard actualizado: `src/pages/Dashboard.tsx` (con sección "Set en curso")
- Hook de datos: `src/hooks/useOrders.ts` (incluye `useActiveOrders`)