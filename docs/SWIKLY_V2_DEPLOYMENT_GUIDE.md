# 🚀 Guía de Despliegue: Swikly API V2

**Fecha:** 31 de Marzo de 2026  
**Componentes actualizados:** ✅ create-swikly-wish-shipment + swikly-webhook  
**Estado:** Listo para desplegar

---

## 📋 Cambios Implementados

### ✅ Fase 1: Quick Wins (Sin cambios BD)
- Añadir `phoneNumber` del usuario al payload
- Añadir `language: "es"` para emails en español
- Mejorar parsing de nombres (firstName/lastName)
- Mejorar logging con prefijo `[Swikly]`

### ✅ Fase 2: Migración a API V2
- ✅ Bearer token en lugar de HMAC
- ✅ Nuevo endpoint: `/accounts/{id}/requests`
- ✅ Estructura payload reorganizada
- ✅ Firma V2 en webhooks con timestamp
- ✅ Web Crypto API nativa (sin dependencias)

---

## 🔧 Configuración Previa

### 1. Actualizar Variables de Entorno

En `supabase/functions/.env`:

```bash
# ❌ REMOVER estas líneas:
SWIKLY_SECRET_KEY=...

# ✅ AÑADIR / ACTUALIZAR:
SWIKLY_API_TOKEN=eyJhbGciOi...                    # Bearer token V2
SWIKLY_ACCOUNT_ID=a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3  # UUID de tu cuenta
SWIKLY_WEBHOOK_SECRET=whsec_...                   # Para verificar firmas
SWIKLY_ENV=sandbox                                # o "production"
```

**Dónde obtener:**
1. **SWIKLY_API_TOKEN**: Panel Swikly → API Credentials → Token V2
2. **SWIKLY_ACCOUNT_ID**: Panel Swikly → Account Settings → ID
3. **SWIKLY_WEBHOOK_SECRET**: Panel Swikly → Webhooks → Signing Secret
4. **SWIKLY_ENV**: "sandbox" para desarrollo, "production" para producción

### 2. Verificar Configuración en supabase/config.toml

```toml
[env.local.functions."create-swikly-wish-shipment"]
jwt_secret = "super-secret-jwt-token-with-at-least-32-characters-long"

[env.local.functions."swikly-webhook"]
# Sin JWT required (webhook viene desde Swikly)
```

---

## 📦 Archivos Modificados

```
supabase/functions/
├── create-swikly-wish-shipment/index.ts  ← ACTUALIZADO (Fase 1 + 2)
└── swikly-webhook/index.ts               ← ACTUALIZADO (Fase 2)

docs/
├── SWIKLY_API_V2_MIGRATION.md           ← NUEVO (detalle técnico)
└── SWIKLY_V2_DEPLOYMENT_GUIDE.md        ← TÚ ESTÁS AQUÍ

scripts/
└── test-user3-swikly-v2.ts              ← NUEVO (script de prueba)
```

---

## 🏃 Despliegue

### Local Development

```bash
# 1. Iniciar Supabase local
supabase start

# 2. Verificar que las Edge Functions están activas
supabase functions deploy create-swikly-wish-shipment
supabase functions deploy swikly-webhook

# 3. Ver estado
supabase status

# 4. Ver logs en tiempo real
supabase functions logs create-swikly-wish-shipment --follow
supabase functions logs swikly-webhook --follow
```

### Production Deployment

```bash
# 1. Ensure variables are set in Supabase Cloud
# https://app.supabase.com/project/[PROJECT_ID]/settings/functions

# 2. Deploy from CLI
supabase functions deploy create-swikly-wish-shipment --project-ref [PROJECT_REF]
supabase functions deploy swikly-webhook --project-ref [PROJECT_REF]

# 3. Verify
supabase functions list --project-ref [PROJECT_REF]
```

---

## 🧪 Testing Post-Despliegue

### Test 1: Verificar user3 (Script)

```bash
# Ejecutar desde raíz del proyecto
deno run -A scripts/test-user3-swikly-v2.ts
```

**Output esperado:**
```
🔍 TEST: Verificar user3 con Swikly V2

✅ Encontrado: user3 (user3@example.com)
   - ID: 123e4567-e89b-12d3-a456-426614174000
   - Teléfono: +34612345678

✅ Encontrados 1 envío(s)

📫 Envío: ship_abc123
   Set: 75192
   Status: assigned
   Swikly Status: accepted
   Depósito: €79.99
   Set Name: Titanic
   PVP Release: 79.99
   ✅ Disponible para imprimir: SÍ

✅ ÉXITO: 1 envío(s) está(n) listo(s) para imprimir etiquetas
```

### Test 2: Verificar Edge Functions (Logs)

```bash
# Terminal 1: Watch logs
supabase functions logs create-swikly-wish-shipment --follow

# Terminal 2: Crear envío de prueba (desde admin panel o script)
```

**Logs esperados:**
```
[Swikly] Using sandbox environment: https://api.v2.sandbox.swikly.com/v1
[Swikly] Account ID: a1b2c3d4-e5f6-...
[Swikly] Fetching set data for set_ref: 75192
[Swikly] Set found: Titanic (75192), deposit: €79.99
[Swikly] Fetching user data for user_id: 123e4567...
[Swikly] User resolved: user3 (user3@example.com), phone: +34612345678
[Swikly] Sending request to API V2: https://api.v2.sandbox.swikly.com/v1/accounts/a1b2c3d4-e5f6-.../requests
[Swikly] Payload: firstName=user, lastName=3, email=user3@example.com, phone=+34612345678, language=es, deposit=€79.99
[Swikly] API Response (200): { "id": "req_xyz789", "status": "Pending", ... }
[Swikly] ✅ Request req_xyz789 created for shipment ship_abc123
```

### Test 3: Verificar Webhook

```bash
# Terminal 1: Watch webhook logs
supabase functions logs swikly-webhook --follow

# Terminal 2: Simular webhook desde Swikly o usar test endpoint
curl -X POST http://localhost:54321/functions/v1/swikly-webhook \
  -H "Content-Type: application/json" \
  -H "Swikly-Signature: t=1739352941,sha256=7244dc6a957d9583516a170ff07242499e58e74da34afd732a60f900e8e162e1" \
  -d '{"id":"req_xyz789","status":"Secured","deposit":{"status":"Secured"}}'
```

**Logs esperados:**
```
[Swikly Webhook] Received webhook, signature: t=1739352941,sha256=7244dc6...
[Swikly Webhook] Signature verification: ✅ Valid
[Swikly Webhook] ✅ Signature verified, processing payload
[Swikly Webhook] Request ID: req_xyz789, Request Status: Secured, Deposit Status: Secured
[Swikly Webhook] Deposit secured by user → 'accepted'
[Swikly Webhook] Looking for shipment with wish_id: req_xyz789
[Swikly Webhook] Found shipment ship_abc123 (current status: wish_created)
[Swikly Webhook] Updating shipment ship_abc123: wish_created → accepted
[Swikly Webhook] ✅ Updated shipment ship_abc123 to 'accepted'
[Swikly Webhook] Sending 'deposit accepted' email to user3@example.com
```

### Test 4: Verificar en Panel Admin

1. Ir a **Admin → Operations → Label Generation**
2. Buscar a **user3**
3. Ver que aparece el set asignado
4. Verificar que `swikly_status = "accepted"`
5. Poder descargar etiqueta

---

## ⚠️ Troubleshooting

### Problema: "No Swikly-Signature header found"

**Causa:** Webhook recibido sin firma  
**Solución:**
```bash
# Verificar que Swikly está configurado para enviar a:
https://your-project.supabase.co/functions/v1/swikly-webhook

# Verificar SWIKLY_WEBHOOK_SECRET en variables de entorno
echo $SWIKLY_WEBHOOK_SECRET
```

---

### Problema: "Invalid signature, rejecting"

**Causa:** Firma V2 no coincide  
**Solución:**
1. Verificar `SWIKLY_WEBHOOK_SECRET` correctamente copiada
2. Revisar que el payload no está siendo modificado
3. Comprobar que el timestamp es reciente

```bash
# Debug: Ver payload recibido
supabase functions logs swikly-webhook --follow
# Buscar: "[Swikly Webhook] Payload:" para ver el JSON completo
```

---

### Problema: "Swikly API error 401: Unauthorized"

**Causa:** Token de API inválido o expirado  
**Solución:**
```bash
# 1. Verificar token en Swikly panel
# 2. Regenerar si está expirado
# 3. Actualizar en supabase/functions/.env
# 4. Redeploy:

supabase functions deploy create-swikly-wish-shipment
```

---

### Problema: "Shipment not found for request_id"

**Causa:** El webhook llega antes que se cree el shipment  
**Solución:** Normal en desarrollo. El webhook será reintentado por Swikly en 24h. Para testing:
1. Crear shipment primero (admin panel)
2. Esperar a que se cree `swikly_wish_id`
3. Luego simular webhook

---

### Problema: "Set not found for set_ref"

**Causa:** Set no existe en BD  
**Solución:**
```bash
# Verificar sets disponibles
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres

SELECT set_ref, set_name, set_pvp_release 
FROM sets 
WHERE set_ref = '75192';
```

---

## 🔄 Rollback (si es necesario)

Si necesitas volver a la versión anterior (API V1):

```bash
# Restaurar versión anterior desde git
git checkout HEAD~1 -- supabase/functions/create-swikly-wish-shipment/index.ts
git checkout HEAD~1 -- supabase/functions/swikly-webhook/index.ts

# Actualizar variables de entorno
# SWIKLY_SECRET_KEY=... (volver a V1)
# Remover: SWIKLY_API_TOKEN

# Redeploy
supabase functions deploy create-swikly-wish-shipment
supabase functions deploy swikly-webhook
```

---

## 📊 Métricas de Éxito

Después del despliegue, verificar:

- ✅ **user3 puede ver sus sets en "Imprimir etiquetas"**
- ✅ **Logs muestran prefijo `[Swikly]` correctamente**
- ✅ **Webhooks se procesan sin errores de firma**
- ✅ **Depósitos cambian de estado `wish_created` → `accepted`**
- ✅ **Emails se envían cuando depósito es aceptado**
- ✅ **`phoneNumber` aparece en payload (si usuario tiene teléfono)**
- ✅ **`language: "es"` se envía siempre**

---

## 📞 Contacto & Support

Si encuentras problemas:

1. **Revisar logs:** `supabase functions logs [function-name]`
2. **Verificar env vars:** `supabase status`
3. **Consultar docs:** `docs/SWIKLY_API_V2_MIGRATION.md`
4. **Script de test:** `scripts/test-user3-swikly-v2.ts`

---

## 📝 Changelog

### v2.0 (31-03-2026)
- ✅ Migración API V1 → V2
- ✅ Bearer token authentication
- ✅ Nueva estructura payload
- ✅ Firma V2 en webhooks
- ✅ Web Crypto API nativa
- ✅ Campos `phoneNumber` + `language`
- ✅ Mejor logging

### v1.0 (Legacy)
- Autenticación HMAC
- Endpoint `/wishes`
- Estructura payload V1
- Firma `X-Api-Sig` header