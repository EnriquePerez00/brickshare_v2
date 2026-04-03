# Brickshare - Plataforma de Alquiler Circular de Sets LEGO

Aplicación web completa de alquiler/préstamo de sets LEGO para familias, construida con **Vite + React + TypeScript** en el frontend y **Supabase** (PostgreSQL local) en el backend.

> ℹ️ **NOTA**: Este proyecto usa **Supabase LOCAL** (Docker) para desarrollo. Todo el stack corre localmente en tu máquina.

---

## 🚀 Quick Start

```bash
# 1. Clonar repositorio
git clone https://github.com/EnriquePerez00/brickshare_v2.git
cd brickshare_v2

# 2. Instalar dependencias
npm install

# 3. Iniciar Supabase local (Docker requerido)
supabase start

# 4. Obtener credenciales y configurar .env.local
supabase status
# Copiar los valores y pegarlos en .env.local

# 5. Iniciar aplicación
npm run dev
```

**Resultado**: Aplicación disponible en `http://localhost:5173`, Backend en `http://127.0.0.1:54321`

---

## 📋 Requisitos

| Herramienta | Versión | Propósito |
|---|---|---|
| **Node.js** | 18+ | Runtime JavaScript |
| **npm** | 9+ | Gestor de paquetes |
| **Docker Desktop** | Latest | Contenedores Supabase |
| **Supabase CLI** | Latest | Gestión BD local |

Instalar Supabase CLI:
```bash
brew install supabase/tap/supabase
# o
npm install -g supabase
```

---

## 🗂️ Estructura del Proyecto (Monorepo)

```
Brickshare/
├── apps/
│   └── web/                          # 🎯 Frontend principal
│       ├── src/
│       │   ├── pages/                # Rutas: Index, Auth, Catalogo, Dashboard, Admin, Operations
│       │   ├── components/           # Componentes React (admin, ui, etc)
│       │   ├── hooks/                # Custom hooks (useProducts, useShipments, etc)
│       │   ├── contexts/             # AuthContext (estado global)
│       │   ├── integrations/supabase/  # Cliente Supabase tipado
│       │   ├── lib/                  # Utilidades (pudoService, etc)
│       │   ├── test/                 # Setup testing (Vitest + MSW)
│       │   ├── __tests__/            # Tests unitarios e integración
│       │   ├── test/fixtures/        # Datos de prueba
│       │   └── public/               # Assets estáticos
│       ├── e2e/                      # Tests E2E (Playwright)
│       │   ├── user-journeys/
│       │   ├── admin-journeys/
│       │   ├── operator-journeys/
│       │   ├── error-scenarios/
│       │   └── helpers/
│       ├── vite.config.ts
│       ├── vitest.config.ts
│       ├── playwright.config.ts
│       └── package.json
│
├── packages/
│   └── shared/                       # Tipos compartidos (web + iOS)
│       └── src/types/pudo.ts
│
├── supabase/
│   ├── config.toml                   # Configuración Supabase local
│   ├── seed.sql                      # Datos iniciales
│   ├── .env                          # Vars Edge Functions
│   ├── functions/                    # 🔥 Edge Functions (Deno runtime)
│   │   ├── brickshare-qr-api/        # Validación QR
│   │   ├── correos-logistics/        # Integración Correos
│   │   ├── correos-pudo/             # PUDO Correos
│   │   ├── create-checkout-session/  # Pago Stripe
│   │   ├── create-logistics-package/ # Paquetes
│   │   ├── create-subscription-intent/ # Suscripción Stripe
│   │   ├── create-swikly-wish/       # Garantías Swikly
│   │   ├── delete-user/              # GDPR
│   │   ├── process-assignment-payment/ # Asignación
│   │   ├── send-brickshare-qr-email/ # Email QR
│   │   ├── send-email/               # Email genérico
│   │   ├── stripe-webhook/           # Webhook Stripe
│   │   ├── swikly-webhook/           # Webhook Swikly
│   │   ├── update-shipment/          # Envíos
│   │   └── ...                       # +10 más
│   ├── migrations/                   # ⚠️ ~90 migraciones (NUNCA ELIMINAR)
│   ├── backups/historic/             # Backups automáticos
│   └── snippets/                     # SQL snippets útiles
│
├── supabase-main/                    # Instancia "producción" local
│   ├── config.toml
│   ├── functions/
│   └── migrations/
│
├── scripts/                          # 🔧 ~40 scripts de utilidad
│   ├── safe-db-reset.sh              # ✅ Reset seguro con backup
│   ├── verify-edge-functions.sh
│   ├── seed-sets-from-brickset.ts
│   ├── test-*.sh
│   └── README_*.md                   # Documentación de scripts
│
├── docs/                             # 📚 Documentación técnica completa
│   ├── PROJECT_OVERVIEW.md           # Visión general
│   ├── ARCHITECTURE.md               # Diseño sistema
│   ├── DATABASE_SCHEMA.md            # Esquema BD (auto-generado)
│   ├── API_REFERENCE.md              # Edge Functions
│   ├── LOCAL_DEVELOPMENT.md          # Setup
│   ├── BRICKSHARE_PUDO*.md           # Sistema PUDO
│   ├── LABEL_PRINTING_AND_LOGISTICS_API.md
│   └── ...                           # +40 docs técnicos
│
├── tests/                            # Documentación testing
│   ├── PHASE_1_UNIT_TESTS.md
│   ├── PHASE_2_INTEGRATION_TESTS.md
│   ├── PHASE_3_E2E_TESTS.md
│   └── PHASE_4_CI_CD.md
│
├── .github/workflows/                # GitHub Actions (4 workflows)
│   ├── test.yml                      # CI tests
│   ├── quality.yml                   # Linting
│   ├── deploy-preview.yml
│   └── dependabot.yml
│
├── src/types/
│   └── supabase.ts                   # Tipos TS auto-generados
│
├── claude.md                         # Documentación Cline
├── package.json                      # Root monorepo
├── .env.local                        # Variables entorno (NO commitear)
├── .clinerules                       # Reglas Cline
└── README.md                         # Este archivo
```

---

## 🛠️ Stack Tecnológico Completo

### Frontend (apps/web)

| Tecnología | Versión | Propósito |
|---|---|---|
| **Vite** | ^7.3.1 | Build tool ultra-rápido |
| **React** | ^18.3.1 | UI framework con hooks |
| **TypeScript** | ^5.8.3 | Tipado estático end-to-end |
| **Tailwind CSS** | ^3.4.17 | Framework CSS utilitario |
| **shadcn/ui** | Latest | Componentes accesibles (Radix UI) |
| **React Router DOM** | ^6.30.1 | Routing SPA |
| **TanStack Query** | ^5.83.0 | Data fetching, caché y sincronización |
| **React Hook Form** | ^7.61.1 | Gestión de formularios |
| **Zod** | ^3.25.76 | Validación schemas |
| **Stripe.js** | ^8.7.0 | Pagos frontend |
| **Recharts** | ^2.15.4 | Gráficos y analytics |
| **Framer Motion** | ^12.26.2 | Animaciones |
| **date-fns** | ^3.6.0 | Manipulación fechas |
| **Lucide React** | ^0.462.0 | Iconos |
| **Sonner** | ^1.7.4 | Toast notifications |
| **QRCode.react** | ^4.2.0 | Generación QR |

### Testing (apps/web)

| Tool | Versión | Propósito |
|---|---|---|
| **Vitest** | ^3.2.4 | Unit + Integration tests (50+ tests) |
| **Testing Library** | ^16.3.2 | Testing componentes React |
| **Playwright** | ^1.58.2 | E2E testing (10+ journeys) |
| **MSW** | ^2.12.14 | API mocking |
| **@faker-js/faker** | ^10.3.0 | Datos de prueba |

### Backend (supabase/)

| Tecnología | Propósito |
|---|---|
| **Supabase** | Backend as a Service (BaaS) local |
| **PostgreSQL 17** | Base de datos relacional |
| **Supabase Auth** | Autenticación JWT + RLS |
| **Edge Functions** | Serverless (Deno runtime) |
| **Supabase Storage** | Almacenamiento archivos |
| **Row Level Security** | Control acceso a nivel fila |

### Integraciones Externas

| Servicio | Propósito | Env Vars |
|---|---|---|
| **Stripe** | Pagos y suscripciones | `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET` |
| **Correos API** | Logística y PUDO | `CORREOS_API_USER`, `CORREOS_API_PASSWORD` |
| **Swikly** | Garantías y depósitos | `SWIKLY_ACCOUNT_ID`, `SWIKLY_SECRET_API_KEY`, `SWIKLY_ENVIRONMENT` |
| **Resend** | Emails transaccionales | `RESEND_API_KEY` |
| **Brickset/Rebrickable** | Datos sets LEGO | `BRICKSET_API_KEY` (opcional) |

### DevOps y CI/CD

| Herramienta | Propósito |
|---|---|
| **Docker** | Supabase local (PostgreSQL, Auth, Storage) |
| **Supabase CLI** | Migraciones, funciones, tipos |
| **GitHub Actions** | CI/CD (4 workflows: tests, quality, deploy, dependabot) |
| **Vercel** | Deployment frontend |
| **ESLint** | Linting código |

---

## 🔧 Comandos de Desarrollo

### Frontend (npm)

```bash
# Desarrollo
npm run dev                 # Iniciar dev server → http://localhost:5173

# Build
npm run build               # Build de producción
npm run preview             # Preview del build

# Linting
npm run lint                # ESLint
npm run lint:fix            # Auto-fix

# Testing
npm run test                # Unit + Integration (Vitest)
npm run test:watch          # Watch mode
npm run test:e2e            # E2E (Playwright)
npm run test:e2e:ui         # UI interactivo
npm run test:e2e:headed     # Ver browser
npm run test:e2e:debug      # Debug mode

# Tipos
npm run dump-schema         # Actualizar docs/DATABASE_SCHEMA.md
```

### Backend (Supabase)

```bash
# Iniciar/Detener
supabase start              # Iniciar servicios locales
supabase stop               # Detener servicios
supabase status             # Ver credenciales y URLs

# Migraciones
supabase migration new nombre_descriptivo
supabase db reset           # ⚠️ NUNCA usar directamente

# ✅ Usar en su lugar:
./scripts/safe-db-reset.sh  # Reset seguro con backup automático
./scripts/restore-data.sh   # Restaurar backup

# Tipos
supabase gen types typescript --local > src/types/supabase.ts

# Studio
open http://127.0.0.1:54323 # Supabase Studio web UI
```

### Base de Datos

```bash
# Conectar a PostgreSQL
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres

# Obtener status BD
supabase status

# Reset de base de datos (elige una opción)
./scripts/safe-db-reset.sh    # Con backup automático (recomendado)
supabase db reset             # Reset directo sin backup

# Exportar esquema
supabase db dump --schema public -f docs/schema_dump.sql

# Verificar integridad
npm run verify-seed-results
```

### CI/CD Local

```bash
# Simular pipeline de CI
./scripts/ci-test.sh        # Tests completos
./scripts/ci-setup.sh       # Setup CI
```

---

## 🔐 Variables de Entorno (.env.local)

```bash
# Supabase Local (obtener con 'supabase status')
VITE_SUPABASE_URL=http://127.0.0.1:54321
VITE_SUPABASE_ANON_KEY=<anon_key_from_status>
VITE_SUPABASE_SERVICE_ROLE_KEY=<service_role_from_status>
SUPABASE_SERVICE_ROLE_KEY=<service_role_from_status>

# Stripe (test keys)
VITE_STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=<your_stripe_secret_key>...
STRIPE_WEBHOOK_SECRET=<your_webhook_secret>...

# Swikly (garantías) - Development by default
SWIKLY_ACCOUNT_ID=your_account_id
SWIKLY_SECRET_API_KEY=your_secret_api_key
SWIKLY_ENVIRONMENT=development  # Por defecto: development
SWIKLY_API_KEY=your_key
SWIKLY_API_URL=https://api.swikly.com

# Correos API (logística)
CORREOS_API_USER=your_user
CORREOS_API_PASSWORD=your_password
CORREOS_SENDER_CODE=your_code
CORREOS_API_URL=https://api.correos.es

# Resend (emails)
RESEND_API_KEY=re_...

# LEGO APIs (opcional)
BRICKSET_API_KEY=your_key
REBRICKABLE_API_KEY=your_key

# App
VITE_APP_URL=http://localhost:5173
```

---

## 🧪 Testing

### Tests Unitarios (Vitest)
```bash
npm run test                # Run once
npm run test:watch          # Watch mode
```
- **50+ tests unitarios** de hooks, componentes y utilidades
- Ubicación: `apps/web/src/__tests__/unit/`

### Tests de Integración (Vitest)
```bash
npm run test                # Incluye tests de integración
```
- **15+ tests de integración** de flujos completos
- Ubicación: `apps/web/src/__tests__/integration/`

### Tests Swikly E2E (Sandbox + Validación Automática)

Para desarrollo local, usamos Swikly Sandbox con validación automática mediante tarjeta VISA de prueba:

```bash
# 1. Asegurar que Supabase está corriendo
supabase start

# 2. Configurar credenciales Swikly en supabase/functions/.env
SWIKLY_API_TOKEN_SANDBOX=api-xxxxxxxxxxxxx
SWIKLY_ACCOUNT_ID=550e8400-e29b-41d4-a716-446655440000

# 3. Ejecutar tests E2E de Swikly
cd apps/web
npm run test -- swikly-flow.test.ts
```

**Tarjeta VISA de Prueba (Sandbox):**
- Número: `4970 1051 8181 8183`
- Vencimiento: `12/27`
- CVV: `123`
- Email: `test-swikly@brickshare.local`
- **Se aprueba automáticamente en Sandbox - sin confirmación manual**

**Flujo E2E Testado:**
1. ✅ Crear envío con set LEGO
2. ✅ Llamar Edge Function (create-swikly-wish-shipment)
3. ✅ Simular pago con VISA de prueba
4. ✅ Procesar webhook de Swikly
5. ✅ Verificar estado actualizado en BD (swikly_status='secured')

**Ventajas para desarrollo:**
- ✅ Sin pasos manuales en tests automatizados
- ✅ Tests ejecutables en CI/CD sin interacción usuario
- ✅ API Sandbox acepta tarjeta de prueba inmediatamente
- ✅ Webhook procesado automáticamente
- ✅ Ver documentación completa: [SWIKLY_E2E_TESTING_GUIDE.md](docs/SWIKLY_E2E_TESTING_GUIDE.md)

**Resultado de tests:**
```
 ✓ src/tests/e2e/swikly-flow.test.ts (7 tests) 3ms
 Test Files  1 passed (1)
      Tests  7 passed (7)
```

### Tests E2E (Playwright)
```bash
npm run test:e2e            # Run all
npm run test:e2e:ui         # UI mode
npm run test:e2e:headed     # Headed mode
```
- **10+ journeys E2E** (user, admin, operator, error scenarios)
- Ubicación: `apps/web/e2e/`

### CI/CD (GitHub Actions)
```bash
# Ver workflows en .github/workflows/
# - test.yml          → Tests (unit + integration + E2E)
# - quality.yml       → Linting y type checking
# - deploy-preview.yml → Preview deployments
```

---

## 📚 Documentación de Referencia

| Documento | Contenido |
|---|---|
| **[claude.md](claude.md)** | Documentación técnica completa (13 secciones) |
| **[docs/PROJECT_OVERVIEW.md](docs/PROJECT_OVERVIEW.md)** | Visión general, flujos, estado |
| **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** | Diseño técnico, diagramas |
| **[docs/DATABASE_SCHEMA.md](docs/DATABASE_SCHEMA.md)** | Esquema BD auto-generado |
| **[docs/LOCAL_DEVELOPMENT.md](docs/LOCAL_DEVELOPMENT.md)** | Setup y workflow completo |
| **[docs/API_REFERENCE.md](docs/API_REFERENCE.md)** | Edge Functions detalladas |
| **[docs/BRICKSHARE_PUDO.md](docs/BRICKSHARE_PUDO.md)** | Sistema PUDO completo |
| **[tests/START_HERE.md](tests/START_HERE.md)** | Guía de inicio testing |

---

## 🎯 Funcionalidades Principales

### Para Usuarios
- ✅ Autenticación (email/password)
- ✅ Suscripción planes (Basic, Standard, Premium)
- ✅ Catálogo de sets LEGO
- ✅ Wishlist y recomendaciones
- ✅ Dashboard personal con envíos activos
- ✅ Tracking de envíos en tiempo real
- ✅ Valoraciones y reseñas
- ✅ Programa de referidos

### Para Admin
- ✅ Backoffice completo
- ✅ Gestión de sets e inventario
- ✅ Gestión de usuarios
- ✅ Panel de analytics
- ✅ Asignación automática de sets
- ✅ Generación de etiquetas de envío
- ✅ Integración Stripe y webhooks

### Para Operador Logístico
- ✅ Panel de operaciones
- ✅ Gestión de envíos
- ✅ Validación QR (entrega/devolución)
- ✅ Recepción y mantenimiento de sets
- ✅ Tracking de devoluciones

### Sistema PUDO Dual
- ✅ Puntos PUDO Correos (externos)
- ✅ Puntos PUDO Brickshare (propios)
- ✅ Validación QR en puntos
- ✅ Integración logística completa

---

## 🔄 Flujos de Negocio Principales

### 1. Suscripción
```
Usuario → Selecciona plan → Stripe Checkout → 
Webhook confirma pago → Perfil actualizado
```

### 2. Asignación de Sets
```
Admin ejecuta preview → Revisa → Confirma →
Crea shipments → Genera QR → Etiquetas Correos
```

### 3. Envío y Entrega
```
Correos recoge → Tránsito → PUDO/Usuario recibe →
Validación QR → Entrega confirmada
```

### 4. Devolución
```
Usuario solicita → Tránsito retorno → Recepción →
Validación QR → Mantenimiento → Stock actualizado
```

### 5. Referidos
```
Usuario A comparte código → Usuario B se registra →
B completa suscripción → Créditos generados para A
```

---

## 🚢 Deployment

El proyecto está configurado para **desarrollo local 100%** con Docker.

Para producción (futuro):
1. **Frontend**: Vercel, Netlify, o similar
2. **Base de datos**: Migrar a Supabase Cloud o RDS
3. **Edge Functions**: Deploy a Supabase Cloud

```bash
# Preparar para deployment
npm run build               # Build de producción
npm run dump-schema         # Actualizar docs

# Aplicar migraciones antes de deploy
./scripts/safe-db-reset.sh
```

---

## 🤝 Contribuir

1. Fork el proyecto: https://github.com/EnriquePerez00/brickshare_v2
2. Crea rama: `git checkout -b feature/mi-feature`
3. Realiza cambios y commit: `git commit -m 'feat: descripción'`
4. Push: `git push origin feature/mi-feature`
5. Abre Pull Request

Ver [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) para convenciones.

---

## ⚙️ Convenciones y Reglas

### Código
- **TypeScript estricto** en todo
- **Componentes funcionales** con hooks
- **shadcn/ui** para componentes (NO crear custom)
- **TanStack Query** para data fetching
- **Zod** para validación con react-hook-form
- **date-fns** para fechas

### Base de Datos
- **NUNCA eliminar** migraciones en `supabase/migrations/`
- **SIEMPRE** crear nuevas: `supabase migration new <name>`
- **RLS habilitado** en todas las tablas

### Git
- Commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`
- Pre-commit hook auto-actualiza docs

---

## 📊 Estado del Proyecto

### ✅ Completado
- Frontend web 100% funcional
- Autenticación con RLS
- Suscripciones Stripe completas
- Integración logística Correos + PUDO
- Sistema QR permanente
- Backoffice admin completo
- Panel operador logístico
- Sistema de referidos
- Testing completo (Unit + Integration + E2E)
- CI/CD con GitHub Actions

### ⚠️ En Desarrollo
- App iOS (React Native/Expo)

### 📋 Próximos
- Aumentar cobertura tests 80%+
- Dashboard analytics avanzado
- Sistema de notificaciones push
- Recomendaciones ML

---

## 🔗 Links Útiles

- **Repositorio**: https://github.com/EnriquePerez00/brickshare_v2
- **Supabase Studio Local**: http://127.0.0.1:54323
- **Frontend Dev**: http://localhost:5173
- **Backend API**: http://127.0.0.1:54321

---

## 📝 Licencia

Este proyecto es privado y propietario.

---

**Desarrollado con ❤️ usando React, Vite, Supabase y mucho café** ☕

*Última actualización: 25/03/2026 - Documentación sincronizada con `claude.md`*