# Análisis de Fallos en Tests E2E - set-rental-cycle.spec.ts

**Fecha**: 2026-03-27  
**Archivo**: `apps/web/e2e/user-journeys/set-rental-cycle.spec.ts`  
**Estado**: ❌ 5 tests fallando en webkit

---

## 🔍 Investigación Realizada

### 1. Análisis del Test Fallido

El test `set-rental-cycle.spec.ts` intenta simular el ciclo completo de alquiler de un usuario:
1. ✅ Login y navegación al catálogo
2. ❌ Agregar set a wishlist (falla buscando elementos)
3. ❌ Filtrar sets por tema (falla - elemento no existe)
4. ❌ Ver wishlist y solicitar asignación (falla - página no carga)
5. ❌ Seguimiento de envío (falla - datos no existen)

### 2. Problemas Identificados

#### **Problema 1: Falta de Setup de Autenticación**
```typescript
// ❌ PROBLEMA: El test NO tiene beforeEach con login
test.describe('User Set Rental Cycle', () => {
  // No hay setup de autenticación aquí
  
  test('should log in and add set to wishlist', async ({ page }) => {
    // Hace login manualmente en cada test
    await page.goto('/auth/signin');
    // ...
  });
});
```

**Comparado con otros tests que SÍ funcionan:**
```typescript
// ✅ CORRECTO: subscription-flow.spec.ts tiene mejor estructura
test.describe('User Subscription Flow', () => {
  test.beforeEach(async ({ page }) => {
    // Setup común aquí
  });
});
```

#### **Problema 2: Selectores Inexistentes en la Aplicación**

Los siguientes selectores NO existen en el código actual:
- ❌ `[data-testid="filter-theme"]` - No encontrado en componentes
- ❌ `[data-testid="Star Wars Millennium Falcon"]` - Formato incorrecto
- ❌ `text=My Wishlist` - Texto puede haber cambiado
- ❌ `text=Active Sets` - Texto puede haber cambiado

#### **Problema 3: Dependencias entre Tests**

```typescript
// ❌ Test 2 depende de que Test 1 haya agregado el set
test('should filter sets by theme and piece count', async ({ page }) => {
  // Asume que ya está en catálogo, pero no hay garantía
  await page.click('[data-testid="filter-theme"]');
});

// ❌ Test 3 depende de que Test 1 haya agregado a wishlist
test('should view wishlist and request set assignment', async ({ page }) => {
  await page.goto('/wishlist');
  // Espera ver sets que Test 1 debería haber agregado
});
```

#### **Problema 4: Falta de Datos de Prueba en Base de Datos**

El test asume que existen:
- Sets en el catálogo
- Usuario con suscripción activa
- Datos de envío (shipments)
- Punto PUDO configurado

Pero NO hay un script que prepare estos datos antes de ejecutar.

#### **Problema 5: Timeouts Cortos (30s)**

Para tests E2E que involucran:
- Login
- Navegación
- Llamadas a Supabase
- Renderizado de React

30 segundos puede ser insuficiente, especialmente en webkit.

---

## 🎯 Soluciones Propuestas

### **Solución 1: Crear Helper de Autenticación Reutilizable**

Crear `apps/web/e2e/helpers/auth.ts`:

```typescript
import { Page } from '@playwright/test';
import { testUsers } from '../fixtures/test-data';

export async function loginAsRegularUser(page: Page) {
  await page.goto('/auth/signin');
  await page.fill('[name="email"]', testUsers.regularUser.email);
  await page.fill('[name="password"]', testUsers.regularUser.password);
  await page.click('button[type="submit"]');
  
  // Esperar a que la navegación complete
  await page.waitForURL(/.*dashboard|catalog/i, { timeout: 10000 });
}

export async function setupAuthenticatedSession(page: Page) {
  // Usar API de Supabase para crear sesión directamente
  const { supabase } = await import('./database');
  
  const { data: { session } } = await supabase.auth.signInWithPassword({
    email: testUsers.regularUser.email,
    password: testUsers.regularUser.password,
  });
  
  if (session) {
    // Inyectar token en el navegador
    await page.goto('/');
    await page.evaluate((token) => {
      localStorage.setItem('supabase.auth.token', token);
    }, session.access_token);
  }
}
```

### **Solución 2: Agregar data-testid en Componentes**

Modificar los componentes de la app para incluir selectores estables:

**Catálogo (`apps/web/src/pages/Catalogo.tsx`):**
```tsx
// Agregar data-testid a filtros
<Select data-testid="filter-theme">
  <SelectTrigger>
    <SelectValue placeholder="Tema" />
  </SelectTrigger>
  {/* ... */}
</Select>

<Select data-testid="filter-pieces">
  <SelectTrigger>
    <SelectValue placeholder="Número de piezas" />
  </SelectTrigger>
  {/* ... */}
</Select>
```

**SetCard component:**
```tsx
<Card data-testid={`set-card-${set.set_ref}`}>
  <button data-testid={`add-to-wishlist-${set.set_ref}`}>
    Add to Wishlist
  </button>
</Card>
```

### **Solución 3: Reescribir Test con Mejor Estructura**

Crear un nuevo archivo `apps/web/e2e/user-journeys/set-rental-cycle-v2.spec.ts`:

```typescript
import { test, expect } from '@playwright/test';
import { loginAsRegularUser } from '../helpers/auth';
import { createTestSet, createTestShipment } from '../helpers/database';
import { testUsers, testSets } from '../fixtures/test-data';

test.describe('User Set Rental Cycle - Complete Flow', () => {
  // Setup antes de CADA test
  test.beforeEach(async ({ page }) => {
    // 1. Limpiar datos previos
    await cleanupTestData(testUsers.regularUser.id);
    
    // 2. Crear datos de prueba
    await createTestSet(testSets.starWars);
    
    // 3. Autenticar usuario
    await loginAsRegularUser(page);
    
    // 4. Verificar que está autenticado
    await expect(page).toHaveURL(/.*dashboard|catalog/i);
  });

  test('should browse catalog and add set to wishlist', async ({ page }) => {
    // Navegar al catálogo
    await page.goto('/catalog');
    await page.waitForLoadState('networkidle');
    
    // Esperar a que carguen los sets
    await expect(page.locator('[data-testid^="set-card-"]')).toHaveCount(1, {
      timeout: 10000
    });
    
    // Agregar a wishlist usando set_ref específico
    await page.click(`[data-testid="add-to-wishlist-${testSets.starWars.set_ref}"]`);
    
    // Verificar notificación de éxito
    await expect(page.locator('text=Added to wishlist')).toBeVisible({
      timeout: 5000
    });
  });

  test('should view wishlist', async ({ page }) => {
    // Primero agregar un set a wishlist
    await addSetToWishlist(page, testSets.starWars.set_ref);
    
    // Ir a wishlist
    await page.goto('/wishlist');
    await page.waitForLoadState('networkidle');
    
    // Verificar que el set aparece
    await expect(page.locator(`[data-testid="wishlist-item-${testSets.starWars.set_ref}"]`))
      .toBeVisible({ timeout: 10000 });
  });

  // Cleanup después de cada test
  test.afterEach(async () => {
    await cleanupTestData(testUsers.regularUser.id);
  });
});

// Helper functions
async function addSetToWishlist(page: Page, setRef: string) {
  await page.goto('/catalog');
  await page.waitForLoadState('networkidle');
  await page.click(`[data-testid="add-to-wishlist-${setRef}"]`);
  await page.waitForTimeout(1000); // Esperar a que se guarde
}

async function cleanupTestData(userId: string) {
  const { supabase } = await import('../helpers/database');
  
  // Limpiar wishlist
  await supabase.from('wishlist').delete().eq('user_id', userId);
  
  // Limpiar shipments de prueba
  await supabase.from('shipments').delete().eq('user_id', userId);
}
```

### **Solución 4: Script de Seed para Tests E2E**

Crear `apps/web/e2e/setup-test-data.ts`:

```typescript
import { supabase } from './helpers/database';
import { testUsers, testSets, pudoLocations } from './fixtures/test-data';

export async function seedTestData() {
  console.log('🌱 Seeding E2E test data...');
  
  // 1. Crear usuario de prueba si no existe
  const { data: existingUser } = await supabase
    .from('users')
    .select('id')
    .eq('email', testUsers.regularUser.email)
    .single();
  
  if (!existingUser) {
    const { data: authUser } = await supabase.auth.signUp({
      email: testUsers.regularUser.email,
      password: testUsers.regularUser.password,
    });
    
    if (authUser) {
      await supabase.from('users').insert({
        id: authUser.user!.id,
        full_name: testUsers.regularUser.fullName,
        subscription_tier: 'standard',
        subscription_status: 'active',
      });
    }
  }
  
  // 2. Crear sets de prueba
  for (const set of Object.values(testSets)) {
    await supabase.from('sets').upsert({
      set_ref: set.set_ref,
      name: set.name,
      theme: set.theme,
      pieces: set.pieces,
      year: set.year,
    }, { onConflict: 'set_ref' });
    
    // Crear inventario
    await supabase.from('inventory_sets').upsert({
      set_ref: set.set_ref,
      available: 3,
      in_use: 0,
      in_transit: 0,
    }, { onConflict: 'set_ref' });
  }
  
  // 3. Crear PUDO de prueba
  for (const pudo of Object.values(pudoLocations)) {
    await supabase.from('brickshare_pudo_locations').upsert({
      id: pudo.id,
      name: pudo.name,
      address: pudo.address,
      city: pudo.city,
      zip_code: pudo.zip_code,
    }, { onConflict: 'id' });
  }
  
  console.log('✅ Test data seeded successfully');
}

export async function cleanupTestData() {
  console.log('🧹 Cleaning up test data...');
  
  // Limpiar en orden inverso por FK
  await supabase.from('wishlist').delete().neq('id', '00000000-0000-0000-0000-000000000000');
  await supabase.from('shipments').delete().eq('user_id', testUsers.regularUser.id);
  
  console.log('✅ Test data cleaned up');
}
```

### **Solución 5: Actualizar playwright.config.ts**

```typescript
export default defineConfig({
  testDir: './e2e',
  timeout: 60000, // ✅ Aumentar a 60 segundos
  expect: {
    timeout: 10000, // ✅ Aumentar expect timeout a 10s
  },
  fullyParallel: false,
  retries: process.env.CI ? 2 : 1, // ✅ 1 retry local
  workers: 1, // ✅ Un worker para evitar race conditions
  
  use: {
    baseURL: 'http://localhost:8080',
    trace: 'retain-on-failure', // ✅ Guardar traces en fallos
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    actionTimeout: 15000, // ✅ 15s para acciones individuales
  },
  
  // ✅ Global setup para seedear datos
  globalSetup: require.resolve('./e2e/global-setup.ts'),
  globalTeardown: require.resolve('./e2e/global-teardown.ts'),
});
```

### **Solución 6: Crear Global Setup**

Crear `apps/web/e2e/global-setup.ts`:

```typescript
import { seedTestData } from './setup-test-data';

async function globalSetup() {
  console.log('🚀 Running global E2E setup...');
  
  // Verificar que Supabase está corriendo
  const response = await fetch('http://127.0.0.1:54331/rest/v1/', {
    headers: { 'apikey': process.env.VITE_SUPABASE_ANON_KEY! }
  });
  
  if (!response.ok) {
    throw new Error('❌ Supabase is not running. Run: supabase start');
  }
  
  // Seedear datos de prueba
  await seedTestData();
  
  console.log('✅ Global setup complete');
}

export default globalSetup;
```

---

## 📋 Plan de Implementación Recomendado

### **Fase 1: Quick Fixes (1-2 horas)**
1. ✅ Aumentar timeouts en `playwright.config.ts`
2. ✅ Crear helper de autenticación básico
3. ✅ Agregar `beforeEach` con login en `set-rental-cycle.spec.ts`

### **Fase 2: Selectores Estables (2-3 horas)**
1. ✅ Agregar `data-testid` en componentes de Catálogo
2. ✅ Agregar `data-testid` en SetCard
3. ✅ Agregar `data-testid` en Wishlist
4. ✅ Actualizar selectores en el test

### **Fase 3: Setup de Datos (3-4 horas)**
1. ✅ Crear `setup-test-data.ts`
2. ✅ Crear `global-setup.ts` y `global-teardown.ts`
3. ✅ Configurar en `playwright.config.ts`
4. ✅ Probar que los datos se crean correctamente

### **Fase 4: Reescritura de Tests (4-6 horas)**
1. ✅ Reescribir `set-rental-cycle.spec.ts` con nueva estructura
2. ✅ Hacer tests independientes (no dependan unos de otros)
3. ✅ Agregar cleanup en `afterEach`
4. ✅ Verificar que pasan en los 3 navegadores

---

## 🚀 Comandos para Probar Solución

```bash
# 1. Seedear datos manualmente primero
cd apps/web
npx ts-node e2e/setup-test-data.ts

# 2. Ejecutar test específico con logs
npx playwright test e2e/user-journeys/set-rental-cycle.spec.ts \
  --project=chromium \
  --headed \
  --reporter=list

# 3. Ver resultados
npx playwright show-report

# 4. Ejecutar todos los tests cuando esté listo
npx playwright test --reporter=list
```

---

## 📊 Impacto Estimado

| Fase | Tiempo | Tests Arreglados | Prioridad |
|------|--------|------------------|-----------|
| Fase 1 | 1-2h | 2/5 | 🔥 Alta |
| Fase 2 | 2-3h | 4/5 | 🔥 Alta |
| Fase 3 | 3-4h | 5/5 | ⚡ Media |
| Fase 4 | 4-6h | 5/5 + mejora calidad | ⚡ Media |

**Total estimado**: 10-15 horas para solución completa

---

## 🎯 Recomendación Inmediata

**Empieza por Fase 1 + parte de Fase 2**:

1. Aumenta timeouts (5 minutos)
2. Crea helper de auth (30 minutos)  
3. Agrega 5-6 data-testid clave (1 hora)
4. Actualiza el test para usar los nuevos selectores (1 hora)

Esto debería hacer que **al menos 3 de los 5 tests pasen**.

---

**Estado**: 📝 Análisis Completo - Listo para Implementación  
**Próximo paso**: Decidir qué fase implementar primero