# ⚡ Fase 4: CI/CD Quick Start

## 🚀 5-Minute Setup

### 1. Copiar Workflows

Los workflows ya están creados en:
- `.github/workflows/test.yml`
- `.github/workflows/quality.yml`
- `.github/workflows/deploy-preview.yml`
- `.github/dependabot.yml`

### 2. Configurar GitHub Secrets

En GitHub → Settings → Secrets, agregar:

```
VERCEL_TOKEN             → Tu token de Vercel
VERCEL_ORG_ID            → Tu Org ID
VERCEL_PROJECT_ID        → Tu Project ID
VITE_SUPABASE_URL        → Tu Supabase URL
VITE_SUPABASE_ANON_KEY   → Tu Anon Key
VITE_STRIPE_PUBLISHABLE  → Tu Stripe Key
```

### 3. Configurar Branch Protection

GitHub → Settings → Branches → Add rule

```
Branch pattern: main, develop

✅ Require status checks to pass
   - Tests
   - Lint

✅ Require branches up to date
✅ Require 1 code review
```

### 4. Test Local

```bash
# Simular CI
export CI=true
./scripts/ci-test.sh
```

### 5. Hacer Push

```bash
git push origin feature/something
```

✅ **Los workflows se ejecutarán automáticamente**

---

## ✅ Verificar que Funciona

1. Go to GitHub **Actions** tab
2. Ver `test.yml` corriendo
3. Esperar a que termine (~5 min)
4. Ver status ✅ o ❌

---

## 📊 Workflow Outputs

### En PR

```
Checks: Test results comentados
Preview: URL de preview en Vercel
Artifacts: Screenshots/videos si E2E falló
```

### En Main

```
Coverage: Reportado a Codecov
Deploy: Automático si tests pasaron
```

---

## 🆘 Troubleshooting Rápido

| Problema | Solución |
|----------|----------|
| Workflows no corren | Verificar `.github/workflows/*.yml` existen |
| Secrets not found | Configurar en Settings → Secrets |
| Tests fallan | Ver logs en Actions tab |
| Deploy falla | Verificar VERCEL tokens válidos |

---

**Done! Your CI/CD is live** 🎉