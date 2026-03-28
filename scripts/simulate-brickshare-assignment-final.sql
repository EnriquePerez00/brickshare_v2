-- =====================================================
-- Simulate Brickshare PUDO Assignment - FINAL VERSION
-- Target: enriquepeto@yahoo.es
-- =====================================================

\echo '=============================================='
\echo '🚀 BRICKSHARE ASSIGNMENT SIMULATION (FINAL)'
\echo '=============================================='
\echo ''

-- Step 1: Create Brickshare PUDO
\echo '📍 Step 1: Creating Brickshare Deposit...'

INSERT INTO public.brickshare_pudo_locations (
  id,
  name,
  address,
  city,
  postal_code,
  province,
  latitude,
  longitude,
  contact_email,
  contact_phone,
  opening_hours,
  is_active,
  created_at,
  updated_at
) VALUES (
  'de8c8f58-0001-4000-8000-000000000001'::uuid,
  'Depósito Brickshare Madrid',
  'Calle Depósito Brickshare 1',
  'Madrid',
  '28001',
  'Madrid',
  40.4168,
  -3.7038,
  'deposito.madrid@brickshare.com',
  '+34912345678',
  '{"lunes":"9:00-20:00","martes":"9:00-20:00"}'::jsonb,
  true,
  NOW(),
  NOW()
)
ON CONFLICT (id) DO UPDATE SET
  is_active = true,
  updated_at = NOW();

\echo '✅ Brickshare Deposit ready'
\echo ''

-- Step 2: Create test set
\echo '🧱 Step 2: Creating test LEGO set...'

INSERT INTO public.sets (
  id,
  set_ref,
  set_name,
  set_theme,
  set_age_range,
  set_piece_count,
  set_price,
  set_pvp_release,
  set_image_url,
  set_status,
  created_at,
  updated_at
) VALUES (
  'de8c8f58-1001-4000-8000-000000000001'::uuid,
  '10698',
  'Caja de Ladrillos Creativos Grande',
  'Classic',
  '4-99',
  790,
  15.00,
  49.99,
  'https://images.brickset.com/sets/images/10698-1.jpg',
  'available',
  NOW(),
  NOW()
)
ON CONFLICT (set_ref) DO UPDATE SET
  set_status = 'available',
  updated_at = NOW();

\echo '✅ Test set created: 10698 - Caja de Ladrillos Creativos Grande'
\echo ''

-- Step 3: Create inventory
\echo '📦 Step 3: Creating inventory...'

INSERT INTO public.inventory_sets (
  set_id,
  inventory_set_total_qty,
  in_shipping,
  in_use,
  in_return,
  in_repair,
  created_at,
  updated_at
) VALUES (
  'de8c8f58-1001-4000-8000-000000000001'::uuid,
  5,
  0,
  0,
  0,
  0,
  NOW(),
  NOW()
)
ON CONFLICT (set_id) DO UPDATE SET
  inventory_set_total_qty = 5,
  in_shipping = 0,
  in_use = 0,
  in_return = 0,
  in_repair = 0,
  updated_at = NOW();

\echo '✅ Inventory created (5 units available)'
\echo ''

-- Step 4: Configure user and create shipment
\echo '👤 Step 4: Configuring user and creating shipment...'

DO $$
DECLARE
  v_user_id uuid;
  v_set_id uuid;
  v_shipment_id uuid;
  v_qr_code text;
BEGIN
  -- Get user
  SELECT user_id INTO v_user_id
  FROM public.users
  WHERE email = 'enriquepeto@yahoo.es';
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User not found. Run scripts/create-enrique-test-user.sql first';
  END IF;
  
  -- Update user config
  UPDATE public.users SET
    user_status = 'no_set',
    subscription_status = 'active',
    subscription_type = 'brick_master',
    pudo_type = 'brickshare',
    pudo_id = 'de8c8f58-0001-4000-8000-000000000001',
    stripe_payment_method_id = COALESCE(stripe_payment_method_id, 'pm_card_visa'),
    profile_completed = true,
    updated_at = NOW()
  WHERE user_id = v_user_id;
  
  RAISE NOTICE '✅ User configured: %', v_user_id;
  
  -- Use the test set we just created
  v_set_id := 'de8c8f58-1001-4000-8000-000000000001'::uuid;
  
  RAISE NOTICE '✅ Selected set: %', v_set_id;
  
  -- Generate QR code
  v_qr_code := 'BS-' || UPPER(SUBSTRING(gen_random_uuid()::text, 1, 8));
  
  -- Create shipment directly
  INSERT INTO public.shipments (
    user_id,
    set_id,
    set_ref,
    shipment_status,
    pudo_type,
    brickshare_pudo_id,
    shipping_address,
    shipping_city,
    shipping_zip_code,
    shipping_province,
    shipping_country,
    delivery_qr_code,
    delivery_qr_expires_at,
    assigned_date,
    created_at,
    updated_at
  )
  SELECT
    v_user_id,
    v_set_id,
    s.set_ref,
    'assigned',
    'brickshare',
    'de8c8f58-0001-4000-8000-000000000001',
    bp.address,
    bp.city,
    bp.postal_code,
    bp.province,
    'ES',
    v_qr_code,
    NOW() + INTERVAL '30 days',
    NOW(),
    NOW(),
    NOW()
  FROM public.sets s
  CROSS JOIN public.brickshare_pudo_locations bp
  WHERE s.id = v_set_id
    AND bp.id = 'de8c8f58-0001-4000-8000-000000000001'::uuid
  RETURNING id INTO v_shipment_id;
  
  -- Update inventory
  UPDATE public.inventory_sets
  SET
    in_shipping = in_shipping + 1,
    inventory_set_total_qty = inventory_set_total_qty - 1,
    updated_at = NOW()
  WHERE set_id = v_set_id;
  
  -- Update user status
  UPDATE public.users
  SET
    user_status = 'assigned_set',
    updated_at = NOW()
  WHERE user_id = v_user_id;
  
  RAISE NOTICE '';
  RAISE NOTICE '════════════════════════════════════════════════════════';
  RAISE NOTICE '✅ SHIPMENT CREATED SUCCESSFULLY';
  RAISE NOTICE '════════════════════════════════════════════════════════';
  RAISE NOTICE 'Shipment ID:  %', v_shipment_id;
  RAISE NOTICE 'User:         enriquepeto@yahoo.es';
  RAISE NOTICE 'Set ID:       %', v_set_id;
  RAISE NOTICE 'Set Ref:      10698';
  RAISE NOTICE 'QR Code:      %', v_qr_code;
  RAISE NOTICE 'Expires:      %', (NOW() + INTERVAL '30 days')::date;
  RAISE NOTICE 'PUDO:         Depósito Brickshare Madrid';
  RAISE NOTICE 'Status:       assigned';
  RAISE NOTICE '════════════════════════════════════════════════════════';
  RAISE NOTICE '';
  RAISE NOTICE '📧 Next step: Send email with QR code';
  RAISE NOTICE '   npx tsx scripts/simulate-brickshare-assignment.ts';
  RAISE NOTICE '';
END $$;

-- Display complete shipment info
\echo '📦 Complete Shipment Details:'
\echo ''

SELECT
  s.id as shipment_id,
  s.shipment_status,
  s.pudo_type,
  s.set_ref,
  s.delivery_qr_code as qr_code,
  TO_CHAR(s.delivery_qr_expires_at, 'YYYY-MM-DD HH24:MI') as qr_expires,
  s.shipping_address as pudo_address,
  s.shipping_city as pudo_city,
  s.shipping_zip_code as pudo_postal_code,
  u.email as user_email,
  u.full_name as user_name,
  st.set_name,
  bp.name as pudo_name
FROM public.shipments s
JOIN public.users u ON s.user_id = u.user_id
JOIN public.sets st ON s.set_id = st.id
LEFT JOIN public.brickshare_pudo_locations bp ON s.brickshare_pudo_id::uuid = bp.id
WHERE u.email = 'enriquepeto@yahoo.es'
  AND s.pudo_type = 'brickshare'
ORDER BY s.created_at DESC
LIMIT 1;

\echo ''
\echo '✅ Simulation complete!'
\echo ''