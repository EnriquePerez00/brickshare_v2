# Edge Functions Environment Setup

## Descripción

Este documento explica la configuración de variables de entorno para las Edge Functions de Supabase en desarrollo local.

## Archivo de Configuración

**Ubicación**: `supabase/.env`

Este archivo contiene las variables de entorno necesarias para que las Edge Functions locales funcionen correctamente. El archivo está en `.gitignore` para evitar commitear credenciales sensibles.

## Variables Requeridas

### Supabase
```bash
SUPABASE_URL=http://127.0.0.1:54331
SUPABASE_SERVICE_ROLE_KEY=<obtener de supabase status>
```

### Resend (Email Service)
```bash
RESEND_API_KEY=<tu_api_key_de_resend>
```

Para desarrollo local, tienes dos opciones:
1. **Usar una API key real de Resend** (modo test): Crea una cuenta en https://resend.com y obtén una API key de test
2. **Usar Mailpit**: Instala Mailpit localmente para capturar emails sin enviarlos realmente

### Stripe
```bash
STRIPE_SECRET_KEY=<your_stripe_secret_key>...
STRIPE_WEBHOOK_SECRET=<your_webhook_secret>...
```

### Correos API
```bash
CORREOS_CLIENT_ID=<tu_client_id>
CORREOS_CLIENT_SECRET=<tu_client_secret>
```

### Brickset API
```bash
BRICKSET_API_KEY=<tu_api_key>
```

### Swikly (Garantías)
```bash
SWIKLY_API_KEY=<tu_api_key>
SWIKLY_WEBHOOK_SECRET=<tu_webhook_secret>
```

### App URL
```bash
APP_URL=http://localhost:5173
```

## Setup Inicial

1. Copia el archivo de ejemplo:
```bash
cp supabase/.env.example supabase/.env
```

2. Edita `supabase/.env` y añade tus credenciales

3. Reinicia las Edge Functions para cargar las nuevas variables:
```bash
pkill -f "supabase functions serve"
supabase functions serve --no-verify-jwt &
```

## Verificación

Para verificar que las Edge Functions están cargando las variables correctamente:

```bash
# Ver el log de las funciones
tail -f /tmp/supabase-functions.log

# Las funciones deberían estar disponibles en:
# http://127.0.0.1:54331/functions/v1/<function-name>
```

## Troubleshooting

### Error: "RESEND_API_KEY is not defined"

Si ves este error, significa que:
1. El archivo `supabase/.env` no existe
2. Las Edge Functions no se reiniciaron después de crear el archivo
3. La variable no está correctamente definida en el archivo

**Solución**:
```bash
# Verificar que el archivo existe y tiene el contenido correcto
cat supabase/.env | grep RESEND_API_KEY

# Reiniciar las Edge Functions
pkill -f "supabase functions serve"
supabase functions serve --no-verify-jwt > /tmp/supabase-functions.log 2>&1 &
```

### Las Edge Functions no cargan las variables

Las variables de entorno se cargan cuando se inicia `supabase functions serve`. Si modificas `supabase/.env`, debes reiniciar el servicio.

## Notas de Seguridad

- ⚠️ **NUNCA** commitees `supabase/.env` al repositorio
- El archivo está incluido en `.gitignore`
- Para producción, las variables se configuran en el dashboard de Supabase
- Las claves de desarrollo/test deben ser diferentes a las de producción

## Referencias

- [Supabase Edge Functions - Environment Variables](https://supabase.com/docs/guides/functions/secrets)
- [Resend - Getting Started](https://resend.com/docs/send-with-nodejs)
- [Stripe - API Keys](https://stripe.com/docs/keys)