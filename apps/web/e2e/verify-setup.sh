#!/bin/bash

# ═══════════════════════════════════════════════════════════════
# E2E Setup Verification Script
# ═══════════════════════════════════════════════════════════════
# Verifies that the E2E test environment is properly configured
# ═══════════════════════════════════════════════════════════════

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}E2E Test Environment Verification${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Check 1: Supabase running
echo -n "Checking Supabase... "
if supabase status &> /dev/null; then
    echo -e "${GREEN}✅ Running${NC}"
else
    echo -e "${RED}❌ Not running${NC}"
    echo "  Fix: Run 'supabase start' from project root"
    exit 1
fi

# Check 2: .env.local exists
echo -n "Checking .env.local... "
if [ -f ".env.local" ]; then
    echo -e "${GREEN}✅ Exists${NC}"
    
    # Check for required variables
    if grep -q "SUPABASE_SERVICE_ROLE_KEY" .env.local; then
        echo -e "  ${GREEN}✓${NC} SUPABASE_SERVICE_ROLE_KEY found"
    else
        echo -e "  ${RED}✗${NC} SUPABASE_SERVICE_ROLE_KEY missing"
        echo "  Fix: Run './e2e/setup-e2e-env.sh'"
    fi
else
    echo -e "${RED}❌ Not found${NC}"
    echo "  Fix: Run './e2e/setup-e2e-env.sh'"
    exit 1
fi

# Check 3: Dev server port
echo -n "Checking dev server on port 8080... "
if lsof -ti:8080 &> /dev/null; then
    echo -e "${GREEN}✅ Server running${NC}"
    
    # Try to connect
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 | grep -q "200"; then
        echo -e "  ${GREEN}✓${NC} Server responding (HTTP 200)"
    else
        echo -e "  ${YELLOW}⚠${NC}  Server running but not responding correctly"
    fi
else
    echo -e "${YELLOW}⚠${NC}  No server running on port 8080"
    echo "  Note: Playwright will start it automatically, or you can start it manually:"
    echo "  Terminal 1: npm run dev"
    echo "  Terminal 2: npx playwright test"
fi

# Check 4: Playwright installed
echo -n "Checking Playwright... "
if command -v npx &> /dev/null && npx playwright --version &> /dev/null; then
    VERSION=$(npx playwright --version)
    echo -e "${GREEN}✅ Installed${NC} ($VERSION)"
else
    echo -e "${RED}❌ Not found${NC}"
    echo "  Fix: npm install"
    exit 1
fi

# Check 5: Helper script
echo -n "Checking start-dev-server.sh... "
if [ -f "start-dev-server.sh" ] && [ -x "start-dev-server.sh" ]; then
    echo -e "${GREEN}✅ Ready${NC}"
else
    echo -e "${YELLOW}⚠${NC}  Script missing or not executable"
    echo "  Fix: chmod +x start-dev-server.sh"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Environment verification complete!${NC}"
echo ""
echo "Ready to run E2E tests:"
echo "  ${BLUE}npx playwright test${NC}          - Run all tests"
echo "  ${BLUE}npx playwright test --ui${NC}     - Interactive UI mode"
echo "  ${BLUE}npx playwright test --headed${NC} - See browser"
echo ""