# Resend Development Setup - Brickshare

## 📋 Variables de Entorno

### Configuration Variables

| Variable | Valor | Scope | Descripción |
|----------|-------|-------|---|
| `RESEND_API_KEY` | `a7937760-ab2b-47a1-9a95-746c7fa7ad63` | Dev | Test API key para sandbox |
| `RESEND_FROM_DOMAIN` | `brickclinic.eu` | Dev | Dominio remitente verificado |
| `RESEND_FROM_EMAIL` | `info@brickclinic.eu` | Dev | Email remitente (development) |
| `RESEND_DEVELOP_EMAIL` | `info@brickclinic.eu` | Dev | Alias para desarrollo |
| `RESEND_SANDBOX_RECIPIENT` | `enriqueperezbcn1973@gmail.com` | Dev | Solo recipient en sandbox |
| `PROD` | `false` (si no está definida) | Dev | Flag para detectar environment |

---

## 🔧 Ubicación de Variables

### `supabase/functions/.env` (Edge Functions)
Todas las variables Resend deben estar aquí para que las Edge Functions puedan acceder:

```bash
RESEND_API_KEY=a7937760-ab2b-47a1-9a95-746c7fa7ad63
RESEND_FROM_DOMAIN=brickclinic.eu
RESEND_FROM_EMAIL=info@brickclinic.eu
RESEND_SANDBOX_RECIPIENT=enriqueperezbcn1973@gmail.com
RESEND_DEVELOP_EMAIL=info@brickclinic.eu
```

---

## 📧 Edge Function: `send-brickshare-qr-email`

### Constantes Definidas

```typescript
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const FROM_DOMAIN = Deno.env.get("RESEND_FROM_DOMAIN") || "brickclinic.eu";
const FROM_EMAIL = Deno.env.get("RESEND_FROM_EMAIL") || "info@brickclinic.eu";
const SANDBOX_RECIPIENT = Deno.env.get("RESEND_SANDBOX_RECIPIENT") || "enriqueperezbcn1973@gmail.com";
const IS_DEVELOPMENT = !Deno.env.get("PROD");
```

### Comportamiento en Development

- ✅ **Todos los emails se envían desde**: `info@brickclinic.eu`
- ✅ **Todos los emails se reciben en**: `enriqueperezbcn1973@gmail.com` (sandbox)
- ✅ **No se usan los emails reales de usuarios** (protección en desarrollo)

### Formato del Email

```
From: Brickshare <info@brickclinic.eu>
To: enriqueperezbcn1973@gmail.com (in development)
```

---

## 🚀 Testing en Development

### 1. Verificar Variables

```bash
grep "RESEND" supabase/functions/.env
```

Debe mostrar:
```
RESEND_API_KEY=a7937760-ab2b-47a1-9a95-746c7fa7ad63
RESEND_FROM_DOMAIN=brickclinic.eu
RESEND_FROM_EMAIL=info@brickclinic.eu
RESEND_SANDBOX_RECIPIENT=enriqueperezbcn1973@gmail.com
RESEND_DEVELOP_EMAIL=info@brickclinic.eu
```

### 2. Reiniciar Supabase

```bash
supabase stop
supabase start
```

### 3. Generar Etiqueta (test end-to-end)

1. Admin Panel → Operations → Label Generation
2. Seleccionar shipment de un usuario de test
3. Click "Generar Etiqueta"
4. Verificar email en: `enriqueperezbcn1973@gmail.com`

### 4. Ver Logs de Edge Function

```bash
docker ps --filter "name=edge-runtime" -q | xargs -I {} docker logs {} --tail 100 | grep -A 10 "send-brickshare-qr-email"
```

---

## ⚠️ Troubleshooting

### Error 500 al generar etiqueta

**Verificar:**
1. ¿`supabase/functions/.env` tiene todas las variables?
2. ¿Se ejecutó `supabase stop && supabase start` después de cambiar .env?
3. ¿El `RESEND_API_KEY` es válido en Resend dashboard?

### Email no llegando

**Verificar:**
1. En desarrollo, **SIEMPRE** llega a `enriqueperezbcn1973@gmail.com`
2. Si no aparece, revisar bandeja de spam
3. Si no está en spam, revisar logs de Docker

### Variable `FROM_EMAIL` undefined

**Causa:** La Edge Function no tiene las constantes definidas
**Solución:** 
- Agregar líneas en el archivo (como se muestra arriba)
- Reiniciar Supabase
- Los fallbacks (`|| "info@brickclinic.eu"`) se activan si env vars no existen

---

## 🌍 Para Production

Cambiar a:
```bash
RESEND_API_KEY=re_XXXXXXXXXX  # Production key
RESEND_FROM_DOMAIN=brickshare.eu
RESEND_FROM_EMAIL=noreply@brickshare.eu
# Remover PROD=false (o establecer PROD=true)
# Remover fallback a sandbox recipient
```

---

**Last Updated**: 2026-01-04  
**Status**: ✅ Development Configuration  
**Tested**: ✅ Email delivery working