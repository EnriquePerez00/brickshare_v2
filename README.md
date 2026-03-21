# Brickshare - Plataforma de Alquiler de Sets LEGO

Aplicación web de alquiler de sets de LEGO construida con **Vite + React** y **backend Supabase**.

## 🚀 Quick Start

```bash
# 1. Clonar repositorio
git clone https://github.com/EnriquePerez00/brickshare_v2.git
cd brickshare_v2

# 2. Instalar dependencias
npm install

# 3. Iniciar Supabase local (Docker requerido)
supabase start

# 4. Configurar variables de entorno
cp .env.example .env.local
# Editar .env.local con las credenciales de 'supabase status'

# 5. Iniciar aplicación
npm run dev
```

La aplicación estará disponible en `http://localhost:5173`

## 📋 Requisitos

- **Node.js 18+**
- **Docker Desktop** (para Supabase local)
- **Supabase CLI**: `brew install supabase/tap/supabase`

## 🗂️ Estructura del Proyecto

```
brickshare_v2/
├── apps/
│   └── web/              # Frontend web (Vite, React, shadcn/ui, Tailwind)
├── packages/
│   └── shared/           # Tipos y contratos compartidos
├── supabase/
│   ├── functions/        # Edge Functions (Deno)
│   ├── migrations/       # Migraciones SQL
│   └── config.toml       # Configuración de Supabase
├── scripts/              # Scripts de utilidad
├── docs/                 # Documentación técnica
└── src/
    └── types/            # Tipos TypeScript generados
```

## 🔧 Comandos Principales

### Desarrollo

```bash
# Iniciar aplicación en modo desarrollo
npm run dev

# Build de producción
npm run build

# Preview del build
npm run preview

# Linting
npm run lint
```

### Supabase

```bash
# Iniciar servicios locales
supabase start

# Ver estado y credenciales
supabase status

# Detener servicios
supabase stop

# Crear nueva migración
supabase migration new nombre_descriptivo

# Aplicar migraciones (reset completo)
supabase db reset

# Generar tipos TypeScript
supabase gen types typescript --local > src/types/supabase.ts

# Acceder a Supabase Studio
open http://127.0.0.1:54323
```

### Base de Datos

```bash
# Conectar a PostgreSQL
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres

# Cargar datos de prueba
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres -f scripts/reset-test-data.sql

# Exportar esquema
supabase db dump --schema public -f docs/schema_dump.sql
```

## 🛠️ Stack Tecnológico

### Frontend
- **Vite** - Build tool
- **React 18** - UI framework
- **TypeScript** - Type safety
- **Tailwind CSS** - Styling
- **shadcn/ui** - Component library
- **React Router** - Routing
- **Tanstack Query** - Data fetching

### Backend
- **Supabase** - Backend as a Service
  - PostgreSQL - Database
  - Auth - Authentication
  - Edge Functions - Serverless functions
  - Storage - File storage
  - Realtime - WebSocket subscriptions

### Integraciones
- **Stripe** - Pagos y suscripciones
- **Correos API** - Logística y envíos
- **Swikly** - Garantías de depósito
- **Resend** - Envío de emails
- **Brickset/Rebrickable** - Datos de sets LEGO

## 📚 Documentación

- **[Guía de Desarrollo Local](docs/LOCAL_DEVELOPMENT.md)** - Setup y workflow completo
- **[Arquitectura](docs/ARCHITECTURE.md)** - Diseño del sistema
- **[Esquema de BD](docs/DATABASE_SCHEMA.md)** - Documentación de base de datos
- **[API Reference](docs/API_REFERENCE.md)** - Endpoints y funciones
- **[Roadmap](docs/DEVELOPMENT_ROADMAP.md)** - Funcionalidades planificadas

## 🔐 Configuración de Entorno

Copia `.env.example` a `.env.local` y configura:

```bash
# Supabase Local (obtener con 'supabase status')
VITE_SUPABASE_URL=http://127.0.0.1:54321
VITE_SUPABASE_ANON_KEY=your_anon_key
VITE_SUPABASE_SERVICE_ROLE_KEY=your_service_role_key

# Stripe (test keys)
VITE_STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
```

## 🚢 Deployment

El proyecto usa Docker para desarrollo local. Para producción:

1. **Base de datos**: Proyecto Supabase en la nube
2. **Frontend**: Vercel o similar
3. **Edge Functions**: Desplegadas automáticamente con Supabase CLI

```bash
# Push de migraciones a producción
supabase db push --linked

# Deploy de Edge Functions
supabase functions deploy
```

## 🧪 Testing

```bash
# Ejecutar tests
npm run test

# Tests con cobertura
npm run test:coverage

# Tests E2E
npm run test:e2e
```

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama: `git checkout -b feature/nueva-funcionalidad`
3. Realiza cambios y commit: `git commit -m 'feat: nueva funcionalidad'`
4. Push: `git push origin feature/nueva-funcionalidad`
5. Abre un Pull Request

Ver [CONTRIBUTING.md](docs/CONTRIBUTING.md) para más detalles.

## 📄 Licencia

Este proyecto es privado y propietario.

## 🔗 Links

- **Repositorio**: https://github.com/EnriquePerez00/brickshare_v2
- **Supabase Studio Local**: http://127.0.0.1:54323
- **Documentación**: [docs/](docs/)

---

**Desarrollado con ❤️ usando Vite, React y Supabase**