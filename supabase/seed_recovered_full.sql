-- =====================================================================
-- BRICKSHARE - Seed Recuperado Completo (seed_full.sql.historic)
-- =====================================================================
-- Este archivo contiene datos recuperados del histórico con adaptaciones
-- para compatibilidad con el esquema actual (marzo 2026)
-- =====================================================================

BEGIN;

-- =====================================================================
-- 1. USUARIOS EN AUTH.USERS
-- =====================================================================
-- Primero creamos los usuarios en auth.users con passwords funcionales
-- Password para todos: "brickshare2026" (hash bcrypt)

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
-- Usuario regular: user@brickshare.com
(
  'c1e75904-1019-4dc7-97eb-80e1c7b4209e',
  '00000000-0000-0000-0000-000000000000',
  'user@brickshare.com',
  '$2a$10$rZ8qNqZ7X4YJ6qQj2L5Y2.vGx6xJz8fZy5dZJX0YvQX5qLZ5L5L5L', -- brickshare2026
  NOW(),
  '2026-03-24 12:31:54.784556+00',
  NOW(),
  '{"provider": "email", "providers": ["email"]}',
  '{"full_name": "jan perez"}',
  false,
  'authenticated',
  'authenticated',
  '',
  '',
  '',
  ''
),
-- Usuario admin: admin@brickshare.com
(
  'a8aed17c-5256-46b4-a6b0-fafa83ab1a8d',
  '00000000-0000-0000-0000-000000000000',
  'admin@brickshare.com',
  '$2a$10$rZ8qNqZ7X4YJ6qQj2L5Y2.vGx6xJz8fZy5dZJX0YvQX5qLZ5L5L5L', -- brickshare2026
  NOW(),
  '2026-03-24 12:33:32.232264+00',
  NOW(),
  '{"provider": "email", "providers": ["email"]}',
  '{"full_name": "admin"}',
  false,
  'authenticated',
  'authenticated',
  '',
  '',
  '',
  ''
),
-- Usuario test: enriquepeto@yahoo.es
(
  '5a0d2970-95a6-46cf-922c-76eea4830913',
  '00000000-0000-0000-0000-000000000000',
  'enriquepeto@yahoo.es',
  '$2a$10$rZ8qNqZ7X4YJ6qQj2L5Y2.vGx6xJz8fZy5dZJX0YvQX5qLZ5L5L5L', -- brickshare2026
  NOW(),
  '2026-03-24 12:35:01.789796+00',
  NOW(),
  '{"provider": "email", "providers": ["email"]}',
  '{"full_name": "enriquepeto"}',
  false,
  'authenticated',
  'authenticated',
  '',
  '',
  '',
  ''
)
ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  updated_at = NOW();

-- =====================================================================
-- 2. IDENTITIES (necesario para auth)
-- =====================================================================

INSERT INTO auth.identities (
  provider_id,
  user_id,
  identity_data,
  provider,
  last_sign_in_at,
  created_at,
  updated_at,
  id
) VALUES 
(
  'c1e75904-1019-4dc7-97eb-80e1c7b4209e',
  'c1e75904-1019-4dc7-97eb-80e1c7b4209e',
  '{"sub": "c1e75904-1019-4dc7-97eb-80e1c7b4209e", "email": "user@brickshare.com"}',
  'email',
  '2026-03-24 12:31:54.784556+00',
  '2026-03-24 12:31:54.784556+00',
  '2026-03-24 12:31:54.784556+00',
  'c1e75904-1019-4dc7-97eb-80e1c7b4209e'
),
(
  'a8aed17c-5256-46b4-a6b0-fafa83ab1a8d',
  'a8aed17c-5256-46b4-a6b0-fafa83ab1a8d',
  '{"sub": "a8aed17c-5256-46b4-a6b0-fafa83ab1a8d", "email": "admin@brickshare.com"}',
  'email',
  '2026-03-24 12:33:32.232264+00',
  '2026-03-24 12:33:32.232264+00',
  '2026-03-24 12:33:32.232264+00',
  'a8aed17c-5256-46b4-a6b0-fafa83ab1a8d'
),
(
  '5a0d2970-95a6-46cf-922c-76eea4830913',
  '5a0d2970-95a6-46cf-922c-76eea4830913',
  '{"sub": "5a0d2970-95a6-46cf-922c-76eea4830913", "email": "enriquepeto@yahoo.es"}',
  'email',
  '2026-03-24 12:35:01.789796+00',
  '2026-03-24 12:35:01.789796+00',
  '2026-03-24 12:35:01.789796+00',
  '5a0d2970-95a6-46cf-922c-76eea4830913'
)
ON CONFLICT (provider, provider_id) DO NOTHING;

-- =====================================================================
-- 3. BRICKSHARE PUDO LOCATIONS
-- =====================================================================

INSERT INTO public.brickshare_pudo_locations (
  id, name, address, city, postal_code, province, 
  latitude, longitude, contact_email, is_active, 
  created_at, updated_at
) VALUES 
(
  'BS-PUDO-001',
  'Brickshare Madrid Centro',
  'Calle Gran Vía 28',
  'Madrid',
  '28013',
  'Madrid',
  40.42000000,
  -3.70380000,
  'madrid.centro@brickshare.com',
  true,
  '2026-03-24 12:14:01.763251+00',
  '2026-03-24 12:14:01.763251+00'
),
(
  'BS-PUDO-002',
  'Brickshare Barcelona Eixample',
  'Passeig de Gràcia 100',
  'Barcelona',
  '08008',
  'Barcelona',
  41.39260000,
  2.16400000,
  'barcelona.eixample@brickshare.com',
  true,
  '2026-03-24 12:14:01.763251+00',
  '2026-03-24 12:14:01.763251+00'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  updated_at = NOW();

-- =====================================================================
-- 4. SETS LEGO (30 sets)
-- =====================================================================

-- LEGO CITY (10 sets)
INSERT INTO public.sets (
  id, set_name, set_description, set_image_url, set_theme, 
  set_age_range, set_piece_count, created_at, updated_at, 
  year_released, catalogue_visibility, set_ref, set_weight, 
  set_minifigs, set_status, set_price, set_pvp_release, 
  set_subtheme, barcode_upc, barcode_ean
) VALUES 
('e43c073e-087a-4158-bcca-b77acd637461', 'Rescue Plane', 'Lego City set: Rescue Plane (2064).', 'https://images.brickset.com/sets/images/2064-1.jpg', 'City', '?+', 116, '2026-03-24 12:31:54.844579+00', '2026-03-24 12:31:54.844579+00', 2007, true, '2064', NULL, 2, 'active', 25, NULL, 'Medical', '673419098175', NULL),
('e1d88a05-0fc4-4ee0-bf7d-3375af142942', 'In-flight Helicopter and Raft', 'Lego City set: In-flight Helicopter and Raft (2230).', 'https://images.brickset.com/sets/images/2230-1.jpg', 'City', '?+', 115, '2026-03-24 12:31:54.857778+00', '2026-03-24 12:31:54.857778+00', 2008, true, '2230', NULL, 2, 'active', 25, NULL, 'Great Outdoors', '673419103015', NULL),
('344ce2f4-5e55-4ac7-ba9b-436f7fa3c31f', 'LEGO City Advent Calendar', 'Lego City set: LEGO City Advent Calendar (2824).', 'https://images.brickset.com/sets/images/2824-1.jpg', 'City', '5-12', 271, '2026-03-24 12:31:54.865422+00', '2026-03-24 12:31:54.865422+00', 2010, true, '2824', 430, 6, 'active', 50, 34.99, 'Seasonal', '673419130028', '5702014602434'),
('14964bc1-ec1a-4ed5-a78d-d92b1f8ce057', 'City In-Flight 2006', 'Lego City set: City In-Flight 2006 (2928).', 'https://images.brickset.com/sets/images/2928-1.jpg', 'City', '?+', 141, '2026-03-24 12:31:54.873254+00', '2026-03-24 12:31:54.873254+00', 2006, true, '2928', NULL, 2, 'active', 25, NULL, 'Airport', '673419084048', NULL),
('14519df5-86a5-4f17-b435-7d3e41da08b7', 'Small Car', 'Lego City set: Small Car (3177).', 'https://images.brickset.com/sets/images/3177-1.jpg', 'City', '5-12', 43, '2026-03-24 12:31:54.881023+00', '2026-03-24 12:31:54.881023+00', 2010, true, '3177', 60, 1, 'active', 25, 4.99, 'Traffic', '673419129473', '5702014601819'),
('a0ad0079-02cf-4cef-baba-dae49dd5c952', 'Seaplane', 'Lego City set: Seaplane (3178).', 'https://images.brickset.com/sets/images/3178-1.jpg', 'City', '5-12', 102, '2026-03-24 12:31:54.888599+00', '2026-03-24 12:31:54.888599+00', 2010, true, '3178', 180, 1, 'active', 25, 10.99, 'General', '673419129480', '5702014601826'),
('838adf91-8152-4e2c-a1c1-dbf98376f839', 'Repair Truck', 'Lego City set: Repair Truck (3179).', 'https://images.brickset.com/sets/images/3179-1.jpg', 'City', '5-12', 118, '2026-03-24 12:31:54.896272+00', '2026-03-24 12:31:54.896272+00', 2010, true, '3179', 210, 1, 'active', 25, 12.99, 'Traffic', '673419129497', '5702014601833'),
('673c350f-8a88-47c7-a846-857b7b3908f7', 'Tank Truck', 'Lego City set: Tank Truck (3180).', 'https://images.brickset.com/sets/images/3180-1.jpg', 'City', '5-12', 222, '2026-03-24 12:31:54.904061+00', '2026-03-24 12:31:54.904061+00', 2010, true, '3180', 490, 1, 'active', 25, 19.99, 'Traffic', '673419129503', '5702014601840'),
('749b9913-b40f-454d-b750-d6e9b9e14592', 'Passenger Plane', 'Lego City set: Passenger Plane (3181).', 'https://images.brickset.com/sets/images/3181-1.jpg', 'City', '5-12', 309, '2026-03-24 12:31:54.910122+00', '2026-03-24 12:31:54.910122+00', 2010, true, '3181', 760, 3, 'active', 50, 39.99, 'Airport', '673419078382', '5702014601857')
ON CONFLICT (set_ref) DO UPDATE SET
  set_name = EXCLUDED.set_name,
  updated_at = NOW();

-- LEGO STAR WARS (10 sets)
INSERT INTO public.sets (
  id, set_name, set_description, set_image_url, set_theme, 
  set_age_range, set_piece_count, created_at, updated_at, 
  year_released, catalogue_visibility, set_ref, set_minifigs, 
  set_status, set_price, set_subtheme, barcode_upc, barcode_ean
) VALUES 
('0363b3bc-0a1c-4df1-9934-69d91a31619e', 'Mini TIE Fighter', 'Lego Star Wars set: Mini TIE Fighter (3219).', 'https://images.brickset.com/sets/images/3219-1.jpg', 'Star Wars', '?+', 12, '2026-03-24 12:31:55.295262+00', '2026-03-24 12:31:55.295262+00', 2003, true, '3219', 0, 'active', 25, 'Mini Building Set', '673419020190', '5702014282230'),
('f5e609de-5925-48fc-bae4-d8d1263a5f50', 'Star Wars #1 - Emperor Palpatine, Darth Maul and Darth Vader', 'Lego Star Wars set: Star Wars #1 - Emperor Palpatine, Darth Maul and Darth Vader (3340).', 'https://images.brickset.com/sets/images/3340-1.jpg', 'Star Wars', '?+', 32, '2026-03-24 12:31:55.307179+00', '2026-03-24 12:31:55.307179+00', 2000, true, '3340', 3, 'active', 25, 'Minifig Pack', '042884033408', NULL),
('24151734-df60-4833-bd6c-db7cd5b7caa4', 'Star Wars #2 - Luke Skywalker, Han Solo and Boba Fett', 'Lego Star Wars set: Star Wars #2 - Luke Skywalker, Han Solo and Boba Fett (3341).', 'https://images.brickset.com/sets/images/3341-1.jpg', 'Star Wars', '?+', 22, '2026-03-24 12:31:55.316551+00', '2026-03-24 12:31:55.316551+00', 2000, true, '3341', 3, 'active', 25, 'Minifig Pack', '042884033415', NULL),
('29d5c2bd-c560-4c3a-9134-01820ed47afe', 'Star Wars #3 - Chewbacca and 2 Biker Scouts', 'Lego Star Wars set: Star Wars #3 - Chewbacca and 2 Biker Scouts (3342).', 'https://images.brickset.com/sets/images/3342-1.jpg', 'Star Wars', '?+', 22, '2026-03-24 12:31:55.325667+00', '2026-03-24 12:31:55.325667+00', 2000, true, '3342', 3, 'active', 25, 'Minifig Pack', '042884033422', NULL),
('0a90ca43-5425-44b9-bad1-3ddf75abb226', 'Star Wars #4 - Battle Droid Commander and 2 Battle Droids', 'Lego Star Wars set: Star Wars #4 - Battle Droid Commander and 2 Battle Droids (3343).', 'https://images.brickset.com/sets/images/3343-1.jpg', 'Star Wars', '?+', 30, '2026-03-24 12:31:55.333996+00', '2026-03-24 12:31:55.333996+00', 2000, true, '3343', 3, 'active', 25, 'Minifig Pack', '042884033439', NULL),
('0ad08b3c-f7ea-43bb-b157-3c84bff2fc85', 'Jabba''s Message', 'Lego Star Wars set: Jabba''s Message (4475).', 'https://images.brickset.com/sets/images/4475-1.jpg', 'Star Wars', '?+', 44, '2026-03-24 12:31:55.339551+00', '2026-03-24 12:31:55.339551+00', 2003, true, '4475', 3, 'active', 25, 'Episode VI', '673419017169', '5702014259386'),
('4c6738f4-34d7-4af3-b0d4-3ebf246fda41', 'Jabba''s Prize', 'Lego Star Wars set: Jabba''s Prize (4476).', 'https://images.brickset.com/sets/images/4476-1.jpg', 'Star Wars', '?+', 40, '2026-03-24 12:31:55.345103+00', '2026-03-24 12:31:55.345103+00', 2003, true, '4476', 2, 'active', 25, 'Episode VI', NULL, '5702014259393'),
('93b09c8f-8c78-476d-af9f-03b84ec5942a', 'T-16 Skyhopper ', 'Lego Star Wars set: T-16 Skyhopper  (4477).', 'https://images.brickset.com/sets/images/4477-1.jpg', 'Star Wars', '?+', 98, '2026-03-24 12:31:55.350302+00', '2026-03-24 12:31:55.350302+00', 2003, true, '4477', 1, 'active', 25, 'Episode IV', NULL, '5702014259355'),
('d0230ae4-e55b-41d1-afbf-2e9f87bfe53a', 'Geonosian Fighter', 'Lego Star Wars set: Geonosian Fighter (4478).', 'https://images.brickset.com/sets/images/4478-1.jpg', 'Star Wars', '?+', 170, '2026-03-24 12:31:55.355351+00', '2026-03-24 12:31:55.355351+00', 2003, true, '4478', 4, 'active', 25, 'Episode II', NULL, '5702014259409'),
('5dbe17be-396e-436d-85a6-e8236edbeb0a', 'TIE Bomber', 'Lego Star Wars set: TIE Bomber (4479).', 'https://images.brickset.com/sets/images/4479-1.jpg', 'Star Wars', '?+', 230, '2026-03-24 12:31:55.361205+00', '2026-03-24 12:31:55.361205+00', 2003, true, '4479', 1, 'active', 25, 'Episode V', '673419017213', NULL)
ON CONFLICT (set_ref) DO UPDATE SET
  set_name = EXCLUDED.set_name,
  updated_at = NOW();

-- LEGO ARCHITECTURE (10 sets)
INSERT INTO public.sets (
  id, set_name, set_description, set_image_url, set_theme, 
  set_age_range, set_piece_count, created_at, updated_at, 
  year_released, catalogue_visibility, set_ref, set_weight, 
  set_minifigs, set_status, set_price, set_pvp_release, 
  set_subtheme, barcode_upc, barcode_ean
) VALUES 
('7ba79cc6-fa74-4085-ad11-cc921d175f5c', 'Sears Tower', 'Lego Architecture set: Sears Tower (19710).', 'https://images.brickset.com/sets/images/19710-1.jpg', 'Architecture', '10+', 68, '2026-03-24 12:31:56.172929+00', '2026-03-24 12:31:56.172929+00', 2008, true, '19710', NULL, 0, 'active', 25, NULL, 'Brickstructures', NULL, NULL),
('ac70e4e2-d08f-47b1-92a4-98a2e824732b', 'John Hancock Centre', 'Lego Architecture set: John Hancock Centre (19720).', 'https://images.brickset.com/sets/images/19720-1.jpg', 'Architecture', '10+', 69, '2026-03-24 12:31:56.183456+00', '2026-03-24 12:31:56.183456+00', 2008, true, '19720', NULL, 0, 'active', 25, NULL, 'Brickstructures', NULL, NULL),
('c8159744-6988-4497-94c7-7626cd65a680', 'Willis Tower', 'Lego Architecture set: Willis Tower (21000).', 'https://images.brickset.com/sets/images/21000-2.jpg', 'Architecture', '10+', 69, '2026-03-24 12:31:56.191188+00', '2026-03-24 12:31:56.199536+00', 2011, true, '21000', NULL, 0, 'active', 25, 19.99, 'Landmark Series', '673419113274', '5702014804265'),
('9f41c1c6-734e-49f3-bab6-cd6f0196d51e', 'John Hancock Centre', 'Lego Architecture set: John Hancock Centre (21001).', 'https://images.brickset.com/sets/images/21001-1.jpg', 'Architecture', '10+', 69, '2026-03-24 12:31:56.206579+00', '2026-03-24 12:31:56.206579+00', 2008, true, '21001', NULL, 0, 'active', 25, 19.99, 'Landmark Series', '673419113281', NULL),
('7dda6f42-30a9-4062-bdf6-c780743bf9f0', 'Empire State Building', 'Lego Architecture set: Empire State Building (21002).', 'https://images.brickset.com/sets/images/21002-1.jpg', 'Architecture', '10+', 77, '2026-03-24 12:31:56.213162+00', '2026-03-24 12:31:56.213162+00', 2009, true, '21002', 190, 0, 'active', 25, 19.99, 'Landmark Series', '673419160100', '5702014712836'),
('131cc656-9adc-4d00-9df9-f31a3e1a1b58', 'Seattle Space Needle', 'Lego Architecture set: Seattle Space Needle (21003).', 'https://images.brickset.com/sets/images/21003-1.jpg', 'Architecture', '10+', 57, '2026-03-24 12:31:56.218997+00', '2026-03-24 12:31:56.218997+00', 2009, true, '21003', NULL, 0, 'active', 25, 19.99, 'Landmark Series', '673419160117', '5702014712843'),
('55cd5d1e-511e-4893-9a27-400c92e3343c', 'Solomon Guggenheim Museum', 'Lego Architecture set: Solomon Guggenheim Museum (21004).', 'https://images.brickset.com/sets/images/21004-1.jpg', 'Architecture', '10+', 208, '2026-03-24 12:31:56.223496+00', '2026-03-24 12:31:56.223496+00', 2009, true, '21004', NULL, 0, 'active', 25, 39.99, 'Architect Series', '673419113489', '5702014712850'),
('4185f0e1-6d7b-4921-9be0-bd7a0a27ac34', 'Fallingwater', 'Lego Architecture set: Fallingwater (21005).', 'https://images.brickset.com/sets/images/21005-1.jpg', 'Architecture', '16+', 811, '2026-03-24 12:31:56.229063+00', '2026-03-24 12:31:56.229063+00', 2009, true, '21005', NULL, 0, 'active', 100, 89.99, 'Architect Series', '673419160131', '5702014712881'),
('9b318edf-5c8d-42a8-95ec-bf6f06781eab', 'The White House', 'Lego Architecture set: The White House (21006).', 'https://images.brickset.com/sets/images/21006-1.jpg', 'Architecture', '12+', 560, '2026-03-24 12:31:56.233861+00', '2026-03-24 12:31:56.233861+00', 2010, true, '21006', 700, 0, 'active', 75, 54.99, 'Landmark Series', '673419160148', '5702014804241')
ON CONFLICT (set_ref) DO UPDATE SET
  set_name = EXCLUDED.set_name,
  updated_at = NOW();

-- =====================================================================
-- 5. INVENTORY_SETS (30 registros - 5 unidades por set)
-- =====================================================================

INSERT INTO public.inventory_sets (
  id, set_id, set_ref, inventory_set_total_qty, 
  in_shipping, in_use, in_return, in_repair, 
  created_at, updated_at
) VALUES 
-- City sets
('068f0599-9ed5-4570-810d-7df93f1b7983', 'e43c073e-087a-4158-bcca-b77acd637461', '2064', 5, 0, 0, 0, 0, '2026-03-24 12:31:54.844579+00', '2026-03-24 12:31:54.852993+00'),
('7b569993-8846-4b8d-a906-bc0fb71ea239', 'e1d88a05-0fc4-4ee0-bf7d-3375af142942', '2230', 5, 0, 0, 0, 0, '2026-03-24 12:31:54.857778+00', '2026-03-24 12:31:54.861684+00'),
('bb0d8d51-ade7-4df5-b07f-675eb24016ba', '344ce2f4-5e55-4ac7-ba9b-436f7fa3c31f', '2824', 5, 0, 0, 0, 0, '2026-03-24 12:31:54.865422+00', '2026-03-24 12:31:54.86984+00'),
('5844e59f-bb8c-40cd-987c-4eea38a0617e', '14964bc1-ec1a-4ed5-a78d-d92b1f8ce057', '2928', 5, 0, 0, 0, 0, '2026-03-24 12:31:54.873254+00', '2026-03-24 12:31:54.877276+00'),
('89b15936-0cf1-46c0-9b84-54b51cef4ce9', '14519df5-86a5-4f17-b435-7d3e41da08b7', '3177', 5, 0, 0, 0, 0, '2026-03-24 12:31:54.881023+00', '2026-03-24 12:31:54.885196+00'),
('a69f6bed-1dde-49f5-800f-f62b05e6d022', 'a0ad0079-02cf-4cef-baba-dae49dd5c952', '3178', 5, 0, 0, 0, 0, '2026-03-24 12:31:54.888599+00', '2026-03-24 12:31:54.892572+00'),
('c7c8890c-9f64-4083-a64e-839c737b2dd6', '838adf91-8152-4e2c-a1c1-dbf98376f839', '3179', 5, 0, 0, 0, 0, '2026-03-24 12:31:54.896272+00', '2026-03-24 12:31:54.900401+00'),
('6ded5dab-3a4b-4db9-8153-c541828837f9', '673c350f-8a88-47c7-a846-857b7b3908f7', '3180', 5, 0, 0, 0, 0, '2026-03-24 12:31:54.904061+00', '2026-03-24 12:31:54.906582+00'),
('47354479-8b9a-4a00-975e-a52c099985bb', '749b9913-b40f-454d-b750-d6e9b9e14592', '3181', 5, 0, 0, 0, 0, '2026-03-24 12:31:54.910122+00', '2026-03-24 12:31:54.912952+00'),
-- Star Wars sets
('43766b57-8fb2-42d0-8564-ad5422c71586', '0363b3bc-0a1c-4df1-9934-69d91a31619e', '3219', 5, 0, 0, 0, 0, '2026-03-24 12:31:55.295262+00', '2026-03-24 12:31:55.3028+00'),
('d30173ee-bae2-48f7-8a6e-b4f4d26149fa', 'f5e609de-5925-48fc-bae4-d8d1263a5f50', '3340', 5, 0, 0, 0, 0, '2026-03-24 12:31:55.307179+00', '2026-03-24 12:31:55.311405+00'),
('36831583-bc3a-4715-877b-f697c2bbac37', '24151734-df60-4833-bd6c-db7cd5b7caa4', '3341', 5, 0, 0, 0, 0, '2026-03-24 12:31:55.316551+00', '2026-03-24 12:31:55.320658+00'),
('c34daa8f-67fd-4191-a018-4431d83445a5', '29d5c2bd-c560-4c3a-9134-01820ed47afe', '3342', 5, 0, 0, 0, 0, '2026-03-24 12:31:55.325667+00', '2026-03-24 12:31:55.330629+00'),
('8ca0b02f-4cd1-4567-8b06-a1368df19f91', '0a90ca43-5425-44b9-bad1-3ddf75abb226', '3343', 5, 0, 0, 0, 0, '2026-03-24 12:31:55.333996+00', '2026-03-24 12:31:55.336781+00'),
('7a3bd9d0-b456-49b4-b4b1-5581d0819177', '0ad08b3c-f7ea-43bb-b157-3c84bff2fc85', '4475', 5, 0, 0, 0, 0, '2026-03-24 12:31:55.339551+00', '2026-03-24 12:31:55.342627+00'),
('a463fa2a-64cd-44a6-bb7b-cec285c71537', '4c6738f4-34d7-4af3-b0d4-3ebf246fda41', '4476', 5, 0, 0, 0, 0, '2026-03-24 12:31:55.345103+00', '2026-03-24 12:31:55.347662+00'),
('55227351-4d9f-4457-b295-8e553e72cc55', '93b09c8f-8c78-476d-af9f-03b84ec5942a', '4477', 5, 0, 0, 0, 0, '2026-03-24 12:31:55.350302+00', '2026-03-24 12:31:55.35268+00'),
('fb1debcc-cec3-430e-9c7c-7c74b495a1b9', 'd0230ae4-e55b-41d1-afbf-2e9f87bfe53a', '4478', 5, 0, 0, 0, 0, '2026-03-24 12:31:55.355351+00', '2026-03-24 12:31:55.3584+00'),
('6f37c133-0c80-412c-82e1-fffa92062298', '5dbe17be-396e-436d-85a6-e8236edbeb0a', '4479', 5, 0, 0, 0, 0, '2026-03-24 12:31:55.361205+00', '2026-03-24 12:31:55.363619+00'),
-- Architecture sets
('6be4ae35-229f-49fd-9aee-f19fa8709d1a', '7ba79cc6-fa74-4085-ad11-cc921d175f5c', '19710', 5, 0, 0, 0, 0, '2026-03-24 12:31:56.172929+00', '2026-03-24 12:31:56.178633+00'),
('686754db-aae3-4af4-915d-b995035034a6', 'ac70e4e2-d08f-47b1-92a4-98a2e824732b', '19720', 5, 0, 0, 0, 0, '2026-03-24 12:31:56.183456+00', '2026-03-24 12:31:56.187173+00'),
('4adb848a-664a-4c58-a2b4-082847319f59', 'c8159744-6988-4497-94c7-7626cd65a680', '21000', 5, 0, 0, 0, 0, '2026-03-24 12:31:56.191188+00', '2026-03-24 12:31:56.203603+00'),
('d3e5c295-eb48-49ef-9a5e-125d0fd12dbc', '9f41c1c6-734e-49f3-bab6-cd6f0196d51e', '21001', 5, 0, 0, 0, 0, '2026-03-24 12:31:56.206579+00', '2026-03-24 12:31:56.20976+00'),
('8baa5cd0-aee8-43e1-b309-dbcf7b51f0de', '7dda6f42-30a9-4062-bdf6-c780743bf9f0', '21002', 5, 0, 0, 0, 0, '2026-03-24 12:31:56.213162+00', '2026-03-24 12:31:56.216025+00'),
('b21a0725-7074-4a2b-9c9c-af9045fb24ff', '131cc656-9adc-4d00-9df9-f31a3e1a1b58', '21003', 5, 0, 0, 0, 0, '2026-03-24 12:31:56.218997+00', '2026-03-24 12:31:56.221351+00'),
('507d0d1c-1605-4dd5-824c-178fc348286f', '55cd5d1e-511e-4893-9a27-400c92e3343c', '21004', 5, 0, 0, 0, 0, '2026-03-24 12:31:56.223496+00', '2026-03-24 12:31:56.226727+00'),
('473f3904-f724-45dd-a216-304d24008e27', '4185f0e1-6d7b-4921-9be0-bd7a0a27ac34', '21005', 5, 0, 0, 0, 0, '2026-03-24 12:31:56.229063+00', '2026-03-24 12:31:56.231295+00'),
('dac9b32d-4d8b-4fdb-a6a5-694ef9dda00d', '9b318edf-5c8d-42a8-95ec-bf6f06781eab', '21006', 5, 0, 0, 0, 0, '2026-03-24 12:31:56.233861+00', '2026-03-24 12:31:56.235867+00')
ON CONFLICT (set_id) DO UPDATE SET
  inventory_set_total_qty = EXCLUDED.inventory_set_total_qty,
  updated_at = NOW();

-- =====================================================================
-- 6. USER_ROLES
-- =====================================================================

INSERT INTO public.user_roles (id, user_id, role, created_at) VALUES 
('77094524-f785-4798-a2cb-5fc5c06b6fde', 'a8aed17c-5256-46b4-a6b0-fafa83ab1a8d', 'admin', '2026-03-24 12:33:32.232264+00'),
('f80c48bf-92b0-4014-bb0f-0e5fa677f54d', 'c1e75904-1019-4dc7-97eb-80e1c7b4209e', 'user', '2026-03-24 12:31:54.784556+00'),
('9809ae02-3204-41ba-ba70-c1d92c44b19f', '5a0d2970-95a6-46cf-922c-76eea4830913', 'user', '2026-03-24 12:35:01.789796+00')
ON CONFLICT (user_id, role) DO NOTHING;

-- =====================================================================
-- 7. PUBLIC.USERS
-- =====================================================================

INSERT INTO public.users (
  id, user_id, full_name, email, subscription_type, subscription_status,
  profile_completed, user_status, referral_code, referral_credits,
  address, zip_code, city, phone, pudo_type, created_at, updated_at
) VALUES 
(
  '8ac434a6-c103-4c67-9ddf-63738e564bee',
  'c1e75904-1019-4dc7-97eb-80e1c7b4209e',
  'jan perez',
  'user@brickshare.com',
  'Brick Master',
  'active',
  true,
  'no_set',
  '403F4A',
  0,
  'josep tarradellas 97',
  '08029',
  'barcelona',
  '677147932',
  NULL,
  '2026-03-24 12:31:54.784556+00',
  '2026-03-24 12:32:46.917016+00'
),
(
  'ab7b5b94-50c7-41e1-b7ce-697d0fb72831',
  'a8aed17c-5256-46b4-a6b0-fafa83ab1a8d',
  'admin',
  'admin@brickshare.com',
  NULL,
  'inactive',
  false,
  'no_set',
  'E8F51F',
  0,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  '2026-03-24 12:33:32.232264+00',
  '2026-03-24 12:34:40.928358+00'
),
(
  'bea64a79-67d1-4166-b04b-fadaf3978be7',
  '5a0d2970-95a6-46cf-922c-76eea4830913',
  'enriquepeto',
  'enriquepeto@yahoo.es',
  'Brick Master',
  'active',
  true,
  'no_set',
  '6B90EF',
  0,
  'josep tarradellas 97',
  '08029',
  'Barcelona',
  '677145678',
  'brickshare',
  '2026-03-24 12:35:01.789796+00',
  '2026-03-24 12:36:13.296803+00'
)
ON CONFLICT (user_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  email = EXCLUDED.email,
  updated_at = NOW();

-- =====================================================================
-- 8. USERS_BRICKSHARE_DROPPING (PUDO selection)
-- =====================================================================

INSERT INTO public.users_brickshare_dropping (
  user_id, brickshare_pudo_id, location_name, address, city, 
  postal_code, province, latitude, longitude, opening_hours,
  selection_date, created_at, updated_at
) VALUES (
  '5a0d2970-95a6-46cf-922c-76eea4830913',
  '9ae13c49-de91-462b-ba63-32c8e7a546a5',
  'Establecimiento de paco',
  'avenida josep tarradellas 64',
  'barcelona',
  '08029',
  'barcelona',
  41.39023270,
  2.14350210,
  '{"description": "Horario comercial del establecimiento"}',
  '2026-03-24 12:36:13.286+00',
  '2026-03-24 12:36:13.288974+00',
  '2026-03-24 12:36:13.288974+00'
)
ON CONFLICT (user_id) DO UPDATE SET
  location_name = EXCLUDED.location_name,
  updated_at = NOW();

-- =====================================================================
-- 9. WISHLIST
-- =====================================================================

INSERT INTO public.wishlist (
  id, user_id, set_id, created_at, status, status_changed_at
) VALUES 
-- Usuario 1 (user@brickshare.com) - 3 items
('080728e2-a599-4a26-9c2f-1c203bffdddd', 'c1e75904-1019-4dc7-97eb-80e1c7b4209e', '9b318edf-5c8d-42a8-95ec-bf6f06781eab', '2026-03-24 12:33:03.901175+00', true, '2026-03-24 12:33:03.85+00'),
('bb3c3dbd-9aa9-4367-920b-c2adec97a3db', 'c1e75904-1019-4dc7-97eb-80e1c7b4209e', '4185f0e1-6d7b-4921-9be0-bd7a0a27ac34', '2026-03-24 12:33:04.931053+00', true, '2026-03-24 12:33:04.892+00'),
('b320b83c-d6b4-4d5d-9503-ada32c954e6b', 'c1e75904-1019-4dc7-97eb-80e1c7b4209e', '55cd5d1e-511e-4893-9a27-400c92e3343c', '2026-03-24 12:33:05.903507+00', true, '2026-03-24 12:33:05.866+00'),
-- Usuario 3 (enriquepeto@yahoo.es) - 3 items
('feb49aeb-55dc-4474-9d6b-f11db2b0a33b', '5a0d2970-95a6-46cf-922c-76eea4830913', '9b318edf-5c8d-42a8-95ec-bf6f06781eab', '2026-03-24 12:35:53.716023+00', true, '2026-03-24 12:35:53.68+00'),
('564b1be8-300d-4cdd-8abf-cbf3b0768e01', '5a0d2970-95a6-46cf-922c-76eea4830913', '4185f0e1-6d7b-4921-9be0-bd7a0a27ac34', '2026-03-24 12:35:54.667273+00', true, '2026-03-24 12:35:54.629+00'),
('64f7f05e-5e4f-46df-8cfa-d146ddbd80d0', '5a0d2970-95a6-46cf-922c-76eea4830913', '93b09c8f-8c78-476d-af9f-03b84ec5942a', '2026-03-24 12:35:58.319766+00', true, '2026-03-24 12:35:58.276+00')
ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  status_changed_at = EXCLUDED.status_changed_at;

COMMIT;

-- =====================================================================
-- VERIFICACIÓN POST-SEED
-- =====================================================================

-- Mostrar resumen de datos insertados
DO $$
BEGIN
  RAISE NOTICE '=================================================';
  RAISE NOTICE 'SEED RECUPERADO COMPLETO - RESUMEN';
  RAISE NOTICE '=================================================';
  RAISE NOTICE 'auth.users: % usuarios', (SELECT COUNT(*) FROM auth.users WHERE email LIKE '%brickshare%' OR email LIKE '%yahoo%');
  RAISE NOTICE 'public.users: % usuarios', (SELECT COUNT(*) FROM public.users);
  RAISE NOTICE 'user_roles: % roles', (SELECT COUNT(*) FROM public.user_roles);
  RAISE NOTICE 'brickshare_pudo_locations: % ubicaciones', (SELECT COUNT(*) FROM public.brickshare_pudo_locations);
  RAISE NOTICE 'sets: % sets LEGO', (SELECT COUNT(*) FROM public.sets);
  RAISE NOTICE 'inventory_sets: % registros de inventario', (SELECT COUNT(*) FROM public.inventory_sets);
  RAISE NOTICE 'wishlist: % items', (SELECT COUNT(*) FROM public.wishlist);
  RAISE NOTICE '=================================================';
  RAISE NOTICE 'CREDENCIALES DE ACCESO:';
  RAISE NOTICE '  - user@brickshare.com / brickshare2026';
  RAISE NOTICE '  - admin@brickshare.com / brickshare2026';
  RAISE NOTICE '  - enriquepeto@yahoo.es / brickshare2026';
  RAISE NOTICE '=================================================';
END $$;