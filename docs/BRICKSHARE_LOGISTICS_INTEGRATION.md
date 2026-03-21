# Integración Brickshare ↔ Brickshare_logistics

Documentación completa de la integración entre los sistemas de Brickshare (plataforma de alquiler) y Brickshare_logistics (sistema de PUDO).

## 📋 Índice

1. [Visión General](#visión-general)
2. [Arquitectura](#arquitectura)
3. [Flujos de Operación](#flujos-de-operación)
4. [API de Integración](#api-de-integración)
5. [Configuración](#configuración)
6. [Estados y Transiciones](#estados-y-transiciones)
7. [Troubleshooting](#troubleshooting)

---

## Visión General

### Propósito

La integración permite que los envíos de Brickshare utilicen el sistema de puntos PUDO (Pick-Up Drop-Off) gestionado por Brickshare_logistics, proporcionando:

- **Para deliveries**: Entrega de sets LEGO en puntos Brickshare
- **Para returns**: Devolución de sets en puntos Brickshare
- **QR codes**: Sistema de validación mediante códigos QR
- **Trazabilidad**: Sincronización de estados entre sistemas

### Proyectos

**Brickshare** (`/Users/I764690/Code_personal/Brickshare`)
- Plataforma principal de alquiler de sets LEGO
- Gestiona usuarios, assignments, pagos, inventario
- **URL**: https://brickshare.es (o tu dominio)

**Brickshare_logistics** (`/Users/I764690/Code_personal/Brickshare_logistics`)
- Sistema de gestión de puntos PUDO
- App móvil para owners de puntos PUDO
- APIs para integración
- **URL**: https://[tu-proyecto].supabase.co

---

## Arquitectura

```
┌─────────────────────────────────────────────────────────┐
│                    BRICKSHARE                            │
│              (Plataforma de Alquiler)                    │
│                                                           │
│  ┌─────────────┐      ┌──────────────┐                 │
│  │  Shipments  │─────▶│ pickup_type  │                 │
│  │             │      │ = 'brickshare'│                 │
│  └─────────────┘      └──────┬───────┘                 │
│         │                     │                          │
│         │  brickshare_package_id                        │
│         │                     │                          │
└─────────┼─────────────────────┼──────────────────────────┘
          │                     │
          │   HTTP REST API     │
          │   (Autenticado)     │
          │                     │
┌─────────▼─────────────────────▼──────────────────────────┐
│              BRICKSHARE_LOGISTICS                         │
│             (Sistema de Logística/PUDO)                   │
│                                                           │
│  ┌─────────────┐      ┌──────────────┐                  │
│  │  Packages   │◀────│  Locations   │                  │
│  │             │      │   (PUDOs)    │                  │
│  └──────┬──────┘      └──────────────┘                  │
│         │                                                 │
│         │  QR Validation                                 │
│         │                                                 │
│  ┌──────▼──────┐                                         │
│  │  App Móvil  │  (Owners escanean QR)                  │
│  └─────────────┘                                         │
└───────────────────────────────────────────────────────────┘
```

### Componentes Clave

#### En Brickshare:

1. **Tabla `shipments`**
   - `brickshare_package_id`: Enlace al package en Logistics
   - `delivery_qr_code`: QR para entrega al cliente
   - `return_qr_code`: QR para devolución del cliente

2. **Edge Function `create-logistics-package`**
   - Crea packages en Brickshare_logistics
   - Se llama automáticamente en `useBrickshareShipments`

3. **Edge Function `send-brickshare-qr-email`** (modificada)
   - Envía QR dinámicos (delivery) o estáticos (return)
   - Diferencia entre entregas y devoluciones

#### En Brickshare_logistics:

1. **Tabla `packages`**
   - `type`: 'delivery' | 'return'
   - `external_shipment_id`: ID del shipment de Brickshare
   - `source_system`: 'brickshare' | 'logistics'
   - `dynamic_qr_hash`: JWT para entregas (expira 5 min)
   - `static_qr_hash`: JWT para devoluciones (sin expiración temporal)

2. **API REST Endpoints**
   - `POST /api/packages/create`: Crear package
   - `GET /api/packages/{id}/status`: Estado de package
   - `GET /api/packages/by-shipment/{shipmentId}/status`: Por shipment ID

3. **Edge Functions**
   - `generate-dynamic-qr`: QR de 5 min para entregas
   - `generate-static-return-qr`: QR permanente para devoluciones
   - `verify-package-qr`: Validación de QR (ambos tipos)

---

## Flujos de Operación

### 1. Delivery (Oficinas → PUDO → Cliente)

```
1. CREACIÓN (Brickshare)
   ↓
   Usuario selecciona punto Brickshare PUDO
   ↓
   useBrickshareShipments.createDeliveryShipment()
   ├─ Crea shipment (pickup_type='brickshare')
   └─ Llama create-logistics-package
       └─ POST /api/packages/create
           └─ Crea package (type='delivery', status='pending_dropoff')

2. ENVÍO DESDE OFICINAS
   ↓
   Package viaja a punto PUDO
   ↓
   Owner recibe paquete

3. RECEPCIÓN EN PUDO (App Móvil)
   ↓
   Owner: Modo "Recepción" → Escanea tracking code
   ↓
   Package: status = 'in_location'

4. CLIENTE SOLICITA RECOGIDA (Web Brickshare)
   ↓
   Cliente: "Solicitar código QR"
   ↓
   send-brickshare-qr-email (type='delivery')
   ↓
   Email enviado con QR simple

5. ENTREGA AL CLIENTE (App Móvil)
   ↓
   Cliente presenta QR (en pantalla o impreso)
   ↓
   Owner: Modo "Entrega QR" → Escanea QR del cliente
   ↓
   verify-package-qr valida:
   ├─ QR válido
   ├─ Package en 'in_location'
   └─ Actualiza a 'picked_up'
   ↓
   Imprime recibo de entrega
```

### 2. Return (Cliente → PUDO → Oficinas)

```
1. SOLICITUD DE DEVOLUCIÓN (Web Brickshare)
   ↓
   Cliente: "Devolver set"
   ↓
   useBrickshareShipments.createReturnShipment()
   ├─ Crea shipment (direction='to_brickshare')
   ├─ Llama create-logistics-package (type='return')
   └─ Llama send-brickshare-qr-email (type='return')
       └─ Email enviado con QR estático

2. CLIENTE ENTREGA EN PUDO (App Móvil)
   ↓
   Cliente presenta QR estático (del email)
   ↓
   Owner: Modo "Recepción" → Escanea QR del cliente
   ↓
   verify-package-qr valida:
   ├─ QR válido (sin límite de tiempo)
   ├─ Package en 'pending_dropoff'
   └─ Actualiza a 'in_location'
   ↓
   Imprime recibo de recepción

3. ENVÍO A OFICINAS
   ↓
   Package viaja a oficinas centrales
   ↓
   Oficinas recepcionan
   ↓
   Brickshare consulta estado:
   GET /api/packages/by-shipment/{shipmentId}/status
   ↓
   Si status='returned' → Proceso completado
```

---

## API de Integración

### Autenticación

Todas las peticiones requieren header de autenticación:

```http
X-Integration-Secret: <SHARED_SECRET>
```

**Configurar en ambos proyectos:**
- Brickshare: `BRICKSHARE_LOGISTICS_SECRET`
- Brickshare_logistics: `BRICKSHARE_INTEGRATION_SECRET`

### Endpoints

#### 1. Crear Package

```http
POST https://[logistics-url]/api/packages/create
Content-Type: application/json
X-Integration-Secret: <secret>

{
  "tracking_code": "BS-ABC12345",
  "type": "delivery",
  "location_id": "uuid-del-pudo",
  "customer_id": "uuid-del-usuario",
  "external_shipment_id": "uuid-del-shipment",
  "source_system": "brickshare"
}
```

**Respuesta 201:**
```json
{
  "success": true,
  "package": {
    "id": "package-uuid",
    "tracking_code": "BS-ABC12345",
    "type": "delivery",
    "status": "pending_dropoff",
    "location_id": "pudo-uuid",
    "location_name": "Estanco López",
    "external_shipment_id": "shipment-uuid",
    "created_at": "2026-03-20T20:00:00Z"
  }
}
```

#### 2. Consultar Estado por Package ID

```http
GET https://[logistics-url]/api/packages/{package-id}/status
X-Integration-Secret: <secret>
```

**Respuesta 200:**
```json
{
  "success": true,
  "package": {
    "id": "package-uuid",
    "tracking_code": "BS-ABC12345",
    "type": "delivery",
    "status": "in_location",
    "location": {
      "id": "pudo-uuid",
      "name": "Estanco López",
      "address": "Calle Mayor 123",
      "city": "Madrid",
      "postal_code": "28001"
    },
    "has_dynamic_qr": false,
    "has_static_qr": false,
    "qr_expires_at": null,
    "external_shipment_id": "shipment-uuid",
    "source_system": "brickshare",
    "created_at": "2026-03-20T20:00:00Z",
    "updated_at": "2026-03-20T21:00:00Z"
  }
}
```

#### 3. Consultar Estado por Shipment ID

```http
GET https://[logistics-url]/api/packages/by-shipment/{shipment-id}/status
X-Integration-Secret: <secret>
```

Misma respuesta que el endpoint anterior.

---

## Configuración

### Variables de Entorno

#### En Brickshare (`.env`):

```env
# URL del proyecto Brickshare_logistics
BRICKSHARE_LOGISTICS_URL=https://[tu-proyecto].supabase.co

# Secret compartido para autenticación
BRICKSHARE_LOGISTICS_SECRET=tu-secret-compartido-muy-seguro
```

#### En Brickshare_logistics (`.env`):

```env
# Secret compartido (mismo que en Brickshare)
BRICKSHARE_INTEGRATION_SECRET=tu-secret-compartido-muy-seguro

# Secret para firmar JWT de QR codes
QR_JWT_SECRET=otro-secret-diferente-para-qr
```

### Migraciones de Base de Datos

#### Brickshare:

```bash
cd /Users/I764690/Code_personal/Brickshare
# La migración 20260322000000_add_logistics_integration.sql
# ya está creada en supabase/migrations/
```

#### Brickshare_logistics:

```bash
cd /Users/I764690/Code_personal/Brickshare_logistics
# La migración 006_add_external_integration.sql
# ya está creada en supabase/migrations/
```

### Despliegue de Edge Functions

#### Brickshare:

```bash
cd /Users/I764690/Code_personal/Brickshare
supabase functions deploy create-logistics-package
supabase functions deploy send-brickshare-qr-email
```

#### Brickshare_logistics:

```bash
cd /Users/I764690/Code_personal/Brickshare_logistics
supabase functions deploy generate-static-return-qr
supabase functions deploy generate-dynamic-qr
supabase functions deploy verify-package-qr
```

---

## Estados y Transiciones

### Package States

```
DELIVERY:
  pending_dropoff → in_location → picked_up
       ↓               ↓              ↓
   (en tránsito)  (en PUDO)    (cliente recogió)

RETURN:
  pending_dropoff → in_location → returned
       ↓               ↓              ↓
  (cliente va)    (en PUDO)    (oficinas recibió)
```

### Shipment States (Brickshare)

- `pending`: Creado, esperando envío
- `in_transit`: En camino
- `ready_for_pickup`: En PUDO, listo para recoger
- `delivered`: Entregado al cliente
- `returned`: Devuelto a oficinas

### Sincronización

**Brickshare consulta periódicamente o bajo demanda:**

```typescript
// En Brickshare frontend
const checkPackageStatus = async (packageId: string) => {
  const response = await fetch(
    `${LOGISTICS_URL}/api/packages/${packageId}/status`,
    {
      headers: {
        'X-Integration-Secret': SECRET
      }
    }
  );
  const data = await response.json();
  return data.package.status;
};
```

---

## Troubleshooting

### Package no se crea en Logistics

**Síntomas:**
- Shipment creado pero `brickshare_package_id` es null
- Email de QR no se envía

**Solución:**
```typescript
// Crear manualmente el package
const { data } = await supabase.functions.invoke('create-logistics-package', {
  body: {
    shipment_id: 'el-uuid-del-shipment',
    type: 'delivery' // o 'return'
  }
});
```

### QR no válido en app móvil

**Síntomas:**
- Error "QR code is invalid or has expired"

**Causas posibles:**
1. QR dinámico expirado (>5 min)
2. Mismatch entre `QR_JWT_SECRET` en ambos proyectos
3. Package ya procesado

**Solución:**
- Para delivery: Regenerar QR dinámico (solicitar nuevo código)
- Para return: El QR estático no expira, verificar JWT_SECRET

### Estado no sincroniza

**Síntomas:**
- Package actualizado en Logistics pero shipment no refleja cambio

**Solución:**
- Brickshare debe consultar activamente el estado
- Implementar polling o webhooks (futuro)

```typescript
// Polling cada 30 segundos
useEffect(() => {
  const interval = setInterval(async () => {
    if (shipment.brickshare_package_id) {
      const status = await checkPackageStatus(shipment.brickshare_package_id);
      if (status === 'picked_up' && shipment.status !== 'delivered') {
        // Actualizar shipment
      }
    }
  }, 30000);
  return () => clearInterval(interval);
}, [shipment]);
```

---

## Seguridad

### Secrets

- **NUNCA** commitear secrets en Git
- Usar `.env.local` en desarrollo
- En producción: Variables de entorno de Supabase

### JWT de QR

- Firmados con HMAC-SHA256
- Dinámicos: expiran en 5 minutos
- Estáticos: sin expiración temporal, invalidados al escanear

### API Endpoints

- Autenticados con shared secret
- CORS configurado para dominios específicos
- Rate limiting recomendado en producción

---

## Próximos Pasos

1. **Webhooks**: Notificaciones en tiempo real de Logistics → Brickshare
2. **Dashboard**: Vista unificada de packages en Operations
3. **Analytics**: Métricas de uso de puntos PUDO
4. **Impresión**: Integrar impresora térmica en app móvil

---

## Soporte

Para problemas o preguntas:
- Revisar logs en Supabase Dashboard
- Consultar esta documentación
- Verificar configuración de variables de entorno

## Changelog

- **2026-03-22**: Implementación inicial de integración
  - Soporte para deliveries y returns
  - QR dinámicos y estáticos
  - API REST para sincronización