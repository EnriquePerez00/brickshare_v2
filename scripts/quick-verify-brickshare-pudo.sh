#!/bin/bash

# ============================================================================
# Script: Quick Verify Brickshare PUDO IDs
# Description: Quick verification of Brickshare PUDO configuration
# Usage: ./scripts/quick-verify-brickshare-pudo.sh
# ============================================================================

echo "════════════════════════════════════════════════════════════════"
echo "  🔍 QUICK BRICKSHARE PUDO VERIFICATION"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Check if Supabase is running
if ! curl -s http://127.0.0.1:54321/health > /dev/null 2>&1; then
    echo "❌ Supabase no está ejecutándose"
    echo "   Ejecuta: supabase start"
    exit 1
fi

echo "✅ Supabase está activo"
echo ""

# Connect to database and run quick checks
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres -t -c "
SELECT '📊 USUARIOS CON BRICKSHARE PUDO:' AS info;
SELECT '────────────────────────────────────' AS separator;
SELECT 
    COUNT(*) || ' usuarios' AS total
FROM users 
WHERE pudo_type = 'brickshare';

SELECT '' AS blank;
SELECT '✅ USUARIOS CON pudo_id = brickshare-001:' AS info;
SELECT 
    COUNT(*) || ' usuarios' AS total
FROM users 
WHERE pudo_type = 'brickshare' 
  AND pudo_id = 'brickshare-001';

SELECT '' AS blank;
SELECT '❌ USUARIOS CON pudo_id INCORRECTO:' AS info;
SELECT 
    COUNT(*) || ' usuarios' AS total
FROM users 
WHERE pudo_type = 'brickshare' 
  AND (pudo_id IS NULL OR pudo_id != 'brickshare-001');

SELECT '' AS blank;
SELECT '🏢 REGISTROS EN users_brickshare_dropping:' AS info;
SELECT 
    COUNT(*) || ' registros' AS total
FROM users_brickshare_dropping;

SELECT '' AS blank;
SELECT '✅ CON brickshare_pudo_id = brickshare-001:' AS info;
SELECT 
    COUNT(*) || ' registros' AS total
FROM users_brickshare_dropping
WHERE brickshare_pudo_id = 'brickshare-001';
"

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  Para ver detalles completos ejecuta:"
echo "  psql postgresql://postgres:postgres@127.0.0.1:54322/postgres \\"
echo "       -f scripts/verify-brickshare-pudo-ids.sql"
echo "════════════════════════════════════════════════════════════════"