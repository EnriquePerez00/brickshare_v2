º-- ═══════════════════════════════════════════════════════════════
-- Create E2E Rental Test Users
-- ═══════════════════════════════════════════════════════════════
-- Creates test users: test@brickshare.test, admin@brickshare.test, operator@brickshare.test
-- Password for all: test123456
-- Run with: psql postgresql://postgres:postgres@127.0.0.1:5433/postgres -f scripts/create-e2e-rental-test-users.sql
-- ═══════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════
-- 1. TEST USER (regular user)
-- ═══════════════════════════════════════════════════════════════

-- Delete if exists
DELETE FROM auth.users WHERE email = 'test@brickshare.test';

-- Create user in auth.users
INSERT INTO auth.users (
  id,
  instance_id,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  aud,
  role,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
)
VALUES (
  '11111111-1111-1111-1111-111111111111'::uuid,
  '00000000-0000-0000-0000-000000000000'::uuid,
  'test@brickshare.test',
  crypt('test123456', gen_salt('bf')),
  now(),
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{"full_name":"Test User"}'::jsonb,
  'authenticated',
  'authenticated',
  now(),
  now(),
  '',
  '',
  '',
  ''
);

-- Create user profile in public.users
INSERT INTO public.users (
  user_id,
  email,
  full_name,
  phone,
  address,
  zip_code,
  city,
  province,
  subscription_type,
  subscription_status,
  stripe_customer_id,
  stripe_payment_method_id,
  pudo_id,
  pudo_type,
  profile_completed,
  created_at,
  updated_at
)
VALUES (
  '11111111-1111-1111-1111-111111111111'::uuid,
  'test@brickshare.test',
  'Test User',
  '+34600000111',
  'Calle Test 1',
  '28001',
  'Madrid',
  'Madrid',
  'brick_pro',
  'active',
  'cus_test_user',
  'pm_test_user',
  'BS-PUDO-001',
  'brickshare',
  true,
  now(),
  now()
)
ON CONFLICT (user_id) DO UPDATE SET
  email = EXCLUDED.email,
  full_name = EXCLUDED.full_name,
  subscription_type = EXCLUDED.subscription_type,
  subscription_status = EXCLUDED.subscription_status,
  pudo_id = EXCLUDED.pudo_id,
  pudo_type = EXCLUDED.pudo_type,
  updated_at = now();

-- Assign user role
INSERT INTO public.user_roles (user_id, role)
VALUES ('11111111-1111-1111-1111-111111111111'::uuid, 'user')
ON CONFLICT (user_id, role) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════
-- 2. ADMIN USER
-- ═══════════════════════════════════════════════════════════════

-- Delete if exists
DELETE FROM auth.users WHERE email = 'admin@brickshare.test';

-- Create user in auth.users
INSERT INTO auth.users (
  id,
  instance_id,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  aud,
  role,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
)
VALUES (
  '22222222-2222-2222-2222-222222222222'::uuid,
  '00000000-0000-0000-0000-000000000000'::uuid,
  'admin@brickshare.test',
  crypt('test123456', gen_salt('bf')),
  now(),
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{"full_name":"Admin User"}'::jsonb,
  'authenticated',
  'authenticated',
  now(),
  now(),
  '',
  '',
  '',
  ''
);

-- Create user profile
INSERT INTO public.users (
  user_id,
  email,
  full_name,
  phone,
  address,
  zip_code,
  city,
  province,
  subscription_type,
  subscription_status,
  profile_completed,
  created_at,
  updated_at
)
VALUES (
  '22222222-2222-2222-2222-222222222222'::uuid,
  'admin@brickshare.test',
  'Admin User',
  '+34600000222',
  'Calle Admin 1',
  '28002',
  'Madrid',
  'Madrid',
  'brick_pro',
  'active',
  true,
  now(),
  now()
)
ON CONFLICT (user_id) DO UPDATE SET
  email = EXCLUDED.email,
  full_name = EXCLUDED.full_name,
  updated_at = now();

-- Assign admin role
INSERT INTO public.user_roles (user_id, role)
VALUES ('22222222-2222-2222-2222-222222222222'::uuid, 'admin')
ON CONFLICT (user_id, role) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════
-- 3. OPERATOR USER
-- ═══════════════════════════════════════════════════════════════

-- Delete if exists
DELETE FROM auth.users WHERE email = 'operator@brickshare.test';

-- Create user in auth.users
INSERT INTO auth.users (
  id,
  instance_id,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  aud,
  role,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
)
VALUES (
  '33333333-3333-3333-3333-333333333333'::uuid,
  '00000000-0000-0000-0000-000000000000'::uuid,
  'operator@brickshare.test',
  crypt('test123456', gen_salt('bf')),
  now(),
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{"full_name":"Operator User"}'::jsonb,
  'authenticated',
  'authenticated',
  now(),
  now(),
  '',
  '',
  '',
  ''
);

-- Create user profile
INSERT INTO public.users (
  user_id,
  email,
  full_name,
  phone,
  address,
  zip_code,
  city,
  province,
  subscription_type,
  subscription_status,
  profile_completed,
  created_at,
  updated_at
)
VALUES (
  '33333333-3333-3333-3333-333333333333'::uuid,
  'operator@brickshare.test',
  'Operator User',
  '+34600000333',
  'Calle Operator 1',
  '28003',
  'Madrid',
  'Madrid',
  'brick_pro',
  'active',
  true,
  now(),
  now()
)
ON CONFLICT (user_id) DO UPDATE SET
  email = EXCLUDED.email,
  full_name = EXCLUDED.full_name,
  updated_at = now();

-- Assign operator role
INSERT INTO public.user_roles (user_id, role)
VALUES ('33333333-3333-3333-3333-333333333333'::uuid, 'operador')
ON CONFLICT (user_id, role) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════
-- VERIFY CREATION
-- ═══════════════════════════════════════════════════════════════

SELECT 
  u.id,
  u.email,
  u.full_name,
  u.subscription_type,
  u.subscription_status,
  u.pudo_id,
  u.pudo_type,
  string_agg(ur.role::text, ', ') as roles
FROM public.users u
LEFT JOIN public.user_roles ur ON ur.user_id = u.user_id
WHERE u.email IN ('test@brickshare.test', 'admin@brickshare.test', 'operator@brickshare.test')
GROUP BY u.id, u.email, u.full_name, u.subscription_type, u.subscription_status, u.pudo_id, u.pudo_type
ORDER BY u.email;
