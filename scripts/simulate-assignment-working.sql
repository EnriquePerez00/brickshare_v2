-- =====================================================
-- Simulate Brickshare PUDO Assignment - WORKING VERSION
-- Target: enriquepeto@yahoo.es
-- =====================================================

\echo '=============================================='
\echo '🚀 BRICKSHARE ASSIGNMENT SIMULATION'
\echo '=============================================='
\echo ''

-- Step 1: Create/Update Brickshare PUDO
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
  'BRICKSHARE-MADRID-001',
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

-- Step 2: Use existing set or create one
\echo '🧱 Step 2: Finding/Creating LEGO set...'

DO $$
DECLARE
  v_set_id uuid;
BEGIN
  -- Try to find an existing set
  SELECT id INTO v_set_id
  FROM public.sets
  WHERE set_status = 'available'
  LIMIT 1;
  
  IF v_set_id IS NULL THEN
    -- Create a test set
    INSERT INTO public.sets (
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
      '10698-TEST',
      'Caja de Ladrillos Creativos Grande (TEST)',
      'Classic',
      '4-99',
      790,
      15.00,
      49.99,
      'https://images.brickset.com/sets/images/10698-1.jpg',
      'active',
      NOW(),
      NOW()
    ) RETURNING id INTO v_set_id;
    
    -- Create inventory for new set
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
      v_set_id,
      5,
      0,
      0,
      0,
      0,
      NOW(),
      NOW()
    );
    
    RAISE NOTICE '✅ Created test set: %', v_set_id;
  ELSE
    RAISE NOTICE '✅ Using existing set: %', v_set_id;
  END IF;
END $$;

\echo '✅ LEGO set ready'
\echo ''

-- Step 3: Configure user and create shipment
\echo '👤 Step 3: Configuring user and creating shipment...'

DO $$
DECLARE
  v_user_id uuid;
  v_set_id uuid;
  v_set_ref text;
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
    pudo_id = 'BRICKSHARE-MADRID-001',
    stripe_payment_method_id = COALESCE(stripe_payment_method_id, 'pm_card_visa'),
    profile_completed = true,
    updated_at = NOW()
  WHERE user_id = v_user_id;
  
  RAISE NOTICE '✅ User configured: %', v_user_id;
  
  -- Get an available set
  SELECT s.id, s.set_ref
  INTO v_set_id, v_set_ref
  FROM public.sets s
  JOIN public.inventory_sets i ON s.id = i.set_id
  WHERE s.set_status = 'active'
    AND i.inventory_set_total_qty > 0
  LIMIT 1;
  
  IF v_set_id IS NULL THEN
    RAISE EXCEPTION 'No available sets in inventory';
  END IF;
  
  RAISE NOTICE '✅ Selected set: % (ref: %)', v_set_id, v_set_ref;
  
  -- Generate QR code
  v_qr_code := 'BS-' || UPPER(SUBSTRING(gen_random_uuid()::text, 1, 8));
  
  -- Create shipment
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
    v_set_ref,
    'assigned',
    'brickshare',
    'BRICKSHARE-MADRID-001',
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
  FROM public.brickshare_pudo_locations bp
  WHERE bp.id = 'BRICKSHARE-MADRID-001'
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
  RAISE NOTICE 'Set Ref:      %', v_set_ref;
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
  s.brickshare_pudo_id as pudo_id
FROM public.shipments s
JOIN public.users u ON s.user_id = u.user_id
JOIN public.sets st ON s.set_id = st.id
WHERE u.email = 'enriquepeto@yahoo.es'
  AND s.pudo_type = 'brickshare'
ORDER BY s.created_at DESC
LIMIT 1;

\echo ''
\echo '✅ Simulation complete!'
\echo ''