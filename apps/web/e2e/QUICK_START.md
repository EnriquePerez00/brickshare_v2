# E2E Tests Quick Start Guide

## 🚀 First Time Setup (One-time)

```bash
cd apps/web

# 1. Setup environment variables
./e2e/setup-e2e-env.sh

# 2. Verify everything is ready
./e2e/verify-setup.sh
```

## 📋 Daily Workflow

### Option A: Let Playwright Handle Everything (Simple)

```bash
npx playwright test
```

Playwright will:
- Start the dev server automatically on port 8080
- Run all tests
- Generate HTML report

### Option B: Manual Server (Faster for development)

```bash
# Terminal 1: Start server (keep it running)
cd /path/to/Brickshare
npm run dev

# Terminal 2: Run tests (run as many times as you want)
cd apps/web
npx playwright test
```

Benefits: Faster test iterations, easier debugging

## 🎯 Common Commands

```bash
# Interactive UI mode (recommended for development)
npx playwright test --ui

# See browser while testing
npx playwright test --headed

# Run specific test
npx playwright test e2e/user-journeys/complete-onboarding.spec.ts

# Debug mode (step by step)
npx playwright test --debug

# List format (see progress)
npx playwright test --reporter=list

# View last test report
npx playwright show-report
```

## 🔍 Running Specific Test Suites

```bash
# User journeys
npx playwright test e2e/user-journeys/

# Admin flows
npx playwright test e2e/admin-journeys/

# Operator operations
npx playwright test e2e/operator-journeys/

# Error scenarios
npx playwright test e2e/error-scenarios/
```

## ⚙️ Configuration

- **Port**: 8080 (configured in `playwright.config.ts`)
- **Base URL**: http://localhost:8080
- **Timeout**: 120 seconds for server startup
- **Parallel**: Disabled (sequential execution)

## 🐛 Quick Troubleshooting

### Server won't start
```bash
# Check if port is in use
lsof -ti:8080

# Kill process if needed
kill -9 $(lsof -ti:8080)
```

### Tests failing unexpectedly
```bash
# Run verification
./e2e/verify-setup.sh

# Check Supabase
supabase status

# Reset database if needed
cd ../..
./scripts/safe-db-reset.sh
```

### UI mode stuck on "Loading..."
Make sure server is running on port 8080:
```bash
curl http://localhost:8080
# Should return HTML
```

## 📚 More Information

- [Complete Setup Guide](./README.md)
- [Troubleshooting Guide](./TROUBLESHOOTING.md)
- [WebServer Configuration](./WEBSERVER_SETUP.md)

## 🎓 Tips

1. **Use UI mode for debugging**: `--ui` gives you visual feedback and time travel
2. **Keep server running**: Faster test iterations during development
3. **Check verification script**: Run `./e2e/verify-setup.sh` when in doubt
4. **Watch test execution**: Use `--headed` to see what the test is doing
5. **Filter tests**: Use test file patterns to run specific suites

## ✅ Pre-flight Checklist

Before running tests:
- [ ] Supabase running (`supabase status`)
- [ ] `.env.local` configured (`./e2e/setup-e2e-env.sh`)
- [ ] Dev server on port 8080 (or let Playwright start it)
- [ ] No port conflicts (`lsof -ti:8080`)

Happy testing! 🧪