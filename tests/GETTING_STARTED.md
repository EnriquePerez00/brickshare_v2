# 🚀 GETTING STARTED - Brickshare Testing

> **Tu sistema de testing está listo para usar. Comienza aquí.**

---

## ⚡ Quick Start en 3 Pasos

### 1️⃣ Ejecuta los tests (1 minuto)
```bash
cd apps/web
npm run test
```

**Resultado esperado**: ✅ Todos los tests pasan

### 2️⃣ Explora en modo watch (desarrollo)
```bash
npm run test:watch
```

Los tests se re-ejecutan automáticamente al guardar cambios.

### 3️⃣ Ve el coverage
```bash
npm run test:coverage
open coverage/index.html
```

---

## 📊 Estado Actual del Proyecto

```
✅ Unit Tests        → 83 tests implementados
✅ Integration Tests → 50 tests implementados  
✅ E2E Tests         → 10 tests implementados
✅ CI/CD             → Configurado en GitHub Actions

Total: 143 tests cubriendo flujos críticos
Tiempo de ejecución: ~8s (unit), ~6s (integration), ~5m (E2E)
Coverage: 70%+ en funcionalidades core
```

---

## 🎯 Comandos Esenciales

### Tests Unitarios (Vitest)
```bash
# Todos los tests
npm run test

# Watch mode (rerun automático)
npm run test:watch

# Solo un archivo
npm run test -- useAuth

# Solo una carpeta
npm run test -- hooks/

# Con coverage
npm run test:coverage
```

### Tests de Integración
```bash
# Todos los tests de integración
npm run test -- integration/

# Por categoría
npm run test -- user-flows/
npm run test -- admin-flows/
npm run test -- operator-flows/
```

### Tests E2E (Playwright)
```bash
# Todos los E2E tests
npx playwright test

# UI mode (interactivo)
npx playwright test --ui

# Solo un archivo
npx playwright test complete-assignment-flow

# Debug mode
npx playwright test --debug

# Ver reporte
npx playwright show-report
```

### CI/CD
```bash
# Simular CI localmente
npm run lint && npm run test:coverage

# Ver workflows
cat .github/workflows/test.yml
```

---

## 📚 Documentación por Rol

### 👨‍💻 Developers
1. Lee esta guía (5 min)
2. Ejecuta `npm run test:watch` mientras desarrollas
3. Consulta [PHASE_1_UNIT.md](./PHASE_1_UNIT.md) para specs de unit tests
4. Consulta [TEST_DATA_FIXTURES.md](./TEST_DATA_FIXTURES.md) para fixtures disponibles

### 🧪 QA Engineers
1. Lee [COVERAGE_REPORT.md](./COVERAGE_REPORT.md) para estado actual
2. Consulta [ROADMAP.md](./ROADMAP.md) para planificación
3. Ejecuta suites completas: `npm run test:coverage`
4. Revisa [PHASE_2_INTEGRATION.md](./PHASE_2_INTEGRATION.md) y [PHASE_3_E2E.md](./PHASE_3_E2E.md)

### 👔 Managers
- **Estado**: ✅ Sistema de testing operativo
- **Cobertura**: 70%+ en funciones críticas
- **Métricas**: Ver [COVERAGE_REPORT.md](./COVERAGE_REPORT.md)
- **Roadmap**: Ver [ROADMAP.md](./ROADMAP.md)

### 🔧 DevOps
- **CI/CD**: Configurado en `.github/workflows/`
- **Setup**: Ver [SETUP_GUIDE.md](./SETUP_GUIDE.md)
- **Branch protection**: Tests obligatorios en PRs
- **Coverage tracking**: Integrado con Codecov

---

## 🎨 Escribir un Nuevo Test

### Unit Test
```typescript
// src/__tests__/unit/hooks/myHook.test.tsx
import { describe, it, expect } from 'vitest';
import { renderHook } from '@testing-library/react';
import { useMyHook } from '@/hooks/useMyHook';

describe('useMyHook', () => {
  it('should return initial value', () => {
    const { result } = renderHook(() => useMyHook());
    expect(result.current).toBeDefined();
  });
});
```

### Integration Test
```typescript
// src/__tests__/integration/user-flows/my-flow.integration.test.ts
import { describe, it, expect } from 'vitest';
import { setupIntegrationTest } from '@/test/fixtures/integration';

describe('My Flow Integration', () => {
  it('should complete the flow', async () => {
    const { user, supabase } = await setupIntegrationTest();
    // Test implementation
  });
});
```

### E2E Test
```typescript
// e2e/user-journeys/my-journey.spec.ts
import { test, expect } from '@playwright/test';

test('complete my journey', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveTitle(/Brickshare/);
});
```

---

## 🐛 Troubleshooting Común

### Tests lentos
```bash
# Ejecuta con verbose para ver cuál es lento
npm run test -- --reporter=verbose

# Revisa que los mocks estén configurados
```

### Tests fallan localmente pero pasan en CI
```bash
# Limpia node_modules y reinstala
rm -rf node_modules && npm install

# Verifica versión de Node
node --version  # Debe ser 18.x o 20.x
```

### Mock no funciona
```typescript
// Asegúrate de importar el mock ANTES del módulo a testear
import { vi } from 'vitest';
vi.mock('@/integrations/supabase/client');

import { myFunction } from './myModule';
```

### E2E tests fallan
```bash
# Instala browsers de Playwright
npx playwright install

# Ejecuta en headed mode para ver qué pasa
npx playwright test --headed

# Verifica que el dev server esté corriendo
npm run dev
```

---

## ❓ FAQs

### ¿Cómo veo el coverage?
```bash
npm run test:coverage
open apps/web/coverage/index.html
```

### ¿Qué es una fixture?
Datos de prueba reutilizables. Ubicación: `apps/web/src/test/fixtures/`

Ver [TEST_DATA_FIXTURES.md](./TEST_DATA_FIXTURES.md) para detalles.

### ¿Cómo debuggeo un test?
```bash
# Con Vitest
npm run test -- --reporter=verbose myTest

# Con Node inspector
node --inspect-brk ./node_modules/vitest/vitest.mjs

# Con Playwright
npx playwright test --debug
```

### ¿Dónde están los mocks de Supabase?
En `apps/web/src/test/mocks/supabase.ts`

Se aplican automáticamente por el setup de Vitest.

### ¿Puedo ejecutar tests en paralelo?
Sí, Vitest ejecuta tests en paralelo por defecto.

Para E2E:
```bash
npx playwright test --workers=4
```

---

## 🔗 Links Rápidos

### Documentación del Proyecto
- [README.md](./README.md) - Índice y visión general
- [COVERAGE_REPORT.md](./COVERAGE_REPORT.md) - Estado actual y métricas
- [ROADMAP.md](./ROADMAP.md) - Planificación de las 4 fases
- [SETUP_GUIDE.md](./SETUP_GUIDE.md) - Configuración detallada

### Especificaciones por Fase
- [PHASE_1_UNIT.md](./PHASE_1_UNIT.md) - Tests unitarios
- [PHASE_2_INTEGRATION.md](./PHASE_2_INTEGRATION.md) - Tests de integración
- [PHASE_3_E2E.md](./PHASE_3_E2E.md) - Tests E2E
- [PHASE_4_CI_CD.md](./PHASE_4_CI_CD.md) - CI/CD setup

### Herramientas Externas
- [Vitest](https://vitest.dev/) - Test runner
- [React Testing Library](https://testing-library.com/react) - Testing utilities
- [Playwright](https://playwright.dev/) - E2E framework
- [MSW](https://mswjs.io/) - API mocking

---

## 📈 Próximos Pasos

### Hoy
- [x] Ejecuta `npm run test` para verificar que todo funciona
- [ ] Explora un test existente para entender la estructura
- [ ] Lee [COVERAGE_REPORT.md](./COVERAGE_REPORT.md) para ver el estado actual

### Esta Semana
- [ ] Escribe tu primer test siguiendo los ejemplos
- [ ] Familiarízate con las fixtures disponibles
- [ ] Ejecuta tests en modo watch mientras desarrollas

### Este Mes
- [ ] Contribuye a mejorar el coverage
- [ ] Revisa y actualiza tests al hacer cambios
- [ ] Participa en code reviews de tests

---

## 🎉 Lo Mejor de Este Sistema

✅ **Rápido** - Tests unitarios en ~8 segundos  
✅ **Completo** - 143 tests cubriendo flujos críticos  
✅ **Automatizado** - CI/CD en GitHub Actions  
✅ **Documentado** - Guías claras para cada fase  
✅ **Mantenible** - Fixtures y mocks reutilizables  
✅ **Escalable** - Preparado para crecer con el proyecto  

---

**¿Listo para empezar?**

```bash
cd apps/web && npm run test
```

**Deberías ver todos los tests pasando ✅**

Para más detalles, consulta [README.md](./README.md) o [SETUP_GUIDE.md](./SETUP_GUIDE.md)