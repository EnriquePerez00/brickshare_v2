-- ═══════════════════════════════════════════════════════════════
-- Create E2E Test User
-- ═══════════════════════════════════════════════════════════════
-- This script creates the test user needed for E2E tests
-- Run with: psql postgresql://postgres:postgres@127.0.0.1:5433/postgres -f scripts/create-e2e-test-user.sql
-- ═══════════════════════════════════════════════════════════════

-- First, ensure the user doesn't exist in auth.users
DELETE FROM auth.users WHERE email = 'test.user@brickshare.com';

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
  '00000000-0000-0000-0000-000000000001'::uuid,
  '00000000-0000-0000-0000-000000000000'::uuid,
  'test.user@brickshare.com',
  crypt('TestPassword123!', gen_salt('bf')),
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
  id,
  email,
  full_name,
  phone,
  address,
  postal_code,
  city,
  country,
  subscription_plan,
  subscription_status,
  stripe_customer_id,
  stripe_subscription_id,
  stripe_payment_method_id,
  created_at,
  updated_at
)
VALUES (
  '00000000-0000-0000-0000-000000000001'::uuid,
  'test.user@brickshare.com',
  'Test User',
  '+34600000001',
  'Calle Test 1',
  '28001',
  'Madrid',
  'España',
  'basic',
  'active',
  'cus_test_user',
  'sub_test_user',
  'pm_test_user',
  now(),
  now()
)
ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  full_name = EXCLUDED.full_name,
  subscription_plan = EXCLUDED.subscription_plan,
  subscription_status = EXCLUDED.subscription_status,
  updated_at = now();

-- Assign user role
INSERT INTO public.user_roles (user_id, role)
VALUES ('00000000-0000-0000-0000-000000000001'::uuid, 'user')
ON CONFLICT (user_id, role) DO NOTHING;

-- Select PUDO location for user
INSERT INTO public.users_correos_dropping (
  user_id,
  unidad_codigo,
  tipo_unidad,
  direccion,
  localidad,
  provincia,
  codigo_postal,
  latitud,
  longitud,
  horarios,
  created_at,
  updated_at
)
VALUES (
  '00000000-0000-0000-0000-000000000001'::uuid,
  'TEST001',
  'CITYPAQ',
  'Plaza Mayor, 1',
  'Madrid',
  'Madrid',
  '28001',
  40.4168,
  -3.7038,
  'L-V: 09:00-21:00, S: 10:00-14:00',
  now(),
  now()
)
ON CONFLICT (user_id) DO UPDATE SET
  unidad_codigo = EXCLUDED.unidad_codigo,
  updated_at = now();

-- Verify creation
SELECT 
  u.id,
  u.email,
  u.full_name,
  u.subscription_plan,
  u.subscription_status,
  ur.role,
  ucd.unidad_codigo as pudo_code
FROM public.users u
LEFT JOIN public.user_roles ur ON ur.user_id = u.id
LEFT JOIN public.users_correos_dropping ucd ON ucd.user_id = u.id
WHERE u.email = 'test.user@brickshare.com';