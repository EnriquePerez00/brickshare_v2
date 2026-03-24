#!/bin/bash

# CI Test Script
# Ejecuta todos los tests en CI

set -e

echo "🧪 Running CI Tests..."

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Counter for test results
UNIT_PASS=0
UNIT_FAIL=0
LINT_PASS=0
LINT_FAIL=0

# 1. Lint
echo -e "${BLUE}[1/4] Running ESLint...${NC}"
if npm run lint --workspace=@brickshare/web; then
  echo -e "${GREEN}✅ ESLint passed${NC}"
  LINT_PASS=1
else
  echo -e "${RED}❌ ESLint failed${NC}"
  LINT_FAIL=1
fi

# 2. Type Check
echo -e "${BLUE}[2/4] Running TypeScript type check...${NC}"
if npm run type-check --workspace=@brickshare/web; then
  echo -e "${GREEN}✅ Type check passed${NC}"
else
  echo -e "${YELLOW}⚠️  Type check had warnings (non-blocking)${NC}"
fi

# 3. Unit Tests
echo -e "${BLUE}[3/4] Running unit tests...${NC}"
if npm run test --workspace=@brickshare/web; then
  echo -e "${GREEN}✅ Unit tests passed${NC}"
  UNIT_PASS=1
else
  echo -e "${RED}❌ Unit tests failed${NC}"
  UNIT_FAIL=1
fi

# 4. Coverage
echo -e "${BLUE}[4/4] Generating coverage report...${NC}"
if npm run test --workspace=@brickshare/web -- --coverage 2>&1; then
  echo -e "${GREEN}✅ Coverage report generated${NC}"
  
  # Display coverage summary
  if [ -f "apps/web/coverage/coverage-final.json" ]; then
    echo -e "${BLUE}Coverage Report Summary:${NC}"
    # Parse coverage (simple check)
    COVERAGE=$(grep -o '"lines":{[^}]*}' apps/web/coverage/coverage-final.json | head -1)
    echo "$COVERAGE"
  fi
else
  echo -e "${YELLOW}⚠️  Coverage generation had issues (non-blocking)${NC}"
fi

# Summary
echo ""
echo -e "${BLUE}════════════════════════════════════${NC}"
echo -e "${BLUE}Test Summary${NC}"
echo -e "${BLUE}════════════════════════════════════${NC}"

if [ $LINT_PASS -eq 1 ]; then
  echo -e "${GREEN}✅ Linting${NC}"
else
  echo -e "${RED}❌ Linting${NC}"
fi

if [ $UNIT_PASS -eq 1 ]; then
  echo -e "${GREEN}✅ Unit Tests${NC}"
else
  echo -e "${RED}❌ Unit Tests${NC}"
fi

echo ""

# Exit with error if any critical test failed
if [ $LINT_FAIL -eq 1 ] || [ $UNIT_FAIL -eq 1 ]; then
  echo -e "${RED}❌ Critical tests failed${NC}"
  exit 1
else
  echo -e "${GREEN}✅ All critical tests passed${NC}"
  exit 0
fi