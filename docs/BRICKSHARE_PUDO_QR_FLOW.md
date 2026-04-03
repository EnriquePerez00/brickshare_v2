# Brickshare PUDO QR Code Flow

## Overview

Este documento explica el flujo completo de códigos QR en el sistema de recogida Brickshare PUDO, diferenciando entre:
- **delivery_qr_code**: Código QR para recepción del paquete (empresa logística)
- **pickup_qr_code**: Código QR para recogida del set (usuario)

---

## Flujo Completo: Paso a Paso

### 1️⃣ Admin Genera Etiqueta

**Cuándo:** El admin hace clic en "Generar Etiqueta" para un shipment en el backoffice

**Qué pasa:**
```
a) Se crea delivery_qr_code (si no existe)
   └─ Formato: BS-DEL-{primeros 12 chars del shipment_id en mayúsculas}
   └─ Ejemplo: BS-DEL-54A82B94-2F1

b) Se copia el valor a pickup_qr_code (mismo código)
   └─ pickup_qr_code = delivery_qr_code
   └─ Ambos tienen el mismo valor pero se usan en momentos diferentes

c) Se genera etiqueta física PUDO
   └─ Imprime el delivery_qr_code en código de barras/QR
   └─ Se coloca en el paquete

d) Se envía email al usuario
   └─ Incluye el pickup_qr_code (mismo valor)
   └─ Usuario lo presenta en el PUDO para recoger
```

**Base de datos después de este paso:**
```sql
UPDATE shipments SET
  delivery_qr_code = 'BS-DEL-54A82B94-2F1',
  pickup_qr_code = 'BS-DEL-54A82B94-2F1',
  swikly_status = 'accepted',
  shipment_status = 'in_transit_pudo'
```

---

### 2️⃣ Empresa Logística Entrega en Punto PUDO

**Cuándo:** La empresa logística lleva el paquete al punto PUDO Brickshare

**Qué pasa:**
```
- Personal del PUDO abre app/sistema de validación QR
- Escanea el delivery_qr_code (impreso en la etiqueta física)
- Sistema busca en tabla shipments WHERE delivery_qr_code = '{qr escaneado}'
- ENCUENTRA → Valida recepción
```

**Validación en BD:**
```sql
SELECT * FROM shipments 
WHERE delivery_qr_code = 'BS-DEL-54A82B94-2F1'
-- Retorna: el registro del shipment

-- Entonces marca:
UPDATE shipments SET
  delivery_validated_at = now(),
  pickup_validated_at = NULL  -- Aún no recogido
```

---

### 3️⃣ Usuario Recoge su Set en Punto PUDO

**Cuándo:** El usuario se presenta en el PUDO con su código

**Qué pasa:**
```
- Usuario presenta su código QR (enviado por email)
- Código que presenta es: pickup_qr_code
- Personal del PUDO escanea el código

- Sistema busca en tabla shipments:
  a) WHERE delivery_qr_code = '{qr escaneado}' ❌ (no encuentra)
  b) WHERE pickup_qr_code = '{qr escaneado}' ✅ (encuentra)
  
- VALIDA RECOGIDA
```

**Validación en BD:**
```sql
SELECT * FROM shipments 
WHERE pickup_qr_code = 'BS-DEL-54A82B94-2F1'
-- Retorna: el registro del shipment

-- Entonces marca:
UPDATE shipments SET
  pickup_validated_at = now(),
  shipment_status = 'delivered_user'  -- Usuario ha recogido su set
```

---

## Estados del Shipment en el Flujo

| Estado | Significado | delivery_validated_at | pickup_validated_at |
|--------|------------|----------------------|-------------------|
| `assigned` | Asignado, listo para generar etiqueta | NULL | NULL |
| `in_transit_pudo` | Etiqueta generada, esperando entrega en PUDO | NULL | NULL |
| `at_pudo` | Recibido en PUDO (delivery validado) | ✅ timestamp | NULL |
| `delivered_user` | Usuario recogió su set | ✅ timestamp | ✅ timestamp |
| `returned` | Set devuelto por usuario | ✅ timestamp | ✅ timestamp |

---

## Campos en Tabla `shipments`

### Campos Relacionados con QR

| Campo | Tipo | Descripción | Cuándo se llena |
|-------|------|-------------|-----------------|
| `delivery_qr_code` | TEXT UNIQUE | QR código para recepción del paquete por empresa logística. Se imprime en etiqueta física | Cuando admin genera etiqueta |
| `delivery_validated_at` | TIMESTAMPTZ | Timestamp cuando personal PUDO escanea delivery_qr_code | Cuando empresa entrega en PUDO |
| `pickup_qr_code` | TEXT UNIQUE | QR código para recogida del set por usuario. Se envía por email | Cuando admin genera etiqueta (copia de delivery_qr_code) |
| `pickup_validated_at` | TIMESTAMPTZ | Timestamp cuando personal PUDO escanea pickup_qr_code | Cuando usuario recoge su set |

---

## Lógica de Validación en APP PUDO (pseudocódigo)

```typescript
async function validateQRCode(scannedQR: string) {
  // Buscar el shipment por el QR escaneado
  const shipment = await findShipment(scannedQR);
  
  if (!shipment) {
    return { error: 'QR no encontrado' };
  }
  
  // ¿Es un delivery_qr_code?
  if (shipment.delivery_qr_code === scannedQR) {
    if (shipment.delivery_validated_at) {
      return { error: 'Este paquete ya fue recibido' };
    }
    
    // VALIDAR RECEPCIÓN
    await updateShipment(shipment.id, {
      delivery_validated_at: now(),
      pickup_validated_at: null // Aún no recogido
    });
    
    return {
      success: true,
      type: 'delivery',
      message: `Paquete recibido: ${shipment.sets.set_name}`,
      user: shipment.users.full_name
    };
  }
  
  // ¿Es un pickup_qr_code?
  else if (shipment.pickup_qr_code === scannedQR) {
    if (shipment.pickup_validated_at) {
      return { error: 'Este set ya fue recogido' };
    }
    
    if (!shipment.delivery_validated_at) {
      return { error: 'El paquete no ha llegado aún' };
    }
    
    // VALIDAR RECOGIDA
    await updateShipment(shipment.id, {
      pickup_validated_at: now(),
      shipment_status: 'delivered_user'
    });
    
    return {
      success: true,
      type: 'pickup',
      message: `Set recogido: ${shipment.sets.set_name}`,
      user: shipment.users.full_name
    };
  }
}
```

---

## Diagrama del Flujo

```
┌─────────────────────────────────────────────────────────────────────┐
│ 1. ADMIN GENERA ETIQUETA                                            │
│    - Crea delivery_qr_code (BS-DEL-54A82B94-2F1)                   │
│    - Copia a pickup_qr_code (mismo valor)                          │
│    - Imprime etiqueta con delivery_qr_code                         │
│    - Envía email al usuario con pickup_qr_code                     │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
        ┌──────────────────────┴──────────────────────┐
        │                                             │
        ▼                                             ▼
┌─────────────────────────┐              ┌────────────────────────┐
│ 2. EMPRESA LOGÍSTICA    │              │ 📧 EMAIL AL USUARIO    │
│ ESCANEA delivery_qr_code│              │                        │
│                         │              │ Asunto: Tu código QR   │
│ ✅ delivery_validated_at│              │ Código: BS-DEL-54A...  │
│    = now()              │              │ (es pickup_qr_code)    │
└────────────┬────────────┘              └────────────┬───────────┘
             │                                        │
             │         Paquete en PUDO               │
             │         ─────────────────             │
             │                                        │
             │         ┌────────────────────────┐    │
             │         │ PUNTO PUDO BRICKSHARE  │    │
             │         │ (en espera de usuario) │    │
             └─────────┤                        │◀───┘
                       │                        │
                       └────────────┬───────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │ 3. USUARIO VA AL PUDO        │
                    │    PRESENTA pickup_qr_code   │
                    │    (recibido por email)      │
                    │                              │
                    │ ✅ pickup_validated_at       │
                    │    = now()                   │
                    │ Status: delivered_user       │
                    └───────────────────────────────┘
```

---

## Casos de Error

### Error 1: Mismo QR escaneado dos veces

**Escenario:** Personal escanea delivery_qr_code dos veces

```sql
-- Primer escaneo (OK)
UPDATE shipments SET delivery_validated_at = now() WHERE id = 'xxx'

-- Segundo escaneo (VALIDACIÓN FALLA)
SELECT * FROM shipments WHERE delivery_qr_code = 'BS-DEL-54A82B94-2F1'
→ IF delivery_validated_at IS NOT NULL THEN error: 'Ya escaneado'
```

### Error 2: Usuario intenta recoger antes de que llegue paquete

**Escenario:** Usuario escanea pickup_qr_code pero delivery aún no validado

```sql
SELECT * FROM shipments WHERE pickup_qr_code = 'BS-DEL-54A82B94-2F1'
→ IF delivery_validated_at IS NULL THEN error: 'Paquete aún no llegó'
```

### Error 3: QR código no existe

```sql
SELECT * FROM shipments WHERE delivery_qr_code = 'INVALID-CODE' OR pickup_qr_code = 'INVALID-CODE'
→ IF NOT FOUND THEN error: 'QR no encontrado en sistema'
```

---

## Índices para Rendimiento

```sql
-- Para búsquedas rápidas
CREATE INDEX idx_shipments_delivery_qr ON shipments(delivery_qr_code) WHERE delivery_qr_code IS NOT NULL;
CREATE INDEX idx_shipments_pickup_qr ON shipments(pickup_qr_code) WHERE pickup_qr_code IS NOT NULL;

-- Para tracking de validaciones
CREATE INDEX idx_shipments_delivery_validated ON shipments(delivery_validated_at) WHERE delivery_validated_at IS NOT NULL;
CREATE INDEX idx_shipments_pickup_validated ON shipments(pickup_validated_at) WHERE pickup_validated_at IS NOT NULL;
```

---

## Resumen de Cambios (Migración 20260331000000)

```sql
-- Nuevos campos añadidos a tabla shipments
ALTER TABLE shipments
ADD COLUMN IF NOT EXISTS pickup_qr_code TEXT UNIQUE,
ADD COLUMN IF NOT EXISTS pickup_validated_at TIMESTAMPTZ;

-- pickup_qr_code: El código que el usuario presenta para recoger
-- pickup_validated_at: Timestamp cuando se valida la recogida en el PUDO
```

---

## Integración con Edge Functions

### Function: `brickshare-qr-api` (Validación)

Esta función debe actualizar tanto `delivery_validated_at` como `pickup_validated_at` según corresponda:

```typescript
// Pseudocódigo
async function validateBrickshareQR(qrCode: string) {
  const shipment = await db.from('shipments')
    .select('*')
    .or(`delivery_qr_code.eq.${qrCode}, pickup_qr_code.eq.${qrCode}`)
    .single();
    
  if (shipment.delivery_qr_code === qrCode) {
    // Es una validación de RECEPCIÓN
    await updateDeliveryValidation(shipment.id);
  } else if (shipment.pickup_qr_code === qrCode) {
    // Es una validación de RECOGIDA
    await updatePickupValidation(shipment.id);
  }
}
```

---

## Testing

Para verificar el flujo en desarrollo:

```bash
# 1. Generar etiqueta (crea ambos QR codes)
npm run test -- label-generation.test.ts

# 2. Simular escaneo delivery_qr_code
curl -X POST /api/brickshare-qr \
  -d '{"qr_code": "BS-DEL-54A82B94-2F1", "type": "delivery"}'

# 3. Simular escaneo pickup_qr_code
curl -X POST /api/brickshare-qr \
  -d '{"qr_code": "BS-DEL-54A82B94-2F1", "type": "pickup"}'