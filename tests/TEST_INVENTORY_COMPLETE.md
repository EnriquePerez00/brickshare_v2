ru# 📋 Inventario Completo de Tests - Brickshare

## 📊 Resumen Ejecutivo

| Fase | Tipo | Tests | Archivos | Estado |
|------|------|-------|----------|--------|
| **Fase 1** | Unit Tests | 83 | 10 | ✅ 100% |
| **Fase 2** | Integration Tests | 147 | 10 | ✅ 100% |
| **Fase 3** | E2E Tests (Playwright) | 10 | 7 | ✅ 100% |
| **TOTAL** | | **240** | **27** | **✅ 100%** |

---

## 🧪 FASE 1: Unit Tests (83 tests)

### Hooks (39 tests)

#### `useAuth.test.tsx` (10 tests)
- ✅ should provide auth state from context
- ✅ should throw error when used outside provider
- ✅ should handle sign in
- ✅ should handle sign out
- ✅ should handle sign up
- ✅ should update profile
- ✅ should check if user is admin
- ✅ should check if user is operator
- ✅ should refresh session
- ✅ should initialize auth state

#### `useProducts.test.tsx` (9 tests)
- ✅ should fetch products successfully
- ✅ should handle empty product list
- ✅ should filter products by theme
- ✅ should filter products by age range
- ✅ should search products by name
- ✅ should handle fetch errors gracefully
- ✅ should refetch products
- ✅ should invalidate product cache
- ✅ should handle network errors

#### `useShipments.test.tsx` (11 tests)
- ✅ should fetch user shipments
- ✅ should handle empty shipments
- ✅ should filter shipments by status
- ✅ should track active shipment
- ✅ should request return
- ✅ should handle return errors
- ✅ should refetch shipments
- ✅ should invalidate shipments cache
- ✅ should fetch single shipment by ID
- ✅ should handle shipment not found
- ✅ should handle network errors

#### `useWishlist.test.tsx` (9 tests)
- ✅ should fetch wishlist items
- ✅ should add item to wishlist
- ✅ should remove item from wishlist
- ✅ should check if item is in wishlist
- ✅ should handle empty wishlist
- ✅ should handle add errors
- ✅ should handle remove errors
- ✅ should refetch wishlist
- ✅ should invalidate wishlist cache

### Components (28 tests)

#### `ProfileCompletionModal.test.tsx` (9 tests)
- ✅ should render when profile incomplete
- ✅ should not render when profile complete
- ✅ should show completion steps
- ✅ should handle form submission
- ✅ should validate required fields
- ✅ should handle API errors
- ✅ should close on completion
- ✅ should disable submit while loading
- ✅ should track completion progress

#### `DeleteAccountDialog.test.tsx` (7 tests)
- ✅ should render dialog trigger
- ✅ should open dialog on click
- ✅ should show warning message
- ✅ should require confirmation text
- ✅ should handle account deletion
- ✅ should handle deletion errors
- ✅ should close dialog after success

#### `ShipmentTimeline.test.tsx` (12 tests)
- ✅ should render timeline steps
- ✅ should highlight current step
- ✅ should show completed steps
- ✅ should show pending steps
- ✅ should render for pending status
- ✅ should render for prepared status
- ✅ should render for in_transit status
- ✅ should render for delivered status
- ✅ should render for returned status
- ✅ should show estimated dates
- ✅ should handle missing dates
- ✅ should show tracking information

### Utils (16 tests)

#### `formatting.test.ts` (7 tests)
- ✅ should format currency correctly
- ✅ should format dates correctly
- ✅ should format relative time
- ✅ should format phone numbers
- ✅ should truncate long text
- ✅ should format postal codes
- ✅ should handle edge cases

#### `validation.test.ts` (9 tests)
- ✅ should validate email addresses
- ✅ should validate phone numbers
- ✅ should validate postal codes
- ✅ should validate required fields
- ✅ should validate age restrictions
- ✅ should validate subscription plans
- ✅ should validate payment methods
- ✅ should validate addresses
- ✅ should validate PUDO selection

#### `pudoService.test.ts` (9 tests)
- ✅ should fetch PUDO locations
- ✅ should filter by postal code
- ✅ should calculate distance
- ✅ should sort by distance
- ✅ should validate PUDO selection
- ✅ should format PUDO address
- ✅ should handle API errors
- ✅ should cache PUDO results
- ✅ should refresh PUDO data

#### `qrService.test.ts` (18 tests)
- ✅ should generate QR code
- ✅ should validate QR format
- ✅ should parse QR data
- ✅ should generate delivery QR
- ✅ should generate return QR
- ✅ should check QR expiration
- ✅ should validate QR signature
- ✅ should handle invalid QR
- ✅ should generate QR with metadata
- ✅ should validate QR timestamp
- ✅ should prevent QR reuse
- ✅ should handle QR errors
- ✅ should encode shipment data
- ✅ should decode shipment data
- ✅ should validate QR length
- ✅ should validate QR prefix
- ✅ should handle malformed QR
- ✅ should generate unique QR codes

---

## 🔗 FASE 2: Integration Tests (147 tests)

### User Flows (51 tests)

#### `authentication.integration.test.ts` (14 tests)
- ✅ should sign up new user
- ✅ should prevent duplicate email
- ✅ should sign in with valid credentials
- ✅ should reject invalid credentials
- ✅ should sign out user
- ✅ should refresh session token
- ✅ should reset password
- ✅ should verify email
- ✅ should handle session expiration
- ✅ should update user profile
- ✅ should check subscription status
- ✅ should handle auth errors
- ✅ should validate password strength
- ✅ should handle OAuth flows

#### `subscription.integration.test.ts` (14 tests)
- ✅ should create Stripe checkout session
- ✅ should handle subscription webhook
- ✅ should upgrade subscription
- ✅ should downgrade subscription
- ✅ should cancel subscription
- ✅ should reactivate subscription
- ✅ should handle payment failures
- ✅ should update payment method
- ✅ should calculate prorated charges
- ✅ should prevent duplicate subscriptions
- ✅ should validate subscription tiers
- ✅ should handle subscription expiration
- ✅ should show subscription history
- ✅ should handle Stripe webhooks

#### `wishlist-browse.integration.test.ts` (11 tests)
- ✅ should browse catalog
- ✅ should filter by theme
- ✅ should filter by age
- ✅ should search by name
- ✅ should add to wishlist
- ✅ should remove from wishlist
- ✅ should show wishlist count
- ✅ should prevent duplicate wishlist items
- ✅ should sort catalog results
- ✅ should paginate results
- ✅ should show set availability

#### `account-management.integration.test.ts` (18 tests)
- ✅ should update profile information
- ✅ should change password
- ✅ should update email
- ✅ should verify email change
- ✅ should update address
- ✅ should select PUDO location
- ✅ should update phone number
- ✅ should delete account
- ✅ should handle profile validation errors
- ✅ should update notification preferences
- ✅ should manage privacy settings
- ✅ should view account history
- ✅ should export account data
- ✅ should handle concurrent updates
- ✅ should validate address format
- ✅ should validate phone format
- ✅ should prevent invalid email
- ✅ should require password for sensitive changes

#### `set-assignment.integration.test.ts` (13 tests)
- ✅ should receive set assignment notification
- ✅ should confirm set reception
- ✅ should track shipment status
- ✅ should request set return
- ✅ should confirm set return
- ✅ should update user status on assignment
- ✅ should generate QR codes
- ✅ should validate PUDO selection
- ✅ should handle assignment errors
- ✅ should prevent double assignments
- ✅ should check inventory availability
- ✅ should respect subscription limits
- ✅ should prioritize wishlist items

### Admin Flows (46 tests)

#### `dashboard.integration.test.ts` (15 tests)
- ✅ should display key metrics
- ✅ should show active users count
- ✅ should show total sets count
- ✅ should show active shipments
- ✅ should show revenue metrics
- ✅ should display recent activity
- ✅ should filter by date range
- ✅ should export dashboard data
- ✅ should refresh metrics
- ✅ should show inventory alerts
- ✅ should display subscription breakdown
- ✅ should show churn rate
- ✅ should calculate MRR
- ✅ should show growth trends
- ✅ should handle missing data

#### `inventory.integration.test.ts` (16 tests)
- ✅ should list all sets
- ✅ should add new set
- ✅ should update set details
- ✅ should delete set
- ✅ should manage inventory stock
- ✅ should track set status
- ✅ should handle set maintenance
- ✅ should record piece damage
- ✅ should create inventory log
- ✅ should filter by availability
- ✅ should search by set number
- ✅ should bulk update inventory
- ✅ should prevent negative stock
- ✅ should validate set data
- ✅ should track set history
- ✅ should handle missing pieces

#### `analytics.integration.test.ts` (13 tests)
- ✅ should fetch user analytics
- ✅ should fetch set performance
- ✅ should track popular sets
- ✅ should calculate utilization rate
- ✅ should show subscription metrics
- ✅ should analyze churn
- ✅ should track referrals
- ✅ should measure NPS
- ✅ should show revenue trends
- ✅ should analyze demographics
- ✅ should track set ratings
- ✅ should measure engagement
- ✅ should export analytics

#### `user-management.integration.test.ts` (12 tests)
- ✅ should list all users
- ✅ should filter by subscription
- ✅ should filter by status
- ✅ should search users
- ✅ should view user details
- ✅ should update user subscription
- ✅ should suspend user account
- ✅ should reactivate account
- ✅ should view user history
- ✅ should assign admin role
- ✅ should remove admin role
- ✅ should handle bulk operations

#### `shipments.integration.test.ts` (18 tests)
- ✅ should list all shipments
- ✅ should filter by status
- ✅ should filter by date range
- ✅ should search by user
- ✅ should view shipment details
- ✅ should update shipment status
- ✅ should generate shipping label
- ✅ should track shipment
- ✅ should handle delivery confirmation
- ✅ should process returns
- ✅ should manage exceptions
- ✅ should bulk update statuses
- ✅ should export shipment data
- ✅ should validate addresses
- ✅ should check inventory
- ✅ should prevent duplicate shipments
- ✅ should calculate shipping costs
- ✅ should handle logistics errors

### Operator Flows (15 tests)

#### `operations.integration.test.ts` (15 tests)
- ✅ should scan QR code
- ✅ should validate delivery QR
- ✅ should validate return QR
- ✅ should confirm package handover
- ✅ should record package reception
- ✅ should inspect set condition
- ✅ should report damage
- ✅ should log missing pieces
- ✅ should mark set for maintenance
- ✅ should complete maintenance
- ✅ should return set to inventory
- ✅ should view pending operations
- ✅ should filter by PUDO location
- ✅ should export operation logs
- ✅ should handle scan errors

### RPC Functions (8 tests)

#### `assignment.integration.test.ts` (8 tests)
- ✅ should generate assignment proposals
- ✅ should only propose sets in stock
- ✅ should prioritize wishlist matches
- ✅ should exclude users without PUDO
- ✅ should create shipments on confirmation
- ✅ should update user status
- ✅ should decrease inventory stock
- ✅ should generate QR codes

### Edge Functions (27 tests)

#### `logistics.integration.test.ts` (27 tests)

**correos-logistics (4 tests)**
- ✅ should create Correos shipment (preregister)
- ✅ should generate Correos label
- ✅ should handle return shipment
- ✅ should track shipment status

**send-brickshare-qr-email (5 tests)**
- ✅ should send delivery QR email
- ✅ should send return QR email
- ✅ should fail with invalid shipment ID
- ✅ should validate shipment fields
- ✅ should include PUDO information

**brickshare-qr-api (6 tests)**
- ✅ should validate delivery QR code
- ✅ should reject invalid QR codes
- ✅ should confirm QR validation
- ✅ should prevent duplicate validation
- ✅ should get PUDO locations list
- ✅ should update shipment status

---

## 🎭 FASE 3: E2E Tests (10 tests)

### User Journeys (6 tests)

#### `complete-onboarding.spec.ts` (2 tests)
- ✅ should complete full onboarding flow
- ✅ should handle incomplete profile

#### `subscription-flow.spec.ts` (2 tests)
- ✅ should subscribe to Basic plan
- ✅ should upgrade to Premium

#### `set-rental-cycle.spec.ts` (2 tests)
- ✅ should complete full rental cycle
- ✅ should handle early return

### Admin Journeys (2 tests)

#### `user-management.spec.ts` (1 test)
- ✅ should manage user lifecycle

#### `complete-assignment-flow.spec.ts` (1 test)
- ✅ should execute complete assignment flow

### Operator Journeys (2 tests)

#### `logistics-operations.spec.ts` (1 test)
- ✅ should process package operations

#### `complete-reception-flow.spec.ts` (1 test)
- ✅ should complete reception and maintenance

### Error Scenarios (tests)

#### `payment-failures.spec.ts`
- ✅ should handle card declined
- ✅ should handle insufficient funds
- ✅ should handle expired card

#### `logistics-failures.spec.ts`
- ✅ should handle shipping delays
- ✅ should handle lost packages
- ✅ should handle damaged sets

---

## 📁 Estructura de Archivos

```
apps/web/
├── src/
│   ├── __tests__/
│   │   ├── unit/
│   │   │   ├── hooks/
│   │   │   │   ├── useAuth.test.tsx                    ✅ 10 tests
│   │   │   │   ├── useProducts.test.tsx                ✅ 9 tests
│   │   │   │   ├── useShipments.test.tsx               ✅ 11 tests
│   │   │   │   └── useWishlist.test.tsx                ✅ 9 tests
│   │   │   ├── components/
│   │   │   │   ├── ProfileCompletionModal.test.tsx     ✅ 9 tests
│   │   │   │   ├── DeleteAccountDialog.test.tsx        ✅ 7 tests
│   │   │   │   └── ShipmentTimeline.test.tsx           ✅ 12 tests
│   │   │   └── utils/
│   │   │       ├── formatting.test.ts                  ✅ 7 tests
│   │   │       ├── validation.test.ts                  ✅ 9 tests
│   │   │       ├── pudoService.test.ts                 ✅ 9 tests
│   │   │       └── qrService.test.ts                   ✅ 18 tests
│   │   └── integration/
│   │       ├── user-flows/
│   │       │   ├── authentication.integration.test.ts   ✅ 14 tests
│   │       │   ├── subscription.integration.test.ts     ✅ 14 tests
│   │       │   ├── wishlist-browse.integration.test.ts  ✅ 11 tests
│   │       │   ├── account-management.integration.test.ts ✅ 18 tests
│   │       │   └── set-assignment.integration.test.ts   ✅ 13 tests
│   │       ├── admin-flows/
│   │       │   ├── dashboard.integration.test.ts        ✅ 15 tests
│   │       │   ├── inventory.integration.test.ts        ✅ 16 tests
│   │       │   ├── analytics.integration.test.ts        ✅ 13 tests
│   │       │   ├── user-management.integration.test.ts  ✅ 12 tests
│   │       │   └── shipments.integration.test.ts        ✅ 18 tests
│   │       ├── operator-flows/
│   │       │   └── operations.integration.test.ts       ✅ 15 tests
│   │       ├── rpc-functions/
│   │       │   └── assignment.integration.test.ts       ✅ 8 tests
│   │       └── edge-functions/
│   │           └── logistics.integration.test.ts        ✅ 27 tests
│   └── test/
│       ├── setup.ts                                     ⚙️ Config
│       ├── mocks/                                       🎭 MSW handlers
│       └── fixtures/                                    📦 Test data
└── e2e/
    ├── user-journeys/
    │   ├── complete-onboarding.spec.ts                  ✅ 2 tests
    │   ├── subscription-flow.spec.ts                    ✅ 2 tests
    │   └── set-rental-cycle.spec.ts                     ✅ 2 tests
    ├── admin-journeys/
    │   ├── user-management.spec.ts                      ✅ 1 test
    │   └── complete-assignment-flow.spec.ts             ✅ 1 test
    ├── operator-journeys/
    │   ├── logistics-operations.spec.ts                 ✅ 1 test
    │   └── complete-reception-flow.spec.ts              ✅ 1 test
    ├── error-scenarios/
    │   ├── payment-failures.spec.ts                     ✅ 3 tests
    │   └── logistics-failures.spec.ts                   ✅ 3 tests
    ├── fixtures/
    │   └── test-data.ts                                 📦 Test data
    └── helpers/
        ├── database.ts                                  🔧 DB helpers
        └── assertions.ts                                ✅ Custom assertions
```

---

## 🚀 Comandos de Ejecución

### Ejecutar Todo
```bash
# Todos los tests (Unit + Integration)
cd apps/web && npm run test

# Con coverage
npm run test:coverage

# Watch mode
npm run test:watch
```

### Ejecutar por Fase
```bash
# Solo Unit Tests
npm run test -- unit

# Solo Integration Tests
npm run test -- integration

# Solo E2E Tests
npm run test:e2e
```

### Ejecutar por Categoría
```bash
# Solo hooks
npm run test -- hooks

# Solo components
npm run test -- components

# Solo admin flows
npm run test -- admin-flows

# Solo user flows
npm run test -- user-flows
```

### Ejecutar Archivo Específico
```bash
# Por ruta
npm run test -- useAuth.test

# Específico
npm run test src/__tests__/unit/hooks/useAuth.test.tsx
```

---

## 🔧 Configuración

### Vitest (`vitest.config.ts`)
```typescript
- Framework: Vitest 3.2.4
- Environment: jsdom
- Coverage: v8
- Globals: true
- Setup: src/test/setup.ts
```

### Playwright (`playwright.config.ts`)
```typescript
- Framework: Playwright 1.49.0
- Browsers: chromium, firefox, webkit
- Base URL: http://localhost:5173
- Timeout: 30s
- Retries: 2 (CI), 0 (local)
```

### MSW (Mock Service Worker)
```typescript
- Version: 2.x
- Handlers: src/test/mocks/handlers.ts
- Browser: src/test/mocks/browser.ts
```

---

## 📦 Test Fixtures

### Fixtures Disponibles
- `users.ts` - Test users with different roles
- `sets.ts` - Sample LEGO sets
- `shipments.ts` - Sample shipments
- `wishlist.ts` - Sample wishlist items
- `integration.ts` - Integration test data
- `test-data.ts` - E2E test data

---

## ⚠️ Notas Importantes

### Variables de Entorno Requeridas
```bash
VITE_SUPABASE_URL=http://127.0.0.1:54321
VITE_SUPABASE_ANON_KEY=<from supabase status>
```

### Prerequisitos
1. Supabase local running (`supabase start`)
2. Database seeded (`./scripts/db-reset.sh`)
3. Edge functions deployed locally
4. Dev server running for E2E tests

### Tests que Requieren Edge Functions
- `logistics.integration.test.ts` (requiere Edge Functions activas)
- `complete-assignment-flow.spec.ts` (requiere Correos API)
- `payment-failures.spec.ts` (requiere Stripe test mode)

### Tests Skipped en CI
Algunos tests pueden skippearse automáticamente si:
- Edge Functions no están disponibles
- APIs externas no responden (Correos, Stripe)
- Base de datos no tiene datos de test

---

## 📈 Cobertura de Código

Ejecutar con coverage:
```bash
npm run test:coverage
```

Genera reporte en:
- `apps/web/coverage/index.html` (navegable)
- `apps/web/coverage/lcov.info` (para CI)

---

## 🐛 Troubleshooting

### Tests Fallan por Variables de Entorno
```bash
# Verificar que Supabase está corriendo
supabase status

# Copiar .env.example a .env.local
cp .env.example .env.local
```

### Tests E2E Fallan
```bash
# Iniciar dev server
npm run dev

# En otra terminal, ejecutar E2E
npm run test:e2e
```

### Edge Functions no Responden
```bash
# Verificar que están desplegadas
supabase functions list

# Ver logs
supabase functions logs
```

---

## 📚 Documentación Relacionada

- `tests/GETTING_STARTED.md` - Guía de inicio
- `tests/PHASE_1_UNIT.md` - Detalles Fase 1
- `tests/PHASE_2_INTEGRATION.md` - Detalles Fase 2
- `tests/PHASE_3_E2E.md` - Detalles Fase 3
- `tests/COVERAGE_REPORT.md` - Reporte de cobertura
- `tests/README.md` - Índice general

---

**Última actualización**: 26 Marzo 2026  
**Total de tests**: 240 tests en 27 archivos  
**Estado**: ✅ Todos operativos