# E2E Tests Setup Fix - Resolution Summary

**Date**: 2026-03-26  
**Issue**: E2E tests failing due to missing environment variables and exports

## Problems Identified

1. **Missing `SUPABASE_SERVICE_ROLE_KEY`**: Tests couldn't connect to database
2. **Missing exports in `database.ts`**: Functions `resetDatabase` and `createReturnShipment` not exported
3. **No environment variable loading**: Playwright config wasn't loading `.env.local`
4. **Missing `dotenv` dependency**: Required to load environment variables

## Solutions Implemented

### 1. Enhanced `apps/web/e2e/helpers/database.ts`

Added missing exports and improved error messages:

```typescript
// Added environment variable loading
if (process.env.NODE_ENV !== 'production') {
  try {
    const dotenv = await import('dotenv');
    dotenv.config({ path: '.env.local' });
  } catch (error) {
    console.warn('dotenv not available, using process.env directly');
  }
}

// Added missing functions
export async function resetDatabase() { /* ... */ }
export async function createReturnShipment(params) { /* ... */ }
```

### 2. Updated `apps/web/playwright.config.ts`

Added explicit environment variable loading:

```typescript
import dotenv from 'dotenv';

// Load .env.local for E2E tests
dotenv.config({ path: '.env.local' });
```

### 3. Created Setup Script

New automated setup script: `apps/web/e2e/setup-e2e-env.sh`

This script:
- Checks Supabase status
- Extracts credentials automatically
- Creates `.env.local` with all required variables
- Provides clear instructions for next steps

Usage:
```bash
cd apps/web
./e2e/setup-e2e-env.sh
```

### 4. Installed Missing Dependencies

```bash
npm install --save-dev dotenv
```

### 5. Documentation Updates

- Enhanced `apps/web/e2e/README.md` with setup instructions
- Created `apps/web/e2e/TROUBLESHOOTING.md` with common issues and solutions

## Required Environment Variables

The following variables must be in `apps/web/.env.local`:

```env
# Supabase Configuration
VITE_SUPABASE_URL=http://127.0.0.1:54321
VITE_SUPABASE_ANON_KEY=<from supabase status>
SUPABASE_SERVICE_ROLE_KEY=<from supabase status>

# App Configuration
VITE_APP_URL=http://localhost:5173

# Stripe Configuration (optional for E2E)
VITE_STRIPE_PUBLISHABLE_KEY=pk_test_...
```

## Running Tests Now

### Quick Start
```bash
# 1. Setup environment (first time only)
cd apps/web
./e2e/setup-e2e-env.sh

# 2. Run tests
npx playwright test

# 3. View report
npx playwright show-report
```

### Test Commands
```bash
# Run all tests
npx playwright test

# Run specific test
npx playwright test e2e/user-journeys/complete-onboarding.spec.ts

# Run in UI mode (interactive)
npx playwright test --ui

# Run with browser visible
npx playwright test --headed

# Debug mode
npx playwright test --debug
```

## Pre-flight Checklist

Before running E2E tests:

- [x] Supabase running (`supabase start`)
- [x] `.env.local` exists with required variables
- [x] `dotenv` dependency installed
- [x] Helper functions exported in `database.ts`
- [x] Playwright config loads environment variables
- [ ] Dev server running (`npm run dev`)

## Test Results

After fixes applied:

```
✅ Environment variables loading correctly
✅ Database helpers accessible
✅ Playwright can connect to Supabase
✅ Tests can run without import errors
```

## Files Modified

1. `apps/web/e2e/helpers/database.ts` - Added exports and env loading
2. `apps/web/playwright.config.ts` - Added dotenv config
3. `apps/web/e2e/setup-e2e-env.sh` - New setup script
4. `apps/web/e2e/README.md` - Enhanced documentation
5. `apps/web/e2e/TROUBLESHOOTING.md` - New troubleshooting guide
6. `apps/web/package.json` - Added dotenv dev dependency

## Next Steps

1. Run full E2E test suite to verify all tests pass
2. Add E2E tests to CI/CD pipeline (`.github/workflows/test.yml`)
3. Consider adding more test scenarios
4. Document test data requirements

## Common Issues

See `apps/web/e2e/TROUBLESHOOTING.md` for detailed solutions to:
- "SUPABASE_SERVICE_ROLE_KEY is required"
- "Module does not provide an export"
- "Cannot connect to Supabase"
- "Test timeout" errors
- Database cleanup issues

## References

- [Playwright Documentation](https://playwright.dev/)
- [Supabase Local Development](https://supabase.com/docs/guides/cli/local-development)
- [Project E2E Tests Guide](./TESTING_E2E_INSTRUCTIONS.md)