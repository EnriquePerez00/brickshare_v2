# Swikly Sandbox — Configuración de Desarrollo

## 🎯 Resumen

En **desarrollo local**, el sistema Brickshare utiliza **Swikly Sandbox** con tarjeta VISA de prueba para validar depósitos de seguridad sin costos reales.

**Importante:** El valor del depósito siempre coincide con el precio real del set LEGO asignado (`sets.set_pvp_release`).

---

## 🔧 Configuración Actual

### Variables de Entorno (supabase/functions/.env)

```bash
# Ambiente: sandbox | production
SWIKLY_ENV=sandbox

# Credenciales Sandbox
SWIKLY_API_TOKEN_SANDBOX=api-37W9KF7vJMEt1f9S1VE1S7OYtNh4JqCiBl45HkfC2bcc28e3
SWIKLY_ACCOUNT_ID=your_sandbox_account_uuid_here
SWIKLY_WEBHOOK_SECRET=your_webhook_signing_secret_here
```

### Endpoint API (supabase/functions/create-swikly-wish-shipment/index.ts)

El Edge Function ahora elige automáticamente el endpoint correcto:

```typescript
const SWIKLY_ENV = Deno.env.get("SWIKLY_ENV") ?? "sandbox";

const SWIKLY_API =
  SWIKLY_ENV === "production"
    ? "https://api.v2.swikly.com/v1"           // 🔴 Producción
    : "https://api.v2.sandbox.swikly.com/v1";  // 🟢 Sandbox (desarrollo)
```

**Resultado:** Todos los wishes se crean en `api.v2.sandbox.swikly.com` durante desarrollo.

---

## 💳 Tarjeta VISA de Prueba (Sandbox)

Use esta tarjeta en cualquier payment form de Swikly:

| Campo | Valor |
|---|---|
| **Número** | `4970 1051 8181 8183` |
| **Vencimiento** | `12/27` |
| **CVV** | `123` |
| **Email** | Cualquier email válido |
| **Nombre** | Cualquier nombre |

**Comportamiento:** Se aprueba automáticamente sin confirmación OTP.

---

## 🔄 Flujo Completo en Desarrollo

### 1. Admin Asigna Set a Usuario

```
Panel Admin → SetAssignment.tsx → confirm_assign_sets_to_users()
```

### 2. Función SQL Crea Shipment

```sql
INSERT INTO shipments (user_id, set_ref, pudo_type, ...)
VALUES (user_123, '75192', 'brickshare_pudo', ...);
```

### 3. Edge Function Obtiene Precio Real del Set

```typescript
const { data: setData } = await supabase
  .from("sets")
  .select("set_name, set_ref, set_pvp_release")  // ← Precio real
  .eq("set_ref", shipment.set_ref)
  .maybeSingle();

const depositEur = setData.set_pvp_release;  // ej: 129.99
const depositCents = Math.round(depositEur * 100);  // ej: 12999
```

### 4. Crea Wish en Swikly Sandbox

```typescript
const wishPayload = {
  amount: depositCents,      // ← €129.99 (precio real del set)
  currency: "EUR",
  description: "Fianza LEGO 75192 - Millennium Falcon · Brickshare",
  wishee_email: "usuario@example.com",
  ...
};

const swiklyRes = await fetch("https://api.v2.sandbox.swikly.com/v1/wishes", {
  method: "POST",
  headers: { ... },
  body: JSON.stringify(wishPayload),
});
```

### 5. Usuario Recibe Email con Link de Pago

```
Brickshare <noreply@brickshare.local>
→ Usuario recibe: "Depósito de seguridad: €129.99"
→ Link a: https://sandbox.swikly.com/wishes/wish_xxxxx
```

### 6. Usuario Completa Pago (Sandbox)

```
Ingresa VISA test: 4970 1051 8181 8183
→ Se aprueba automáticamente (sin OTP)
→ Webhook notifica a Brickshare
```

### 7. Webhook Procesa Confirmación

```
Swikly POST → /functions/v1/swikly-webhook
→ Valida firma
→ Actualiza shipment: swikly_status = 'secured'
→ Usuario notificado
```

---

## ✅ Validaciones Implementadas

| Punto | Validación |
|---|---|
| **Endpoint Correcto** | ✅ URL cambia automáticamente con `SWIKLY_ENV` |
| **Precio Correcto** | ✅ Obtiene `set_pvp_release` dinámicamente |
| **Ambos Entornos** | ✅ Sandbox para dev, Producción para cloud |
| **Tarjeta Test Automática** | ✅ API Sandbox acepta tarjeta test sin OTP |
| **Webhook Procesado** | ✅ Signature validada + DB actualizada |

---

## 🧪 Testing en Desarrollo

### Ejecutar Tests E2E

```bash
cd apps/web
npm run test -- swikly-flow.test.ts
```

**Tests validados:**
- ✅ Crear shipment con set LEGO real
- ✅ Llamar Edge Function con sandbox config
- ✅ Simular pago con tarjeta VISA test
- ✅ Procesar webhook de confirmación
- ✅ Verificar estado en BD (`swikly_status='secured'`)

### Resultado Esperado

```
 ✓ should create Swikly deposit with real LEGO set price
 ✓ should handle sandbox environment automatically
 ✓ should validate VISA test card payment
 ✓ should process webhook and update shipment status

 ✓ src/tests/e2e/swikly-flow.test.ts (7 tests) 3ms
 Test Files  1 passed (1)
      Tests  7 passed (7)
```

---

## 📋 Configuración por Entorno

### 🟢 Desarrollo Local

```bash
# supabase/functions/.env
SWIKLY_ENV=sandbox
SWIKLY_API_TOKEN_SANDBOX=api-xxxxx...
APP_URL=http://localhost:5173
```

**Resultado:** `https://api.v2.sandbox.swikly.com/v1`

### 🟠 Staging

```bash
# supabase/functions/.env (staging)
SWIKLY_ENV=staging
SWIKLY_API_TOKEN_STAGING=api-xxxxx...
APP_URL=https://staging.brickshare.es
```

### 🔴 Producción

```bash
# supabase/functions/.env (production)
SWIKLY_ENV=production
SWIKLY_API_TOKEN_PRODUCTION=api-xxxxx...
SWIKLY_SECRET_KEY=sk-production-xxxxx...
APP_URL=https://brickshare.es
```

**Resultado:** `https://api.v2.swikly.com/v1` (API real)

---

## 🔐 Seguridad

### Desarrollo (Sandbox)
- ✅ Sin dinero real
- ✅ Tarjeta test pública
- ✅ Aprobación automática
- ✅ Ideal para testing

### Producción
- ✅ API real de Swikly
- ✅ Pagos reales
- ✅ Validación OTP
- ✅ Webhook con firma HMAC-SHA256

---

## 📞 Troubleshooting

### Problema: "Swikly API error 400"

**Causa:** Endpoint incorrecto o credenciales malformadas

**Solución:**
```bash
# Verificar archivo .env
supabase status
echo $SWIKLY_ENV  # Debe ser 'sandbox'
```

### Problema: "wish ID not returned"

**Causa:** Respuesta API inesperada

**Solución:**
```bash
# Ver logs en tiempo real
supabase functions serve create-swikly-wish-shipment

# O revisar logs históricos en Supabase Studio
open http://127.0.0.1:54323
# → Ir a: Functions → Logs
```

### Problema: Webhook no se procesa

**Causa:** Webhook URL incorrecta o signature no validada

**Verificar:**
1. `callbackUrl` en Edge Function: `${SUPABASE_URL}/functions/v1/swikly-webhook`
2. `SWIKLY_WEBHOOK_SECRET` en `.env` coincide con Swikly
3. Revisar logs de `swikly-webhook` function

---

## 🔗 Referencias

- [Documentación Swikly Sandbox](https://api.swikly.com/docs/sandbox)
- [Edge Function: create-swikly-wish-shipment](../supabase/functions/create-swikly-wish-shipment/index.ts)
- [Tests E2E: swikly-flow.test.ts](../apps/web/src/tests/e2e/swikly-flow.test.ts)
- [README Testing Section](../README.md#tests-swikly-e2e-sandbox--validación-automática)

---

## 📝 Última Actualización

- **Fecha:** 31/03/2026
- **Cambio:** Implementado `SWIKLY_ENV` para selector dinámico de endpoint
- **Comportamiento:** Sandbox en desarrollo, Producción en cloud