# 📋 Fase 4: CI/CD Implementation Guide

## 🎯 Objetivo

Implementar un pipeline de Integración Continua/Despliegue Continuo (CI/CD) automático que:
- ✅ Ejecuta tests en cada push/PR
- ✅ Valida code quality
- ✅ Genera reportes de coverage
- ✅ Deployea previews en PRs
- ✅ Protege ramas principales

---

## 📁 Archivos Creados en Fase 4

### GitHub Actions Workflows

```
.github/
├── workflows/
│   ├── test.yml              # Tests (lint, unit, integration, e2e)
│   ├── quality.yml           # Code quality checks
│   ├── deploy-preview.yml    # Vercel preview deployments
│   └── dependabot.yml        # Auto dependency updates
```

### Scripts de Soporte

```
scripts/
├── ci-setup.sh              # Setup environment
├── ci-test.sh               # Run all tests
└── verify-dev-server.sh     # Verify dev server (existente)
```

---

## 🚀 Workflow: `test.yml`

### Objetivo
Ejecutar todos los tests automáticamente en cada push/PR.

### Jobs

#### 1. **Lint & Type Check**
```
- Ejecuta ESLint
- Ejecuta TypeScript type check
- Verifica sintaxis y tipos
- ⏱️ Tiempo: ~10s
```

#### 2. **Unit Tests** (Matrix: Node 18.x, 20.x)
```
- Ejecuta Vitest unit tests
- Genera coverage report
- Upload a Codecov
- ⏱️ Tiempo: ~30s por Node version
```

#### 3. **Integration Tests**
```
- Inicia PostgreSQL container
- Ejecuta Vitest integration tests
- Requiere DB setup
- ⏱️ Tiempo: ~60s
```

#### 4. **E2E Tests**
```
- Instala Playwright browsers
- Ejecuta tests E2E
- Upload de artifacts
- ⏱️ Tiempo: ~3 minutos
- ⚠️ Solo en PRs y develop
```

#### 5. **Summary**
```
- Verifica que todos los tests pasaron
- Resume status general
```

---

## 🧹 Workflow: `quality.yml`

### Objetivo
Validar code quality y seguridad.

### Jobs

#### 1. **Code Quality Checks**
```
- ESLint validation
- TypeScript type checking
- Busca console.* statements
- Busca TODO/FIXME comments
- Verifica bundle size
```

#### 2. **Dependency Check**
```
- npm audit (seguridad)
- Busca packages outdated
- Reporta vulnerabilidades
```

---

## 🌐 Workflow: `deploy-preview.yml`

### Objetivo
Deploy automático a Vercel en PRs.

### Features

```yaml
- Builds la aplicación
- Deploya a Vercel preview environment
- Comenta el PR con URL de preview
- Corre smoke tests
- Verifica accesibilidad
```

### Resultado

En cada PR verás un comentario como:

```
🎉 Preview Deploy Ready!

✅ View Preview: https://brickshare-pr-123.vercel.app

- Commit: abc1234
- Branch: feature/test
- Deploy Status: Success
```

---

## 🔄 Workflow: `dependabot.yml`

### Objetivo
Automatizar actualizaciones de dependencias.

### Configuración

```yaml
- npm: Actualización semanal
- GitHub Actions: Actualización semanal
- Max 5 PRs abiertos
- Auto-assign a EnriquePerez00
```

---

## ⚙️ Setup Requerido

### 1. GitHub Secrets

Configura estos secrets en GitHub (Settings → Secrets):

```
VERCEL_TOKEN
VERCEL_ORG_ID
VERCEL_PROJECT_ID
VITE_SUPABASE_URL
VITE_SUPABASE_ANON_KEY
VITE_STRIPE_PUBLISHABLE_KEY
```

### 2. Branch Protection Rules

1. Go to Settings → Branches
2. Add rule for `main` and `develop`
3. Enable:
   - ✅ Require status checks to pass
   - ✅ Require branches up to date
   - ✅ Require code reviews (1)
   - ✅ Dismiss stale reviews
   - ✅ Restrict who can push

### 3. Codecov (Opcional)

1. Go to https://codecov.io
2. Link GitHub account
3. Select repository
4. Get token y configurar

---

## 📊 Test Pipeline

```
┌─────────────────────────────────────────┐
│  Push or PR Opened                      │
└────────────┬────────────────────────────┘
             │
    ┌────────▼────────┐
    │   test.yml      │
    └────────┬────────┘
             │
    ┌────────▼──────────────────┐
    │ Lint & Type Check         │
    │ ⏱️  ~10s                  │
    └────────┬──────────────────┘
             │
    ┌────────▼──────────────────┐
    │ Unit Tests (Node 18, 20)  │
    │ ⏱️  ~30s cada             │
    └────────┬──────────────────┘
             │
    ┌────────▼──────────────────┐
    │ Integration Tests         │
    │ ⏱️  ~60s                  │
    └────────┬──────────────────┘
             │
    ┌────────▼──────────────────┐
    │ E2E Tests                 │
    │ ⏱️  ~3min (si aplica)     │
    └────────┬──────────────────┘
             │
    ┌────────▼──────────────────┐
    │ Summary & Status          │
    │                           │
    │ ✅ All pass → OK merge    │
    │ ❌ Any fail → Block merge │
    └────────────────────────────┘
```

**Total Time**: ~5-7 minutes

---

## 🔍 Visualizar Workflows en GitHub

1. Go to **Actions** tab en GitHub
2. Selecciona workflow (Tests, Quality, etc)
3. Haz click en el run más reciente
4. Ver logs detallados de cada job

### Filtrar por Status

```
✅ Passed      - Todos los tests pasaron
❌ Failed      - Al menos uno falló
⏳ In Progress - Actualmente corriendo
⊘ Skipped     - No se ejecutó (ej: solo en develop)
```

---

## 📈 Monitorear Coverage

### En GitHub

1. Go to PR
2. Ver comentario de Codecov (si configurado)
3. Click para ver detalles de cobertura

### Localmente

```bash
# Generar coverage report local
cd apps/web
npm run test -- --coverage

# Ver en HTML
open coverage/index.html
```

---

## 🚀 Ejecutar Scripts Localmente

### Setup CI Environment

```bash
./scripts/ci-setup.sh
```

### Ejecutar Todos los Tests (como en CI)

```bash
./scripts/ci-test.sh
```

### Ejecutar Tests Específicos

```bash
# Unit tests
npm run test --workspace=@brickshare/web

# Unit tests + coverage
npm run test --workspace=@brickshare/web -- --coverage

# E2E tests
npm run test:e2e --workspace=@brickshare/web

# Linting
npm run lint --workspace=@brickshare/web

# Type check
npm run type-check --workspace=@brickshare/web
```

---

## ⚠️ Troubleshooting

### Tests pass locally pero fallan en CI

**Causas comunes:**
- Node.js version diferente
- Variables de entorno faltantes
- Cache issues
- Permisos de archivos

**Solución:**

```bash
# Simular CI environment local
export CI=true
export NODE_ENV=test
npm ci                    # no npm install
npm run lint --workspace=@brickshare/web
npm run test --workspace=@brickshare/web
```

### Workflow muy lento

**Causas:**
- node_modules sin cachear
- Dependencias faltantes
- Database setup lento

**Solución:**
```yaml
# Ya incluido en workflows:
cache: 'npm'              # Cache node_modules
services: postgres        # Parallelizar DB
```

### E2E tests fallan en CI

**Causas:**
- Servidor no está disponible
- Selectores incorrectos
- Timeouts muy cortos

**Solución:**
```bash
# Ver artifacts
npx playwright show-report
```

---

## 📋 npm Scripts Requeridos

Asegurate que estos scripts estén en `apps/web/package.json`:

```json
{
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "lint": "eslint . --ext .ts,.tsx",
    "type-check": "tsc --noEmit",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui"
  }
}
```

---

## 🎓 Best Practices

### ✅ DO

```
✅ Escribir tests para features nuevas
✅ Mantener tests actualizados
✅ Revisar coverage reports
✅ Arreglar warnings en CI
✅ Usar matrix para múltiples Node versions
✅ Cachear dependencies
```

### ❌ DON'T

```
❌ Ignorar test failures
❌ Hacer push sin tests
❌ Mergear sin status checks
❌ Dejar console.logs en code
❌ Ignorar security warnings
❌ Crear workflows sin documentación
```

---

## 📞 Support

### Archivos de Referencia

- `.github/workflows/test.yml` - Workflow principal
- `tests/PHASE_4_QUICKSTART.md` - Quick start
- `tests/PHASE_4_TROUBLESHOOTING.md` - Troubleshooting

### Comandos Útiles

```bash
# Ver logs del último workflow
gh run list --limit 1 --json name,status,conclusion

# Re-ejecutar un workflow
gh run rerun <RUN_ID>

# Ver workflow específico
gh run view <RUN_ID>
```

---

## ✅ Checklist de Implementación

- [ ] Copiar `.github/workflows/` archivos
- [ ] Copiar `scripts/ci-*.sh` archivos
- [ ] Configurar GitHub Secrets
- [ ] Configurar Branch Protection Rules
- [ ] Verificar que workflows se ejecutan
- [ ] Revisar primeros resultados
- [ ] Configurar Codecov (opcional)
- [ ] Agregar badges a README
- [ ] Documentar para el team
- [ ] Entrenar team en CI/CD

---

**Fase 4 Completa** ✅

Una vez implementado tendrás un pipeline robusto que garantiza quality en cada change.