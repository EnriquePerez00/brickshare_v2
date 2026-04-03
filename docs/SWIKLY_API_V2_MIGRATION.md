# Migración Swikly: API V1 → API V2

**Fecha:** 31 de Marzo de 2026  
**Estado:** ✅ **COMPLETADO** (Fase 1 + Fase 2)  
**Componentes Actualizados:**
- ✅ `supabase/functions/create-swikly-wish-shipment/index.ts`
- ✅ `supabase/functions/swikly-webhook/index.ts`

---

## 📋 Resumen de Cambios

### Fase 1: Quick Wins ⚡ (Sin cambios BD)

**✅ Implementado en `create-swikly-wish-shipment/index.ts`:**

1. **Añadir campo `phoneNumber`** (línea 132-133)
   - Se envía el teléfono del usuario si está disponible
   - Opcional en la API de Swikly pero recomendado
   - Mejora la experiencia en depósitos de Swikly

2. **Añadir campo `language: "es"`** (línea 124)
   - Especifica que el depósito es en español
   - Swikly envía emails en el idioma correcto

3. **Mejorar parsing de nombres** (líneas 126-128)
   - Mejor algoritmo para separar firstName/lastName
   - Maneja nombres con múltiples palabras correctamente

4. **Mejorar logging** (líneas 74-76, 85-88, 102-104, 113-114, 163)
   - Prefijo `[Swikly]` para identificar logs
   - Información estructurada en cada paso
   - Emojis para estados: ✅ éxito, ❌ error, ⚠️ warning

---

### Fase 2: Migración a API V2 🔄

#### **2.1 Actualizar autenticación** (línea 6)

**ANTES (V1 Legacy - HMAC):**
```typescript
const SWIKLY_SECRET_KEY = Deno.env.get("SWIKLY_SECRET_KEY") ?? "";
function buildSwiklySignature(body: string): string {
  return hmac("sha256", SWIKLY_SECRET_KEY, body, "utf8", "hex") as string;
}

headers: {
  "X-Api-Key": SWIKLY_ACCOUNT_ID,
  "X-Api-Sig": signature,
}
```

**DESPUÉS (V2 - Bearer Token):**
```typescript
const SWIKLY_API_TOKEN = Deno.env.get("SWIKLY_API_TOKEN") ?? "";

headers: {
  "Authorization": `Bearer ${SWIKLY_API_TOKEN}`,
}
```

---

#### **2.2 Cambiar endpoint** (línea 168)

**ANTES:**
```
POST /wishes
```

**DESPUÉS:**
```
POST /accounts/{SWIKLY_ACCOUNT_ID}/requests
```

---

#### **2.3 Actualizar estructura del payload** (líneas 120-144)

**ANTES (API V1):**
```json
{
  "amount": 79999,
  "currency": "EUR",
  "description": "...",
  "wishee_email": "user@example.com",
  "wishee_firstname": "John",
  "wishee_lastname": "Doe",
  "start_date": "2026-03-31",
  "end_date": "2026-06-29",
  "callback_url": "...",
  "success_url": "...",
  "cancel_url": "..."
}
```

**DESPUÉS (API V2):**
```json
{
  "description": "Fianza LEGO...",
  "language": "es",
  "firstName": "John",
  "lastName": "Doe",
  "email": "user@example.com",
  "phoneNumber": "+34612345678",
  "callbacks": {
    "requestSecured": "..."
  },
  "deposit": {
    "startDate": "2026-03-31",
    "endDate": "2026-06-29",
    "amount": 79999
  },
  "redirectUrl": "...",
  "returnUrl": "..."
}
```

---

#### **2.4 Adaptar parsing de respuesta** (líneas 150-156)

**ANTES:**
```typescript
const wishId = swiklyData.id ?? swiklyData.wish_id ?? swiklyData.data?.id;
const wishUrl = swiklyData.url ?? swiklyData.wish_url ?? swiklyData.data?.url ?? swiklyData.link ?? "";
```

**DESPUÉS:**
```typescript
const wishId = swiklyData.id; // Siempre es 'id' en V2
const wishUrl = swiklyData.shortLink?.shortLink ?? swiklyData.shortLink; // Nueva estructura anidada
```

---

#### **2.5 Actualizar webhook para firma V2** (líneas 1-65 en `swikly-webhook/index.ts`)

**Verificación de firma V2:**

```typescript
async function verifySwiklySignatureV2(
  signatureHeader: string,
  rawBody: string
): Promise<boolean> {
  // Parse: "t=1739352941,sha256=7244dc6a..."
  // Payload: "<timestamp>.<raw_body>"
  // HMAC: crypto.subtle.sign("HMAC", key, messageData)
}
```

**Cambios:**
- ✅ Lee header `Swikly-Signature` (antes era `X-Api-Sig`)
- ✅ Formato: `t=<timestamp>,sha256=<hash>` (antes era solo hash)
- ✅ Usa Web Crypto API nativa en lugar de dependencia externa
- ✅ Construye payload como `timestamp.body` (antes era solo body)

---

#### **2.6 Actualizar mapeo de estados de webhook** (líneas 127-149)

**ANTES (API V1):**
```typescript
const swiklyEvent = payload.status; // "accepted", "released", etc.
const statusMap = { accepted: "accepted", released: "released", ... };
```

**DESPUÉS (API V2):**
```typescript
const requestStatus = payload.status; // "Pending", "Secured", "Canceled", "Expired"
const depositStatus = payload.deposit?.status; // "Pending", "Secured", "Released", "Canceled"

// Lógica mejorada:
if (requestStatus === "Secured" && depositStatus === "Secured") → "accepted"
if (requestStatus === "Canceled") → "cancelled"
if (requestStatus === "Expired") → "expired"
if (depositStatus === "Released") → "released"
```

---

## 🔧 Variables de Entorno Requeridas

### Cambios necesarios en `supabase/functions/.env`

```bash
# ❌ REMOVER
SWIKLY_SECRET_KEY=...

# ✅ AÑADIR / ACTUALIZAR
SWIKLY_API_TOKEN=eyJhbGciOi...              # Bearer token V2
SWIKLY_ACCOUNT_ID=A1B2C3D4-E5F6-...         # UUID de la cuenta
SWIKLY_WEBHOOK_SECRET=whsec_...             # Para verificar firmas de webhooks
SWIKLY_ENV=sandbox                           # o "production"
```

---

## 📊 Comparativa: V1 vs V2

| Aspecto | V1 Legacy | V2 Actual |
|---|---|---|
| **Base URL** | `https://api.v2.swikly.com/v1` | `https://api.v2.swikly.com/v1` |
| **Auth** | `X-Api-Key` + `X-Api-Sig` (HMAC) | `Authorization: Bearer {token}` |
| **Endpoint** | `/wishes` | `/accounts/{id}/requests` |
| **Payload** | `wishee_*` fields | `firstName`, `lastName`, `email` |
| **Deposit** | Plano en root | Anidado en `deposit` object |
| **Response** | `id` / `wish_url` (inconsistente) | `id` / `shortLink.shortLink` (consistente) |
| **Webhook Header** | `X-Api-Sig` | `Swikly-Signature` |
| **Firma formato** | `hex_hash` | `t=timestamp,sha256=hash` |
| **Payload firma** | Body completo | `timestamp.body` |

---

## ✅ Checklist de Implementación

- [x] Actualizar autenticación (Bearer token)
- [x] Cambiar endpoint `/wishes` → `/accounts/{id}/requests`
- [x] Refactorizar payload (campos de depósito)
- [x] Adaptar parsing de respuesta (shortLink)
- [x] Migrar webhook (nueva firma V2)
- [x] Actualizar mapeo de estados
- [x] Mejorar logging con prefijo `[Swikly]`
- [x] Añadir `phoneNumber` al payload
- [x] Añadir `language: "es"` al payload
- [x] Mejorar parsing de nombres (firstName/lastName)
- [x] Documentar cambios

---

## 🧪 Testing Post-Migración

### 1. Verificar Edge Functions

```bash
# Local development
supabase functions deploy create-swikly-wish-shipment
supabase functions deploy swikly-webhook

# Ver logs
supabase functions logs create-swikly-wish-shipment
supabase functions logs swikly-webhook
```

### 2. Test Manual en Sandbox

```bash
# Ver credenciales del ambiente
supabase status

# Prueba: Crear envío para user3 con depósito Swikly
# El payload debe incluir:
# - language: "es"
# - phoneNumber: (si disponible)
# - deposit.amount en céntimos
# - callbacks.requestSecured con la URL correcta
```

### 3. Verificar Webhook

- ✅ Header `Swikly-Signature` presente
- ✅ Firma se verifica correctamente
- ✅ Shipment se actualiza con nuevo estado
- ✅ Email se envía al usuario

---

## 📝 Notas Importantes

1. **Removido import HMAC**: La dependencia `hmac` ya no es necesaria. Se usa Web Crypto API nativa de Deno.

2. **API V2 es más consistente**: Todos los campos tienen nombres claros y estructura predecible.

3. **Autenticación simplificada**: Bearer token es más seguro y estándar que HMAC con secreto en payload.

4. **Webhooks más seguros**: Firma incluye timestamp para prevenir replay attacks.

5. **Logging mejorado**: Todos los logs llevan prefijo `[Swikly]` para facilitar búsqueda.

---

## 🔍 Referencias

- **API V2 Docs:** https://api.v2.swikly.com/v1/docs
- **Especificación OpenAPI:** `docs/api-specs/swikly-openapi-v1.yaml`
- **Configuración Swikly:** `docs/SWIKLY_DEV_CONFIGURATION.md`
- **Detalle anterior (V1):** `docs/SWIKLY_WEBHOOK_SHIPMENTS_MIGRATION.md`

---

## 🚀 Próximos Pasos (Fase 3 - Opcional)

Si se desea mejorar aún más la estructura:

1. Añadir columnas `first_name` y `last_name` a tabla `users`
   - Evita parsing frágil de `full_name`
   - Útil para otros servicios

2. Crear tests E2E para flujo completo de depósitos

3. Implementar retry logic con exponential backoff en Edge Functions

4. Migrar a Swikly Cloud (si aplica)