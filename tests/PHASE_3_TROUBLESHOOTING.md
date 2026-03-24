# 🔧 Fase 3: E2E Tests - Troubleshooting Guide

## ⚠️ Problema: Timeout en webServer

**Error**:
```
Error: Timed out waiting 60000ms from config.webServer.
```

### Causa

Playwright intenta iniciar automáticamente el servidor dev, pero si ya tienes uno corriendo en el puerto 5173, habrá un conflicto.

### Solución ✅

Se ha actualizado `playwright.config.ts` con `reuseExistingServer: true`, lo que significa:

**Playwright ahora reutilizará tu servidor existente** en lugar de intentar iniciar uno nuevo.

---

## 🚀 Cómo Ejecutar E2E Tests

### Prerrequisito: Servidor Dev Corriendo

**Antes de ejecutar tests**, asegúrate de que el servidor dev está corriendo:

```bash
# Terminal 1 - Servidor dev
cd apps/web
npm run dev

# Espera a ver:
# ✓ built in XXXms
# ➜  Local:   http://localhost:5173/
```

### Ejecutar Tests

**En otra terminal**, ejecuta los tests E2E:

```bash
# Terminal 2 - Tests E2E
cd apps/web
npm run test:e2e

# O con UI
npm run test:e2e:ui

# O en headless mode con navegador visible
npm run test:e2e:headed
```

### Flujo Correcto

```
Terminal 1: npm run dev
   ↓
[Esperar a que el servidor esté listo]
   ↓
Terminal 2: npm run test:e2e
   ↓
✅ Tests corren usando servidor existente
```

---

## ✅ Verificación

Después de la actualización, verifica que funciona:

```bash
# 1. Inicia servidor
cd apps/web
npm run dev

# 2. En otra terminal, lista los tests disponibles
npx playwright test --list

# 3. Ejecuta los tests
npm run test:e2e
```

---

## 🎯 Configuración Explicada

```typescript
// En playwright.config.ts
webServer: {
  command: 'npm run dev',
  url: 'http://localhost:5173',
  reuseExistingServer: true,  // ✅ SIEMPRE reusar servidor existente
}
```

Esto significa:
- Si el servidor **YA está corriendo** → Usa ese servidor
- Si el servidor **NO está corriendo** → Intenta iniciarlo con `npm run dev`
- **Si el port está ocupado** → No da error, solo usa lo que ya existe

---

## 🔍 Debug

Si aún tienes problemas:

### 1. Verificar que el puerto 5173 responde

```bash
curl http://localhost:5173 -v
```

Debería mostrar `200 OK` o similar.

### 2. Verificar que Playwright ve el servidor

```bash
cd apps/web
npx playwright test user-journeys/complete-onboarding.spec.ts -g "should display" --debug
```

### 3. Ver logs completos

```bash
npm run test:e2e -- --reporter=verbose
```

### 4. Ejecutar un test individual

```bash
npx playwright test e2e/user-journeys/complete-onboarding.spec.ts
```

---

## 📋 Checklist

- [ ] Servidor dev corriendo (`npm run dev`)
- [ ] Puedes acceder a http://localhost:5173 en navegador
- [ ] `playwright.config.ts` tiene `reuseExistingServer: true`
- [ ] Ejecutas `npm run test:e2e` en otra terminal
- [ ] Tests inician sin timeout

---

## 💡 Tips

### Para Desarrollo Rápido

```bash
# Terminal 1
npm run dev

# Terminal 2
npm run test:e2e:ui
```

UI mode permite:
- ✅ Ver tests en tiempo real
- ✅ Pausar y reanudar
- ✅ Inspeccionador integrado
- ✅ Muy útil para debugging

### Ejecutar Tests Específicos

```bash
# Por nombre
npx playwright test -g "should complete onboarding"

# Por archivo
npx playwright test user-journeys/

# Por navegador
npx playwright test --project=chromium
```

### Limpiar y Reintentar

```bash
# Eliminar cache
rm -rf .playwright

# Reinstalar browsers
npx playwright install

# Ejecutar tests
npm run test:e2e
```

---

## 🆘 Errores Comunes

### "Connection refused"
```
Error: connect ECONNREFUSED 127.0.0.1:5173
```
**Solución**: Asegúrate de que `npm run dev` está corriendo en la terminal 1.

### "Timed out"
```
Error: Timed out waiting 60000ms
```
**Solución**: Ver arriba - probablemente servidor no está listo. Espera 10s después de ver el message "built in X ms".

### "Port already in use"
```
Error: listen EADDRINUSE: address already in use :::5173
```
**Solución**: 
```bash
# Mata el proceso en puerto 5173
lsof -i :5173
kill -9 <PID>

# O simplemente cierra la otra terminal y reinicia
```

### "Selector not found"
```
Error: Target page, context or browser has been closed
```
**Solución**: 
- Los selectores en los tests pueden no coincidir con tu aplicación actual
- Usa `npm run test:e2e:ui --headed` para ver qué está pasando
- Actualiza los selectores en los test files

---

## 📚 Recursos

- [Playwright Config](https://playwright.dev/docs/test-configuration)
- [Debugging](https://playwright.dev/docs/debug)
- [Web Server](https://playwright.dev/docs/test-webserver)

---

**Last Updated**: 23/03/2026  
**Status**: ✅ Solución implementada