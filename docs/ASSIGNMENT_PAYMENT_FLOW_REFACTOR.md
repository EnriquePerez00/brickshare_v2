# Refactorización: Movimiento de Lógica de Pago en Flujo de Asignación

## Problema Original

El error `400 Bad Request` en la asignación de sets a usuarios ocurría porque:

1. **Ubicación incorrecta de pago**: La lógica de pago se ejecutaba en `SetAssignment.tsx` (confirmación de asignación)
2. **Contexto incorrecto**: La Edge Function `process-assignment-payment` se invocaba sin acceso a datos de PUDO
3. **Secuencia lógica defectuosa**: Se intentaba cobrar ANTES de confirmar la asignación en base de datos
4. **Falta de información**: Al momento del pago, no se disponía de `pudo_type` consistente

## Solución Implementada

Se refactorizó el flujo para mover la lógica de pago al punto correcto del ciclo de vida:

### ANTES (Arquitectura defectuosa)
```
SetAssignment (Confirmación)
    ↓
    ├─ process-assignment-payment (❌ ERROR 400)
    │   └─ Falla: Contexto incompleto, sin pudo_type
    │
    └─ confirm_assign_sets_to_users (no se ejecuta)
```

### DESPUÉS (Arquitectura correcta)
```
SetAssignment (Confirmación)
    ↓
    └─ confirm_assign_sets_to_users (sin pago)
        ↓ Crea shipments en estado "assigned"
        ↓
LabelGeneration (Impresión de etiquetas)
    ↓
    ├─ generateCorreosLabel()
    │   ├─ processCorreosPayment() ✅ (contexto completo)
    │   ├─ Preregister en Correos
    │   └─ Get label PDF
    │
    └─ generateBrickshareLabel()
        └─ Send QR email (sin pago)
```

## Cambios Realizados

### 1. **SetAssignment.tsx** - Simplificación de confirmación
**Cambios:**
- ✂️ Eliminada lógica de `process-assignment-payment` del flujo de confirmación
- ✂️ Eliminado helper `executeCorreosPreregistration()`
- ✂️ Eliminado dialog de errores de pago (`paymentErrorDialog`)
- ✂️ Simplificados mensajes de éxito

**Antes:**
```typescript
// ANTES: Intenta cobrar aquí (❌ INCORRECTO)
const paymentResponse = await supabase.functions.invoke(
    'process-assignment-payment',
    { body: { userId, setRef, pudoType } }
);
// Luego intenta confirmar...
const { data } = await supabase.rpc("confirm_assign_sets_to_users", { p_user_ids: userIds });
```

**Después:**
```typescript
// DESPUÉS: Solo confirma asignación (✅ CORRECTO)
const { data } = await supabase.rpc("confirm_assign_sets_to_users", {
    p_user_ids: userIds,
});
toast.success(`¡Éxito! Se crearon ${data.length} asignaciones. Los pagos se procesarán al imprimir etiquetas.`);
```

### 2. **LabelGeneration.tsx** - Adición de lógica de pago
**Cambios:**
- ✅ Agregado helper `processCorreosPayment(userId, setRef)`
- ✅ Integrado en `generateCorreosLabel()` como PASO 1
- ✅ Mejora de manejo de errores para pagos

**Nuevo flujo:**
```typescript
const generateCorreosLabel = async (shipmentId: string) => {
    const shipment = pendingShipments?.find(s => s.id === shipmentId);
    
    // PASO 1: Process payment FIRST (necesario para Correos)
    await processCorreosPayment(shipment.user_id, shipment.set_ref);
    
    // PASO 2: Preregister en Correos
    const preregData = await supabase.functions.invoke('correos-logistics', {
        body: { action: 'preregister', p_shipment_id: shipmentId }
    });
    
    // PASO 3: Get label
    const labelData = await supabase.functions.invoke('correos-logistics', {
        body: { action: 'get_label', p_shipment_id: shipmentId }
    });
    
    // PASO 4: Print label
    printLabelPDF(labelData.label_url, false);
};
```

## Ventajas de Esta Arquitectura

### 1. **Separación de Responsabilidades**
- Asignación: Solo crea shipments en BD
- Pago: Ocurre cuando se genera etiqueta (cuando hay datos completos)
- Logística: Se ejecuta después de pago confirmado

### 2. **Contexto Completo en Momento de Pago**
- Al generar etiqueta, ya tenemos:
  - `user_id` desde shipment
  - `set_ref` desde shipment
  - `pudo_type` desde shipment (confirmado en BD)
  - Stripe customer ID del usuario

### 3. **Mejor UX**
- Admin confirma asignaciones rápidamente (sin esperar pagos)
- Pagos se procesan cuando se generan etiquetas (punto lógico)
- Usuarios ven shipments "assigned" antes de que se cobre

### 4. **Manejo de Errores Mejorado**
- Si pago falla: shipment queda en estado "assigned", puede reintentar
- Si Correos falla: pago ya fue procesado, registrar para auditoría
- Errores específicos para cada tipo de PUDO

## Flujo Completo de Usuario

### Para Usuario con Correos PUDO:
```
1. Admin selecciona usuario en SetAssignment
   ↓
2. Confirma asignación (sin pago)
   ↓ Shipment creado: estado "assigned"
   ↓
3. Admin va a LabelGeneration
   ↓
4. Genera etiqueta
   ├─ PAGO procesado aquí ✅
   ├─ Preregistro Correos
   └─ Label PDF descargado
   ↓ Shipment actualizado: estado "in_transit_pudo"
```

### Para Usuario con Brickshare PUDO:
```
1. Admin selecciona usuario en SetAssignment
   ↓
2. Confirma asignación (sin pago)
   ↓ Shipment creado: estado "assigned"
   ↓
3. Admin va a LabelGeneration
   ↓
4. Genera etiqueta
   ├─ SIN PAGO (regalo interno)
   ├─ QR generado o reutilizado
   └─ Email con QR enviado
   ↓ Shipment actualizado: estado "in_transit_pudo"
```

## Estados de Shipment

| Estado | Descripción | Acción Admin |
|--------|-------------|--------------|
| `assigned` | Asignado, pendiente de etiqueta | En LabelGeneration |
| `in_transit_pudo` | Etiqueta generada, en tránsito | Esperar llegada a PUDO |
| `in_reception` | Llegó a PUDO | (Operador) |
| `returned` | Devuelto por usuario | (Operador) |

## Cambios en Edge Functions

### `process-assignment-payment`
- ✅ Sigue siendo responsable de:
  - Validar Stripe customer ID
  - Crear depósito Swikly
  - Cobrar transporte a Correos
  - Capturar pago en Stripe

- ✅ Ahora se llama desde:
  - `LabelGeneration.tsx` (Correos PUDO)
  - NO desde `SetAssignment.tsx`

### `correos-logistics`
- Sin cambios en funcionalidad
- Ahora recibe shipment con datos completos ya pagados

## Testing del Flujo

### Caso de Uso: Usuario "Enrique Perez"
```bash
# 1. Generar propuesta
Admin → SetAssignment → "Genera propuesta"

# 2. Confirmar asignación (sin pago)
Admin → SetAssignment → "Confirmar asignaciones (todas)"
✅ Resultado: Shipment creado, estado "assigned"

# 3. Generar etiqueta (con pago)
Admin → LabelGeneration → Etiqueta para Enrique
✅ Resultado: Pago procesado, etiqueta generada
```

## Rollback Plan

Si algo falla en `LabelGeneration`:

```typescript
// Shipment queda en "assigned"
// Puede regenerarse etiqueta (reintentará pago)
// Si pago fue capturado: documentar en auditoría de Stripe
```

## Referencias

- **Edge Function**: `supabase/functions/process-assignment-payment/`
- **RPC Functions**: `supabase/migrations/*/` (confirm_assign_sets_to_users)
- **UI Components**:
  - `apps/web/src/components/admin/operations/SetAssignment.tsx`
  - `apps/web/src/components/admin/operations/LabelGeneration.tsx`

## Conclusión

Esta refactorización corrige la raíz del problema 400 al mover la lógica de pago a un contexto donde:
1. Todos los datos requeridos están disponibles
2. La BD ya tiene el shipment confirmado
3. El error se maneja con mejor contexto
4. La UX es más fluida para el admin