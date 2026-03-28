# Playwright UI - Guía de Uso

**Fecha**: 2026-03-26  
**Estado**: ✅ Configurado y Funcionando

## ✅ Configuración Verificada

El diagnóstico ha confirmado que todo está correctamente configurado:

- ✅ **222 tests** detectados en 10 archivos
- ✅ Supabase corriendo en puerto **54331**
- ✅ `SUPABASE_SERVICE_ROLE_KEY` configurado
- ✅ Variables de entorno correctas en `.env.local`
- ✅ Playwright v1.58.2 instalado

## 🚀 Cómo Abrir Playwright UI

### Opción 1: Comando básico
```bash
cd apps/web
npx playwright test --ui
```

### Opción 2: Con navegador específico
```bash
cd apps/web
npx playwright test --ui --project=chromium
```

### Opción 3: Con modo debug
```bash
cd apps/web
DEBUG=pw:api npx playwright test --ui
```

## 📋 Tests Disponibles

### Admin Journeys (2 archivos)
- `admin-journeys/assignment-operations.spec.ts` - 6 tests
- `admin-journeys/complete-assignment-flow.spec.ts` - 5 tests  
- `admin-journeys/user-management.spec.ts` - 7 tests

### User Journeys (3 archivos)
- `user-journeys/complete-onboarding.spec.ts` - Tests de onboarding
- `user-journeys/set-rental-cycle.spec.ts` - Ciclo de alquiler completo
- `user-journeys/subscription-flow.spec.ts` - Flujo de suscripción

### Operator Journeys (2 archivos)
- `operator-journeys/complete-reception-flow.spec.ts` - Recepción de sets
- `operator-journeys/logistics-operations.spec.ts` - Operaciones logísticas

### Error Scenarios (2 archivos)
- `error-scenarios/payment-failures.spec.ts` - Fallos de pago
- `error-scenarios/logistics-failures.spec.ts` - Fallos logísticos

## 🔍 Si el UI No Se Abre

### 1. Verificar que el proceso está corriendo
```bash
ps aux | grep playwright
```

### 2. Verificar puerto del UI (por defecto usa puerto aleatorio)
El UI de Playwright se abre automáticamente en tu navegador por defecto. Si no se abre:

```bash
# Intenta con un navegador específico
open http://localhost:3000  # El puerto puede variar
```

### 3. Limpiar cache de Playwright
```bash
cd apps/web
rm -rf .playwright
npx playwright install chromium
```

### 4. Verificar que no hay procesos bloqueando
```bash
# Matar procesos de Playwright previos
pkill -f playwright
```

## 🎯 Ejecutar Tests Sin UI

### Ejecutar todos los tests
```bash
cd apps/web
npx playwright test
```

### Ejecutar un archivo específico
```bash
cd apps/web
npx playwright test e2e/user-journeys/complete-onboarding.spec.ts
```

### Ejecutar en modo debug
```bash
cd apps/web
npx playwright test --debug e2e/user-journeys/complete-onboarding.spec.ts
```

### Ejecutar con headed mode (ver el navegador)
```bash
cd apps/web
npx playwright test --headed
```

## 🐛 Troubleshooting Común

### Problema: "Loading..." infinito en UI
**Causa**: Error en la conexión a Supabase  
**Solución**: Verificar que Supabase está corriendo
```bash
supabase status
```

### Problema: Tests no aparecen
**Causa**: Error de sintaxis en algún test  
**Solución**: Revisar logs con
```bash
npx playwright test --list
```

### Problema: Error de variables de entorno
**Causa**: `.env.local` mal configurado  
**Solución**: Verificar que contiene
```bash
cat apps/web/.env.local | grep SUPABASE_SERVICE_ROLE_KEY
```

## 📊 Comandos Útiles

```bash
# Ver lista de tests
npx playwright test --list

# Ver reporte HTML de última ejecución
npx playwright show-report

# Ejecutar solo tests de admin
npx playwright test admin-journeys/

# Ejecutar solo tests de usuario
npx playwright test user-journeys/

# Ejecutar solo tests de operador
npx playwright test operator-journeys/

# Ejecutar tests de errores
npx playwright test error-scenarios/

# Ejecutar con múltiples workers
npx playwright test --workers=4

# Ejecutar y generar reporte
npx playwright test --reporter=html
```

## 🎨 UI Features

El Playwright UI ofrece:
- 📋 Lista de todos los tests
- ▶️ Ejecución selectiva de tests
- 🔍 Inspección de pasos de cada test
- 📸 Screenshots automáticos en fallos
- 🎬 Videos de ejecución
- 🕵️ Time travel debugging
- 📊 Resultados en tiempo real

## 🔗 Referencias

- [Playwright UI Mode Docs](https://playwright.dev/docs/test-ui-mode)
- [Playwright Test Docs](https://playwright.dev/docs/intro)
- Configuración local: `apps/web/playwright.config.ts`
- Tests E2E: `apps/web/e2e/`
- Helpers: `apps/web/e2e/helpers/`

---

**Última verificación**: 2026-03-26 18:40  
**Estado**: ✅ Funcionando correctamente