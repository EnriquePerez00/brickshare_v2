# Configuración de Swikly para Desarrollo Local

## ⚠️ IMPORTANTE: Solo para Entorno de Desarrollo

Este documento describe la configuración de Swikly V2 API en **entorno sandbox** para desarrollo local.

---

## 📋 Variables de Entorno Configuradas

### Frontend (`apps/web/.env.local`)
```bash
VITE_SWIKLY_DEV_API_KEY=api-f6NBJGlRytWRZSPQAKydNsohrRK1AN8R0Tl1ZNZj87993c79
```

### Backend Edge Functions (`supabase/functions/.env`)
```bash
SWIKLY_API_TOKEN=api-f6NBJGlRytWRZSPQAKydNsohrRK1AN8R0Tl1ZNZj87993c79
SWIKLY_ACCOUNT_ID=your_sandbox_account_uuid_here
SWIKLY_WEBHOOK_SECRET=your_webhook_signing_secret_here
```

---

## 💳 Tarjeta de Test - Swikly Sandbox

Para realizar pruebas de depósitos de garantía en el entorno sandbox de Swikly, utiliza la siguiente tarjeta de test:

| Campo | Valor |
|---|---|
| **Número de Tarjeta** | `4970 1051 8181 8183` |
| **Fecha de Expiración** | `12/27` |
| **CVV** | `123` |
| **Tipo** | VISA |

### Comportamiento de la Tarjeta de Test

- ✅ La tarjeta **simula una autorización exitosa** en el sandbox
- ✅ **No se realiza cargo real** - solo simulación
- ✅ Permite probar el flujo completo de creación de garantías (wishes)
- ✅ Válida para todas las operaciones de test de Swikly V2 API

---

## 🔐 Endpoints de Swikly V2 API

### Sandbox (Desarrollo)
```
Base URL: https://api.v2.sandbox.swikly.com/v1
```

### Producción (NO usar en desarrollo local)
```
Base URL: https://api.v2.swikly.com/v1
```

---

## 🚀 Integración Activa

### Estado Actual
- ✅ **Bypass Swikly DESACTIVADO** en desarrollo
- ✅ La integración Swikly está **activa** en local
- ✅ Se realizan llamadas reales a Swikly Sandbox API

### Funciones Edge que Usan Swikly

1. **`create-swikly-wish-shipment`** - Crear garantía para un envío
2. **`swikly-webhook`** - Recibir eventos de Swikly (confirmaciones, cancelaciones)
3. **`swikly-manage-wish`** - Gestionar garantías existentes

---

## 📡 Webhooks de Swikly

Para que Swikly pueda enviar webhooks a tu entorno local, necesitas exponer tu Supabase local (puerto 54331) usando un túnel.

### Configuración de Túnel (ngrok/Grok)

**TODO: Documentar URL activa cuando se configure el túnel**

Ejemplo de comando ngrok:
```bash
ngrok http 54331
```

Una vez iniciado, la URL del webhook sería:
```
https://[tu-id-unico].ngrok.io/functions/v1/swikly-webhook
```

### Registrar Webhook en Swikly Dashboard

1. Accede al dashboard de Swikly Sandbox
2. Navega a **Settings > Webhooks**
3. Añade la URL del túnel: `https://[tu-id].ngrok.io/functions/v1/swikly-webhook`
4. Copia el **Webhook Secret** y actualízalo en `supabase/functions/.env`:
   ```bash
   SWIKLY_WEBHOOK_SECRET=your_actual_webhook_secret_here
   ```

---

## 🧪 Testing Local

### 1. Verificar Variables de Entorno
```bash
# Verificar frontend
cat apps/web/.env.local | grep SWIKLY

# Verificar edge functions
cat supabase/functions/.env | grep SWIKLY
```

### 2. Probar Creación de Garantía
```bash
# Iniciar Supabase local
supabase start

# Ejecutar función de test
supabase functions serve create-swikly-wish-shipment
```

### 3. Usar la Tarjeta de Test
- Crear un envío desde el panel de admin
- Introducir la tarjeta `4970 1051 8181 8183`
- Verificar que se crea la garantía en Swikly

---

## 🔍 Logs y Debugging

### Ver Logs de Edge Functions
```bash
supabase functions logs create-swikly-wish-shipment
supabase functions logs swikly-webhook
```

### Verificar Llamadas a Swikly
Los logs mostrarán las requests/responses a la API de Swikly:
```
POST https://api.v2.sandbox.swikly.com/v1/wishes
Authorization: Bearer api-f6NBJGlRytWRZSPQAKydNsohrRK1AN8R0Tl1ZNZj87993c79
```

---

## ⚠️ Notas de Seguridad

1. **NUNCA** commitear las claves reales de producción
2. Las claves sandbox están **diseñadas para desarrollo** y no tienen acceso a datos reales
3. La tarjeta de test **NO es una tarjeta bancaria real**
4. El puerto 54331 **solo debe estar expuesto vía túnel** durante desarrollo activo
5. **Cerrar el túnel ngrok** cuando no estés desarrollando

---

## 📚 Referencias

- [Swikly V2 API Documentation](../docs/api-specs/SWIKLY_API.md)
- [Swikly Webhook Integration](../docs/SWIKLY_WEBHOOK_SHIPMENTS_MIGRATION.md)
- [Local Development Guide](./LOCAL_DEVELOPMENT.md)

---

**Última actualización:** 31/03/2026
**Entorno:** Local Development (Sandbox)
**Puerto Supabase:** 54331