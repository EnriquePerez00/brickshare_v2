# Resumen de Variables de Entorno - Brickshare

## 📋 Variables Configuradas

### Frontend (`apps/web/.env.local`)

```bash
# ═══════════════════════════════════════════════════════════════
# Local Development Environment Variables
# ═══════════════════════════════════════════════════════════════

# Supabase Configuration (Local Docker on port 54331)
VITE_SUPABASE_URL=http://127.0.0.1:54331
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU

# App Configuration
VITE_APP_URL=http://localhost:8080
BASE_URL=http://localhost:8080
PLAYWRIGHT_BASE_URL=http://localhost:8080

# Stripe Configuration (Test Mode)
VITE_STRIPE_PUBLISHABLE_KEY=pk_test_your_key_here

# Swikly Configuration (Sandbox Development)
VITE_SWIKLY_DEV_API_KEY=api-f6NBJGlRytWRZSPQAKydNsohrRK1AN8R0Tl1ZNZj87993c79

# Feature Flags
VITE_ENABLE_ANALYTICS=false
VITE_ENABLE_DEBUG=true
```

### Backend Edge Functions (`supabase/functions/.env`)

```bash
RESEND_API_KEY=re_test_local_development_key_123456
COSTE_ENVIO_DEVOLUCION=8

# Swikly V2 API — https://api.v2.sandbox.swikly.com/v1
SWIKLY_API_TOKEN=api-f6NBJGlRytWRZSPQAKydNsohrRK1AN8R0Tl1ZNZj87993c79
SWIKLY_ACCOUNT_ID=your_sandbox_account_uuid_here
SWIKLY_WEBHOOK_SECRET=your_webhook_signing_secret_here

APP_URL=http://localhost:5173
```

---

## 🔑 Credenciales de Test

### Swikly Sandbox - Tarjeta VISA de Prueba

```
Número: 4970 1051 8181 8183
Fecha:  12/27
CVV:    123
Tipo:   VISA
```

**Comportamiento**: 
- ✅ Simula autorización exitosa en sandbox
- ✅ NO realiza cargo real
- ✅ Válida para todas las operaciones de test

---

## 🌐 Configuración de Puertos

| Servicio | Puerto | URL/Endpoint |
|---|---|---|
| **PostgreSQL** | 54322 | `postgresql://postgres:postgres@127.0.0.1:54322/postgres` |
| **API REST** | **54331** | `http://127.0.0.1:54331` |
| **Supabase Studio** | 54323 | `http://127.0.0.1:54323` |
| **Frontend Dev** | 5173 | `http://localhost:5173` |
| **Frontend Build** | 8080 | `http://localhost:8080` |

⚠️ **Nota Importante**: Este proyecto usa el puerto **54331** para la API REST (no el estándar 54321).

---

## 🔐 APIs Externas Configuradas

### Swikly V2
- **Entorno**: Sandbox (Desarrollo)
- **Base URL**: `https://api.v2.sandbox.swikly.com/v1`
- **Estado**: ✅ Activo (bypass desactivado)
- **Documentación**: [SWIKLY_DEV_CONFIGURATION.md](./SWIKLY_DEV_CONFIGURATION.md)

### Stripe
- **Entorno**: Test Mode
- **Estado**: ⚠️ Pendiente de configurar claves reales

### Correos API
- **Estado**: ⚠️ Pendiente de configurar credenciales

### Resend (Email)
- **Estado**: ✅ Configurado con clave de test local

---

## 📡 Webhooks (Túnel ngrok)

Para recibir webhooks de servicios externos en tu entorno local:

### Configurar Túnel

```bash
# Instalar ngrok (si no está instalado)
brew install ngrok

# Exponer puerto de Supabase
ngrok http 54331
```

### URLs de Webhook

Una vez iniciado ngrok, obtendrás una URL como `https://abc123.ngrok.io`.

Configura los webhooks en los servicios externos:

| Servicio | Webhook URL |
|---|---|
| **Stripe** | `https://[tu-id].ngrok.io/functions/v1/stripe-webhook` |
| **Swikly** | `https://[tu-id].ngrok.io/functions/v1/swikly-webhook` |

⚠️ **Seguridad**: 
- Solo mantén el túnel activo durante desarrollo activo
- Cierra ngrok cuando no lo necesites
- NUNCA expongas datos de producción

**TODO**: Documentar URL activa de ngrok cuando se configure

---

## 🎯 Estados de Integración

| Integración | Estado | Notas |
|---|---|---|
| **Supabase Local** | ✅ Activo | Puerto 54331 |
| **Swikly Sandbox** | ✅ Activo | Bypass desactivado |
| **Stripe Test** | ⚠️ Parcial | Pendiente claves completas |
| **Correos API** | ⚠️ Pendiente | Sin configurar |
| **Webhooks (ngrok)** | ⚠️ Manual | Activar cuando sea necesario |

---

## 📚 Documentación Relacionada

- [LOCAL_DEVELOPMENT.md](./LOCAL_DEVELOPMENT.md) - Guía completa de desarrollo local
- [SWIKLY_DEV_CONFIGURATION.md](./SWIKLY_DEV_CONFIGURATION.md) - Configuración detallada de Swikly
- [.env.example](../.env.example) - Plantilla de variables de entorno
- [.clinerules](../.clinerules) - Reglas del proyecto para Cline

---

## ✅ Checklist de Configuración

- [x] Variables de entorno frontend configuradas
- [x] Variables de entorno backend configuradas
- [x] Swikly API key añadida
- [x] Bypass Swikly desactivado
- [x] Tarjeta de test documentada
- [x] Puerto 54331 documentado
- [ ] Configurar túnel ngrok (cuando sea necesario)
- [ ] Actualizar webhook URL en dashboard Swikly
- [ ] Completar configuración de Stripe
- [ ] Configurar Correos API

---

**Última actualización**: 31/03/2026  
**Entorno**: Desarrollo Local (Docker)  
**Puerto API**: 54331