-- Create E2E admin user for testing
-- Email: admin@brickshare.test
-- Password: test123456

-- 1. Create auth user
INSERT INTO auth.users (
  id,
  instance_id,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
)
VALUES (
  '00000000-0000-0000-0000-000000000001', -- Fixed UUID for admin
  '00000000-0000-0000-0000-000000000000',
  'admin@brickshare.test',
  crypt('test123456', gen_salt('bf')),
  now(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name":"Admin Test"}',
  now(),
  now(),
  '',
  '',
  '',
  ''
)
ON CONFLICT (id) DO UPDATE
SET
  email = EXCLUDED.email,
  encrypted_password = EXCLUDED.encrypted_password,
  email_confirmed_at = EXCLUDED.email_confirmed_at;

-- 2. Create public.users entry (user_id is the FK to auth.users)
INSERT INTO public.users (
  user_id,
  email,
  full_name,
  phone,
  address,
  zip_code,
  city,
  subscription_status,
  stripe_customer_id,
  created_at,
  updated_at
)
VALUES (
  '00000000-0000-0000-0000-000000000001',
  'admin@brickshare.test',
  'Admin Test',
  '+34600000001',
  'Calle Admin 1',
  '28001',
  'Madrid',
  'active',
  'cus_test_admin',
  now(),
  now()
)
ON CONFLICT (user_id) DO UPDATE
SET
  email = EXCLUDED.email,
  full_name = EXCLUDED.full_name;

-- 3. Assign admin role
INSERT INTO public.user_roles (user_id, role)
VALUES ('00000000-0000-0000-0000-000000000001', 'admin'::app_role)
ON CONFLICT (user_id, role) DO NOTHING;

-- Verify
SELECT 
  u.email,
  u.full_name,
  ur.role,
  u.subscription_status
FROM public.users u
LEFT JOIN public.user_roles ur ON u.id = ur.user_id
WHERE u.email = 'admin@brickshare.test';