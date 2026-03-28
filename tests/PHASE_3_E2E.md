# 🎬 Fase 3: E2E Tests Specification

## Overview

**Fase 3** implementa ~10 tests E2E que validan flujos críticos de negocio en un browser real usando Playwright.

| Categoría | Tests | Estado |
|---|---|---|
| **Critical User Flows** | ~4 tests | ⏳ Pendiente |
| **Critical Admin Flows** | ~3 tests | ⏳ Pendiente |
| **Critical Business Flows** | ~3 tests | ⏳ Pendiente |
| **Total Fase 3** | **~10 tests** | **⏳ Pendiente** |

---

## 🎯 Setup Requerido

### Dependencias
```bash
npm install --save-dev @playwright/test
```

### Configuración
- `playwright.config.ts` - Configuración de Playwright
- `e2e/` - Carpeta de tests E2E
- `e2e/fixtures/` - Fixtures para E2E

### Variables de Entorno
```
E2E_BASE_URL=http://localhost:5173
E2E_API_URL=http://localhost:3000
```

---

## 👤 Critical User Flows (~4 tests)

### 1. Complete User Journey (1 test)

**Archivo**: `e2e/user-journey.spec.ts`

```gherkin
Scenario: User completes full journey from signup to receiving a set
  Given user visits landing page
  When user clicks "Sign Up"
  Then user fills signup form
  And user confirms email
  And user completes profile
  And user selects PUDO location
  And user selects subscription plan (Premium)
  And user completes Stripe payment
  Then user sees dashboard with available sets
  When user clicks first set
  Then user sees set details
  And user clicks "Add to Wishlist"
  Then user sees wishlist updated
  When admin assigns set to user
  And shipment is created
  Then user sees "Set in Transit"
  When shipment arrives at PUDO
  And user scans QR code
  Then user sees "Set Received"
```

**Assertions**:
- ✅ User autenticado
- ✅ Profile completado
- ✅ Subscription activa
- ✅ Set asignado
- ✅ Shipment rastreado
- ✅ Email notifications enviadas

### 2. Subscription Purchase Flow (1 test)

**Archivo**: `e2e/subscription-purchase.spec.ts`

```gherkin
Scenario: User upgrades subscription through Stripe
  Given user is logged in with Basic plan
  When user goes to account settings
  And user clicks "Upgrade Plan"
  And user selects "Premium" plan
  And user clicks "Checkout"
  Then Stripe checkout modal appears
  When user fills card details (test card)
  And user submits payment
  Then payment processes successfully
  And user sees "Subscription Updated"
  And user plan changes to Premium
```

**Assertions**:
- ✅ Stripe integration funciona
- ✅ Plan updated en BD
- ✅ New limits aplicados
- ✅ Email confirmación enviado

### 3. Set Return Flow (1 test)

**Archivo**: `e2e/set-return.spec.ts`

```gherkin
Scenario: User returns set and receives next one
  Given user has active set in use
  When user clicks "Return This Set"
  Then return QR code appears
  When user takes QR to PUDO
  And operator scans QR
  Then shipment marked as "returned"
  And system automatically assigns new set
  And new shipment created
  Then user sees new set in transit
```

**Assertions**:
- ✅ Return shipment creado
- ✅ QR validado
- ✅ New assignment automático
- ✅ Notifications enviadas

### 4. Wishlist & Browse Flow (1 test)

**Archivo**: `e2e/wishlist-browse.spec.ts`

```gherkin
Scenario: User browses catalog and manages wishlist
  Given user is on catalog page
  When user filters by "Star Wars" theme
  Then only SW sets appear
  When user sorts by "Most Pieces"
  Then sets reordered by piece count
  When user adds 3 sets to wishlist
  Then wishlist count shows 3
  When user reorders wishlist by drag & drop
  Then new order persists
```

**Assertions**:
- ✅ Filters funcionan
- ✅ Sorting funciona
- ✅ Wishlist actualiza
- ✅ Persistence en BD

---

## 🛠️ Critical Admin Flows (~3 tests)

### 5. Set Assignment Flow (1 test)

**Archivo**: `e2e/admin-assignment.spec.ts`

```gherkin
Scenario: Admin previews, reviews and confirms set assignments
  Given admin is logged in
  When admin goes to "Set Assignment"
  And admin clicks "Preview Assignments"
  Then preview shows proposed assignments
  When admin reviews the proposal
  And admin clicks "Confirm"
  Then system creates shipments
  And QR codes generated
  And emails sent to users
```

**Assertions**:
- ✅ Preview datos correctos
- ✅ Shipments creados
- ✅ QR codes válidos
- ✅ Emails enviados

### 6. Inventory Management (1 test)

**Archivo**: `e2e/admin-inventory.spec.ts`

```gherkin
Scenario: Admin manages inventory and maintenance
  Given admin is on inventory page
  When admin views "All Sets"
  Then sees sets by status
  When admin marks set as "damaged"
  Then status changes to "en_reparacion"
  When admin creates purchase order for pieces
  Then purchase logged
  When admin marks set as "fixed"
  Then status back to "active"
```

**Assertions**:
- ✅ Status cambios funcionar
- ✅ Purchase order creado
- ✅ Maintenance log actualizado

### 7. User Management (1 test)

**Archivo**: `e2e/admin-users.spec.ts`

```gherkin
Scenario: Admin manages users and subscriptions
  Given admin is on users page
  When admin searches for user
  Then user found in results
  When admin clicks user
  Then sees complete profile
  When admin changes user subscription
  Then change applies immediately
  When admin views user activity
  Then sees shipments and returns
```

**Assertions**:
- ✅ Search funciona
- ✅ Subscription change actualiza
- ✅ Activity log completo

---

## 💼 Critical Business Flows (~3 tests)

### 8. Payment & Billing Integrity (1 test)

**Archivo**: `e2e/billing-flow.spec.ts`

```gherkin
Scenario: Complete billing workflow
  Given user purchases subscription
  When payment processes
  Then Stripe webhook received
  And subscription status updated
  When subscription renews monthly
  Then automatic charge processed
  And user notified
```

**Assertions**:
- ✅ Stripe webhook funciona
- ✅ Subscription estado sincronizado
- ✅ Recurring charges funcionar

### 9. Logistics Integrity (1 test)

**Archivo**: `e2e/logistics-flow.spec.ts`

```gherkin
Scenario: Complete logistics flow with tracking
  Given set assigned to user
  When shipment created with Correos
  Then tracking number in system
  When shipment in transit
  Then user sees status update
  When user receives at PUDO
  And scans QR
  Then Correos tracking confirmed
  And system marks delivered
```

**Assertions**:
- ✅ Correos API integración
- ✅ Tracking actualiza
- ✅ QR validation funciona
- ✅ Status sincronizado

### 10. Data Integrity & Security (1 test)

**Archivo**: `e2e/security-flow.spec.ts`

```gherkin
Scenario: Data integrity and security checks
  Given user logged in
  When user tries to access other user's data
  Then access denied
  When user deletes account
  Then all data removed
  And personal info deleted from all systems
  When user logs in with deleted account
  Then authentication fails
```

**Assertions**:
- ✅ RLS policies enforced
- ✅ Account deletion completo
- ✅ Data privacy maintained

---

## 📊 Summary

| Categoría | Tests | Tiempo | Cobertura |
|---|---|---|---|
| **User Flows** | 4 | ~2m | Critical paths |
| **Admin Flows** | 3 | ~1.5m | Core operations |
| **Business Flows** | 3 | ~1.5m | Revenue & compliance |
| **Total Fase 3** | **10** | **~5m** | **Critical workflows** |

---

## 🔧 Technical Setup

### Playwright Config
```typescript
// playwright.config.ts
export default defineConfig({
  testDir: './e2e',
  webServer: {
    command: 'npm run dev',
    port: 5173,
  },
  use: {
    baseURL: 'http://localhost:5173',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
});
```

### Running Tests
```bash
# Run all E2E tests
npx playwright test

# Run specific test
npx playwright test user-journey

# Debug mode
npx playwright test --debug

# View report
npx playwright show-report
```

---

## ✅ Implementation Steps

1. Instalar Playwright
2. Configurar `playwright.config.ts`
3. Crear E2E fixtures
4. Implementar 10 tests
5. Configurar CI/CD para E2E
6. Documentar E2E patterns

---

**Próxima Fase**: [PHASE 4 - CI/CD]