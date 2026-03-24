-- =====================================================
-- Create Test User: enriquepeto@yahoo.es
-- Password: User1test
-- Subscription: Brick Master (active)
-- =====================================================

-- Step 1: Create user in auth.users with hashed password
-- Password hash for "User1test" using bcrypt
DO $$
DECLARE
  v_user_id uuid;
  v_set_ids uuid[];
BEGIN
  -- Create auth user
  INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_user_meta_data,
    raw_app_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'enriquepeto@yahoo.es',
    crypt('User1test', gen_salt('bf')), -- Bcrypt hash
    NOW(),
    '{"full_name": "Enrique Perez"}'::jsonb,
    '{"provider": "email", "providers": ["email"]}'::jsonb,
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
  )
  RETURNING id INTO v_user_id;

  RAISE NOTICE 'Created auth user with ID: %', v_user_id;

  -- Step 2: Create user profile in users table
  INSERT INTO users (
    user_id,
    email,
    full_name,
    phone,
    address,
    city,
    zip_code,
    subscription_status,
    subscription_type,
    user_status,
    stripe_customer_id,
    stripe_subscription_id,
    stripe_payment_method_id,
    subscription_start_date,
    subscription_end_date,
    profile_completed,
    impact_points,
    referral_code,
    referred_by,
    free_months_earned,
    free_months_used,
    created_at,
    updated_at
  ) VALUES (
    v_user_id,
    'enriquepeto@yahoo.es',
    'Enrique Perez',
    '+34600123456',
    'Calle Test 123',
    'Madrid',
    '28001',
    'active', -- subscription_status
    'brick_master', -- subscription_type (premium tier)
    'active', -- user_status
    'cus_test_enrique_' || substring(v_user_id::text, 1, 8), -- Test Stripe customer ID
    'sub_test_enrique_' || substring(v_user_id::text, 1, 8), -- Test Stripe subscription ID
    'pm_card_visa', -- Test payment method (Stripe test card)
    NOW(),
    NOW() + INTERVAL '1 year',
    true,
    500,
    'ENRIQUE' || substring(md5(random()::text), 1, 6),
    NULL,
    0,
    0,
    NOW(),
    NOW()
  );

  RAISE NOTICE 'Created user profile for: enriquepeto@yahoo.es';

  -- Step 3: Assign user role
  INSERT INTO user_roles (user_id, role)
  VALUES (v_user_id, 'user');

  RAISE NOTICE 'Assigned user role';

  -- Step 4: Get 5 sets with available inventory
  SELECT ARRAY(
    SELECT set_id 
    FROM inventory_sets 
    WHERE available > 0 
    ORDER BY set_id 
    LIMIT 5
  ) INTO v_set_ids;

  RAISE NOTICE 'Selected % sets for wishlist', array_length(v_set_ids, 1);

  -- Step 5: Add sets to wishlist
  IF array_length(v_set_ids, 1) >= 5 THEN
    INSERT INTO wishlist (user_id, set_id, priority, created_at)
    SELECT 
      v_user_id,
      unnest(v_set_ids),
      generate_series(1, array_length(v_set_ids, 1)),
      NOW();
    
    RAISE NOTICE 'Added % sets to wishlist', array_length(v_set_ids, 1);
  ELSE
    RAISE NOTICE 'WARNING: Only % sets with inventory available', array_length(v_set_ids, 1);
  END IF;

  -- Step 6: Create identity record for email provider
  INSERT INTO auth.identities (
    id,
    user_id,
    identity_data,
    provider,
    last_sign_in_at,
    created_at,
    updated_at
  ) VALUES (
    gen_random_uuid(),
    v_user_id,
    jsonb_build_object(
      'sub', v_user_id::text,
      'email', 'enriquepeto@yahoo.es'
    ),
    'email',
    NOW(),
    NOW(),
    NOW()
  );

  RAISE NOTICE 'Created identity record';

  -- Summary
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'User created successfully!';
  RAISE NOTICE 'Email: enriquepeto@yahoo.es';
  RAISE NOTICE 'Password: User1test';
  RAISE NOTICE 'User ID: %', v_user_id;
  RAISE NOTICE 'Subscription: Brick Master (active)';
  RAISE NOTICE 'Payment Method: pm_card_visa (Stripe test)';
  RAISE NOTICE 'Sets in Wishlist: %', array_length(v_set_ids, 1);
  RAISE NOTICE '==============================================';

END $$;

-- Verify creation
SELECT 
  u.email,
  u.full_name,
  u.subscription_type,
  u.subscription_status,
  u.stripe_payment_method_id,
  COUNT(w.set_id) as wishlist_count
FROM users u
LEFT JOIN wishlist w ON w.user_id = u.user_id
WHERE u.email = 'enriquepeto@yahoo.es'
GROUP BY u.user_id, u.email, u.full_name, u.subscription_type, u.subscription_status, u.stripe_payment_method_id;