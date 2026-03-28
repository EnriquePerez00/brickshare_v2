# 🎯 E2E Tests - Próximos Pasos Inmediatos

## 📋 Estado Actual

✅ **COMPLETADO**:
- Arquitectura de modales identificada y documentada
- Helpers de modal creados con debugging extenso
- Tests refactorizados para usar modales en lugar de rutas
- Documentación completa generada
- Selectores correctos identificados en el código fuente

🟡 **BLOQUEADO - Requiere Dev Server**:
- Los tests E2E necesitan que el dev server esté corriendo en `localhost:5173`
- Playwright está configurado para usar `http://localhost:5173` como `baseURL`

## 🚀 Pasos para Ejecutar Tests

### 1. Iniciar Dev Server
```bash
cd /Users/I764690/Code_personal/Brickshare/apps/web
npm run dev
```

**Esperar hasta ver**:
```
➜  Local:   http://localhost:5173/
➜  Network: use --host to expose
```

### 2. En Otra Terminal: Ejecutar Tests
```bash
cd /Users/I764690/Code_personal/Brickshare/apps/web

# Ejecutar un test específico
npx playwright test e2e/user-journeys/complete-onboarding.spec.ts --project=chromium --reporter=list

# O con UI interactivo
npx playwright test --ui
```

### 3. Revisar Debugging Output

Los tests ahora incluyen debugging extenso que mostrará:
```
Available buttons on page: [
  { "text": "Iniciar sesión", "className": "...", "id": "" },
  { "text": "Registrarse", "className": "...", "id": "" },
  ...
]
Trying selector "button:has-text("Registrarse")": found 1 elements
Element visible: true
Clicking element with selector: button:has-text("Registrarse")
```

### 4. Si el Test Falla

El test generará automáticamente:
- `debug-no-signup-button.png` - Screenshot completo de la página
- Logs en consola con todos los botones disponibles
- Video de la ejecución en `test-results/`
- Trace para análisis con `npx playwright show-trace`

## 🔍 Selectores Confirmados

Basado en el análisis del código fuente (`apps/web/src/components/Navbar.tsx`):

### Botón de Registro
```typescript
<Button
  onClick={() => openAuthModal("signup")}
  data-testid="register-link"
  aria-label="Registrarse"
>
  Registrarse
</Button>
```

**Selectores que deberían funcionar**:
- `[data-testid="register-link"]` ✅ MEJOR OPCIÓN
- `button:has-text("Registrarse")` ✅
- `button[aria-label="Registrarse"]` ✅

### Botón de Login
```typescript
<Button
  onClick={() => openAuthModal("login")}
  data-testid="login-link"
>
  Iniciar sesión
</Button>
```

**Selectores que deberían funcionar**:
- `[data-testid="login-link"]` ✅ MEJOR OPCIÓN  
- `button:has-text("Iniciar sesión")` ✅

## 📝 Tests Actualizados

### complete-onboarding.spec.ts
```typescript
test('should complete signup', async ({ page }) => {
  await page.goto('/');
  await openSignupModal(page);  // Busca [data-testid="register-link"]
  await waitForAuthForm(page);
  await fillSignupForm(page, email, password);
  await submitAuthForm(page);
  // Assertions...
});
```

## 🛠️ Troubleshooting

### Problema: "Could not find signup button"

**Solución 1**: Verificar que el dev server está corriendo
```bash
curl http://localhost:5173
```

**Solución 2**: Revisar screenshot generado
```bash
open debug-no-signup-button.png
```

**Solución 3**: Usar Playwright UI para debugging interactivo
```bash
npx playwright test --ui --debug
```

### Problema: Modal no se abre

**Causa posible**: El botón se hace clic pero el modal no aparece

**Debug**:
1. Verificar que AuthContext está inicializado
2. Verificar que AuthModal se renderiza
3. Revisar console errors en el navegador del test

### Problema: Timeout esperando el formulario

**Causa posible**: Modal se abre pero formulario tarda en cargar

**Solución**: Incrementar timeout
```typescript
await waitForAuthForm(page, 30000); // 30 segundos
```

## 📊 Métricas de Éxito

✅ **Test Exitoso si**:
1. Dev server responde en localhost:5173
2. Página se carga sin errores 404/500
3. Botón "Registrarse" es visible
4. Modal se abre al hacer clic
5. Formulario con email/password aparece
6. Signup completa correctamente

## 🎯 Resultado Esperado

```bash
Running 4 tests using 1 worker

Available buttons on page: [...]
Trying selector "[data-testid="register-link"]": found 1 elements
Element visible: true
Clicking element with selector: [data-testid="register-link"]

  ✓  1 [chromium] › complete-onboarding.spec.ts:36:3 › should complete signup (8.2s)
  ✓  2 [chromium] › complete-onboarding.spec.ts:78:3 › should validate required fields (3.1s)
  ✓  3 [chromium] › complete-onboarding.spec.ts:98:3 › should reject weak passwords (4.5s)
  ✓  4 [chromium] › complete-onboarding.spec.ts:118:3 › should complete login (5.8s)

  4 passed (21.6s)
```

## 🔄 Workflow Completo

```bash
# Terminal 1: Dev Server
cd /Users/I764690/Code_personal/Brickshare/apps/web
npm run dev

# Terminal 2: Tests (esperar a que dev server esté listo)
cd /Users/I764690/Code_personal/Brickshare/apps/web
npx playwright test e2e/user-journeys/complete-onboarding.spec.ts --project=chromium --reporter=list

# Si hay fallos, ver traces
npx playwright show-trace test-results/[carpeta-del-test]/trace.zip
```

## 📚 Documentación Relacionada

- `apps/web/e2e/ROUTE_REFERENCE.md` - Guía de rutas y arquitectura
- `apps/web/e2e/helpers/modal-helpers.ts` - Helpers con debugging
- `docs/E2E_ARCHITECTURE_FIX_SUMMARY.md` - Resumen técnico completo
- `apps/web/e2e/QUICK_START.md` - Guía rápida E2E

---

**Estado**: 🟡 **READY TO RUN** (requiere dev server)  
**Fecha**: 27/03/2026  
**Última Actualización**: Helpers actualizados con debugging extenso