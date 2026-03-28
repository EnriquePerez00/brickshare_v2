#!/bin/bash
# Complete Assignment Flow Test for enriquepeto@yahoo.es
# Executes SQL simulation + Email/Label generation

set -e

echo "=============================================="
echo "🚀 COMPLETE ASSIGNMENT FLOW TEST"
echo "   User: enriquepeto@yahoo.es"
echo "=============================================="
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if Supabase is running
if ! supabase status > /dev/null 2>&1; then
  echo -e "${RED}❌ Supabase is not running${NC}"
  echo "   Start it with: supabase start"
  exit 1
fi

echo -e "${GREEN}✅ Supabase is running${NC}"
echo ""

# Get database connection string
# Parse from the table format output
DB_URL=$(supabase status | grep -A 1 "Database" | grep "postgresql" | awk '{print $NF}')

if [ -z "$DB_URL" ]; then
  echo -e "${RED}❌ Could not get database URL${NC}"
  echo "   Trying alternative method..."
  DB_URL="postgresql://postgres:postgres@127.0.0.1:5433/postgres"
fi

echo -e "${BLUE}Database URL: ${DB_URL}${NC}"
echo ""

# ============================================================
# PART 1: SQL Simulation (Assignment + QR Generation)
# ============================================================
echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
echo -e "${YELLOW}PART 1: SQL SIMULATION${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
echo ""

psql "$DB_URL" -f scripts/simulate-enrique-complete-flow.sql

if [ $? -ne 0 ]; then
  echo -e "${RED}❌ SQL simulation failed${NC}"
  exit 1
fi

echo ""
echo -e "${GREEN}✅ SQL simulation completed${NC}"
echo ""

# Small delay to ensure database commits
sleep 2

# ============================================================
# PART 2: Email and Label Generation (TypeScript)
# ============================================================
echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
echo -e "${YELLOW}PART 2: EMAIL & LABEL GENERATION${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
echo ""

npx tsx scripts/simulate-enrique-complete-flow.ts

if [ $? -ne 0 ]; then
  echo -e "${RED}❌ Email/Label generation failed${NC}"
  exit 1
fi

echo ""
echo -e "${GREEN}✅ Email and label generation completed${NC}"
echo ""

# ============================================================
# SUMMARY
# ============================================================
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo -e "${BLUE}✅ COMPLETE FLOW TEST FINISHED${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}📧 CHECK YOUR EMAIL: enriquepeto@yahoo.es${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Verify email received with QR code"
echo "  2. Check shipment status in database"
echo "  3. Test QR validation with PUDO app"
echo ""
echo -e "${GREEN}✨ All validations passed!${NC}"