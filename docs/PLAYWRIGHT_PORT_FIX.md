# Playwright Port Configuration Fix

**Fecha**: 2026-03-26  
**Problema**: Playwright UI no cargaba tests debido a configuración incorrecta de puerto

## 🐛 Problema Identificado

Playwright estaba configurado para conectarse a `http://localhost:5173`, pero el servidor de desarrollo real estaba corriendo en `http://localhost:8080`.

Esto causaba:
- ❌ CLI listaba los tests correctamente (solo lee archivos)
- ❌ UI no podía cargar los tests (intentaba conectar al puerto incorrecto)
- ❌ Tests fallaban al ejecutarse (no encontraban la aplicación)

## ✅ Solución Implementada

### 1. Actualizado `apps/web/playwright.config.ts`

```typescript
// ANTES
baseURL: 'http://localhost:5173',
webServer: {
  url: 'http://localhost:5173',
}

// DESPUÉS
baseURL: process.env.BASE_URL || 'http://localhost:8080',
webServer: {
  url: process.env.BASE_URL || 'http://localhost:8080',
}
```

### 2. Actualizado `apps/web/.env.local`

```bash
VITE_APP_URL=http://localhost:8080
BASE_URL=http://localhost:8080
PLAYWRIGHT_BASE_URL=http://localhost:8080
```

## 🚀 Cómo Usar Ahora

### Opción 1: Con servidor ya iniciado (Recomendado)

```bash
# Si tu servidor ya está corriendo en localhost:8080
cd apps/web
npx playwright test --ui
```

Gracias a `reuseExistingServer: true`, Playwright reutilizará tu servidor existente.

### Opción 2: Dejar que Playwright inicie el servidor

```bash
cd apps/web
# Playwright ejecutará 'npm run dev' automáticamente
npx playwright test --ui
```

### Opción 3: Ejecutar tests sin UI

```bash
cd apps/web
npx playwright test
```

## 🔧 Configuración Flexible

Si en el futuro necesitas cambiar el puerto, solo actualiza la variable de entorno:

```bash
# En .env.local
BASE_URL=http://localhost:OTRO_PUERTO
```

## ✅ Verificación

Para confirmar que todo funciona:

```bash
cd apps/web

# 1. Listar tests (debe mostrar 222 tests)
npx playwright test --list

# 2. Verificar configuración
cat .env.local | grep BASE_URL

# 3. Abrir UI
npx playwright test --ui
```

## 📚 Archivos Modificados

- ✅ `apps/web/playwright.config.ts` - Puerto 5173 → 8080
- ✅ `apps/web/.env.local` - Agregadas variables BASE_URL y PLAYWRIGHT_BASE_URL

## 🎯 Resultado

Ahora Playwright UI debería:
- ✅ Cargar correctamente todos los tests
- ✅ Conectarse al servidor en el puerto correcto
- ✅ Permitir ejecutar tests interactivamente
- ✅ Mostrar los 222 tests disponibles

---

**Estado**: ✅ RESUELTO  
**Impacto**: Tests E2E ahora funcionan correctamente con Playwright UI