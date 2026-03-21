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
- API REST en `http://127.0.0.1:54321`
- Supabase Studio en `http://127.0.0.1:54323`

### 4. Configurar Variables de Entorno
Copiar `.env.example` a `.env.local` y actualizar las credenciales obtenidas de `supabase status`:

```bash
cp .env.example .env.local
```

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
# Conectar a PostgreSQL con psql
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
# Port: 54322
# Database: postgres
# Username: postgres
# Password: postgres
```

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

- [Supabase Local Development](https://supabase.com/docs/guides/cli/local-development)
- [Supabase Migrations](https://supabase.com/docs/guides/cli/local-development#database-migrations)
- [Edge Functions](https://supabase.com/docs/guides/functions)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)

## 🎯 Próximos Pasos

1. Familiarízate con el esquema de BD en `docs/DATABASE_SCHEMA.md`
2. Explora las Edge Functions en `supabase/functions/`
3. Revisa la arquitectura en `docs/ARCHITECTURE.md`
4. Lee el roadmap en `docs/DEVELOPMENT_ROADMAP.md`

---

**Última actualización**: 21/03/2026  
**Modo de desarrollo**: 100% Local con Docker