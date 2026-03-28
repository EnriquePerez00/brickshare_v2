# E2E Tests - Service Role Key Configuration Fix

**Date**: 2026-03-26  
**Issue**: Playwright tests not loading due to missing `SUPABASE_SERVICE_ROLE_KEY`  
**Status**: ✅ Resolved

## Problem Description

When running `npx playwright test --list` or `npx playwright test --ui`, the tests would not load and showed the error:

```
Error: SUPABASE_SERVICE_ROLE_KEY is required for E2E tests
   at helpers/database.ts:7
```

The UI mode would open but show an empty test list or get stuck on "Loading...".

## Root Cause

The `SUPABASE_SERVICE_ROLE_KEY` environment variable was:
1. Not present in `apps/web/.env.local`
2. Or present but empty/invalid

This variable is **required** because:
- E2E tests use `apps/web/e2e/helpers/database.ts` 
- This helper creates a Supabase client with **service role** permissions
- Service role is needed to:
  - Reset database between tests (`resetDatabase()`)
  - Seed test data (`seedTestData()`)
  - Create/delete test users via auth admin API
  - Bypass RLS policies for test setup

## Solution

### Quick Fix (Automatic)

```bash
cd apps/web

# Extract service role key from Supabase and add to .env.local
SERVICE_ROLE_KEY=$(supabase status | grep "service_role key:" | awk '{print $3}')
echo "SUPABASE_SERVICE_ROLE_KEY=$SERVICE_ROLE_KEY" >> .env.local

# Verify it was added
grep SUPABASE_SERVICE_ROLE_KEY .env.local
```

### Manual Fix

1. Get the service role key:
```bash
supabase status
```

Look for the line:
```
service_role key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

2. Add it to `apps/web/.env.local`:
```bash
cd apps/web
echo "SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." >> .env.local
```

Or open `.env.local` in an editor and add:
```
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU
```

### Using the Setup Script

The automated setup script can also configure this:

```bash
cd apps/web
./e2e/setup-e2e-env.sh
```

## Verification

After adding the key, verify it works:

```bash
cd apps/web

# 1. Check the variable is set
cat .env.local | grep SUPABASE_SERVICE_ROLE_KEY

# 2. List tests (should show all test files)
npx playwright test --list

# 3. Try UI mode
npx playwright test --ui
```

Expected output from `--list`:
```
Listing tests:
  [chromium] › e2e/admin-journeys/complete-assignment-flow.spec.ts:XX:XX
  [chromium] › e2e/admin-journeys/user-management.spec.ts:XX:XX
  [chromium] › e2e/error-scenarios/logistics-failures.spec.ts:XX:XX
  [chromium] › e2e/error-scenarios/payment-failures.spec.ts:XX:XX
  [chromium] › e2e/operator-journeys/complete-reception-flow.spec.ts:XX:XX
  [chromium] › e2e/operator-journeys/logistics-operations.spec.ts:XX:XX
  [chromium] › e2e/user-journeys/complete-onboarding.spec.ts:XX:XX
  [chromium] › e2e/user-journeys/set-rental-cycle.spec.ts:XX:XX
  [chromium] › e2e/user-journeys/subscription-flow.spec.ts:XX:XX

Total: XX tests in 9 files (chromium)
```

## Why This Variable is Critical

### What is Service Role Key?

The **service role key** is a special JWT token that:
- Has **full admin access** to Supabase
- **Bypasses Row Level Security (RLS)** policies
- Can use **admin-only APIs** (e.g., auth.admin.createUser)
- Should **NEVER** be exposed to the frontend

### Why E2E Tests Need It

```typescript
// apps/web/e2e/helpers/database.ts
export const supabase = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    persistSession: false,
    autoRefreshToken: false
  }
});
```

This client can:
1. **Reset database** - Delete all test data between tests
2. **Seed test data** - Create users, sets, inventory
3. **Manage auth users** - Create/delete via admin API
4. **Bypass RLS** - Access all tables regardless of policies

Without it, tests cannot:
- ❌ Clean up after themselves
- ❌ Create test users with verified emails
- ❌ Set up test data that would require admin permissions
- ❌ Access tables protected by RLS

## Security Considerations

### ⚠️ IMPORTANT: Service Role Key Security

1. **Never commit to Git**
   - `.env.local` is in `.gitignore`
   - Service role key has **full database access**

2. **Only use in local development**
   - The key from `supabase status` is for **local Docker instance**
   - Production keys are different and should stay in Supabase Cloud

3. **Never expose to frontend**
   - E2E tests run in Node.js (backend)
   - Frontend should only use `VITE_SUPABASE_ANON_KEY`

### Environment Files Hierarchy

```
apps/web/
├── .env.local          ← Local development (git-ignored)
│   └── SUPABASE_SERVICE_ROLE_KEY (for E2E tests)
├── .env.e2e.local      ← E2E-specific overrides (git-ignored)
├── .env.example        ← Template (committed, no secrets)
└── .env                ← Base config (if exists)
```

Loading order:
1. `.env` (if exists)
2. `.env.local` (overrides .env)
3. `.env.e2e.local` (overrides both for E2E tests)

## Troubleshooting

### Problem: Key is set but tests still fail

**Check 1**: Variable name spelling
```bash
grep -i service .env.local
```
Must be exactly: `SUPABASE_SERVICE_ROLE_KEY`

**Check 2**: Key format
```bash
cat .env.local | grep SUPABASE_SERVICE_ROLE_KEY
```
Should start with: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9`

**Check 3**: No quotes needed
```bash
# ❌ Wrong
SUPABASE_SERVICE_ROLE_KEY="eyJ..."

# ✅ Correct
SUPABASE_SERVICE_ROLE_KEY=eyJ...
```

### Problem: Supabase not running

```bash
supabase status
# If not running:
supabase start
```

### Problem: Different key each time

If you run `supabase db reset`, the keys might change. Solution:
```bash
# Re-extract and update
cd apps/web
SERVICE_ROLE_KEY=$(supabase status | grep "service_role key:" | awk '{print $3}')
sed -i '' "s/SUPABASE_SERVICE_ROLE_KEY=.*/SUPABASE_SERVICE_ROLE_KEY=$SERVICE_ROLE_KEY/" .env.local
```

## Related Files

- `apps/web/e2e/helpers/database.ts` - Uses service role key
- `apps/web/.env.local` - Where key should be stored
- `apps/web/playwright.config.ts` - Loads .env files via dotenv
- `apps/web/e2e/setup-e2e-env.sh` - Automated setup script
- `apps/web/e2e/verify-setup.sh` - Verification script

## Summary

✅ **Fixed**: Added `SUPABASE_SERVICE_ROLE_KEY` to `apps/web/.env.local`  
✅ **Tests loading**: `npx playwright test --list` now shows all tests  
✅ **UI mode working**: `npx playwright test --ui` displays test list  

The issue was simply missing environment variable configuration. All E2E test infrastructure is correctly set up, it just needed the service role key to authenticate with Supabase.

---

**Next Steps:**
1. Run tests: `npx playwright test`
2. Use UI mode: `npx playwright test --ui`
3. Debug specific test: `npx playwright test --debug e2e/user-journeys/complete-onboarding.spec.ts`