# Playwright WebServer Configuration

## Problem Solved

The Playwright tests were failing with:
```
Error: Timed out waiting 60000ms from config.webServer.
```

## Root Cause

The issue occurred because:

1. **Project structure**: The main `vite.config.ts` is at the **root** of the monorepo, not in `apps/web/`
2. **Working directory**: Playwright runs from `apps/web/`, but `npm run dev` needs to run from the **root**
3. **Command mismatch**: The webServer command was trying to run `npm run dev` from the wrong directory

## Solution Implemented

### 1. Created Helper Script

`apps/web/start-dev-server.sh`:
```bash
#!/bin/bash
# Navigate to project root and start dev server
cd "$(dirname "$0")/../.."
exec npm run dev
```

This script:
- Automatically finds the project root (2 levels up from `apps/web/`)
- Executes `npm run dev` from the correct directory
- Uses `exec` to replace the shell process (cleaner shutdown)

### 2. Updated playwright.config.ts

```typescript
webServer: {
  command: './start-dev-server.sh',
  url: 'http://localhost:5173',
  reuseExistingServer: !process.env.CI,
  timeout: 120000, // 2 minutes (increased from 60s)
  stdout: 'pipe',
  stderr: 'pipe',
}
```

Key improvements:
- **command**: Uses the helper script to start from correct directory
- **reuseExistingServer**: Set to `true` in development (not CI) to reuse running servers
- **timeout**: Increased to 120 seconds for slower machines
- **stdout/stderr**: Piped to show server logs in case of errors

## Usage

### Option 1: Let Playwright Manage the Server (Automatic)

Simply run tests and Playwright will start/stop the server automatically:

```bash
cd apps/web
npx playwright test
```

### Option 2: Manual Server Management (Recommended for Development)

Keep the server running in a separate terminal for faster test iterations:

```bash
# Terminal 1: Start and keep server running
cd /path/to/Brickshare
npm run dev

# Terminal 2: Run tests as many times as you want
cd apps/web
npx playwright test
```

With `reuseExistingServer: true`, Playwright will detect your running server and won't try to start a new one.

## Troubleshooting

### Server won't start

```bash
# Check if port is in use
lsof -ti:5173

# Kill process if needed
kill -9 $(lsof -ti:5173)

# Try starting manually to see errors
npm run dev
```

### Tests still timeout

1. Check if Supabase is running: `supabase status`
2. Verify `.env.local` has correct variables
3. Increase timeout in `playwright.config.ts` if your machine is slow
4. Check server logs for errors

### Script permission errors

```bash
chmod +x apps/web/start-dev-server.sh
```

## CI/CD Considerations

In CI environments:
- `reuseExistingServer` is set to `false` (starts fresh server)
- Timeout of 120s allows for slower CI runners
- Server is automatically cleaned up after tests

## File Structure

```
Brickshare/
├── vite.config.ts           # Main Vite config (at root)
├── package.json              # Has "dev" script
├── apps/
│   └── web/
│       ├── playwright.config.ts      # Playwright config
│       ├── start-dev-server.sh       # Helper script (NEW)
│       └── e2e/
│           ├── README.md
│           ├── TROUBLESHOOTING.md
│           └── WEBSERVER_SETUP.md    # This file
```

## Port Configuration

The project is configured to use **port 8080** by default (changed from Vite's default 5173).

### Changing the Port

If you need to use a different port, update these locations:

**1. `playwright.config.ts`:**
```typescript
baseURL: 'http://localhost:YOUR_PORT',
// and
webServer: {
  url: 'http://localhost:YOUR_PORT',
}
```

**2. Or use environment variable:**
```bash
# In .env.local
BASE_URL=http://localhost:YOUR_PORT
```

### Verify Server Port

```bash
# Check what port your server is using
lsof -ti:8080  # Should show a process if running on 8080
curl http://localhost:8080  # Should return your app
```

## Best Practices

1. **Development**: Keep server running manually for faster test iterations
2. **CI/CD**: Let Playwright manage the server lifecycle
3. **Debugging**: Use `--headed` mode to see what the test is doing
4. **Logs**: Check server output if tests fail unexpectedly
5. **Port consistency**: Ensure your dev server and Playwright use the same port
