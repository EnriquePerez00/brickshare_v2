# E2E Tests Troubleshooting Guide

## Common Issues and Solutions

### 1. "SUPABASE_SERVICE_ROLE_KEY is required for E2E tests"

**Problem**: The test runner cannot find the required service role key.

**Solution**:
```bash
# Run the setup script
cd apps/web
./e2e/setup-e2e-env.sh
```

This will automatically:
- Start Supabase if not running
- Extract credentials from Supabase
- Create/update `.env.local` with required variables

**Manual fix** (if script fails):
1. Start Supabase: `supabase start`
2. Get credentials: `supabase status`
3. Create `apps/web/.env.local`:
   ```env
   VITE_SUPABASE_URL=http://127.0.0.1:54321
   VITE_SUPABASE_ANON_KEY=<from supabase status>
   SUPABASE_SERVICE_ROLE_KEY=<from supabase status>
   ```

---

### 2. "Module does not provide an export named 'resetDatabase'"

**Problem**: Helper functions are missing from `e2e/helpers/database.ts`.

**Solution**: This has been fixed in the latest version. If you still see this error:
1. Pull the latest code
2. Verify `database.ts` exports these functions:
   - `resetDatabase()`
   - `createReturnShipment()`
   - `createTestUser()`

---

### 3. "Timed out waiting 60000ms from config.webServer"

**Problem**: The development server couldn't start in time or failed to start.

**Common causes**:
1. Port 5173 is already in use
2. Dev server has errors and can't start
3. Server starts too slowly (takes > 60 seconds)
4. Wrong working directory

**Solutions**:

**Check if port is in use:**
```bash
lsof -ti:5173
# If something is using it, kill it:
kill -9 $(lsof -ti:5173)
```

**Increase timeout** (already set to 120s in config):
The timeout is now 120 seconds, which should be enough. If you still see timeouts, check server logs.

**Run server manually** (recommended for development):
```bash
# Terminal 1: Start server manually
cd /path/to/Brickshare
npm run dev

# Terminal 2: Run tests
cd apps/web
npx playwright test
```

With `reuseExistingServer: true`, Playwright will use your running server instead of starting a new one.

**Check server startup**:
```bash
# Test if server can start
cd /path/to/Brickshare
npm run dev
# Watch for any errors
```

---

### 4. "Cannot connect to Supabase"

**Problem**: Supabase is not running or wrong URL in config.

**Solution**:
```bash
# Check Supabase status
supabase status

# If not running, start it
supabase start

# Verify connection
curl http://127.0.0.1:54321/rest/v1/
```

---

### 4. "Test timeout" or "Page.goto: Timeout"

**Problem**: Development server not running or slow to start.

**Solution**:
1. Start dev server manually in another terminal:
   ```bash
   npm run dev
   ```
2. Verify it's running: `curl http://localhost:5173`
3. Increase timeout in `playwright.config.ts` if needed:
   ```ts
   timeout: 60000, // 60 seconds
   ```

---

### 5. "Database not clean" or "Test data conflicts"

**Problem**: Previous test data interfering with current tests.

**Solution**:
```bash
# Reset database to clean state
cd ../..
./scripts/safe-db-reset.sh

# Or use Supabase reset (more aggressive)
supabase db reset
```

---

### 6. "Permission denied" errors

**Problem**: Using anon key instead of service role key for admin operations.

**Solution**: Verify your `.env.local` has both keys:
- `VITE_SUPABASE_ANON_KEY` - For client-side auth
- `SUPABASE_SERVICE_ROLE_KEY` - For test database operations

The service role key bypasses RLS policies and is required for test setup/teardown.

---

## Running Tests

### Run all tests
```bash
npx playwright test
```

### Run specific test file
```bash
npx playwright test e2e/user-journeys/complete-onboarding.spec.ts
```

### Run tests in UI mode (interactive)
```bash
npx playwright test --ui
```

### Run tests in headed mode (see browser)
```bash
npx playwright test --headed
```

### Debug a specific test
```bash
npx playwright test --debug e2e/user-journeys/complete-onboarding.spec.ts
```

### View last test report
```bash
npx playwright show-report
```

---

## Environment Variables Reference

| Variable | Purpose | Where to get it |
|----------|---------|-----------------|
| `VITE_SUPABASE_URL` | Supabase API URL | `supabase status` |
| `VITE_SUPABASE_ANON_KEY` | Public anon key | `supabase status` |
| `SUPABASE_SERVICE_ROLE_KEY` | Admin service key | `supabase status` |
| `VITE_APP_URL` | App base URL | Usually `http://localhost:5173` |
| `VITE_STRIPE_PUBLISHABLE_KEY` | Stripe test key | Stripe dashboard |

---

## Pre-flight Checklist

Before running E2E tests, ensure:

- [ ] Supabase is running (`supabase status`)
- [ ] `.env.local` exists with all required variables
- [ ] Dev server is running (`npm run dev`)
- [ ] Database has test data (`./scripts/safe-db-reset.sh` if needed)
- [ ] No other tests are running (port conflicts)

---

## Getting Help

If you're still experiencing issues:

1. Check the [main E2E README](./README.md)
2. Review test logs in `playwright-report/`
3. Check Supabase logs: `supabase logs`
4. Verify network requests in browser DevTools (headed mode)
5. Ask in #testing Slack channel

---

## Test Structure

```
e2e/
├── helpers/           # Shared test utilities
│   ├── database.ts    # DB operations (resetDatabase, createTestUser)
│   ├── auth.ts        # Authentication helpers
│   └── assertions.ts  # Custom assertions
├── fixtures/          # Test data and fixtures
│   └── test-data.ts   # Sample data for tests
├── user-journeys/     # User-facing test scenarios
├── admin-journeys/    # Admin panel tests
├── operator-journeys/ # Operator workflow tests
└── error-scenarios/   # Error handling tests