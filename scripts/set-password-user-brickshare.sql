-- =====================================================
-- Set password for existing user: user@brickshare.com
-- Password: User1test
-- User ID: 83c0c80a-aef3-47cc-a6a9-dd9c5172dae4
-- =====================================================

DO $$
DECLARE
  v_user_id uuid := '83c0c80a-aef3-47cc-a6a9-dd9c5172dae4';
BEGIN
  -- Create/Update auth.users
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
    '{"full_name": "Jan Perez"}'::jsonb,
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
    email_confirmed_at = NOW(),
    updated_at = NOW();

  -- Ensure auth.identities exists (provider_id = email for email provider)
  INSERT INTO auth.identities (
    provider_id,
    user_id,
    identity_data,
    provider,
    last_sign_in_at,
    created_at,
    updated_at
  ) VALUES (
    'user@brickshare.com',
    v_user_id,
    jsonb_build_object(
      'sub', v_user_id::text,
      'email', 'user@brickshare.com',
      'email_verified', true,
      'phone_verified', false
    ),
    'email',
    NOW(),
    NOW(),
    NOW()
  )
  ON CONFLICT (provider, provider_id) DO UPDATE SET
    identity_data = EXCLUDED.identity_data,
    updated_at = NOW();

  -- Ensure user role
  INSERT INTO user_roles (user_id, role)
  VALUES (v_user_id, 'user')
  ON CONFLICT (user_id, role) DO NOTHING;

  RAISE NOTICE '==============================================';
  RAISE NOTICE 'Password updated successfully!';
  RAISE NOTICE 'Email: user@brickshare.com';
  RAISE NOTICE 'Password: User1test';
  RAISE NOTICE 'User ID: %', v_user_id;
  RAISE NOTICE '==============================================';

END $$;

-- Verification
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
WHERE id = '83c0c80a-aef3-47cc-a6a9-dd9c5172dae4';

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
WHERE user_id = '83c0c80a-aef3-47cc-a6a9-dd9c5172dae4';

\echo ''
\echo '3. User Roles:'
SELECT role
FROM user_roles
WHERE user_id = '83c0c80a-aef3-47cc-a6a9-dd9c5172dae4';

\echo ''
\echo '4. Auth Identity:'
SELECT 
  provider,
  provider_id,
  created_at
FROM auth.identities
WHERE user_id = '83c0c80a-aef3-47cc-a6a9-dd9c5172dae4';