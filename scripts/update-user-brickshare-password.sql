-- =====================================================
-- Update/Create User: user@brickshare.com
-- Password: User1test
-- =====================================================

DO $$
DECLARE
  v_user_id uuid := '78df0591-4c9d-4e4d-acb2-32ed95e261f5';
  v_auth_user_exists boolean;
  v_public_user_exists boolean;
BEGIN
  -- Check if user exists in auth.users
  SELECT EXISTS (
    SELECT 1 FROM auth.users WHERE id = v_user_id
  ) INTO v_auth_user_exists;

  -- Check if user exists in public.users
  SELECT EXISTS (
    SELECT 1 FROM users WHERE user_id = v_user_id
  ) INTO v_public_user_exists;

  IF v_auth_user_exists THEN
    -- Update existing auth user password
    UPDATE auth.users 
    SET 
      encrypted_password = crypt('User1test', gen_salt('bf')),
      email = 'user@brickshare.com',
      updated_at = NOW()
    WHERE id = v_user_id;
    
    RAISE NOTICE 'Updated password for existing auth user';
  ELSE
    -- Create new auth user
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
    );
    
    RAISE NOTICE 'Created new auth user';
  END IF;

  IF v_public_user_exists THEN
    -- Update existing public user
    UPDATE users 
    SET 
      email = 'user@brickshare.com',
      full_name = 'Test User',
      subscription_status = 'active',
      subscription_type = 'basic',
      user_status = 'active',
      profile_completed = true,
      updated_at = NOW()
    WHERE user_id = v_user_id;
    
    RAISE NOTICE 'Updated existing public user';
  ELSE
    -- Create new public user
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
      'active',
      true,
      'cus_test_user_' || substring(v_user_id::text, 1, 8),
      'USER' || substring(md5(random()::text), 1, 6),
      0
    );
    
    RAISE NOTICE 'Created new public user';
  END IF;

  -- Ensure user role exists
  INSERT INTO user_roles (user_id, role)
  VALUES (v_user_id, 'user')
  ON CONFLICT (user_id, role) DO NOTHING;

  -- Ensure identity exists
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

  RAISE NOTICE '==============================================';
  RAISE NOTICE 'User ready!';
  RAISE NOTICE 'Email: user@brickshare.com';
  RAISE NOTICE 'Password: User1test';
  RAISE NOTICE 'User ID: %', v_user_id;
  RAISE NOTICE '==============================================';

END $$;

-- Verify user in both tables
SELECT 
  'auth.users' as table_name,
  email,
  email_confirmed_at IS NOT NULL as email_confirmed
FROM auth.users
WHERE email = 'user@brickshare.com'
UNION ALL
SELECT 
  'public.users' as table_name,
  email,
  profile_completed as email_confirmed
FROM users
WHERE email = 'user@brickshare.com';