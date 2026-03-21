# Brickshare PUDO QR Code System - API Documentation

## Descripción General

Sistema de códigos QR para validación de entregas y devoluciones en puntos Brickshare (PUDO). Este sistema permite gestionar envíos de sets LEGO a través de puntos de recogida propios de Brickshare, utilizando códigos QR para validar entregas y devoluciones.

## Características Principales

- **Dual Flow**: Soporta tanto puntos Correos (flujo existente) como puntos Brickshare (nuevo flujo)
- **QR Code Generation**: Generación automática de códigos QR únicos para entregas y devoluciones
- **Mobile API**: API para aplicaciones móviles que validan QR sin exponer datos personales
- **Email Notifications**: Envío automático de QR codes por email
- **Audit Trail**: Registro completo de todas las validaciones de QR

## Arquitectura del Sistema

```
┌─────────────────────────────────────────────────────────────┐
│                      Usuario/Cliente                         │
└────────────────┬────────────────────────────────────────────┘
                 │
                 │ 1. Solicita envío
                 │
┌────────────────▼────────────────────────────────────────────┐
│                   Sistema Brickshare                         │
│  - Genera QR de entrega                                      │
│  - Envía email con QR                                        │
└────────────────┬────────────────────────────────────────────┘
                 │
                 │ 2. QR Code enviado
                 │
┌────────────────▼────────────────────────────────────────────┐
│                Punto Brickshare (PUDO)                       │
│  - Escanea QR de entrega                                     │
│  - Valida código via API                                     │
│  - Confirma entrega                                          │
└────────────────┬────────────────────────────────────────────┘
                 │
                 │ 3. Entrega validada
                 │
┌────────────────▼────────────────────────────────────────────┐
│                      Usuario/Cliente                         │
│  - Recibe el set                                             │
│  - Usa el set                                                │
│  - Solicita devolución                                       │
└────────────────┬────────────────────────────────────────────┘
                 │
                 │ 4. Solicitud de devolución
                 │
┌────────────────▼────────────────────────────────────────────┐
│                   Sistema Brickshare                         │
│  - Genera QR de devolución                                   │
│  - Envía email con QR                                        │
└────────────────┬────────────────────────────────────────────┘
                 │
                 │ 5. QR devolución enviado
                 │
┌────────────────▼────────────────────────────────────────────┐
│                Punto Brickshare (PUDO)                       │
│  - Escanea QR de devolución                                  │
│  - Valida código via API                                     │
│  - Confirma devolución                                       │
└─────────────────────────────────────────────────────────────┘
```

## Base de Datos

### Tablas Nuevas

#### `brickshare_pudo_locations`
Ubicaciones de puntos Brickshare.

```sql
CREATE TABLE brickshare_pudo_locations (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    city TEXT NOT NULL,
    postal_code TEXT NOT NULL,
    province TEXT NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    contact_phone TEXT,
    contact_email TEXT,
    opening_hours JSONB,
    is_active BOOLEAN DEFAULT true,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);
```

#### `qr_validation_logs`
Registro de todas las validaciones de códigos QR.

```sql
CREATE TABLE qr_validation_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shipment_id UUID NOT NULL REFERENCES shipments(id),
    qr_code TEXT NOT NULL,
    validation_type TEXT NOT NULL CHECK (validation_type IN ('delivery', 'return')),
    validated_by TEXT,
    validated_at TIMESTAMPTZ DEFAULT now(),
    validation_status TEXT NOT NULL CHECK (validation_status IN ('success', 'expired', 'invalid', 'already_used')),
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT now()
);
```

### Campos Añadidos a `shipments`

```sql
ALTER TABLE shipments
ADD COLUMN pickup_type TEXT CHECK (pickup_type IN ('correos', 'brickshare')) DEFAULT 'correos',
ADD COLUMN brickshare_pudo_id TEXT,
ADD COLUMN delivery_qr_code TEXT UNIQUE,
ADD COLUMN delivery_qr_expires_at TIMESTAMPTZ,
ADD COLUMN delivery_validated_at TIMESTAMPTZ,
ADD COLUMN return_qr_code TEXT UNIQUE,
ADD COLUMN return_qr_expires_at TIMESTAMPTZ,
ADD COLUMN return_validated_at TIMESTAMPTZ,
ADD COLUMN brickshare_metadata JSONB DEFAULT '{}'::jsonb;
```

## API Endpoints

### Base URL
```
https://your-project.supabase.co/functions/v1/brickshare-qr-api
```

### 1. Validar Código QR

Valida un código QR y devuelve información del envío (sin datos personales).

**Endpoint**: `GET /validate/{qr_code}`

**Autenticación**: No requerida (público)

**Parámetros**:
- `qr_code` (path): El código QR a validar

**Respuesta Exitosa** (200):
```json
{
  "success": true,
  "data": {
    "shipment_id": "uuid",
    "validation_type": "delivery",
    "shipment_info": {
      "assignment_id": "uuid",
      "set_id": "uuid",
      "set_name": "Millennium Falcon",
      "set_number": "75192",
      "theme": "Star Wars",
      "status": "in_transit",
      "brickshare_pudo_id": "BS-PUDO-001",
      "validation_type": "delivery"
    }
  }
}
```

**Respuesta con Error** (400):
```json
{
  "success": false,
  "error": "QR code has expired"
}
```

**Posibles Errores**:
- `QR code not found`: El código no existe
- `QR code already used`: Ya fue validado
- `QR code has expired`: El código ha expirado
- `This shipment is not for Brickshare pickup point`: No es un envío Brickshare
- `Cannot return a set that has not been delivered yet`: Intento de devolución antes de entrega

**Ejemplo cURL**:
```bash
curl https://your-project.supabase.co/functions/v1/brickshare-qr-api/validate/BS-ABC123XYZ456
```

---

### 2. Confirmar Validación de QR

Confirma la validación de un código QR y actualiza el estado del envío.

**Endpoint**: `POST /confirm`

**Autenticación**: No requerida (público)

**Body**:
```json
{
  "qr_code": "BS-ABC123XYZ456",
  "validated_by": "BS-PUDO-001" // Opcional: ID del punto PUDO
}
```

**Respuesta Exitosa** (200):
```json
{
  "success": true,
  "message": "Shipment successfully delivered",
  "shipment_id": "uuid"
}
```

**Respuesta con Error** (400):
```json
{
  "success": false,
  "error": "QR code has expired"
}
```

**Ejemplo cURL**:
```bash
curl -X POST https://your-project.supabase.co/functions/v1/brickshare-qr-api/confirm \
  -H "Content-Type: application/json" \
  -d '{"qr_code":"BS-ABC123XYZ456","validated_by":"BS-PUDO-001"}'
```

---

### 3. Obtener Ubicaciones PUDO

Devuelve la lista de puntos Brickshare activos.

**Endpoint**: `GET /pudo-locations`

**Autenticación**: No requerida (público)

**Respuesta Exitosa** (200):
```json
{
  "success": true,
  "data": [
    {
      "id": "BS-PUDO-001",
      "name": "Brickshare Madrid Centro",
      "address": "Calle Gran Vía 28",
      "city": "Madrid",
      "postal_code": "28013",
      "province": "Madrid",
      "latitude": 40.4200,
      "longitude": -3.7038,
      "contact_phone": "+34 912 345 678",
      "contact_email": "madrid.centro@brickshare.com",
      "opening_hours": {
        "monday": "10:00-20:00",
        "tuesday": "10:00-20:00",
        "wednesday": "10:00-20:00",
        "thursday": "10:00-20:00",
        "friday": "10:00-20:00",
        "saturday": "10:00-14:00",
        "sunday": "closed"
      },
      "is_active": true
    }
  ]
}
```

**Ejemplo cURL**:
```bash
curl https://your-project.supabase.co/functions/v1/brickshare-qr-api/pudo-locations
```

---

### 4. Obtener Detalles de Envío

Devuelve información detallada de un envío específico.

**Endpoint**: `GET /shipment/{id}`

**Autenticación**: Requerida (Bearer token)

**Headers**:
```
Authorization: Bearer <token>
```

**Respuesta Exitosa** (200):
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "status": "in_transit",
    "pickup_type": "brickshare",
    "delivery_qr_code": "BS-ABC123XYZ456",
    "delivery_qr_expires_at": "2026-04-20T00:00:00Z",
    "delivery_validated_at": null,
    "return_qr_code": null,
    "return_qr_expires_at": null,
    "return_validated_at": null,
    "brickshare_pudo_id": "BS-PUDO-001",
    "assignment": {
      "id": "uuid",
      "set_id": "uuid",
      "product": {
        "name": "Millennium Falcon",
        "set_number": "75192",
        "theme": "Star Wars"
      }
    },
    "pudo": {
      "name": "Brickshare Madrid Centro",
      "address": "Calle Gran Vía 28",
      "city": "Madrid",
      "postal_code": "28013"
    }
  }
}
```

**Ejemplo cURL**:
```bash
curl https://your-project.supabase.co/functions/v1/brickshare-qr-api/shipment/uuid \
  -H "Authorization: Bearer <token>"
```

## Funciones de Base de Datos

### `generate_delivery_qr(p_shipment_id UUID)`

Genera un código QR único para la entrega.

**Parámetros**:
- `p_shipment_id`: UUID del envío

**Retorna**:
```sql
TABLE(qr_code TEXT, expires_at TIMESTAMPTZ)
```

**Ejemplo**:
```sql
SELECT * FROM generate_delivery_qr('uuid-del-envio');
```

---

### `generate_return_qr(p_shipment_id UUID)`

Genera un código QR único para la devolución.

**Parámetros**:
- `p_shipment_id`: UUID del envío

**Retorna**:
```sql
TABLE(qr_code TEXT, expires_at TIMESTAMPTZ)
```

**Ejemplo**:
```sql
SELECT * FROM generate_return_qr('uuid-del-envio');
```

---

### `validate_qr_code(p_qr_code TEXT)`

Valida un código QR y devuelve información del envío.

**Parámetros**:
- `p_qr_code`: El código QR a validar

**Retorna**:
```sql
TABLE(
    shipment_id UUID,
    validation_type TEXT,
    is_valid BOOLEAN,
    error_message TEXT,
    shipment_info JSONB
)
```

**Ejemplo**:
```sql
SELECT * FROM validate_qr_code('BS-ABC123XYZ456');
```

---

### `confirm_qr_validation(p_qr_code TEXT, p_validated_by TEXT)`

Confirma la validación y actualiza el estado del envío.

**Parámetros**:
- `p_qr_code`: El código QR a confirmar
- `p_validated_by`: ID del validador (opcional)

**Retorna**:
```sql
TABLE(
    success BOOLEAN,
    message TEXT,
    shipment_id UUID
)
```

**Ejemplo**:
```sql
SELECT * FROM confirm_qr_validation('BS-ABC123XYZ456', 'BS-PUDO-001');
```

## Flujo de Trabajo Completo

### 1. Creación de Envío a Punto Brickshare

```typescript
// Frontend: Usuario selecciona punto Brickshare
import { useBrickshareShipments } from '@/hooks/useBrickshareShipments';

const { updateToBricksharePudo, generateDeliveryQR } = useBrickshareShipments();

// Actualizar envío para usar punto Brickshare
await updateToBricksharePudo.mutateAsync({
  shipmentId: 'uuid',
  pudoId: 'BS-PUDO-001'
});

// Generar QR de entrega (se envía automáticamente por email)
await generateDeliveryQR.mutateAsync('uuid');
```

### 2. Validación de Entrega en Punto PUDO

```typescript
// App móvil del punto PUDO: Escanear QR
const response = await fetch(
  'https://your-project.supabase.co/functions/v1/brickshare-qr-api/validate/BS-ABC123XYZ456'
);
const validation = await response.json();

if (validation.success && validation.data.validation_type === 'delivery') {
  // Mostrar información del set
  console.log('Set:', validation.data.shipment_info.set_name);
  
  // Confirmar entrega
  await fetch(
    'https://your-project.supabase.co/functions/v1/brickshare-qr-api/confirm',
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        qr_code: 'BS-ABC123XYZ456',
        validated_by: 'BS-PUDO-001'
      })
    }
  );
}
```

### 3. Solicitud de Devolución

```typescript
// Frontend: Usuario solicita devolución
const { generateReturnQR } = useBrickshareShipments();

// Generar QR de devolución (se envía automáticamente por email)
await generateReturnQR.mutateAsync('uuid');
```

### 4. Validación de Devolución en Punto PUDO

```typescript
// App móvil del punto PUDO: Escanear QR de devolución
const response = await fetch(
  'https://your-project.supabase.co/functions/v1/brickshare-qr-api/validate/BS-XYZ789ABC012'
);
const validation = await response.json();

if (validation.success && validation.data.validation_type === 'return') {
  // Confirmar devolución
  await fetch(
    'https://your-project.supabase.co/functions/v1/brickshare-qr-api/confirm',
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        qr_code: 'BS-XYZ789ABC012',
        validated_by: 'BS-PUDO-001'
      })
    }
  );
}
```

## Estados del Envío

| Estado | Descripción |
|--------|-------------|
| `pending` | Envío creado, pendiente de preparación |
| `ready_for_pickup` | Listo para ser recogido en punto PUDO |
| `in_transit` | En tránsito hacia punto PUDO |
| `delivered` | Entregado al usuario (QR validado) |
| `returned` | Devuelto por el usuario (QR de devolución validado) |

## Seguridad

### Datos Expuestos en API Pública

La API de validación **NO expone**:
- Datos personales del usuario (nombre, email, teléfono, dirección)
- Datos de pago
- Información sensible del alquiler

La API **SÍ expone**:
- Información del set LEGO (nombre, número, tema)
- Estado del envío
- Tipo de validación (entrega o devolución)
- ID del punto PUDO

### Expiración de Códigos QR

- Los códigos QR expiran automáticamente después de 30 días
- No se pueden reutilizar códigos ya validados
- Los intentos de validación se registran en `qr_validation_logs`

### Políticas RLS (Row Level Security)

```sql
-- Usuarios solo pueden ver sus propios logs de validación
CREATE POLICY "Users can view their own validation logs"
    ON qr_validation_logs FOR SELECT
    TO authenticated
    USING (
        shipment_id IN (
            SELECT s.id FROM shipments s
            JOIN assignments a ON s.assignment_id = a.id
            WHERE a.user_id = auth.uid()
        )
    );
```

## Emails Automáticos

### Email de Entrega

Se envía automáticamente cuando se genera el QR de entrega:
- **Asunto**: "Tu código QR para recoger: {producto}"
- **Contenido**: 
  - Código QR grande y destacado
  - Información del punto PUDO
  - Fecha de expiración
  - Instrucciones de recogida

### Email de Devolución

Se envía automáticamente cuando se genera el QR de devolución:
- **Asunto**: "Tu código QR para devolver: {producto}"
- **Contenido**:
  - Código QR grande y destacado
  - Información del punto PUDO
  - Fecha de expiración
  - Instrucciones de devolución
  - Recordatorio de verificar que el set está completo

## Monitorización y Logs

Todos los eventos de validación se registran en `qr_validation_logs`:

```sql
SELECT 
    qvl.validated_at,
    qvl.validation_type,
    qvl.validation_status,
    s.id as shipment_id,
    p.name as product_name,
    bpl.name as pudo_name
FROM qr_validation_logs qvl
JOIN shipments s ON qvl.shipment_id = s.id
JOIN assignments a ON s.assignment_id = a.id
JOIN products p ON a.set_id = p.id
LEFT JOIN brickshare_pudo_locations bpl ON qvl.validated_by = bpl.id
ORDER BY qvl.validated_at DESC;
```

## Mantenimiento

### Añadir Nuevo Punto PUDO

```sql
INSERT INTO brickshare_pudo_locations (
    id, name, address, city, postal_code, province,
    latitude, longitude, contact_email, is_active
) VALUES (
    'BS-PUDO-003',
    'Brickshare Valencia Centro',
    'Calle de Colón 1',
    'Valencia',
    '46004',
    'Valencia',
    39.4699,
    -0.3763,
    'valencia.centro@brickshare.com',
    true
);
```

### Desactivar Punto PUDO

```sql
UPDATE brickshare_pudo_locations
SET is_active = false
WHERE id = 'BS-PUDO-001';
```

### Regenerar QR Expirado

```sql
-- Regenerar QR de entrega
SELECT * FROM generate_delivery_qr('uuid-del-envio');

-- Regenerar QR de devolución
SELECT * FROM generate_return_qr('uuid-del-envio');
```

## Testing

### Test de Validación

```bash
# Validar QR de entrega
curl https://your-project.supabase.co/functions/v1/brickshare-qr-api/validate/BS-TEST123

# Confirmar validación
curl -X POST https://your-project.supabase.co/functions/v1/brickshare-qr-api/confirm \
  -H "Content-Type: application/json" \
  -d '{"qr_code":"BS-TEST123","validated_by":"BS-PUDO-001"}'
```

### Test de Puntos PUDO

```bash
# Obtener lista de puntos
curl https://your-project.supabase.co/functions/v1/brickshare-qr-api/pudo-locations
```

## Errores Comunes y Soluciones

| Error | Causa | Solución |
|-------|-------|----------|
| `QR code not found` | Código inválido o no existe | Verificar que el QR fue generado correctamente |
| `QR code already used` | Ya fue validado anteriormente | Código de un solo uso, generar uno nuevo si es necesario |
| `QR code has expired` | Han pasado más de 30 días | Regenerar código QR |
| `Cannot return...` | Intento de devolución sin entrega | Primero debe validarse la entrega |
| `This shipment is not for Brickshare` | El envío usa Correos | Solo aplica para puntos Brickshare |

## Roadmap Futuro

- [ ] Generación de QR codes como imágenes PNG/SVG
- [ ] Notificaciones push al validar QR
- [ ] Dashboard para puntos PUDO con estadísticas
- [ ] Soporte para múltiples sets en un solo QR
- [ ] Integración con sistema de inventario de puntos PUDO
- [ ] Códigos QR dinámicos con información en tiempo real

## Contacto y Soporte

Para preguntas técnicas o reportar problemas:
- Email: tech@brickshare.com
- Documentación: https://docs.brickshare.com
- GitHub Issues: https://github.com/brickshare/issues