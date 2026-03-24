-- =====================================================
-- Create/Update User: user@brickshare.com
-- Password: User1test
-- =====================================================

DO $$
DECLARE
  v_user_id uuid := '78df0591-4c9d-4e4d-acb2-32ed95e261f5';
BEGIN
  -- Create/Update auth user
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
    v_user_id,
    'authenticated',
    'authenticated',
    'user@brickshare.com',
    crypt('User1test', gen_salt('bf')),
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
    email = 'user@brickshare.com',
    updated_at = NOW();

  -- Create/Update public user
  INSERT INTO users (
    user_id,
    email,
    full_name,
    subscription_status,
    subscription_type,
    user_status,
    profile_completed,
    stripe_customer_id,
    referral_code,
    impact_points
  ) VALUES (
    v_user_id,
    'user@brickshare.com',
    'Test User',
    'active',
    'basic',
    'no_set',
    true,
    'cus_test_user_' || substring(v_user_id::text, 1, 8),
    'USER' || substring(md5(random()::text), 1, 6),
    0
  )
  ON CONFLICT (user_id) DO UPDATE SET
    email = 'user@brickshare.com',
    full_name = 'Test User',
    subscription_status = 'active',
    subscription_type = 'basic',
    profile_completed = true,
    updated_at = NOW();

  -- Ensure user role
  INSERT INTO user_roles (user_id, role)
  VALUES (v_user_id, 'user')
  ON CONFLICT (user_id, role) DO NOTHING;

  -- Ensure identity
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
  ON CONFLICT (provider, provider_id) DO NOTHING;

  RAISE NOTICE '==============================================';
  RAISE NOTICE 'User: user@brickshare.com';
  RAISE NOTICE 'Password: User1test';
  RAISE NOTICE 'User ID: %', v_user_id;
  RAISE NOTICE 'Status: Ready to use';
  RAISE NOTICE '==============================================';

END $$;

-- Comprehensive verification
\echo ''
\echo '===== VERIFICATION ====='
\echo ''
\echo '1. Auth User:'
SELECT 
  id,
  email,
  email_confirmed_at IS NOT NULL as email_confirmed,
  created_at
FROM auth.users
WHERE email = 'user@brickshare.com';

\echo ''
\echo '2. Public User:'
SELECT 
  user_id,
  email,
  full_name,
  user_status,
  subscription_type,
  subscription_status,
  profile_completed
FROM users
WHERE email = 'user@brickshare.com';

\echo ''
\echo '3. User Roles:'
SELECT 
  ur.role
FROM user_roles ur
JOIN users u ON u.user_id = ur.user_id
WHERE u.email = 'user@brickshare.com';

\echo ''
\echo '4. Auth Identity:'
SELECT 
  provider,
  created_at
FROM auth.identities
WHERE user_id = '78df0591-4c9d-4e4d-acb2-32ed95e261f5';