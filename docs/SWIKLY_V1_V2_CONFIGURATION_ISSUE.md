# 🔧 Problema: API Key V1 en API V2

**Fecha:** 31 de Marzo de 2026  
**Problema:** user3 no puede crear depósitos Swikly porque:
1. El ACCOUNT_ID está configurado como `your_sandbox_account_uuid_here` (inválido)
2. Las variables de entorno no coinciden (`.env` usa `SWIKLY_API_TOKEN_SANDBOX`, código espera `SWIKLY_API_TOKEN`)

---

## 🔍 Diagnóstico

### Estado Actual del `.env`

```bash
SWIKLY_API_TOKEN_SANDBOX=api-37W9KF7vJMEt1f9S1VE1S7OYtNh4JqCiBl45HkfC2bcc28e3
SWIKLY_ACCOUNT_ID=your_sandbox_account_uuid_here  # ❌ INVÁLIDO
SWIKLY_WEBHOOK_SECRET=your_webhook_signing_secret_here
```

### Problemas Identificados

1. **SWIKLY_ACCOUNT_ID inválido**
   - Actualmente: `your_sandbox_account_uuid_here`
   - Necesario: UUID válido de la cuenta Swikly (ej: `a1b2c3d4-e5f6-4g7h-8i9j-0k1l2m3n4o5p`)
   - Sin esto, la API V2 no puede procesar la solicitud

2. **Variables de entorno no coinciden**
   - `.env` tiene: `SWIKLY_API_TOKEN_SANDBOX`
   - Código espera: `SWIKLY_API_TOKEN`
   - **✅ SOLUCIONADO:** Ahora el código intenta ambas variables

3. **API Key del sandbox**
   - Token actual: `api-37W9KF7vJMEt1f9S1VE1S7OYtNh4JqCiBl45HkfC2bcc28e3`
   - Este es un token de V1 en formato válido
   - ✅ El código ahora lo acepta automáticamente de `SWIKLY_API_TOKEN_SANDBOX`

---

## ✅ Soluciones Aplicadas

### 1. Código Actualizado (`create-swikly-wish-shipment/index.ts`)

```typescript
// ✅ Ahora soporta ambas variables
const SWIKLY_API_TOKEN = Deno.env.get("SWIKLY_API_TOKEN") ?? 
                          Deno.env.get("SWIKLY_API_TOKEN_SANDBOX") ?? "";

// ✅ Validación mejorada antes de hacer la llamada
if (!SWIKLY_API_TOKEN) {
  throw new Error(
    "SWIKLY_API_TOKEN not configured. Set SWIKLY_API_TOKEN or SWIKLY_API_TOKEN_SANDBOX in environment"
  );
}

if (!SWIKLY_ACCOUNT_ID || SWIKLY_ACCOUNT_ID.includes("your_")) {
  throw new Error(
    `SWIKLY_ACCOUNT_ID not configured properly. Current value: "${SWIKLY_ACCOUNT_ID}". Please set a valid UUID.`
  );
}
```

### 2. Logging Mejorado

```typescript
console.log(`[Swikly] Account ID: ${SWIKLY_ACCOUNT_ID || "⚠️ NOT CONFIGURED"}`);
console.log(`[Swikly] API Token: ${SWIKLY_API_TOKEN ? "✓ Configured" : "❌ MISSING"}`);
```

---

## 🎯 Próximos Pasos

### 1. Obtener el ACCOUNT_ID Correcto

El `ACCOUNT_ID` es el identificador único de tu cuenta en Swikly. Para obtenerlo:

**Opción A: Panel de Swikly**
1. Ir a https://dashboard.swikly.com/
2. Dashboard → Settings / Configuración
3. Buscar "Account ID" o "Account UUID"
4. Copiar el UUID (formato: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`)

**Opción B: Llamada a API**
```bash
curl -H "Authorization: Bearer api-37W9KF7vJMEt1f9S1VE1S7OYtNh4JqCiBl45HkfC2bcc28e3" \
  https://api.v2.sandbox.swikly.com/v1/accounts
```

### 2. Actualizar el `.env`

```bash
# supabase/functions/.env

# ✅ ACTUALIZAR ESTO:
SWIKLY_ACCOUNT_ID=a1b2c3d4-e5f6-4g7h-8i9j-0k1l2m3n4o5p
```

### 3. Redeploy de Edge Functions

```bash
supabase functions deploy create-swikly-wish-shipment
supabase functions deploy swikly-webhook
```

### 4. Reintentar Asignación a user3

1. Panel Admin → Operations → Set Assignment
2. Seleccionar user3
3. Asignar set
4. Ver que el depósito Swikly se crea correctamente

---

## 📊 Flujo de Configuración

```
┌─────────────────────────────────────────────────────────┐
│  supabase/functions/.env                                │
├─────────────────────────────────────────────────────────┤
│  SWIKLY_API_TOKEN_SANDBOX=api-37W9KF7v...   ✓ OK       │
│  SWIKLY_ACCOUNT_ID=your_sandbox_...        ❌ FALTA    │
│  SWIKLY_WEBHOOK_SECRET=your_webhook_...    ⚠️ FALTA    │
└─────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│  create-swikly-wish-shipment/index.ts                   │
├─────────────────────────────────────────────────────────┤
│  ✓ Lee SWIKLY_API_TOKEN_SANDBOX                         │
│  ✓ Lee SWIKLY_ACCOUNT_ID                                │
│  ✓ Valida que no sean placeholders                      │
│  ✓ Hace llamada a API V2 de Swikly                      │
└─────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│  API V2 Swikly Sandbox                                  │
├─────────────────────────────────────────────────────────┤
│  POST /accounts/{ACCOUNT_ID}/requests                   │
│  Headers: Authorization: Bearer {API_TOKEN}             │
│  Body: deposit, firstName, lastName, email, phone       │
└─────────────────────────────────────────────────────────┘
```

---

## 🧪 Testing

### Test 1: Ver logs al crear depósito

```bash
# Terminal 1: Watch logs
supabase functions logs create-swikly-wish-shipment --follow

# Terminal 2: Crear un envío (admin panel)
# Admin → Operations → Set Assignment → user3
```

**Logs esperados con configuración correcta:**
```
[Swikly] Account ID: a1b2c3d4-e5f6-4g7h-8i9j-0k1l2m3n4o5p
[Swikly] API Token: ✓ Configured
[Swikly] Creating deposit request for shipment ship_xyz123
[Swikly] Sending request to API V2: https://api.v2.sandbox.swikly.com/v1/accounts/a1b2c3d4-e5f6-4g7h-8i9j-0k1l2m3n4o5p/requests
[Swikly] API Response (200): { "id": "req_xyz789", "status": "Pending", ... }
[Swikly] ✅ Request req_xyz789 created for shipment ship_xyz123
```

### Test 2: Con configuración incompleta

Si ACCOUNT_ID falta o es inválido:
```
[Swikly] Account ID: ⚠️ NOT CONFIGURED
[Swikly] [Swikly] ❌ Error: SWIKLY_ACCOUNT_ID not configured properly. 
Current value: "your_sandbox_account_uuid_here". 
Please set a valid UUID.
```

---

## 📝 Resumen

| Aspecto | Estado | Acción |
|---|---|---|
| API Key de sandbox | ✅ Válido | Ninguna (ya existe) |
| Soporte de ambas variables | ✅ Implementado | Ninguna |
| Validaciones mejoradas | ✅ Implementado | Ninguna |
| ACCOUNT_ID válido | ❌ Falta | **Obtener de Swikly y actualizar `.env`** |
| WEBHOOK_SECRET | ⚠️ Placeholder | **Obtener de Swikly y actualizar `.env`** |

---

## 🚀 Próxima Sesión

Una vez tengas el ACCOUNT_ID correcto:
1. Actualizar `supabase/functions/.env`
2. Ejecutar `supabase functions deploy create-swikly-wish-shipment`
3. Reintentar asignación a user3
4. Verificar en logs que Swikly responde con código 200