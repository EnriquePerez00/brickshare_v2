-- ============================================================================
-- Script: Verify Brickshare PUDO IDs
-- Description: Check all users with Brickshare PUDO configuration
-- Usage: psql postgresql://postgres:postgres@127.0.0.1:54322/postgres -f scripts/verify-brickshare-pudo-ids.sql
-- ============================================================================

\echo '════════════════════════════════════════════════════════════════════════════'
\echo '  BRICKSHARE PUDO ID VERIFICATION'
\echo '════════════════════════════════════════════════════════════════════════════'
\echo ''

-- ============================================================================
-- 1. Users with Brickshare PUDO type
-- ============================================================================

\echo '📊 Users with pudo_type = brickshare:'
\echo '────────────────────────────────────────────────────────────────────────────'

SELECT 
    u.user_id,
    u.full_name,
    u.email,
    u.pudo_type,
    u.pudo_id,
    u.subscription_status,
    u.subscription_plan
FROM users u
WHERE u.pudo_type = 'brickshare'
ORDER BY u.full_name;

\echo ''

-- ============================================================================
-- 2. Brickshare dropping table details
-- ============================================================================

\echo '🏢 Brickshare Dropping Records:'
\echo '────────────────────────────────────────────────────────────────────────────'

SELECT 
    ubd.user_id,
    u.full_name,
    ubd.brickshare_pudo_id,
    ubd.location_name,
    ubd.address,
    ubd.city,
    ubd.postal_code,
    ubd.selection_date
FROM users_brickshare_dropping ubd
JOIN users u ON ubd.user_id = u.user_id
ORDER BY u.full_name;

\echo ''

-- ============================================================================
-- 3. Summary statistics
-- ============================================================================

\echo '📈 Summary Statistics:'
\echo '────────────────────────────────────────────────────────────────────────────'

SELECT 
    'Total users with Brickshare PUDO' AS metric,
    COUNT(*) AS count
FROM users
WHERE pudo_type = 'brickshare'

UNION ALL

SELECT 
    'Users with pudo_id = brickshare-001' AS metric,
    COUNT(*) AS count
FROM users
WHERE pudo_type = 'brickshare' AND pudo_id = 'brickshare-001'

UNION ALL

SELECT 
    'Users with incorrect/NULL pudo_id' AS metric,
    COUNT(*) AS count
FROM users
WHERE pudo_type = 'brickshare' AND (pudo_id IS NULL OR pudo_id != 'brickshare-001')

UNION ALL

SELECT 
    'Brickshare dropping records' AS metric,
    COUNT(*) AS count
FROM users_brickshare_dropping

UNION ALL

SELECT 
    'Records with brickshare-001 ID' AS metric,
    COUNT(*) AS count
FROM users_brickshare_dropping
WHERE brickshare_pudo_id = 'brickshare-001';

\echo ''

-- ============================================================================
-- 4. Check for inconsistencies
-- ============================================================================

\echo '⚠️  Potential Issues:'
\echo '────────────────────────────────────────────────────────────────────────────'

-- Users with brickshare type but no dropping record
SELECT 
    '❌ Users with pudo_type=brickshare but no dropping record' AS issue,
    COUNT(*) AS count
FROM users u
WHERE u.pudo_type = 'brickshare'
  AND NOT EXISTS (
    SELECT 1 FROM users_brickshare_dropping ubd 
    WHERE ubd.user_id = u.user_id
  )

UNION ALL

-- Dropping records without user
SELECT 
    '❌ Dropping records without matching user' AS issue,
    COUNT(*) AS count
FROM users_brickshare_dropping ubd
WHERE NOT EXISTS (
    SELECT 1 FROM users u 
    WHERE u.user_id = ubd.user_id AND u.pudo_type = 'brickshare'
  )

UNION ALL

-- Mismatched pudo_id between tables
SELECT 
    '❌ Mismatched pudo_id between users and dropping tables' AS issue,
    COUNT(*) AS count
FROM users u
JOIN users_brickshare_dropping ubd ON u.user_id = ubd.user_id
WHERE u.pudo_type = 'brickshare'
  AND u.pudo_id != ubd.brickshare_pudo_id;

\echo ''
\echo '════════════════════════════════════════════════════════════════════════════'
\echo '  END OF VERIFICATION'
\echo '════════════════════════════════════════════════════════════════════════════'