Dumping data from local database...
SET session_replication_role = replica;

--
-- PostgreSQL database dump
--

-- \restrict NZfTJhCMV4WuGe794BBbXRBkxrCEl9LUcxcDtargIsknqbon4gt7EMUlJv6mCeH

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

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
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: custom_oauth_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_authorizations; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_client_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_consents; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: webauthn_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: webauthn_credentials; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: backoffice_operations; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: brickshare_pudo_locations; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."brickshare_pudo_locations" ("id", "name", "address", "city", "postal_code", "province", "latitude", "longitude", "contact_phone", "contact_email", "opening_hours", "is_active", "notes", "created_at", "updated_at") VALUES
	('BS-PUDO-001', 'Brickshare Madrid Centro', 'Calle Gran Vía 28', 'Madrid', '28013', 'Madrid', 40.42000000, -3.70380000, NULL, 'madrid.centro@brickshare.com', NULL, true, NULL, '2026-03-25 09:38:23.240849+00', '2026-03-25 09:38:23.240849+00'),
	('BS-PUDO-002', 'Brickshare Barcelona Eixample', 'Passeig de Gràcia 100', 'Barcelona', '08008', 'Barcelona', 41.39260000, 2.16400000, NULL, 'barcelona.eixample@brickshare.com', NULL, true, NULL, '2026-03-25 09:38:23.240849+00', '2026-03-25 09:38:23.240849+00');


--
-- Data for Name: donations; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: sets; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."sets" ("id", "set_name", "set_description", "set_image_url", "set_theme", "set_age_range", "set_piece_count", "skill_boost", "created_at", "updated_at", "year_released", "catalogue_visibility", "set_ref", "set_weight", "set_minifigs", "set_status", "set_price", "current_value_new", "current_value_used", "set_pvp_release", "set_subtheme", "barcode_upc", "barcode_ean") VALUES
	('8132bf4c-6038-485a-8b64-5604c8d1a1aa', 'Rescue Plane', 'Lego City set: Rescue Plane (2064).', 'https://images.brickset.com/sets/images/2064-1.jpg', 'City', '?+', 116, NULL, '2026-03-25 09:34:28.462596+00', '2026-03-25 09:34:28.462596+00', 2007, true, '2064', NULL, 2, 'active', 25, NULL, NULL, NULL, 'Medical', '673419098175', NULL),
	('9d875b50-2972-4f7c-8f8f-4f1111d3faeb', 'In-flight Helicopter and Raft', 'Lego City set: In-flight Helicopter and Raft (2230).', 'https://images.brickset.com/sets/images/2230-1.jpg', 'City', '?+', 115, NULL, '2026-03-25 09:34:28.489746+00', '2026-03-25 09:34:28.489746+00', 2008, true, '2230', NULL, 2, 'active', 25, NULL, NULL, NULL, 'Great Outdoors', '673419103015', NULL),
	('9fce1e1f-0740-4eb2-bc44-0d99b7ddd109', 'LEGO City Advent Calendar', 'Lego City set: LEGO City Advent Calendar (2824).', 'https://images.brickset.com/sets/images/2824-1.jpg', 'City', '5-12', 271, NULL, '2026-03-25 09:34:28.498689+00', '2026-03-25 09:34:28.498689+00', 2010, true, '2824', 430, 6, 'active', 50, NULL, NULL, 34.99, 'Seasonal', '673419130028', '5702014602434'),
	('0dd9d872-499f-468a-9f78-90e27e067d16', 'City In-Flight 2006', 'Lego City set: City In-Flight 2006 (2928).', 'https://images.brickset.com/sets/images/2928-1.jpg', 'City', '?+', 141, NULL, '2026-03-25 09:34:28.505517+00', '2026-03-25 09:34:28.505517+00', 2006, true, '2928', NULL, 2, 'active', 25, NULL, NULL, NULL, 'Airport', '673419084048', NULL),
	('2f82d97a-6837-45d6-b755-4f2eabdc30dc', 'Small Car', 'Lego City set: Small Car (3177).', 'https://images.brickset.com/sets/images/3177-1.jpg', 'City', '5-12', 43, NULL, '2026-03-25 09:34:28.51097+00', '2026-03-25 09:34:28.51097+00', 2010, true, '3177', 60, 1, 'active', 25, NULL, NULL, 4.99, 'Traffic', '673419129473', '5702014601819'),
	('c51fa2b3-70b3-46a6-8b09-434dd3ca7c71', 'Seaplane', 'Lego City set: Seaplane (3178).', 'https://images.brickset.com/sets/images/3178-1.jpg', 'City', '5-12', 102, NULL, '2026-03-25 09:34:28.516316+00', '2026-03-25 09:34:28.516316+00', 2010, true, '3178', 180, 1, 'active', 25, NULL, NULL, 10.99, 'General', '673419129480', '5702014601826'),
	('6096c1ca-d3be-49e1-9a3f-3e62d518567e', 'Repair Truck', 'Lego City set: Repair Truck (3179).', 'https://images.brickset.com/sets/images/3179-1.jpg', 'City', '5-12', 118, NULL, '2026-03-25 09:34:28.521312+00', '2026-03-25 09:34:28.521312+00', 2010, true, '3179', 210, 1, 'active', 25, NULL, NULL, 12.99, 'Traffic', '673419129497', '5702014601833'),
	('26752645-8e59-4746-80eb-8daa238653a6', 'Tank Truck', 'Lego City set: Tank Truck (3180).', 'https://images.brickset.com/sets/images/3180-1.jpg', 'City', '5-12', 222, NULL, '2026-03-25 09:34:28.526562+00', '2026-03-25 09:34:28.526562+00', 2010, true, '3180', 490, 1, 'active', 25, NULL, NULL, 19.99, 'Traffic', '673419129503', '5702014601840'),
	('80ffb07b-3bc2-442e-bc87-e32fb83d51cc', 'Passenger Plane', 'Lego City set: Passenger Plane (3181).', 'https://images.brickset.com/sets/images/3181-1.jpg', 'City', '5-12', 309, NULL, '2026-03-25 09:34:28.531802+00', '2026-03-25 09:34:28.531802+00', 2010, true, '3181', 760, 3, 'active', 50, NULL, NULL, 39.99, 'Airport', '673419078382', '5702014601857'),
	('24de40b8-8837-406c-a5d1-5638adcd23a2', 'Mini TIE Fighter', 'Lego Star Wars set: Mini TIE Fighter (3219).', 'https://images.brickset.com/sets/images/3219-1.jpg', 'Star Wars', '?+', 12, NULL, '2026-03-25 09:34:28.804272+00', '2026-03-25 09:34:28.804272+00', 2003, true, '3219', NULL, 0, 'active', 25, NULL, NULL, NULL, 'Mini Building Set', '673419020190', '5702014282230'),
	('8a31f68d-4992-4c21-99d6-3cecbee547be', 'Star Wars #1 - Emperor Palpatine, Darth Maul and Darth Vader', 'Lego Star Wars set: Star Wars #1 - Emperor Palpatine, Darth Maul and Darth Vader (3340).', 'https://images.brickset.com/sets/images/3340-1.jpg', 'Star Wars', '?+', 32, NULL, '2026-03-25 09:34:28.812791+00', '2026-03-25 09:34:28.812791+00', 2000, true, '3340', NULL, 3, 'active', 25, NULL, NULL, NULL, 'Minifig Pack', '042884033408', NULL),
	('28876fcc-b568-4312-89d2-27e079317424', 'Star Wars #2 - Luke Skywalker, Han Solo and Boba Fett', 'Lego Star Wars set: Star Wars #2 - Luke Skywalker, Han Solo and Boba Fett (3341).', 'https://images.brickset.com/sets/images/3341-1.jpg', 'Star Wars', '?+', 22, NULL, '2026-03-25 09:34:28.818959+00', '2026-03-25 09:34:28.818959+00', 2000, true, '3341', NULL, 3, 'active', 25, NULL, NULL, NULL, 'Minifig Pack', '042884033415', NULL),
	('7656dff6-523b-4951-84fa-b04f4b205a0f', 'Star Wars #3 - Chewbacca and 2 Biker Scouts', 'Lego Star Wars set: Star Wars #3 - Chewbacca and 2 Biker Scouts (3342).', 'https://images.brickset.com/sets/images/3342-1.jpg', 'Star Wars', '?+', 22, NULL, '2026-03-25 09:34:28.824284+00', '2026-03-25 09:34:28.824284+00', 2000, true, '3342', NULL, 3, 'active', 25, NULL, NULL, NULL, 'Minifig Pack', '042884033422', NULL),
	('cee0f945-2131-4b20-9ad2-f33fe8f52594', 'Star Wars #4 - Battle Droid Commander and 2 Battle Droids', 'Lego Star Wars set: Star Wars #4 - Battle Droid Commander and 2 Battle Droids (3343).', 'https://images.brickset.com/sets/images/3343-1.jpg', 'Star Wars', '?+', 30, NULL, '2026-03-25 09:34:28.829552+00', '2026-03-25 09:34:28.829552+00', 2000, true, '3343', NULL, 3, 'active', 25, NULL, NULL, NULL, 'Minifig Pack', '042884033439', NULL),
	('1d26bc1c-c014-407a-affd-bfa2ccf6f58a', 'Jabba''s Message', 'Lego Star Wars set: Jabba''s Message (4475).', 'https://images.brickset.com/sets/images/4475-1.jpg', 'Star Wars', '?+', 44, NULL, '2026-03-25 09:34:28.835269+00', '2026-03-25 09:34:28.835269+00', 2003, true, '4475', NULL, 3, 'active', 25, NULL, NULL, NULL, 'Episode VI', '673419017169', '5702014259386'),
	('34c6e363-2304-4108-8494-978be2171dac', 'Jabba''s Prize', 'Lego Star Wars set: Jabba''s Prize (4476).', 'https://images.brickset.com/sets/images/4476-1.jpg', 'Star Wars', '?+', 40, NULL, '2026-03-25 09:34:28.841428+00', '2026-03-25 09:34:28.841428+00', 2003, true, '4476', NULL, 2, 'active', 25, NULL, NULL, NULL, 'Episode VI', NULL, '5702014259393'),
	('849788bc-cc3b-4a4c-910f-2cacb470ab38', 'T-16 Skyhopper ', 'Lego Star Wars set: T-16 Skyhopper  (4477).', 'https://images.brickset.com/sets/images/4477-1.jpg', 'Star Wars', '?+', 98, NULL, '2026-03-25 09:34:28.847769+00', '2026-03-25 09:34:28.847769+00', 2003, true, '4477', NULL, 1, 'active', 25, NULL, NULL, NULL, 'Episode IV', NULL, '5702014259355'),
	('1030dc57-40d2-45be-9133-c610cb6c5ace', 'Geonosian Fighter', 'Lego Star Wars set: Geonosian Fighter (4478).', 'https://images.brickset.com/sets/images/4478-1.jpg', 'Star Wars', '?+', 170, NULL, '2026-03-25 09:34:28.855123+00', '2026-03-25 09:34:28.855123+00', 2003, true, '4478', NULL, 4, 'active', 25, NULL, NULL, NULL, 'Episode II', NULL, '5702014259409'),
	('feca1df0-674a-4ec5-ab5e-60368bbb21a6', 'TIE Bomber', 'Lego Star Wars set: TIE Bomber (4479).', 'https://images.brickset.com/sets/images/4479-1.jpg', 'Star Wars', '?+', 230, NULL, '2026-03-25 09:34:28.861981+00', '2026-03-25 09:34:28.861981+00', 2003, true, '4479', NULL, 1, 'active', 25, NULL, NULL, NULL, 'Episode V', '673419017213', NULL),
	('7cdea4b7-bc0e-48f4-b5c7-ed17a64ee5a4', 'Sears Tower', 'Lego Architecture set: Sears Tower (19710).', 'https://images.brickset.com/sets/images/19710-1.jpg', 'Architecture', '10+', 68, NULL, '2026-03-25 09:34:29.199815+00', '2026-03-25 09:34:29.199815+00', 2008, true, '19710', NULL, 0, 'active', 25, NULL, NULL, NULL, 'Brickstructures', NULL, NULL),
	('883ac1ca-719d-4559-98d8-6e0da144e218', 'John Hancock Centre', 'Lego Architecture set: John Hancock Centre (19720).', 'https://images.brickset.com/sets/images/19720-1.jpg', 'Architecture', '10+', 69, NULL, '2026-03-25 09:34:29.209451+00', '2026-03-25 09:34:29.209451+00', 2008, true, '19720', NULL, 0, 'active', 25, NULL, NULL, NULL, 'Brickstructures', NULL, NULL),
	('acff5cc5-5c77-48ba-a66b-b4d823f6088e', 'Willis Tower', 'Lego Architecture set: Willis Tower (21000).', 'https://images.brickset.com/sets/images/21000-2.jpg', 'Architecture', '10+', 69, NULL, '2026-03-25 09:34:29.215752+00', '2026-03-25 09:34:29.226264+00', 2011, true, '21000', NULL, 0, 'active', 25, NULL, NULL, 19.99, 'Landmark Series', '673419113274', '5702014804265'),
	('6b6d594b-f5b5-4412-b01f-5b329fa133a3', 'John Hancock Centre', 'Lego Architecture set: John Hancock Centre (21001).', 'https://images.brickset.com/sets/images/21001-1.jpg', 'Architecture', '10+', 69, NULL, '2026-03-25 09:34:29.234289+00', '2026-03-25 09:34:29.234289+00', 2008, true, '21001', NULL, 0, 'active', 25, NULL, NULL, 19.99, 'Landmark Series', '673419113281', NULL),
	('57c8d75d-6b4f-457f-97d9-f54ddb856e7a', 'Empire State Building', 'Lego Architecture set: Empire State Building (21002).', 'https://images.brickset.com/sets/images/21002-1.jpg', 'Architecture', '10+', 77, NULL, '2026-03-25 09:34:29.241262+00', '2026-03-25 09:34:29.241262+00', 2009, true, '21002', 190, 0, 'active', 25, NULL, NULL, 19.99, 'Landmark Series', '673419160100', '5702014712836'),
	('a35316d4-8cd0-4b03-bba5-98bf9dcdd56e', 'Seattle Space Needle', 'Lego Architecture set: Seattle Space Needle (21003).', 'https://images.brickset.com/sets/images/21003-1.jpg', 'Architecture', '10+', 57, NULL, '2026-03-25 09:34:29.248745+00', '2026-03-25 09:34:29.248745+00', 2009, true, '21003', NULL, 0, 'active', 25, NULL, NULL, 19.99, 'Landmark Series', '673419160117', '5702014712843'),
	('6c5768fb-3b29-4deb-a1af-f60fbb2b9cfe', 'Solomon Guggenheim Museum', 'Lego Architecture set: Solomon Guggenheim Museum (21004).', 'https://images.brickset.com/sets/images/21004-1.jpg', 'Architecture', '10+', 208, NULL, '2026-03-25 09:34:29.25469+00', '2026-03-25 09:34:29.25469+00', 2009, true, '21004', NULL, 0, 'active', 25, NULL, NULL, 39.99, 'Architect Series', '673419113489', '5702014712850'),
	('dabe9d8d-3dd2-4866-bc2c-8bae359ca4cd', 'Fallingwater', 'Lego Architecture set: Fallingwater (21005).', 'https://images.brickset.com/sets/images/21005-1.jpg', 'Architecture', '16+', 811, NULL, '2026-03-25 09:34:29.261105+00', '2026-03-25 09:34:29.261105+00', 2009, true, '21005', NULL, 0, 'active', 100, NULL, NULL, 89.99, 'Architect Series', '673419160131', '5702014712881'),
	('463d1d9f-b0b5-484c-a324-6efad99f2ef7', 'The White House', 'Lego Architecture set: The White House (21006).', 'https://images.brickset.com/sets/images/21006-1.jpg', 'Architecture', '12+', 560, NULL, '2026-03-25 09:34:29.269017+00', '2026-03-25 09:34:29.269017+00', 2010, true, '21006', 700, 0, 'active', 75, NULL, NULL, 54.99, 'Landmark Series', '673419160148', '5702014804241');


--
-- Data for Name: inventory_sets; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."inventory_sets" ("id", "set_id", "set_ref", "inventory_set_total_qty", "in_shipping", "in_use", "in_return", "in_repair", "created_at", "updated_at", "spare_parts_order") VALUES
	('eb15e4cf-aacc-4c64-9501-fbc9243c1f35', '8132bf4c-6038-485a-8b64-5604c8d1a1aa', '2064', 2, 0, 0, 0, 0, '2026-03-25 09:49:17.982136+00', '2026-03-25 09:49:17.982136+00', NULL),
	('c9995f93-9163-42ab-9788-798b5f9a896b', '9d875b50-2972-4f7c-8f8f-4f1111d3faeb', '2230', 2, 0, 0, 0, 0, '2026-03-25 09:49:17.982136+00', '2026-03-25 09:49:17.982136+00', NULL),
	('ec750492-751c-467e-9c96-889c97f04bb8', '9fce1e1f-0740-4eb2-bc44-0d99b7ddd109', '2824', 2, 0, 0, 0, 0, '2026-03-25 09:49:17.982136+00', '2026-03-25 09:49:17.982136+00', NULL),
	('23401309-8b4c-42d4-9544-bff5f8b2f584', '0dd9d872-499f-468a-9f78-90e27e067d16', '2928', 2, 0, 0, 0, 0, '2026-03-25 09:49:17.982136+00', '2026-03-25 09:49:17.982136+00', NULL),
	('be61f432-76ba-4433-9696-2ea1f5bfbe62', '2f82d97a-6837-45d6-b755-4f2eabdc30dc', '3177', 2, 0, 0, 0, 0, '2026-03-25 09:49:17.982136+00', '2026-03-25 09:49:17.982136+00', NULL),
	('359c8355-1a84-4d95-bc80-aecb2c551f1e', 'c51fa2b3-70b3-46a6-8b09-434dd3ca7c71', '3178', 2, 0, 0, 0, 0, '2026-03-25 09:49:17.982136+00', '2026-03-25 09:49:17.982136+00', NULL),
	('f0083179-ab4e-4484-a0a9-f6189303a7d5', '6096c1ca-d3be-49e1-9a3f-3e62d518567e', '3179', 2, 0, 0, 0, 0, '2026-03-25 09:49:17.982136+00', '2026-03-25 09:49:17.982136+00', NULL),
	('b93651e3-c8ac-412f-b85e-998156ba61b1', '26752645-8e59-4746-80eb-8daa238653a6', '3180', 2, 0, 0, 0, 0, '2026-03-25 09:49:17.982136+00', '2026-03-25 09:49:17.982136+00', NULL),
	('446fa975-55f8-4664-a1be-948a4889096a', '80ffb07b-3bc2-442e-bc87-e32fb83d51cc', '3181', 2, 0, 0, 0, 0, '2026-03-25 09:49:17.982136+00', '2026-03-25 09:49:17.982136+00', NULL),
	('e3b763b2-6f79-45b9-aa8a-bf580aa1c5ea', '24de40b8-8837-406c-a5d1-5638adcd23a2', '3219', 2, 0, 0, 0, 0, '2026-03-25 09:49:17.982136+00', '2026-03-25 09:49:17.982136+00', NULL),
	('e4649e0a-b30d-4027-ba8d-7ea504caee74', '8a31f68d-4992-4c21-99d6-3cecbee547be', '3340', 2, 0, 0, 0, 0, '2026-03-25 09:49:17.982136+00', '2026-03-25 09:49:17.982136+00', NULL),
	('59eae85b-2c59-4659-bbd7-fdf2c03c9b13', '28876fcc-b568-4312-89d2-27e079317424', '3341', 2, 0, 0, 0, 0, '2026-03-25 09:49:17.982136+00', '2026-03-25 09:49:17.982136+00', NULL),
	('19d421a0-c3e8-40ed-b0bf-042d73b493ac', '7656dff6-523b-4951-84fa-b04f4b205a0f', '3342', 2, 0, 0, 0, 0, '2026-03-25 09:49:17.982136+00', '2026-03-25 09:49:17.982136+00', NULL),
	('28758563-b5e3-4f48-82ea-54771984f236', 'cee0f945-2131-4b20-9ad2-f33fe8f52594', '3343', 2, 0, 0, 0, 0, '2026-03-25 09:49:17.982136+00', '2026-03-25 09:49:17.982136+00', NULL),
	('8ca927e8-b074-44ed-9667-082bdb9e06e7', '1d26bc1c-c014-407a-affd-bfa2ccf6f58a', '4475', 2, 0, 0, 0, 0, '2026-03-25 09:49:17.982136+00', '2026-03-25 09:49:17.982136+00', NULL),
	('09762e5b-3109-4097-913e-a1a38bc3023f', '34c6e363-2304-4108-8494-978be2171dac', '4476', 2, 0, 0, 0, 0, '2026-03-25 09:49:17.982136+00', '2026-03-25 09:49:17.982136+00', NULL),
	('3ec81a0f-3a27-45c1-b586-1d2cab312633', '849788bc-cc3b-4a4c-910f-2cacb470ab38', '4477', 2, 0, 0, 0, 0, '2026-03-25 09:49:17.982136+00', '2026-03-25 09:49:17.982136+00', NULL),
	('24f20f4b-5e4e-45a2-9790-2002d0fc3e83', '1030dc57-40d2-45be-9133-c610cb6c5ace', '4478', 2, 0, 0, 0, 0, '2026-03-25 09:49:17.982136+00', '2026-03-25 09:49:17.982136+00', NULL),
	('952f0e3b-ce2d-40aa-aa4a-fca21dbf1921', 'feca1df0-674a-4ec5-ab5e-60368bbb21a6', '4479', 2, 0, 0, 0, 0, '2026-03-25 09:49:17.982136+00', '2026-03-25 09:49:17.982136+00', NULL),
	('806622e5-81f4-46a6-afa3-3ac403d95e90', '7cdea4b7-bc0e-48f4-b5c7-ed17a64ee5a4', '19710', 2, 0, 0, 0, 0, '2026-03-25 09:49:17.982136+00', '2026-03-25 09:49:17.982136+00', NULL),
	('2c52758e-2861-4ce5-8e91-7f9cace9cef3', '883ac1ca-719d-4559-98d8-6e0da144e218', '19720', 2, 0, 0, 0, 0, '2026-03-25 09:49:17.982136+00', '2026-03-25 09:49:17.982136+00', NULL),
	('94d4a5b2-aba9-45e3-b42a-17917d46cc88', 'acff5cc5-5c77-48ba-a66b-b4d823f6088e', '21000', 2, 0, 0, 0, 0, '2026-03-25 09:49:17.982136+00', '2026-03-25 09:49:17.982136+00', NULL),
	('f20758b8-046f-4644-bea2-df7a825d97e0', '6b6d594b-f5b5-4412-b01f-5b329fa133a3', '21001', 2, 0, 0, 0, 0, '2026-03-25 09:49:17.982136+00', '2026-03-25 09:49:17.982136+00', NULL),
	('7f8ad9b8-3be2-49ce-b9c8-d64a626ce456', '57c8d75d-6b4f-457f-97d9-f54ddb856e7a', '21002', 2, 0, 0, 0, 0, '2026-03-25 09:49:17.982136+00', '2026-03-25 09:49:17.982136+00', NULL),
	('1f241565-8299-48e7-848c-16a0baca6b23', 'a35316d4-8cd0-4b03-bba5-98bf9dcdd56e', '21003', 2, 0, 0, 0, 0, '2026-03-25 09:49:17.982136+00', '2026-03-25 09:49:17.982136+00', NULL),
	('0a338630-bc1b-4246-a108-47882083c538', '6c5768fb-3b29-4deb-a1af-f60fbb2b9cfe', '21004', 2, 0, 0, 0, 0, '2026-03-25 09:49:17.982136+00', '2026-03-25 09:49:17.982136+00', NULL),
	('c94c3cc6-0db5-4c95-bd0e-2050dad43a5e', 'dabe9d8d-3dd2-4866-bc2c-8bae359ca4cd', '21005', 2, 0, 0, 0, 0, '2026-03-25 09:49:17.982136+00', '2026-03-25 09:49:17.982136+00', NULL),
	('114318bf-bcf9-43bd-a597-eac5ef241886', '463d1d9f-b0b5-484c-a324-6efad99f2ef7', '21006', 2, 0, 0, 0, 0, '2026-03-25 09:49:17.982136+00', '2026-03-25 09:49:17.982136+00', NULL);


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: shipments; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: qr_validation_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: reception_operations; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: referrals; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: set_piece_list; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: shipment_update_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: shipping_orders; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: users_brickshare_dropping; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: users_correos_dropping; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: wishlist; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: buckets_vectors; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: iceberg_namespaces; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: iceberg_tables; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: vector_indexes; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: hooks; Type: TABLE DATA; Schema: supabase_functions; Owner: supabase_functions_admin
--



--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: supabase_auth_admin
--

SELECT pg_catalog.setval('"auth"."refresh_tokens_id_seq"', 1, false);


--
-- Name: hooks_id_seq; Type: SEQUENCE SET; Schema: supabase_functions; Owner: supabase_functions_admin
--

SELECT pg_catalog.setval('"supabase_functions"."hooks_id_seq"', 1, false);


--
-- PostgreSQL database dump complete
--

-- \unrestrict NZfTJhCMV4WuGe794BBbXRBkxrCEl9LUcxcDtargIsknqbon4gt7EMUlJv6mCeH

RESET ALL;
