Dumping data from local database...
SET session_replication_role = replica;

--
-- PostgreSQL database dump
--

-- \restrict Gt8xCxYZ6tqPeObIFEWlSSJbtd6QOmuyIqUFaBlxOAhWiKDezl1dLbDBjxafda0

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

INSERT INTO "auth"."users" ("instance_id", "id", "aud", "role", "email", "encrypted_password", "email_confirmed_at", "invited_at", "confirmation_token", "confirmation_sent_at", "recovery_token", "recovery_sent_at", "email_change_token_new", "email_change", "email_change_sent_at", "last_sign_in_at", "raw_app_meta_data", "raw_user_meta_data", "is_super_admin", "created_at", "updated_at", "phone", "phone_confirmed_at", "phone_change", "phone_change_token", "phone_change_sent_at", "email_change_token_current", "email_change_confirm_status", "banned_until", "reauthentication_token", "reauthentication_sent_at", "is_sso_user", "deleted_at", "is_anonymous") VALUES
	('00000000-0000-0000-0000-000000000000', '11111111-1111-1111-1111-111111111111', 'authenticated', 'authenticated_user', 'usertwo@test.com', '$2a$06$vG2de56C6N...QYWfSGOy.RtvvsgfFrGb395KKRGS57RtiwOqbp8e', '2026-03-25 22:26:38.287607+00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}', '{}', NULL, '2026-03-25 22:26:38.287607+00', '2026-03-25 22:26:38.287607+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '22222222-2222-2222-2222-222222222222', 'authenticated', 'authenticated_user', 'admin@test.com', '$2a$06$8beqZDCdOXmlbQ9z2i0oZeNjXcqB7JnbtTukE6Wjybos6iNr4Awb.', '2026-03-25 22:26:38.287607+00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '{}', '{}', NULL, '2026-03-25 22:26:38.287607+00', '2026-03-25 22:26:38.287607+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false);


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
-- Data for Name: backoffice_operations; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: brickshare_pudo_locations; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."brickshare_pudo_locations" ("id", "name", "address", "city", "postal_code", "province", "latitude", "longitude", "contact_phone", "contact_email", "opening_hours", "is_active", "notes", "created_at", "updated_at") VALUES
	('BS-PUDO-001', 'Brickshare Madrid Centro', 'Calle Gran Vía 28', 'Madrid', '28013', 'Madrid', 40.42000000, -3.70380000, NULL, 'madrid.centro@brickshare.com', NULL, true, NULL, '2026-03-25 22:26:05.433445+00', '2026-03-25 22:26:05.433445+00'),
	('BS-PUDO-002', 'Brickshare Barcelona Eixample', 'Passeig de Gràcia 100', 'Barcelona', '08008', 'Barcelona', 41.39260000, 2.16400000, NULL, 'barcelona.eixample@brickshare.com', NULL, true, NULL, '2026-03-25 22:26:05.433445+00', '2026-03-25 22:26:05.433445+00');


--
-- Data for Name: donations; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: sets; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: inventory_sets; Type: TABLE DATA; Schema: public; Owner: postgres
--



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

INSERT INTO "public"."wishlist" ("id", "user_id", "set_id", "created_at", "status", "status_changed_at") VALUES
	('5454ecd0-4f07-4052-8083-59546c6f42d0', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '2026-03-25 22:26:38.300865+00', true, '2026-03-25 22:26:38.300865+00'),
	('64138e1f-00a2-4a71-9f0b-c1ed3afaab43', '11111111-1111-1111-1111-111111111111', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '2026-03-25 22:26:38.300865+00', true, '2026-03-25 22:26:38.300865+00');


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

-- \unrestrict Gt8xCxYZ6tqPeObIFEWlSSJbtd6QOmuyIqUFaBlxOAhWiKDezl1dLbDBjxafda0

RESET ALL;
A new version of Supabase CLI is available: v2.84.2 (currently installed v2.78.1)
We recommend updating regularly for new features and bug fixes: https://supabase.com/docs/guides/cli/getting-started#updating-the-supabase-cli
