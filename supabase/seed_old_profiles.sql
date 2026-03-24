SET session_replication_role = replica;

--
-- PostgreSQL database dump
--

-- \restrict nz4ywwasCPyit3bdJmv1oHQQOfcm668rFx6DrRanCBCMyZmOg36txuE4vgfLZNZ

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
-- Data for Name: backoffice_operations; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: sets; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: inventory; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."profiles" ("id", "user_id", "full_name", "avatar_url", "sub_status", "impact_points", "created_at", "updated_at", "address", "address_extra", "zip_code", "city", "province", "phone", "email", "subscription_id", "subscription_type", "subscription_status") VALUES
	('433add17-a414-4b39-8f80-4356d8fa7da5', '78df0591-4c9d-4e4d-acb2-32ed95e261f5', 'enrique perez', NULL, 'free', 0, '2026-03-21 17:50:05.5957+00', '2026-03-21 17:50:05.5957+00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active'),
	('d0c69592-c3d0-4f9a-93eb-29adce8ea486', '83c0c80a-aef3-47cc-a6a9-dd9c5172dae4', 'Jan Perez', NULL, 'free', 0, '2026-03-21 21:06:40.145786+00', '2026-03-21 21:06:40.145786+00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active'),
	('f1f0bc83-d6ba-4f11-b740-09ae713b9839', '78f27662-6b00-4fec-9700-ac511bd5301e', 'Admin', NULL, 'free', 0, '2026-03-21 21:24:08.99455+00', '2026-03-21 21:24:08.99455+00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active');


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
-- PostgreSQL database dump complete
--

-- \unrestrict nz4ywwasCPyit3bdJmv1oHQQOfcm668rFx6DrRanCBCMyZmOg36txuE4vgfLZNZ

RESET ALL;
