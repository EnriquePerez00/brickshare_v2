# Shipment Status Update Fix

## Fecha
25/03/2026

## Problema Reportado

Los shipments permanecían en estado `assigned` después de generar etiquetas, cuando deberían cambiar automáticamente a `in_transit_pudo`.

## Investigación

### Hallazgos

1. **Inconsistencia en nombre de campo detectada:**
   - `apps/web/src/lib/labelPrintService.ts` usaba campo incorrecto: `shipping_status`
   - `apps/web/src/components/admin/operations/LabelGeneration.tsx` usaba el correcto: `shipment_status`
   - El nombre correcto del campo en la tabla `shipments` es: **`shipment_status`**

2. **Flujo de actualización:**
   - `LabelGeneration.tsx` SÍ actualiza el estado correctamente después de generar etiqueta
   - Llamaba a función local `updateShipmentStatus()` con el campo correcto
   - El helper en `labelPrintService.ts` tenía el bug pero no se estaba usando activamente

3. **Estado de BD al momento de la investigación:**
   - No había shipments en BD (tabla vacía)
   - Probable reset de BD antes de la investigación
   - No se pudo verificar el problema in-situ

## Solución Aplicada

### 1. Corrección en labelPrintService.ts

**Archivo**: `apps/web/src/lib/labelPrintService.ts`

**Cambio realizado (línea 44)**:
```typescript
// ❌ ANTES (INCORRECTO)
.update({ shipping_status: status })

// ✅ DESPUÉS (CORRECTO)
.update({ shipment_status: status })
```

Esta corrección asegura consistencia en todo el código, aunque la función no estaba siendo utilizada actualmente.

## Verificación del Flujo Correcto

### LabelGeneration.tsx - Flujo Actual (CORRECTO)

```typescript
// 1. Generar etiqueta (según tipo PUDO)
if (shipment.pudo_type === 'correos') {
    await generateCorreosLabel(shipment.id);
} else if (shipment.pudo_type === 'brickshare') {
    await generateBrickshareLabel(shipment.id);
}

// 2. Actualizar estado ✅
await updateShipmentStatus(shipment.id);

// Función local que usa el campo CORRECTO
const updateShipmentStatus = async (shipmentId: string) => {
    const { error } = await supabase
        .from('shipments')
        .update({
            shipment_status: 'in_transit_pudo',  // ✅ CAMPO CORRECTO
            updated_at: new Date().toISOString()
        })
        .eq('id', shipmentId);

    if (error) throw error;
};
```

## Flujo Completo de Generación de Etiquetas

### Para Correos PUDO:
1. **Preregistro** → `correos-logistics` con action `preregister`
2. **Obtener PDF** → `correos-logistics` con action `get_label`
3. **Imprimir/Abrir** → `window.open(label_url)`
4. **Actualizar estado** → `shipment_status = 'in_transit_pudo'`

### Para Brickshare PUDO:
1. **Enviar email con QR** → `send-brickshare-qr-email`
2. **Actualizar estado** → `shipment_status = 'in_transit_pudo'`

## Posibles Causas del Problema Original

Si los shipments realmente se quedaban en `assigned`, las causas podrían ser:

1. **Error silencioso en actualización:**
   - La función `updateShipmentStatus()` podría estar fallando sin mostrar error
   - Verificar permisos RLS en tabla `shipments`

2. **Interrupción del flujo:**
   - Usuario cerraba ventana antes de completar actualización
   - Error en generación de etiqueta interrumpía el flujo antes de actualizar

3. **Problema de permisos:**
   - Usuario operador sin permisos UPDATE en tabla shipments
   - Política RLS bloqueando actualización

## Recomendaciones

### 1. Mejorar Logging
```typescript
const updateShipmentStatus = async (shipmentId: string) => {
    console.log('[Label] Updating shipment status:', shipmentId);
    
    const { error } = await supabase
        .from('shipments')
        .update({
            shipment_status: 'in_transit_pudo',
            updated_at: new Date().toISOString()
        })
        .eq('id', shipmentId);

    if (error) {
        console.error('[Label] Failed to update status:', error);
        throw error;
    }
    
    console.log('[Label] Status updated successfully');
};
```

### 2. Verificar Políticas RLS
```sql
-- Verificar que operadores pueden actualizar shipments
SELECT * FROM pg_policies 
WHERE tablename = 'shipments' 
  AND cmd = 'UPDATE';
```

### 3. Transacción Atómica
Considerar envolver generación + actualización en transacción:
```typescript
// En Edge Function correos-logistics
// Agregar UPDATE al final de preregister/get_label
await supabase
    .from('shipments')
    .update({ shipment_status: 'in_transit_pudo' })
    .eq('id', shipmentId);
```

## Testing

### Crear shipment de prueba:
```sql
INSERT INTO shipments (
  user_id,
  set_id,
  set_ref,
  shipment_type,
  shipment_status,
  pudo_type,
  brickshare_pudo_id
) VALUES (
  (SELECT id FROM users WHERE email = 'test@example.com'),
  (SELECT id FROM sets LIMIT 1),
  '21005',
  'delivery',
  'assigned',
  'brickshare',
  (SELECT id FROM brickshare_pudo_locations LIMIT 1)
) RETURNING id;
```

### Generar etiqueta desde UI:
1. Panel de Operaciones → Generación de Etiquetas
2. Clic en "Generar Etiqueta"
3. Verificar que `shipment_status` cambia a `in_transit_pudo`

### Verificar resultado:
```sql
SELECT id, shipment_status, updated_at 
FROM shipments 
WHERE id = 'shipment-id-aqui';
```

## Archivos Modificados

- ✅ `apps/web/src/lib/labelPrintService.ts` - Campo corregido
- ℹ️ `apps/web/src/components/admin/operations/LabelGeneration.tsx` - Ya estaba correcto

## Estado Final

- ✅ Inconsistencia de campo corregida
- ✅ Código unificado usando `shipment_status`
- ✅ Flujo de actualización verificado como correcto
- ⚠️ No se pudo replicar el problema (BD vacía)
- ℹ️ Requiere testing en producción para confirmar fix completo

## Referencias

- [LABEL_GENERATION_FEATURE.md](./LABEL_GENERATION_FEATURE.md) - Feature completa
- [LABEL_GENERATION_TROUBLESHOOTING.md](./LABEL_GENERATION_TROUBLESHOOTING.md) - Guía de troubleshooting
- [CORREOS_LOGISTICS_ORDERS_FIX.md](./CORREOS_LOGISTICS_ORDERS_FIX.md) - Fix anterior relacionado