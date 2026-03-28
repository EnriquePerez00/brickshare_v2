# Brickshare — Documentación Técnica Completa

> Plataforma de alquiler circular de sets LEGO  
> Repositorio: https://github.com/EnriquePerez00/brickshare_v2  
> Última actualización: 25/03/2026

---

# ⚡ Reglas de Consumo de Tokens

1. **Respostas Concisas:** No me des explicaciones largas a menos que te lo pida. Ve directo al código.
2. **Lectura Selectiva:** Antes de leer archivos grandes, pregúntame o lee solo las líneas relevantes.
3. **No repitas código:** Si solo cambias una línea, no me devuelvas el archivo entero; usa bloques de diff o solo la parte afectada.
4. **Pensamiento Interno:** Minimiza el razonamiento paso a paso si la solución es trivial.

---

# 🚫 REGLAS CRÍTICAS

### ❌ NUNCA hagas:
```bash
supabase db reset  # ¡NUNCA ejecutes esto directamente!
```

### ✅ SIEMPRE usa:
```bash
./scripts/safe-db-reset.sh  # Hace backup automático antes del reset
```

### ⚠️ IMPORTANTE: SOLO BASES DE DATOS LOCALES

**Regla fundamental**: Este proyecto NO usa Supabase Cloud. Todo el desarrollo se realiza con instancias locales de Supabase sobre Docker.

Si encuentras URLs con `.supabase.co` o `.supabase.com` en cualquier archivo, son errores que deben corregirse.

---

## 1. Configuración de Bases de Datos

### Base de Datos de Desarrollo (LOCAL - Puerto 54322)

```bash
# Credenciales de desarrollo (Supabase Docker local - directorio /supabase)
Base de datos: postgresql://postgres:postgres@127.0.0.1:54322/postgres
API URL: http://127.0.0.1:54321
Studio: http://127.0.0.1:54323
Anon Key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Service Role: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Obtener credenciales actuales**:
```bash
cd /Users/I764690/Code_personal/Brickshare
supabase status
```

**Características**:
- ✅ BD principal para desarrollo y pruebas
- ✅ Datos seed completos y actualizados
- ✅ ~90 migraciones aplicadas automáticamente
- ✅ Reinicio seguro con `./scripts/safe-db-reset.sh`
- ✅ Backups automáticos en `supabase/backups/historic/`

**Iniciar**:
```bash
cd /Users/I764690/Code_personal/Brickshare
supabase start
```

---

### Archivo .env.local (Desarrollo)

```bash
# Supabase Local (obtener con 'supabase status')
VITE_SUPABASE_URL=http://127.0.0.1:54321
VITE_SUPABASE_ANON_KEY=<anon_key_from_supabase_status>
VITE_SUPABASE_SERVICE_ROLE_KEY=<service_role_from_supabase_status>
SUPABASE_SERVICE_ROLE_KEY=<service_role_from_supabase_status>

# Stripe (test keys)
VITE_STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=<your_stripe_secret_key>...
STRIPE_WEBHOOK_SECRET=<your_webhook_secret>...

# Swikly (garantías)
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

## 2. Estructura del Repositorio

```
Brickshare/
├── apps/
│   └── web/                          # 🎯 Frontend principal (React + Vite)
│       ├── src/
│       │   ├── pages/                # Rutas principales
│       │   │   ├── Index.tsx         # Landing page
│       │   │   ├── Auth.tsx          # Login/Registro
│       │   │   ├── Catalogo.tsx      # Catálogo de sets
│       │   │   ├── Dashboard.tsx     # Panel usuario
│       │   │   ├── Admin.tsx         # Backoffice admin
│       │   │   └── Operations.tsx    # Panel operador
│       │   ├── components/           # Componentes React
│       │   │   ├── admin/            # Componentes backoffice
│       │   │   │   ├── inventory/    # Gestión inventario
│       │   │   │   │   ├── InventoryManager.tsx
│       │   │   │   │   ├── InventoryPiecesManager.tsx
│       │   │   │   │   ├── MaintenanceList.tsx
│       │   │   │   │   └── PiecePurchaseManager.tsx
│       │   │   │   ├── operations/   # Operaciones logísticas
│       │   │   │   │   ├── SetAssignment.tsx
│       │   │   │   │   ├── ShipmentsList.tsx
│       │   │   │   │   ├── ReturnsList.tsx
│       │   │   │   │   ├── LabelPrinting.tsx
│       │   │   │   │   └── LabelGeneration.tsx
│       │   │   │   ├── products/     # Gestión de sets
│       │   │   │   │   └── ProductsManager.tsx
│       │   │   │   ├── users/        # Gestión de usuarios
│       │   │   │   │   ├── UsersManager.tsx
│       │   │   │   │   └── WishlistsViewer.tsx
│       │   │   │   └── logistics/    # Logística
│       │   │   │       └── LogisticsManager.tsx
│       │   │   └── ui/               # shadcn/ui components
│       │   ├── hooks/                # Custom hooks
│       │   │   ├── useProducts.ts    # Gestión de sets
│       │   │   ├── useShipments.ts   # Gestión de envíos
│       │   │   ├── useWishlist.ts    # Lista de deseos
│       │   │   ├── usePudo.ts        # Puntos PUDO
│       │   │   └── useAssignedShipments.ts
│       │   ├── contexts/             # React Context
│       │   │   └── AuthContext.tsx   # Autenticación global
│       │   ├── integrations/         # Cliente Supabase
│       │   │   └── supabase/
│       │   │       ├── client.ts     # Cliente tipado
│       │   │       └── types.ts      # Tipos de BD
│       │   ├── lib/                  # Utilidades
│       │   │   ├── pudoService.ts    # Servicio PUDO
│       │   │   └── utils.ts          # Helpers generales
│       │   ├── test/                 # Infraestructura de testing
│       │   │   ├── setup.ts          # Configuración Vitest
│       │   │   ├── mocks/            # Mocks MSW
│       │   │   └── fixtures/         # Datos de prueba
│       │   └── __tests__/            # Tests
│       │       ├── unit/             # Tests unitarios
│       │       └── integration/      # Tests de integración
│       ├── e2e/                      # Tests E2E (Playwright)
│       │   ├── user-journeys/        # Flujos de usuario
│       │   ├── admin-journeys/       # Flujos de admin
│       │   ├── operator-journeys/    # Flujos de operador
│       │   ├── error-scenarios/      # Casos de error
│       │   └── helpers/              # Helpers E2E
│       ├── public/                   # Assets estáticos
│       ├── package.json              # Dependencias frontend
│       ├── vite.config.ts            # Config Vite
│       ├── playwright.config.ts      # Config Playwright
│       └── vitest.config.ts          # Config Vitest
│
├── packages/
│   └── shared/                       # Código compartido
│       └── src/
│           └── types/                # Tipos compartidos
│               └── pudo.ts           # Tipos PUDO
│
├── supabase/
│   ├── config.toml                   # Configuración Supabase
│   ├── seed.sql                      # Datos iniciales
│   ├── .env                          # Variables Edge Functions
│   ├── functions/                    # 🔥 Edge Functions (Deno)
│   │   ├── brickshare-qr-api/       # API QR validación
│   │   ├── change-subscription/      # Cambio suscripción
│   │   ├── correos-logistics/        # Logística Correos
│   │   ├── correos-pudo/             # Puntos PUDO
│   │   ├── create-checkout-session/  # Pago Stripe
│   │   ├── create-logistics-package/ # Paquetes logísticos
│   │   ├── create-subscription-intent/
│   │   ├── create-swikly-wish/       # Garantías Swikly
│   │   ├── delete-user/              # Eliminar cuenta
│   │   ├── fetch-lego-data/          # Enriquecer sets
│   │   ├── process-assignment-payment/
│   │   ├── send-brickshare-qr-email/ # Email QR
│   │   ├── send-email/               # Email genérico
│   │   ├── stripe-webhook/           # Webhook Stripe
│   │   ├── submit-donation/          # Donaciones
│   │   ├── swikly-manage-wish/       # Gestión Swikly
│   │   ├── swikly-webhook/           # Webhook Swikly
│   │   └── update-shipment/          # Actualizar envío
│   ├── migrations/                   # ⚠️ ~90 migraciones (NUNCA ELIMINAR)
│   ├── backups/                      # Backups automáticos
│   │   └── historic/                 # Backups históricos
│   └── snippets/                     # SQL snippets útiles
│
├── supabase-main/                    # Instancia "producción" local
│   ├── config.toml
│   ├── functions/
│   └── migrations/
│
├── scripts/                          # 🔧 ~40 Scripts de utilidad
│   ├── safe-db-reset.sh              # ✅ Reset seguro con backup
│   ├── restore-data.sh               # Restaurar backup
│   ├── sync-auth-users-to-local.ts   # Sync usuarios
│   ├── seed-sets-from-brickset.ts    # Importar sets
│   ├── verify-edge-functions.sh      # Verificar functions
│   ├── test-*.sh                     # Scripts de testing
│   └── README_*.md                   # Docs de scripts
│
├── docs/                             # 📚 Documentación técnica
│   ├── PROJECT_OVERVIEW.md           # Visión general
│   ├── ARCHITECTURE.md               # Arquitectura
│   ├── DATABASE_SCHEMA.md            # Esquema BD (auto-gen)
│   ├── schema_dump.sql               # Dump SQL completo
│   ├── API_REFERENCE.md              # Edge Functions
│   ├── LOCAL_DEVELOPMENT.md          # Setup desarrollo
│   ├── BRICKSHARE_PUDO*.md           # Sistema PUDO
│   └── ...                           # Más docs técnicos
│
├── tests/                            # Documentación de testing
│   ├── PHASE_1_UNIT_TESTS.md         # Tests unitarios
│   ├── PHASE_2_INTEGRATION_TESTS.md  # Tests integración
│   ├── PHASE_3_E2E_TESTS.md          # Tests E2E
│   └── PHASE_4_CI_CD.md              # CI/CD
│
├── .github/
│   └── workflows/                    # GitHub Actions
│       ├── test.yml                  # CI tests
│       ├── quality.yml               # Linting
│       └── deploy-preview.yml        # Preview deploys
│
├── src/
│   └── types/
│       └── supabase.ts               # Tipos TS auto-generados
│
├── package.json                      # Monorepo root
├── .env.local                        # Variables entorno
├── .clinerules                       # Reglas de Cline
└── claude.md                         # Este archivo
```

---

## 3. Stack Tecnológico

### 3.1 Frontend Web

| Tecnología | Versión | Propósito |
|---|---|---|
| **Vite** | ^7.3.1 | Build tool y dev server ultra-rápido |
| **React** | ^18.3.1 | Librería UI con hooks |
| **TypeScript** | ^5.8.3 | Tipado estático end-to-end |
| **Tailwind CSS** | ^3.4.17 | Framework CSS utilitario |
| **shadcn/ui** | Latest | Componentes accesibles (Radix UI) |
| **React Router DOM** | ^6.30.1 | Routing SPA |
| **TanStack Query** | ^5.83.0 | Data fetching, caché y sincronización |
| **React Hook Form** | ^7.61.1 | Gestión de formularios |
| **Zod** | ^3.25.76 | Validación de esquemas |
| **Stripe.js** | ^8.7.0 | Pagos en el frontend |
| **Recharts** | ^2.15.4 | Gráficos y analytics |
| **Framer Motion** | ^12.26.2 | Animaciones fluidas |
| **date-fns** | ^3.6.0 | Manipulación de fechas |
| **Lucide React** | ^0.462.0 | Iconos modernos |
| **Sonner** | ^1.7.4 | Toast notifications |
| **PapaParse** | ^5.5.3 | Parsing CSV |
| **QRCode.react** | ^4.2.0 | Generación códigos QR |

### 3.2 Testing

| Herramienta | Versión | Propósito |
|---|---|---|
| **Vitest** | ^3.2.4 | Test runner (50+ tests unitarios) |
| **Testing Library** | ^16.3.2 | Testing componentes React |
| **Playwright** | ^1.58.2 | E2E testing (10+ journeys) |
| **MSW** | ^2.12.14 | API mocking |
| **@faker-js/faker** | ^10.3.0 | Datos de prueba |

### 3.3 Backend (Supabase)

| Tecnología | Propósito |
|---|---|
| **Supabase** | Backend as a Service (BaaS) |
| **PostgreSQL 17** | Base de datos relacional |
| **Supabase Auth** | Autenticación JWT + RLS |
| **Edge Functions** | Serverless (Deno runtime) |
| **Supabase Storage** | Almacenamiento archivos |
| **Row Level Security** | Control acceso nivel fila |

### 3.4 Integraciones Externas

| Servicio | Propósito | Variables Requeridas |
|---|---|---|
| **Stripe** | Pagos y suscripciones | `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET` |
| **Correos API** | Logística y envíos PUDO | `CORREOS_API_USER`, `CORREOS_API_PASSWORD` |
| **Swikly** | Garantías y depósitos | `SWIKLY_API_KEY` |
| **Resend** | Emails transaccionales | `RESEND_API_KEY` |
| **Brickset** | Datos sets LEGO | `BRICKSET_API_KEY` (opcional) |
| **Rebrickable** | Piezas LEGO | `REBRICKABLE_API_KEY` (opcional) |

### 3.5 DevOps y CI/CD

| Herramienta | Propósito |
|---|---|
| **Docker** | Supabase local (PostgreSQL, Auth, Storage) |
| **Supabase CLI** | Migraciones, funciones, tipos |
| **GitHub Actions** | CI/CD (4 workflows) |
| **Vercel** | Deployment frontend |
| **ESLint** | Linting código |

### 3.6 Sistema de Roles (RBAC)

| Rol | Acceso | Tablas con Acceso |
|---|---|---|
| `user` | Cliente suscriptor | `users`, `wishlist`, `shipments` (propios), `reviews` (propios) |
| `admin` | Acceso total backoffice | Todas las tablas |
| `operador` | Operaciones logísticas | `shipments`, `inventory_sets`, `reception_operations` |

---

## 4. Edge Functions (Supabase — Deno Runtime)

| Función | JWT | Rol | Propósito |
|---|:---:|---|---|
| `brickshare-qr-api` | ✅ | Admin/Operador | Validación códigos QR en puntos PUDO |
| `change-subscription` | ✅ | User | Cambiar/cancelar plan Stripe |
| `correos-logistics` | ✅ | Admin/Operador | Crear envíos con Correos API |
| `correos-pudo` | ❌ | Public | Consultar puntos PUDO cercanos |
| `create-checkout-session` | ✅ | User | Crear sesión pago Stripe |
| `create-logistics-package` | ✅ | Admin | Crear paquete logístico |
| `create-subscription-intent` | ✅ | User | Intent suscripción Stripe |
| `create-swikly-wish` | ✅ | Admin | Crear garantía Swikly |
| `delete-user` | ✅ | User/Admin | Eliminar cuenta (GDPR) |
| `fetch-lego-data` | ✅ | Admin | Enriquecer sets desde APIs |
| `process-assignment-payment` | ✅ | Admin | Pago asignación set |
| `send-brickshare-qr-email` | ✅ | Admin | Email con QR entrega/devolución |
| `send-email` | ✅ | Service | Email genérico vía Resend |
| `stripe-webhook` | ❌ | Stripe | Recibir eventos Stripe |
| `submit-donation` | ❌ | Public | Registrar donaciones |
| `swikly-manage-wish` | ✅ | Admin | Gestionar garantías Swikly |
| `swikly-webhook` | ❌ | Swikly | Recibir eventos Swikly |
| `update-shipment` | ✅ | Admin/Operador | Actualizar estado envío |

---

## 5. Tablas Principales de la Base de Datos

### Tabla `users` (Perfiles de Usuario)

Perfil completo vinculado a `auth.users`. Se crea automáticamente al registrar usuario.

**Campos clave**:
- `user_id` (FK → auth.users) — ID del usuario
- `subscription_type` — Plan: `brick_starter`, `brick_pro`, `brick_master`
- `subscription_status` — Estado: `active`, `inactive`
- `user_status` — Estado ciclo: `no_set`, `set_shipping`, `received`, `has_set`, `set_returning`, `suspended`, `cancelled`
- `stripe_customer_id` — ID cliente Stripe
- `referral_code` — Código referido (6 chars, auto-generado)
- `referred_by` — Usuario que refirió
- `referral_credits` — Créditos acumulados por referidos

### Tabla `sets` (Catálogo LEGO)

Catálogo de sets disponibles para alquiler.

**Campos clave**:
- `set_ref` — Referencia LEGO (ej: "75192")
- `set_name` — Nombre del set
- `set_theme` — Tema (Star Wars, City, Technic...)
- `set_piece_count` — Número de piezas
- `set_age_range` — Edad recomendada
- `set_price` — Precio referencia
- `set_status` — Estado: `active`, `inactive`, `in_repair`
- `catalogue_visibility` — Visible en catálogo público

### Tabla `inventory_sets` (Inventario Físico)

Control de stock de cada set.

**Campos clave**:
- `inventory_set_total_qty` — Cantidad en almacén
- `in_shipping` — Unidades en envío
- `in_use` — Unidades con usuarios
- `in_return` — Unidades en devolución
- `in_repair` — Unidades en reparación

### Tabla `shipments` (Envíos y Tracking)

Gestiona todo el ciclo de vida del envío.

**Estados**: `pending`, `preparation`, `assigned`, `in_transit`, `delivered`, `returned`, `return_in_transit`, `cancelled`

**Campos PUDO**:
- `pickup_type` — `correos` (externo) o `brickshare` (propio)
- `brickshare_pudo_id` — ID punto PUDO Brickshare
- `correos_shipment_id` — ID envío Correos

**Campos QR**:
- `delivery_qr_code` — QR validación entrega
- `return_qr_code` — QR validación devolución
- `delivery_validated_at` — Fecha validación entrega
- `return_validated_at` — Fecha validación devolución

**Campos Swikly**:
- `swikly_wish_id` — ID garantía
- `swikly_status` — Estado: `pending`, `wish_created`, `accepted`, `released`, `captured`
- `swikly_deposit_amount` — Monto depósito (céntimos)

### Tabla `wishlist` (Lista de Deseos)

Lista de sets deseados por usuarios para asignación automática.

**Campos**:
- `user_id`, `set_id`
- `status` — `true` = activo, `false` = ya asignado/removido
- `status_changed_at` — Fecha último cambio

### Tabla `reviews` (Reseñas)

Valoraciones de sets por usuarios.

**Campos**:
- `rating` — 1 a 5 estrellas
- `comment` — Texto libre
- `age_fit` — ¿Apropiado para edad indicada?
- `difficulty` — Dificultad construcción (1-5)
- `would_reorder` — ¿Volvería a alquilar?

### Tabla `referrals` (Programa de Referidos)

Tracking de referidos y recompensas.

**Estados**: `pending`, `credited`, `rejected`

**Campos**:
- `referrer_id` — Usuario que refirió
- `referee_id` — Usuario referido
- `reward_credits` — Créditos otorgados
- `stripe_coupon_id` — Cupón Stripe generado

### Tabla `brickshare_pudo_locations` (Puntos PUDO Propios)

Puntos de recogida/entrega gestionados por Brickshare.

**Campos**:
- `id` — Identificador del punto
- `name`, `address`, `city`, `postal_code`
- `latitude`, `longitude` — Coordenadas
- `opening_hours` — Horarios (JSONB)
- `is_active` — Si está operativo

### Tabla `reception_operations` (Operaciones de Recepción)

Registro de recepciones y mantenimiento post-devolución.

**Campos**:
- `event_id` (FK → shipments) — Envío asociado
- `weight_measured` — Peso medido en recepción
- `reception_completed` — Si recepción completada
- `missing_parts` — Notas piezas faltantes

### Tabla `qr_validation_logs` (Logs Validación QR)

Registro de todas las validaciones QR.

**Campos**:
- `shipment_id` — Envío asociado
- `qr_code` — Código validado
- `validation_type` — `delivery` o `return`
- `validation_status` — `success`, `expired`, `invalid`, `already_used`

---

## 6. Funciones RPC Principales

| Función | Parámetros | Descripción |
|---|---|---|
| `preview_assign_sets_to_users()` | — | Muestra asignaciones propuestas según wishlist |
| `confirm_assign_sets_to_users(p_user_ids)` | `uuid[]` | Confirma asignaciones: crea shipments, actualiza inventario |
| `delete_assignment_and_rollback(p_envio_id)` | `uuid` | Elimina asignación y revierte cambios |
| `update_set_status_from_return(p_set_id, p_new_status, p_envio_id)` | `uuid, text, uuid` | Actualiza estado set tras devolución |
| `generate_delivery_qr(p_shipment_id)` | `uuid` | Genera QR entrega (permanente, no expira) |
| `generate_return_qr(p_shipment_id)` | `uuid` | Genera QR devolución (permanente, no expira) |
| `validate_qr_code(p_qr_code)` | `text` | Valida QR y retorna info envío |
| `confirm_qr_validation(p_qr_code, p_validated_by)` | `text, text` | Confirma validación QR |
| `has_role(_user_id, _role)` | `uuid, app_role` | Verifica rol usuario (RLS) |
| `process_referral_credit(p_referee_user_id)` | `uuid` | Procesa crédito referido |

---

## 7. Flujos de Negocio Principales

### 7.1 Suscripción
```
Usuario → Selecciona plan → Stripe Checkout → 
Webhook confirma pago → Perfil actualizado → 
Usuario accede Dashboard
```

### 7.2 Asignación de Sets (Admin)
```
Admin ejecuta preview_assign_sets_to_users() → 
Revisa propuesta →
confirm_assign_sets_to_users([user_ids]) →
  - Crea shipments (estado: assigned)
  - Actualiza inventory_sets (decrementa stock, incrementa in_shipping)
  - Cambia user_status a 'set_shipping'
  - Desactiva wishlist correspondiente
  - Genera QR codes (delivery + return)
```

### 7.3 Envío y Entrega
```
Admin genera etiqueta (correos-logistics) →
Correos recoge paquete →
PUDO/Usuario recibe →
Validación QR (brickshare-qr-api) →
Estado shipment: delivered →
user_status: has_set
```

### 7.4 Devolución y Recepción
```
Usuario solicita devolución (Dashboard) →
Estado shipment: return_in_transit →
user_status: no_set →
Validación QR retorno →
Recepción en almacén (trigger crea reception_operation) →
Operador completa recepción (peso, piezas) →
reception_completed = true (trigger actualiza inventario) →
Set vuelve a stock (active o in_repair según estado)
```

### 7.5 Sistema PUDO Dual

**Correos PUDO (Externo)**:
- Usuario selecciona punto Correos cercano
- `correos-pudo` function consulta API Correos
- Info guardada en `users_correos_dropping`

**Brickshare PUDO (Propio)**:
- Puntos gestionados por Brickshare
- Validación QR en punto
- `brickshare_pudo_locations` tabla maestra
- `brickshare-qr-api` function valida entregas/devoluciones

### 7.6 Programa de Referidos
```
Usuario A comparte código referido →
Usuario B se registra con código →
Usuario B completa suscripción →
process_referral_credit() →
Usuario A recibe créditos →
Stripe coupon auto-generado
```

---

## 8. Sistema de Testing

### 8.1 Tests Unitarios (Vitest)

**Ubicación**: `apps/web/src/__tests__/unit/`

**Cobertura**: 50+ tests
- Hooks: `useProducts`, `useShipments`, `useWishlist`, `useAuth`
- Components: `ProfileCompletionModal`, `DeleteAccountDialog`, `ShipmentTimeline`
- Utils: `pudoService`, `validation`, `formatting`

**Ejecutar**:
```bash
npm run test           # Run once
npm run test:watch     # Watch mode
```

### 8.2 Tests de Integración (Vitest)

**Ubicación**: `apps/web/src/__tests__/integration/`

**Cobertura**: 15+ tests de flujos completos
- User flows: autenticación, suscripción, wishlist, account management
- Admin flows: dashboard, inventory, analytics, user management, shipments
- Operator flows: operations, logistics

**Ejecutar**:
```bash
npm run test
```

### 8.3 Tests E2E (Playwright)

**Ubicación**: `apps/web/e2e/`

**Cobertura**: 10+ journeys completos
- User journeys: onboarding, subscription, rental cycle
- Admin journeys: user management, assignment operations
- Operator journeys: logistics operations
- Error scenarios: payment failures, logistics failures

**Ejecutar**:
```bash
npm run test:e2e           # Run all
npm run test:e2e:ui        # UI mode
npm run test:e2e:headed    # Headed mode
npm run test:e2e:debug     # Debug mode
```

### 8.4 CI/CD (GitHub Actions)

**Workflows**:
1. `.github/workflows/test.yml` — Tests (unit + integration + E2E)
2. `.github/workflows/quality.yml` — Linting y type checking
3. `.github/workflows/deploy-preview.yml` — Preview deployments
4. `.github/dependabot.yml` — Dependency updates

---

## 9. Scripts de Utilidad Principales

### Gestión de BD

| Script | Propósito |
|---|---|
| `./scripts/safe-db-reset.sh` | ✅ Reset seguro con backup automático |
| `./scripts/restore-data.sh` | Restaurar backup específico |
| `scripts/verify-seed-results.ts` | Verificar integridad seed |
| `scripts/sync-auth-users-to-local.ts` | Sincronizar usuarios auth |

### Testing y Verificación

| Script | Propósito |
|---|---|
| `scripts/verify-edge-functions.sh` | Verificar todas las Edge Functions |
| `scripts/test-pudo-api.sh` | Test API PUDO Correos |
| `scripts/test-logistics-api.sh` | Test API logística |
| `scripts/test-complete-flow-with-emails.sh` | Test flujo completo con emails |

### Datos y Seeds

| Script | Propósito |
|---|---|
| `scripts/seed-sets-from-brickset.ts` | Importar sets desde Brickset |
| `scripts/create-user-brickshare.sql` | Crear usuario test |
| `scripts/simulate-brickshare-assignment.ts` | Simular asignación completa |

### Documentación

| Script | Propósito |
|---|---|
| `scripts/update-schema-docs.sh` | Actualizar `docs/DATABASE_SCHEMA.md` |
| `npm run dump-schema` | Alias del script anterior |

---

## 10. Comandos de Desarrollo

### Desarrollo Local

```bash
# Frontend
npm run dev                    # → http://localhost:5173
npm run build                  # Build producción
npm run preview                # Preview build

# Backend
supabase start                 # Iniciar Supabase local
supabase status                # Ver credenciales
supabase stop                  # Detener servicios

# Base de datos
./scripts/safe-db-reset.sh     # Reset con backup
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres  # Conectar

# Regenerar tipos
supabase gen types typescript --local > src/types/supabase.ts
```

### Testing

```bash
# Unit + Integration
npm run test                   # Run once
npm run test:watch             # Watch mode

# E2E
npm run test:e2e               # Run all E2E
npm run test:e2e:ui            # Interactive UI
npm run test:e2e:headed        # Ver browser
npm run test:e2e:debug         # Debug mode

# CI/CD (localmente)
./scripts/ci-test.sh           # Simular CI
```

### Linting y Quality

```bash
npm run lint                   # ESLint
npm run lint:fix               # Auto-fix
```

---

## 11. Convenciones y Reglas Estrictas

### Código
- **TypeScript estricto** en todo el proyecto
- **Componentes funcionales** con hooks (NO clases)
- **shadcn/ui** para UI — NO crear custom si existe en shadcn
- **TanStack Query** para data fetching — usar `staleTime` para caché
- **Zod** para validación con `react-hook-form`
- **date-fns** para fechas (NO moment.js)
- **Sonner** para toast notifications
- **❌ NUNCA harcodear valores configurables** en el código (URLs, IDs, claves, hosts, puertos, etc.)
  - Todas las variables configurables deben provenir de `import.meta.env` (frontend) o `Deno.env.get()` (Edge Functions)
  - Excepciones permitidas: constantes de lógica de negocio, enums estáticos, valores hardcoded en datos de test
  - Ejemplos de lo que NO se debe harcodear: `BS-PUDO-001`, URLs API, direcciones de servidores, configuraciones por entorno

### Base de Datos
- **NUNCA eliminar** archivos en `supabase/migrations/`
- **SIEMPRE** crear nuevas migraciones: `supabase migration new <nombre>`
- **RLS habilitado** en todas las tablas
- **set_ref** (ej: "75192") es el identificador humano de sets
- **user_id** siempre referencia `auth.users.id`

### Edge Functions
- **Deno runtime** — usar `Deno.env.get()` para env vars
- **CORS headers** en todas las respuestas
- **JWT verificación** en `supabase/config.toml`
- **Service Role Key** solo servidor — NUNCA en frontend

### Git
- Commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`
- Pre-commit hook auto-actualiza `docs/DATABASE_SCHEMA.md`

---

## 12. Estado Actual y Limitaciones

### ✅ Completado
- Frontend web 100% funcional
- Autenticación con Supabase Auth + RLS
- Catálogo con enriquecimiento APIs externas
- Suscripciones Stripe completas
- Sistema PUDO dual (Correos + Brickshare)
- Integración logística completa (Correos API)
- Sistema QR permanente para validación
- Backoffice admin completo
- Panel operador logístico (web)
- **App móvil operadores PUDO** (React Native/Expo en `../Brickshare_logistics/apps/mobile/`)
- Wishlist, reviews, referidos, donaciones
- Sistema de testing completo (Unit + Integration + E2E)
- CI/CD con GitHub Actions
- Programa de referidos funcional
- Sistema de garantías con Swikly

### ⚠️ En Desarrollo / Limitaciones
- App iOS consumidor incompleta (React Native/Expo en `apps/ios/`)
- Sin Supabase Cloud — 100% desarrollo local
- Cobertura tests ~60% (objetivo: 80%)
- Documentación API externa (Correos) limitada
- Sin monitoring/alerting en producción

### 📋 Próximos Pasos
1. Completar paridad app iOS con web
2. Aumentar cobertura tests a 80%+
3. Implementar sistema de notificaciones push
4. Dashboard analytics avanzado
5. Sistema de recomendaciones ML

---

## 13. Documentación de Referencia

Antes de preguntar, consulta:

| Archivo | Contenido |
|---|---|
| `docs/PROJECT_OVERVIEW.md` | Visión general, estado proyecto |
| `docs/ARCHITECTURE.md` | Diseño técnico, diagramas |
| `docs/DATABASE_SCHEMA.md` | Esquema completo auto-generado |
| `docs/LOCAL_DEVELOPMENT.md` | Setup, comandos, troubleshooting |
| `docs/API_REFERENCE.md` | Edge Functions detalladas |
| `docs/BRICKSHARE_PUDO.md` | Integración PUDO/Correos |
| `tests/START_HERE.md` | Guía inicio testing |
| `README.md` | Quick start básico |

---

## 14. App Móvil para Operadores PUDO

**Ubicación**: `../Brickshare_logistics/apps/mobile/`

Aplicación React Native (Expo) completa para operadores de puntos PUDO. Permite validar códigos QR para recepción de sets (entrega/devolución) con funcionalidad offline-first.

---

**Última actualización**: 27/03/2026  
**Modo de desarrollo**: 100% Local (Docker + Supabase CLI)  
**App Operadores**: Disponible en `../Brickshare_logistics/apps/mobile/`
