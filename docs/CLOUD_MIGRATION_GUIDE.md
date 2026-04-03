# 🚀 Guía de Migración a Supabase Cloud

## Estado: En Progreso
**Proyecto Cloud**: `tevoogkifiszfontzkgd.supabase.co`

---

## 📋 Resumen Ejecutivo

Esta guía documenta la migración de Brickshare desde **desarrollo local (Docker)** a **Supabase Cloud**.

| Componente | Local | Cloud |
|---|---|---|
| **Base de Datos** | PostgreSQL local (puerto 5433) | PostgreSQL cloud gerenciado |
| **Auth** | Supabase Auth local | Supabase Auth cloud |
| **Storage** | S3 local (Minio) | Supabase Storage cloud |
| **Edge Functions** | Deno local | Deno cloud |
| **API** | http://127.0.0.1:54331 | https://tevoogkifiszfontzkgd.supabase.co |

---

## ✅ Pasos Completados

- [x] **Autenticación CLI**: `supabase login` ejecutado
- [x] **Backup Local**: BD local respaldada en `/tmp/brickshare_backup.sql` (4126 líneas)
- [x] **Credenciales Cloud**: Obtenidas del dashboard
  - URL: `https://tevoogkifiszfontzkgd.supabase.co`
  - Anon Key: `eyJhbGc...`
  - Service Role: `eyJhbGc...`
- [x] **Archivo .env.production**: Creado con credenciales
- [x] **.gitignore**: Actualizado para proteger secretos

---

## ⏳ Pasos Pendientes

### 1️⃣ Aplicar Migraciones al Cloud (MANUAL)

Accede al [SQL Editor del Dashboard](https://app.supabase.com/project/tevoogkifiszfontzkgd/sql/new):

```bash
# Opción A: Copiar contenido del backup
cat /tmp/brickshare_backup.sql
# Luego pegarlo en el SQL Editor del dashboard y ejecutar

# Opción B: Usar el backup SQL directamente
# (el archivo está en /tmp/brickshare_backup.sql)
```

**Pasos**:
1. Ir a https://app.supabase.com/project/tevoogkifiszfontzkgd/sql/new
2. Copiar el contenido de `/tmp/brickshare_backup.sql`
3. Pegarlo en el editor
4. Hacer clic en "Run" (el botón azul)
5. Esperar a que complete (debería mostrar "✓ Executed successfully")

### 2️⃣ Configurar Edge Functions

Las Edge Functions necesitan ser desplegadas. Opciones:

#### Opción A: Desplegar vía Dashboard
1. Ir a https://app.supabase.com/project/tevoogkifiszfontzkgd/functions
2. Para cada función en `supabase/functions/`:
   - Crear nueva función
   - Copiar código de `supabase/functions/<name>/index.ts`
   - Configurar variables de entorno

#### Opción B: Usar Supabase CLI (requiere fix de auth)
```bash
# Una vez autenticado correctamente
supabase functions deploy --project-ref tevoogkifiszfontzkgd
```

### 3️⃣ Configurar Secrets para Edge Functions

En el Dashboard → Edge Functions → Settings:

```
SUPABASE_SERVICE_ROLE_KEY = eyJhbGc... (la clave service_role)
STRIPE_SECRET_KEY = sk_test_...
STRIPE_WEBHOOK_SECRET = whsec_...
RESEND_API_KEY = re_...
CORREOS_API_USER = ...
CORREOS_API_PASSWORD = ...
CORREOS_SENDER_CODE = ...
```

### 4️⃣ Configurar Webhooks

- **Stripe**: Apuntar a `https://tevoogkifiszfontzkgd.supabase.co/functions/v1/stripe-webhook`
- **Swikly**: Apuntar a `https://tevoogkifiszfontzkgd.supabase.co/functions/v1/swikly-webhook`

### 5️⃣ Actualizar Código Frontend

Asegurar que usa `.env.production` en producción:

```typescript
// apps/web/src/integrations/supabase/client.ts
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY;
```

### 6️⃣ Desplegar a Vercel

```bash
# Asegurar que .env.production está en variables de entorno de Vercel
# (NO commitar .env.production al repo)

npm run build
# Vercel desplegará automáticamente
```

---

## 🔐 Variables de Entorno Críticas

### Frontend (.env.production)
```
VITE_SUPABASE_URL=https://tevoogkifiszfontzkgd.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGc...
VITE_STRIPE_PUBLISHABLE_KEY=pk_test_...
VITE_APP_URL=https://brickshare.vercel.app
VITE_ENVIRONMENT=production
```

### Edge Functions (Dashboard Settings)
- `SUPABASE_SERVICE_ROLE_KEY`
- `STRIPE_SECRET_KEY`
- `RESEND_API_KEY`
- `CORREOS_API_USER/PASSWORD/SENDER_CODE`

---

## 🗄️ Estructura de la BD Cloud

La BD cloud tendrá la misma estructura que la local:

### Tablas Principales
- `public.users` - Perfil de usuario (auth + suscripción)
- `public.sets` - Catálogo LEGO
- `public.inventory_sets` - Stock físico
- `public.shipments` - Envíos y tracking
- `public.user_roles` - Roles (admin, user, operador)
- ... (ver `docs/DATABASE_SCHEMA.md`)

### Funciones RPC
- `preview_assign_sets_to_users()`
- `confirm_assign_sets_to_users()`
- `has_role(user_id, role)`
- ... (ver `docs/API_REFERENCE.md`)

### Políticas RLS
Todas las tablas tienen Row Level Security habilitado:
- `users` - Solo puede ver/editar el propio perfil
- `sets` - Lectura pública, escritura admin
- `shipments` - Solo puede ver/editar propios envíos
- ... (ver migraciones)

---

## 🔄 Cambios en el Flujo de Desarrollo

### Antes (Local)
```bash
supabase start          # Inicia BD local Docker
npm run dev            # Frontend http://localhost:5173
# Editar migraciones y hacer reset
supabase db reset      # NO usar directamente
./scripts/db-reset.sh  # Usar esto
```

### Después (Cloud)
```bash
# Frontend sigue igual
npm run dev            # Usa .env.develop (BD local) o .env.production (BD cloud)

# Para cambios en BD:
# 1. Crear migraciones locales primero
# 2. Aplicarlas al cloud manualmente vía SQL Editor
# 3. O usar supabase db push (cuando CLI sea fixeado)
```

---

## ⚠️ Consideraciones Importantes

### RLS (Row Level Security)
- ✅ Habilitado en todas las tablas
- ✅ Políticas configuradas según roles
- ⚠️ **IMPORTANTE**: Usar `supabase_user_id()` en WHERE clauses

### Auth
- ✅ Supabase Auth cloud configurado
- ✅ Métodos: Email/Password, OAuth (si está habilitado)
- ⚠️ Recordar que `auth.users` es separado de `public.users`

### Storage
- ✅ Supabase Storage cloud funcional
- ✅ Buckets: `sets` (imágenes), `documents` (PDFs, etc)
- ⚠️ URLs públicas: `https://tevoogkifiszfontzkgd.supabase.co/storage/v1/object/public/[bucket]/[path]`

### Edge Functions
- ✅ Ambiente Deno en cloud
- ✅ Acceso a BD vía conexión TCP
- ⚠️ Timeout: 30 segundos (revisar funciones largas)
- ⚠️ Memory: 512MB límite
- ⚠️ Tamaño máximo: 100MB

---

## 📋 Checklist de Verificación

Una vez completados todos los pasos:

- [ ] SQL backup aplicado al cloud
- [ ] Edge Functions desplegadas
- [ ] Secrets configurados en cloud
- [ ] Webhooks Stripe/Swikly actualizados
- [ ] Frontend conectando a BD cloud
- [ ] Auth funcionando en cloud
- [ ] Usuarios pueden loguearse
- [ ] Catálogo de sets visible
- [ ] Suscripciones procesándose
- [ ] Envíos creándose correctamente
- [ ] Storage funcionando (imágenes)
- [ ] Emails enviándose (Resend)
- [ ] Logs de Edge Functions visibles

---

## 🆘 Troubleshooting

### Error: "Connection refused" al conectar a BD
→ Verificar que estás usando `https://tevoogkifiszfontzkgd.supabase.co` (no localhost)

### Error: "Unauthorized" en Edge Functions
→ Revisar que la `Service Role Key` está en los secrets

### Error: "RLS policy violation"
→ Verificar que el usuario está autenticado y tiene permisos correctos

### Error: "Webhook signature mismatch"
→ Asegurar que el secret de Stripe/Swikly está correcto

---

## 📚 Referencias

- [Documentación Supabase Cloud](https://supabase.com/docs)
- [Guía SQL Editor](https://supabase.com/docs/guides/database/sql-editor)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- [Edge Functions](https://supabase.com/docs/guides/functions)
- [Arquitectura Brickshare](./ARCHITECTURE.md)
- [Esquema BD](./DATABASE_SCHEMA.md)

---

**Estado**: 🟡 En Progreso (Pendientes: Migraciones SQL + Edge Functions)
**Última actualización**: 29/03/2026