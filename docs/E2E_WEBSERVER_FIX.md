# E2E WebServer Timeout Fix - Resolution Summary

**Date**: 2026-03-26  
**Issue**: `Error: Timed out waiting 60000ms from config.webServer`

## Problem

Playwright E2E tests were failing because the development server couldn't start:

```
Error: Timed out waiting 60000ms from config.webServer.
```

## Root Cause Analysis

The Brickshare project has a **monorepo structure** where:
- Main `vite.config.ts` is at the **project root**
- `package.json` with `"dev"` script is at the **project root**  
- Playwright config is in `apps/web/`
- Tests run from `apps/web/` directory

The webServer command was executing `npm run dev` from `apps/web/`, but needed to run from the project root.

## Solution Implemented

### 1. Created Helper Script

**File**: `apps/web/start-dev-server.sh`

```bash
#!/bin/bash
# Navigate to project root and start dev server
cd "$(dirname "$0")/../.."
exec npm run dev
```

This script:
- Automatically resolves the project root (2 levels up)
- Executes `npm run dev` from correct location
- Uses `exec` for clean process management

### 2. Updated Playwright Configuration

**File**: `apps/web/playwright.config.ts`

```typescript
webServer: {
  command: './start-dev-server.sh',          // ✅ Use helper script
  url: 'http://localhost:5173',
  reuseExistingServer: !process.env.CI,     // ✅ Reuse in dev, fresh in CI
  timeout: 120000,                           // ✅ Increased to 2 minutes
  stdout: 'pipe',                            // ✅ Show server logs
  stderr: 'pipe',
}
```

Changes made:
- **command**: Changed from `npm run dev` to `./start-dev-server.sh`
- **reuseExistingServer**: Smart detection (dev vs CI)
- **timeout**: Doubled to 120 seconds for slower machines
- **stdout/stderr**: Added for better debugging

### 3. Documentation Updates

Created comprehensive guides:
- `apps/web/e2e/WEBSERVER_SETUP.md` - Detailed setup and troubleshooting
- Updated `apps/web/e2e/TROUBLESHOOTING.md` - Added webServer timeout section

## Usage Patterns

### For Development (Recommended)

```bash
# Terminal 1: Keep server running
npm run dev

# Terminal 2: Run tests repeatedly
cd apps/web
npx playwright test
```

Benefits:
- Faster test iterations (no server restart)
- See server logs in separate terminal
- Easy to restart server if needed

### For CI/CD (Automatic)

```bash
cd apps/web
npx playwright test
```

Playwright automatically:
- Starts fresh dev server
- Waits for it to be ready
- Runs all tests
- Shuts down server cleanly

## Files Modified

1. ✅ `apps/web/playwright.config.ts` - Updated webServer configuration
2. ✅ `apps/web/start-dev-server.sh` - New helper script (executable)
3. ✅ `apps/web/e2e/WEBSERVER_SETUP.md` - New comprehensive guide
4. ✅ `apps/web/e2e/TROUBLESHOOTING.md` - Added timeout troubleshooting
5. ✅ `docs/E2E_WEBSERVER_FIX.md` - This resolution summary

## Port Configuration Update

The project uses **port 8080** for the development server (not Vite's default 5173).

**Updated configuration in `playwright.config.ts`:**
```typescript
baseURL: 'http://localhost:8080',  // Changed from 5173
webServer: {
  url: 'http://localhost:8080',    // Changed from 5173
}
```

This can be overridden with the `BASE_URL` environment variable if needed.

## Verification

After implementing the fix:

```bash
cd apps/web
npx playwright test
```

Results:
- ✅ Server starts correctly from project root
- ✅ Tests can connect to http://localhost:8080
- ✅ No more timeout errors
- ✅ Tests execute successfully

## Key Learnings

1. **Monorepo awareness**: Always consider working directory when running commands
2. **Helper scripts**: Useful for complex multi-step commands
3. **Timeout tuning**: Default 60s may not be enough for all machines
4. **Dev workflow**: Reusing running servers speeds up development
5. **Clear documentation**: Essential for team understanding

## Common Issues & Solutions

### "Port 5173 already in use"
```bash
lsof -ti:5173 | xargs kill -9
```

### "Permission denied" on script
```bash
chmod +x apps/web/start-dev-server.sh
```

### "Cannot find module" in dev server
```bash
# Install dependencies
npm install
```

### Tests still timeout
1. Check Supabase is running: `supabase status`
2. Verify `.env.local` exists with correct variables
3. Manually test: `npm run dev` (should start without errors)
4. Check console for error messages

## Next Steps

1. ✅ WebServer configuration fixed and tested
2. ✅ Documentation created
3. 📋 Consider adding health check endpoint
4. 📋 Add webServer monitoring to CI logs
5. 📋 Document in team onboarding guide

## References

- [Playwright webServer docs](https://playwright.dev/docs/test-webserver)
- [Project Structure](../../../docs/ARCHITECTURE.md)
- [E2E Testing Guide](./e2e/README.md)
- [Troubleshooting](./e2e/TROUBLESHOOTING.md)