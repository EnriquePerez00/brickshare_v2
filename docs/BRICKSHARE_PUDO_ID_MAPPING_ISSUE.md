# Análisis: Error en Mapeo de IDs de Depósitos Brickshare

**Fecha**: 26/03/2026  
**Issue**: Usuario Enrique Perez con error 400 al asignar sets  
**Root Cause**: Mapeo incorrecto de ID en PudoSelector

---

## 🔍 Diagnóstico

### Síntoma Original
```
Error: Edge Function returned a non-2xx status code
POST http://localhost:54321/functions/v1/process-assignment-payment 400 (Bad Request)
```

### Usuario Afectado
- **Nombre**: Enrique Perez
- **Stripe Customer ID**: `cus_UDa9p5PiEOhPvu`
- **User ID**: `368aab57-f618-481a-bdca-ca63f5a7c16e`
- **Estado actual en BD**:
  ```sql
  pudo_type: 'brickshare'
  pudo_id: '9ae13c49-de91-462b-ba63-32c8e7a546a5'  -- ❌ UUID incorrecto
  ```

---

## 🐛 Causa Raíz

### 1. Respuesta de la API `/api/locations-local`

La API devuelve **DOS campos de identificación**:

```json
{
  "id": "9ae13c49-de91-462b-ba63-32c8e7a546a5",  // UUID (Primary Key en tabla brickshare_pudo_locations)
  "pudo_id": "brickshare-001",                    // ID del sistema remoto (formato correcto)
  "code": "31814",
  "name": "paco pil",
  "location_name": "Establecimiento de paco",
  "address": "avenida josep tarradellas 64",
  "postal_code": "08029",
  "city": "barcelona",
  "is_active": true
}
```

### 2. Mapeo Incorrecto en PudoSelector.tsx

**Archivo**: `apps/web/src/components/PudoSelector.tsx`  
**Línea**: ~250

```typescript
// ❌ INCORRECTO - Usa el UUID de la tabla
const point: PUDOPoint = {
    id_correos_pudo: dep.id,  // Mapea UUID en lugar de pudo_id
    nombre: dep.location_name || dep.name,
    direccion: dep.address,
    cp: dep.postal_code,
    ciudad: dep.city,
    lat: location.lat(),
    lng: location.lng(),
    horario: "Horario comercial del establecimiento",
    tipo_punto: "Deposito"
};
```

**Debería ser**:
```typescript
// ✅ CORRECTO - Usa el ID del sistema remoto
const point: PUDOPoint = {
    id_correos_pudo: dep.pudo_id || dep.id,  // Prioriza pudo_id
    // ... resto igual
};
```

### 3. Flujo de Transformación

```
API /api/locations-local
  ↓
  {
    id: "9ae13c49-...",           // UUID (PK tabla)
    pudo_id: "brickshare-001"     // ID sistema remoto
  }
  ↓
PudoSelector.tsx (línea ~250)
  ↓
  id_correos_pudo: dep.id  ❌ Mapea UUID
  ↓
pudoService.ts → transformPUDOPointToBricksharePudo()
  ↓
  brickshare_pudo_id: pudoPoint.id_correos_pudo  // Recibe UUID
  ↓
BD users.pudo_id = "9ae13c49-..." ❌
BD users_brickshare_dropping.brickshare_pudo_id = "9ae13c49-..." ❌
```

---

## ✅ Solución

### Opción 1: Fix Mínimo (Recomendado)

Cambiar una línea en `PudoSelector.tsx`:

```typescript
// Línea ~250
id_correos_pudo: dep.pudo_id || dep.id,  // Prioriza pudo_id, fallback a id
```

**Pros**:
- Cambio mínimo (1 línea)
- Backwards compatible
- Resuelve el problema inmediatamente

**Cons**:
- No valida que el formato sea correcto

### Opción 2: Fix con Validación (Más robusto)

1. **Cambio en PudoSelector.tsx**:
```typescript
// Validar que tengamos pudo_id con formato correcto
const brickshareId = dep.pudo_id;
if (!brickshareId || !/^brickshare-\d{3,}$/i.test(brickshareId)) {
    console.error('❌ Invalid Brickshare pudo_id format:', dep);
    return null; // Skip this deposit
}

const point: PUDOPoint = {
    id_correos_pudo: brickshareId,
    // ... resto
};
```

2. **Validación adicional en pudoService.ts**:
```typescript
export function transformPUDOPointToBricksharePudo(pudoPoint: PUDOPoint): Partial<BricksharePudoPoint> {
    const isUUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(pudoPoint.id_correos_pudo);
    const isBrickshareFormat = /^brickshare-\d{3,}$/i.test(pudoPoint.id_correos_pudo);
    
    if (isUUID) {
        throw new Error('ID de depósito inválido: se recibió UUID en lugar de formato brickshare-XXX');
    }
    
    if (!isBrickshareFormat) {
        throw new Error(`ID de depósito inválido: ${pudoPoint.id_correos_pudo}. Debe ser formato brickshare-XXX`);
    }
    
    // ... resto de la función
}
```

**Pros**:
- Previene futuros errores
- Validación explícita
- Mensajes de error claros

**Cons**:
- Más código
- Requiere testing adicional

---

## 🔧 Migración de Datos Existentes

Para corregir usuarios que ya tienen UUIDs guardados:

```sql
-- Fix para usuario Enrique Perez (caso inmediato)
UPDATE public.users
SET pudo_id = 'brickshare-001'
WHERE user_id = '368aab57-f618-481a-bdca-ca63f5a7c16e';

UPDATE public.users_brickshare_dropping
SET brickshare_pudo_id = 'brickshare-001'
WHERE user_id = '368aab57-f618-481a-bdca-ca63f5a7c16e';

-- Fix para todos los usuarios con UUID en pudo_id (preventivo)
UPDATE public.users
SET pudo_id = 'brickshare-001'
WHERE pudo_type = 'brickshare'
  AND pudo_id ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$';

UPDATE public.users_brickshare_dropping
SET brickshare_pudo_id = 'brickshare-001'
WHERE brickshare_pudo_id ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$';
```

---

## 📊 Verificación

### Script de verificación de usuarios afectados:

```sql
-- Usuarios con UUID en lugar de brickshare-XXX
SELECT 
    u.user_id,
    u.full_name,
    u.email,
    u.pudo_type,
    u.pudo_id,
    ubd.brickshare_pudo_id,
    CASE 
        WHEN u.pudo_id ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' 
        THEN '❌ UUID (incorrecto)'
        WHEN u.pudo_id ~ '^brickshare-\d{3,}$' 
        THEN '✅ Formato correcto'
        ELSE '⚠️ Otro formato'
    END as pudo_id_status
FROM users u
LEFT JOIN users_brickshare_dropping ubd ON ubd.user_id = u.user_id
WHERE u.pudo_type = 'brickshare';
```

---

## 🎯 Recomendación Final

**Implementar Opción 1 (fix mínimo) + Migración SQL inmediatamente**:

1. ✅ Cambiar `dep.id` → `dep.pudo_id || dep.id` en PudoSelector.tsx
2. ✅ Ejecutar migración SQL para corregir usuarios existentes
3. ✅ Verificar que Enrique puede asignar sets correctamente
4. ⏱️ (Opcional) Implementar validación adicional en sprint futuro

**Tiempo estimado**: 15 minutos  
**Impacto**: Alto (bloquea asignaciones a usuarios con Brickshare PUDO)  
**Riesgo**: Bajo (cambio simple y bien localizado)

---

## 📚 Referencias

- Tabla BD: `brickshare_pudo_locations` (contiene AMBOS campos: `id` UUID + `pudo_id` texto)
- Migración: `20260326120000_fix_brickshare_pudo_ids.sql` (intento previo de fix)
- Componente: `apps/web/src/components/PudoSelector.tsx`
- Servicio: `apps/web/src/lib/pudoService.ts`
- API Endpoint: Vite proxy `/api/locations-local` → Backend remoto