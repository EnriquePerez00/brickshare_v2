#!/bin/bash

# ═══════════════════════════════════════════════════════════════
# Run E2E Tests - Helper Script
# ═══════════════════════════════════════════════════════════════
# Este script facilita la ejecución de tests E2E con la configuración
# correcta.
# ═══════════════════════════════════════════════════════════════

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "🧪 Brickshare E2E Test Runner"
echo ""

# Check if Supabase is running
if ! supabase status &> /dev/null; then
    echo -e "${RED}❌ Supabase is not running${NC}"
    echo "Starting Supabase..."
    cd ../.. && supabase start
    cd apps/web
fi

# Verify Supabase URL and port
SUPABASE_URL=$(supabase status | grep "API URL" | awk '{print $3}')
echo -e "${GREEN}✅ Supabase running at: ${SUPABASE_URL}${NC}"

# Check if dev server is running
if ! lsof -i :8080 &> /dev/null; then
    echo -e "${YELLOW}⚠️  Dev server not running on port 8080${NC}"
    echo "Please start it in another terminal with: npm run dev"
    echo ""
    read -p "Press Enter when dev server is ready..."
fi

# Display test options
echo ""
echo "Select test type:"
echo "1) Smoke tests only (fast, ~10s)"
echo "2) All E2E tests (slow, several minutes)"
echo "3) Smoke tests with UI"
echo "4) Specific test file"
echo ""
read -p "Enter choice [1-4]: " choice

case $choice in
    1)
        echo -e "${GREEN}Running smoke tests...${NC}"
        npx playwright test basic-smoke.spec.ts --project=chromium --reporter=list
        ;;
    2)
        echo -e "${GREEN}Running all E2E tests...${NC}"
        npx playwright test --project=chromium --reporter=list
        ;;
    3)
        echo -e "${GREEN}Running smoke tests with UI...${NC}"
        npx playwright test basic-smoke.spec.ts --project=chromium --ui
        ;;
    4)
        echo ""
        echo "Available test files:"
        find e2e -name "*.spec.ts" -type f | sed 's|e2e/||'
        echo ""
        read -p "Enter test file path (e.g., user-journeys/complete-onboarding.spec.ts): " testfile
        echo -e "${GREEN}Running ${testfile}...${NC}"
        npx playwright test "$testfile" --project=chromium --reporter=list
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}✅ Tests completed!${NC}"
echo ""
echo "View HTML report with: npx playwright show-report"