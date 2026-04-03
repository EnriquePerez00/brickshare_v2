# 🚀 Manual de Despliegue Manual a Supabase Cloud

**Proyecto Cloud**: `tevoogkifiszfontzkgd.supabase.co`
**Generado**: 29/03/2026

---

## 📋 Estado Actual

### ✅ Completado
- [x] Backup SQL de BD local: `/tmp/brickshare_backup.sql` (4126 líneas)
- [x] Credenciales cloud obtenidas y almacenadas
- [x] `.env.production` creado (GITIGNORED)
- [x] `.gitignore` actualizado
- [x] Documentación preparada

### ⏳ Pendiente (Pasos Manuales)
- [ ] Aplicar migraciones SQL al cloud
- [ ] Desplegar 19 Edge Functions
- [ ] Configurar secrets en dashboard
- [ ] Actualizar webhooks (Stripe, Swikly)
- [ ] Desplegar a Vercel

---

## 🔧 PASO 1: Aplicar Migraciones SQL

### 1.1 Acceder al SQL Editor
```
https://app.supabase.com/project/tevoogkifiszfontzkgd/sql/new
```

### 1.2 Copiar el backup SQL
```bash
cat /tmp/brickshare_backup.sql
```

### 1.3 Pegar y ejecutar
1. Abrir el SQL Editor en el link anterior
2. Copiar TODO el contenido de `/tmp/brickshare_backup.sql`
3. Pegarlo en el editor
4. Hacer clic en el botón azul "Run"
5. Esperar a que complete (debería mostrar "✓ Executed successfully")

**Contenido a ejecutar**: 4126 líneas con:
- Schemas y tipos (app_role, operation_type, shipment_status, etc)
- Tablas: users, sets, inventory_sets, shipments, user_roles, etc
- Funciones RPC: preview_assign_sets_to_users, confirm_assign_sets_to_users, etc
- Triggers: actualizaciones automáticas en shipments, inventory, etc
- Políticas RLS: seguridad por usuario y rol

---

## 🔌 PASO 2: Desplegar Edge Functions

**Limitación**: La CLI de Supabase tiene un problema de autenticación. Usar método manual.

### 2.1 Acceder al Dashboard de Functions
```
https://app.supabase.com/project/tevoogkifiszfontzkgd/functions
```

### 2.2 Crear cada función manualmente

**Funciones a desplegar** (19 total):

| # | Función | Propósito |
|---|---------|----------|
| 1 | `brickshare-qr-api` | API para validar QR en entregas/devoluciones |
| 2 | `change-subscription` | Cambiar/cancelar suscripción |
| 3 | `correos-logistics` | Crear envíos con Correos |
| 4 | `correos-pudo` | Consultar puntos PUDO de Correos |
| 5 | `create-checkout-session` | Iniciar sesión de checkout Stripe |
| 6 | `create-logistics-package` | Crear paquete logístico |
| 7 | `create-subscription-intent` | Iniciar suscripción |
| 8 | `create-swikly-wish-shipment` | Crear garantía Swikly en shipment |
| 9 | `create-swikly-wish` | Crear garantía Swikly |
| 10 | `delete-user` | Eliminar cuenta usuario |
| 11 | `fetch-lego-data` | Enriquecer datos de sets LEGO |
| 12 | `process-assignment-payment` | Procesar pago de asignación |
| 13 | `send-brickshare-qr-email` | Email con QR de entrega/devolución |
| 14 | `send-email` | Enviar emails via Resend |
| 15 | `stripe-webhook` | Webhook de Stripe (eventos de pago) |
| 16 | `submit-donation` | Registrar donaciones LEGO |
| 17 | `swikly-manage-wish` | Gestionar garantías Swikly |
| 18 | `swikly-webhook` | Webhook de Swikly (eventos de garantía) |
| 19 | `update-shipment` | Actualizar estado de shipment |

**Para cada función**:

1. Clic en "Create a new function"
2. Darle el nombre (sin el prefijo "supabase_functions_")
3. Copiar el código de `supabase/functions/<nombre>/index.ts`
4. Pegar en el editor
5. Clic en "Deploy"

**Ejemplo**:
```
Función: brickshare-qr-api
Copiar desde: supabase/functions/brickshare-qr-api/index.ts
Nombre en dashboard: brickshare-qr-api
```

---

## 🔐 PASO 3: Configurar Secrets

**Ubicación**: Dashboard → Edge Functions → Settings → Secrets

### 3.1 Variables a añadir

```
SUPABASE_SERVICE_ROLE_KEY
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRldm9vZ2tpZmlzemZvbnR6a2dkIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2ODc0MzgzMCwiZXhwIjoyMDg0MzE5ODMwfQ.CpF9LjQjRxxIh5ZFpzL21dY19CWsBT7SFMp97Vy1BG0

STRIPE_SECRET_KEY
sk_test_... (obtener del dashboard Stripe)

STRIPE_WEBHOOK_SECRET
whsec_... (obtener de Webhooks en Stripe)

RESEND_API_KEY
re_... (obtener del dashboard Resend)

CORREOS_API_USER
... (usuario API Correos)

CORREOS_API_PASSWORD
... (contraseña API Correos)

CORREOS_SENDER_CODE
... (código de remitente Correos)
```

**Pasos**:
1. Ir a Settings → Secrets
2. Hacer clic en "Add secret"
3. Pegar nombre exacto (key)
4. Pegar valor (value)
5. Repetir para cada uno
6. Clic en "Save"

---

## 🪝 PASO 4: Configurar Webhooks

### 4.1 Stripe Webhook

**En dashboard Stripe**:
1. Ir a Developers → Webhooks
2. Clic en "Add endpoint"
3. URL: `https://tevoogkifiszfontzkgd.supabase.co/functions/v1/stripe-webhook`
4. Eventos: `payment_intent.succeeded`, `customer.subscription.updated`, `customer.subscription.deleted`
5. Clic en "Add endpoint"
6. Copiar "Signing secret"
7. Actualizar `STRIPE_WEBHOOK_SECRET` en Supabase

### 4.2 Swikly Webhook

**En dashboard Swikly**:
1. Settings → Webhooks
2. URL: `https://tevoogkifiszfontzkgd.supabase.co/functions/v1/swikly-webhook`
3. Eventos: `wish.created`, `wish.updated`, `wish.expired`
4. Guardar

---

## 📱 PASO 5: Configurar Variables en Vercel

### 5.1 Preparar variables

En Vercel, ir a Project Settings → Environment Variables y añadir:

```
VITE_SUPABASE_URL
https://tevoogkifiszfontzkgd.supabase.co

VITE_SUPABASE_ANON_KEY
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRldm9vZ2tpZmlzemZvbnR6a2dkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg3NDM4MzAsImV4cCI6MjA4NDMxOTgzMH0.LtlL5AGwpn8TsBB8iqWYpX1KMaqTxgh13pC1L3cw6Is

VITE_STRIPE_PUBLISHABLE_KEY
pk_test_... (obtener del dashboard Stripe)

VITE_APP_URL
https://brickshare.vercel.app (o tu dominio)

VITE_ENVIRONMENT
production
```

### 5.2 Hacer deploy

```bash
git push origin develop
# (o main, según tu rama)
# Vercel desplegará automáticamente
```

---

## ✅ Checklist de Verificación

Una vez completados todos los pasos:

### Base de Datos
- [ ] SQL backup ejecutado sin errores
- [ ] Tablas visibles en SQL Editor
- [ ] Funciones RPC disponibles
- [ ] Políticas RLS activas

### Edge Functions
- [ ] 19 funciones desplegadas
- [ ] Logs sin errores en Dashboard
- [ ] Secrets configurados
- [ ] Webhooks recibiendo eventos

### Frontend
- [ ] Variables de entorno en Vercel
- [ ] Deploy exitoso en Vercel
- [ ] App cargando desde VITE_SUPABASE_URL
- [ ] Auth funcionando (login/signup)
- [ ] Catálogo visible
- [ ] Suscripciones procesándose

### Proveedores
- [ ] Stripe webhook activo (endpoint verde)
- [ ] Swikly webhook activo
- [ ] Resend enviando emails
- [ ] Correos API respondiendo

---

## 🆘 Troubleshooting

### Error: "Connection refused" en frontend
**Causa**: Frontend intenta conectar a localhost en lugar de cloud
**Solución**: Verificar `VITE_SUPABASE_URL` en Vercel apunta a `https://tevoogkifiszfontzkgd.supabase.co`

### Error: "RLS policy violation"
**Causa**: Usuario no autenticado o sin permisos
**Solución**: Verificar que usuario está logueado y tiene rol asignado

### Error: "Function not found" en Edge Functions
**Causa**: Función no desplegada
**Solución**: Verificar que función aparece en dashboard y está "active"

### Error: "Unauthorized" en webhook
**Causa**: Secret incorrecto
**Solución**: Verificar que `STRIPE_WEBHOOK_SECRET` / `SWIKLY_SECRET` son exactos

### Error: "Email not sent"
**Causa**: RESEND_API_KEY incorrecto o no en Secrets
**Solución**: Verificar key en Supabase Secrets y en Resend dashboard

---

## 📚 Referencias

- [Dashboard Supabase](https://app.supabase.com/project/tevoogkifiszfontzkgd)
- [Documentación Técnica](./CLOUD_MIGRATION_GUIDE.md)
- [Schema BD](./DATABASE_SCHEMA.md)
- [API Reference](./API_REFERENCE.md)

---

## 📝 Archivo de Backup SQL

Ubicación: `/tmp/brickshare_backup.sql`
Tamaño: 4126 líneas
Contenido:
- Schemas públicos y privados
- Tipos custom (app_role, operation_type, etc)
- 28 tablas principales
- 15+ funciones RPC
- Triggers para lógica de negocio
- Políticas RLS para seguridad

---

## 🔐 Archivo .env.production

Ubicación: `/Users/I764690/Code_personal/Brickshare/.env.production`
**GITIGNORED**: No se commitea al repositorio
Contenido:
```
VITE_SUPABASE_URL=https://tevoogkifiszfontzkgd.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGc...
VITE_STRIPE_PUBLISHABLE_KEY=pk_test_...
VITE_APP_URL=https://brickshare.vercel.app
VITE_ENVIRONMENT=production
```

---

**Estado**: 🟡 Pasos manuales pendientes
**Última actualización**: 29/03/2026
**Proyecto Cloud**: tevoogkifiszfontzkgd.supabase.co