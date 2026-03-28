-- ═══════════════════════════════════════════════════════════════
-- Create E2E Onboarding Test User
-- ═══════════════════════════════════════════════════════════════
-- Creates a clean user for testing the complete onboarding flow
-- State: Email verified, NO subscription, NO PUDO, profile INCOMPLETE
-- ═══════════════════════════════════════════════════════════════

-- Clean up existing user first
DELETE FROM auth.users WHERE email = 'e2e.onboarding@test.com';

-- Create auth user (email already verified for faster tests)
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
  'e2e00000-0000-0000-0000-000000000001'::uuid,
  '00000000-0000-0000-0000-000000000000'::uuid,
  'e2e.onboarding@test.com',
  crypt('TestPassword123!', gen_salt('bf')),
  now(), -- Email already verified
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{}'::jsonb,
  'authenticated',
  'authenticated',
  now(),
  now(),
  '',
  '',
  '',
  ''
);

-- Create MINIMAL user profile (incomplete for onboarding test)
-- Use 'inactive' instead of 'none' to satisfy constraint
INSERT INTO public.users (
  user_id,
  email,
  full_name,
  profile_completed,
  subscription_status,
  created_at,
  updated_at
)
VALUES (
  'e2e00000-0000-0000-0000-000000000001'::uuid,
  'e2e.onboarding@test.com',
  NULL, -- Will be completed during test
  false, -- Profile NOT completed
  'inactive', -- Valid status value
  now(),
  now()
)
ON CONFLICT (user_id) DO UPDATE SET
  email = EXCLUDED.email,
  subscription_status = EXCLUDED.subscription_status,
  updated_at = now();

-- Assign basic user role
INSERT INTO public.user_roles (user_id, role)
VALUES ('e2e00000-0000-0000-0000-000000000001'::uuid, 'user')
ON CONFLICT (user_id, role) DO NOTHING;

-- Verify creation
SELECT 
  u.user_id,
  u.email,
  u.full_name,
  u.profile_completed,
  u.subscription_status,
  ur.role,
  CASE 
    WHEN ucd.user_id IS NOT NULL THEN 'YES'
    ELSE 'NO'
  END as has_pudo
FROM public.users u
LEFT JOIN public.user_roles ur ON ur.user_id = u.user_id
LEFT JOIN public.users_correos_dropping ucd ON ucd.user_id = u.user_id
WHERE u.email = 'e2e.onboarding@test.com';

-- Show available sets for testing
SELECT 
  COUNT(*) as total_sets,
  COUNT(CASE WHEN set_status = 'available' THEN 1 END) as available_sets
FROM public.sets;

-- Show available PUDO points
SELECT COUNT(*) as total_pudo_points
FROM public.brickshare_pudo_locations;