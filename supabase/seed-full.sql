SET session_replication_role = replica;

--
-- PostgreSQL database dump
--

-- \restrict 9PD5wGFgPSaPNX8VYtNCAWmFRrG7jvsX5gh9ffZkxOmtINQ3qczvS0wGvbYkZSR

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

INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES
	('00000000-0000-0000-0000-000000000000', 'ad8824ad-ebf4-47ce-8d06-e3e691a2f30d', '{"action":"user_signedup","actor_id":"e5b89a11-b73a-48d8-a40d-7dcb4e34721a","actor_username":"enriquepeto@yahoo.es","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2026-03-23 17:31:10.786896+00', ''),
	('00000000-0000-0000-0000-000000000000', '6a0fac15-3f0e-4e07-b2cc-d545e39390b1', '{"action":"login","actor_id":"e5b89a11-b73a-48d8-a40d-7dcb4e34721a","actor_username":"enriquepeto@yahoo.es","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2026-03-23 17:31:10.791738+00', ''),
	('00000000-0000-0000-0000-000000000000', 'dbdcec57-852d-4e1e-b6d1-80171f3033cc', '{"action":"logout","actor_id":"e5b89a11-b73a-48d8-a40d-7dcb4e34721a","actor_username":"enriquepeto@yahoo.es","actor_via_sso":false,"log_type":"account"}', '2026-03-23 17:31:30.095914+00', ''),
	('00000000-0000-0000-0000-000000000000', '071a231d-5043-47aa-b82b-a42f19a2069c', '{"action":"user_signedup","actor_id":"423ae03e-ec12-4319-9395-67fee60a5ea5","actor_username":"admin2@brickshare.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2026-03-23 17:31:42.099074+00', ''),
	('00000000-0000-0000-0000-000000000000', 'e4478103-8cea-414c-9715-46b5240666ad', '{"action":"login","actor_id":"423ae03e-ec12-4319-9395-67fee60a5ea5","actor_username":"admin2@brickshare.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2026-03-23 17:31:42.104235+00', '');


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
	('00000000-0000-0000-0000-000000000000', 'e5b89a11-b73a-48d8-a40d-7dcb4e34721a', 'authenticated', 'authenticated', 'enriquepeto@yahoo.es', '$2a$10$OAgIY1YaZN/S2eH7q19ZQemxmZ05Afzn/H0SsUmoEG8fsxhOAzlva', '2026-03-23 17:31:10.787206+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-03-23 17:31:10.792252+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "e5b89a11-b73a-48d8-a40d-7dcb4e34721a", "email": "enriquepeto@yahoo.es", "email_verified": true, "phone_verified": false}', NULL, '2026-03-23 17:31:10.783337+00', '2026-03-23 17:31:10.79379+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '423ae03e-ec12-4319-9395-67fee60a5ea5', 'authenticated', 'authenticated', 'admin2@brickshare.com', '$2a$10$6ap633eGComp7W90OoJa..KRR55be9qCfpD704ip3fR2Bzf6yU4OS', '2026-03-23 17:31:42.099329+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-03-23 17:31:42.104673+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "423ae03e-ec12-4319-9395-67fee60a5ea5", "email": "admin2@brickshare.com", "email_verified": true, "phone_verified": false}', NULL, '2026-03-23 17:31:42.095302+00', '2026-03-23 17:31:42.105891+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false);


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."identities" ("provider_id", "user_id", "identity_data", "provider", "last_sign_in_at", "created_at", "updated_at", "id") VALUES
	('e5b89a11-b73a-48d8-a40d-7dcb4e34721a', 'e5b89a11-b73a-48d8-a40d-7dcb4e34721a', '{"sub": "e5b89a11-b73a-48d8-a40d-7dcb4e34721a", "email": "enriquepeto@yahoo.es", "email_verified": false, "phone_verified": false}', 'email', '2026-03-23 17:31:10.785998+00', '2026-03-23 17:31:10.786016+00', '2026-03-23 17:31:10.786016+00', '4a1b5aad-0152-42e2-8d2c-77d09b3676bb'),
	('423ae03e-ec12-4319-9395-67fee60a5ea5', '423ae03e-ec12-4319-9395-67fee60a5ea5', '{"sub": "423ae03e-ec12-4319-9395-67fee60a5ea5", "email": "admin2@brickshare.com", "email_verified": false, "phone_verified": false}', 'email', '2026-03-23 17:31:42.098209+00', '2026-03-23 17:31:42.098222+00', '2026-03-23 17:31:42.098222+00', '661ba0f4-d407-493a-b8aa-2f056167be68');


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."sessions" ("id", "user_id", "created_at", "updated_at", "factor_id", "aal", "not_after", "refreshed_at", "user_agent", "ip", "tag", "oauth_client_id", "refresh_token_hmac_key", "refresh_token_counter", "scopes") VALUES
	('1ab4efbb-a0be-4842-8576-9248f6aa28b8', '423ae03e-ec12-4319-9395-67fee60a5ea5', '2026-03-23 17:31:42.104702+00', '2026-03-23 17:31:42.104702+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', '192.168.65.1', NULL, NULL, NULL, NULL, NULL);


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."mfa_amr_claims" ("session_id", "created_at", "updated_at", "authentication_method", "id") VALUES
	('1ab4efbb-a0be-4842-8576-9248f6aa28b8', '2026-03-23 17:31:42.106106+00', '2026-03-23 17:31:42.106106+00', 'password', '2a2335c5-42be-46bc-87a2-4f15bdc18f0b');


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

INSERT INTO "auth"."refresh_tokens" ("instance_id", "id", "token", "user_id", "revoked", "created_at", "updated_at", "parent", "session_id") VALUES
	('00000000-0000-0000-0000-000000000000', 2, '6agqpl6lnxwj', '423ae03e-ec12-4319-9395-67fee60a5ea5', false, '2026-03-23 17:31:42.105379+00', '2026-03-23 17:31:42.105379+00', NULL, '1ab4efbb-a0be-4842-8576-9248f6aa28b8');


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
	('BS-PUDO-001', 'Brickshare Madrid Centro', 'Calle Gran Vía 28', 'Madrid', '28013', 'Madrid', 40.42000000, -3.70380000, NULL, 'madrid.centro@brickshare.com', NULL, true, NULL, '2026-03-23 17:29:07.196858+00', '2026-03-23 17:29:07.196858+00'),
	('BS-PUDO-002', 'Brickshare Barcelona Eixample', 'Passeig de Gràcia 100', 'Barcelona', '08008', 'Barcelona', 41.39260000, 2.16400000, NULL, 'barcelona.eixample@brickshare.com', NULL, true, NULL, '2026-03-23 17:29:07.196858+00', '2026-03-23 17:29:07.196858+00');


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

INSERT INTO "public"."users" ("id", "user_id", "full_name", "avatar_url", "impact_points", "created_at", "updated_at", "email", "subscription_type", "subscription_status", "profile_completed", "user_status", "stripe_customer_id", "referral_code", "referred_by", "referral_credits", "address", "address_extra", "zip_code", "city", "province", "phone") VALUES
	('598a799b-c85e-4fc0-bb7a-fbf74c435fa3', 'e5b89a11-b73a-48d8-a40d-7dcb4e34721a', 'enrique perez', NULL, 0, '2026-03-23 17:31:10.783166+00', '2026-03-23 17:31:27.534963+00', 'enriquepeto@yahoo.es', NULL, 'inactive', true, 'no_set', NULL, 'DA2683', NULL, 0, 'josep tarradellas 97', NULL, '08029', 'barcelona', NULL, '123456789'),
	('33061735-3ca2-4d3a-9b77-fff654df1eef', '423ae03e-ec12-4319-9395-67fee60a5ea5', NULL, NULL, 0, '2026-03-23 17:31:42.095172+00', '2026-03-23 17:31:42.095172+00', 'admin2@brickshare.com', NULL, 'inactive', false, 'no_set', NULL, 'C8BBE7', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL);


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
-- Data for Name: shipping_orders; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."user_roles" ("id", "user_id", "role", "created_at") VALUES
	('8e19dcab-cb6a-4e6f-b638-5cb4e8d99c92', 'e5b89a11-b73a-48d8-a40d-7dcb4e34721a', 'user', '2026-03-23 17:31:10.783166+00'),
	('d7c06b87-910e-401b-a271-a4a2eda0a262', '423ae03e-ec12-4319-9395-67fee60a5ea5', 'user', '2026-03-23 17:31:42.095172+00');


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

SELECT pg_catalog.setval('"auth"."refresh_tokens_id_seq"', 2, true);


--
-- Name: hooks_id_seq; Type: SEQUENCE SET; Schema: supabase_functions; Owner: supabase_functions_admin
--

SELECT pg_catalog.setval('"supabase_functions"."hooks_id_seq"', 1, false);


--
-- PostgreSQL database dump complete
--

-- \unrestrict 9PD5wGFgPSaPNX8VYtNCAWmFRrG7jvsX5gh9ffZkxOmtINQ3qczvS0wGvbYkZSR

RESET ALL;
