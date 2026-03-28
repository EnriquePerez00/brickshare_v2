--
-- Brickshare Seed File
-- Auto-generated database dump from current instance
-- Contains: users, roles, LEGO sets, inventory, and PUDO locations
-- Generated: 2026-03-26
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.9 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.users DISABLE TRIGGER ALL;

INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) VALUES
('00000000-0000-0000-0000-000000000000', '360aab57-f618-481a-bdca-ca63f5a7c16e', 'authenticated', 'authenticated', 'enriquepeto@yahoo.es', '$2a$06$/RkumXWiBO73eECsv5l.l.cNQGy266OZaUg6gsBFo2f2eApiY8dnG', '2026-03-25 22:15:22.184963+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"provider": "email", "providers": ["email"]}', '{"full_name": "Enrique Perez"}', NULL, '2026-03-25 22:15:22.184963+00', '2026-03-25 22:15:22.184963+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
('00000000-0000-0000-0000-000000000000', 'f620655a-81a2-4cbe-89cf-bf5840b1a160', 'authenticated', 'authenticated', 'admin@brickshare.com', '$2a$06$CyurV2BsJpuofGt6DWIyTePXllZDOlSc/djawZGDB9aHJhZb/ezxO', '2026-03-25 22:15:22.184963+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-03-25 22:16:30.393339+00', '{"provider": "email", "providers": ["email"]}', '{"full_name": "Admin Brickshare"}', NULL, '2026-03-25 22:15:22.184963+00', '2026-03-25 22:16:30.395387+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
('00000000-0000-0000-0000-000000000000', '8251dd64-3747-40d0-8d20-c32b3a87d215', 'authenticated', 'authenticated', 'user2@brickshare.com', '$2a$06$zjERqpx3idGftkuthPL7suNH3UyJoCalFsu2gkE2.BEmWOIW/VlvG', '2026-03-25 22:15:22.184963+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-03-25 22:18:37.079451+00', '{"provider": "email", "providers": ["email"]}', '{"full_name": "User Two"}', NULL, '2026-03-25 22:15:22.184963+00', '2026-03-25 22:18:37.081148+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false);

ALTER TABLE auth.users ENABLE TRIGGER ALL;

--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.identities DISABLE TRIGGER ALL;

INSERT INTO auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) VALUES
('f620655a-81a2-4cbe-89cf-bf5840b1a160', 'f620655a-81a2-4cbe-89cf-bf5840b1a160', '{"sub": "f620655a-81a2-4cbe-89cf-bf5840b1a160", "email": "admin@brickshare.com", "email_verified": false, "phone_verified": false}', 'email', '2026-03-25 22:15:22.184963+00', '2026-03-25 22:15:22.184963+00', '2026-03-25 22:15:22.184963+00', '4e937493-12c2-4fb1-93d0-b2ba83225626'),
('360aab57-f618-481a-bdca-ca63f5a7c16e', '360aab57-f618-481a-bdca-ca63f5a7c16e', '{"sub": "360aab57-f618-481a-bdca-ca63f5a7c16e", "email": "enriquepeto@yahoo.es", "email_verified": false, "phone_verified": false}', 'email', '2026-03-25 22:15:22.184963+00', '2026-03-25 22:15:22.184963+00', '2026-03-25 22:15:22.184963+00', '3586f0fe-4933-47ff-a0ca-c53f23d7378f'),
('8251dd64-3747-40d0-8d20-c32b3a87d215', '8251dd64-3747-40d0-8d20-c32b3a87d215', '{"sub": "8251dd64-3747-40d0-8d20-c32b3a87d215", "email": "user2@brickshare.com", "email_verified": false, "phone_verified": false}', 'email', '2026-03-25 22:15:22.184963+00', '2026-03-25 22:15:22.184963+00', '2026-03-25 22:15:22.184963+00', '8b60d4f9-e439-4a51-8d46-5c0d7944c880');

ALTER TABLE auth.identities ENABLE TRIGGER ALL;

--
-- Data for Name: brickshare_pudo_locations; Type: TABLE DATA; Schema: public; Owner: postgres
--

ALTER TABLE public.brickshare_pudo_locations DISABLE TRIGGER ALL;

INSERT INTO public.brickshare_pudo_locations (id, name, address, city, postal_code, province, latitude, longitude, contact_phone, contact_email, opening_hours, is_active, notes, created_at, updated_at) VALUES
('BS-PUDO-001', 'Brickshare Madrid Centro', 'Calle Gran Vía 28', 'Madrid', '28013', 'Madrid', 40.42000000, -3.70380000, NULL, 'madrid.centro@brickshare.com', NULL, true, NULL, '2026-03-25 22:13:46.408451+00', '2026-03-25 22:13:46.408451+00'),
('BS-PUDO-002', 'Brickshare Barcelona Eixample', 'Passeig de Gràcia 100', 'Barcelona', '08008', 'Barcelona', 41.39260000, 2.16400000, NULL, 'barcelona.eixample@brickshare.com', NULL, true, NULL, '2026-03-25 22:13:46.408451+00', '2026-03-25 22:13:46.408451+00');

ALTER TABLE public.brickshare_pudo_locations ENABLE TRIGGER ALL;

--
-- Data for Name: sets; Type: TABLE DATA; Schema: public; Owner: postgres
--

ALTER TABLE public.sets DISABLE TRIGGER ALL;

INSERT INTO public.sets (id, set_name, set_description, set_image_url, set_theme, set_age_range, set_piece_count, skill_boost, created_at, updated_at, year_released, catalogue_visibility, set_ref, set_weight, set_minifigs, set_status, set_price, current_value_new, current_value_used, set_pvp_release, set_subtheme, barcode_upc, barcode_ean) VALUES
('6a8802bd-bef4-43f1-a36d-657a27ac11bb', 'Rescue Plane', 'Lego City set: Rescue Plane (2064).', 'https://images.brickset.com/sets/images/2064-1.jpg', 'City', '?+', 116, NULL, '2026-03-25 22:15:31.730327+00', '2026-03-25 22:15:31.730327+00', 2007, true, '2064', NULL, 2, 'active', 25, NULL, NULL, NULL, 'Medical', '673419098175', NULL),
('f6ce8907-c5f6-4652-8b42-9b445678e888', 'In-flight Helicopter and Raft', 'Lego City set: In-flight Helicopter and Raft (2230).', 'https://images.brickset.com/sets/images/2230-1.jpg', 'City', '?+', 115, NULL, '2026-03-25 22:15:31.75197+00', '2026-03-25 22:15:31.75197+00', 2008, true, '2230', NULL, 2, 'active', 25, NULL, NULL, NULL, 'Great Outdoors', '673419103015', NULL),
('0beb3582-b8c6-4963-a4f0-5d4c7d36873b', 'LEGO City Advent Calendar', 'Lego City set: LEGO City Advent Calendar (2824).', 'https://images.brickset.com/sets/images/2824-1.jpg', 'City', '5-12', 271, NULL, '2026-03-25 22:15:31.759122+00', '2026-03-25 22:15:31.759122+00', 2010, true, '2824', 430, 6, 'active', 50, NULL, NULL, 34.99, 'Seasonal', '673419130028', '5702014602434'),
('64cbaa56-a801-49a2-b2ee-b78934efa3be', 'City In-Flight 2006', 'Lego City set: City In-Flight 2006 (2928).', 'https://images.brickset.com/sets/images/2928-1.jpg', 'City', '?+', 141, NULL, '2026-03-25 22:15:31.770302+00', '2026-03-25 22:15:31.770302+00', 2006, true, '2928', NULL, 2, 'active', 25, NULL, NULL, NULL, 'Airport', '673419084048', NULL),
('3213cd08-65e3-499a-8209-3303f7b63f7a', 'Small Car', 'Lego City set: Small Car (3177).', 'https://images.brickset.com/sets/images/3177-1.jpg', 'City', '5-12', 43, NULL, '2026-03-25 22:15:31.775256+00', '2026-03-25 22:15:31.775256+00', 2010, true, '3177', 60, 1, 'active', 25, NULL, NULL, 4.99, 'Traffic', '673419129473', '5702014601819'),
('9d3b7faf-661e-4784-8c50-d4d1cd604cc8', 'Seaplane', 'Lego City set: Seaplane (3178).', 'https://images.brickset.com/sets/images/3178-1.jpg', 'City', '5-12', 102, NULL, '2026-03-25 22:15:31.780897+00', '2026-03-25 22:15:31.780897+00', 2010, true, '3178', 180, 1, 'active', 25, NULL, NULL, 10.99, 'General', '673419129480', '5702014601826'),
('9e04ddf7-c2bd-4157-bc87-1250b32a4633', 'Repair Truck', 'Lego City set: Repair Truck (3179).', 'https://images.brickset.com/sets/images/3179-1.jpg', 'City', '5-12', 118, NULL, '2026-03-25 22:15:31.785335+00', '2026-03-25 22:15:31.785335+00', 2010, true, '3179', 210, 1, 'active', 25, NULL, NULL, 12.99, 'Traffic', '673419129497', '5702014601833'),
('01ccc153-1361-4081-b62e-831549a56984', 'Tank Truck', 'Lego City set: Tank Truck (3180).', 'https://images.brickset.com/sets/images/3180-1.jpg', 'City', '5-12', 222, NULL, '2026-03-25 22:15:31.789917+00', '2026-03-25 22:15:31.789917+00', 2010, true, '3180', 490, 1, 'active', 25, NULL, NULL, 19.99, 'Traffic', '673419129503', '5702014601840'),
('4f159df2-8af3-44ae-a863-2fdf95be19e5', 'Passenger Plane', 'Lego City set: Passenger Plane (3181).', 'https://images.brickset.com/sets/images/3181-1.jpg', 'City', '5-12', 309, NULL, '2026-03-25 22:15:31.794299+00', '2026-03-25 22:15:31.794299+00', 2010, true, '3181', 760, 3, 'active', 50, NULL, NULL, 39.99, 'Airport', '673419078382', '5702014601857'),
('606d9ef7-6fab-4afc-a55a-ffa91519ef3a', 'Mini TIE Fighter', 'Lego Star Wars set: Mini TIE Fighter (3219).', 'https://images.brickset.com/sets/images/3219-1.jpg', 'Star Wars', '?+', 12, NULL, '2026-03-25 22:15:32.367122+00', '2026-03-25 22:15:32.367122+00', 2003, true, '3219', NULL, 0, 'active', 25, NULL, NULL, NULL, 'Mini Building Set', '673419020190', '5702014282230'),
('86f0c773-cffb-44e3-887d-aa6d0a82f550', 'Star Wars #1 - Emperor Palpatine, Darth Maul and Darth Vader', 'Lego Star Wars set: Star Wars #1 - Emperor Palpatine, Darth Maul and Darth Vader (3340).', 'https://images.brickset.com/sets/images/3340-1.jpg', 'Star Wars', '?+', 32, NULL, '2026-03-25 22:15:32.38168+00', '2026-03-25 22:15:32.38168+00', 2000, true, '3340', NULL, 3, 'active', 25, NULL, NULL, NULL, 'Minifig Pack', '042884033408', NULL),
('2f0737fb-3fd5-479d-8fa3-b35ba1cf995c', 'Star Wars #2 - Luke Skywalker, Han Solo and Boba Fett', 'Lego Star Wars set: Star Wars #2 - Luke Skywalker, Han Solo and Boba Fett (3341).', 'https://images.brickset.com/sets/images/3341-1.jpg', 'Star Wars', '?+', 22, NULL, '2026-03-25 22:15:32.392576+00', '2026-03-25 22:15:32.392576+00', 2000, true, '3341', NULL, 2, 'active', 25, NULL, NULL, NULL, 'Minifig Pack', '673419103015', NULL),
('d13f6cb4-15b3-42a5-84bf-e02dd10622d8', 'Star Wars #3 - Chewbacca and 2 Biker Scouts', 'Lego Star Wars set: Star Wars #3 - Chewbacca and 2 Biker Scouts (3342).', 'https://images.brickset.com/sets/images/3342-1.jpg', 'Star Wars', '?+', 22, NULL, '2026-03-25 22:15:32.402728+00', '2026-03-25 22:15:32.402728+00', 2000, true, '3342', NULL, 3, 'active', 25, NULL, NULL, NULL, 'Minifig Pack', '042884033422', NULL),
('cc11551b-c47b-444e-a101-a272ad2e2d32', 'Star Wars #4 - Battle Droid Commander and 2 Battle Droids', 'Lego Star Wars set: Star Wars #4 - Battle Droid Commander and 2 Battle Droids (3343).', 'https://images.brickset.com/sets/images/3343-1.jpg', 'Star Wars', '?+', 30, NULL, '2026-03-25 22:15:32.412668+00', '2026-03-25 22:15:32.412668+00', 2000, true, '3343', NULL, 3, 'active', 25, NULL, NULL, NULL, 'Minifig Pack', '042884033439', NULL),
('801322a7-ed2e-4017-bdad-f7729d4bb350', 'Jabba''s Message', 'Lego Star Wars set: Jabba''s Message (4475).', 'https://images.brickset.com/sets/images/4475-1.jpg', 'Star Wars', '?+', 44, NULL, '2026-03-25 22:15:32.422772+00', '2026-03-25 22:15:32.422772+00', 2003, true, '4475', NULL, 3, 'active', 25, NULL, NULL, NULL, 'Episode VI', '673419017169', '5702014259386'),
('1d1c1bf4-e319-463f-8e6e-0b5864f18f4e', 'Jabba''s Prize', 'Lego Star Wars set: Jabba''s Prize (4476).', 'https://images.brickset.com/sets/images/4476-1.jpg', 'Star Wars', '?+', 40, NULL, '2026-03-25 22:15:32.429896+00', '2026-03-25 22:15:32.429896+00', 2003, true, '4476', NULL, 2, 'active', 25, NULL, NULL, NULL, 'Episode VI', NULL, '5702014259393'),
('11196b3d-cd9e-4c41-a380-6ed14462e57f', 'T-16 Skyhopper ', 'Lego Star Wars set: T-16 Skyhopper  (4477).', 'https://images.brickset.com/sets/images/4477-1.jpg', 'Star Wars', '?+', 98, NULL, '2026-03-25 22:15:32.436805+00', '2026-03-25 22:15:32.436805+00', 2003, true, '4477', NULL, 1, 'active', 25, NULL, NULL, NULL, 'Episode IV', NULL, '5702014259355'),
('80968204-f8a4-4ead-ae6d-24047c8cd3b9', 'Geonosian Fighter', 'Lego Star Wars set: Geonosian Fighter (4478).', 'https://images.brickset.com/sets/images/4478-1.jpg', 'Star Wars', '?+', 170, NULL, '2026-03-25 22:15:32.442833+00', '2026-03-25 22:15:32.442833+00', 2003, true, '4478', NULL, 4, 'active', 25, NULL, NULL, NULL, 'Episode II', NULL, '5702014259409'),
('33347f57-fe3a-4b57-a0c1-6ecdd706da3f', 'TIE Bomber', 'Lego Star Wars set: TIE Bomber (4479).', 'https://images.brickset.com/sets/images/4479-1.jpg', 'Star Wars', '?+', 230, NULL, '2026-03-25 22:15:32.448494+00', '2026-03-25 22:15:32.448494+00', 2003, true, '4479', NULL, 1, 'active', 25, NULL, NULL, NULL, 'Episode V', '673419017213', NULL),
('ee2649aa-721b-4691-b321-5522281f0ee4', 'Sears Tower', 'Lego Architecture set: Sears Tower (19710).', 'https://images.brickset.com/sets/images/19710-1.jpg', 'Architecture', '10+', 68, NULL, '2026-03-25 22:15:32.907186+00', '2026-03-25 22:15:32.907186+00', 2008, true, '19710', NULL, 0, 'active', 25, NULL, NULL, NULL, 'Brickstructures', NULL, NULL),
('57350da7-e196-48a9-b1c4-5ade0ebc8f2b', 'John Hancock Centre', 'Lego Architecture set: John Hancock Centre (19720).', 'https://images.brickset.com/sets/images/19720-1.jpg', 'Architecture', '10+', 69, NULL, '2026-03-25 22:15:32.91786+00', '2026-03-25 22:15:32.91786+00', 2008, true, '19720', NULL, 0, 'active', 25, NULL, NULL, NULL, 'Brickstructures', NULL, NULL),
('f39a1d42-35f0-445a-8ca6-b91974f6aa26', 'Willis Tower', 'Lego Architecture set: Willis Tower (21000).', 'https://images.brickset.com/sets/images/21000-2.jpg', 'Architecture', '10+', 69, NULL, '2026-03-25 22:15:32.92508+00', '2026-03-25 22:15:32.931997+00', 2011, true, '21000', NULL, 0, 'active', 25, NULL, NULL, 19.99, 'Landmark Series', '673419113274', '5702014804265'),
('a55a6f63-2dfa-4cbc-8ca4-8b87baa831c0', 'John Hancock Centre', 'Lego Architecture set: John Hancock Centre (21001).', 'https://images.brickset.com/sets/images/21001-1.jpg', 'Architecture', '10+', 69, NULL, '2026-03-25 22:15:32.938525+00', '2026-03-25 22:15:32.938525+00', 2008, true, '21001', NULL, 0, 'active', 25, NULL, NULL, 19.99, 'Landmark Series', '673419113281', NULL),
('535f8eec-123a-4577-9dac-d9d54be7cccf', 'Empire State Building', 'Lego Architecture set: Empire State Building (21002).', 'https://images.brickset.com/sets/images/21002-1.jpg', 'Architecture', '10+', 77, NULL, '2026-03-25 22:15:32.943552+00', '2026-03-25 22:15:32.943552+00', 2009, true, '21002', 190, 0, 'active', 25, NULL, NULL, 19.99, 'Landmark Series', '673419160100', '5702014712836'),
('ef73ed54-9d7c-4042-a03d-44e76af1dc7b', 'Seattle Space Needle', 'Lego Architecture set: Seattle Space Needle (21003).', 'https://images.brickset.com/sets/images/21003-1.jpg', 'Architecture', '10+', 57, NULL, '2026-03-25 22:15:32.949651+00', '2026-03-25 22:15:32.949651+00', 2009, true, '21003', NULL, 0, 'active', 25, NULL, NULL, 19.99, 'Landmark Series', '673419160117', '5702014712843'),
('8475a851-2dce-4e6a-9b43-dd7c4c1f66bb', 'Solomon Guggenheim Museum', 'Lego Architecture set: Solomon Guggenheim Museum (21004).', 'https://images.brickset.com/sets/images/21004-1.jpg', 'Architecture', '10+', 208, NULL, '2026-03-25 22:15:32.954948+00', '2026-03-25 22:15:32.954948+00', 2009, true, '21004', NULL, 0, 'active', 25, NULL, NULL, 39.99, 'Architect Series', '673419113489', '5702014712850'),
('ed351eb7-35f4-43a3-ab48-dbf8ef897b99', 'Fallingwater', 'Lego Architecture set: Fallingwater (21005).', 'https://images.brickset.com/sets/images/21005-1.jpg', 'Architecture', '16+', 811, NULL, '2026-03-25 22:15:32.960351+00', '2026-03-25 22:15:32.960351+00', 2009, true, '21005', NULL, 0, 'active', 100, NULL, NULL, 89.99, 'Architect Series', '673419160131', '5702014712881'),
('e2ee0d77-59b2-441e-bdbe-ad0642c2dc71', 'The White House', 'Lego Architecture set: The White House (21006).', 'https://images.brickset.com/sets/images/21006-1.jpg', 'Architecture', '12+', 560, NULL, '2026-03-25 22:15:32.965651+00', '2026-03-25 22:15:32.965651+00', 2010, true, '21006', 700, 0, 'active', 75, NULL, NULL, 54.99, 'Landmark Series', '673419160148', '5702014804241');

ALTER TABLE public.sets ENABLE TRIGGER ALL;

--
-- Data for Name: inventory_sets; Type: TABLE DATA; Schema: public; Owner: postgres
--

ALTER TABLE public.inventory_sets DISABLE TRIGGER ALL;

INSERT INTO public.inventory_sets (id, set_id, set_ref, inventory_set_total_qty, in_shipping, in_use, in_return, in_repair, created_at, updated_at, spare_parts_order) VALUES
('8811fd31-4f71-4ea6-9107-acee5c0c4eb2', '6a8802bd-bef4-43f1-a36d-657a27ac11bb', '2064', 5, 0, 0, 0, 0, '2026-03-25 22:15:31.730327+00', '2026-03-25 22:15:31.746658+00', NULL),
('a5ae018a-9f62-4846-a213-78c30d4e3a37', 'f6ce8907-c5f6-4652-8b42-9b445678e888', '2230', 5, 0, 0, 0, 0, '2026-03-25 22:15:31.75197+00', '2026-03-25 22:15:31.755521+00', NULL),
('a2a45e3f-10cf-4ffe-9d2d-3b8cfde5af59', '0beb3582-b8c6-4963-a4f0-5d4c7d36873b', '2824', 5, 0, 0, 0, 0, '2026-03-25 22:15:31.759122+00', '2026-03-25 22:15:31.767198+00', NULL),
('34f9dc70-03d4-4cb1-b5bb-690775308e16', '64cbaa56-a801-49a2-b2ee-b78934efa3be', '2928', 5, 0, 0, 0, 0, '2026-03-25 22:15:31.770302+00', '2026-03-25 22:15:31.773034+00', NULL),
('de11093b-4a43-45e3-be1a-91cabf3b339c', '3213cd08-65e3-499a-8209-3303f7b63f7a', '3177', 5, 0, 0, 0, 0, '2026-03-25 22:15:31.775256+00', '2026-03-25 22:15:31.778838+00', NULL),
('0c033fdf-f3b0-48cd-b0f8-f81d23827514', '9d3b7faf-661e-4784-8c50-d4d1cd604cc8', '3178', 5, 0, 0, 0, 0, '2026-03-25 22:15:31.780897+00', '2026-03-25 22:15:31.783181+00', NULL),
('3e7cc920-5dea-415f-85a3-cd8c35a9d473', '9e04ddf7-c2bd-4157-bc87-1250b32a4633', '3179', 5, 0, 0, 0, 0, '2026-03-25 22:15:31.785335+00', '2026-03-25 22:15:31.787745+00', NULL),
('808e811d-3def-4378-937a-5322ed3b28d9', '01ccc153-1361-4081-b62e-831549a56984', '3180', 5, 0, 0, 0, 0, '2026-03-25 22:15:31.789917+00', '2026-03-25 22:15:31.792303+00', NULL),
('9f84312a-8166-405d-b47d-5db990a1ef95', '4f159df2-8af3-44ae-a863-2fdf95be19e5', '3181', 5, 0, 0, 0, 0, '2026-03-25 22:15:31.794299+00', '2026-03-25 22:15:31.79641+00', NULL),
('d204e4a3-4742-4eda-9cf6-56913cfea585', '606d9ef7-6fab-4afc-a55a-ffa91519ef3a', '3219', 5, 0, 0, 0, 0, '2026-03-25 22:15:32.367122+00', '2026-03-25 22:15:32.375878+00', NULL),
('cc8467d5-6336-4773-a494-668d4c40fd9f', '86f0c773-cffb-44e3-887d-aa6d0a82f550', '3340', 5, 0, 0, 0, 0, '2026-03-25 22:15:32.38168+00', '2026-03-25 22:15:32.38711+00', NULL),
('f2df648e-4a03-42c6-bc7f-de2a52cb67a6', '2f0737fb-3fd5-479d-8fa3-b35ba1cf995c', '3341', 5, 0, 0, 0, 0, '2026-03-25 22:15:32.392576+00', '2026-03-25 22:15:32.39814+00', NULL),
('86a606eb-72b9-44eb-9ab5-113e8b36b086', 'd13f6cb4-15b3-42a5-84bf-e02dd10622d8', '3342', 5, 0, 0, 0, 0, '2026-03-25 22:15:32.402728+00', '2026-03-25 22:15:32.407322+00', NULL),
('e9483e9c-fef4-41ca-9745-e59293dceb41', 'cc11551b-c47b-444e-a101-a272ad2e2d32', '3343', 5, 0, 0, 0, 0, '2026-03-25 22:15:32.412668+00', '2026-03-25 22:15:32.418175+00', NULL),
('2c5f8960-a635-4dda-8c99-f596fe01575e', '801322a7-ed2e-4017-bdad-f7729d4bb350', '4475', 5, 0, 0, 0, 0, '2026-03-25 22:15:32.422772+00', '2026-03-25 22:15:32.426483+00', NULL),
('6e15e24e-a2bd-43b5-af45-71d1bbe1c319', '1d1c1bf4-e319-463f-8e6e-0b5864f18f4e', '4476', 5, 0, 0, 0, 0, '2026-03-25 22:15:32.429896+00', '2026-03-25 22:15:32.433491+00', NULL),
('afd58b97-1980-4b99-9469-f1095261e85b', '11196b3d-cd9e-4c41-a380-6ed14462e57f', '4477', 5, 0, 0, 0, 0, '2026-03-25 22:15:32.436805+00', '2026-03-25 22:15:32.43994+00', NULL),
('3d1edf3c-8cfb-44fe-b058-7bc9b140457d', '80968204-f8a4-4ead-ae6d-24047c8cd3b9', '4478', 5, 0, 0, 0, 0, '2026-03-25 22:15:32.442833+00', '2026-03-25 22:15:32.445732+00', NULL),
('ec814dd9-f887-4dc7-b182-4bb9dd3b4a83', '33347f57-fe3a-4b57-a0c1-6ecdd706da3f', '4479', 5, 0, 0, 0, 0, '2026-03-25 22:15:32.448494+00', '2026-03-25 22:15:32.451421+00', NULL),
('11d7f92a-8d71-4b8b-829b-03517ff789d1', 'ee2649aa-721b-4691-b321-5522281f0ee4', '19710', 5, 0, 0, 0, 0, '2026-03-25 22:15:32.907186+00', '2026-03-25 22:15:32.913356+00', NULL),
('7ea5d8c6-9be3-4eab-b171-27445fd6eb04', '57350da7-e196-48a9-b1c4-5ade0ebc8f2b', '19720', 5, 0, 0, 0, 0, '2026-03-25 22:15:32.91786+00', '2026-03-25 22:15:32.921824+00', NULL),
('6c8b189b-286b-4067-8f44-cd3000e0b6f9', 'f39a1d42-35f0-445a-8ca6-b91974f6aa26', '21000', 5, 0, 0, 0, 0, '2026-03-25 22:15:32.92508+00', '2026-03-25 22:15:32.935737+00', NULL),
('c40dde84-c931-437d-9a3b-cee003765ce7', 'a55a6f63-2dfa-4cbc-8ca4-8b87baa831c0', '21001', 5, 0, 0, 0, 0, '2026-03-25 22:15:32.938525+00', '2026-03-25 22:15:32.941085+00', NULL),
('32e6800c-eade-42f7-8b6c-ee1cb88f3dda', '535f8eec-123a-4577-9dac-d9d54be7cccf', '21002', 5, 0, 0, 0, 0, '2026-03-25 22:15:32.943552+00', '2026-03-25 22:15:32.946417+00', NULL),
('6ff4fb8f-4f8d-48c2-b9c4-1f34bc2c64c1', 'ef73ed54-9d7c-4042-a03d-44e76af1dc7b', '21003', 5, 0, 0, 0, 0, '2026-03-25 22:15:32.949651+00', '2026-03-25 22:15:32.952511+00', NULL),
('22b10efa-dd6a-4fbe-aa8d-d0db8b82abc8', '8475a851-2dce-4e6a-9b43-dd7c4c1f66bb', '21004', 5, 0, 0, 0, 0, '2026-03-25 22:15:32.954948+00', '2026-03-25 22:15:32.957536+00', NULL),
('ef3ea5c0-980a-425d-9b68-2093ce58b210', 'ed351eb7-35f4-43a3-ab48-dbf8ef897b99', '21005', 5, 0, 0, 0, 0, '2026-03-25 22:15:32.960351+00', '2026-03-25 22:15:32.963448+00', NULL),
('c8330256-bbbf-40b1-bc55-02382097dd34', 'e2ee0d77-59b2-441e-bdbe-ad0642c2dc71', '21006', 5, 0, 0, 0, 0, '2026-03-25 22:15:32.965651+00', '2026-03-25 22:15:32.968427+00', NULL);

ALTER TABLE public.inventory_sets DISABLE TRIGGER ALL;

--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

ALTER TABLE public.user_roles DISABLE TRIGGER ALL;

INSERT INTO public.user_roles (id, user_id, role, created_at) VALUES
('62362f24-0a65-4fb6-8e59-08a22be511a5', 'f620655a-81a2-4cbe-89cf-bf5840b1a160', 'admin', '2026-03-25 22:15:22.184963+00'),
('70995ace-fea2-4579-82e3-c83340148058', '360aab57-f618-481a-bdca-ca63f5a7c16e', 'user', '2026-03-25 22:15:22.184963+00'),
('f8533c3a-4048-4e11-bf84-50dead82c51f', '8251dd64-3747-40d0-8d20-c32b3a87d215', 'user', '2026-03-25 22:15:22.184963+00');

ALTER TABLE public.user_roles ENABLE TRIGGER ALL;

--
-- PostgreSQL database dump complete
--