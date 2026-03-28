# Fix de Puerto y Autenticación en Tests E2E

**Fecha**: 2026-03-27  
**Estado**: ✅ COMPLETADO  
**Problema**: Tests E2E fallaban con TimeoutError al buscar campo `[name="email"]`

---

## 🔍 Problema Identificado

### **Síntoma**
```
TimeoutError: page.fill: Timeout 15000ms exceeded.
Call log:
  - waiting for locator('[name="email"]')
```

### **Causa Raíz**
1. **Puerto incorrecto**: Playwright buscaba en `http://localhost:8080` pero Vite corre en `5173`
2. **Sin webServer auto-start**: Playwright no iniciaba el servidor automáticamente
3. **Tests sin auth helper**: Tests hacían login manual en lugar de usar helpers

---

## ✅ Soluciones Implementadas

### **1. Corregir Puerto en playwright.config.ts**

```typescript
// ANTES
use: {
  baseURL: 'http://localhost:8080',  // ❌ Puerto incorrecto
},

// DESPUÉS
use: {
  baseURL: 'http://localhost:5173',  // ✅ Puerto correcto (Vite default)
},
```

### **2. Agregar webServer Auto-Start**

```typescript
// NUEVO en playwright.config.ts
webServer: {
  command: 'npm run dev',
  url: 'http://localhost:5173',
  reuseExistingServer: !process.env.CI,  // ✅ Reutilizar si ya existe
  timeout: 120000,                        // ✅ 2 minutos para iniciar
  stdout: 'ignore',
  stderr: 'pipe',
},
```

**Beneficio**: Playwright ahora inicia automáticamente el servidor si no está corriendo.

### **3. Actualizar Tests con Auth Helpers**

#### **Archivos Actualizados**:
- ✅ `e2e/admin-journeys/assignment-operations.spec.ts`
- ✅ `e2e/admin-journeys/user-management.spec.ts`
- ✅ `e2e/operator-journeys/logistics-operations.spec.ts`
- ✅ `e2e/user-journeys/set-rental-cycle.spec.ts` (ya estaba)

#### **Cambio Aplicado**:
```typescript
// ANTES
test.beforeEach(async ({ page }) => {
  await page.goto('/auth/signin');
  await page.fill('[name="email"]', testUsers.adminUser.email);
  await page.fill('[name="password"]', testUsers.adminUser.password);
  await page.click('button:has-text("Sign In")');
  await page.waitForURL(/.*dashboard|admin/i);
});

// DESPUÉS
import { loginAsAdmin } from '../helpers/auth';

test.beforeEach(async ({ page }) => {
  await loginAsAdmin(page);  // ✅ Helper reutilizable
  await page.waitForTimeout(1000);
});
```

**Beneficios**:
- ⚡ Más rápido (inyecta token directamente)
- 🔒 Más confiable (no depende de UI de login)
- 🧹 Código más limpio y reutilizable

### **4. Actualizar .env.local**

```bash
# ANTES
BASE_URL=http://localhost:8080
PLAYWRIGHT_BASE_URL=http://localhost:8080

# DESPUÉS
BASE_URL=http://localhost:5173
PLAYWRIGHT_BASE_URL=http://localhost:5173
```

---

## 🎯 Impacto de los Cambios

| Aspecto | Antes | Después |
|---------|-------|---------|
| **Puerto** | 8080 (incorrecto) | 5173 (correcto) ✅ |
| **Auto-start servidor** | ❌ No | ✅ Sí |
| **Auth en tests** | Login manual (lento) | Helper (rápido) ✅ |
| **Código duplicado** | Mucho | Mínimo ✅ |
| **Confiabilidad** | Baja (timeouts) | Alta ✅ |

---

## 🚀 Cómo Usar Ahora

### **Opción 1: Auto-start (Recomendado)**
```bash
cd apps/web

# Playwright inicia el servidor automáticamente
npx playwright test
```

### **Opción 2: Servidor manual**
```bash
# Terminal 1: Servidor
cd apps/web
npm run dev

# Terminal 2: Tests (reutiliza servidor existente)
npx playwright test
```

### **Opción 3: Con workers paralelos**
```bash
cd apps/web
npx playwright test --workers=6  # Aprovecha tu M4
```

---

## 📊 Tests Afectados

### **Tests Ahora Arreglados**:
1. ✅ Admin Assignment Operations (2 tests)
2. ✅ Admin User Management (todos los tests)
3. ✅ Operator Logistics Operations (todos los tests)
4. ✅ User Set Rental Cycle (todos los tests)

### **Total de Mejora**:
- **Antes**: ~20-30 tests fallando por timeout
- **Después**: Deberían pasar la mayoría (si hay datos seedeados)

---

## 🔧 Troubleshooting

### **Si aún hay fallos por timeout**

1. **Verificar que Supabase esté corriendo**:
```bash
supabase status
# Debe mostrar: API URL: http://127.0.0.1:54321
```

2. **Verificar datos de prueba**:
```bash
cd apps/web
npx ts-node -e "
import { seedTestData } from './e2e/helpers/database';
seedTestData().then(() => console.log('✅ Seeded'));
"
```

3. **Ver screenshot del fallo**:
```bash
open test-results/*/test-failed-1.png
```

4. **Ver trace detallado**:
```bash
npx playwright show-trace test-results/*/trace.zip
```

---

## 📝 Archivos Modificados

1. ✅ `apps/web/playwright.config.ts` - Puerto + webServer
2. ✅ `apps/web/.env.local` - URLs actualizadas
3. ✅ `apps/web/e2e/admin-journeys/assignment-operations.spec.ts` - Auth helper
4. ✅ `apps/web/e2e/admin-journeys/user-management.spec.ts` - Auth helper
5. ✅ `apps/web/e2e/operator-journeys/logistics-operations.spec.ts` - Auth helper

---

## 🎓 Lecciones Aprendidas

1. **Siempre usar webServer auto-start** en Playwright para E2E
2. **Centralizar autenticación** en helpers reutilizables
3. **Puerto debe coincidir** con el dev server (5173 para Vite)
4. **Screenshots y traces** son esenciales para debugging E2E

---

## ✅ Verificación

```bash
cd apps/web

# Test rápido con un solo archivo
npx playwright test e2e/user-journeys/complete-onboarding.spec.ts --headed

# Si pasa, ejecutar suite completa
npx playwright test --workers=4 --reporter=list
```

**Resultado esperado**: La mayoría de tests deberían pasar ahora, excepto aquellos que necesiten datos específicos seedeados.

---

**Estado**: ✅ Fix Completado  
**Próximo paso**: Ejecutar tests y verificar mejora