-- Direct shipment creation for testing
-- No error handling, just create everything directly

\echo '🚀 Creating test shipment...'
\echo ''

-- 1. Clean up previous test data
DELETE FROM shipments WHERE user_id IN (SELECT user_id FROM users WHERE email = 'enriquepeto@yahoo.es');
DELETE FROM inventory_sets WHERE set_id IN (SELECT id FROM sets WHERE set_ref = '10698-TEST');
DELETE FROM sets WHERE set_ref = '10698-TEST';

-- 2. Create PUDO
INSERT INTO brickshare_pudo_locations (
  id, name, address, city, postal_code, province,
  latitude, longitude, contact_email, is_active
) VALUES (
  'BRICKSHARE-MADRID-001',
  'Depósito Brickshare Madrid',
  'Calle Depósito Brickshare 1',
  'Madrid', '28001', 'Madrid',
  40.4168, -3.7038,
  'deposito.madrid@brickshare.com',
  true
) ON CONFLICT (id) DO UPDATE SET is_active = true;

\echo '✅ PUDO created'

-- 3. Create set
INSERT INTO sets (
  set_ref, set_name, set_theme, set_age_range,
  set_piece_count, set_price, set_pvp_release,
  set_image_url, set_status
) VALUES (
  '10698-TEST',
  'Caja de Ladrillos Creativos Grande (TEST)',
  'Classic', '4-99',
  790, 15.00, 49.99,
  'https://images.brickset.com/sets/images/10698-1.jpg',
  'active'
);

\echo '✅ Set created'

-- 4. Create inventory
INSERT INTO inventory_sets (
  set_id, inventory_set_total_qty, in_shipping, in_use, in_return, in_repair
)
SELECT id, 5, 0, 0, 0, 0
FROM sets WHERE set_ref = '10698-TEST';

\echo '✅ Inventory created'

-- 5. Update user
UPDATE users SET
  user_status = 'no_set',
  subscription_status = 'active',
  subscription_type = 'brick_master',
  pudo_type = 'brickshare',
  pudo_id = 'BRICKSHARE-MADRID-001',
  stripe_payment_method_id = COALESCE(stripe_payment_method_id, 'pm_card_visa'),
  profile_completed = true
WHERE email = 'enriquepeto@yahoo.es';

\echo '✅ User configured'

-- 6. Create shipment
INSERT INTO shipments (
  user_id, set_id, set_ref,
  shipment_status, pudo_type, brickshare_pudo_id,
  shipping_address, shipping_city, shipping_zip_code,
  shipping_province, shipping_country,
  delivery_qr_code, delivery_qr_expires_at,
  assigned_date
)
SELECT
  u.user_id,
  s.id,
  s.set_ref,
  'assigned',
  'brickshare',
  'BRICKSHARE-MADRID-001',
  bp.address,
  bp.city,
  bp.postal_code,
  bp.province,
  'ES',
  'BS-' || UPPER(SUBSTRING(gen_random_uuid()::text, 1, 8)),
  NOW() + INTERVAL '30 days',
  NOW()
FROM users u
CROSS JOIN sets s
CROSS JOIN brickshare_pudo_locations bp
WHERE u.email = 'enriquepeto@yahoo.es'
  AND s.set_ref = '10698-TEST'
  AND bp.id = 'BRICKSHARE-MADRID-001';

\echo '✅ Shipment created'

-- 7. Update inventory
UPDATE inventory_sets SET
  in_shipping = 1,
  inventory_set_total_qty = 4
WHERE set_id IN (SELECT id FROM sets WHERE set_ref = '10698-TEST');

-- 8. Update user status
UPDATE users SET
  user_status = 'assigned_set'
WHERE email = 'enriquepeto@yahoo.es';

\echo ''
\echo '════════════════════════════════════════════'
\echo '✅ TEST SHIPMENT CREATED'
\echo '════════════════════════════════════════════'
\echo ''

-- Show result
SELECT
  s.id as shipment_id,
  s.shipment_status,
  s.set_ref,
  s.delivery_qr_code as qr_code,
  TO_CHAR(s.delivery_qr_expires_at, 'YYYY-MM-DD') as qr_expires,
  s.shipping_address,
  s.shipping_city,
  u.email,
  st.set_name
FROM shipments s
JOIN users u ON s.user_id = u.user_id
JOIN sets st ON s.set_id = st.id
WHERE u.email = 'enriquepeto@yahoo.es'
ORDER BY s.created_at DESC
LIMIT 1;

\echo ''
\echo '📧 Next: Run email script'
\echo '   npx tsx scripts/simulate-brickshare-assignment.ts'
\echo ''