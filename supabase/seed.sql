SET session_replication_role = replica;

--
-- PostgreSQL database dump
--

-- \restrict ebVckroH2HeIEjURxZcr1V6gkTOYeUN7GUMELmeULVR4WbzWKSHSElFOdIJdNm9

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
	('00000000-0000-0000-0000-000000000000', '78df0591-4c9d-4e4d-acb2-32ed95e261f5', 'authenticated', 'authenticated', 'user@brickshare.com', '$2a$10$ikQP8DtBoQh0xriy.VIMyubtn40z1PDhPyW1uRnMecG6lIYA7W7mG', '2026-03-21 17:50:05.64113+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-03-21 17:50:05.647919+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "78df0591-4c9d-4e4d-acb2-32ed95e261f5", "email": "user@brickshare.com", "full_name": "enrique perez", "email_verified": true, "phone_verified": false}', NULL, '2026-03-21 17:50:05.596099+00', '2026-03-21 21:01:58.356021+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '83c0c80a-aef3-47cc-a6a9-dd9c5172dae4', 'authenticated', 'authenticated', 'user2@brickshare.com', '$2a$10$y8zI/KMbkXpVVPx5dzE8k.hJFpn1NijkwGs3D8ZUYQqX3pJ54Vhf6', '2026-03-21 21:06:40.195267+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-03-22 08:14:42.669404+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "83c0c80a-aef3-47cc-a6a9-dd9c5172dae4", "email": "user2@brickshare.com", "full_name": "Jan Perez", "email_verified": true, "phone_verified": false}', NULL, '2026-03-21 21:06:40.146119+00', '2026-03-22 08:14:42.742215+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '78f27662-6b00-4fec-9700-ac511bd5301e', 'authenticated', 'authenticated', 'admin@brickshare.com', '$2a$10$P7ggQVGqj81bfvJlmMzIv.vtG2wRVEas6RrbUza/gjQPDGgtvW4Mm', '2026-03-21 21:24:09.052149+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-03-22 10:41:45.266992+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "78f27662-6b00-4fec-9700-ac511bd5301e", "email": "admin@brickshare.com", "full_name": "Admin", "email_verified": true, "phone_verified": false}', NULL, '2026-03-21 21:24:08.99491+00', '2026-03-22 10:41:45.288021+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false);


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."identities" ("provider_id", "user_id", "identity_data", "provider", "last_sign_in_at", "created_at", "updated_at", "id") VALUES
	('78df0591-4c9d-4e4d-acb2-32ed95e261f5', '78df0591-4c9d-4e4d-acb2-32ed95e261f5', '{"sub": "78df0591-4c9d-4e4d-acb2-32ed95e261f5", "email": "user@brickshare.com", "full_name": "enrique perez", "email_verified": false, "phone_verified": false}', 'email', '2026-03-21 17:50:05.63296+00', '2026-03-21 17:50:05.633014+00', '2026-03-21 17:50:05.633014+00', 'dca5778e-b1eb-49ff-8f13-360812926d51'),
	('83c0c80a-aef3-47cc-a6a9-dd9c5172dae4', '83c0c80a-aef3-47cc-a6a9-dd9c5172dae4', '{"sub": "83c0c80a-aef3-47cc-a6a9-dd9c5172dae4", "email": "user2@brickshare.com", "full_name": "Jan Perez", "email_verified": false, "phone_verified": false}', 'email', '2026-03-21 21:06:40.188886+00', '2026-03-21 21:06:40.188934+00', '2026-03-21 21:06:40.188934+00', 'ee50eed1-64b4-46f2-9a96-20e80dd4a2ac'),
	('78f27662-6b00-4fec-9700-ac511bd5301e', '78f27662-6b00-4fec-9700-ac511bd5301e', '{"sub": "78f27662-6b00-4fec-9700-ac511bd5301e", "email": "admin@brickshare.com", "full_name": "Admin", "email_verified": false, "phone_verified": false}', 'email', '2026-03-21 21:24:09.042215+00', '2026-03-21 21:24:09.042266+00', '2026-03-21 21:24:09.042266+00', '5bba08ca-1c6b-4cbe-b511-16dc3dcfc6da');


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
	('39ff8087-256e-44f3-9869-e010e979bea8', '78df0591-4c9d-4e4d-acb2-32ed95e261f5', '2026-03-21 17:50:05.648013+00', '2026-03-21 21:01:58.367697+00', NULL, 'aal1', NULL, '2026-03-21 21:01:58.367587', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', '165.85.128.5', NULL, NULL, NULL, NULL, NULL);


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."mfa_amr_claims" ("session_id", "created_at", "updated_at", "authentication_method", "id") VALUES
	('39ff8087-256e-44f3-9869-e010e979bea8', '2026-03-21 17:50:05.672885+00', '2026-03-21 17:50:05.672885+00', 'password', '3357b326-d13f-4fcf-aa67-e9346ef0fbb3');


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
	('00000000-0000-0000-0000-000000000000', 217, 'mwevsxmeh5ec', '78df0591-4c9d-4e4d-acb2-32ed95e261f5', true, '2026-03-21 17:50:05.661683+00', '2026-03-21 19:40:16.662085+00', NULL, '39ff8087-256e-44f3-9869-e010e979bea8'),
	('00000000-0000-0000-0000-000000000000', 218, 'kywwazrvrr2r', '78df0591-4c9d-4e4d-acb2-32ed95e261f5', true, '2026-03-21 19:40:16.677453+00', '2026-03-21 21:01:58.316289+00', 'mwevsxmeh5ec', '39ff8087-256e-44f3-9869-e010e979bea8'),
	('00000000-0000-0000-0000-000000000000', 219, 'kvn3u2ny45cq', '78df0591-4c9d-4e4d-acb2-32ed95e261f5', false, '2026-03-21 21:01:58.339927+00', '2026-03-21 21:01:58.339927+00', 'kywwazrvrr2r', '39ff8087-256e-44f3-9869-e010e979bea8');


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
-- Data for Name: sets; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: inventory; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."users" ("id", "user_id", "full_name", "avatar_url", "impact_points", "created_at", "updated_at", "email", "subscription_type", "subscription_status", "profile_completed", "user_status") VALUES
	('433add17-a414-4b39-8f80-4356d8fa7da5', '78df0591-4c9d-4e4d-acb2-32ed95e261f5', 'enrique perez', NULL, 0, '2026-03-21 17:50:05.5957+00', '2026-03-21 17:50:05.5957+00', 'user@brickshare.com', 'free', 'active', false, 'no_set'),
	('d0c69592-c3d0-4f9a-93eb-29adce8ea486', '83c0c80a-aef3-47cc-a6a9-dd9c5172dae4', 'Jan Perez', NULL, 0, '2026-03-21 21:06:40.145786+00', '2026-03-21 21:06:40.145786+00', 'user2@brickshare.com', 'free', 'active', false, 'no_set'),
	('f1f0bc83-d6ba-4f11-b740-09ae713b9839', '78f27662-6b00-4fec-9700-ac511bd5301e', 'Admin', NULL, 0, '2026-03-21 21:24:08.99455+00', '2026-03-21 21:24:08.99455+00', 'admin@brickshare.com', 'free', 'active', false, 'no_set');


--
-- Data for Name: set_piece_list; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."user_roles" ("id", "user_id", "role", "created_at") VALUES
	('2d1938a2-5861-4b18-94d2-34f8cbec7e30', '78df0591-4c9d-4e4d-acb2-32ed95e261f5', 'user', '2026-03-21 17:50:05.5957+00'),
	('1f3722af-6f35-431e-b3df-4dff352b643e', '83c0c80a-aef3-47cc-a6a9-dd9c5172dae4', 'user', '2026-03-21 21:06:40.145786+00'),
	('a385e066-2d9e-45e3-b301-3383efe7c391', '78f27662-6b00-4fec-9700-ac511bd5301e', 'user', '2026-03-21 21:24:08.99455+00');


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
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: supabase_auth_admin
--

SELECT pg_catalog.setval('"auth"."refresh_tokens_id_seq"', 229, true);


--
-- PostgreSQL database dump complete
--

-- \unrestrict ebVckroH2HeIEjURxZcr1V6gkTOYeUN7GUMELmeULVR4WbzWKSHSElFOdIJdNm9

RESET ALL;
