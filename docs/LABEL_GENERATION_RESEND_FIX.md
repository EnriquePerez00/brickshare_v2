# Fix: Error 404 en Generación de Etiquetas Brickshare

## Problema

Al intentar generar etiquetas para envíos Brickshare, se producían dos errores:

1. **Error 404**: `POST http://localhost:54331/functions/v1/send-brickshare-qr-email 404 (Not Found)`
2. **Warning de Stripe**: `Stripe.js integrations must use HTTPS`

## Causa Raíz

### Error 404
La Edge Function `send-brickshare-qr-email` no estaba cargada con las variables de entorno correctas, específicamente faltaba la `RESEND_API_KEY` real.

En `supabase/.env` se encontraba un placeholder:
```bash
RESEND_API_KEY=re_placeholder_test_key
```

### Warning de Stripe
Este es un warning esperado en desarrollo local. Stripe requiere HTTPS en producción, pero en `localhost` este warning no impide la funcionalidad.

## Solución Implementada

### 1. Actualización de Variables de Entorno

Se actualizó `supabase/.env` con la API key real de Resend encontrada en `.env.develop`:

```bash
RESEND_API_KEY=re_SHuDbPYg_9xmaZExxHeH6uvdL8Nk1HjQn
```

### 2. Recarga de Edge Functions

Se reiniciaron las Edge Functions para cargar las nuevas variables de entorno:

```bash
supabase functions serve --env-file supabase/.env --no-verify-jwt
```

### 3. Verificación de Configuración

Se confirmó que la configuración de Supabase local está correcta:

```
Project URL: http://127.0.0.1:54331
Edge Functions: http://127.0.0.1:54331/functions/v1
```

## Archivo de Configuración Actualizado

**`supabase/.env`**:
```bash
# Edge Functions Environment Variables

# Supabase
SUPABASE_URL=http://127.0.0.1:54331
SUPABASE_SERVICE_ROLE_KEY=<your_service_role_key>

# Resend (Email Service) ✅ ACTUALIZADO
RESEND_API_KEY=re_SHuDbPYg_9xmaZExxHeH6uvdL8Nk1HjQn

# Stripe
STRIPE_SECRET_KEY=<your_stripe_secret_key>
STRIPE_WEBHOOK_SECRET=<your_webhook_secret>

# Correos API
CORREOS_CLIENT_ID=8f21043b027346faa6eb9582f2312fdd
CORREOS_CLIENT_SECRET=9d973F90ab294211B8B14723A6aC6128

# Brickset API
BRICKSET_API_KEY=3-Vz2Y-d9eO-WJojN

# Swikly (Garantías)
SWIKLY_API_KEY=placeholder_swikly_key
SWIKLY_WEBHOOK_SECRET=placeholder_swikly_webhook_secret

# App URL
APP_URL=http://localhost:5173
```

## Flujo Corregido

### Generación de Etiqueta Brickshare

1. **Usuario**: Admin hace clic en "Generar Etiqueta" para un envío Brickshare
2. **Frontend** (`LabelGeneration.tsx`):
   - Verifica si existe `delivery_qr_code`, si no lo genera
   - Llama a la Edge Function `send-brickshare-qr-email`
3. **Edge Function** (`send-brickshare-qr-email/index.ts`):
   - Lee `RESEND_API_KEY` desde variables de entorno ✅
   - Obtiene datos del shipment, usuario, set y PUDO
   - Genera código QR como imagen (usando QR Server API)
   - Envía email HTML con el QR embebido vía Resend ✅
4. **Resultado**: Usuario recibe email con QR para recoger el set

## Cómo Probar

### Prueba Manual

1. Asegúrate de que Supabase esté corriendo:
```bash
supabase status
```

2. Asegúrate de que las Edge Functions estén cargadas:
```bash
# Deberías ver:
# Serving functions on http://127.0.0.1:54331/functions/v1/<function-name>
```

3. En el navegador:
   - Ve a `/operations` como admin
   - Haz clic en "Generación de Etiquetas"
   - Selecciona un envío Brickshare pendiente
   - Haz clic en "Generar Etiqueta"

4. Verifica en la consola del navegador:
   - NO debe aparecer el error 404
   - Debe aparecer un toast de éxito: "Email con QR enviado al usuario"

### Prueba con Script

Ejecuta el script de prueba de emails QR:

```bash
npm run test:qr-email
```

## Warning de Stripe (No Crítico)

El warning `Stripe.js integrations must use HTTPS` es esperado en desarrollo local:

- **En desarrollo**: Puedes ignorarlo, Stripe funciona correctamente en `localhost`
- **En producción**: Vercel proporciona HTTPS automáticamente, por lo que no aparecerá

Si deseas eliminar el warning en desarrollo, puedes:

1. Configurar HTTPS local con `mkcert`
2. O simplemente ignorarlo (recomendado)

## Seguridad

- La API key de Resend está en `.env.local` y `supabase/.env` (ambos en `.gitignore`)
- **NUNCA** commitear estos archivos al repositorio
- En producción, usar variables de entorno de Vercel

## Referencias

- [Resend API Docs](https://resend.com/docs/api-reference/emails/send-email)
- [Supabase Edge Functions Environment Variables](https://supabase.com/docs/guides/functions/secrets)
- [QR Server API](https://goqr.me/api/)

---

**Fecha**: 25/03/2026  
**Autor**: Cline  
**Estado**: ✅ Resuelto