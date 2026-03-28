-- =====================================================
-- Simulate Brickshare PUDO Assignment Flow
-- Target: enriquepeto@yahoo.es
-- PUDO Type: brickshare (Depósito Brickshare)
-- =====================================================

\echo '=========================================='
\echo '🚀 BRICKSHARE ASSIGNMENT SIMULATION'
\echo '=========================================='
\echo ''

-- =====================================================
-- STEP 1: Create/Verify Brickshare Deposit PUDO
-- =====================================================
\echo '📍 Step 1: Creating Brickshare Deposit PUDO...'

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
  'L-V: 9:00-20:00, S: 10:00-14:00',
  true,
  NOW(),
  NOW()
)
ON CONFLICT (id) DO UPDATE SET
  is_active = true,
  updated_at = NOW();

\echo '✅ Brickshare Deposit created/verified'
\echo ''

-- =====================================================
-- STEP 2: Verify/Update User enriquepeto@yahoo.es
-- =====================================================
\echo '👤 Step 2: Verifying user enriquepeto@yahoo.es...'

DO $$
DECLARE
  v_user_id uuid;
  v_user_exists boolean;
BEGIN
  -- Check if user exists
  SELECT user_id INTO v_user_id
  FROM public.users
  WHERE email = 'enriquepeto@yahoo.es';
  
  v_user_exists := FOUND;
  
  IF NOT v_user_exists THEN
    RAISE EXCEPTION 'User enriquepeto@yahoo.es not found. Please run scripts/create-enrique-test-user.sql first.';
  END IF;
  
  -- Update user with Brickshare PUDO configuration
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
  
  RAISE NOTICE '✅ User updated with Brickshare PUDO configuration';
  RAISE NOTICE '   - User ID: %', v_user_id;
  RAISE NOTICE '   - Status: no_set';
  RAISE NOTICE '   - PUDO Type: brickshare';
  RAISE NOTICE '   - PUDO ID: de8c8f58-0001-4000-8000-000000000001';
END $$;

\echo ''

-- =====================================================
-- STEP 3: Ensure Wishlist Has Sets
-- =====================================================
\echo '📝 Step 3: Checking wishlist...'

DO $$
DECLARE
  v_user_id uuid;
  v_wishlist_count integer;
  v_available_set_id uuid;
BEGIN
  -- Get user ID
  SELECT user_id INTO v_user_id
  FROM public.users
  WHERE email = 'enriquepeto@yahoo.es';
  
  -- Count active wishlist items
  SELECT COUNT(*) INTO v_wishlist_count
  FROM public.wishlist
  WHERE user_id = v_user_id AND status = true;
  
  RAISE NOTICE '   Current wishlist items: %', v_wishlist_count;
  
  -- If wishlist is empty, add a set
  IF v_wishlist_count = 0 THEN
    -- Find first available set with inventory
    SELECT s.id INTO v_available_set_id
    FROM public.sets s
    JOIN public.inventory_sets i ON s.id = i.set_id
    WHERE i.inventory_set_total_qty > 0
    ORDER BY s.set_price ASC
    LIMIT 1;
    
    IF v_available_set_id IS NOT NULL THEN
      INSERT INTO public.wishlist (user_id, set_id, status, created_at, status_changed_at)
      VALUES (v_user_id, v_available_set_id, true, NOW(), NOW())
      ON CONFLICT (user_id, set_id) DO UPDATE
      SET status = true, status_changed_at = NOW();
      
      RAISE NOTICE '✅ Added set to wishlist: %', v_available_set_id;
    ELSE
      RAISE EXCEPTION 'No available sets in inventory';
    END IF;
  ELSE
    RAISE NOTICE '✅ Wishlist already has % item(s)', v_wishlist_count;
  END IF;
END $$;

\echo ''

-- =====================================================
-- STEP 4: Preview Assignment
-- =====================================================
\echo '🔍 Step 4: Previewing assignment...'

SELECT 
  user_name,
  user_email,
  set_name,
  set_ref,
  set_price,
  current_stock,
  pudo_type,
  pudo_name
FROM preview_assign_sets_to_users()
WHERE user_email = 'enriquepeto@yahoo.es';

\echo ''

-- =====================================================
-- STEP 5: Confirm Assignment (Create Shipment)
-- =====================================================
\echo '✅ Step 5: Confirming assignment...'

DO $$
DECLARE
  v_user_id uuid;
  v_assignment_result RECORD;
  v_shipment_id uuid;
  v_qr_code text;
  v_qr_expires_at timestamptz;
BEGIN
  -- Get user ID
  SELECT user_id INTO v_user_id
  FROM public.users
  WHERE email = 'enriquepeto@yahoo.es';
  
  -- Execute assignment
  SELECT * INTO v_assignment_result
  FROM confirm_assign_sets_to_users(ARRAY[v_user_id])
  LIMIT 1;
  
  IF v_assignment_result.shipment_id IS NULL THEN
    RAISE EXCEPTION 'Assignment failed - no shipment created';
  END IF;
  
  v_shipment_id := v_assignment_result.shipment_id;
  
  RAISE NOTICE '✅ Shipment created successfully';
  RAISE NOTICE '   - Shipment ID: %', v_shipment_id;
  RAISE NOTICE '   - User: %', v_assignment_result.user_name;
  RAISE NOTICE '   - Email: %', v_assignment_result.user_email;
  RAISE NOTICE '   - Set: % (%)', v_assignment_result.set_name, v_assignment_result.set_ref;
  RAISE NOTICE '   - PUDO: %', v_assignment_result.pudo_name;
  RAISE NOTICE '   - Address: %', v_assignment_result.pudo_address;
  RAISE NOTICE '   - City: % %', v_assignment_result.pudo_cp, v_assignment_result.pudo_city;
  RAISE NOTICE '   - Province: %', v_assignment_result.pudo_province;
  
  -- =====================================================
  -- STEP 6: Generate QR Code
  -- =====================================================
  RAISE NOTICE '';
  RAISE NOTICE '🎫 Step 6: Generating QR code...';
  
  -- Generate QR code
  v_qr_code := 'BS-' || UPPER(SUBSTRING(v_shipment_id::text, 1, 8));
  v_qr_expires_at := NOW() + INTERVAL '30 days';
  
  -- Update shipment with QR code
  UPDATE public.shipments
  SET
    delivery_qr_code = v_qr_code,
    delivery_qr_expires_at = v_qr_expires_at,
    updated_at = NOW()
  WHERE id = v_shipment_id;
  
  RAISE NOTICE '✅ QR Code generated';
  RAISE NOTICE '   - QR Code: %', v_qr_code;
  RAISE NOTICE '   - Expires: %', v_qr_expires_at;
  
  -- Store shipment_id for next step
  PERFORM set_config('app.last_shipment_id', v_shipment_id::text, false);
  PERFORM set_config('app.qr_code', v_qr_code, false);
END $$;

\echo ''

-- =====================================================
-- STEP 7: Display Complete Shipment Information
-- =====================================================
\echo '📦 Step 7: Complete shipment information:'
\echo ''

SELECT
  s.id as shipment_id,
  s.shipment_status,
  s.pudo_type,
  s.set_ref,
  s.delivery_qr_code,
  s.delivery_qr_expires_at,
  s.brickshare_pudo_id,
  s.shipping_address,
  s.shipping_city,
  s.shipping_zip_code,
  s.shipping_province,
  s.shipping_country,
  s.assigned_date,
  s.created_at,
  u.email as user_email,
  u.full_name as user_name,
  st.set_name,
  st.set_ref as set_reference,
  bp.name as pudo_name,
  bp.address as pudo_address,
  bp.city as pudo_city,
  bp.postal_code as pudo_postal_code
FROM public.shipments s
JOIN public.users u ON s.user_id = u.user_id
JOIN public.sets st ON s.set_id = st.id
LEFT JOIN public.brickshare_pudo_locations bp ON s.brickshare_pudo_id = bp.id
WHERE s.id = current_setting('app.last_shipment_id')::uuid;

\echo ''
\echo '=========================================='
\echo '✅ SIMULATION COMPLETED'
\echo '=========================================='
\echo ''
\echo '📧 Next Step: Run the TypeScript script to send the email:'
\echo '   npx tsx scripts/simulate-brickshare-assignment.ts'
\echo ''
\echo '🔍 QR Code for testing:'
SELECT '   ' || current_setting('app.qr_code') as qr_code;
\echo ''