 el seed#!/bin/bash
# Wrapper script for 'supabase db reset' that triggers pre-reset hook
# Usage: ./scripts/db-reset.sh [supabase db reset options]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   🔄 Brickshare Database Reset (with backup)     ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════╝${NC}"
echo ""

# Check if git hook exists
if [ ! -f ".git/hooks/pre-db-reset" ]; then
    echo -e "${RED}⚠️  Pre-reset hook not found. Installing...${NC}"
    ./scripts/install-hooks.sh
fi

# Execute the pre-reset hook
if [ -x ".git/hooks/pre-db-reset" ]; then
    .git/hooks/pre-db-reset
else
    echo -e "${YELLOW}⚠️  Pre-reset hook is not executable. Skipping backup.${NC}"
fi

# Execute the actual supabase db reset command
echo -e "${BLUE}🚀 Executing: supabase db reset $@${NC}"
echo ""
supabase db reset "$@"

# Post-reset actions
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✅ Database reset completed successfully!       ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}💡 Database restored from:${NC}"
echo -e "   📄 supabase/seed.sql (official seed data)"
echo -e "   📁 supabase/migrations/*.sql (schema)"
echo ""
echo -e "${BLUE}💾 Backup saved at:${NC}"
echo -e "   📁 supabase/backups/pre_reset_*.sql (timestamped)"
echo ""
