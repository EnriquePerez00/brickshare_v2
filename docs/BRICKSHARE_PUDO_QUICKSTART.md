# Brickshare PUDO QR System - Guía Rápida

## Resumen

Sistema de códigos QR para validar entregas y devoluciones en puntos Brickshare (PUDO).

## 🚀 Inicio Rápido

### 1. Aplicar Migraciones

```bash
# Aplicar migración de base de datos
supabase db reset
```

### 2. Desplegar Edge Functions

```bash
# Desplegar API de validación QR
supabase functions deploy brickshare-qr-api

# Desplegar servicio de envío de emails
supabase functions deploy send-brickshare-qr-email
```

### 3. Configurar Variables de Entorno

```bash
# En Supabase Dashboard > Project Settings > Edge Functions
RESEND_API_KEY=tu_api_key_de_resend
```

## 📱 Uso Básico

### Frontend - Seleccionar Punto Brickshare

```typescript
import { useBrickshareShipments } from '@/hooks/useBrickshareShipments';

const { pudoLocations, updateToBricksharePudo, generateDeliveryQR } = useBrickshareShipments();

// Usuario selecciona punto PUDO
await updateToBricksharePudo.mutateAsync({
  shipmentId: 'uuid-envio',
  pudoId: 'BS-PUDO-001'
});

// Generar y enviar QR por email
await generateDeliveryQR.mutateAsync('uuid-envio');
```

### App Móvil - Validar QR de Entrega

```typescript
// 1. Validar QR
const response = await fetch(
  `${API_URL}/validate/${qrCode}`
);
const { success, data } = await response.json();

if (success) {
  // 2. Mostrar info del set
  console.log('Set:', data.shipment_info.set_name);
  
  // 3. Confirmar entrega
  await fetch(`${API_URL}/confirm`, {
    method: 'POST',
    body: JSON.stringify({
      qr_code: qrCode,
      validated_by: 'BS-PUDO-001'
    })
  });
}
```

### Frontend - Solicitar Devolución

```typescript
const { generateReturnQR } = useBrickshareShipments();

// Generar y enviar QR de devolución por email
await generateReturnQR.mutateAsync('uuid-envio');
```

### App Móvil - Validar QR de Devolución

```typescript
// 1. Validar QR de devolución
const response = await fetch(
  `${API_URL}/validate/${returnQrCode}`
);

// 2. Confirmar devolución
if (validation_type === 'return') {
  await fetch(`${API_URL}/confirm`, {
    method: 'POST',
    body: JSON.stringify({
      qr_code: returnQrCode,
      validated_by: 'BS-PUDO-001'
    })
  });
}
```

## 🔑 Endpoints Principales

| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/validate/{qr}` | GET | Validar código QR |
| `/confirm` | POST | Confirmar validación |
| `/pudo-locations` | GET | Listar puntos PUDO |
| `/shipment/{id}` | GET | Info del envío (auth) |

## 📊 Estados del Envío

```
pending → ready_for_pickup → in_transit → delivered → returned
```

## 🛠️ Funciones SQL

```sql
-- Generar QR de entrega
SELECT * FROM generate_delivery_qr('uuid-envio');

-- Generar QR de devolución
SELECT * FROM generate_return_qr('uuid-envio');

-- Validar QR
SELECT * FROM validate_qr_code('BS-ABC123XYZ456');

-- Confirmar validación
SELECT * FROM confirm_qr_validation('BS-ABC123XYZ456', 'BS-PUDO-001');
```

## 📧 Emails Automáticos

- **Entrega**: Se envía al generar `delivery_qr_code`
- **Devolución**: Se envía al generar `return_qr_code`

Los emails incluyen:
- Código QR grande y visible
- Información del punto PUDO
- Instrucciones de uso
- Fecha de expiración (30 días)

## 🔒 Seguridad

### Datos NO Expuestos en API Pública
- ❌ Datos personales del usuario
- ❌ Email, teléfono, dirección
- ❌ Información de pago

### Datos Expuestos
- ✅ Información del set LEGO
- ✅ Estado del envío
- ✅ Tipo de validación
- ✅ ID del punto PUDO

## 📝 Base de Datos

### Tablas Nuevas
- `brickshare_pudo_locations`: Puntos Brickshare
- `qr_validation_logs`: Registro de validaciones

### Campos Añadidos a `shipments`
- `pickup_type`: 'correos' | 'brickshare'
- `brickshare_pudo_id`: ID del punto PUDO
- `delivery_qr_code`: QR de entrega
- `delivery_qr_expires_at`: Fecha expiración
- `delivery_validated_at`: Fecha validación
- `return_qr_code`: QR de devolución
- `return_qr_expires_at`: Fecha expiración
- `return_validated_at`: Fecha validación

## 🧪 Testing Rápido

```bash
# 1. Test validación
curl https://PROJECT.supabase.co/functions/v1/brickshare-qr-api/validate/BS-TEST123

# 2. Test confirmación
curl -X POST https://PROJECT.supabase.co/functions/v1/brickshare-qr-api/confirm \
  -H "Content-Type: application/json" \
  -d '{"qr_code":"BS-TEST123","validated_by":"BS-PUDO-001"}'

# 3. Test puntos PUDO
curl https://PROJECT.supabase.co/functions/v1/brickshare-qr-api/pudo-locations
```

## 📚 Documentación Completa

Ver [BRICKSHARE_PUDO_QR_API.md](./BRICKSHARE_PUDO_QR_API.md) para documentación detallada.

## ⚠️ Consideraciones

1. **Códigos QR**: Expiran en 30 días
2. **Un solo uso**: No se pueden reutilizar
3. **Orden**: Primero delivery, luego return
4. **Logs**: Todas las validaciones se registran
5. **Emails**: Automáticos al generar QR

## 🐛 Problemas Comunes

| Error | Solución |
|-------|----------|
| QR not found | Verificar que se generó el QR |
| Already used | QR de un solo uso |
| Expired | Regenerar QR (30 días máx) |
| Cannot return | Primero validar entrega |

## 📞 Soporte

- Docs: [BRICKSHARE_PUDO_QR_API.md](./BRICKSHARE_PUDO_QR_API.md)
- Email: tech@brickshare.com