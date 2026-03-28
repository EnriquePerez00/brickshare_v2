-- =====================================================
-- Complete Assignment Flow Simulation
-- Target: enriquepeto@yahoo.es
-- Includes: Assignment + QR Generation + Validation
-- =====================================================

\echo '=============================================='
\echo '🚀 COMPLETE ASSIGNMENT FLOW SIMULATION'
\echo '   User: enriquepeto@yahoo.es'
\echo '=============================================='
\echo ''

-- =====================================================
-- STEP 1: Verify User Configuration
-- =====================================================
\echo '📋 Step 1: Verifying user configuration...'
\echo ''

DO $$
DECLARE
  v_user_id uuid;
  v_email text;
  v_full_name text;
  v_user_status text;
  v_subscription_status text;
  v_subscription_type text;
  v_pudo_type text;
  v_pudo_id text;
  v_stripe_payment_method_id text;
  v_profile_completed boolean;
BEGIN
  -- Get user details
  SELECT 
    user_id, email, full_name, user_status, 
    subscription_status, subscription_type,
    pudo_type, pudo_id, stripe_payment_method_id, profile_completed
  INTO 
    v_user_id, v_email, v_full_name, v_user_status,
    v_subscription_status, v_subscription_type,
    v_pudo_type, v_pudo_id, v_stripe_payment_method_id, v_profile_completed
  FROM public.users
  WHERE email = 'enriquepeto@yahoo.es';
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION '❌ User not found: enriquepeto@yahoo.es';
  END IF;
  
  RAISE NOTICE '✅ User found:';
  RAISE NOTICE '   - ID: %', v_user_id;
  RAISE NOTICE '   - Name: %', v_full_name;
  RAISE NOTICE '   - Status: %', v_user_status;
  RAISE NOTICE '   - Subscription: % (%)', v_subscription_status, v_subscription_type;
  RAISE NOTICE '   - PUDO Type: %', v_pudo_type;
  RAISE NOTICE '   - PUDO ID: %', v_pudo_id;
  RAISE NOTICE '   - Payment Method: %', CASE WHEN v_stripe_payment_method_id IS NOT NULL THEN '✅ Configured' ELSE '❌ Missing' END;
  RAISE NOTICE '   - Profile Completed: %', v_profile_completed;
  
  -- Validate prerequisites
  IF v_subscription_status != 'active' THEN
    RAISE EXCEPTION '❌ User subscription is not active: %', v_subscription_status;
  END IF;
  
  IF v_pudo_id IS NULL THEN
    RAISE EXCEPTION '❌ User has no PUDO configured';
  END IF;
  
  IF v_stripe_payment_method_id IS NULL THEN
    RAISE EXCEPTION '❌ User has no payment method configured';
  END IF;
  
  RAISE NOTICE '';
  RAISE NOTICE '✅ All prerequisites met!';
  
  -- Store user_id for next steps
  PERFORM set_config('app.target_user_id', v_user_id::text, false);
  PERFORM set_config('app.target_pudo_type', v_pudo_type, false);
END $$;

\echo ''

-- =====================================================
-- STEP 2: Check PUDO Configuration
-- =====================================================
\echo '📍 Step 2: Checking PUDO configuration...'
\echo ''

DO $$
DECLARE
  v_user_id uuid := current_setting('app.target_user_id')::uuid;
  v_pudo_type text := current_setting('app.target_pudo_type');
  v_pudo_id text;
  v_pudo_name text;
  v_pudo_address text;
  v_pudo_exists boolean;
BEGIN
  SELECT pudo_id INTO v_pudo_id
  FROM public.users
  WHERE user_id = v_user_id;
  
  IF v_pudo_type = 'brickshare' THEN
    -- Check Brickshare PUDO
    SELECT EXISTS(
      SELECT 1 FROM public.brickshare_pudo_locations
      WHERE id = v_pudo_id::uuid AND is_active = true
    ) INTO v_pudo_exists;
    
    IF NOT v_pudo_exists THEN
      RAISE EXCEPTION '❌ Brickshare PUDO not found or inactive: %', v_pudo_id;
    END IF;
    
    SELECT name, address INTO v_pudo_name, v_pudo_address
    FROM public.brickshare_pudo_locations
    WHERE id = v_pudo_id::uuid;
    
    RAISE NOTICE '✅ Brickshare PUDO configured:';
    RAISE NOTICE '   - ID: %', v_pudo_id;
    RAISE NOTICE '   - Name: %', v_pudo_name;
    RAISE NOTICE '   - Address: %', v_pudo_address;
    
  ELSIF v_pudo_type = 'correos' THEN
    -- Check Correos PUDO
    SELECT EXISTS(
      SELECT 1 FROM public.users_correos_dropping
      WHERE user_id = v_user_id
    ) INTO v_pudo_exists;
    
    IF NOT v_pudo_exists THEN
      RAISE EXCEPTION '❌ Correos PUDO not configured for user';
    END IF;
    
    SELECT location_name, address INTO v_pudo_name, v_pudo_address
    FROM public.users_correos_dropping
    WHERE user_id = v_user_id;
    
    RAISE NOTICE '✅ Correos PUDO configured:';
    RAISE NOTICE '   - Name: %', v_pudo_name;
    RAISE NOTICE '   - Address: %', v_pudo_address;
    
  ELSE
    RAISE EXCEPTION '❌ Invalid PUDO type: %', v_pudo_type;
  END IF;
END $$;

\echo ''

-- =====================================================
-- STEP 3: Check Wishlist
-- =====================================================
\echo '📝 Step 3: Checking wishlist...'
\echo ''

DO $$
DECLARE
  v_user_id uuid := current_setting('app.target_user_id')::uuid;
  v_wishlist_count integer;
  v_available_set_id uuid;
  v_set_name text;
  v_set_ref text;
BEGIN
  -- Count active wishlist items
  SELECT COUNT(*) INTO v_wishlist_count
  FROM public.wishlist
  WHERE user_id = v_user_id AND status = true;
  
  RAISE NOTICE '   Wishlist items: %', v_wishlist_count;
  
  -- If wishlist is empty, add a set
  IF v_wishlist_count = 0 THEN
    RAISE NOTICE '   Adding set to wishlist...';
    
    -- Find first available set with inventory
    SELECT s.id, s.set_name, s.set_ref INTO v_available_set_id, v_set_name, v_set_ref
    FROM public.sets s
    JOIN public.inventory_sets i ON s.id = i.set_id
    WHERE i.inventory_set_total_qty > 0
      AND s.set_status = 'available'
    ORDER BY s.set_price ASC
    LIMIT 1;
    
    IF v_available_set_id IS NULL THEN
      RAISE EXCEPTION '❌ No available sets in inventory';
    END IF;
    
    INSERT INTO public.wishlist (user_id, set_id, status, created_at, status_changed_at)
    VALUES (v_user_id, v_available_set_id, true, NOW(), NOW())
    ON CONFLICT (user_id, set_id) DO UPDATE
    SET status = true, status_changed_at = NOW();
    
    RAISE NOTICE '✅ Added set to wishlist: % (%)', v_set_name, v_set_ref;
  ELSE
    RAISE NOTICE '✅ Wishlist has % item(s)', v_wishlist_count;
  END IF;
  
  -- Display wishlist
  RAISE NOTICE '';
  RAISE NOTICE '📋 Current wishlist:';
  FOR v_set_name, v_set_ref IN
    SELECT s.set_name, s.set_ref
    FROM public.wishlist w
    JOIN public.sets s ON w.set_id = s.id
    WHERE w.user_id = v_user_id AND w.status = true
    LIMIT 5
  LOOP
    RAISE NOTICE '   - % (%)', v_set_name, v_set_ref;
  END LOOP;
END $$;

\echo ''

-- =====================================================
-- STEP 4: Preview Assignment
-- =====================================================
\echo '🔍 Step 4: Previewing assignment...'
\echo ''

SELECT 
  user_name,
  user_email,
  set_name,
  set_ref,
  set_price,
  current_stock,
  pudo_type,
  CASE 
    WHEN matches_wishlist THEN '✅ From Wishlist'
    ELSE '⚠️  Random (no wishlist match)'
  END as source
FROM preview_assign_sets_to_users()
WHERE user_email = 'enriquepeto@yahoo.es';

\echo ''

-- =====================================================
-- STEP 5: Confirm Assignment (Create Shipment)
-- =====================================================
\echo '✅ Step 5: Confirming assignment...'
\echo ''

DO $$
DECLARE
  v_user_id uuid := current_setting('app.target_user_id')::uuid;
  v_assignment_result RECORD;
  v_shipment_id uuid;
BEGIN
  -- Execute assignment
  SELECT * INTO v_assignment_result
  FROM confirm_assign_sets_to_users(ARRAY[v_user_id])
  LIMIT 1;
  
  IF v_assignment_result.shipment_id IS NULL THEN
    RAISE EXCEPTION '❌ Assignment failed - no shipment created';
  END IF;
  
  v_shipment_id := v_assignment_result.shipment_id;
  
  RAISE NOTICE '✅ Shipment created successfully';
  RAISE NOTICE '   - Shipment ID: %', v_shipment_id;
  RAISE NOTICE '   - User: %', v_assignment_result.user_name;
  RAISE NOTICE '   - Email: %', v_assignment_result.user_email;
  RAISE NOTICE '   - Set: % (%)', v_assignment_result.set_name, v_assignment_result.set_ref;
  RAISE NOTICE '   - Price: €%', v_assignment_result.set_price;
  RAISE NOTICE '   - PUDO: %', v_assignment_result.pudo_name;
  RAISE NOTICE '   - Created: %', v_assignment_result.created_at;
  
  -- Store shipment_id for next steps
  PERFORM set_config('app.shipment_id', v_shipment_id::text, false);
END $$;

\echo ''

-- =====================================================
-- STEP 6: Validate Shipment Creation
-- =====================================================
\echo '🔎 Step 6: Validating shipment...'
\echo ''

DO $$
DECLARE
  v_shipment_id uuid := current_setting('app.shipment_id')::uuid;
  v_shipment RECORD;
BEGIN
  SELECT * INTO v_shipment
  FROM public.shipments
  WHERE id = v_shipment_id;
  
  IF v_shipment.id IS NULL THEN
    RAISE EXCEPTION '❌ Shipment not found in database';
  END IF;
  
  RAISE NOTICE '✅ Shipment validated:';
  RAISE NOTICE '   - Status: %', v_shipment.shipment_status;
  RAISE NOTICE '   - PUDO Type: %', v_shipment.pudo_type;
  RAISE NOTICE '   - Set Ref: %', v_shipment.set_ref;
  RAISE NOTICE '   - Delivery QR: %', COALESCE(v_shipment.delivery_qr_code, 'NOT YET GENERATED');
  RAISE NOTICE '   - QR Expires: %', v_shipment.delivery_qr_expires_at;
  RAISE NOTICE '   - Shipping Address: %', v_shipment.shipping_address;
  RAISE NOTICE '   - Shipping City: %', v_shipment.shipping_city;
  RAISE NOTICE '   - Shipping Postal Code: %', v_shipment.shipping_zip_code;
  
  -- Validate required fields
  IF v_shipment.shipment_status IS NULL THEN
    RAISE EXCEPTION '❌ Shipment status is NULL';
  END IF;
  
  IF v_shipment.pudo_type IS NULL THEN
    RAISE EXCEPTION '❌ PUDO type is NULL';
  END IF;
  
  IF v_shipment.set_ref IS NULL THEN
    RAISE EXCEPTION '❌ Set ref is NULL';
  END IF;
  
  IF v_shipment.shipping_address IS NULL THEN
    RAISE EXCEPTION '❌ Shipping address is NULL';
  END IF;
  
  RAISE NOTICE '';
  RAISE NOTICE '✅ All required fields present!';
END $$;

\echo ''

-- =====================================================
-- STEP 7: Verify Inventory Update
-- =====================================================
\echo '📦 Step 7: Verifying inventory update...'
\echo ''

DO $$
DECLARE
  v_shipment_id uuid := current_setting('app.shipment_id')::uuid;
  v_set_id uuid;
  v_inventory RECORD;
BEGIN
  SELECT set_id INTO v_set_id
  FROM public.shipments
  WHERE id = v_shipment_id;
  
  SELECT * INTO v_inventory
  FROM public.inventory_sets
  WHERE set_id = v_set_id;
  
  RAISE NOTICE '✅ Inventory status:';
  RAISE NOTICE '   - Total Qty: %', v_inventory.inventory_set_total_qty;
  RAISE NOTICE '   - In Shipping: %', v_inventory.in_shipping;
  RAISE NOTICE '   - In Use: %', v_inventory.in_use;
  RAISE NOTICE '   - In Return: %', v_inventory.in_return;
  RAISE NOTICE '   - In Repair: %', v_inventory.in_repair;
  
  IF v_inventory.in_shipping = 0 THEN
    RAISE WARNING '⚠️  in_shipping is 0 - inventory may not have been updated';
  END IF;
END $$;

\echo ''

-- =====================================================
-- STEP 8: Display Complete Shipment Information
-- =====================================================
\echo '📄 Step 8: Complete shipment details:'
\echo ''

SELECT
  s.id as shipment_id,
  s.shipment_status,
  s.pudo_type,
  s.set_ref,
  s.delivery_qr_code,
  TO_CHAR(s.delivery_qr_expires_at, 'YYYY-MM-DD HH24:MI:SS') as qr_expires_at,
  s.brickshare_pudo_id,
  s.shipping_address,
  s.shipping_city,
  s.shipping_zip_code,
  s.shipping_province,
  s.shipping_country,
  TO_CHAR(s.assigned_date, 'YYYY-MM-DD HH24:MI:SS') as assigned_date,
  u.email as user_email,
  u.full_name as user_name,
  u.phone as user_phone,
  st.set_name,
  st.set_price,
  CASE 
    WHEN s.pudo_type = 'brickshare' THEN bp.name
    WHEN s.pudo_type = 'correos' THEN ucd.location_name
  END as pudo_name,
  CASE 
    WHEN s.pudo_type = 'brickshare' THEN bp.contact_phone
    WHEN s.pudo_type = 'correos' THEN ucd.contact_phone
  END as pudo_phone
FROM public.shipments s
JOIN public.users u ON s.user_id = u.user_id
JOIN public.sets st ON s.set_id = st.id
LEFT JOIN public.brickshare_pudo_locations bp ON s.brickshare_pudo_id = bp.id
LEFT JOIN public.users_correos_dropping ucd ON s.user_id = ucd.user_id
WHERE s.id = current_setting('app.shipment_id')::uuid;

\echo ''
\echo '=============================================='
\echo '✅ SQL SIMULATION COMPLETED'
\echo '=============================================='
\echo ''
\echo '📧 Next Step: Run TypeScript script to send email'
\echo '   npx tsx scripts/simulate-enrique-complete-flow.ts'
\echo ''
\echo '🔍 Shipment ID for testing:'
SELECT '   ' || current_setting('app.shipment_id') as shipment_id;
\echo ''