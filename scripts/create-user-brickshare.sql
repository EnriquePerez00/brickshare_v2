-- =====================================================
-- Create User: user@brickshare.com
-- Password: User1test
-- Subscription: Basic (active)
-- =====================================================

DO $$
DECLARE
  v_user_id uuid;
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
    '78df0591-4c9d-4e4d-acb2-32ed95e261f5', -- Fixed UUID for consistency
    'authenticated',
    'authenticated',
    'user@brickshare.com',
    crypt('User1test', gen_salt('bf')), -- Bcrypt hash
    NOW(),
    '{"full_name": "Test User"}'::jsonb,
    '{"provider": "email", "providers": ["email"]}'::jsonb,
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
  )
  ON CONFLICT (id) DO UPDATE SET
    encrypted_password = crypt('User1test', gen_salt('bf')),
    email = EXCLUDED.email,
    updated_at = NOW()
  RETURNING id INTO v_user_id;

  RAISE NOTICE 'Created/Updated auth user with ID: %', v_user_id;

  -- Create/Update user profile in users table
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
    'user@brickshare.com',
    'Test User',
    '+34600000000',
    'Calle Test 1',
    'Madrid',
    '28001',
    'active',
    'basic',
    'active',
    'cus_test_user_' || substring(v_user_id::text, 1, 8),
    'sub_test_user_' || substring(v_user_id::text, 1, 8),
    'pm_card_visa',
    NOW(),
    NOW() + INTERVAL '1 year',
    true,
    0,
    'USER' || substring(md5(random()::text), 1, 6),
    NULL,
    0,
    0,
    NOW(),
    NOW()
  )
  ON CONFLICT (user_id) DO UPDATE SET
    email = EXCLUDED.email,
    full_name = EXCLUDED.full_name,
    subscription_status = EXCLUDED.subscription_status,
    subscription_type = EXCLUDED.subscription_type,
    user_status = EXCLUDED.user_status,
    updated_at = NOW();

  RAISE NOTICE 'Created/Updated user profile for: user@brickshare.com';

  -- Assign user role
  INSERT INTO user_roles (user_id, role)
  VALUES (v_user_id, 'user')
  ON CONFLICT (user_id, role) DO NOTHING;

  RAISE NOTICE 'Assigned user role';

  -- Create identity record for email provider
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
      'email', 'user@brickshare.com'
    ),
    'email',
    NOW(),
    NOW(),
    NOW()
  )
  ON CONFLICT (provider, provider_id) DO UPDATE SET
    identity_data = EXCLUDED.identity_data,
    updated_at = NOW();

  RAISE NOTICE 'Created/Updated identity record';

  -- Summary
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'User created/updated successfully!';
  RAISE NOTICE 'Email: user@brickshare.com';
  RAISE NOTICE 'Password: User1test';
  RAISE NOTICE 'User ID: %', v_user_id;
  RAISE NOTICE 'Subscription: Basic (active)';
  RAISE NOTICE '==============================================';

END $$;

-- Verify creation
SELECT 
  u.user_id,
  u.email,
  u.full_name,
  u.subscription_type,
  u.subscription_status,
  u.user_status,
  u.stripe_payment_method_id
FROM users u
WHERE u.email = 'user@brickshare.com';