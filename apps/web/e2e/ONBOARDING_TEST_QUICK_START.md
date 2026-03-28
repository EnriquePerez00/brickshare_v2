# Quick Start: Onboarding E2E Tests

## ⚡ 30-Second Setup

```bash
# 1. Create test user (one-time)
psql postgresql://postgres:postgres@127.0.0.1:5433/postgres \
  -f scripts/create-e2e-onboarding-user.sql

# 2. Start dev server (keep running)
cd apps/web && npm run dev

# 3. Run tests (in another terminal)
cd apps/web && npx playwright test e2e/user-journeys/complete-onboarding.spec.ts
```

## ✅ Expected Output

```
Running 4 tests using 1 worker

  ✓ [chromium] › complete-onboarding.spec.ts:18:3 › should complete signup (3.5s)
  ✓ [chromium] › complete-onboarding.spec.ts:46:3 › should validate required fields (1.2s)
  ✓ [chromium] › complete-onboarding.spec.ts:60:3 › should reject weak passwords (1.5s)
  ✓ [chromium] › complete-onboarding.spec.ts:77:3 › should complete login (2.8s)

  4 passed (9s)
```

## 🎯 What's Being Tested

1. **Signup** - New user registration with unique email
2. **Validation** - Required fields enforcement
3. **Password** - Weak password rejection
4. **Login** - Existing user authentication

## 🔍 Interactive Mode

```bash
# See the browser in action
npx playwright test e2e/user-journeys/complete-onboarding.spec.ts --ui
```

## 📊 View Results

```bash
npx playwright show-report
```

## 🐛 Troubleshooting

### Tests fail with "Cannot connect"
**Solution**: Start dev server first
```bash
cd apps/web && npm run dev
```

### Test user doesn't exist
**Solution**: Create it
```bash
psql postgresql://postgres:postgres@127.0.0.1:5433/postgres \
  -f scripts/create-e2e-onboarding-user.sql
```

### Supabase not running
**Solution**: Start it
```bash
supabase start
```

## 📝 Test Credentials

**Pre-created Test User**:
- Email: `e2e.onboarding@test.com`
- Password: `TestPassword123!`
- Status: Verified, incomplete profile, no subscription

## 🚀 CI/CD Ready

These tests are ready for GitHub Actions integration. See [E2E_CONFIGURATION.md](./E2E_CONFIGURATION.md) for details.

---

**Status**: ✅ All tests passing  
**Duration**: ~9 seconds  
**Maintenance**: Low (stable selectors)