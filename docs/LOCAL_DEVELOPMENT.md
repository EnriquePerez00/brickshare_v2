# Guía de Desarrollo Local - Brickshare

## 🚀 Setup Inicial

### Requisitos Previos
- Docker Desktop instalado y corriendo
- Node.js 18+ instalado
- Supabase CLI instalado: `brew install supabase/tap/supabase`

### 1. Clonar el Repositorio
```bash
git clone https://github.com/EnriquePerez00/brickshare_v2.git
cd brickshare_v2
```

### 2. Instalar Dependencias
```bash
npm install
```

### 3. Iniciar Supabase Local
```bash
# Iniciar todos los servicios de Supabase en Docker
supabase start

# Ver estado y credenciales
supabase status
```

Esto iniciará:
- PostgreSQL en `postgresql://postgres:postgres@127.0.0.1:54322/postgres`
- API REST en `http://127.0.0.1:54331` ⚠️ **NOTA**: Este proyecto usa el puerto **54331** (no el estándar 54321)
- Supabase Studio en `http://127.0.0.1:54323`

### 4. Configurar Variables de Entorno
Copiar `.env.example` a `apps/web/.env.local` y actualizar las credenciales obtenidas de `supabase status`:

```bash
cp .env.example apps/web/.env.local
```

⚠️ **Importante**: El archivo `apps/web/.env.local` ya está configurado para usar el puerto **54331**.

Si necesitas configurar Swikly (depósitos de garantía), consulta [SWIKLY_DEV_CONFIGURATION.md](./SWIKLY_DEV_CONFIGURATION.md).

### 5. Iniciar la Aplicación
```bash
npm run dev
```

La aplicación estará disponible en `http://localhost:5173`

## 📋 Comandos Principales

### Supabase

```bash
# Iniciar servicios
supabase start

# Detener servicios
supabase stop

# Ver estado y credenciales
supabase status

# Acceder a Studio (UI para gestionar BD)
open http://127.0.0.1:54323

# Crear nueva migración
supabase migration new nombre_descriptivo

# Aplicar migraciones pendientes
supabase db reset

# Generar tipos TypeScript
supabase gen types typescript --local > src/types/supabase.ts

# Ver logs de Edge Functions
supabase functions serve --debug
```

### Base de Datos

```bash
# Conectar a PostgreSQL con psql (Puerto 54322 para DB, 54331 para API)
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres

# Exportar esquema
supabase db dump --schema public -f docs/schema_dump.sql

# Reset completo (¡CUIDADO! Elimina todos los datos)
supabase db reset

# Aplicar seed data de prueba
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres -f scripts/reset-test-data.sql
```

### Desarrollo

```bash
# Modo desarrollo
npm run dev

# Build de producción
npm run build

# Preview de build
npm run preview

# Linting
npm run lint

# Tests
npm run test
```

## 🗂️ Estructura del Proyecto

```
brickshare_v2/
├── apps/web/              # Aplicación web principal
│   └── src/
├── packages/shared/       # Código compartido
├── supabase/
│   ├── functions/         # Edge Functions
│   ├── migrations/        # Migraciones SQL (¡NO ELIMINAR!)
│   └── config.toml        # Configuración de Supabase
├── scripts/               # Scripts de utilidad
├── docs/                  # Documentación
└── src/types/             # Tipos TypeScript generados
```

## 🔧 Workflow de Desarrollo

### 1. Crear una Nueva Feature

```bash
# Crear rama
git checkout -b feature/nueva-funcionalidad

# Hacer cambios...

# Si cambias el esquema de BD, crear migración
supabase migration new add_nueva_tabla

# Editar el archivo de migración en supabase/migrations/

# Aplicar la migración
supabase db reset

# Regenerar tipos
supabase gen types typescript --local > src/types/supabase.ts
```

### 2. Desarrollar Edge Functions

```bash
# Crear nueva función
supabase functions new mi-funcion

# Desarrollar la función en supabase/functions/mi-funcion/index.ts

# Probar localmente
supabase functions serve mi-funcion --debug

# En otra terminal, llamar a la función
curl http://localhost:54321/functions/v1/mi-funcion \
  -H "Authorization: Bearer <ANON_KEY>"
```

### 3. Commit y Push

```bash
# Añadir cambios
git add .

# El git hook actualizará automáticamente docs/DATABASE_SCHEMA.md

# Commit
git commit -m "feat: descripción de la feature"

# Push
git push origin feature/nueva-funcionalidad
```

## 🗄️ Gestión de Datos

### Seed Data de Prueba

```bash
# Cargar datos de prueba
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres -f scripts/reset-test-data.sql
```

### Backup Local

```bash
# Exportar solo datos (sin esquema)
supabase db dump --data-only -f backups/backup_$(date +%Y%m%d).sql

# Importar backup
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres -f backups/backup_20260321.sql
```

### Reset Completo

```bash
# Eliminar todos los datos y re-aplicar migraciones
supabase db reset

# Cargar datos de prueba
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres -f scripts/reset-test-data.sql
```

## 🔍 Debugging

### Ver Logs

```bash
# Logs de PostgreSQL
docker logs supabase_db_tevoogkifiszfontzkgd

# Logs de todas las Edge Functions
supabase functions serve --debug
```

### Acceder a PostgreSQL

```bash
# Con psql
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres

# Con un cliente visual, usar:
# Host: 127.0.0.1
# Port: 54322 (Base de Datos) | 54331 (API REST)
# Database: postgres
# Username: postgres
# Password: postgres
```

### Exponer Entorno Local (Webhooks)

Para recibir webhooks de servicios externos (Stripe, Swikly, etc.) necesitas exponer tu entorno local usando un túnel:

```bash
# Instalar ngrok (si no lo tienes)
brew install ngrok

# Exponer el puerto de Supabase (54331)
ngrok http 54331
```

La URL generada (ej: `https://abc123.ngrok.io`) puede usarse para:
- Webhooks de Stripe: `https://abc123.ngrok.io/functions/v1/stripe-webhook`
- Webhooks de Swikly: `https://abc123.ngrok.io/functions/v1/swikly-webhook`

⚠️ **Seguridad**: Solo mantén el túnel activo durante desarrollo. Ciérralo cuando no lo uses.

Para más detalles sobre configuración de Swikly, consulta [SWIKLY_DEV_CONFIGURATION.md](./SWIKLY_DEV_CONFIGURATION.md).

### Supabase Studio

Abre `http://127.0.0.1:54323` para:
- Explorar tablas y datos
- Ejecutar queries SQL
- Ver y testear Edge Functions
- Gestionar políticas RLS
- Ver logs en tiempo real

## 🚨 Troubleshooting

### Docker no está corriendo

```bash
# macOS
open -a Docker

# Esperar a que Docker inicie, luego
supabase start
```

### Puerto ya en uso

```bash
# Verificar si hay otro proyecto Supabase corriendo
docker ps | grep supabase

# Detener otro proyecto
supabase stop --project-id <otro-project-id>

# O cambiar el puerto en supabase/config.toml
```

### Migraciones fallan

```bash
# Ver el error completo
supabase db reset --debug

# Si una migración específica falla, editarla en supabase/migrations/
# Luego reintentar
supabase db reset
```

### Regenerar tipos TypeScript

```bash
# Si los tipos están desactualizados
supabase gen types typescript --local > src/types/supabase.ts
```

## 📚 Recursos

### Documentación Externa
- [Supabase Local Development](https://supabase.com/docs/guides/cli/local-development)
- [Supabase Migrations](https://supabase.com/docs/guides/cli/local-development#database-migrations)
- [Edge Functions](https://supabase.com/docs/guides/functions)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)

### Documentación del Proyecto
- [Configuración de Swikly](./SWIKLY_DEV_CONFIGURATION.md) - Setup de depósitos de garantía
- [Arquitectura](./ARCHITECTURE.md) - Diseño técnico del sistema
- [Esquema de Base de Datos](./DATABASE_SCHEMA.md) - Referencia completa de tablas
- [Roadmap de Desarrollo](./DEVELOPMENT_ROADMAP.md) - Próximas funcionalidades

## 🎯 Próximos Pasos

1. Familiarízate con el esquema de BD en `docs/DATABASE_SCHEMA.md`
2. Explora las Edge Functions en `supabase/functions/`
3. Revisa la arquitectura en `docs/ARCHITECTURE.md`
4. Lee el roadmap en `docs/DEVELOPMENT_ROADMAP.md`

---

## 🔧 Configuración de Puertos

| Servicio | Puerto | URL |
|---|---|---|
| **PostgreSQL** | 54322 | `postgresql://postgres:postgres@127.0.0.1:54322/postgres` |
| **API REST** | 54331 | `http://127.0.0.1:54331` |
| **Supabase Studio** | 54323 | `http://127.0.0.1:54323` |
| **Frontend** | 8080 | `http://localhost:8080` |

⚠️ **Nota**: Este proyecto usa el puerto **54331** para la API REST en lugar del puerto estándar 54321 de Supabase.

---

**Última actualización**: 31/03/2026  
**Modo de desarrollo**: 100% Local con Docker  
**Puerto API personalizado**: 54331
