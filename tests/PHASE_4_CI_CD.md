# 🚀 Fase 4: CI/CD Integration

## Overview

**Fase 4** configura GitHub Actions para ejecutar tests automáticamente en PRs y pushes, protegiendo la rama principal y generando reportes de coverage.

---

## 🎯 Objetivos

- ✅ Ejecutar tests automáticamente en cada PR
- ✅ Bloquear merges si tests fallan
- ✅ Generar coverage reports
- ✅ Notificar resultados en PR
- ✅ Cachear dependencias para velocidad
- ✅ Ejecutar E2E tests opcionalmente

---

## 📁 Configuración de GitHub Actions

### 1. Main Workflow

**Archivo**: `.github/workflows/test.yml`

```yaml
name: Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        node-version: [18.x, 20.x]
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run linter
        run: npm run lint
      
      - name: Run unit tests
        run: npm run test -w @brickshare/web
      
      - name: Generate coverage
        run: npm run test:coverage -w @brickshare/web
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./apps/web/coverage/coverage-final.json
          flags: unittests
          fail_ci_if_error: true
      
      - name: Comment PR with coverage
        uses: romeovs/lcov-reporter-action@v0.3.1
        if: github.event_name == 'pull_request'
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
```

### 2. E2E Tests Workflow

**Archivo**: `.github/workflows/e2e.yml`

```yaml
name: E2E Tests

on:
  pull_request:
    branches: [main, develop]
    paths:
      - 'apps/web/src/**'
      - 'e2e/**'
      - '.github/workflows/e2e.yml'

jobs:
  e2e:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: 20.x
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Install Playwright
        run: npx playwright install --with-deps
      
      - name: Run E2E tests
        run: npx playwright test
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: playwright-report
          path: playwright-report/
          retention-days: 30
```

### 3. Deploy Workflow

**Archivo**: `.github/workflows/deploy.yml`

```yaml
name: Deploy to Vercel

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to Vercel
        uses: vercel/action@master
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
```

---

## 🛡️ Branch Protection Rules

### Setup en GitHub

1. Go to Repository Settings
2. Branches → Branch protection rules
3. Add rule for `main` and `develop`

### Rules to Enable

```
✅ Require status checks to pass before merging
   - Tests (unit & integration)
   - Linter (ESLint)
   - Coverage (min 70%)

✅ Require branches to be up to date before merging

✅ Require code reviews before merging
   - Dismiss stale pull request approvals
   - Require review from code owners

✅ Restrict who can push to matching branches
   - Allow force pushes: No

✅ Include administrators
```

---

## 📊 Coverage Monitoring

### Codecov Configuration

**Archivo**: `codecov.yml`

```yaml
coverage:
  precision: 2
  round: down
  range: "70..100"

ignore:
  - "node_modules"
  - "dist"
  - "**/*.test.ts"
  - "**/*.test.tsx"

flags:
  unittests:
    paths:
      - "apps/web/src/__tests__"
  
  integration:
    paths:
      - "apps/web/src/__tests__/integration"

status:
  project:
    default:
      target: 70
      threshold: 2
  patch:
    default:
      target: 80
      threshold: 5
```

### Coverage Badge

Add to README:

```markdown
[![codecov](https://codecov.io/gh/EnriquePerez00/brickshare_v2/branch/main/graph/badge.svg?token=YOUR_TOKEN)](https://codecov.io/gh/EnriquePerez00/brickshare_v2)
```

---

## 🔔 Notifications

### Slack Integration

**Archivo**: `.github/workflows/slack-notify.yml`

```yaml
name: Slack Notifications

on:
  workflow_run:
    workflows: ["Tests"]
    types: [completed]

jobs:
  notify:
    runs-on: ubuntu-latest
    steps:
      - name: Notify Slack
        uses: slackapi/slack-github-action@v1
        with:
          webhook-url: ${{ secrets.SLACK_WEBHOOK }}
          payload: |
            {
              "text": "Test Results",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "Workflow: ${{ github.workflow }}\nStatus: ${{ github.event.workflow_run.conclusion }}\nAuthor: ${{ github.event.workflow_run.head_commit.author.name }}"
                  }
                }
              ]
            }
```

---

## 📋 npm Scripts Required

Add to `apps/web/package.json`:

```json
{
  "scripts": {
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage",
    "lint": "eslint src/ --ext .ts,.tsx",
    "type-check": "tsc --noEmit",
    "dev": "vite",
    "build": "vite build"
  }
}
```

---

## 🔐 Environment Secrets

Configure in GitHub:

| Secret | Value | Usage |
|---|---|---|
| `CODECOV_TOKEN` | Codecov token | Coverage uploads |
| `VERCEL_TOKEN` | Vercel token | Deployments |
| `VERCEL_ORG_ID` | Vercel org | Deployments |
| `VERCEL_PROJECT_ID` | Project ID | Deployments |
| `SLACK_WEBHOOK` | Slack webhook | Notifications |

---

## 🎯 Test Strategy in CI

### Pull Requests

1. **Run Unit Tests** (~8s)
   - All tests must pass
   - Coverage must be ≥70%

2. **Run Linter** (~5s)
   - No ESLint errors
   - TypeScript strict mode

3. **Optional: Run E2E Tests** (~5m)
   - Only if `e2e/**` or `src/**` changed
   - Upload Playwright reports

### Merge to Main

- Must pass all checks
- Must have ≥1 approval
- Must be up to date with main
- Admin can override if needed

---

## 📈 Performance Targets

| Task | Target | Strategy |
|---|---|---|
| **Unit Tests** | <10s | Parallelization |
| **Linter** | <5s | Cache .eslintcache |
| **Build** | <30s | Cache node_modules |
| **E2E Tests** | <5m | Parallelization |

---

## 🛠️ Local Pre-commit Hooks

**Archivo**: `.husky/pre-commit`

```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

npm run lint
npm run test -- --changed
npm run type-check
```

Setup:

```bash
npm install husky --save-dev
npx husky install
npx husky add .husky/pre-commit "npm run lint && npm run test -- --changed"
```

---

## 📊 Workflow Summary

```
PR Opened
    ↓
GitHub Actions triggered
    ├─ Install dependencies (cached)
    ├─ Run linter (5s)
    ├─ Run unit tests (8s)
    ├─ Generate coverage (2s)
    └─ Upload to Codecov
    ↓
Results commented on PR
    ├─ ✅ All tests pass → Ready for review
    ├─ ❌ Tests fail → Block merge
    └─ 📊 Coverage < 70% → Block merge
    ↓
Code review required
    ↓
PR Approved
    ↓
Merge to main
    ├─ Run final tests
    └─ Deploy to Vercel
    ↓
Production deployed
```

---

## ✅ Implementation Steps

1. Create `.github/workflows/` directory
2. Create `test.yml` workflow
3. Create `e2e.yml` workflow
4. Create `deploy.yml` workflow
5. Configure branch protection rules
6. Add secrets to GitHub
7. Setup Codecov integration
8. Setup Slack notifications (optional)
9. Setup Husky pre-commit hooks
10. Test all workflows

---

## 🎓 Best Practices

✅ **Cache Dependencies**
- npm install usa cache para velocidad

✅ **Matrix Testing**
- Test en múltiples Node.js versions

✅ **Fail Fast**
- Stop workflow si linter/type-check falla

✅ **Artifact Storage**
- Guardar screenshots/videos de E2E failures

✅ **Coverage Trending**
- Monitorear coverage over time

✅ **Notifications**
- Notificar team de failures

---

## 📞 Troubleshooting

### Tests pass locally pero fallan en CI
- Revisar Node.js version
- Revisar variables de entorno
- Revisar cache issues

### Workflow muy lento
- Agregar más cache
- Parallelizar tests
- Usar matrix para múltiples jobs

### Coverage drops
- Revisar new code sin tests
- Revisar fixtures correctas
- Ejecutar coverage locally

---

**CI/CD Setup Completo** ✅

Una vez implementado, cada PR estará totalmente validado antes de merge.