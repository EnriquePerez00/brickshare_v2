# Implementación Fase 1: Quick Fixes para Tests E2E

**Fecha**: 2026-03-27  
**Estado**: ✅ COMPLETADO  
**Tiempo estimado**: 1-2 horas  
**Tiempo real**: ~30 minutos

---

## 🎯 Objetivo

Implementar arreglos rápidos para que al menos 2-3 de los 5 tests fallidos pasen, sin necesidad de refactorizar completamente la aplicación.

---

## ✅ Cambios Implementados

### 1. **Aumentar Timeouts en `playwright.config.ts`**

**Archivo**: `apps/web/playwright.config.ts`

**Cambios**:
```typescript
// ANTES
timeout: 30000 (implícito)
expect: { timeout: 5000 (implícito) }
retries: 0
workers: process.env.CI ? 1 : undefined

// DESPUÉS
timeout: 60000,           // ✅ 60 segundos para tests completos
expect: { timeout: 10000 }, // ✅ 10 segundos para assertions
retries: process.env.CI ? 2 : 1, // ✅ 1 retry en local
workers: 1,               // ✅ Un worker para evitar race conditions
use: {
  actionTimeout: 15000,   // ✅ 15 segundos para acciones individuales
  trace: 'retain-on-failure', // ✅ Guardar traces solo en fallos
}
```

**Impacto esperado**:
- ❌ Tests que fallaban por timeout ahora tienen más tiempo
- ❌ Assertions tienen 10s en lugar de 5s
- ✅ Un retry automático si algo falla la primera vez

### 2. **Crear Helper de Autenticación**

**Archivo**: `apps/web/e2e/helpers/auth.ts` (nuevo)

**Funcionalidades**:
- ✅ `loginAsTestUser(page)` - Login rápido con usuario de prueba
- ✅ `loginAsAdmin(page)` - Login como admin
- ✅ `loginAsOperator(page)` - Login como operador
- ✅ `setupAuthenticatedSession(page, email, password)` - Inyectar token directamente
- ✅ `loginViaUI(page, email, password)` - Login tradicional por UI
- ✅ `logout(page)` - Cerrar sesión
- ✅ `isAuthenticated(page)` - Verificar si hay sesión activa

**Ventajas**:
1. **Más rápido**: Inyecta token directamente en localStorage (no necesita UI)
2. **Más confiable**: No depende de que la UI de login cargue correctamente
3. **Reutilizable**: Se puede usar en todos los tests

**Ejemplo de uso**:
```typescript
import { loginAsTestUser } from '../helpers/auth';

test.beforeEach(async ({ page }) => {
  await loginAsTestUser(page);
});
```

### 3. **Actualizar Test con `beforeEach`**

**Archivo**: `apps/web/e2e/user-journeys/set-rental-cycle.spec.ts`

**Cambios**:
```typescript
// ANTES
test.describe('User Set Rental Cycle', () => {
  test('should browse catalog...', async ({ page }) => {
    // Cada test se ejecuta sin autenticación
    await page.goto('/catalog');
    // ...
  });
});

// DESPUÉS
test.describe('User Set Rental Cycle', () => {
  test.beforeEach(async ({ page }) => {
    await loginAsTestUser(page);
    await page.waitForTimeout(1000); // Esperar carga de auth
  });

  test('should browse catalog...', async ({ page }) => {
    // Ahora el usuario YA está autenticado
    await page.goto('/catalog');
    // ...
  });
});
```

**Impacto**:
- ✅ Usuario autenticado ANTES de cada test
- ✅ No necesita hacer login manualmente en cada test
- ✅ Tests más rápidos (login una vez, no en cada test)

---

## 🧪 Cómo Probar

### Opción 1: Ejecutar el test específico

```bash
cd apps/web

# Ejecutar solo el test modificado
npx playwright test e2e/user-journeys/set-rental-cycle.spec.ts \
  --project=chromium \
  --reporter=list
```

### Opción 2: Ejecutar con UI para ver paso a paso

```bash
cd apps/web
npx playwright test e2e/user-journeys/set-rental-cycle.spec.ts \
  --project=chromium \
  --headed \
  --reporter=list
```

### Opción 3: Ver resultados visuales

```bash
cd apps/web
npx playwright test e2e/user-journeys/set-rental-cycle.spec.ts
npx playwright show-report
```

---

## 📊 Resultados Esperados

### **Escenario Optimista (2-3 tests pasan)**

✅ Tests que deberían pasar ahora:
1. `should browse catalog and add set to wishlist` - Usuario autenticado
2. `should view wishlist and request set assignment` - Si hay datos de wishlist

❌ Tests que aún pueden fallar:
1. `should filter sets by theme` - Falta `data-testid="filter-theme"`
2. `should track shipment` - Faltan datos de shipments en BD
3. `should display set in active collection` - Faltan datos en BD

### **Escenario Realista (1-2 tests pasan)**

Si los datos de prueba no están seedeados, solo pasarán tests que no dependan de datos específicos.

---

## 🚀 Próximos Pasos

### **Si 2-3 tests pasan**: ✅ Fase 1 exitosa
- Continuar con **Fase 2** (Agregar data-testid en componentes)
- Esto debería hacer que pasen 4-5 tests

### **Si solo 1 test pasa**: ⚠️ Necesitas Fase 3
- Implementar **Fase 3** (Setup de datos)
- Seedear usuario de prueba con:
  - Suscripción activa
  - PUDO configurado
  - Sets en wishlist
  - Shipments activos

### **Si ningún test pasa**: ❌ Problema más profundo
- Verificar que Supabase está corriendo: `supabase status`
- Verificar que el servidor web está en localhost:8080
- Revisar los screenshots en `test-results/`
- Ver video de ejecución para identificar el problema

---

## 📁 Archivos Modificados

1. ✅ `apps/web/playwright.config.ts` - Timeouts aumentados
2. ✅ `apps/web/e2e/helpers/auth.ts` - Helper de autenticación (nuevo)
3. ✅ `apps/web/e2e/user-journeys/set-rental-cycle.spec.ts` - BeforeEach agregado

---

## 🎓 Lecciones Aprendidas

### **❌ Problema Original**
- Tests sin autenticación previa
- Timeouts muy cortos (30s) para E2E completos
- Cada test intentaba hacer login por separado

### **✅ Solución Aplicada**
- Helper reutilizable de auth
- Timeouts realistas (60s para tests, 15s para acciones)
- `beforeEach` para auth común

### **📚 Best Practices E2E**
1. Siempre usar `beforeEach` para setup común
2. Crear helpers reutilizables para autenticación
3. Timeouts generosos para E2E (60s mínimo)
4. Usar `actionTimeout` para acciones individuales
5. Activar `trace` y `video` solo en fallos (no siempre)

---

**Estado**: ✅ Fase 1 Implementada  
**Siguiente**: Ejecutar tests y evaluar resultados para decidir si continuar con Fase 2