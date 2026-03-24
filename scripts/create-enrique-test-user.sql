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

  -- Step 2: Update user profile in users table (trigger already created basic record)
  UPDATE users SET
    email = 'enriquepeto@yahoo.es',
    full_name = 'Enrique Perez',
    phone = '+34600123456',
    address = 'Calle Test 123',
    city = 'Madrid',
    zip_code = '28001',
    subscription_status = 'active',
    subscription_type = 'brick_master',
    user_status = 'no_set',
    stripe_customer_id = 'cus_test_enrique_' || substring(v_user_id::text, 1, 8),
    stripe_payment_method_id = 'pm_card_visa',
    profile_completed = true,
    impact_points = 500,
    referral_code = 'ENRIQUE' || substring(md5(random()::text), 1, 6),
    referral_credits = 0,
    updated_at = NOW()
  WHERE user_id = v_user_id;

  RAISE NOTICE 'Created user profile for: enriquepeto@yahoo.es';

  -- Step 3: Ensure user role exists (trigger may have already created it)
  INSERT INTO user_roles (user_id, role)
  VALUES (v_user_id, 'user')
  ON CONFLICT (user_id, role) DO NOTHING;

  RAISE NOTICE 'User role ensured';

  -- Step 4: Create identity record for email provider
  INSERT INTO auth.identities (
    provider_id,
    user_id,
    identity_data,
    provider,
    last_sign_in_at,
    created_at,
    updated_at
  ) VALUES (
    v_user_id::text,
    v_user_id,
    jsonb_build_object(
      'sub', v_user_id::text,
      'email', 'enriquepeto@yahoo.es',
      'email_verified', false,
      'phone_verified', false
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