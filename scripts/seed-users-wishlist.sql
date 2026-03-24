-- Script para insertar usuarios, roles y wishlist desde seed.sql
-- Ejecuta este script DESPUÉS de tener la base de datos inicializada

BEGIN;

-- 1. Crear usuarios en auth.users (necesario para foreign keys)
-- Contraseña por defecto: "password123" (bcrypt hash)
INSERT INTO auth.users (
  id,
  instance_id,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_app_meta_data,
  raw_user_meta_data,
  is_super_admin,
  role,
  aud,
  confirmation_token,
  recovery_token,
  email_change_token_new,
  email_change
) VALUES 
(
  '490961d7-c037-46cc-b4a4-8ab1f98a70c1',
  '00000000-0000-0000-0000-000000000000',
  'enriquepeto@yahoo.es',
  '$2a$10$8P6fZQqKqN5UVCw0P5yVDOzDH9S/6JNjLw6gVqxCN3qF.5U5w5bGC', -- password123
  NOW(),
  '2026-03-23 20:04:50.724775+00',
  '2026-03-23 20:05:52.225346+00',
  '{"provider":"email","providers":["email"]}',
  '{"full_name":"enrique perez"}',
  false,
  'authenticated',
  'authenticated',
  '',
  '',
  '',
  ''
),
(
  'e2d1f7aa-04f5-4d3d-b68b-65e5abdeaada',
  '00000000-0000-0000-0000-000000000000',
  'admin@brickshare.com',
  '$2a$10$8P6fZQqKqN5UVCw0P5yVDOzDH9S/6JNjLw6gVqxCN3qF.5U5w5bGC', -- password123
  NOW(),
  '2026-03-23 20:06:12.826352+00',
  '2026-03-23 20:06:12.826352+00',
  '{"provider":"email","providers":["email"]}',
  '{"full_name":"admin"}',
  false,
  'authenticated',
  'authenticated',
  '',
  '',
  '',
  ''
)
ON CONFLICT (id) DO NOTHING;

-- 2. Crear identities en auth.identities
INSERT INTO auth.identities (
  provider_id,
  user_id,
  identity_data,
  provider,
  last_sign_in_at,
  created_at,
  updated_at
) VALUES
(
  '490961d7-c037-46cc-b4a4-8ab1f98a70c1',
  '490961d7-c037-46cc-b4a4-8ab1f98a70c1',
  '{"sub":"490961d7-c037-46cc-b4a4-8ab1f98a70c1","email":"enriquepeto@yahoo.es"}',
  'email',
  NOW(),
  '2026-03-23 20:04:50.724775+00',
  '2026-03-23 20:04:50.724775+00'
),
(
  'e2d1f7aa-04f5-4d3d-b68b-65e5abdeaada',
  'e2d1f7aa-04f5-4d3d-b68b-65e5abdeaada',
  '{"sub":"e2d1f7aa-04f5-4d3d-b68b-65e5abdeaada","email":"admin@brickshare.com"}',
  'email',
  NOW(),
  '2026-03-23 20:06:12.826352+00',
  '2026-03-23 20:06:12.826352+00'
)
ON CONFLICT (provider_id, provider) DO NOTHING;

-- 3. Insertar sets necesarios para la wishlist
INSERT INTO public.sets (id, set_name, set_description, set_image_url, set_theme, set_age_range, set_piece_count, skill_boost, created_at, updated_at, year_released, catalogue_visibility, set_ref, set_weight, set_minifigs, set_status, set_price, current_value_new, current_value_used, set_pvp_release, set_subtheme, barcode_upc, barcode_ean) VALUES 
('05530a58-cc6e-40ea-942e-647e1d4cd871', 'Volcano Jackhammer', 'LEGO City volcano exploration vehicle with jackhammer equipment.', 'https://cdn.rebrickable.com/media/sets/30350-1/33660.jpg', 'City', '5-12', 53, NULL, '2026-03-23 20:10:54.063462+00', '2026-03-23 20:10:54.063462+00', 2016, true, '30350', 75, 1, 'active', 100.00, NULL, NULL, NULL, NULL, NULL, NULL),
('852e09c2-a509-45b8-b7f4-503fa3c80860', 'Clone Turbo Tank', 'LEGO Star Wars mini Clone Turbo Tank from The Clone Wars era.', 'https://cdn.rebrickable.com/media/sets/20006-1/233.jpg', 'Star Wars', '7-14', 64, NULL, '2026-03-23 20:10:54.064261+00', '2026-03-23 20:10:54.064261+00', 2008, true, '20006', 90, 0, 'active', 110.00, NULL, NULL, NULL, NULL, NULL, NULL),
('0bf4aeea-ab63-4f39-b211-02fd6d0e6356', 'AT-TE Walker', 'LEGO Star Wars mini All Terrain Tactical Enforcer walker.', 'https://cdn.rebrickable.com/media/sets/20009-1/120124.jpg', 'Star Wars', '7-14', 94, NULL, '2026-03-23 20:10:54.06578+00', '2026-03-23 20:10:54.06578+00', 2009, true, '20009', 125, 0, 'active', 130.00, NULL, NULL, NULL, NULL, NULL, NULL),
('d83d8625-7c5a-493c-a10a-311cecd14ea5', 'Willis Tower', 'LEGO Architecture Willis Tower (formerly Sears Tower) - rebranded version.', 'https://cdn.rebrickable.com/media/sets/21000-2/15213.jpg', 'Architecture', '12+', 69, NULL, '2026-03-23 20:10:54.075239+00', '2026-03-23 20:10:54.075239+00', 2011, true, '21000-2', 95, 0, 'active', 110.00, NULL, NULL, NULL, NULL, NULL, NULL),
('5df2a912-a915-40e3-b17a-6c1e57a93994', 'John Hancock Center', 'LEGO Architecture John Hancock Center - official Architecture series model.', 'https://cdn.rebrickable.com/media/sets/21001-1/17482.jpg', 'Architecture', '12+', 72, NULL, '2026-03-23 20:10:54.076368+00', '2026-03-23 20:10:54.076368+00', 2008, true, '21001', 100, 0, 'active', 115.00, NULL, NULL, NULL, NULL, NULL, NULL)
ON CONFLICT (id) DO NOTHING;

-- 4. Insertar datos en public.users
INSERT INTO public.users (id, user_id, full_name, avatar_url, impact_points, created_at, updated_at, email, subscription_type, subscription_status, profile_completed, user_status, stripe_customer_id, referral_code, referred_by, referral_credits, address, address_extra, zip_code, city, province, phone) VALUES 
('650aaad7-f50a-4a1a-a804-285e7c8010a3', '490961d7-c037-46cc-b4a4-8ab1f98a70c1', 'enrique perez', NULL, 0, '2026-03-23 20:04:50.724775+00', '2026-03-23 20:05:52.225346+00', 'enriquepeto@yahoo.es', 'Brick Master', 'active', true, 'no_set', NULL, '63DA33', NULL, 0, 'josep tarradellas 97-101', NULL, '08029', 'Barcelona', NULL, '123456789'),
('2d5152a3-3b28-49c5-8539-1ca8d358715a', 'e2d1f7aa-04f5-4d3d-b68b-65e5abdeaada', 'admin', NULL, 0, '2026-03-23 20:06:12.826352+00', '2026-03-23 20:06:12.826352+00', 'admin@brickshare.com', NULL, 'inactive', false, 'no_set', NULL, '7A8B38', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL)
ON CONFLICT (user_id) DO NOTHING;

-- 5. Insertar roles
INSERT INTO public.user_roles (id, user_id, role, created_at) VALUES 
('b34840c4-645e-46e6-a8c9-eb5ba25b8f9f', '490961d7-c037-46cc-b4a4-8ab1f98a70c1', 'user', '2026-03-23 20:04:50.724775+00'),
('16ec129a-cfd9-4c6c-b8e5-fdd484c5a994', 'e2d1f7aa-04f5-4d3d-b68b-65e5abdeaada', 'admin', '2026-03-23 20:06:12.826352+00')
ON CONFLICT (user_id, role) DO NOTHING;

-- 6. Insertar wishlist
INSERT INTO public.wishlist (id, user_id, set_id, created_at, status, status_changed_at) VALUES 
('1160a8a3-3f54-4306-9a15-d6ad5662b05f', '490961d7-c037-46cc-b4a4-8ab1f98a70c1', '5df2a912-a915-40e3-b17a-6c1e57a93994', '2026-03-23 20:11:21.323092+00', true, '2026-03-23 20:11:21.281+00'),
('6f01032f-e86d-41cb-a507-41f85ed7089f', '490961d7-c037-46cc-b4a4-8ab1f98a70c1', 'd83d8625-7c5a-493c-a10a-311cecd14ea5', '2026-03-23 20:11:22.44018+00', true, '2026-03-23 20:11:22.406+00'),
('05e8dacf-8ecd-4e08-923e-a6ad0d0b92f7', '490961d7-c037-46cc-b4a4-8ab1f98a70c1', '05530a58-cc6e-40ea-942e-647e1d4cd871', '2026-03-23 20:11:30.70373+00', true, '2026-03-23 20:11:30.669+00'),
('0def2835-b2a8-473a-ac6b-8c8326e3137e', '490961d7-c037-46cc-b4a4-8ab1f98a70c1', '852e09c2-a509-45b8-b7f4-503fa3c80860', '2026-03-23 20:11:31.756823+00', true, '2026-03-23 20:11:31.723+00'),
('dc3a8a57-143c-44fd-a02a-dbbcb51870df', '490961d7-c037-46cc-b4a4-8ab1f98a70c1', '0bf4aeea-ab63-4f39-b211-02fd6d0e6356', '2026-03-23 20:11:34.414942+00', true, '2026-03-23 20:11:34.377+00')
ON CONFLICT (user_id, set_id) DO NOTHING;

COMMIT;

-- Verificación
SELECT 'Usuarios en auth.users:' as info;
SELECT id, email FROM auth.users WHERE id IN ('490961d7-c037-46cc-b4a4-8ab1f98a70c1', 'e2d1f7aa-04f5-4d3d-b68b-65e5abdeaada');

SELECT 'Usuarios en public.users:' as info;
SELECT id, user_id, full_name, email FROM public.users WHERE user_id IN ('490961d7-c037-46cc-b4a4-8ab1f98a70c1', 'e2d1f7aa-04f5-4d3d-b68b-65e5abdeaada');

SELECT 'Roles:' as info;
SELECT id, user_id, role FROM public.user_roles WHERE user_id IN ('490961d7-c037-46cc-b4a4-8ab1f98a70c1', 'e2d1f7aa-04f5-4d3d-b68b-65e5abdeaada');

SELECT 'Wishlist:' as info;
SELECT w.id, u.email, s.set_ref, s.set_name 
FROM public.wishlist w
JOIN public.users u ON w.user_id = u.user_id
JOIN public.sets s ON w.set_id = s.id
WHERE w.user_id = '490961d7-c037-46cc-b4a4-8ab1f98a70c1';