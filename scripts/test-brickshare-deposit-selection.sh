#!/bin/bash

# Test script to verify Brickshare deposit selection flow
# This script tests the complete PUDO selection for a Brickshare deposit

echo "🧪 Testing Brickshare Deposit Selection Flow"
echo "=============================================="
echo ""

# Check if local Supabase is running
if ! curl -s http://127.0.0.1:54321/rest/v1/ > /dev/null 2>&1; then
    echo "❌ Supabase local is not running!"
    echo "   Run: supabase start"
    exit 1
fi

echo "✅ Supabase is running"
echo ""

# Check if there are any Brickshare PUDO locations
echo "📍 Checking Brickshare PUDO locations in database..."
PUDO_COUNT=$(psql "postgresql://postgres:postgres@127.0.0.1:54322/postgres" -t -c "SELECT COUNT(*) FROM brickshare_pudo_locations WHERE is_active = true;")
echo "   Found $PUDO_COUNT active Brickshare PUDO locations"
echo ""

if [ "$PUDO_COUNT" -eq 0 ]; then
    echo "⚠️  No active Brickshare PUDO locations found"
    echo "   You may need to seed the database or the /api/locations-local endpoint should provide them"
fi

# Check migration status
echo "🔍 Checking latest migration..."
LATEST_MIGRATION=$(psql "postgresql://postgres:postgres@127.0.0.1:54322/postgres" -t -c "SELECT version FROM supabase_migrations.schema_migrations ORDER BY version DESC LIMIT 1;")
echo "   Latest migration: $LATEST_MIGRATION"
echo ""

# Test query to simulate what happens when saving a Brickshare PUDO
echo "🧪 Testing Brickshare PUDO save simulation..."
echo ""
echo "   This would INSERT into users_brickshare_dropping with:"
echo "   - brickshare_pudo_id: 'test-deposit-id'"
echo "   - location_name: 'Test Brickshare Deposit'"
echo "   - address: 'Calle Test 123'"
echo "   - city: 'Madrid'"
echo "   - postal_code: '28001'"
echo "   - province: 'Madrid'"
echo ""

# Show table structure
echo "📋 Current users_brickshare_dropping table structure:"
psql "postgresql://postgres:postgres@127.0.0.1:54322/postgres" -c "\d users_brickshare_dropping"
echo ""

echo "✅ Test preparation complete"
echo ""
echo "Next steps:"
echo "1. Start the dev server: npm run dev"
echo "2. Login as a test user"
echo "3. Go to Dashboard"
echo "4. Click 'Seleccionar punto' for PUDO"
echo "5. Select a Brickshare deposit (green marker)"
echo "6. Click 'Confirmar Selección'"
echo "7. Check the console logs for any errors"