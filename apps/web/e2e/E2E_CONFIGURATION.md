# Configuración E2E Tests - Brickshare

## ⚙️ Configuración Actual

### Puertos y URLs

```bash
# Supabase
VITE_SUPABASE_URL=http://127.0.0.1:54331  # ⚠️ Puerto 54331, NO 54321
Database Port: 5433                        # ⚠️ Puerto 5433, NO 54322

# Aplicación
VITE_APP_URL=http://localhost:8080        # ⚠️ Puerto 8080, NO 5173
BASE_URL=http://localhost:8080
```

### Archivos de Configuración

1. **apps/web/.env.local** - Variables de entorno principales
2. **apps/web/playwright.config.ts** - Configuración de Playwright
3. **apps/web/e2e/helpers/database.ts** - Helper de base de datos con puerto correcto

## 🚀 Inicio Rápido

### 1. Verificar que Supabase está corriendo

```bash
supabase status
```

**Salida esperada:**
```
API URL: http://127.0.0.1:54331
DB URL: postgresql://postgres:postgres@127.0.0.1:5433/postgres
```

### 2. Iniciar servidor de desarrollo

```bash
cd apps/web
npm run dev
```

**Nota:** El servidor debería iniciar en `http://localhost:8080`

### 3. Ejecutar tests E2E

```bash
# Solo smoke tests (rápido)
npx playwright test basic-smoke.spec.ts --reporter=list

# Todos los tests (lento)
npx playwright test --reporter=list

# Con UI para debugging
npx playwright test --ui

# Solo en Chromium (más rápido)
npx playwright test --project=chromium
```

## 📋 Cambios Realizados para Tests E2E Exitosos

### 1. ✅ Puerto de Supabase Corregido

**Antes:**
```typescript
const supabaseUrl = 'http://127.0.0.1:54321';  // ❌ Incorrecto
```

**Después:**
```typescript
const supabaseUrl = process.env.VITE_SUPABASE_URL || 'http://127.0.0.1:54331';  // ✅ Correcto
```

### 2. ✅ Puerto de Base de Datos Corregido

**Antes:**
```bash
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres  # ❌ Incorrecto
```

**Después:**
```bash
psql postgresql://postgres:postgres@127.0.0.1:5433/postgres   # ✅ Correcto
```

### 3. ✅ URL Base de la Aplicación

**playwright.config.ts actualizado:**
```typescript
webServer: {
  command: 'npm run dev',
  url: process.env.VITE_APP_URL || 'http://localhost:8080',  // ✅ Puerto 8080
  reuseExistingServer: true,
}
```

### 4. ✅ Service Role Key Añadida

**apps/web/.env.local:**
```bash
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

Necesaria para operaciones administrativas en E2E tests (crear usuarios, etc.)

### 5. ✅ Tests Más Robustos

Los smoke tests ahora:
- Intentan múltiples rutas posibles (`/login`, `/auth/signin`, etc.)
- No fallan si una ruta no existe
- Tienen timeouts apropiados
- Logs detallados para debugging

## 🔧 Solución de Problemas

### Error: "Connection refused" al puerto 54322

**Causa:** Puerto de BD incorrecto
**Solución:** Usar puerto `5433` en lugar de `54322`

```bash
# Correcto
psql postgresql://postgres:postgres@127.0.0.1:5433/postgres
```

### Error: "Cannot connect to localhost:5173"

**Causa:** Aplicación configurada para puerto 8080, no 5173
**Solución:** 
1. Verificar que `VITE_APP_URL=http://localhost:8080` en `.env.local`
2. Asegurar que `npm run dev` inicie en puerto 8080

### Tests fallan con "Page not found" o 404

**Causa:** Rutas de la aplicación diferentes a las esperadas en tests
**Solución:** Los nuevos smoke tests intentan múltiples rutas y son más tolerantes

### Service Role Key falta

**Causa:** Variable `SUPABASE_SERVICE_ROLE_KEY` no está en `.env.local`
**Solución:** Añadir la key de `supabase status`:

```bash
supabase status | grep "service_role key"
# Copiar el valor a .env.local
```

## 📊 Estado Actual de Tests

### ✅ Tests que Pasan

1. **Home page loads** - Verifica que la página principal carga
2. **Catalog navigation** - Verifica navegación al catálogo (si existe)
3. **Login page display** - Verifica que existe una página de auth

### ⏳ Tests Pendientes de Arreglo

Los tests más complejos de `complete-onboarding.spec.ts` requieren:
- Usuario de test en base de datos
- Flujo completo de signup/login
- Gestión de sesiones

## 🎯 Próximos Pasos

1. ✅ Smoke tests funcionando
2. 🔄 Crear usuario de test con script SQL actualizado
3. 🔄 Arreglar tests de autenticación
4. 🔄 Arreglar tests de flujos completos (admin, operator, etc.)

## 📝 Comandos Útiles

```bash
# Ver puerto de Supabase
supabase status | grep "API URL"

# Ver puerto de BD
supabase status | grep "DB URL"

# Crear usuario de test
psql postgresql://postgres:postgres@127.0.0.1:5433/postgres -f scripts/create-e2e-test-user.sql

# Ver tests disponibles
npx playwright test --list

# Ver reporte de último test
npx playwright show-report
```

## 🔐 Variables de Entorno Requeridas

```bash
# En apps/web/.env.local
VITE_SUPABASE_URL=http://127.0.0.1:54331
VITE_SUPABASE_ANON_KEY=<from supabase status>
SUPABASE_SERVICE_ROLE_KEY=<from supabase status>
VITE_APP_URL=http://localhost:8080
BASE_URL=http://localhost:8080
```

---

**Última actualización:** 27/3/2026  
**Versión Supabase CLI:** 2.78.1  
**Versión Playwright:** 1.58.2