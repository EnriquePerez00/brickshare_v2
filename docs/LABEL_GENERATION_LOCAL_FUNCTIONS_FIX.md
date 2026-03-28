# Fix: Generación de Etiquetas - Edge Functions Locales

## 📋 Problema

Al intentar generar etiquetas después de asignar un set a un usuario, se producía un error 404:

```
POST http://localhost:54331/functions/v1/send-brickshare-qr-email 404 (Not Found)
```

## 🔍 Diagnóstico

El problema tenía dos causas relacionadas:

1. **Despliegue accidental en cloud**: Durante el diagnóstico inicial, se desplegó `send-brickshare-qr-email` en Supabase Cloud (proyecto `tevoogkifiszfontzkgd`) usando `supabase functions deploy`
2. **Edge Functions no servidas localmente**: En Supabase local, las Edge Functions del directorio `supabase/functions/` no se estaban sirviendo automáticamente

## ✅ Solución

### Entender el Modelo de Edge Functions en Supabase

**Supabase Cloud:**
- Requiere desplegar funciones explícitamente con `supabase functions deploy <nombre>`
- Las funciones se despliegan a un proyecto específico en la nube

**Supabase Local:**
- Las funciones en `supabase/functions/` deben **servirse explícitamente** con `supabase functions serve`
- NO se despliegan - se ejecutan directamente desde el código fuente local

### Comando para Servir Edge Functions Localmente

```bash
# Servir una función específica
supabase functions serve send-brickshare-qr-email --env-file supabase/.env --no-verify-jwt &

# O servir TODAS las funciones (recomendado para desarrollo)
supabase functions serve --env-file supabase/.env --no-verify-jwt &
```

**Flags importantes:**
- `--env-file supabase/.env`: Carga las variables de entorno necesarias (RESEND_API_KEY, STRIPE_SECRET_KEY, etc.)
- `--no-verify-jwt`: Desactiva la verificación JWT (seguro solo en local)
- `&`: Ejecuta en segundo plano

### Verificar que las Funciones Están Sirviendo

```bash
# Ver logs y confirmar que las funciones están disponibles
# Deberías ver algo como:
# Serving functions on http://127.0.0.1:54331/functions/v1/<function-name>
# - http://127.0.0.1:54331/functions/v1/send-brickshare-qr-email
# - http://127.0.0.1:54331/functions/v1/correos-logistics
# ... y más funciones
```

### Configuración de Variables de Entorno

Asegúrate de que `supabase/.env` contiene todas las claves necesarias:

```bash
# Edge Functions Environment Variables
SUPABASE_URL=http://127.0.0.1:54331
SUPABASE_SERVICE_ROLE_KEY=<tu_service_role_key>

# Resend (Email Service)
RESEND_API_KEY=re_xxxxx

# Stripe
STRIPE_SECRET_KEY=<your_stripe_secret_key>
STRIPE_WEBHOOK_SECRET=<your_webhook_secret>

# Correos API
CORREOS_CLIENT_ID=xxxxx
CORREOS_CLIENT_SECRET=xxxxx

# Otros servicios...
```

## 🎯 Flujo Completo de Desarrollo Local

### 1. Iniciar Supabase Local

```bash
supabase start
```

### 2. Servir Edge Functions

```bash
supabase functions serve --env-file supabase/.env --no-verify-jwt &
```

### 3. Iniciar Frontend

```bash
npm run dev
```

### 4. Verificar Configuración

```bash
# .env.local debe apuntar a local
VITE_SUPABASE_URL=http://127.0.0.1:54331
VITE_SUPABASE_ANON_KEY=<anon_key_local>
```

## 🚀 Testing

Ahora la generación de etiquetas debería funcionar correctamente:

1. Ve a **Operaciones → Asignación de Sets**
2. Asigna un set a un usuario
3. Ve a **Operaciones → Generar Etiquetas**
4. Selecciona el envío y genera la etiqueta
5. Deberías ver el código QR generado
6. El email con el QR se enviará a través de Resend (o se capturará en Mailpit si está configurado)

## 📝 Notas Importantes

### ⚠️ Diferencias Cloud vs Local

| Aspecto | Cloud | Local |
|---------|-------|-------|
| **Deploy** | `supabase functions deploy <nombre>` | No necesario |
| **Servir** | Automático después del deploy | `supabase functions serve` |
| **Variables ENV** | Se configuran en el dashboard | Archivo `supabase/.env` |
| **Hot Reload** | No | Sí (detecta cambios automáticamente) |

### ⚠️ Variables ENV Filtradas

Supabase filtra automáticamente variables que empiezan con `SUPABASE_`:

```
Env name cannot start with SUPABASE_, skipping: SUPABASE_SERVICE_ROLE_KEY
Env name cannot start with SUPABASE_, skipping: SUPABASE_URL
```

Esto es **normal y esperado**. Supabase inyecta automáticamente estas variables internamente.

### ⚠️ Funciones Faltantes

Si ves advertencias como:

```
WARN: failed to read file: open /Users/.../supabase/functions/brickman-chat/index.ts: no such file or directory
```

Significa que hay referencias a funciones que no existen. Puedes ignorar estas advertencias o limpiar las referencias si no las necesitas.

## 🔧 Troubleshooting

### Problema: 404 en Edge Function

**Causa**: Las Edge Functions no están sirviendo
**Solución**: Ejecutar `supabase functions serve --env-file supabase/.env --no-verify-jwt &`

### Problema: 500 Internal Server Error en la función

**Causa**: Falta alguna variable de entorno (ej: `RESEND_API_KEY`)
**Solución**: Verificar que `supabase/.env` tiene todas las claves necesarias

### Problema: La función no detecta cambios

**Causa**: El proceso de `functions serve` está cacheando
**Solución**: 
```bash
# Matar el proceso
pkill -f "supabase functions serve"

# Reiniciar
supabase functions serve --env-file supabase/.env --no-verify-jwt &
```

## 📚 Referencias

- [Supabase Edge Functions Local Development](https://supabase.com/docs/guides/functions/local-development)
- [Edge Functions Environment Variables](https://supabase.com/docs/guides/functions/secrets)
- [LABEL_GENERATION_FEATURE.md](./LABEL_GENERATION_FEATURE.md)
- [EDGE_FUNCTIONS_ENV_SETUP.md](./EDGE_FUNCTIONS_ENV_SETUP.md)

## ✅ Checklist de Verificación

- [ ] Supabase local está corriendo (`supabase status`)
- [ ] Edge Functions están sirviendo (`supabase functions serve`)
- [ ] `.env.local` apunta a local (puerto 54331)
- [ ] `supabase/.env` tiene todas las claves necesarias
- [ ] Frontend está corriendo (`npm run dev`)
- [ ] La generación de etiquetas funciona sin error 404

---

**Fecha**: 25 de marzo de 2026
**Versión**: 1.0
**Estado**: ✅ Resuelto