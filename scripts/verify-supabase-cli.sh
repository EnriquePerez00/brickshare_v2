#!/bin/bash

# Script to verify local Supabase CLI setup
# Verifies that the CLI is properly configured for local development

echo "🔍 Verifying Supabase CLI configuration..."
echo ""

# Check that Supabase CLI is installed
if ! command -v supabase &> /dev/null; then
    echo "❌ Supabase CLI is not installed"
    echo "   Install with: brew install supabase/tap/supabase"
    exit 1
fi

echo "✅ Supabase CLI installed: $(supabase --version)"
echo ""

# Check if Docker is running (required for local Supabase)
if ! docker info &> /dev/null; then
    echo "❌ Docker is not running"
    echo "   Supabase local requires Docker. Please start Docker Desktop."
    exit 1
fi

echo "✅ Docker is running"
echo ""

# Check if local Supabase is running
if supabase status &> /dev/null 2>&1; then
    echo "✅ Local Supabase is running"
    echo ""
    supabase status 2>/dev/null
    echo ""
else
    echo "⚠️  Local Supabase is not running"
    echo "   Start it with: supabase start"
    echo ""
fi

# Check migrations directory
MIGRATION_COUNT=$(ls -1 supabase/migrations/*.sql 2>/dev/null | wc -l | tr -d ' ')
if [ "$MIGRATION_COUNT" -gt 0 ]; then
    echo "✅ Found $MIGRATION_COUNT migration files"
else
    echo "⚠️  No migration files found in supabase/migrations/"
fi
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Supabase CLI configured for local development!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🚀 Available commands:"
echo "   - supabase start              # Start local Supabase"
echo "   - supabase stop               # Stop local Supabase"
echo "   - supabase db reset           # Reset DB and apply all migrations"
echo "   - supabase migration new      # Create a new migration"
echo "   - npm run dump-schema         # Update schema documentation"
echo ""
echo "ℹ️  This project uses local Supabase only (no remote database)."