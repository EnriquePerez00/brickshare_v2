# Swikly API V2 — Referencia para Brickshare

**Fuente:** OpenAPI spec descargada de `https://api.v2.sandbox.swikly.com/v1/openapi.yaml`  
**Archivo local:** `docs/api-specs/swikly-openapi-v1.yaml`  
**Fecha:** 2026-03-28

---

## 1. Entornos

| Entorno | Base URL |
|---|---|
| **Sandbox** | `https://api.v2.sandbox.swikly.com/v1` |
| **Producción** | `https://api.v2.swikly.com/v1` |

---

## 2. Autenticación

La API V2 usa **Bearer Token** (API Key), **no HMAC signatures**.

```
Authorization: Bearer <SWIKLY_API_TOKEN>
```

> ⚠️ Las Edge Functions actuales usan el formato V1 legacy (`X-Api-Key` + `X-Api-Sig` con HMAC). Deben migrarse a Bearer token.

---

## 3. Variables de Entorno en Brickshare

| Variable | Descripción | Ejemplo |
|---|---|---|
| `SWIKLY_API_TOKEN` | Bearer token para autenticar con la API V2 | `eyJhbGciOi...` |
| `SWIKLY_ACCOUNT_ID` | UUID de la cuenta Swikly del negocio | `A1B2C3D4-E5F6-...` |
| `SWIKLY_WEBHOOK_SECRET` | Secreto para verificar firmas HMAC de webhooks | `whsec_...` |
| `APP_URL` | URL base de la app para redirect URLs | `http://localhost:5173` |

Configuradas en `supabase/functions/.env`.

---

## 4. Endpoints Principales

### 4.1 Crear Request (Depósito de Garantía)

```
POST /accounts/{accountId}/requests
Authorization: Bearer <SWIKLY_API_TOKEN>
Content-Type: application/json
```

**Body para depósito (nuestro caso de uso):**

```json
{
  "description": "Fianza LEGO 75192 - Millennium Falcon · Brickshare",
  "language": "es",
  "firstName": "John",
  "lastName": "Doe",
  "email": "john.doe@example.com",
  "phoneNumber": "+34612345678",
  "callbacks": {
    "requestSecured": "https://<SUPABASE_URL>/functions/v1/swikly-webhook"
  },
  "deposit": {
    "startDate": "2026-03-28",
    "endDate": "2026-06-26",
    "amount": 79999
  },
  "redirectUrl": "https://brickshare.es/dashboard?deposit=confirmed",
  "returnUrl": "https://brickshare.es/dashboard?deposit=return"
}
```

**Campos importantes:**
- `amount` — En **céntimos** (79999 = €799.99)
- `startDate` — Fecha inicio del depósito (hoy)
- `endDate` — Fecha fin (debe ser hoy o posterior). Para Brickshare: +90 días
- `callbacks.requestSecured` — URL que recibe POST cuando el usuario completa el depósito
- `redirectUrl` — Redirige automáticamente al usuario tras completar
- `returnUrl` — Alternativa: muestra botón para que el usuario haga clic

**Response (201 Created):**

```json
{
  "id": "CF85309F-2557-4140-817D-E429B3F8E5D6",
  "status": "Pending",
  "shortLink": {
    "shortLink": "https://v2.sandbox.swik.link/xHbUtRi"
  },
  "deposit": {
    "id": "DEP-UUID",
    "amount": 79999,
    "status": "Pending"
  },
  "person": {
    "id": "PERSON-UUID",
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@example.com"
  },
  "createdAt": "2026-03-28T12:00:00.000+00:00"
}
```

### 4.2 Obtener Request por ID

```
GET /accounts/{accountId}/requests/{requestId}
Authorization: Bearer <SWIKLY_API_TOKEN>
```

### 4.3 Listar Requests

```
GET /accounts/{accountId}/requests?page=1&perPage=15
Authorization: Bearer <SWIKLY_API_TOKEN>
```

### 4.4 Cancelar Request

```
DELETE /accounts/{accountId}/requests/{requestId}
Authorization: Bearer <SWIKLY_API_TOKEN>
```

Solo cancela si el estado es `Pending` (usuario aún no ha completado).

### 4.5 Crear Reclaim (Cobrar depósito por daños)

```
POST /accounts/{accountId}/reclaims
Authorization: Bearer <SWIKLY_API_TOKEN>
Content-Type: application/json
```

```json
{
  "reclaimableType": "Deposit",
  "reclaimableId": "DEP-UUID",
  "amount": 15000,
  "reason": "Piezas faltantes en set LEGO 75192"
}
```

> **Importante:** Tras crear un reclaim, se deben subir documentos justificativos.

### 4.6 Crear Refund (Devolver fondos al usuario)

```
POST /accounts/{accountId}/refunds
Authorization: Bearer <SWIKLY_API_TOKEN>
Content-Type: application/json
```

```json
{
  "refundableType": "Payment",
  "refundableId": "PAYMENT-UUID",
  "amount": 5000
}
```

---

## 5. Estados (Status)

### Request Status

| Estado | Descripción |
|---|---|
| `Pending` | Esperando que el usuario complete |
| `Secured` | Usuario ha completado todas las operaciones |
| `PartiallyCanceled` | Algunas operaciones canceladas |
| `Canceled` | Todas las operaciones canceladas |
| `Expired` | Expirado sin completar |

### Deposit Status

| Estado | Descripción |
|---|---|
| `Pending` | Esperando aceptación del usuario |
| `Temporary` | Temporal |
| `Secured` | Depósito activo y asegurado |
| `Released` | Depósito liberado (devuelto) |
| `Canceled` | Cancelado |
| `ExpiredWithoutAcceptance` | Expirado sin aceptar |

### Reclaim Status

| Estado | Descripción |
|---|---|
| `Initialized` | Recién creado |
| `Scheduled` | Programado para ejecutar |
| `Finished` | Completado |

---

## 6. Webhooks (Callbacks)

### 6.1 Tipos de Callback

Al crear una Request, se pueden configurar 3 callbacks:

```json
{
  "callbacks": {
    "requestSecured": "https://url/webhook",
    "allPendingReclaimsCompleted": "https://url/webhook",
    "allPendingRefundsCompleted": "https://url/webhook"
  }
}
```

| Callback | Cuándo se dispara |
|---|---|
| `requestSecured` | Cuando el usuario completa el depósito |
| `allPendingReclaimsCompleted` | Cuando todos los reclaims pendientes terminan |
| `allPendingRefundsCompleted` | Cuando todos los refunds pendientes terminan |

### 6.2 Headers del Webhook

Swikly envía estos headers en cada callback:

| Header | Descripción |
|---|---|
| `Swikly-Account-Id` | UUID de la cuenta |
| `Swikly-Trade-Name` | Nombre comercial (ASCII) |
| `Swikly-Currency` | Moneda (EUR) |
| `Swikly-Signature` | Firma HMAC para verificación |

### 6.3 Verificación de Firma

El header `Swikly-Signature` tiene formato:

```
t=1739352941,sha256=7244dc6a957d9583516a170ff07242499e58e74da34afd732a60f900e8e162e1
```

Verificación:
1. Extraer timestamp (`t`) y hash (`sha256`) del header
2. Concatenar: `{timestamp}.{raw_body}`
3. Calcular HMAC-SHA256 con `SWIKLY_WEBHOOK_SECRET`
4. Comparar con el hash del header

```typescript
function verifySwiklySignature(
  signatureHeader: string,
  rawBody: string,
  secret: string
): boolean {
  const [tPart, sha256Part] = signatureHeader.split(",");
  const timestamp = tPart.replace("t=", "");
  const expectedHash = sha256Part.replace("sha256=", "");
  
  const payload = `${timestamp}.${rawBody}`;
  const computedHash = hmacSha256(secret, payload);
  
  return computedHash === expectedHash;
}
```

### 6.4 Body del Webhook

El body contiene el **objeto Request completo** con todas sus operaciones:

```json
{
  "id": "CF85309F-...",
  "status": "Secured",
  "deposit": {
    "id": "DEP-UUID",
    "amount": 79999,
    "status": "Secured",
    "startDate": "2026-03-28",
    "endDate": "2026-06-26"
  },
  "person": {
    "firstName": "John",
    "lastName": "Doe",
    "email": "john@example.com"
  },
  "createdAt": "2026-03-28T12:00:00.000+00:00"
}
```

---

## 7. Mapeo con Brickshare

### Flujo de Depósito

```
1. Admin confirma asignación → se crea shipment
2. create-swikly-wish-shipment:
   a. Lee set_pvp_release como monto del depósito
   b. POST /accounts/{accountId}/requests con deposit
   c. Guarda request.id como swikly_wish_id en shipment
   d. Guarda shortLink como swikly_wish_url
   e. swikly_status = "wish_created"
3. Usuario hace clic en link y completa el depósito
4. Swikly envía callback requestSecured → swikly-webhook
5. Webhook:
   a. Verifica firma
   b. Busca shipment por swikly_wish_id
   c. Actualiza swikly_status = "accepted"
   d. Envía email de confirmación
```

### Mapeo de Campos DB → API

| Campo shipments | Campo Swikly V2 |
|---|---|
| `swikly_wish_id` | `request.id` |
| `swikly_wish_url` | `shortLink.shortLink` |
| `swikly_deposit_amount` | `deposit.amount` (céntimos) |
| `swikly_status` | Derivado de `request.status` + `deposit.status` |

### Mapeo de Estados

| Swikly V2 Status | swikly_status (DB) |
|---|---|
| Request: Pending | `wish_created` |
| Request: Secured | `accepted` |
| Request: Canceled | `cancelled` |
| Request: Expired | `expired` |
| Deposit: Released | `released` |
| Reclaim: Finished | `captured` |

---

## 8. Edge Functions Afectadas

| Función | Usa API Swikly | Estado |
|---|---|---|
| `create-swikly-wish-shipment` | ✅ POST requests | ⚠️ Necesita migrar a V2 |
| `swikly-webhook` | ✅ Recibe callbacks | ⚠️ Necesita migrar firma V2 |
| `swikly-manage-wish` | ✅ DELETE/GET requests | ⚠️ Necesita migrar a V2 |
| `process-assignment-payment` | ❌ Solo Stripe | ✅ OK |

### Cambios Requeridos para V2

#### `create-swikly-wish-shipment`

**ANTES (V1 legacy):**
```typescript
const SWIKLY_API = "https://api.v2.swikly.com/v1";  // ← URL correcta pero auth incorrecta
headers: {
  "X-Api-Key": SWIKLY_ACCOUNT_ID,
  "X-Api-Sig": hmacSignature,
}
endpoint: /wishes
```

**DESPUÉS (V2):**
```typescript
const SWIKLY_API = "https://api.v2.sandbox.swikly.com/v1";
headers: {
  "Authorization": `Bearer ${SWIKLY_API_TOKEN}`,
}
endpoint: /accounts/${SWIKLY_ACCOUNT_ID}/requests
```

#### `swikly-webhook`

**ANTES:** Verifica `X-Api-Sig` con HMAC del body  
**DESPUÉS:** Verifica `Swikly-Signature` header con formato `t=...,sha256=...`

---

## 9. Testing en Sandbox

### Crear un depósito de prueba

```bash
curl -X POST "https://api.v2.sandbox.swikly.com/v1/accounts/${SWIKLY_ACCOUNT_ID}/requests" \
  -H "Authorization: Bearer ${SWIKLY_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Test Brickshare deposit",
    "language": "es",
    "firstName": "Test",
    "lastName": "User",
    "email": "test@brickshare.es",
    "deposit": {
      "startDate": "2026-03-28",
      "endDate": "2026-06-26",
      "amount": 5000
    },
    "callbacks": {
      "requestSecured": "https://your-supabase-url/functions/v1/swikly-webhook"
    },
    "redirectUrl": "http://localhost:5173/dashboard?deposit=confirmed"
  }'
```

### Listar requests

```bash
curl "https://api.v2.sandbox.swikly.com/v1/accounts/${SWIKLY_ACCOUNT_ID}/requests" \
  -H "Authorization: Bearer ${SWIKLY_API_TOKEN}"
```

### Cancelar un request

```bash
curl -X DELETE "https://api.v2.sandbox.swikly.com/v1/accounts/${SWIKLY_ACCOUNT_ID}/requests/${REQUEST_ID}" \
  -H "Authorization: Bearer ${SWIKLY_API_TOKEN}"
```

---

## 10. Notas Importantes

1. **Montos siempre en céntimos** — `79999` = €799.99
2. **endDate debe ser hoy o posterior** — Si pasó, la API rechaza
3. **Bearer token, no HMAC** — La autenticación V2 es simple
4. **Webhooks usan firma diferente** — `Swikly-Signature` con formato `t=...,sha256=...`
5. **Sandbox vs Producción** — Solo cambia la base URL y las credenciales
6. **Reclaims requieren documentos** — Tras crear un reclaim, subir archivos justificativos
7. **El shortLink es la URL para el usuario** — Es lo que se envía por email

---

## 11. Referencia Completa

Para la especificación OpenAPI completa, ver:
- `docs/api-specs/swikly-openapi-v1.yaml`
- [Documentación Swikly](https://api.v2.swikly.com/v1/docs)