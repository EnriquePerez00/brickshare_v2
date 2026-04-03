# Sistema Triple de Códigos QR - Brickshare

> ⚠️ **DOCUMENTO ACTUALIZADO**: 2026-03-04
> 
> Este documento reemplaza el sistema dual anterior (BS-DEL / BS-REC) con el sistema triple correcto (BS-DEL / BS-PCK / BS-RET).

## Resumen

Cuando se gestiona un envío en Brickshare, el sistema utiliza **3 códigos QR diferentes** con propósitos específicos:

1. **QR de Etiqueta (Delivery QR - BS-DEL)** - Para el PUDO al recibir el paquete
2. **QR de Recogida (Pickup QR - BS-PCK)** - Para el cliente al recoger
3. **QR de Devolución (Return QR - BS-RET)** - Para el cliente al devolver

---

## 1. QR de Etiqueta (Delivery QR)

### Propósito
Este QR se **imprime en la etiqueta física** que acompaña al paquete. El personal del PUDO lo escanea cuando el paquete llega para registrarlo en su inventario.

### Formato
```
BS-DEL-<SHIPMENT_ID_12_CHARS>
```

### Ejemplo
```
BS-DEL-4BCD6EB3-C99
```

### Uso
- 🏷️ Se imprime en la etiqueta física del paquete (10x5cm)
- 📦 Viaja junto al paquete hasta el PUDO
- 🔍 El personal lo escanea al **recibir** el paquete
- ✅ Confirma que el paquete llegó al PUDO correcto

### Ubicación en BD
```sql
shipments.delivery_qr_code
```

---

## 2. QR de Recogida (Pickup QR)

### Propósito
Este QR es el que **recibe el cliente por email** y debe presentar en el PUDO para recoger su set LEGO.

### Formato
```
BS-PCK-<SHIPMENT_ID_12_CHARS>
```

### Ejemplo
```
BS-PCK-4BCD6EB3-C99
```

### Uso
- ✉️ Se envía al email del usuario
- 📱 El usuario lo muestra en su móvil o impreso
- 🏪 El cliente lo presenta al personal del PUDO
- ✅ El personal lo escanea para validar la entrega

### Ubicación en BD
```sql
shipments.pickup_qr_code
```

---

## 3. QR de Devolución (Return QR)

### Propósito
Este QR se genera cuando el usuario solicita devolver el set. Lo presenta en el PUDO para completar la devolución.

### Formato
```
BS-RET-<SHIPMENT_ID_12_CHARS>
```

### Ejemplo
```
BS-RET-4BCD6EB3-C99
```

### Uso
- ✉️ Se envía por email cuando el usuario solicita devolución
- 📱 El usuario lo presenta en el PUDO
- 📦 El personal lo escanea al recibir el set de vuelta
- ✅ Confirma la devolución del set

### Ubicación en BD
```sql
shipments.return_qr_code
```

---

## Flujo Completo

```
┌─────────────────────────────────────────────────────────────┐
│ 1. ADMIN GENERA ETIQUETA Y ENVÍO                            │
│    ↓                                                          │
│    Edge Function: send-brickshare-qr-email                   │
│    ├─→ Genera QR Etiqueta: BS-DEL-4BCD6EB3-C99             │
│    │   • Se guarda en shipments.delivery_qr_code            │
│    │   • Se imprime en etiqueta física                      │
│    │                                                          │
│    └─→ Genera QR Recogida: BS-PCK-4BCD6EB3-C99             │
│        • Se guarda en shipments.pickup_qr_code              │
│        • Se envía al email del usuario                       │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ 2. PAQUETE LLEGA AL PUDO                                     │
│    ↓                                                          │
│    Personal escanea QR Etiqueta (BS-DEL)                    │
│    BS-DEL-4BCD6EB3-C99                                       │
│    ↓                                                          │
│    ✅ Sistema registra llegada al PUDO                       │
│    ✅ Paquete en inventario PUDO, listo para entregar       │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ 3. CLIENTE RECOGE EL SET                                     │
│    ↓                                                          │
│    Cliente muestra QR Recogida (BS-PCK) en su móvil         │
│    BS-PCK-4BCD6EB3-C99                                       │
│    ↓                                                          │
│    Personal escanea el QR del cliente                        │
│    ↓                                                          │
│    ✅ Sistema valida identidad del cliente                   │
│    ✅ Personal entrega el set LEGO                           │
│    ✅ Estado del envío cambia a 'delivered'                  │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ 4. CLIENTE SOLICITA DEVOLUCIÓN                               │
│    ↓                                                          │
│    Edge Function: request-return                             │
│    └─→ Genera QR Devolución: BS-RET-4BCD6EB3-C99           │
│        • Se guarda en shipments.return_qr_code              │
│        • Se envía al email del usuario                       │
│    ↓                                                          │
│    Cliente va al PUDO con el set y el QR                    │
│    Personal escanea BS-RET-4BCD6EB3-C99                     │
│    ↓                                                          │
│    ✅ Sistema registra devolución                            │
│    ✅ Estado cambia a 'returned'                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Implementación Técnica

### Edge Function: `send-brickshare-qr-email/index.ts`

```typescript
// Generar QR de Etiqueta (se guarda en BD e imprime)
deliveryQR = generateQRCode(shipment_id, 'DEL'); 
// Resultado: BS-DEL-4BCD6EB3-C99

// Generar QR de Recogida (se guarda en BD y envía por email)
pickupQR = generateQRCode(shipment_id, 'PCK');
// Resultado: BS-PCK-4BCD6EB3-C99

// Actualizar BD
await supabaseClient
  .from('shipments')
  .update({ 
    delivery_qr_code: deliveryQR,
    pickup_qr_code: pickupQR
  })
  .eq('id', shipment_id);
```

### Edge Function: `request-return/index.ts`

```typescript
// Generar QR de Devolución (se guarda en BD y envía por email)
returnQR = generateQRCode(shipment_id, 'RET');
// Resultado: BS-RET-4BCD6EB3-C99

// Actualizar BD
await supabaseClient
  .from('shipments')
  .update({ return_qr_code: returnQR })
  .eq('id', shipment_id);
```

### Función Auxiliar

```typescript
// Genera QR basado en shipment_id (determinístico)
function generateQRCode(shipmentId: string, prefix: 'DEL' | 'PCK' | 'RET'): string {
  const shipmentIdShort = shipmentId.substring(0, 12).toUpperCase();
  return `BS-${prefix}-${shipmentIdShort}`;
}
```

---

## Diferencias Clave

| Característica | QR Etiqueta (DEL) | QR Recogida (PCK) | QR Devolución (RET) |
|---|---|---|---|
| **Prefijo** | `BS-DEL-` | `BS-PCK-` | `BS-RET-` |
| **Generación** | Del shipment_id | Del shipment_id | Del shipment_id |
| **Almacenamiento** | ✅ `delivery_qr_code` | ✅ `pickup_qr_code` | ✅ `return_qr_code` |
| **Dónde se muestra** | 🏷️ Etiqueta física | ✉️ Email usuario | ✉️ Email usuario |
| **Uso** | PUDO valida recepción | Cliente recoge set | Cliente devuelve set |
| **Cuándo se genera** | Al crear envío | Al crear envío | Al solicitar devolución |
| **Quién lo escanea** | Personal PUDO | Personal PUDO | Personal PUDO |

---

## Beneficios del Sistema Triple

### ✅ Seguridad
- Tres puntos de validación independientes
- Cada QR tiene un propósito único y específico
- No se puede confundir una etiqueta con un email de usuario

### ✅ Trazabilidad
- **QR Etiqueta (BS-DEL)**: Confirma llegada del paquete al PUDO
- **QR Recogida (BS-PCK)**: Confirma entrega al cliente correcto
- **QR Devolución (BS-RET)**: Confirma devolución del set

### ✅ Claridad Operativa
- Personal PUDO sabe exactamente qué acción realizar según el prefijo
- `BS-DEL` → Registrar entrada en inventario
- `BS-PCK` → Entregar al cliente
- `BS-RET` → Recibir devolución del cliente

### ✅ Auditabilidad
- Logs separados para cada tipo de operación
- Historial completo del ciclo de vida del envío

---

## Ejemplo Real

```
📦 Shipment ID: 4bcd6eb3-c99c-4456-8a7a-57901f5a3a69

┌──────────────────────────────────────────┐
│ QR ETIQUETA (Impresa en paquete)         │
├──────────────────────────────────────────┤
│  BS-DEL-4BCD6EB3-C99                    │
│                                          │
│  Para: Enrique Perez                    │
│  PUDO: Brickshare Madrid Centro         │
│  Dirección: Calle Gran Vía 1, 28013     │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ QR RECOGIDA (Email al cliente)           │
├──────────────────────────────────────────┤
│  BS-PCK-4BCD6EB3-C99                    │
│                                          │
│  Cliente: Enrique Perez                 │
│  Email: enriqueperezbcn1973@gmail.com   │
│  Set: LEGO 21004                        │
│  Instrucciones: Presenta este QR        │
│                 en el PUDO para recoger  │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ QR DEVOLUCIÓN (Email al cliente)         │
├──────────────────────────────────────────┤
│  BS-RET-4BCD6EB3-C99                    │
│                                          │
│  Cliente: Enrique Perez                 │
│  Set: LEGO 21004                        │
│  Instrucciones: Presenta este QR        │
│                 junto con el set         │
└──────────────────────────────────────────┘
```

---

## API de Validación

Cada QR se valida a través de endpoints específicos en `brickshare-qr-api`:

```
POST /brickshare-qr-api/validate-delivery
{
  "qr_code": "BS-DEL-4BCD6EB3-C99"
}
→ Registra llegada del paquete al PUDO

POST /brickshare-qr-api/validate-pickup
{
  "qr_code": "BS-PCK-4BCD6EB3-C99"
}
→ Registra entrega al cliente

POST /brickshare-qr-api/validate-return
{
  "qr_code": "BS-RET-4BCD6EB3-C99"
}
→ Registra devolución del set
```

---

## ❌ Códigos Deprecados

### BS-REC- (Reception QR)

**ELIMINADO** en la refactorización del 2026-03-04.

#### Razón de eliminación
El código `BS-REC-` era redundante y causaba confusión:
- Se generaba como código aleatorio temporal
- No se almacenaba en BD
- Su función (validar recepción en PUDO) ahora la cumple `BS-DEL-`

#### Migración
- **Antes**: Etiqueta mostraba `BS-REC-xxx` (aleatorio)
- **Ahora**: Etiqueta muestra `BS-DEL-xxx` (del shipment_id)

**⚠️ IMPORTANTE**: No usar `BS-REC-` en ningún código nuevo. Todas las etiquetas deben usar `BS-DEL-`.

---

## Historial de Cambios

### 2026-03-04 - Refactorización Completa
- ❌ Eliminado `BS-REC-` (recepción)
- ✅ Clarificado `BS-DEL-` para etiqueta física
- ✅ Añadido `BS-PCK-` para email de recogida del usuario
- ✅ Mantenido `BS-RET-` para devoluciones
- ✅ Actualizada toda la documentación

### 2026-04-03 - Sistema Dual (OBSOLETO)
- Sistema anterior con `BS-DEL-` y `BS-REC-`
- `BS-REC-` era aleatorio y temporal
- **DEPRECADO** - Ver especificación actual arriba

---

## Referencias

- [✅ QR Codes Specification (ACTUAL)](./QR_CODES_SPECIFICATION.md) ← **Documento principal**
- [Brickshare PUDO QR Flow](./BRICKSHARE_PUDO_QR_FLOW.md)
- [Pickup QR Code Implementation](./PICKUP_QR_CODE_IMPLEMENTATION.md)
- [Edge Function: send-brickshare-qr-email](../supabase/functions/send-brickshare-qr-email/index.ts)
- [Edge Function: request-return](../supabase/functions/request-return/index.ts)