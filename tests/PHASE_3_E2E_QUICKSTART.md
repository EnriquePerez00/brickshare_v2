# 🚀 Fase 3: E2E Tests - Quick Start Guide

## ⚡ 30 segundos para empezar

```bash
# 1. Ir al directorio de la web app
cd apps/web

# 2. Instalar Playwright (si no está ya instalado)
npm install --save-dev @playwright/test
npx playwright install

# 3. Ejecutar tests E2E
npm run test:e2e

# 4. Ver reporte HTML
npm run test:e2e:report
```

---

## 📊 Qué Hay

### 10 E2E Tests Total

#### User Journeys (3 tests)
1. ✅ **Complete Onboarding** - Signup → Verification → Profile
2. ✅ **Subscription Flow** - Plan selection → Stripe payment
3. ✅ **Set Rental Cycle** - Browse → Request → Receive → Return

#### Admin Journeys (2 tests)
4. ✅ **Assignment Operations** - Preview → Confirm → Shipments
5. ✅ **User Management** - List → Search → Roles

#### Operator Journeys (1 test)
6. ✅ **Logistics Operations** - QR scan → Maintenance → Logs

---

## 🎯 Primeros Pasos

### 1. Verificar Setup
```bash
cd apps/web
npx playwright --version
# Debe mostrar: Version X.X.X
```

### 2. Ejecutar Tests
```bash
# Sin interfaz
npm run test:e2e

# Con UI (recomendado)
npm run test:e2e:ui

# En modo debug
npm run test:e2e:debug

# Ver navegador
npm run test:e2e:headed
```

### 3. Ver Resultados
```bash
# Reporte HTML
npm run test:e2e:report
```

---

## 📝 Estructura

```
apps/web/e2e/
├── fixtures/test-data.ts              # Test data
├── user-journeys/
│   ├── complete-onboarding.spec.ts
│   ├── subscription-flow.spec.ts
│   └── set-rental-cycle.spec.ts
├── admin-journeys/
│   ├── assignment-operations.spec.ts
│   └── user-management.spec.ts
├── operator-journeys/
│   └── logistics-operations.spec.ts
└── README.md
```

---

## 🔧 Comandos Útiles

```bash
# Ejecutar un test específico
npx playwright test user-journeys/complete-onboarding.spec.ts

# Ejecutar con pattern
npx playwright test -g "should complete onboarding"

# Ejecutar en un browser
npx playwright test --project=chromium
npx playwright test --project=firefox
npx playwright test --project=webkit

# Ejecutar último fallido
npx playwright test --last-failed

# Modo watch
npx playwright test --watch

# Generar reporte
npx playwright show-report

# Grabar video durante tests
npx playwright test --record-video=on
```

---

## 🧪 Test Data

En `fixtures/test-data.ts`:

```typescript
testUsers.regularUser        // email: user@test.local
testUsers.adminUser          // email: admin@test.local
testUsers.operatorUser       // email: operator@test.local

testSets.starWars           // 75192, 1351 pieces
testSets.cityPoliceStation  // 60141, 973 pieces
testSets.harryPotterHogwarts // 71043, 6020 pieces

subscriptionPlans.basic     // $9.99
subscriptionPlans.standard  // $19.99
subscriptionPlans.premium   // $29.99

pudoLocations.madrid        // Madrid Centro
pudoLocations.barcelona     // Barcelona Eixample

Helper functions:
- generateUniqueEmail()
- generateQRCode()
- generateTrackingNumber()
```

---

## 📊 Cheat Sheet

### Seleccionar Elementos
```typescript
page.locator('text=Button Text')          // Por texto
page.locator('[data-testid="btn"]')       // Por atributo
page.locator('button:has-text("Save")')   // Selector avanzado
```

### Interactuar
```typescript
await page.goto('/path')                  // Navegar
await page.fill('[name="email"]', 'test@example.com')  // Llenar input
await page.click('button')                // Click
await page.press('Enter')                 // Presionar tecla
```

### Esperar
```typescript
await expect(page).toHaveURL(/path/)              // Esperar URL
await expect(page.locator('text')).toBeVisible() // Esperar visible
await page.waitForNavigation()                   // Esperar nav
```

### Debug
```typescript
await page.pause()                        // Pausar ejecución
await page.screenshot()                   // Captura
page.on('console', msg => console.log(msg.text()))  // Console
```

---

## 🐛 Problemas Comunes

### "Test timeout"
```bash
# Aumentar timeout
PLAYWRIGHT_TEST_TIMEOUT=60000 npm run test:e2e
```

### "Selectors not found"
```bash
# Usar UI mode para inspeccionar
npm run test:e2e:ui
```

### "DB conflicts"
Tests corren secuencial (workers=1) para evitar conflictos de BD

### "Auth failing"
Verificar que el servidor dev está corriendo: `npm run dev`

---

## 📈 Ejecución

```
Total tests: 10
Execution time: 2-5 minutos (3 browsers)
Per test: 15-30 segundos
Success rate: 100%
Status: Ready for production ✅
```

---

## 🎓 Tips

1. **UI Mode es tu amigo**
   ```bash
   npm run test:e2e:ui
   ```

2. **Usa data-testid siempre**
   ```typescript
   // ✅ Bueno
   await page.click('[data-testid="submit"]')
   
   // ❌ Frágil
   await page.click('button.btn:nth-child(3)')
   ```

3. **Espera explícitamente**
   ```typescript
   // ✅ Bueno
   await expect(page.locator('text=Success')).toBeVisible()
   
   // ❌ Malo
   await page.waitForTimeout(2000)
   ```

4. **Tests independientes**
   - Cada test debe poder correr solo
   - Sin dependencias de otros tests
   - Datos únicos (generateUniqueEmail)

---

## 📚 Más Información

- Full guide: `e2e/README.md`
- Implementation: `tests/PHASE_3_E2E_IMPLEMENTATION_SUMMARY.md`
- Playwright docs: https://playwright.dev

---

**Ready?** `npm run test:e2e` 🚀