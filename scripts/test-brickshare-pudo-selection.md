# Test Script: Brickshare PUDO Selection

## Objetivo
Validar que la selección de un punto PUDO Brickshare funciona correctamente después de la corrección del bug.

## Problema Original
- El componente `PudoSelector` enviaba `tipo_punto: 'Deposito'` para puntos Brickshare
- El sistema esperaba el tipo normalizado pero no manejaba correctamente la transformación
- Error al intentar guardar el PUDO en la base de datos

## Solución Implementada
1. **Normalización mejorada en Dashboard.tsx**: Logs detallados del flujo
2. **Tipo actualizado en packages/shared/types/pudo.ts**: Soporte para 'brickshare', 'brickshare_deposit' y 'correos'
3. **Logs de debug en pudoService.ts**: Trazabilidad completa del guardado

## Pasos de Prueba

### 1. Preparación
```bash
# Asegurarse de que el servidor de desarrollo está corriendo
npm run dev

# En otra terminal, asegurarse de que Supabase local está activo
supabase status
```

### 2. Test Manual en la UI

1. **Login** en la aplicación
2. **Ir al Dashboard** (`/dashboard`)
3. **Hacer clic en "Seleccionar punto"** en la sección PUDO
4. **Buscar una dirección** (ej: "josep tarradellas 97, 08029")
5. **Seleccionar un Depósito Brickshare** (marcador verde en el mapa)
6. **Hacer clic en "Confirmar Selección"**

### 3. Verificar en la Consola del Navegador

Deberías ver logs como:
```
📍 [handlePudoSelect] Selected point: {...}
📍 [handlePudoSelect] Point tipo_punto value: Deposito
📍 [handlePudoSelect] Normalized type: Deposito
🏢 [handlePudoSelect] Processing as Brickshare deposit
🔄 [transformPUDOPointToBricksharePudo] Transforming point: {...}
✅ [transformPUDOPointToBricksharePudo] Transformed result: {...}
🏢 [saveUserBricksharePudo] Starting save for user: ...
🏢 [saveUserBricksharePudo] PUDO data: {...}
🗑️ [saveUserBricksharePudo] Deleting existing Correos PUDO...
💾 [saveUserBricksharePudo] Saving Brickshare PUDO to users_brickshare_dropping...
✅ [saveUserBricksharePudo] Saved to users_brickshare_dropping successfully
💾 [saveUserBricksharePudo] Updating users table with unified reference...
✅ [saveUserBricksharePudo] Users table updated successfully
✅ [handlePudoSelect] Brickshare PUDO saved successfully
```

### 4. Verificar en la Base de Datos

```sql
-- Verificar que el PUDO se guardó en users_brickshare_dropping
SELECT * FROM public.users_brickshare_dropping 
WHERE user_id = 'TU_USER_ID';

-- Verificar que la referencia en users está correcta
SELECT user_id, pudo_id, pudo_type 
FROM public.users 
WHERE user_id = 'TU_USER_ID';

-- Debería mostrar:
-- pudo_type: 'brickshare'
-- pudo_id: ID del depósito seleccionado
```

### 5. Verificar en la UI

- El dashboard debería mostrar el PUDO seleccionado con:
  - Badge verde "Depósito Brickshare"
  - Nombre del establecimiento
  - Dirección completa
  - Mensaje informativo sobre el uso del PUDO

## Casos de Prueba Adicionales

### Caso 1: Cambiar de Brickshare a Correos
1. Seleccionar un depósito Brickshare
2. Seleccionar una oficina Correos (marcador azul)
3. Verificar que el registro anterior se elimina correctamente

### Caso 2: Cambiar de Correos a Brickshare
1. Seleccionar una oficina Correos
2. Seleccionar un depósito Brickshare
3. Verificar que el registro anterior se elimina correctamente

### Caso 3: Actualizar mismo tipo
1. Seleccionar un depósito Brickshare
2. Seleccionar otro depósito Brickshare diferente
3. Verificar que se actualiza correctamente (upsert)

## Errores Esperados vs Corregidos

### ❌ ANTES (Error)
```
❌ Error updating PUDO: Invalid PUDO type
```

### ✅ DESPUÉS (Correcto)
```
✅ Punto de entrega actualizado correctamente
```

## Verificación Final

- [ ] El PUDO Brickshare se guarda correctamente en `users_brickshare_dropping`
- [ ] La tabla `users` tiene `pudo_type='brickshare'` y `pudo_id` correcto
- [ ] No hay registros huérfanos en `users_correos_dropping`
- [ ] El dashboard muestra correctamente el PUDO seleccionado
- [ ] Los logs en consola muestran el flujo completo sin errores
- [ ] El toast de éxito se muestra al usuario

## Rollback (si es necesario)

Si algo falla, los cambios están en:
- `apps/web/src/pages/Dashboard.tsx`
- `apps/web/src/lib/pudoService.ts`
- `packages/shared/src/types/pudo.ts`

Puedes revertir con:
```bash
git checkout HEAD -- apps/web/src/pages/Dashboard.tsx
git checkout HEAD -- apps/web/src/lib/pudoService.ts
git checkout HEAD -- packages/shared/src/types/pudo.ts