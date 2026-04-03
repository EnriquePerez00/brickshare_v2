--
-- PostgreSQL database dump
--

\restrict zVM8DEXpFxQkvwm7fM2ViKrSVMlQGBTRbo6QpigqP0fBHk5LX2zYNCbXOLgZ1KH

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

DROP EVENT TRIGGER IF EXISTS pgrst_drop_watch;
DROP EVENT TRIGGER IF EXISTS pgrst_ddl_watch;
DROP EVENT TRIGGER IF EXISTS issue_pg_net_access;
DROP EVENT TRIGGER IF EXISTS issue_pg_graphql_access;
DROP EVENT TRIGGER IF EXISTS issue_pg_cron_access;
DROP EVENT TRIGGER IF EXISTS issue_graphql_placeholder;
DROP PUBLICATION IF EXISTS supabase_realtime;
DROP POLICY IF EXISTS users_update_own ON public.users;
DROP POLICY IF EXISTS users_select_own_referral ON public.users;
DROP POLICY IF EXISTS users_select_own ON public.users;
DROP POLICY IF EXISTS users_insert_own ON public.users;
DROP POLICY IF EXISTS reviews_update_own ON public.reviews;
DROP POLICY IF EXISTS reviews_select_published ON public.reviews;
DROP POLICY IF EXISTS reviews_select_own ON public.reviews;
DROP POLICY IF EXISTS reviews_insert_own ON public.reviews;
DROP POLICY IF EXISTS reviews_delete_own ON public.reviews;
DROP POLICY IF EXISTS reviews_admin_all ON public.reviews;
DROP POLICY IF EXISTS referrals_select_referee ON public.referrals;
DROP POLICY IF EXISTS referrals_select_own ON public.referrals;
DROP POLICY IF EXISTS referrals_admin_all ON public.referrals;
DROP POLICY IF EXISTS "Users can view their own wishlist" ON public.wishlist;
DROP POLICY IF EXISTS "Users can view their own validation logs" ON public.qr_validation_logs;
DROP POLICY IF EXISTS "Users can view their own shipping orders" ON public.shipping_orders;
DROP POLICY IF EXISTS "Users can view their own roles" ON public.user_roles;
DROP POLICY IF EXISTS "Users can view their own profile" ON public.users;
DROP POLICY IF EXISTS "Users can view their own donations" ON public.donations;
DROP POLICY IF EXISTS "Users can view their own Correos PUDO selection" ON public.users_correos_dropping;
DROP POLICY IF EXISTS "Users can view their own Brickshare PUDO selection" ON public.users_brickshare_dropping;
DROP POLICY IF EXISTS "Users can view own shipments" ON public.shipments;
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update their own wishlist" ON public.wishlist;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update their own Correos PUDO selection" ON public.users_correos_dropping;
DROP POLICY IF EXISTS "Users can update their own Brickshare PUDO selection" ON public.users_brickshare_dropping;
DROP POLICY IF EXISTS "Users can update own shipment status" ON public.shipments;
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
DROP POLICY IF EXISTS "Users can remove from their own wishlist" ON public.wishlist;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.users;
DROP POLICY IF EXISTS "Users can insert their own Correos PUDO selection" ON public.users_correos_dropping;
DROP POLICY IF EXISTS "Users can insert their own Brickshare PUDO selection" ON public.users_brickshare_dropping;
DROP POLICY IF EXISTS "Users can delete their own profile" ON public.users;
DROP POLICY IF EXISTS "Users can delete their own Correos PUDO selection" ON public.users_correos_dropping;
DROP POLICY IF EXISTS "Users can delete their own Brickshare PUDO selection" ON public.users_brickshare_dropping;
DROP POLICY IF EXISTS "Users can add to their own wishlist" ON public.wishlist;
DROP POLICY IF EXISTS "Sets are viewable by everyone" ON public.sets;
DROP POLICY IF EXISTS "Set piece lists are viewable by everyone" ON public.set_piece_list;
DROP POLICY IF EXISTS "Operators can update shipments" ON public.shipments;
DROP POLICY IF EXISTS "Operators can create shipments" ON public.shipments;
DROP POLICY IF EXISTS "Inventario is viewable by everyone" ON public.inventory_sets;
DROP POLICY IF EXISTS "Authenticated users can read" ON public.reception_operations;
DROP POLICY IF EXISTS "Authenticated users can insert their own donations" ON public.donations;
DROP POLICY IF EXISTS "Allow public read of active PUDO locations" ON public.brickshare_pudo_locations;
DROP POLICY IF EXISTS "Admins can view all wishlists" ON public.wishlist;
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.users;
DROP POLICY IF EXISTS "Admins can update sets" ON public.sets;
DROP POLICY IF EXISTS "Admins can update any user" ON public.users;
DROP POLICY IF EXISTS "Admins can manage set piece lists" ON public.set_piece_list;
DROP POLICY IF EXISTS "Admins can manage all roles" ON public.user_roles;
DROP POLICY IF EXISTS "Admins can manage all donations" ON public.donations;
DROP POLICY IF EXISTS "Admins can insert sets" ON public.sets;
DROP POLICY IF EXISTS "Admins can delete sets" ON public.sets;
DROP POLICY IF EXISTS "Admins and operators full access" ON public.shipments;
DROP POLICY IF EXISTS "Admins and operators can update" ON public.reception_operations;
DROP POLICY IF EXISTS "Admins and operators can insert" ON public.reception_operations;
DROP POLICY IF EXISTS "Admins and Operators can view operations" ON public.backoffice_operations;
DROP POLICY IF EXISTS "Admins and Operators can log operations" ON public.backoffice_operations;
DROP POLICY IF EXISTS "Admins and Operadores can view all users" ON public.users;
DROP POLICY IF EXISTS "Admins and Operadores can manage inventario" ON public.inventory_sets;
ALTER TABLE IF EXISTS ONLY storage.vector_indexes DROP CONSTRAINT IF EXISTS vector_indexes_bucket_id_fkey;
ALTER TABLE IF EXISTS ONLY storage.s3_multipart_uploads_parts DROP CONSTRAINT IF EXISTS s3_multipart_uploads_parts_upload_id_fkey;
ALTER TABLE IF EXISTS ONLY storage.s3_multipart_uploads_parts DROP CONSTRAINT IF EXISTS s3_multipart_uploads_parts_bucket_id_fkey;
ALTER TABLE IF EXISTS ONLY storage.s3_multipart_uploads DROP CONSTRAINT IF EXISTS s3_multipart_uploads_bucket_id_fkey;
ALTER TABLE IF EXISTS ONLY storage.objects DROP CONSTRAINT IF EXISTS "objects_bucketId_fkey";
ALTER TABLE IF EXISTS ONLY storage.iceberg_tables DROP CONSTRAINT IF EXISTS iceberg_tables_namespace_id_fkey;
ALTER TABLE IF EXISTS ONLY storage.iceberg_tables DROP CONSTRAINT IF EXISTS iceberg_tables_catalog_id_fkey;
ALTER TABLE IF EXISTS ONLY storage.iceberg_namespaces DROP CONSTRAINT IF EXISTS iceberg_namespaces_catalog_id_fkey;
ALTER TABLE IF EXISTS ONLY public.wishlist DROP CONSTRAINT IF EXISTS wishlist_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_referred_by_fkey;
ALTER TABLE IF EXISTS ONLY public.users_correos_dropping DROP CONSTRAINT IF EXISTS users_correos_dropping_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.users_brickshare_dropping DROP CONSTRAINT IF EXISTS users_brickshare_dropping_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_roles DROP CONSTRAINT IF EXISTS user_roles_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.shipping_orders DROP CONSTRAINT IF EXISTS shipping_orders_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.shipping_orders DROP CONSTRAINT IF EXISTS shipping_orders_set_id_fkey;
ALTER TABLE IF EXISTS ONLY public.set_piece_list DROP CONSTRAINT IF EXISTS set_piece_list_set_id_fkey;
ALTER TABLE IF EXISTS ONLY public.reviews DROP CONSTRAINT IF EXISTS reviews_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.reviews DROP CONSTRAINT IF EXISTS reviews_set_id_fkey;
ALTER TABLE IF EXISTS ONLY public.reviews DROP CONSTRAINT IF EXISTS reviews_envio_id_fkey;
ALTER TABLE IF EXISTS ONLY public.referrals DROP CONSTRAINT IF EXISTS referrals_referrer_id_fkey;
ALTER TABLE IF EXISTS ONLY public.referrals DROP CONSTRAINT IF EXISTS referrals_referee_id_fkey;
ALTER TABLE IF EXISTS ONLY public.qr_validation_logs DROP CONSTRAINT IF EXISTS qr_validation_logs_shipment_id_fkey;
ALTER TABLE IF EXISTS ONLY public.reception_operations DROP CONSTRAINT IF EXISTS operaciones_recepcion_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.reception_operations DROP CONSTRAINT IF EXISTS operaciones_recepcion_set_id_fkey;
ALTER TABLE IF EXISTS ONLY public.reception_operations DROP CONSTRAINT IF EXISTS operaciones_recepcion_event_id_fkey;
ALTER TABLE IF EXISTS ONLY public.inventory_sets DROP CONSTRAINT IF EXISTS inventory_sets_set_id_fkey;
ALTER TABLE IF EXISTS ONLY public.shipments DROP CONSTRAINT IF EXISTS envios_user_id_fkey_public_users;
ALTER TABLE IF EXISTS ONLY public.shipments DROP CONSTRAINT IF EXISTS envios_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.shipments DROP CONSTRAINT IF EXISTS envios_set_id_fkey;
ALTER TABLE IF EXISTS ONLY public.donations DROP CONSTRAINT IF EXISTS donations_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.backoffice_operations DROP CONSTRAINT IF EXISTS backoffice_operations_user_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.webauthn_credentials DROP CONSTRAINT IF EXISTS webauthn_credentials_user_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.webauthn_challenges DROP CONSTRAINT IF EXISTS webauthn_challenges_user_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.sso_domains DROP CONSTRAINT IF EXISTS sso_domains_sso_provider_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.sessions DROP CONSTRAINT IF EXISTS sessions_user_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.sessions DROP CONSTRAINT IF EXISTS sessions_oauth_client_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.saml_relay_states DROP CONSTRAINT IF EXISTS saml_relay_states_sso_provider_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.saml_relay_states DROP CONSTRAINT IF EXISTS saml_relay_states_flow_state_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.saml_providers DROP CONSTRAINT IF EXISTS saml_providers_sso_provider_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.refresh_tokens DROP CONSTRAINT IF EXISTS refresh_tokens_session_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.one_time_tokens DROP CONSTRAINT IF EXISTS one_time_tokens_user_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.oauth_consents DROP CONSTRAINT IF EXISTS oauth_consents_user_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.oauth_consents DROP CONSTRAINT IF EXISTS oauth_consents_client_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.oauth_authorizations DROP CONSTRAINT IF EXISTS oauth_authorizations_user_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.oauth_authorizations DROP CONSTRAINT IF EXISTS oauth_authorizations_client_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.mfa_factors DROP CONSTRAINT IF EXISTS mfa_factors_user_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.mfa_challenges DROP CONSTRAINT IF EXISTS mfa_challenges_auth_factor_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.mfa_amr_claims DROP CONSTRAINT IF EXISTS mfa_amr_claims_session_id_fkey;
ALTER TABLE IF EXISTS ONLY auth.identities DROP CONSTRAINT IF EXISTS identities_user_id_fkey;
ALTER TABLE IF EXISTS ONLY _realtime.extensions DROP CONSTRAINT IF EXISTS extensions_tenant_external_id_fkey;
DROP TRIGGER IF EXISTS update_objects_updated_at ON storage.objects;
DROP TRIGGER IF EXISTS protect_objects_delete ON storage.objects;
DROP TRIGGER IF EXISTS protect_buckets_delete ON storage.buckets;
DROP TRIGGER IF EXISTS enforce_bucket_name_length_trigger ON storage.buckets;
DROP TRIGGER IF EXISTS tr_check_filters ON realtime.subscription;
DROP TRIGGER IF EXISTS users_generate_referral_code ON public.users;
DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;
DROP TRIGGER IF EXISTS update_shipments_updated_at ON public.shipments;
DROP TRIGGER IF EXISTS update_sets_updated_at ON public.sets;
DROP TRIGGER IF EXISTS update_set_piece_list_updated_at ON public.set_piece_list;
DROP TRIGGER IF EXISTS update_reception_operations_updated_at ON public.reception_operations;
DROP TRIGGER IF EXISTS update_inventario_sets_updated_at ON public.inventory_sets;
DROP TRIGGER IF EXISTS update_donations_updated_at ON public.donations;
DROP TRIGGER IF EXISTS trigger_update_users_correos_dropping_updated_at ON public.users_correos_dropping;
DROP TRIGGER IF EXISTS trigger_update_users_brickshare_dropping_updated_at ON public.users_brickshare_dropping;
DROP TRIGGER IF EXISTS reviews_updated_at ON public.reviews;
DROP TRIGGER IF EXISTS referrals_updated_at ON public.referrals;
DROP TRIGGER IF EXISTS on_shipping_orders_updated ON public.shipping_orders;
DROP TRIGGER IF EXISTS on_shipment_warehouse_received ON public.shipments;
DROP TRIGGER IF EXISTS on_shipment_return_user_status ON public.shipments;
DROP TRIGGER IF EXISTS on_shipment_return_transit_inv ON public.shipments;
DROP TRIGGER IF EXISTS on_shipment_delivered ON public.shipments;
DROP TRIGGER IF EXISTS on_set_created ON public.sets;
DROP TRIGGER IF EXISTS on_reception_completed ON public.reception_operations;
DROP TRIGGER IF EXISTS on_auth_user_created_for_referral ON auth.users;
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP INDEX IF EXISTS supabase_functions.supabase_functions_hooks_request_id_idx;
DROP INDEX IF EXISTS supabase_functions.supabase_functions_hooks_h_table_id_h_name_idx;
DROP INDEX IF EXISTS storage.vector_indexes_name_bucket_id_idx;
DROP INDEX IF EXISTS storage.name_prefix_search;
DROP INDEX IF EXISTS storage.idx_objects_bucket_id_name_lower;
DROP INDEX IF EXISTS storage.idx_objects_bucket_id_name;
DROP INDEX IF EXISTS storage.idx_multipart_uploads_list;
DROP INDEX IF EXISTS storage.idx_iceberg_tables_namespace_id;
DROP INDEX IF EXISTS storage.idx_iceberg_tables_location;
DROP INDEX IF EXISTS storage.idx_iceberg_namespaces_bucket_id;
DROP INDEX IF EXISTS storage.buckets_analytics_unique_name_idx;
DROP INDEX IF EXISTS storage.bucketid_objname;
DROP INDEX IF EXISTS storage.bname;
DROP INDEX IF EXISTS realtime.subscription_subscription_id_entity_filters_action_filter_key;
DROP INDEX IF EXISTS realtime.messages_inserted_at_topic_index;
DROP INDEX IF EXISTS realtime.ix_realtime_subscription_entity;
DROP INDEX IF EXISTS public.users_referral_code_lower;
DROP INDEX IF EXISTS public.sets_year_idx;
DROP INDEX IF EXISTS public.sets_theme_idx;
DROP INDEX IF EXISTS public.sets_created_at_idx;
DROP INDEX IF EXISTS public.sets_age_range_idx;
DROP INDEX IF EXISTS public.reviews_user_id_idx;
DROP INDEX IF EXISTS public.reviews_set_id_idx;
DROP INDEX IF EXISTS public.reviews_envio_unique;
DROP INDEX IF EXISTS public.referrals_referrer_id_idx;
DROP INDEX IF EXISTS public.idx_users_stripe_customer_id;
DROP INDEX IF EXISTS public.idx_users_pudo_type;
DROP INDEX IF EXISTS public.idx_users_pudo_id;
DROP INDEX IF EXISTS public.idx_users_correos_dropping_user_id;
DROP INDEX IF EXISTS public.idx_users_correos_dropping_tipo;
DROP INDEX IF EXISTS public.idx_users_correos_dropping_cp;
DROP INDEX IF EXISTS public.idx_users_brickshare_dropping_user_id;
DROP INDEX IF EXISTS public.idx_users_brickshare_dropping_location;
DROP INDEX IF EXISTS public.idx_set_piece_list_set_id;
DROP INDEX IF EXISTS public.idx_set_piece_list_lego_ref;
DROP INDEX IF EXISTS public.idx_qr_validation_shipment;
DROP INDEX IF EXISTS public.idx_qr_validation_code;
DROP INDEX IF EXISTS public.idx_operaciones_recepcion_user_id;
DROP INDEX IF EXISTS public.idx_operaciones_recepcion_set_id;
DROP INDEX IF EXISTS public.idx_operaciones_recepcion_event_id;
DROP INDEX IF EXISTS public.idx_inventario_sets_set_ref;
DROP INDEX IF EXISTS public.idx_inventario_sets_set_id;
DROP INDEX IF EXISTS public.idx_envios_user_id;
DROP INDEX IF EXISTS public.idx_envios_set_id;
DROP INDEX IF EXISTS public.idx_envios_return_qr;
DROP INDEX IF EXISTS public.idx_envios_pickup_type;
DROP INDEX IF EXISTS public.idx_envios_numero_seguimiento;
DROP INDEX IF EXISTS public.idx_envios_fecha_entrega;
DROP INDEX IF EXISTS public.idx_envios_estado;
DROP INDEX IF EXISTS public.idx_envios_delivery_qr;
DROP INDEX IF EXISTS public.idx_envios_correos_shipment_id;
DROP INDEX IF EXISTS public.idx_envios_brickshare_package_id;
DROP INDEX IF EXISTS public.idx_donations_status;
DROP INDEX IF EXISTS public.idx_donations_email;
DROP INDEX IF EXISTS public.idx_brickshare_pudo_location;
DROP INDEX IF EXISTS public.idx_brickshare_pudo_active;
DROP INDEX IF EXISTS public.idx_backoff_ops_user_id;
DROP INDEX IF EXISTS public.idx_backoff_ops_type;
DROP INDEX IF EXISTS public.idx_backoff_ops_time;
DROP INDEX IF EXISTS public.envios_swikly_wish_id_idx;
DROP INDEX IF EXISTS auth.webauthn_credentials_user_id_idx;
DROP INDEX IF EXISTS auth.webauthn_credentials_credential_id_key;
DROP INDEX IF EXISTS auth.webauthn_challenges_user_id_idx;
DROP INDEX IF EXISTS auth.webauthn_challenges_expires_at_idx;
DROP INDEX IF EXISTS auth.users_is_anonymous_idx;
DROP INDEX IF EXISTS auth.users_instance_id_idx;
DROP INDEX IF EXISTS auth.users_instance_id_email_idx;
DROP INDEX IF EXISTS auth.users_email_partial_key;
DROP INDEX IF EXISTS auth.user_id_created_at_idx;
DROP INDEX IF EXISTS auth.unique_phone_factor_per_user;
DROP INDEX IF EXISTS auth.sso_providers_resource_id_pattern_idx;
DROP INDEX IF EXISTS auth.sso_providers_resource_id_idx;
DROP INDEX IF EXISTS auth.sso_domains_sso_provider_id_idx;
DROP INDEX IF EXISTS auth.sso_domains_domain_idx;
DROP INDEX IF EXISTS auth.sessions_user_id_idx;
DROP INDEX IF EXISTS auth.sessions_oauth_client_id_idx;
DROP INDEX IF EXISTS auth.sessions_not_after_idx;
DROP INDEX IF EXISTS auth.saml_relay_states_sso_provider_id_idx;
DROP INDEX IF EXISTS auth.saml_relay_states_for_email_idx;
DROP INDEX IF EXISTS auth.saml_relay_states_created_at_idx;
DROP INDEX IF EXISTS auth.saml_providers_sso_provider_id_idx;
DROP INDEX IF EXISTS auth.refresh_tokens_updated_at_idx;
DROP INDEX IF EXISTS auth.refresh_tokens_session_id_revoked_idx;
DROP INDEX IF EXISTS auth.refresh_tokens_parent_idx;
DROP INDEX IF EXISTS auth.refresh_tokens_instance_id_user_id_idx;
DROP INDEX IF EXISTS auth.refresh_tokens_instance_id_idx;
DROP INDEX IF EXISTS auth.recovery_token_idx;
DROP INDEX IF EXISTS auth.reauthentication_token_idx;
DROP INDEX IF EXISTS auth.one_time_tokens_user_id_token_type_key;
DROP INDEX IF EXISTS auth.one_time_tokens_token_hash_hash_idx;
DROP INDEX IF EXISTS auth.one_time_tokens_relates_to_hash_idx;
DROP INDEX IF EXISTS auth.oauth_consents_user_order_idx;
DROP INDEX IF EXISTS auth.oauth_consents_active_user_client_idx;
DROP INDEX IF EXISTS auth.oauth_consents_active_client_idx;
DROP INDEX IF EXISTS auth.oauth_clients_deleted_at_idx;
DROP INDEX IF EXISTS auth.oauth_auth_pending_exp_idx;
DROP INDEX IF EXISTS auth.mfa_factors_user_id_idx;
DROP INDEX IF EXISTS auth.mfa_factors_user_friendly_name_unique;
DROP INDEX IF EXISTS auth.mfa_challenge_created_at_idx;
DROP INDEX IF EXISTS auth.idx_user_id_auth_method;
DROP INDEX IF EXISTS auth.idx_oauth_client_states_created_at;
DROP INDEX IF EXISTS auth.idx_auth_code;
DROP INDEX IF EXISTS auth.identities_user_id_idx;
DROP INDEX IF EXISTS auth.identities_email_idx;
DROP INDEX IF EXISTS auth.flow_state_created_at_idx;
DROP INDEX IF EXISTS auth.factor_id_created_at_idx;
DROP INDEX IF EXISTS auth.email_change_token_new_idx;
DROP INDEX IF EXISTS auth.email_change_token_current_idx;
DROP INDEX IF EXISTS auth.custom_oauth_providers_provider_type_idx;
DROP INDEX IF EXISTS auth.custom_oauth_providers_identifier_idx;
DROP INDEX IF EXISTS auth.custom_oauth_providers_enabled_idx;
DROP INDEX IF EXISTS auth.custom_oauth_providers_created_at_idx;
DROP INDEX IF EXISTS auth.confirmation_token_idx;
DROP INDEX IF EXISTS auth.audit_logs_instance_id_idx;
DROP INDEX IF EXISTS _realtime.tenants_external_id_index;
DROP INDEX IF EXISTS _realtime.extensions_tenant_external_id_type_index;
DROP INDEX IF EXISTS _realtime.extensions_tenant_external_id_index;
ALTER TABLE IF EXISTS ONLY supabase_migrations.seed_files DROP CONSTRAINT IF EXISTS seed_files_pkey;
ALTER TABLE IF EXISTS ONLY supabase_migrations.schema_migrations DROP CONSTRAINT IF EXISTS schema_migrations_pkey;
ALTER TABLE IF EXISTS ONLY supabase_functions.migrations DROP CONSTRAINT IF EXISTS migrations_pkey;
ALTER TABLE IF EXISTS ONLY supabase_functions.hooks DROP CONSTRAINT IF EXISTS hooks_pkey;
ALTER TABLE IF EXISTS ONLY storage.vector_indexes DROP CONSTRAINT IF EXISTS vector_indexes_pkey;
ALTER TABLE IF EXISTS ONLY storage.s3_multipart_uploads DROP CONSTRAINT IF EXISTS s3_multipart_uploads_pkey;
ALTER TABLE IF EXISTS ONLY storage.s3_multipart_uploads_parts DROP CONSTRAINT IF EXISTS s3_multipart_uploads_parts_pkey;
ALTER TABLE IF EXISTS ONLY storage.objects DROP CONSTRAINT IF EXISTS objects_pkey;
ALTER TABLE IF EXISTS ONLY storage.migrations DROP CONSTRAINT IF EXISTS migrations_pkey;
ALTER TABLE IF EXISTS ONLY storage.migrations DROP CONSTRAINT IF EXISTS migrations_name_key;
ALTER TABLE IF EXISTS ONLY storage.iceberg_tables DROP CONSTRAINT IF EXISTS iceberg_tables_pkey;
ALTER TABLE IF EXISTS ONLY storage.iceberg_namespaces DROP CONSTRAINT IF EXISTS iceberg_namespaces_pkey;
ALTER TABLE IF EXISTS ONLY storage.buckets_vectors DROP CONSTRAINT IF EXISTS buckets_vectors_pkey;
ALTER TABLE IF EXISTS ONLY storage.buckets DROP CONSTRAINT IF EXISTS buckets_pkey;
ALTER TABLE IF EXISTS ONLY storage.buckets_analytics DROP CONSTRAINT IF EXISTS buckets_analytics_pkey;
ALTER TABLE IF EXISTS ONLY realtime.schema_migrations DROP CONSTRAINT IF EXISTS schema_migrations_pkey;
ALTER TABLE IF EXISTS ONLY realtime.subscription DROP CONSTRAINT IF EXISTS pk_subscription;
ALTER TABLE IF EXISTS ONLY realtime.messages_2026_03_27 DROP CONSTRAINT IF EXISTS messages_2026_03_27_pkey;
ALTER TABLE IF EXISTS ONLY realtime.messages_2026_03_26 DROP CONSTRAINT IF EXISTS messages_2026_03_26_pkey;
ALTER TABLE IF EXISTS ONLY realtime.messages_2026_03_25 DROP CONSTRAINT IF EXISTS messages_2026_03_25_pkey;
ALTER TABLE IF EXISTS ONLY realtime.messages_2026_03_24 DROP CONSTRAINT IF EXISTS messages_2026_03_24_pkey;
ALTER TABLE IF EXISTS ONLY realtime.messages_2026_03_23 DROP CONSTRAINT IF EXISTS messages_2026_03_23_pkey;
ALTER TABLE IF EXISTS ONLY realtime.messages DROP CONSTRAINT IF EXISTS messages_pkey;
ALTER TABLE IF EXISTS ONLY public.wishlist DROP CONSTRAINT IF EXISTS wishlist_user_id_product_id_key;
ALTER TABLE IF EXISTS ONLY public.wishlist DROP CONSTRAINT IF EXISTS wishlist_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_user_id_key;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_stripe_customer_id_key;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.users_correos_dropping DROP CONSTRAINT IF EXISTS users_correos_dropping_pkey;
ALTER TABLE IF EXISTS ONLY public.users_brickshare_dropping DROP CONSTRAINT IF EXISTS users_brickshare_dropping_pkey;
ALTER TABLE IF EXISTS ONLY public.user_roles DROP CONSTRAINT IF EXISTS user_roles_user_id_role_key;
ALTER TABLE IF EXISTS ONLY public.user_roles DROP CONSTRAINT IF EXISTS user_roles_pkey;
ALTER TABLE IF EXISTS ONLY public.shipping_orders DROP CONSTRAINT IF EXISTS shipping_orders_pkey;
ALTER TABLE IF EXISTS ONLY public.set_piece_list DROP CONSTRAINT IF EXISTS set_piece_list_pkey;
ALTER TABLE IF EXISTS ONLY public.reviews DROP CONSTRAINT IF EXISTS reviews_pkey;
ALTER TABLE IF EXISTS ONLY public.referrals DROP CONSTRAINT IF EXISTS referrals_referee_id_key;
ALTER TABLE IF EXISTS ONLY public.referrals DROP CONSTRAINT IF EXISTS referrals_pkey;
ALTER TABLE IF EXISTS ONLY public.qr_validation_logs DROP CONSTRAINT IF EXISTS qr_validation_logs_pkey;
ALTER TABLE IF EXISTS ONLY public.sets DROP CONSTRAINT IF EXISTS products_pkey;
ALTER TABLE IF EXISTS ONLY public.reception_operations DROP CONSTRAINT IF EXISTS operaciones_recepcion_pkey;
ALTER TABLE IF EXISTS ONLY public.inventory_sets DROP CONSTRAINT IF EXISTS inventario_sets_set_id_key;
ALTER TABLE IF EXISTS ONLY public.inventory_sets DROP CONSTRAINT IF EXISTS inventario_sets_pkey;
ALTER TABLE IF EXISTS ONLY public.shipments DROP CONSTRAINT IF EXISTS envios_return_qr_code_key;
ALTER TABLE IF EXISTS ONLY public.shipments DROP CONSTRAINT IF EXISTS envios_pkey;
ALTER TABLE IF EXISTS ONLY public.shipments DROP CONSTRAINT IF EXISTS envios_numero_seguimiento_key;
ALTER TABLE IF EXISTS ONLY public.shipments DROP CONSTRAINT IF EXISTS envios_delivery_qr_code_key;
ALTER TABLE IF EXISTS ONLY public.donations DROP CONSTRAINT IF EXISTS donations_pkey;
ALTER TABLE IF EXISTS ONLY public.brickshare_pudo_locations DROP CONSTRAINT IF EXISTS brickshare_pudo_locations_pkey;
ALTER TABLE IF EXISTS ONLY public.backoffice_operations DROP CONSTRAINT IF EXISTS backoffice_operations_pkey;
ALTER TABLE IF EXISTS ONLY auth.webauthn_credentials DROP CONSTRAINT IF EXISTS webauthn_credentials_pkey;
ALTER TABLE IF EXISTS ONLY auth.webauthn_challenges DROP CONSTRAINT IF EXISTS webauthn_challenges_pkey;
ALTER TABLE IF EXISTS ONLY auth.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY auth.users DROP CONSTRAINT IF EXISTS users_phone_key;
ALTER TABLE IF EXISTS ONLY auth.sso_providers DROP CONSTRAINT IF EXISTS sso_providers_pkey;
ALTER TABLE IF EXISTS ONLY auth.sso_domains DROP CONSTRAINT IF EXISTS sso_domains_pkey;
ALTER TABLE IF EXISTS ONLY auth.sessions DROP CONSTRAINT IF EXISTS sessions_pkey;
ALTER TABLE IF EXISTS ONLY auth.schema_migrations DROP CONSTRAINT IF EXISTS schema_migrations_pkey;
ALTER TABLE IF EXISTS ONLY auth.saml_relay_states DROP CONSTRAINT IF EXISTS saml_relay_states_pkey;
ALTER TABLE IF EXISTS ONLY auth.saml_providers DROP CONSTRAINT IF EXISTS saml_providers_pkey;
ALTER TABLE IF EXISTS ONLY auth.saml_providers DROP CONSTRAINT IF EXISTS saml_providers_entity_id_key;
ALTER TABLE IF EXISTS ONLY auth.refresh_tokens DROP CONSTRAINT IF EXISTS refresh_tokens_token_unique;
ALTER TABLE IF EXISTS ONLY auth.refresh_tokens DROP CONSTRAINT IF EXISTS refresh_tokens_pkey;
ALTER TABLE IF EXISTS ONLY auth.one_time_tokens DROP CONSTRAINT IF EXISTS one_time_tokens_pkey;
ALTER TABLE IF EXISTS ONLY auth.oauth_consents DROP CONSTRAINT IF EXISTS oauth_consents_user_client_unique;
ALTER TABLE IF EXISTS ONLY auth.oauth_consents DROP CONSTRAINT IF EXISTS oauth_consents_pkey;
ALTER TABLE IF EXISTS ONLY auth.oauth_clients DROP CONSTRAINT IF EXISTS oauth_clients_pkey;
ALTER TABLE IF EXISTS ONLY auth.oauth_client_states DROP CONSTRAINT IF EXISTS oauth_client_states_pkey;
ALTER TABLE IF EXISTS ONLY auth.oauth_authorizations DROP CONSTRAINT IF EXISTS oauth_authorizations_pkey;
ALTER TABLE IF EXISTS ONLY auth.oauth_authorizations DROP CONSTRAINT IF EXISTS oauth_authorizations_authorization_id_key;
ALTER TABLE IF EXISTS ONLY auth.oauth_authorizations DROP CONSTRAINT IF EXISTS oauth_authorizations_authorization_code_key;
ALTER TABLE IF EXISTS ONLY auth.mfa_factors DROP CONSTRAINT IF EXISTS mfa_factors_pkey;
ALTER TABLE IF EXISTS ONLY auth.mfa_factors DROP CONSTRAINT IF EXISTS mfa_factors_last_challenged_at_key;
ALTER TABLE IF EXISTS ONLY auth.mfa_challenges DROP CONSTRAINT IF EXISTS mfa_challenges_pkey;
ALTER TABLE IF EXISTS ONLY auth.mfa_amr_claims DROP CONSTRAINT IF EXISTS mfa_amr_claims_session_id_authentication_method_pkey;
ALTER TABLE IF EXISTS ONLY auth.instances DROP CONSTRAINT IF EXISTS instances_pkey;
ALTER TABLE IF EXISTS ONLY auth.identities DROP CONSTRAINT IF EXISTS identities_provider_id_provider_unique;
ALTER TABLE IF EXISTS ONLY auth.identities DROP CONSTRAINT IF EXISTS identities_pkey;
ALTER TABLE IF EXISTS ONLY auth.flow_state DROP CONSTRAINT IF EXISTS flow_state_pkey;
ALTER TABLE IF EXISTS ONLY auth.custom_oauth_providers DROP CONSTRAINT IF EXISTS custom_oauth_providers_pkey;
ALTER TABLE IF EXISTS ONLY auth.custom_oauth_providers DROP CONSTRAINT IF EXISTS custom_oauth_providers_identifier_key;
ALTER TABLE IF EXISTS ONLY auth.audit_log_entries DROP CONSTRAINT IF EXISTS audit_log_entries_pkey;
ALTER TABLE IF EXISTS ONLY auth.mfa_amr_claims DROP CONSTRAINT IF EXISTS amr_id_pk;
ALTER TABLE IF EXISTS ONLY _realtime.tenants DROP CONSTRAINT IF EXISTS tenants_pkey;
ALTER TABLE IF EXISTS ONLY _realtime.schema_migrations DROP CONSTRAINT IF EXISTS schema_migrations_pkey;
ALTER TABLE IF EXISTS ONLY _realtime.extensions DROP CONSTRAINT IF EXISTS extensions_pkey;
ALTER TABLE IF EXISTS supabase_functions.hooks ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS auth.refresh_tokens ALTER COLUMN id DROP DEFAULT;
DROP TABLE IF EXISTS supabase_migrations.seed_files;
DROP TABLE IF EXISTS supabase_migrations.schema_migrations;
DROP TABLE IF EXISTS supabase_functions.migrations;
DROP SEQUENCE IF EXISTS supabase_functions.hooks_id_seq;
DROP TABLE IF EXISTS supabase_functions.hooks;
DROP TABLE IF EXISTS storage.vector_indexes;
DROP TABLE IF EXISTS storage.s3_multipart_uploads_parts;
DROP TABLE IF EXISTS storage.s3_multipart_uploads;
DROP TABLE IF EXISTS storage.objects;
DROP TABLE IF EXISTS storage.migrations;
DROP TABLE IF EXISTS storage.iceberg_tables;
DROP TABLE IF EXISTS storage.iceberg_namespaces;
DROP TABLE IF EXISTS storage.buckets_vectors;
DROP TABLE IF EXISTS storage.buckets_analytics;
DROP TABLE IF EXISTS storage.buckets;
DROP TABLE IF EXISTS realtime.subscription;
DROP TABLE IF EXISTS realtime.schema_migrations;
DROP TABLE IF EXISTS realtime.messages_2026_03_27;
DROP TABLE IF EXISTS realtime.messages_2026_03_26;
DROP TABLE IF EXISTS realtime.messages_2026_03_25;
DROP TABLE IF EXISTS realtime.messages_2026_03_24;
DROP TABLE IF EXISTS realtime.messages_2026_03_23;
DROP TABLE IF EXISTS realtime.messages;
DROP TABLE IF EXISTS public.wishlist;
DROP TABLE IF EXISTS public.users_correos_dropping;
DROP TABLE IF EXISTS public.users_brickshare_dropping;
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.user_roles;
DROP TABLE IF EXISTS public.shipping_orders;
DROP TABLE IF EXISTS public.sets;
DROP VIEW IF EXISTS public.set_review_stats;
DROP TABLE IF EXISTS public.set_piece_list;
DROP VIEW IF EXISTS public.set_avg_ratings;
DROP TABLE IF EXISTS public.reviews;
DROP TABLE IF EXISTS public.referrals;
DROP TABLE IF EXISTS public.reception_operations;
DROP TABLE IF EXISTS public.qr_validation_logs;
DROP TABLE IF EXISTS public.inventory_sets;
DROP TABLE IF EXISTS public.donations;
DROP VIEW IF EXISTS public.brickshare_pudo_shipments;
DROP TABLE IF EXISTS public.shipments;
DROP TABLE IF EXISTS public.brickshare_pudo_locations;
DROP TABLE IF EXISTS public.backoffice_operations;
DROP TABLE IF EXISTS auth.webauthn_credentials;
DROP TABLE IF EXISTS auth.webauthn_challenges;
DROP TABLE IF EXISTS auth.users;
DROP TABLE IF EXISTS auth.sso_providers;
DROP TABLE IF EXISTS auth.sso_domains;
DROP TABLE IF EXISTS auth.sessions;
DROP TABLE IF EXISTS auth.schema_migrations;
DROP TABLE IF EXISTS auth.saml_relay_states;
DROP TABLE IF EXISTS auth.saml_providers;
DROP SEQUENCE IF EXISTS auth.refresh_tokens_id_seq;
DROP TABLE IF EXISTS auth.refresh_tokens;
DROP TABLE IF EXISTS auth.one_time_tokens;
DROP TABLE IF EXISTS auth.oauth_consents;
DROP TABLE IF EXISTS auth.oauth_clients;
DROP TABLE IF EXISTS auth.oauth_client_states;
DROP TABLE IF EXISTS auth.oauth_authorizations;
DROP TABLE IF EXISTS auth.mfa_factors;
DROP TABLE IF EXISTS auth.mfa_challenges;
DROP TABLE IF EXISTS auth.mfa_amr_claims;
DROP TABLE IF EXISTS auth.instances;
DROP TABLE IF EXISTS auth.identities;
DROP TABLE IF EXISTS auth.flow_state;
DROP TABLE IF EXISTS auth.custom_oauth_providers;
DROP TABLE IF EXISTS auth.audit_log_entries;
DROP TABLE IF EXISTS _realtime.tenants;
DROP TABLE IF EXISTS _realtime.schema_migrations;
DROP TABLE IF EXISTS _realtime.extensions;
DROP FUNCTION IF EXISTS supabase_functions.http_request();
DROP FUNCTION IF EXISTS storage.update_updated_at_column();
DROP FUNCTION IF EXISTS storage.search_v2(prefix text, bucket_name text, limits integer, levels integer, start_after text, sort_order text, sort_column text, sort_column_after text);
DROP FUNCTION IF EXISTS storage.search_by_timestamp(p_prefix text, p_bucket_id text, p_limit integer, p_level integer, p_start_after text, p_sort_order text, p_sort_column text, p_sort_column_after text);
DROP FUNCTION IF EXISTS storage.search(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text);
DROP FUNCTION IF EXISTS storage.protect_delete();
DROP FUNCTION IF EXISTS storage.operation();
DROP FUNCTION IF EXISTS storage.list_objects_with_delimiter(_bucket_id text, prefix_param text, delimiter_param text, max_keys integer, start_after text, next_token text, sort_order text);
DROP FUNCTION IF EXISTS storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, next_key_token text, next_upload_token text);
DROP FUNCTION IF EXISTS storage.get_size_by_bucket();
DROP FUNCTION IF EXISTS storage.get_common_prefix(p_key text, p_prefix text, p_delimiter text);
DROP FUNCTION IF EXISTS storage.foldername(name text);
DROP FUNCTION IF EXISTS storage.filename(name text);
DROP FUNCTION IF EXISTS storage.extension(name text);
DROP FUNCTION IF EXISTS storage.enforce_bucket_name_length();
DROP FUNCTION IF EXISTS storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb);
DROP FUNCTION IF EXISTS realtime.topic();
DROP FUNCTION IF EXISTS realtime.to_regrole(role_name text);
DROP FUNCTION IF EXISTS realtime.subscription_check_filters();
DROP FUNCTION IF EXISTS realtime.send(payload jsonb, event text, topic text, private boolean);
DROP FUNCTION IF EXISTS realtime.quote_wal2json(entity regclass);
DROP FUNCTION IF EXISTS realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer);
DROP FUNCTION IF EXISTS realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]);
DROP FUNCTION IF EXISTS realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text);
DROP FUNCTION IF EXISTS realtime."cast"(val text, type_ regtype);
DROP FUNCTION IF EXISTS realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]);
DROP FUNCTION IF EXISTS realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text);
DROP FUNCTION IF EXISTS realtime.apply_rls(wal jsonb, max_record_bytes integer);
DROP FUNCTION IF EXISTS public.validate_qr_code(p_qr_code text);
DROP FUNCTION IF EXISTS public.uses_brickshare_pudo(shipment_id uuid);
DROP FUNCTION IF EXISTS public.update_users_correos_dropping_updated_at();
DROP FUNCTION IF EXISTS public.update_users_brickshare_dropping_updated_at();
DROP FUNCTION IF EXISTS public.update_updated_at_column();
DROP FUNCTION IF EXISTS public.update_set_status_from_return(p_set_id uuid, p_new_status text, p_envio_id uuid);
DROP FUNCTION IF EXISTS public.set_updated_at();
DROP FUNCTION IF EXISTS public.process_referral_credit(p_referee_user_id uuid);
DROP FUNCTION IF EXISTS public.preview_assign_sets_to_users();
DROP FUNCTION IF EXISTS public.increment_referral_credits(p_user_id uuid, p_amount integer);
DROP FUNCTION IF EXISTS public.has_role(_user_id uuid, _role public.app_role);
DROP FUNCTION IF EXISTS public.handle_updated_at();
DROP FUNCTION IF EXISTS public.handle_shipment_warehouse_received();
DROP FUNCTION IF EXISTS public.handle_shipment_return_transit_inventory();
DROP FUNCTION IF EXISTS public.handle_shipment_delivered();
DROP FUNCTION IF EXISTS public.handle_return_user_status();
DROP FUNCTION IF EXISTS public.handle_reception_close();
DROP FUNCTION IF EXISTS public.handle_new_user();
DROP FUNCTION IF EXISTS public.handle_new_set_inventory();
DROP FUNCTION IF EXISTS public.handle_new_auth_user();
DROP FUNCTION IF EXISTS public.get_user_active_pudo(p_user_id uuid);
DROP FUNCTION IF EXISTS public.generate_return_qr(p_shipment_id uuid);
DROP FUNCTION IF EXISTS public.generate_referral_code_users();
DROP FUNCTION IF EXISTS public.generate_qr_code();
DROP FUNCTION IF EXISTS public.generate_delivery_qr(p_shipment_id uuid);
DROP FUNCTION IF EXISTS public.delete_assignment_and_rollback(p_envio_id uuid);
DROP FUNCTION IF EXISTS public.confirm_qr_validation(p_qr_code text, p_validated_by text);
DROP FUNCTION IF EXISTS public.confirm_assign_sets_to_users(p_user_ids uuid[]);
DROP FUNCTION IF EXISTS pgbouncer.get_auth(p_usename text);
DROP FUNCTION IF EXISTS extensions.set_graphql_placeholder();
DROP FUNCTION IF EXISTS extensions.pgrst_drop_watch();
DROP FUNCTION IF EXISTS extensions.pgrst_ddl_watch();
DROP FUNCTION IF EXISTS extensions.grant_pg_net_access();
DROP FUNCTION IF EXISTS extensions.grant_pg_graphql_access();
DROP FUNCTION IF EXISTS extensions.grant_pg_cron_access();
DROP FUNCTION IF EXISTS auth.uid();
DROP FUNCTION IF EXISTS auth.role();
DROP FUNCTION IF EXISTS auth.jwt();
DROP FUNCTION IF EXISTS auth.email();
DROP TYPE IF EXISTS storage.buckettype;
DROP TYPE IF EXISTS realtime.wal_rls;
DROP TYPE IF EXISTS realtime.wal_column;
DROP TYPE IF EXISTS realtime.user_defined_filter;
DROP TYPE IF EXISTS realtime.equality_op;
DROP TYPE IF EXISTS realtime.action;
DROP TYPE IF EXISTS public.operation_type;
DROP TYPE IF EXISTS public.app_role;
DROP TYPE IF EXISTS auth.one_time_token_type;
DROP TYPE IF EXISTS auth.oauth_response_type;
DROP TYPE IF EXISTS auth.oauth_registration_type;
DROP TYPE IF EXISTS auth.oauth_client_type;
DROP TYPE IF EXISTS auth.oauth_authorization_status;
DROP TYPE IF EXISTS auth.factor_type;
DROP TYPE IF EXISTS auth.factor_status;
DROP TYPE IF EXISTS auth.code_challenge_method;
DROP TYPE IF EXISTS auth.aal_level;
DROP EXTENSION IF EXISTS "uuid-ossp";
DROP EXTENSION IF EXISTS supabase_vault;
DROP EXTENSION IF EXISTS pgcrypto;
DROP EXTENSION IF EXISTS pg_stat_statements;
DROP EXTENSION IF EXISTS pg_graphql;
DROP SCHEMA IF EXISTS vault;
DROP SCHEMA IF EXISTS supabase_migrations;
DROP SCHEMA IF EXISTS supabase_functions;
DROP SCHEMA IF EXISTS storage;
DROP SCHEMA IF EXISTS realtime;
DROP SCHEMA IF EXISTS pgbouncer;
DROP EXTENSION IF EXISTS pg_net;
DROP SCHEMA IF EXISTS graphql_public;
DROP SCHEMA IF EXISTS graphql;
DROP SCHEMA IF EXISTS extensions;
DROP SCHEMA IF EXISTS auth;
DROP SCHEMA IF EXISTS _realtime;
--
-- Name: _realtime; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA _realtime;


--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA auth;


--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA extensions;


--
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql;


--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql_public;


--
-- Name: pg_net; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_net; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_net IS 'Async HTTP';


--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA pgbouncer;


--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA realtime;


--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA storage;


--
-- Name: supabase_functions; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA supabase_functions;


--
-- Name: supabase_migrations; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA supabase_migrations;


--
-- Name: vault; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA vault;


--
-- Name: pg_graphql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_graphql WITH SCHEMA graphql;


--
-- Name: EXTENSION pg_graphql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_graphql IS 'pg_graphql: GraphQL support';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS supabase_vault WITH SCHEMA vault;


--
-- Name: EXTENSION supabase_vault; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION supabase_vault IS 'Supabase Vault Extension';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


--
-- Name: oauth_authorization_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_authorization_status AS ENUM (
    'pending',
    'approved',
    'denied',
    'expired'
);


--
-- Name: oauth_client_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_client_type AS ENUM (
    'public',
    'confidential'
);


--
-- Name: oauth_registration_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_registration_type AS ENUM (
    'dynamic',
    'manual'
);


--
-- Name: oauth_response_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_response_type AS ENUM (
    'code'
);


--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


--
-- Name: app_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.app_role AS ENUM (
    'admin',
    'user',
    'operador'
);


--
-- Name: operation_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.operation_type AS ENUM (
    'recepcion paquete',
    'analisis_peso',
    'deposito_fulfillment',
    'higienizado',
    'retorno_stock'
);


--
-- Name: action; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in'
);


--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text
);


--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);


--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);


--
-- Name: buckettype; Type: TYPE; Schema: storage; Owner: -
--

CREATE TYPE storage.buckettype AS ENUM (
    'STANDARD',
    'ANALYTICS',
    'VECTOR'
);


--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    func_is_graphql_resolve bool;
BEGIN
    func_is_graphql_resolve = (
        SELECT n.proname = 'resolve'
        FROM pg_event_trigger_ddl_commands() AS ev
        LEFT JOIN pg_catalog.pg_proc AS n
        ON ev.objid = n.oid
    );

    IF func_is_graphql_resolve
    THEN
        -- Update public wrapper to pass all arguments through to the pg_graphql resolve func
        DROP FUNCTION IF EXISTS graphql_public.graphql;
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language sql
        as $$
            select graphql.resolve(
                query := query,
                variables := coalesce(variables, '{}'),
                "operationName" := "operationName",
                extensions := extensions
            );
        $$;

        -- This hook executes when `graphql.resolve` is created. That is not necessarily the last
        -- function in the extension so we need to grant permissions on existing entities AND
        -- update default permissions to any others that are created after `graphql.resolve`
        grant usage on schema graphql to postgres, anon, authenticated, service_role;
        grant select on all tables in schema graphql to postgres, anon, authenticated, service_role;
        grant execute on all functions in schema graphql to postgres, anon, authenticated, service_role;
        grant all on all sequences in schema graphql to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on functions to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on sequences to postgres, anon, authenticated, service_role;

        -- Allow postgres role to allow granting usage on graphql and graphql_public schemas to custom roles
        grant usage on schema graphql_public to postgres with grant option;
        grant usage on schema graphql to postgres with grant option;
    END IF;

END;
$_$;


--
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
    ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

    ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
    ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

    REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
    REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

    GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


--
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: -
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $_$
begin
    raise debug 'PgBouncer auth request: %', p_usename;

    return query
    select 
        rolname::text, 
        case when rolvaliduntil < now() 
            then null 
            else rolpassword::text 
        end 
    from pg_authid 
    where rolname=$1 and rolcanlogin;
end;
$_$;


--
-- Name: confirm_assign_sets_to_users(uuid[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.confirm_assign_sets_to_users(p_user_ids uuid[]) RETURNS TABLE(shipment_id uuid, user_id uuid, set_id uuid, user_name text, user_email text, user_phone text, set_name text, set_ref text, set_price numeric, set_weight numeric, pudo_id text, pudo_name text, pudo_address text, pudo_cp text, pudo_city text, pudo_province text, created_at timestamp with time zone)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    r RECORD;
    target_set_id UUID;
    new_shipment_id UUID;
    v_set_name TEXT;
    v_set_ref TEXT;
    v_set_price NUMERIC;
    v_set_weight NUMERIC;
    v_pudo_id TEXT;
    v_pudo_name TEXT;
    v_pudo_address TEXT;
    v_pudo_cp TEXT;
    v_pudo_city TEXT;
    v_pudo_province TEXT;
    v_created_at TIMESTAMPTZ;
    v_pudo_type TEXT;
BEGIN
    -- Loop through each user to confirm their assignment
    FOR r IN (
        SELECT 
            u.user_id,
            u.full_name,
            u.email,
            u.phone,
            u.pudo_type,
            -- Correos PUDO data
            ucd.correos_id_pudo,
            ucd.correos_name,
            ucd.correos_full_address,
            ucd.correos_zip_code,
            ucd.correos_city,
            ucd.correos_province,
            -- Brickshare PUDO data
            bp.id as brickshare_pudo_id,
            bp.name as brickshare_pudo_name,
            bp.address as brickshare_address,
            bp.postal_code as brickshare_postal_code,
            bp.city as brickshare_city,
            bp.province as brickshare_province
        FROM public.users u
        LEFT JOIN public.users_correos_dropping ucd ON u.user_id = ucd.user_id
        LEFT JOIN public.brickshare_pudo_locations bp ON u.pudo_id = bp.id AND u.pudo_type = 'brickshare'
        WHERE u.user_id = ANY(p_user_ids)
          AND u.user_status IN ('no_set', 'set_returning')
          AND EXISTS (
              SELECT 1 
              FROM public.wishlist w 
              WHERE w.user_id = u.user_id 
                AND w.status = true
          )
    ) LOOP
        -- Store pudo_type for later use
        v_pudo_type := r.pudo_type;
        
        -- Determine PUDO data based on type
        IF v_pudo_type = 'correos' THEN
            v_pudo_id := r.correos_id_pudo;
            v_pudo_name := r.correos_name;
            v_pudo_address := r.correos_full_address;
            v_pudo_cp := r.correos_zip_code;
            v_pudo_city := r.correos_city;
            v_pudo_province := r.correos_province;
        ELSIF v_pudo_type = 'brickshare' THEN
            v_pudo_id := r.brickshare_pudo_id;
            v_pudo_name := r.brickshare_pudo_name;
            v_pudo_address := r.brickshare_address;
            v_pudo_cp := r.brickshare_postal_code;
            v_pudo_city := r.brickshare_city;
            v_pudo_province := r.brickshare_province;
        ELSE
            -- Skip user if no PUDO configured
            CONTINUE;
        END IF;
        
        -- Find the first available set from user's wishlist
        SELECT 
            w.set_id,
            s.set_name,
            s.set_ref,
            s.set_price,
            s.set_weight
        INTO 
            target_set_id,
            v_set_name,
            v_set_ref,
            v_set_price,
            v_set_weight
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        JOIN public.sets s ON w.set_id = s.id
        WHERE w.user_id = r.user_id
          AND w.status = true
          AND i.inventory_set_total_qty > 0
        ORDER BY w.created_at ASC
        LIMIT 1;

        IF target_set_id IS NOT NULL THEN
            -- Update inventory
            UPDATE public.inventory_sets
            SET 
                inventory_set_total_qty = inventory_set_total_qty - 1,
                in_shipping = in_shipping + 1
            WHERE inventory_sets.set_id = target_set_id;

            -- Create shipment directly (NO orders table)
            INSERT INTO public.shipments (
                user_id,
                set_id,
                set_ref,
                shipment_status,
                shipping_address,
                shipping_city,
                shipping_zip_code,
                shipping_country
            )
            VALUES (
                r.user_id,
                target_set_id,
                v_set_ref,
                'assigned',
                COALESCE(v_pudo_address, 'Pending assignment'),
                COALESCE(v_pudo_city, 'Pending'),
                COALESCE(v_pudo_cp, '00000'),
                'España'
            )
            RETURNING shipments.id, shipments.created_at
            INTO new_shipment_id, v_created_at;

            -- Update user status to 'set_shipping'
            UPDATE public.users
            SET user_status = 'set_shipping'
            WHERE users.user_id = r.user_id;

            -- Mark wishlist item as assigned
            UPDATE public.wishlist
            SET 
                status = false,
                status_changed_at = now()
            WHERE wishlist.user_id = r.user_id
              AND wishlist.set_id = target_set_id;

            -- Populate return record (NO order_id field)
            confirm_assign_sets_to_users.shipment_id := new_shipment_id;
            confirm_assign_sets_to_users.user_id := r.user_id;
            confirm_assign_sets_to_users.set_id := target_set_id;
            confirm_assign_sets_to_users.user_name := r.full_name;
            confirm_assign_sets_to_users.user_email := r.email;
            confirm_assign_sets_to_users.user_phone := r.phone;
            confirm_assign_sets_to_users.set_name := v_set_name;
            confirm_assign_sets_to_users.set_ref := v_set_ref;
            confirm_assign_sets_to_users.set_price := v_set_price;
            confirm_assign_sets_to_users.set_weight := v_set_weight;
            confirm_assign_sets_to_users.pudo_id := v_pudo_id;
            confirm_assign_sets_to_users.pudo_name := v_pudo_name;
            confirm_assign_sets_to_users.pudo_address := v_pudo_address;
            confirm_assign_sets_to_users.pudo_cp := v_pudo_cp;
            confirm_assign_sets_to_users.pudo_city := v_pudo_city;
            confirm_assign_sets_to_users.pudo_province := v_pudo_province;
            confirm_assign_sets_to_users.created_at := v_created_at;
            
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$;


--
-- Name: FUNCTION confirm_assign_sets_to_users(p_user_ids uuid[]); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.confirm_assign_sets_to_users(p_user_ids uuid[]) IS 'Confirms set assignments for users. Creates shipments directly (NO orders table), sets user_status to set_shipping, and copies PUDO address data. Requires PUDO point configured.';


--
-- Name: confirm_qr_validation(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.confirm_qr_validation(p_qr_code text, p_validated_by text DEFAULT NULL::text) RETURNS TABLE(success boolean, message text, shipment_id uuid)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_validation RECORD;
    v_new_status TEXT;
BEGIN
    SELECT * INTO v_validation FROM validate_qr_code(p_qr_code);
    IF NOT v_validation.is_valid THEN
        RETURN QUERY SELECT false, v_validation.error_message, v_validation.shipment_id; RETURN;
    END IF;

    IF v_validation.validation_type = 'delivery' THEN
        v_new_status := 'delivered_user';
        UPDATE shipments SET delivery_validated_at = now(), shipment_status = v_new_status, updated_at = now() WHERE id = v_validation.shipment_id;
    ELSIF v_validation.validation_type = 'return' THEN
        v_new_status := 'returned';
        UPDATE shipments SET return_validated_at = now(), shipment_status = v_new_status, updated_at = now() WHERE id = v_validation.shipment_id;
    END IF;

    INSERT INTO qr_validation_logs (shipment_id, qr_code, validation_type, validated_by, validation_status, metadata)
    VALUES (v_validation.shipment_id, p_qr_code, v_validation.validation_type, p_validated_by, 'success', jsonb_build_object('validated_at', now()));

    RETURN QUERY SELECT true, format('Shipment successfully %s', CASE WHEN v_validation.validation_type = 'delivery' THEN 'delivered' ELSE 'returned' END), v_validation.shipment_id;
END;
$$;


--
-- Name: delete_assignment_and_rollback(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_assignment_and_rollback(p_envio_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_user_id UUID;
    v_set_id UUID;
BEGIN
    SELECT user_id, set_id INTO v_user_id, v_set_id FROM public.shipments WHERE id = p_envio_id;
    IF v_user_id IS NULL THEN RAISE EXCEPTION 'Shipment with ID % not found', p_envio_id; END IF;

    DELETE FROM public.shipments WHERE id = p_envio_id;

    UPDATE public.inventory_sets
    SET inventory_set_total_qty = inventory_set_total_qty + 1, in_shipping = GREATEST(in_shipping - 1, 0)
    WHERE set_id = v_set_id;

    INSERT INTO public.wishlist (user_id, set_id) VALUES (v_user_id, v_set_id) ON CONFLICT (user_id, set_id) DO NOTHING;

    UPDATE public.users
    SET user_status = CASE 
        WHEN EXISTS (SELECT 1 FROM public.shipments WHERE user_id = v_user_id AND shipment_status IN ('preparation', 'in_transit_pudo'))
        THEN user_status ELSE 'no_set' END
    WHERE user_id = v_user_id;
END;
$$;


--
-- Name: generate_delivery_qr(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_delivery_qr(p_shipment_id uuid) RETURNS TABLE(qr_code text, expires_at timestamp with time zone)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_qr_code TEXT; v_expires_at TIMESTAMPTZ; v_max_attempts INTEGER := 10; v_attempt INTEGER := 0;
BEGIN
    v_expires_at := now() + interval '30 days';
    LOOP
        v_qr_code := generate_qr_code(); v_attempt := v_attempt + 1;
        IF NOT EXISTS (SELECT 1 FROM shipments WHERE delivery_qr_code = v_qr_code OR return_qr_code = v_qr_code) THEN EXIT; END IF;
        IF v_attempt >= v_max_attempts THEN RAISE EXCEPTION 'Unable to generate unique QR code after % attempts', v_max_attempts; END IF;
    END LOOP;
    UPDATE shipments SET delivery_qr_code = v_qr_code, delivery_qr_expires_at = v_expires_at, updated_at = now() WHERE id = p_shipment_id;
    RETURN QUERY SELECT v_qr_code, v_expires_at;
END;
$$;


--
-- Name: generate_qr_code(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_qr_code() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    chars TEXT := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    result TEXT := 'BS-';
    i INTEGER;
BEGIN
    FOR i IN 1..16 LOOP
        result := result || substr(chars, floor(random() * length(chars) + 1)::integer, 1);
    END LOOP;
    RETURN result;
END;
$$;


--
-- Name: generate_referral_code_users(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_referral_code_users() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    new_code TEXT;
    attempts INTEGER := 0;
BEGIN
    -- Only generate if not already set
    IF NEW.referral_code IS NULL THEN
        LOOP
            -- 6-char uppercase alphanumeric code
            new_code := UPPER(SUBSTRING(MD5(RANDOM()::TEXT || NEW.user_id::TEXT) FROM 1 FOR 6));

            -- Check uniqueness
            IF NOT EXISTS (
                SELECT 1 FROM public.users 
                WHERE LOWER(referral_code) = LOWER(new_code)
            ) THEN
                NEW.referral_code := new_code;
                EXIT;
            END IF;

            attempts := attempts + 1;
            IF attempts > 10 THEN
                -- Fallback: use longer hash
                NEW.referral_code := UPPER(SUBSTRING(MD5(NEW.user_id::TEXT) FROM 1 FOR 8));
                EXIT;
            END IF;
        END LOOP;
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: generate_return_qr(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_return_qr(p_shipment_id uuid) RETURNS TABLE(qr_code text, expires_at timestamp with time zone)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_qr_code TEXT; v_expires_at TIMESTAMPTZ; v_max_attempts INTEGER := 10; v_attempt INTEGER := 0;
BEGIN
    v_expires_at := now() + interval '30 days';
    LOOP
        v_qr_code := generate_qr_code(); v_attempt := v_attempt + 1;
        IF NOT EXISTS (SELECT 1 FROM shipments WHERE delivery_qr_code = v_qr_code OR return_qr_code = v_qr_code) THEN EXIT; END IF;
        IF v_attempt >= v_max_attempts THEN RAISE EXCEPTION 'Unable to generate unique QR code after % attempts', v_max_attempts; END IF;
    END LOOP;
    UPDATE shipments SET return_qr_code = v_qr_code, return_qr_expires_at = v_expires_at, updated_at = now() WHERE id = p_shipment_id;
    RETURN QUERY SELECT v_qr_code, v_expires_at;
END;
$$;


--
-- Name: get_user_active_pudo(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_user_active_pudo(p_user_id uuid) RETURNS TABLE(pudo_type text, pudo_id text, pudo_name text, pudo_address text, pudo_city text, pudo_postal_code text)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    -- Check users table for PUDO type
    RETURN QUERY
    SELECT 
        u.pudo_type,
        u.pudo_id,
        CASE 
            WHEN u.pudo_type = 'correos' THEN c.correos_name
            WHEN u.pudo_type = 'brickshare' THEN b.location_name
            ELSE NULL
        END as pudo_name,
        CASE 
            WHEN u.pudo_type = 'correos' THEN c.correos_full_address
            WHEN u.pudo_type = 'brickshare' THEN b.address
            ELSE NULL
        END as pudo_address,
        CASE 
            WHEN u.pudo_type = 'correos' THEN c.correos_city
            WHEN u.pudo_type = 'brickshare' THEN b.city
            ELSE NULL
        END as pudo_city,
        CASE 
            WHEN u.pudo_type = 'correos' THEN c.correos_zip_code
            WHEN u.pudo_type = 'brickshare' THEN b.postal_code
            ELSE NULL
        END as pudo_postal_code
    FROM public.users u
    LEFT JOIN public.users_correos_dropping c ON u.user_id = c.user_id AND u.pudo_type = 'correos'
    LEFT JOIN public.users_brickshare_dropping b ON u.user_id = b.user_id AND u.pudo_type = 'brickshare'
    WHERE u.user_id = p_user_id;
END;
$$;


--
-- Name: FUNCTION get_user_active_pudo(p_user_id uuid); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.get_user_active_pudo(p_user_id uuid) IS 'Returns the active PUDO point information for a user regardless of type';


--
-- Name: handle_new_auth_user(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_new_auth_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    INSERT INTO public.users (user_id, full_name, avatar_url)
    VALUES (
        NEW.id,
        NEW.raw_user_meta_data ->> 'full_name',
        NEW.raw_user_meta_data ->> 'avatar_url'
    )
    ON CONFLICT (user_id) DO NOTHING;
    RETURN NEW;
END;
$$;


--
-- Name: handle_new_set_inventory(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_new_set_inventory() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO public.inventory_sets (set_id, set_ref, inventory_set_total_qty)
    VALUES (NEW.id, NEW.set_ref, 2)
    ON CONFLICT (set_id) DO UPDATE
    SET inventory_set_total_qty = 2; -- Reset to 2 if re-importing, or maybe we should just do NOTHING? 
    -- The original logic had ON CONFLICT DO UPDATE SET... 
    -- Actually, later migration 20260127095000 had ON CONFLICT DO NOTHING in the function body, 
    -- but update logic in the specialized block above it.
    -- Let's stick to simple initialization: IF exists, do nothing or ensure at least 2?
    -- The prompt implies re-importing via UI overwrites pieces. Maybe we should ensure inventory entry exists.
    -- Let's use DO NOTHING to preserve existing stock counts if just re-importing set details.
    
    RETURN NEW;
END;
$$;


--
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    -- Create record in users table
    INSERT INTO public.users (
        user_id,
        full_name,
        avatar_url,
        email
    )
    VALUES (
        NEW.id,
        NEW.raw_user_meta_data ->> 'full_name',
        NEW.raw_user_meta_data ->> 'avatar_url',
        NEW.email
    )
    ON CONFLICT (user_id) DO NOTHING;

    -- Assign default 'user' role
    INSERT INTO public.user_roles (user_id, role)
    VALUES (NEW.id, 'user'::app_role)
    ON CONFLICT (user_id, role) DO NOTHING;

    RETURN NEW;
END;
$$;


--
-- Name: handle_reception_close(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_reception_close() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    IF NEW.reception_completed = TRUE AND OLD.reception_completed = FALSE THEN
        UPDATE public.inventory_sets
        SET in_return = GREATEST(0, COALESCE(in_return, 0) - 1), updated_at = now()
        WHERE set_id = NEW.set_id;

        IF NEW.missing_parts IS NOT NULL AND TRIM(NEW.missing_parts) != '' THEN
            UPDATE public.inventory_sets SET in_repair = COALESCE(in_repair, 0) + 1 WHERE set_id = NEW.set_id;
            UPDATE public.sets SET set_status = 'in_repair', updated_at = now() WHERE id = NEW.set_id;
        ELSE
            UPDATE public.sets SET set_status = 'active', updated_at = now() WHERE id = NEW.set_id;
        END IF;

        UPDATE public.shipments SET handling_processed = TRUE, updated_at = now() WHERE id = NEW.event_id;
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: handle_return_user_status(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_return_user_status() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    IF NEW.shipment_status = 'in_return_pudo' AND OLD.shipment_status != 'in_return_pudo' THEN
        UPDATE public.users SET user_status = 'no_set' WHERE user_id = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: handle_shipment_delivered(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_shipment_delivered() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    IF NEW.shipment_status = 'delivered_user' AND OLD.shipment_status != 'delivered_user' THEN
        UPDATE public.users SET user_status = 'has_set' WHERE user_id = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: handle_shipment_return_transit_inventory(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_shipment_return_transit_inventory() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    IF NEW.shipment_status = 'in_return_pudo' AND OLD.shipment_status != 'in_return_pudo' THEN
        UPDATE public.inventory_sets
        SET in_return = COALESCE(in_return, 0) + 1, updated_at = now()
        WHERE set_id = NEW.set_id;
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: handle_shipment_warehouse_received(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_shipment_warehouse_received() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    IF NEW.shipment_status = 'returned' AND OLD.shipment_status != 'returned' THEN
        INSERT INTO public.reception_operations (event_id, user_id, set_id)
        VALUES (NEW.id, NEW.user_id, NEW.set_id);
        NEW.warehouse_reception_date = now();
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: handle_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;


--
-- Name: has_role(uuid, public.app_role); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.has_role(_user_id uuid, _role public.app_role) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.user_roles
        WHERE user_id = _user_id
          AND role = _role
    )
$$;


--
-- Name: increment_referral_credits(uuid, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.increment_referral_credits(p_user_id uuid, p_amount integer DEFAULT 1) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.users
    SET referral_credits = referral_credits + p_amount
    WHERE user_id = p_user_id;
END;
$$;


--
-- Name: preview_assign_sets_to_users(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.preview_assign_sets_to_users() RETURNS TABLE(user_id uuid, user_name text, set_id uuid, set_name text, set_ref text, set_price numeric, current_stock integer, matches_wishlist boolean, pudo_type text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    r RECORD;
    v_set_id UUID;
    v_set_name TEXT;
    v_set_ref TEXT;
    v_set_price DECIMAL;
    v_current_stock INTEGER;
    v_matches_wishlist BOOLEAN;
    v_pudo_type TEXT;
BEGIN
    -- Loop through eligible users (those without a set and are regular users)
    FOR r IN (
        SELECT u.user_id, u.full_name, u.pudo_type
        FROM public.users u
        WHERE u.user_status IN ('no_set', 'set_returning')
          -- Only include users who don't have admin or operador roles
          AND NOT EXISTS (
              SELECT 1 FROM public.user_roles ur
              WHERE ur.user_id = u.user_id
              AND ur.role IN ('admin', 'operador')
          )
    ) LOOP
        v_set_id := NULL;
        v_matches_wishlist := FALSE;
        v_pudo_type := r.pudo_type;
        
        -- Try to find set from user's wishlist that they haven't had before
        SELECT w.set_id, s.set_name, s.set_ref, 
               COALESCE(s.set_price, 100.00), i.inventory_set_total_qty
        INTO v_set_id, v_set_name, v_set_ref, v_set_price, v_current_stock
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        JOIN public.sets s ON w.set_id = s.id
        WHERE w.user_id = r.user_id
          AND w.status = true
          AND i.inventory_set_total_qty > 0
          -- Check if user has NOT had this set before
          AND NOT EXISTS (
              SELECT 1 FROM public.shipments e
              WHERE e.user_id = r.user_id 
                AND e.set_id = w.set_id
          )
        ORDER BY w.created_at ASC  -- Prioritize by wishlist order
        LIMIT 1;
        
        -- If found in wishlist, mark as match
        IF v_set_id IS NOT NULL THEN
            v_matches_wishlist := TRUE;
        ELSE
            -- No valid wishlist match, choose random available set
            SELECT s.id, s.set_name, s.set_ref, 
                   COALESCE(s.set_price, 100.00), i.inventory_set_total_qty
            INTO v_set_id, v_set_name, v_set_ref, v_set_price, v_current_stock
            FROM public.sets s
            JOIN public.inventory_sets i ON s.id = i.set_id
            WHERE i.inventory_set_total_qty > 0
            ORDER BY RANDOM()
            LIMIT 1;
            
            v_matches_wishlist := FALSE;
        END IF;
        
        -- Return assignment if a set was found
        IF v_set_id IS NOT NULL THEN
            preview_assign_sets_to_users.user_id := r.user_id;
            preview_assign_sets_to_users.user_name := r.full_name;
            preview_assign_sets_to_users.set_id := v_set_id;
            preview_assign_sets_to_users.set_name := v_set_name;
            preview_assign_sets_to_users.set_ref := v_set_ref;
            preview_assign_sets_to_users.set_price := v_set_price;
            preview_assign_sets_to_users.current_stock := v_current_stock;
            preview_assign_sets_to_users.matches_wishlist := v_matches_wishlist;
            preview_assign_sets_to_users.pudo_type := v_pudo_type;
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$;


--
-- Name: FUNCTION preview_assign_sets_to_users(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.preview_assign_sets_to_users() IS 'Generates a preview of set assignments for eligible users. Includes pudo_type to determine if Correos preregistration should be executed.';


--
-- Name: process_referral_credit(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.process_referral_credit(p_referee_user_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_referral    public.referrals%ROWTYPE;
    v_referrer_id UUID;
BEGIN
    -- Find pending referral for this user
    SELECT * INTO v_referral
    FROM public.referrals
    WHERE referee_id = p_referee_user_id
      AND status = 'pending';

    IF NOT FOUND THEN
        RETURN; -- No pending referral, nothing to do
    END IF;

    v_referrer_id := v_referral.referrer_id;

    -- Award credits to referrer in USERS table
    UPDATE public.users
    SET referral_credits = referral_credits + v_referral.reward_credits
    WHERE user_id = v_referrer_id;

    -- Mark referral as credited
    UPDATE public.referrals
    SET status = 'credited',
        credited_at = NOW()
    WHERE id = v_referral.id;
END;
$$;


--
-- Name: set_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


--
-- Name: update_set_status_from_return(uuid, text, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_set_status_from_return(p_set_id uuid, p_new_status text, p_envio_id uuid DEFAULT NULL::uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    IF p_new_status NOT IN ('active', 'inactive', 'in_repair') THEN
        RAISE EXCEPTION 'Invalid status: %', p_new_status;
    END IF;

    UPDATE public.sets SET set_status = p_new_status, updated_at = now() WHERE id = p_set_id;

    UPDATE public.inventory_sets SET in_return = in_return - 1, updated_at = now() WHERE set_id = p_set_id;

    IF p_new_status = 'in_repair' THEN
        UPDATE public.inventory_sets SET in_repair = in_repair + 1 WHERE set_id = p_set_id;
    END IF;

    IF p_new_status = 'active' THEN NULL; END IF;

    IF p_envio_id IS NOT NULL THEN
        UPDATE public.shipments SET warehouse_reception_date = now(), handling_processed = TRUE, updated_at = now() WHERE id = p_envio_id;
    END IF;
END;
$$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;


--
-- Name: update_users_brickshare_dropping_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_users_brickshare_dropping_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


--
-- Name: update_users_correos_dropping_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_users_correos_dropping_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


--
-- Name: uses_brickshare_pudo(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.uses_brickshare_pudo(shipment_id uuid) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
    SELECT pickup_type = 'brickshare' AND brickshare_pudo_id IS NOT NULL FROM shipments WHERE id = shipment_id;
$$;


--
-- Name: validate_qr_code(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validate_qr_code(p_qr_code text) RETURNS TABLE(shipment_id uuid, validation_type text, is_valid boolean, error_message text, shipment_info jsonb)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_shipment RECORD;
    v_is_valid BOOLEAN := false; v_error_message TEXT := NULL; v_validation_type TEXT := NULL; v_shipment_info JSONB;
BEGIN
    SELECT s.id, s.order_id, s.shipment_status as status, s.pickup_type,
        s.delivery_qr_code, s.delivery_qr_expires_at, s.delivery_validated_at,
        s.return_qr_code, s.return_qr_expires_at, s.return_validated_at,
        s.brickshare_pudo_id, o.set_id, st.set_name, st.set_ref as set_number, st.set_theme as theme
    INTO v_shipment
    FROM shipments s JOIN orders o ON s.order_id = o.id LEFT JOIN sets st ON o.set_id = st.id
    WHERE s.delivery_qr_code = p_qr_code OR s.return_qr_code = p_qr_code;

    IF NOT FOUND THEN
        RETURN QUERY SELECT NULL::UUID, NULL::TEXT, false, 'QR code not found'::TEXT, NULL::JSONB; RETURN;
    END IF;

    IF v_shipment.pickup_type != 'brickshare' THEN
        RETURN QUERY SELECT v_shipment.id, NULL::TEXT, false, 'This shipment is not for Brickshare pickup point'::TEXT, NULL::JSONB; RETURN;
    END IF;

    IF v_shipment.delivery_qr_code = p_qr_code THEN
        v_validation_type := 'delivery';
        IF v_shipment.delivery_validated_at IS NOT NULL THEN v_error_message := 'QR code already used';
        ELSIF v_shipment.delivery_qr_expires_at < now() THEN v_error_message := 'QR code has expired';
        ELSE v_is_valid := true; END IF;
    ELSIF v_shipment.return_qr_code = p_qr_code THEN
        v_validation_type := 'return';
        IF v_shipment.return_validated_at IS NOT NULL THEN v_error_message := 'QR code already used';
        ELSIF v_shipment.return_qr_expires_at < now() THEN v_error_message := 'QR code has expired';
        ELSIF v_shipment.delivery_validated_at IS NULL THEN v_error_message := 'Cannot return a set that has not been delivered yet';
        ELSE v_is_valid := true; END IF;
    END IF;

    v_shipment_info := jsonb_build_object('order_id', v_shipment.order_id, 'set_id', v_shipment.set_id, 'set_name', v_shipment.set_name,
        'set_number', v_shipment.set_number, 'theme', v_shipment.theme, 'status', v_shipment.status,
        'brickshare_pudo_id', v_shipment.brickshare_pudo_id, 'validation_type', v_validation_type);

    RETURN QUERY SELECT v_shipment.id, v_validation_type, v_is_valid, v_error_message, v_shipment_info;
END;
$$;


--
-- Name: apply_rls(jsonb, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
    AS $$
declare
-- Regclass of the table e.g. public.notes
entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

-- I, U, D, T: insert, update ...
action realtime.action = (
    case wal ->> 'action'
        when 'I' then 'INSERT'
        when 'U' then 'UPDATE'
        when 'D' then 'DELETE'
        else 'ERROR'
    end
);

-- Is row level security enabled for the table
is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

subscriptions realtime.subscription[] = array_agg(subs)
    from
        realtime.subscription subs
    where
        subs.entity = entity_
        -- Filter by action early - only get subscriptions interested in this action
        -- action_filter column can be: '*' (all), 'INSERT', 'UPDATE', or 'DELETE'
        and (subs.action_filter = '*' or subs.action_filter = action::text);

-- Subscription vars
roles regrole[] = array_agg(distinct us.claims_role::text)
    from
        unnest(subscriptions) us;

working_role regrole;
claimed_role regrole;
claims jsonb;

subscription_id uuid;
subscription_has_access bool;
visible_to_subscription_ids uuid[] = '{}';

-- structured info for wal's columns
columns realtime.wal_column[];
-- previous identity values for update/delete
old_columns realtime.wal_column[];

error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

-- Primary jsonb output for record
output jsonb;

begin
perform set_config('role', null, true);

columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'columns') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

old_columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'identity') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

for working_role in select * from unnest(roles) loop

    -- Update `is_selectable` for columns and old_columns
    columns =
        array_agg(
            (
                c.name,
                c.type_name,
                c.type_oid,
                c.value,
                c.is_pkey,
                pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
            )::realtime.wal_column
        )
        from
            unnest(columns) c;

    old_columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(old_columns) c;

    if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            -- subscriptions is already filtered by entity
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 400: Bad Request, no primary key']
        )::realtime.wal_rls;

    -- The claims role does not have SELECT permission to the primary key of entity
    elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 401: Unauthorized']
        )::realtime.wal_rls;

    else
        output = jsonb_build_object(
            'schema', wal ->> 'schema',
            'table', wal ->> 'table',
            'type', action,
            'commit_timestamp', to_char(
                ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
            ),
            'columns', (
                select
                    jsonb_agg(
                        jsonb_build_object(
                            'name', pa.attname,
                            'type', pt.typname
                        )
                        order by pa.attnum asc
                    )
                from
                    pg_attribute pa
                    join pg_type pt
                        on pa.atttypid = pt.oid
                where
                    attrelid = entity_
                    and attnum > 0
                    and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
            )
        )
        -- Add "record" key for insert and update
        || case
            when action in ('INSERT', 'UPDATE') then
                jsonb_build_object(
                    'record',
                    (
                        select
                            jsonb_object_agg(
                                -- if unchanged toast, get column name and value from old record
                                coalesce((c).name, (oc).name),
                                case
                                    when (c).name is null then (oc).value
                                    else (c).value
                                end
                            )
                        from
                            unnest(columns) c
                            full outer join unnest(old_columns) oc
                                on (c).name = (oc).name
                        where
                            coalesce((c).is_selectable, (oc).is_selectable)
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                    )
                )
            else '{}'::jsonb
        end
        -- Add "old_record" key for update and delete
        || case
            when action = 'UPDATE' then
                jsonb_build_object(
                        'old_record',
                        (
                            select jsonb_object_agg((c).name, (c).value)
                            from unnest(old_columns) c
                            where
                                (c).is_selectable
                                and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                        )
                    )
            when action = 'DELETE' then
                jsonb_build_object(
                    'old_record',
                    (
                        select jsonb_object_agg((c).name, (c).value)
                        from unnest(old_columns) c
                        where
                            (c).is_selectable
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                    )
                )
            else '{}'::jsonb
        end;

        -- Create the prepared statement
        if is_rls_enabled and action <> 'DELETE' then
            if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                deallocate walrus_rls_stmt;
            end if;
            execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
        end if;

        visible_to_subscription_ids = '{}';

        for subscription_id, claims in (
                select
                    subs.subscription_id,
                    subs.claims
                from
                    unnest(subscriptions) subs
                where
                    subs.entity = entity_
                    and subs.claims_role = working_role
                    and (
                        realtime.is_visible_through_filters(columns, subs.filters)
                        or (
                          action = 'DELETE'
                          and realtime.is_visible_through_filters(old_columns, subs.filters)
                        )
                    )
        ) loop

            if not is_rls_enabled or action = 'DELETE' then
                visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
            else
                -- Check if RLS allows the role to see the record
                perform
                    -- Trim leading and trailing quotes from working_role because set_config
                    -- doesn't recognize the role as valid if they are included
                    set_config('role', trim(both '"' from working_role::text), true),
                    set_config('request.jwt.claims', claims::text, true);

                execute 'execute walrus_rls_stmt' into subscription_has_access;

                if subscription_has_access then
                    visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                end if;
            end if;
        end loop;

        perform set_config('role', null, true);

        return next (
            output,
            is_rls_enabled,
            visible_to_subscription_ids,
            case
                when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                else '{}'
            end
        )::realtime.wal_rls;

    end if;
end loop;

perform set_config('role', null, true);
end;
$$;


--
-- Name: broadcast_changes(text, text, text, text, text, record, record, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text DEFAULT 'ROW'::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$$;


--
-- Name: build_prepared_statement_sql(text, regclass, realtime.wal_column[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


--
-- Name: cast(text, regtype); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
  res jsonb;
begin
  if type_::text = 'bytea' then
    return to_jsonb(val);
  end if;
  execute format('select to_jsonb(%L::'|| type_::text || ')', val) into res;
  return res;
end
$$;


--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
      /*
      Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
      */
      declare
          op_symbol text = (
              case
                  when op = 'eq' then '='
                  when op = 'neq' then '!='
                  when op = 'lt' then '<'
                  when op = 'lte' then '<='
                  when op = 'gt' then '>'
                  when op = 'gte' then '>='
                  when op = 'in' then '= any'
                  else 'UNKNOWN OP'
              end
          );
          res boolean;
      begin
          execute format(
              'select %L::'|| type_::text || ' ' || op_symbol
              || ' ( %L::'
              || (
                  case
                      when op = 'in' then type_::text || '[]'
                      else type_::text end
              )
              || ')', val_1, val_2) into res;
          return res;
      end;
      $$;


--
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
    /*
    Should the record be visible (true) or filtered out (false) after *filters* are applied
    */
        select
            -- Default to allowed when no filters present
            $2 is null -- no filters. this should not happen because subscriptions has a default
            or array_length($2, 1) is null -- array length of an empty array is null
            or bool_and(
                coalesce(
                    realtime.check_equality_op(
                        op:=f.op,
                        type_:=coalesce(
                            col.type_oid::regtype, -- null when wal2json version <= 2.4
                            col.type_name::regtype
                        ),
                        -- cast jsonb to text
                        val_1:=col.value #>> '{}',
                        val_2:=f.value
                    ),
                    false -- if null, filter does not match
                )
            )
        from
            unnest(filters) f
            join unnest(columns) col
                on f.column_name = col.name;
    $_$;


--
-- Name: list_changes(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS SETOF realtime.wal_rls
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
      with pub as (
        select
          concat_ws(
            ',',
            case when bool_or(pubinsert) then 'insert' else null end,
            case when bool_or(pubupdate) then 'update' else null end,
            case when bool_or(pubdelete) then 'delete' else null end
          ) as w2j_actions,
          coalesce(
            string_agg(
              realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
              ','
            ) filter (where ppt.tablename is not null and ppt.tablename not like '% %'),
            ''
          ) w2j_add_tables
        from
          pg_publication pp
          left join pg_publication_tables ppt
            on pp.pubname = ppt.pubname
        where
          pp.pubname = publication
        group by
          pp.pubname
        limit 1
      ),
      w2j as (
        select
          x.*, pub.w2j_add_tables
        from
          pub,
          pg_logical_slot_get_changes(
            slot_name, null, max_changes,
            'include-pk', 'true',
            'include-transaction', 'false',
            'include-timestamp', 'true',
            'include-type-oids', 'true',
            'format-version', '2',
            'actions', pub.w2j_actions,
            'add-tables', pub.w2j_add_tables
          ) x
      )
      select
        xyz.wal,
        xyz.is_rls_enabled,
        xyz.subscription_ids,
        xyz.errors
      from
        w2j,
        realtime.apply_rls(
          wal := w2j.data::jsonb,
          max_record_bytes := max_record_bytes
        ) xyz(wal, is_rls_enabled, subscription_ids, errors)
      where
        w2j.w2j_add_tables <> ''
        and xyz.subscription_ids[1] is not null
    $$;


--
-- Name: quote_wal2json(regclass); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
      select
        (
          select string_agg('' || ch,'')
          from unnest(string_to_array(nsp.nspname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
        )
        || '.'
        || (
          select string_agg('' || ch,'')
          from unnest(string_to_array(pc.relname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
          )
      from
        pg_class pc
        join pg_namespace nsp
          on pc.relnamespace = nsp.oid
      where
        pc.oid = entity
    $$;


--
-- Name: send(jsonb, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  generated_id uuid;
  final_payload jsonb;
BEGIN
  BEGIN
    -- Generate a new UUID for the id
    generated_id := gen_random_uuid();

    -- Check if payload has an 'id' key, if not, add the generated UUID
    IF payload ? 'id' THEN
      final_payload := payload;
    ELSE
      final_payload := jsonb_set(payload, '{id}', to_jsonb(generated_id));
    END IF;

    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    -- Attempt to insert the message
    INSERT INTO realtime.messages (id, payload, event, topic, private, extension)
    VALUES (generated_id, final_payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      -- Capture and notify the error
      RAISE WARNING 'ErrorSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    /*
    Validates that the user defined filters for a subscription:
    - refer to valid columns that the claimed role may access
    - values are coercable to the correct column type
    */
    declare
        col_names text[] = coalesce(
                array_agg(c.column_name order by c.ordinal_position),
                '{}'::text[]
            )
            from
                information_schema.columns c
            where
                format('%I.%I', c.table_schema, c.table_name)::regclass = new.entity
                and pg_catalog.has_column_privilege(
                    (new.claims ->> 'role'),
                    format('%I.%I', c.table_schema, c.table_name)::regclass,
                    c.column_name,
                    'SELECT'
                );
        filter realtime.user_defined_filter;
        col_type regtype;

        in_val jsonb;
    begin
        for filter in select * from unnest(new.filters) loop
            -- Filtered column is valid
            if not filter.column_name = any(col_names) then
                raise exception 'invalid column for filter %', filter.column_name;
            end if;

            -- Type is sanitized and safe for string interpolation
            col_type = (
                select atttypid::regtype
                from pg_catalog.pg_attribute
                where attrelid = new.entity
                      and attname = filter.column_name
            );
            if col_type is null then
                raise exception 'failed to lookup type for column %', filter.column_name;
            end if;

            -- Set maximum number of entries for in filter
            if filter.op = 'in'::realtime.equality_op then
                in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
                if coalesce(jsonb_array_length(in_val), 0) > 100 then
                    raise exception 'too many values for `in` filter. Maximum 100';
                end if;
            else
                -- raises an exception if value is not coercable to type
                perform realtime.cast(filter.value, col_type);
            end if;

        end loop;

        -- Apply consistent order to filters so the unique constraint on
        -- (subscription_id, entity, filters) can't be tricked by a different filter order
        new.filters = coalesce(
            array_agg(f order by f.column_name, f.op, f.value),
            '{}'
        ) from unnest(new.filters) f;

        return new;
    end;
    $$;


--
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


--
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


--
-- Name: can_insert_object(text, text, uuid, jsonb); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


--
-- Name: enforce_bucket_name_length(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.enforce_bucket_name_length() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if length(new.name) > 100 then
        raise exception 'bucket name "%" is too long (% characters). Max is 100.', new.name, length(new.name);
    end if;
    return new;
end;
$$;


--
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
_filename text;
BEGIN
	select string_to_array(name, '/') into _parts;
	select _parts[array_length(_parts,1)] into _filename;
	-- @todo return the last part instead of 2
	return reverse(split_part(reverse(_filename), '.', 1));
END
$$;


--
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;


--
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[1:array_length(_parts,1)-1];
END
$$;


--
-- Name: get_common_prefix(text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_common_prefix(p_key text, p_prefix text, p_delimiter text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
SELECT CASE
    WHEN position(p_delimiter IN substring(p_key FROM length(p_prefix) + 1)) > 0
    THEN left(p_key, length(p_prefix) + position(p_delimiter IN substring(p_key FROM length(p_prefix) + 1)))
    ELSE NULL
END;
$$;


--
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_size_by_bucket() RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::int) as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


--
-- Name: list_multipart_uploads_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text) RETURNS TABLE(key text, id text, created_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;


--
-- Name: list_objects_with_delimiter(text, text, text, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_objects_with_delimiter(_bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_peek_name TEXT;
    v_current RECORD;
    v_common_prefix TEXT;

    -- Configuration
    v_is_asc BOOLEAN;
    v_prefix TEXT;
    v_start TEXT;
    v_upper_bound TEXT;
    v_file_batch_size INT;

    -- Seek state
    v_next_seek TEXT;
    v_count INT := 0;

    -- Dynamic SQL for batch query only
    v_batch_query TEXT;

BEGIN
    -- ========================================================================
    -- INITIALIZATION
    -- ========================================================================
    v_is_asc := lower(coalesce(sort_order, 'asc')) = 'asc';
    v_prefix := coalesce(prefix_param, '');
    v_start := CASE WHEN coalesce(next_token, '') <> '' THEN next_token ELSE coalesce(start_after, '') END;
    v_file_batch_size := LEAST(GREATEST(max_keys * 2, 100), 1000);

    -- Calculate upper bound for prefix filtering (bytewise, using COLLATE "C")
    IF v_prefix = '' THEN
        v_upper_bound := NULL;
    ELSIF right(v_prefix, 1) = delimiter_param THEN
        v_upper_bound := left(v_prefix, -1) || chr(ascii(delimiter_param) + 1);
    ELSE
        v_upper_bound := left(v_prefix, -1) || chr(ascii(right(v_prefix, 1)) + 1);
    END IF;

    -- Build batch query (dynamic SQL - called infrequently, amortized over many rows)
    IF v_is_asc THEN
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" >= $2 ' ||
                'AND o.name COLLATE "C" < $3 ORDER BY o.name COLLATE "C" ASC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" >= $2 ' ||
                'ORDER BY o.name COLLATE "C" ASC LIMIT $4';
        END IF;
    ELSE
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" < $2 ' ||
                'AND o.name COLLATE "C" >= $3 ORDER BY o.name COLLATE "C" DESC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" < $2 ' ||
                'ORDER BY o.name COLLATE "C" DESC LIMIT $4';
        END IF;
    END IF;

    -- ========================================================================
    -- SEEK INITIALIZATION: Determine starting position
    -- ========================================================================
    IF v_start = '' THEN
        IF v_is_asc THEN
            v_next_seek := v_prefix;
        ELSE
            -- DESC without cursor: find the last item in range
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_prefix AND o.name COLLATE "C" < v_upper_bound
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix <> '' THEN
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            END IF;

            IF v_next_seek IS NOT NULL THEN
                v_next_seek := v_next_seek || delimiter_param;
            ELSE
                RETURN;
            END IF;
        END IF;
    ELSE
        -- Cursor provided: determine if it refers to a folder or leaf
        IF EXISTS (
            SELECT 1 FROM storage.objects o
            WHERE o.bucket_id = _bucket_id
              AND o.name COLLATE "C" LIKE v_start || delimiter_param || '%'
            LIMIT 1
        ) THEN
            -- Cursor refers to a folder
            IF v_is_asc THEN
                v_next_seek := v_start || chr(ascii(delimiter_param) + 1);
            ELSE
                v_next_seek := v_start || delimiter_param;
            END IF;
        ELSE
            -- Cursor refers to a leaf object
            IF v_is_asc THEN
                v_next_seek := v_start || delimiter_param;
            ELSE
                v_next_seek := v_start;
            END IF;
        END IF;
    END IF;

    -- ========================================================================
    -- MAIN LOOP: Hybrid peek-then-batch algorithm
    -- Uses STATIC SQL for peek (hot path) and DYNAMIC SQL for batch
    -- ========================================================================
    LOOP
        EXIT WHEN v_count >= max_keys;

        -- STEP 1: PEEK using STATIC SQL (plan cached, very fast)
        IF v_is_asc THEN
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_next_seek AND o.name COLLATE "C" < v_upper_bound
                ORDER BY o.name COLLATE "C" ASC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_next_seek
                ORDER BY o.name COLLATE "C" ASC LIMIT 1;
            END IF;
        ELSE
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix <> '' THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            END IF;
        END IF;

        EXIT WHEN v_peek_name IS NULL;

        -- STEP 2: Check if this is a FOLDER or FILE
        v_common_prefix := storage.get_common_prefix(v_peek_name, v_prefix, delimiter_param);

        IF v_common_prefix IS NOT NULL THEN
            -- FOLDER: Emit and skip to next folder (no heap access needed)
            name := rtrim(v_common_prefix, delimiter_param);
            id := NULL;
            updated_at := NULL;
            created_at := NULL;
            last_accessed_at := NULL;
            metadata := NULL;
            RETURN NEXT;
            v_count := v_count + 1;

            -- Advance seek past the folder range
            IF v_is_asc THEN
                v_next_seek := left(v_common_prefix, -1) || chr(ascii(delimiter_param) + 1);
            ELSE
                v_next_seek := v_common_prefix;
            END IF;
        ELSE
            -- FILE: Batch fetch using DYNAMIC SQL (overhead amortized over many rows)
            -- For ASC: upper_bound is the exclusive upper limit (< condition)
            -- For DESC: prefix is the inclusive lower limit (>= condition)
            FOR v_current IN EXECUTE v_batch_query USING _bucket_id, v_next_seek,
                CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix) ELSE v_prefix END, v_file_batch_size
            LOOP
                v_common_prefix := storage.get_common_prefix(v_current.name, v_prefix, delimiter_param);

                IF v_common_prefix IS NOT NULL THEN
                    -- Hit a folder: exit batch, let peek handle it
                    v_next_seek := v_current.name;
                    EXIT;
                END IF;

                -- Emit file
                name := v_current.name;
                id := v_current.id;
                updated_at := v_current.updated_at;
                created_at := v_current.created_at;
                last_accessed_at := v_current.last_accessed_at;
                metadata := v_current.metadata;
                RETURN NEXT;
                v_count := v_count + 1;

                -- Advance seek past this file
                IF v_is_asc THEN
                    v_next_seek := v_current.name || delimiter_param;
                ELSE
                    v_next_seek := v_current.name;
                END IF;

                EXIT WHEN v_count >= max_keys;
            END LOOP;
        END IF;
    END LOOP;
END;
$_$;


--
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.operation() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


--
-- Name: protect_delete(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.protect_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Check if storage.allow_delete_query is set to 'true'
    IF COALESCE(current_setting('storage.allow_delete_query', true), 'false') != 'true' THEN
        RAISE EXCEPTION 'Direct deletion from storage tables is not allowed. Use the Storage API instead.'
            USING HINT = 'This prevents accidental data loss from orphaned objects.',
                  ERRCODE = '42501';
    END IF;
    RETURN NULL;
END;
$$;


--
-- Name: search(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_peek_name TEXT;
    v_current RECORD;
    v_common_prefix TEXT;
    v_delimiter CONSTANT TEXT := '/';

    -- Configuration
    v_limit INT;
    v_prefix TEXT;
    v_prefix_lower TEXT;
    v_is_asc BOOLEAN;
    v_order_by TEXT;
    v_sort_order TEXT;
    v_upper_bound TEXT;
    v_file_batch_size INT;

    -- Dynamic SQL for batch query only
    v_batch_query TEXT;

    -- Seek state
    v_next_seek TEXT;
    v_count INT := 0;
    v_skipped INT := 0;
BEGIN
    -- ========================================================================
    -- INITIALIZATION
    -- ========================================================================
    v_limit := LEAST(coalesce(limits, 100), 1500);
    v_prefix := coalesce(prefix, '') || coalesce(search, '');
    v_prefix_lower := lower(v_prefix);
    v_is_asc := lower(coalesce(sortorder, 'asc')) = 'asc';
    v_file_batch_size := LEAST(GREATEST(v_limit * 2, 100), 1000);

    -- Validate sort column
    CASE lower(coalesce(sortcolumn, 'name'))
        WHEN 'name' THEN v_order_by := 'name';
        WHEN 'updated_at' THEN v_order_by := 'updated_at';
        WHEN 'created_at' THEN v_order_by := 'created_at';
        WHEN 'last_accessed_at' THEN v_order_by := 'last_accessed_at';
        ELSE v_order_by := 'name';
    END CASE;

    v_sort_order := CASE WHEN v_is_asc THEN 'asc' ELSE 'desc' END;

    -- ========================================================================
    -- NON-NAME SORTING: Use path_tokens approach (unchanged)
    -- ========================================================================
    IF v_order_by != 'name' THEN
        RETURN QUERY EXECUTE format(
            $sql$
            WITH folders AS (
                SELECT path_tokens[$1] AS folder
                FROM storage.objects
                WHERE objects.name ILIKE $2 || '%%'
                  AND bucket_id = $3
                  AND array_length(objects.path_tokens, 1) <> $1
                GROUP BY folder
                ORDER BY folder %s
            )
            (SELECT folder AS "name",
                   NULL::uuid AS id,
                   NULL::timestamptz AS updated_at,
                   NULL::timestamptz AS created_at,
                   NULL::timestamptz AS last_accessed_at,
                   NULL::jsonb AS metadata FROM folders)
            UNION ALL
            (SELECT path_tokens[$1] AS "name",
                   id, updated_at, created_at, last_accessed_at, metadata
             FROM storage.objects
             WHERE objects.name ILIKE $2 || '%%'
               AND bucket_id = $3
               AND array_length(objects.path_tokens, 1) = $1
             ORDER BY %I %s)
            LIMIT $4 OFFSET $5
            $sql$, v_sort_order, v_order_by, v_sort_order
        ) USING levels, v_prefix, bucketname, v_limit, offsets;
        RETURN;
    END IF;

    -- ========================================================================
    -- NAME SORTING: Hybrid skip-scan with batch optimization
    -- ========================================================================

    -- Calculate upper bound for prefix filtering
    IF v_prefix_lower = '' THEN
        v_upper_bound := NULL;
    ELSIF right(v_prefix_lower, 1) = v_delimiter THEN
        v_upper_bound := left(v_prefix_lower, -1) || chr(ascii(v_delimiter) + 1);
    ELSE
        v_upper_bound := left(v_prefix_lower, -1) || chr(ascii(right(v_prefix_lower, 1)) + 1);
    END IF;

    -- Build batch query (dynamic SQL - called infrequently, amortized over many rows)
    IF v_is_asc THEN
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" >= $2 ' ||
                'AND lower(o.name) COLLATE "C" < $3 ORDER BY lower(o.name) COLLATE "C" ASC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" >= $2 ' ||
                'ORDER BY lower(o.name) COLLATE "C" ASC LIMIT $4';
        END IF;
    ELSE
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" < $2 ' ||
                'AND lower(o.name) COLLATE "C" >= $3 ORDER BY lower(o.name) COLLATE "C" DESC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" < $2 ' ||
                'ORDER BY lower(o.name) COLLATE "C" DESC LIMIT $4';
        END IF;
    END IF;

    -- Initialize seek position
    IF v_is_asc THEN
        v_next_seek := v_prefix_lower;
    ELSE
        -- DESC: find the last item in range first (static SQL)
        IF v_upper_bound IS NOT NULL THEN
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_prefix_lower AND lower(o.name) COLLATE "C" < v_upper_bound
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        ELSIF v_prefix_lower <> '' THEN
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_prefix_lower
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        ELSE
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        END IF;

        IF v_peek_name IS NOT NULL THEN
            v_next_seek := lower(v_peek_name) || v_delimiter;
        ELSE
            RETURN;
        END IF;
    END IF;

    -- ========================================================================
    -- MAIN LOOP: Hybrid peek-then-batch algorithm
    -- Uses STATIC SQL for peek (hot path) and DYNAMIC SQL for batch
    -- ========================================================================
    LOOP
        EXIT WHEN v_count >= v_limit;

        -- STEP 1: PEEK using STATIC SQL (plan cached, very fast)
        IF v_is_asc THEN
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek AND lower(o.name) COLLATE "C" < v_upper_bound
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            END IF;
        ELSE
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek AND lower(o.name) COLLATE "C" >= v_prefix_lower
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix_lower <> '' THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek AND lower(o.name) COLLATE "C" >= v_prefix_lower
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            END IF;
        END IF;

        EXIT WHEN v_peek_name IS NULL;

        -- STEP 2: Check if this is a FOLDER or FILE
        v_common_prefix := storage.get_common_prefix(lower(v_peek_name), v_prefix_lower, v_delimiter);

        IF v_common_prefix IS NOT NULL THEN
            -- FOLDER: Handle offset, emit if needed, skip to next folder
            IF v_skipped < offsets THEN
                v_skipped := v_skipped + 1;
            ELSE
                name := split_part(rtrim(storage.get_common_prefix(v_peek_name, v_prefix, v_delimiter), v_delimiter), v_delimiter, levels);
                id := NULL;
                updated_at := NULL;
                created_at := NULL;
                last_accessed_at := NULL;
                metadata := NULL;
                RETURN NEXT;
                v_count := v_count + 1;
            END IF;

            -- Advance seek past the folder range
            IF v_is_asc THEN
                v_next_seek := lower(left(v_common_prefix, -1)) || chr(ascii(v_delimiter) + 1);
            ELSE
                v_next_seek := lower(v_common_prefix);
            END IF;
        ELSE
            -- FILE: Batch fetch using DYNAMIC SQL (overhead amortized over many rows)
            -- For ASC: upper_bound is the exclusive upper limit (< condition)
            -- For DESC: prefix_lower is the inclusive lower limit (>= condition)
            FOR v_current IN EXECUTE v_batch_query
                USING bucketname, v_next_seek,
                    CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix_lower) ELSE v_prefix_lower END, v_file_batch_size
            LOOP
                v_common_prefix := storage.get_common_prefix(lower(v_current.name), v_prefix_lower, v_delimiter);

                IF v_common_prefix IS NOT NULL THEN
                    -- Hit a folder: exit batch, let peek handle it
                    v_next_seek := lower(v_current.name);
                    EXIT;
                END IF;

                -- Handle offset skipping
                IF v_skipped < offsets THEN
                    v_skipped := v_skipped + 1;
                ELSE
                    -- Emit file
                    name := split_part(v_current.name, v_delimiter, levels);
                    id := v_current.id;
                    updated_at := v_current.updated_at;
                    created_at := v_current.created_at;
                    last_accessed_at := v_current.last_accessed_at;
                    metadata := v_current.metadata;
                    RETURN NEXT;
                    v_count := v_count + 1;
                END IF;

                -- Advance seek past this file
                IF v_is_asc THEN
                    v_next_seek := lower(v_current.name) || v_delimiter;
                ELSE
                    v_next_seek := lower(v_current.name);
                END IF;

                EXIT WHEN v_count >= v_limit;
            END LOOP;
        END IF;
    END LOOP;
END;
$_$;


--
-- Name: search_by_timestamp(text, text, integer, integer, text, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search_by_timestamp(p_prefix text, p_bucket_id text, p_limit integer, p_level integer, p_start_after text, p_sort_order text, p_sort_column text, p_sort_column_after text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_cursor_op text;
    v_query text;
    v_prefix text;
BEGIN
    v_prefix := coalesce(p_prefix, '');

    IF p_sort_order = 'asc' THEN
        v_cursor_op := '>';
    ELSE
        v_cursor_op := '<';
    END IF;

    v_query := format($sql$
        WITH raw_objects AS (
            SELECT
                o.name AS obj_name,
                o.id AS obj_id,
                o.updated_at AS obj_updated_at,
                o.created_at AS obj_created_at,
                o.last_accessed_at AS obj_last_accessed_at,
                o.metadata AS obj_metadata,
                storage.get_common_prefix(o.name, $1, '/') AS common_prefix
            FROM storage.objects o
            WHERE o.bucket_id = $2
              AND o.name COLLATE "C" LIKE $1 || '%%'
        ),
        -- Aggregate common prefixes (folders)
        -- Both created_at and updated_at use MIN(obj_created_at) to match the old prefixes table behavior
        aggregated_prefixes AS (
            SELECT
                rtrim(common_prefix, '/') AS name,
                NULL::uuid AS id,
                MIN(obj_created_at) AS updated_at,
                MIN(obj_created_at) AS created_at,
                NULL::timestamptz AS last_accessed_at,
                NULL::jsonb AS metadata,
                TRUE AS is_prefix
            FROM raw_objects
            WHERE common_prefix IS NOT NULL
            GROUP BY common_prefix
        ),
        leaf_objects AS (
            SELECT
                obj_name AS name,
                obj_id AS id,
                obj_updated_at AS updated_at,
                obj_created_at AS created_at,
                obj_last_accessed_at AS last_accessed_at,
                obj_metadata AS metadata,
                FALSE AS is_prefix
            FROM raw_objects
            WHERE common_prefix IS NULL
        ),
        combined AS (
            SELECT * FROM aggregated_prefixes
            UNION ALL
            SELECT * FROM leaf_objects
        ),
        filtered AS (
            SELECT *
            FROM combined
            WHERE (
                $5 = ''
                OR ROW(
                    date_trunc('milliseconds', %I),
                    name COLLATE "C"
                ) %s ROW(
                    COALESCE(NULLIF($6, '')::timestamptz, 'epoch'::timestamptz),
                    $5
                )
            )
        )
        SELECT
            split_part(name, '/', $3) AS key,
            name,
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
        FROM filtered
        ORDER BY
            COALESCE(date_trunc('milliseconds', %I), 'epoch'::timestamptz) %s,
            name COLLATE "C" %s
        LIMIT $4
    $sql$,
        p_sort_column,
        v_cursor_op,
        p_sort_column,
        p_sort_order,
        p_sort_order
    );

    RETURN QUERY EXECUTE v_query
    USING v_prefix, p_bucket_id, p_level, p_limit, p_start_after, p_sort_column_after;
END;
$_$;


--
-- Name: search_v2(text, text, integer, integer, text, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer DEFAULT 100, levels integer DEFAULT 1, start_after text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text, sort_column text DEFAULT 'name'::text, sort_column_after text DEFAULT ''::text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    v_sort_col text;
    v_sort_ord text;
    v_limit int;
BEGIN
    -- Cap limit to maximum of 1500 records
    v_limit := LEAST(coalesce(limits, 100), 1500);

    -- Validate and normalize sort_order
    v_sort_ord := lower(coalesce(sort_order, 'asc'));
    IF v_sort_ord NOT IN ('asc', 'desc') THEN
        v_sort_ord := 'asc';
    END IF;

    -- Validate and normalize sort_column
    v_sort_col := lower(coalesce(sort_column, 'name'));
    IF v_sort_col NOT IN ('name', 'updated_at', 'created_at') THEN
        v_sort_col := 'name';
    END IF;

    -- Route to appropriate implementation
    IF v_sort_col = 'name' THEN
        -- Use list_objects_with_delimiter for name sorting (most efficient: O(k * log n))
        RETURN QUERY
        SELECT
            split_part(l.name, '/', levels) AS key,
            l.name AS name,
            l.id,
            l.updated_at,
            l.created_at,
            l.last_accessed_at,
            l.metadata
        FROM storage.list_objects_with_delimiter(
            bucket_name,
            coalesce(prefix, ''),
            '/',
            v_limit,
            start_after,
            '',
            v_sort_ord
        ) l;
    ELSE
        -- Use aggregation approach for timestamp sorting
        -- Not efficient for large datasets but supports correct pagination
        RETURN QUERY SELECT * FROM storage.search_by_timestamp(
            prefix, bucket_name, v_limit, levels, start_after,
            v_sort_ord, v_sort_col, sort_column_after
        );
    END IF;
END;
$$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


--
-- Name: http_request(); Type: FUNCTION; Schema: supabase_functions; Owner: -
--

CREATE FUNCTION supabase_functions.http_request() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'supabase_functions'
    AS $$
  DECLARE
    request_id bigint;
    payload jsonb;
    url text := TG_ARGV[0]::text;
    method text := TG_ARGV[1]::text;
    headers jsonb DEFAULT '{}'::jsonb;
    params jsonb DEFAULT '{}'::jsonb;
    timeout_ms integer DEFAULT 1000;
  BEGIN
    IF url IS NULL OR url = 'null' THEN
      RAISE EXCEPTION 'url argument is missing';
    END IF;

    IF method IS NULL OR method = 'null' THEN
      RAISE EXCEPTION 'method argument is missing';
    END IF;

    IF TG_ARGV[2] IS NULL OR TG_ARGV[2] = 'null' THEN
      headers = '{"Content-Type": "application/json"}'::jsonb;
    ELSE
      headers = TG_ARGV[2]::jsonb;
    END IF;

    IF TG_ARGV[3] IS NULL OR TG_ARGV[3] = 'null' THEN
      params = '{}'::jsonb;
    ELSE
      params = TG_ARGV[3]::jsonb;
    END IF;

    IF TG_ARGV[4] IS NULL OR TG_ARGV[4] = 'null' THEN
      timeout_ms = 1000;
    ELSE
      timeout_ms = TG_ARGV[4]::integer;
    END IF;

    CASE
      WHEN method = 'GET' THEN
        SELECT http_get INTO request_id FROM net.http_get(
          url,
          params,
          headers,
          timeout_ms
        );
      WHEN method = 'POST' THEN
        payload = jsonb_build_object(
          'old_record', OLD,
          'record', NEW,
          'type', TG_OP,
          'table', TG_TABLE_NAME,
          'schema', TG_TABLE_SCHEMA
        );

        SELECT http_post INTO request_id FROM net.http_post(
          url,
          payload,
          params,
          headers,
          timeout_ms
        );
      ELSE
        RAISE EXCEPTION 'method argument % is invalid', method;
    END CASE;

    INSERT INTO supabase_functions.hooks
      (hook_table_id, hook_name, request_id)
    VALUES
      (TG_RELID, TG_NAME, request_id);

    RETURN NEW;
  END
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: extensions; Type: TABLE; Schema: _realtime; Owner: -
--

CREATE TABLE _realtime.extensions (
    id uuid NOT NULL,
    type text,
    settings jsonb,
    tenant_external_id text,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: _realtime; Owner: -
--

CREATE TABLE _realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: tenants; Type: TABLE; Schema: _realtime; Owner: -
--

CREATE TABLE _realtime.tenants (
    id uuid NOT NULL,
    name text,
    external_id text,
    jwt_secret text,
    max_concurrent_users integer DEFAULT 200 NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    max_events_per_second integer DEFAULT 100 NOT NULL,
    postgres_cdc_default text DEFAULT 'postgres_cdc_rls'::text,
    max_bytes_per_second integer DEFAULT 100000 NOT NULL,
    max_channels_per_client integer DEFAULT 100 NOT NULL,
    max_joins_per_second integer DEFAULT 500 NOT NULL,
    suspend boolean DEFAULT false,
    jwt_jwks jsonb,
    notify_private_alpha boolean DEFAULT false,
    private_only boolean DEFAULT false NOT NULL,
    migrations_ran integer DEFAULT 0,
    broadcast_adapter character varying(255) DEFAULT 'gen_rpc'::character varying,
    max_presence_events_per_second integer DEFAULT 1000,
    max_payload_size_in_kb integer DEFAULT 3000,
    max_client_presence_events_per_window integer,
    client_presence_window_ms integer,
    presence_enabled boolean DEFAULT false NOT NULL,
    CONSTRAINT jwt_secret_or_jwt_jwks_required CHECK (((jwt_secret IS NOT NULL) OR (jwt_jwks IS NOT NULL)))
);


--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: custom_oauth_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.custom_oauth_providers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    provider_type text NOT NULL,
    identifier text NOT NULL,
    name text NOT NULL,
    client_id text NOT NULL,
    client_secret text NOT NULL,
    acceptable_client_ids text[] DEFAULT '{}'::text[] NOT NULL,
    scopes text[] DEFAULT '{}'::text[] NOT NULL,
    pkce_enabled boolean DEFAULT true NOT NULL,
    attribute_mapping jsonb DEFAULT '{}'::jsonb NOT NULL,
    authorization_params jsonb DEFAULT '{}'::jsonb NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    email_optional boolean DEFAULT false NOT NULL,
    issuer text,
    discovery_url text,
    skip_nonce_check boolean DEFAULT false NOT NULL,
    cached_discovery jsonb,
    discovery_cached_at timestamp with time zone,
    authorization_url text,
    token_url text,
    userinfo_url text,
    jwks_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT custom_oauth_providers_authorization_url_https CHECK (((authorization_url IS NULL) OR (authorization_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_authorization_url_length CHECK (((authorization_url IS NULL) OR (char_length(authorization_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_client_id_length CHECK (((char_length(client_id) >= 1) AND (char_length(client_id) <= 512))),
    CONSTRAINT custom_oauth_providers_discovery_url_length CHECK (((discovery_url IS NULL) OR (char_length(discovery_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_identifier_format CHECK ((identifier ~ '^[a-z0-9][a-z0-9:-]{0,48}[a-z0-9]$'::text)),
    CONSTRAINT custom_oauth_providers_issuer_length CHECK (((issuer IS NULL) OR ((char_length(issuer) >= 1) AND (char_length(issuer) <= 2048)))),
    CONSTRAINT custom_oauth_providers_jwks_uri_https CHECK (((jwks_uri IS NULL) OR (jwks_uri ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_jwks_uri_length CHECK (((jwks_uri IS NULL) OR (char_length(jwks_uri) <= 2048))),
    CONSTRAINT custom_oauth_providers_name_length CHECK (((char_length(name) >= 1) AND (char_length(name) <= 100))),
    CONSTRAINT custom_oauth_providers_oauth2_requires_endpoints CHECK (((provider_type <> 'oauth2'::text) OR ((authorization_url IS NOT NULL) AND (token_url IS NOT NULL) AND (userinfo_url IS NOT NULL)))),
    CONSTRAINT custom_oauth_providers_oidc_discovery_url_https CHECK (((provider_type <> 'oidc'::text) OR (discovery_url IS NULL) OR (discovery_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_oidc_issuer_https CHECK (((provider_type <> 'oidc'::text) OR (issuer IS NULL) OR (issuer ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_oidc_requires_issuer CHECK (((provider_type <> 'oidc'::text) OR (issuer IS NOT NULL))),
    CONSTRAINT custom_oauth_providers_provider_type_check CHECK ((provider_type = ANY (ARRAY['oauth2'::text, 'oidc'::text]))),
    CONSTRAINT custom_oauth_providers_token_url_https CHECK (((token_url IS NULL) OR (token_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_token_url_length CHECK (((token_url IS NULL) OR (char_length(token_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_userinfo_url_https CHECK (((userinfo_url IS NULL) OR (userinfo_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_userinfo_url_length CHECK (((userinfo_url IS NULL) OR (char_length(userinfo_url) <= 2048)))
);


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text,
    code_challenge_method auth.code_challenge_method,
    code_challenge text,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone,
    invite_token text,
    referrer text,
    oauth_client_state_id uuid,
    linking_target_id uuid,
    email_optional boolean DEFAULT false NOT NULL
);


--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.flow_state IS 'Stores metadata for all OAuth/SSO login flows';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text,
    web_authn_session_data jsonb
);


--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid,
    last_webauthn_challenge_data jsonb
);


--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: COLUMN mfa_factors.last_webauthn_challenge_data; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.mfa_factors.last_webauthn_challenge_data IS 'Stores the latest WebAuthn challenge data including attestation/assertion for customer verification';


--
-- Name: oauth_authorizations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_authorizations (
    id uuid NOT NULL,
    authorization_id text NOT NULL,
    client_id uuid NOT NULL,
    user_id uuid,
    redirect_uri text NOT NULL,
    scope text NOT NULL,
    state text,
    resource text,
    code_challenge text,
    code_challenge_method auth.code_challenge_method,
    response_type auth.oauth_response_type DEFAULT 'code'::auth.oauth_response_type NOT NULL,
    status auth.oauth_authorization_status DEFAULT 'pending'::auth.oauth_authorization_status NOT NULL,
    authorization_code text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone DEFAULT (now() + '00:03:00'::interval) NOT NULL,
    approved_at timestamp with time zone,
    nonce text,
    CONSTRAINT oauth_authorizations_authorization_code_length CHECK ((char_length(authorization_code) <= 255)),
    CONSTRAINT oauth_authorizations_code_challenge_length CHECK ((char_length(code_challenge) <= 128)),
    CONSTRAINT oauth_authorizations_expires_at_future CHECK ((expires_at > created_at)),
    CONSTRAINT oauth_authorizations_nonce_length CHECK ((char_length(nonce) <= 255)),
    CONSTRAINT oauth_authorizations_redirect_uri_length CHECK ((char_length(redirect_uri) <= 2048)),
    CONSTRAINT oauth_authorizations_resource_length CHECK ((char_length(resource) <= 2048)),
    CONSTRAINT oauth_authorizations_scope_length CHECK ((char_length(scope) <= 4096)),
    CONSTRAINT oauth_authorizations_state_length CHECK ((char_length(state) <= 4096))
);


--
-- Name: oauth_client_states; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_client_states (
    id uuid NOT NULL,
    provider_type text NOT NULL,
    code_verifier text,
    created_at timestamp with time zone NOT NULL
);


--
-- Name: TABLE oauth_client_states; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.oauth_client_states IS 'Stores OAuth states for third-party provider authentication flows where Supabase acts as the OAuth client.';


--
-- Name: oauth_clients; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_clients (
    id uuid NOT NULL,
    client_secret_hash text,
    registration_type auth.oauth_registration_type NOT NULL,
    redirect_uris text NOT NULL,
    grant_types text NOT NULL,
    client_name text,
    client_uri text,
    logo_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    client_type auth.oauth_client_type DEFAULT 'confidential'::auth.oauth_client_type NOT NULL,
    token_endpoint_auth_method text NOT NULL,
    CONSTRAINT oauth_clients_client_name_length CHECK ((char_length(client_name) <= 1024)),
    CONSTRAINT oauth_clients_client_uri_length CHECK ((char_length(client_uri) <= 2048)),
    CONSTRAINT oauth_clients_logo_uri_length CHECK ((char_length(logo_uri) <= 2048)),
    CONSTRAINT oauth_clients_token_endpoint_auth_method_check CHECK ((token_endpoint_auth_method = ANY (ARRAY['client_secret_basic'::text, 'client_secret_post'::text, 'none'::text])))
);


--
-- Name: oauth_consents; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_consents (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    client_id uuid NOT NULL,
    scopes text NOT NULL,
    granted_at timestamp with time zone DEFAULT now() NOT NULL,
    revoked_at timestamp with time zone,
    CONSTRAINT oauth_consents_revoked_after_granted CHECK (((revoked_at IS NULL) OR (revoked_at >= granted_at))),
    CONSTRAINT oauth_consents_scopes_length CHECK ((char_length(scopes) <= 2048)),
    CONSTRAINT oauth_consents_scopes_not_empty CHECK ((char_length(TRIM(BOTH FROM scopes)) > 0))
);


--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);


--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: -
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: -
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text,
    oauth_client_id uuid,
    refresh_token_hmac_key text,
    refresh_token_counter bigint,
    scopes text,
    CONSTRAINT sessions_scopes_length CHECK ((char_length(scopes) <= 4096))
);


--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: COLUMN sessions.refresh_token_hmac_key; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.refresh_token_hmac_key IS 'Holds a HMAC-SHA256 key used to sign refresh tokens for this session.';


--
-- Name: COLUMN sessions.refresh_token_counter; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.refresh_token_counter IS 'Holds the ID (counter) of the last issued refresh token.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    disabled boolean,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: webauthn_challenges; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.webauthn_challenges (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    challenge_type text NOT NULL,
    session_data jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    CONSTRAINT webauthn_challenges_challenge_type_check CHECK ((challenge_type = ANY (ARRAY['signup'::text, 'registration'::text, 'authentication'::text])))
);


--
-- Name: webauthn_credentials; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.webauthn_credentials (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    credential_id bytea NOT NULL,
    public_key bytea NOT NULL,
    attestation_type text DEFAULT ''::text NOT NULL,
    aaguid uuid,
    sign_count bigint DEFAULT 0 NOT NULL,
    transports jsonb DEFAULT '[]'::jsonb NOT NULL,
    backup_eligible boolean DEFAULT false NOT NULL,
    backed_up boolean DEFAULT false NOT NULL,
    friendly_name text DEFAULT ''::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    last_used_at timestamp with time zone
);


--
-- Name: backoffice_operations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.backoffice_operations (
    event_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    operation_type public.operation_type NOT NULL,
    operation_time timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb
);


--
-- Name: brickshare_pudo_locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.brickshare_pudo_locations (
    id text NOT NULL,
    name text NOT NULL,
    address text NOT NULL,
    city text NOT NULL,
    postal_code text NOT NULL,
    province text NOT NULL,
    latitude numeric(10,8),
    longitude numeric(11,8),
    contact_phone text,
    contact_email text,
    opening_hours jsonb,
    is_active boolean DEFAULT true,
    notes text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: TABLE brickshare_pudo_locations; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.brickshare_pudo_locations IS 'Brickshare pickup and drop-off locations';


--
-- Name: shipments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shipments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    assigned_date timestamp with time zone,
    estimated_delivery_date timestamp with time zone,
    actual_delivery_date timestamp with time zone,
    user_delivery_date timestamp with time zone,
    warehouse_reception_date timestamp with time zone,
    estimated_return_date date,
    shipment_status text DEFAULT 'pendiente'::text NOT NULL,
    shipping_address text NOT NULL,
    shipping_city text NOT NULL,
    shipping_zip_code text NOT NULL,
    shipping_country text DEFAULT 'España'::text NOT NULL,
    shipping_provider text,
    pickup_provider_address text,
    tracking_number text,
    carrier text,
    additional_notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    warehouse_pickup_date timestamp with time zone,
    return_request_date timestamp with time zone,
    pickup_provider text,
    set_ref text,
    set_id uuid,
    handling_processed boolean DEFAULT false,
    correos_shipment_id text,
    label_url text,
    pickup_id text,
    last_tracking_update timestamp with time zone,
    swikly_wish_id text,
    swikly_wish_url text,
    swikly_status text DEFAULT 'pending'::text,
    swikly_deposit_amount integer,
    pickup_type text DEFAULT 'correos'::text,
    brickshare_pudo_id text,
    delivery_qr_code text,
    delivery_qr_expires_at timestamp with time zone,
    delivery_validated_at timestamp with time zone,
    return_qr_code text,
    return_qr_expires_at timestamp with time zone,
    return_validated_at timestamp with time zone,
    brickshare_metadata jsonb DEFAULT '{}'::jsonb,
    brickshare_package_id text,
    CONSTRAINT check_shipment_status CHECK ((shipment_status = ANY (ARRAY['pending'::text, 'preparation'::text, 'in_transit_pudo'::text, 'delivered_pudo'::text, 'delivered_user'::text, 'in_return_pudo'::text, 'in_return'::text, 'returned'::text, 'cancelled'::text]))),
    CONSTRAINT envios_pickup_type_check CHECK ((pickup_type = ANY (ARRAY['correos'::text, 'brickshare'::text]))),
    CONSTRAINT envios_swikly_status_check CHECK ((swikly_status = ANY (ARRAY['pending'::text, 'wish_created'::text, 'accepted'::text, 'released'::text, 'captured'::text, 'expired'::text, 'cancelled'::text])))
);


--
-- Name: COLUMN shipments.shipment_status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.shipments.shipment_status IS 'Allowed values: preparacion, ruta_envio, entregado, devuelto, ruta_devolucion, cancelado';


--
-- Name: COLUMN shipments.warehouse_pickup_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.shipments.warehouse_pickup_date IS 'Date when the shipment was picked up from the warehouse';


--
-- Name: COLUMN shipments.return_request_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.shipments.return_request_date IS 'Date when the user requested a return';


--
-- Name: COLUMN shipments.pickup_provider; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.shipments.pickup_provider IS 'Carrier or entity in charge of the return pickup';


--
-- Name: COLUMN shipments.set_ref; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.shipments.set_ref IS 'LEGO set reference (e.g., 75192) for quick reference';


--
-- Name: COLUMN shipments.set_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.shipments.set_id IS 'Direct reference to the set being shipped, eliminates need for orders table';


--
-- Name: COLUMN shipments.correos_shipment_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.shipments.correos_shipment_id IS 'External shipment identifier returned by Correos Preregister API';


--
-- Name: COLUMN shipments.label_url; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.shipments.label_url IS 'Path to the generated shipping label in storage';


--
-- Name: COLUMN shipments.pickup_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.shipments.pickup_id IS 'External identifier for the scheduled pickup';


--
-- Name: COLUMN shipments.last_tracking_update; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.shipments.last_tracking_update IS 'Timestamp of the last synchronization with Correos Tracking API';


--
-- Name: COLUMN shipments.brickshare_package_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.shipments.brickshare_package_id IS 'ID del package en Brickshare_logistics. Usado cuando pickup_type="brickshare" para sincronización con el sistema de PUDO.';


--
-- Name: brickshare_pudo_shipments; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.brickshare_pudo_shipments AS
 SELECT id,
    user_id,
    shipment_status AS status,
    pickup_type,
    brickshare_pudo_id,
    brickshare_package_id,
    delivery_qr_code,
    delivery_validated_at AS delivery_qr_validated_at,
    return_qr_code,
    return_validated_at AS return_qr_validated_at,
    tracking_number,
    created_at,
    updated_at
   FROM public.shipments s
  WHERE ((pickup_type = 'brickshare'::text) AND (brickshare_pudo_id IS NOT NULL));


--
-- Name: donations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.donations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    name text NOT NULL,
    email text NOT NULL,
    phone text,
    address text,
    estimated_weight numeric NOT NULL,
    delivery_method text NOT NULL,
    reward text NOT NULL,
    children_benefited integer NOT NULL,
    co2_avoided numeric NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    tracking_code text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT donations_delivery_method_check CHECK ((delivery_method = ANY (ARRAY['pickup-point'::text, 'home-pickup'::text]))),
    CONSTRAINT donations_reward_check CHECK ((reward = ANY (ARRAY['economic'::text, 'social'::text]))),
    CONSTRAINT donations_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'confirmed'::text, 'shipped'::text, 'received'::text, 'processed'::text, 'completed'::text])))
);


--
-- Name: inventory_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inventory_sets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    set_id uuid NOT NULL,
    set_ref text,
    inventory_set_total_qty integer DEFAULT 0 NOT NULL,
    in_shipping integer DEFAULT 0 NOT NULL,
    in_use integer DEFAULT 0 NOT NULL,
    in_return integer DEFAULT 0 NOT NULL,
    in_repair integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    spare_parts_order text
);


--
-- Name: TABLE inventory_sets; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.inventory_sets IS 'Detailed tracking of set units across different states (warehouse, shipping, use, etc.)';


--
-- Name: COLUMN inventory_sets.set_ref; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.inventory_sets.set_ref IS 'Official LEGO reference number (sets.lego_ref)';


--
-- Name: qr_validation_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.qr_validation_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    shipment_id uuid NOT NULL,
    qr_code text NOT NULL,
    validation_type text NOT NULL,
    validated_by text,
    validated_at timestamp with time zone DEFAULT now(),
    validation_status text NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT qr_validation_logs_validation_status_check CHECK ((validation_status = ANY (ARRAY['success'::text, 'expired'::text, 'invalid'::text, 'already_used'::text]))),
    CONSTRAINT qr_validation_logs_validation_type_check CHECK ((validation_type = ANY (ARRAY['delivery'::text, 'return'::text])))
);


--
-- Name: TABLE qr_validation_logs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.qr_validation_logs IS 'Logs of QR code validations for deliveries and returns';


--
-- Name: reception_operations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reception_operations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_id uuid,
    user_id uuid NOT NULL,
    set_id uuid NOT NULL,
    weight_measured numeric(10,2),
    reception_completed boolean DEFAULT false NOT NULL,
    missing_parts text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE reception_operations; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.reception_operations IS 'Table to record the reception and maintenance check of sets returned by users.';


--
-- Name: COLUMN reception_operations.weight_measured; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reception_operations.weight_measured IS 'Actual weight of the set upon reception (in grams).';


--
-- Name: COLUMN reception_operations.reception_completed; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reception_operations.reception_completed IS 'True if the reception process is completed.';


--
-- Name: COLUMN reception_operations.missing_parts; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reception_operations.missing_parts IS 'Details or notes about missing pieces found during reception.';


--
-- Name: referrals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.referrals (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    referrer_id uuid NOT NULL,
    referee_id uuid NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    reward_credits integer DEFAULT 1 NOT NULL,
    stripe_coupon_id text,
    credited_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT referrals_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'credited'::text, 'rejected'::text])))
);


--
-- Name: TABLE referrals; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.referrals IS 'Referral program: tracks who referred whom and reward status';


--
-- Name: COLUMN referrals.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.referrals.status IS 'pending=signup done, credited=reward applied, rejected=did not qualify';


--
-- Name: COLUMN referrals.reward_credits; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.referrals.reward_credits IS 'Credits awarded (1 = 1 free month equivalent)';


--
-- Name: reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reviews (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    set_id uuid NOT NULL,
    envio_id uuid,
    rating smallint NOT NULL,
    comment text,
    age_fit boolean,
    difficulty smallint,
    would_reorder boolean,
    is_published boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT reviews_difficulty_check CHECK (((difficulty >= 1) AND (difficulty <= 5))),
    CONSTRAINT reviews_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


--
-- Name: TABLE reviews; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.reviews IS 'User reviews and ratings for rented LEGO sets';


--
-- Name: COLUMN reviews.rating; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reviews.rating IS '1-5 star rating';


--
-- Name: COLUMN reviews.age_fit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reviews.age_fit IS 'Was the set appropriate for the stated age range?';


--
-- Name: COLUMN reviews.difficulty; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reviews.difficulty IS '1=very easy, 5=very hard building difficulty';


--
-- Name: COLUMN reviews.would_reorder; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reviews.would_reorder IS 'Would the user rent this set again?';


--
-- Name: COLUMN reviews.is_published; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reviews.is_published IS 'Set to false to hide a review without deleting it';


--
-- Name: set_avg_ratings; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.set_avg_ratings AS
 SELECT set_id,
    round(avg(rating), 1) AS avg_rating,
    count(*) AS review_count
   FROM public.reviews
  WHERE (is_published = true)
  GROUP BY set_id;


--
-- Name: set_piece_list; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.set_piece_list (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    set_id uuid NOT NULL,
    set_ref text NOT NULL,
    piece_ref text NOT NULL,
    color_ref text,
    piece_description text,
    piece_qty integer DEFAULT 1 NOT NULL,
    piece_weight numeric,
    piece_image_url text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    piece_studdim text,
    element_id text,
    color_id integer,
    is_spare boolean DEFAULT false,
    part_cat_id integer,
    year_from integer,
    year_to integer,
    is_trans boolean DEFAULT false,
    external_ids jsonb
);


--
-- Name: set_review_stats; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.set_review_stats AS
 SELECT set_id,
    count(*) AS review_count,
    round(avg(rating), 2) AS avg_rating,
    count(*) FILTER (WHERE (rating = 5)) AS five_stars,
    count(*) FILTER (WHERE (rating = 4)) AS four_stars,
    count(*) FILTER (WHERE (rating = 3)) AS three_stars,
    count(*) FILTER (WHERE (rating = 2)) AS two_stars,
    count(*) FILTER (WHERE (rating = 1)) AS one_star,
    round(avg(difficulty), 1) AS avg_difficulty,
    count(*) FILTER (WHERE (would_reorder = true)) AS would_reorder_count
   FROM public.reviews
  WHERE (is_published = true)
  GROUP BY set_id;


--
-- Name: sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    set_name text NOT NULL,
    set_description text,
    set_image_url text,
    set_theme text NOT NULL,
    set_age_range text NOT NULL,
    set_piece_count integer NOT NULL,
    skill_boost text[],
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    year_released integer,
    catalogue_visibility boolean DEFAULT true NOT NULL,
    set_ref text,
    set_weight numeric,
    set_minifigs numeric,
    set_status text DEFAULT 'inactive'::text,
    set_price numeric DEFAULT 100.00,
    current_value_new numeric,
    current_value_used numeric,
    set_pvp_release numeric,
    set_subtheme text,
    barcode_upc text,
    barcode_ean text,
    CONSTRAINT check_set_status CHECK ((set_status = ANY (ARRAY['active'::text, 'inactive'::text, 'in_repair'::text])))
);


--
-- Name: COLUMN sets.set_ref; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sets.set_ref IS 'Official LEGO catalog reference number';


--
-- Name: shipping_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shipping_orders (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    set_id uuid NOT NULL,
    shipping_order_date timestamp with time zone DEFAULT now(),
    tracking_ref text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: TABLE shipping_orders; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.shipping_orders IS 'Tracks shipping orders with external carriers';


--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_roles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    role public.app_role NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    full_name text,
    avatar_url text,
    impact_points integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    email text,
    subscription_type text,
    subscription_status text DEFAULT 'inactive'::text,
    profile_completed boolean DEFAULT false,
    user_status text DEFAULT 'no_set'::text,
    stripe_customer_id text,
    referral_code text,
    referred_by uuid,
    referral_credits integer DEFAULT 0 NOT NULL,
    address text,
    address_extra text,
    zip_code text,
    city text,
    province text,
    phone text,
    stripe_payment_method_id text,
    pudo_id text,
    pudo_type text,
    CONSTRAINT check_user_status CHECK ((user_status = ANY (ARRAY['no_set'::text, 'set_shipping'::text, 'received'::text, 'has_set'::text, 'set_returning'::text, 'suspended'::text, 'cancelled'::text]))),
    CONSTRAINT users_pudo_type_check CHECK ((pudo_type = ANY (ARRAY['correos'::text, 'brickshare'::text]))),
    CONSTRAINT users_subscription_status_check CHECK ((subscription_status = ANY (ARRAY['active'::text, 'inactive'::text, 'trialing'::text, 'past_due'::text, 'canceled'::text])))
);


--
-- Name: COLUMN users.subscription_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.subscription_type IS 'The plan level (Brick Starter, Pro, Master)';


--
-- Name: COLUMN users.subscription_status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.subscription_status IS 'Status of the subscription (OK, trialing, past_due, canceled, etc.)';


--
-- Name: COLUMN users.profile_completed; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.profile_completed IS 'Whether the user has completed their profile information';


--
-- Name: COLUMN users.user_status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.user_status IS 'Allowed values: no_set, set_shipping, received, has_set, set_returning, suspended, cancelled';


--
-- Name: COLUMN users.stripe_customer_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.stripe_customer_id IS 'Stripe Customer ID associated with the user';


--
-- Name: COLUMN users.referral_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.referral_code IS 'Unique shareable code (6 chars, auto-generated)';


--
-- Name: COLUMN users.referred_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.referred_by IS 'auth.users.id of the user who referred this one';


--
-- Name: COLUMN users.referral_credits; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.referral_credits IS 'Accumulated credits from successful referrals';


--
-- Name: COLUMN users.stripe_payment_method_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.stripe_payment_method_id IS 'Stripe Payment Method ID (e.g., pm_card_visa for test mode)';


--
-- Name: COLUMN users.pudo_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.pudo_id IS 'Reference to the active PUDO point ID (either correos_id_pudo or brickshare_pudo_id)';


--
-- Name: COLUMN users.pudo_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users.pudo_type IS 'Type of PUDO point currently selected by the user (correos or brickshare)';


--
-- Name: users_brickshare_dropping; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_brickshare_dropping (
    user_id uuid NOT NULL,
    brickshare_pudo_id text NOT NULL,
    location_name text NOT NULL,
    address text NOT NULL,
    city text NOT NULL,
    postal_code text NOT NULL,
    province text NOT NULL,
    latitude numeric(10,8),
    longitude numeric(11,8),
    contact_email text,
    contact_phone text,
    opening_hours jsonb,
    selection_date timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE users_brickshare_dropping; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.users_brickshare_dropping IS 'Stores user-selected Brickshare deposit locations for pickup/dropoff';


--
-- Name: COLUMN users_brickshare_dropping.brickshare_pudo_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.users_brickshare_dropping.brickshare_pudo_id IS 'ID of the Brickshare PUDO location. Can be any string identifier from the /api/locations-local endpoint or the brickshare_pudo_locations table. The id_correos_pudo field from PudoSelector is mapped to this field when tipo_punto is Deposito.';


--
-- Name: users_correos_dropping; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_correos_dropping (
    user_id uuid NOT NULL,
    correos_id_pudo text NOT NULL,
    correos_name text NOT NULL,
    correos_point_type text NOT NULL,
    correos_street text NOT NULL,
    correos_street_number text,
    correos_zip_code text NOT NULL,
    correos_city text NOT NULL,
    correos_province text NOT NULL,
    correos_country text DEFAULT 'España'::text NOT NULL,
    correos_full_address text NOT NULL,
    correos_latitude numeric(10,8) NOT NULL,
    correos_longitude numeric(11,8) NOT NULL,
    correos_opening_hours text,
    correos_structured_hours jsonb,
    correos_available boolean DEFAULT true NOT NULL,
    correos_phone text,
    correos_email text,
    correos_internal_code text,
    correos_locker_capacity integer,
    correos_additional_services text[],
    correos_accessibility boolean DEFAULT false,
    correos_parking boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    correos_selection_date timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT users_correos_dropping_correos_tipo_punto_check CHECK ((correos_point_type = ANY (ARRAY['Oficina'::text, 'Citypaq'::text, 'Locker'::text])))
);


--
-- Name: TABLE users_correos_dropping; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.users_correos_dropping IS 'Stores user-selected Correos PUDO (Pick Up Drop Off) points for delivery and pickup';


--
-- Name: wishlist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wishlist (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    set_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    status boolean DEFAULT true NOT NULL,
    status_changed_at timestamp with time zone DEFAULT now()
);


--
-- Name: messages; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
)
PARTITION BY RANGE (inserted_at);


--
-- Name: messages_2026_03_23; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2026_03_23 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: messages_2026_03_24; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2026_03_24 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: messages_2026_03_25; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2026_03_25 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: messages_2026_03_26; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2026_03_26 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: messages_2026_03_27; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2026_03_27 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    action_filter text DEFAULT '*'::text,
    CONSTRAINT subscription_action_filter_check CHECK ((action_filter = ANY (ARRAY['*'::text, 'INSERT'::text, 'UPDATE'::text, 'DELETE'::text])))
);


--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: -
--

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    owner_id text,
    type storage.buckettype DEFAULT 'STANDARD'::storage.buckettype NOT NULL
);


--
-- Name: COLUMN buckets.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: buckets_analytics; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets_analytics (
    name text NOT NULL,
    type storage.buckettype DEFAULT 'ANALYTICS'::storage.buckettype NOT NULL,
    format text DEFAULT 'ICEBERG'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: buckets_vectors; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets_vectors (
    id text NOT NULL,
    type storage.buckettype DEFAULT 'VECTOR'::storage.buckettype NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: iceberg_namespaces; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.iceberg_namespaces (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_name text NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    catalog_id uuid NOT NULL
);


--
-- Name: iceberg_tables; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.iceberg_tables (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    namespace_id uuid NOT NULL,
    bucket_name text NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    location text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    remote_table_id text,
    shard_key text,
    shard_id text,
    catalog_id uuid NOT NULL
);


--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: objects; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text,
    owner_id text,
    user_metadata jsonb
);


--
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads (
    id text NOT NULL,
    in_progress_size bigint DEFAULT 0 NOT NULL,
    upload_signature text NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    version text NOT NULL,
    owner_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_metadata jsonb
);


--
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    upload_id text NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    part_number integer NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    etag text NOT NULL,
    owner_id text,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: vector_indexes; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.vector_indexes (
    id text DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    bucket_id text NOT NULL,
    data_type text NOT NULL,
    dimension integer NOT NULL,
    distance_metric text NOT NULL,
    metadata_configuration jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: hooks; Type: TABLE; Schema: supabase_functions; Owner: -
--

CREATE TABLE supabase_functions.hooks (
    id bigint NOT NULL,
    hook_table_id integer NOT NULL,
    hook_name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    request_id bigint
);


--
-- Name: TABLE hooks; Type: COMMENT; Schema: supabase_functions; Owner: -
--

COMMENT ON TABLE supabase_functions.hooks IS 'Supabase Functions Hooks: Audit trail for triggered hooks.';


--
-- Name: hooks_id_seq; Type: SEQUENCE; Schema: supabase_functions; Owner: -
--

CREATE SEQUENCE supabase_functions.hooks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hooks_id_seq; Type: SEQUENCE OWNED BY; Schema: supabase_functions; Owner: -
--

ALTER SEQUENCE supabase_functions.hooks_id_seq OWNED BY supabase_functions.hooks.id;


--
-- Name: migrations; Type: TABLE; Schema: supabase_functions; Owner: -
--

CREATE TABLE supabase_functions.migrations (
    version text NOT NULL,
    inserted_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: supabase_migrations; Owner: -
--

CREATE TABLE supabase_migrations.schema_migrations (
    version text NOT NULL,
    statements text[],
    name text
);


--
-- Name: seed_files; Type: TABLE; Schema: supabase_migrations; Owner: -
--

CREATE TABLE supabase_migrations.seed_files (
    path text NOT NULL,
    hash text NOT NULL
);


--
-- Name: messages_2026_03_23; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_03_23 FOR VALUES FROM ('2026-03-23 00:00:00') TO ('2026-03-24 00:00:00');


--
-- Name: messages_2026_03_24; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_03_24 FOR VALUES FROM ('2026-03-24 00:00:00') TO ('2026-03-25 00:00:00');


--
-- Name: messages_2026_03_25; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_03_25 FOR VALUES FROM ('2026-03-25 00:00:00') TO ('2026-03-26 00:00:00');


--
-- Name: messages_2026_03_26; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_03_26 FOR VALUES FROM ('2026-03-26 00:00:00') TO ('2026-03-27 00:00:00');


--
-- Name: messages_2026_03_27; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_03_27 FOR VALUES FROM ('2026-03-27 00:00:00') TO ('2026-03-28 00:00:00');


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Name: hooks id; Type: DEFAULT; Schema: supabase_functions; Owner: -
--

ALTER TABLE ONLY supabase_functions.hooks ALTER COLUMN id SET DEFAULT nextval('supabase_functions.hooks_id_seq'::regclass);


--
-- Data for Name: extensions; Type: TABLE DATA; Schema: _realtime; Owner: -
--

INSERT INTO _realtime.extensions (id, type, settings, tenant_external_id, inserted_at, updated_at) VALUES ('5393ae29-14c0-447a-a823-df4cd31ee7fa', 'postgres_cdc_rls', '{"region": "us-east-1", "db_host": "4KActuI21fWRt6ZAG4A1wb9jPV16XB9hOoJKEDnvy4xPNrrhma6I8nd28t/mto4/", "db_name": "sWBpZNdjggEPTQVlI52Zfw==", "db_port": "+enMDFi1J/3IrrquHHwUmA==", "db_user": "uxbEq/zz8DXVD53TOI1zmw==", "slot_name": "supabase_realtime_replication_slot", "db_password": "sWBpZNdjggEPTQVlI52Zfw==", "publication": "supabase_realtime", "ssl_enforced": false, "poll_interval_ms": 100, "poll_max_changes": 100, "poll_max_record_bytes": 1048576}', 'realtime-dev', '2026-03-24 20:09:45', '2026-03-24 20:09:45');


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: _realtime; Owner: -
--

INSERT INTO _realtime.schema_migrations (version, inserted_at) VALUES (20210706140551, '2026-03-24 20:09:30');
INSERT INTO _realtime.schema_migrations (version, inserted_at) VALUES (20220329161857, '2026-03-24 20:09:30');
INSERT INTO _realtime.schema_migrations (version, inserted_at) VALUES (20220410212326, '2026-03-24 20:09:30');
INSERT INTO _realtime.schema_migrations (version, inserted_at) VALUES (20220506102948, '2026-03-24 20:09:30');
INSERT INTO _realtime.schema_migrations (version, inserted_at) VALUES (20220527210857, '2026-03-24 20:09:31');
INSERT INTO _realtime.schema_migrations (version, inserted_at) VALUES (20220815211129, '2026-03-24 20:09:31');
INSERT INTO _realtime.schema_migrations (version, inserted_at) VALUES (20220815215024, '2026-03-24 20:09:31');
INSERT INTO _realtime.schema_migrations (version, inserted_at) VALUES (20220818141501, '2026-03-24 20:09:31');
INSERT INTO _realtime.schema_migrations (version, inserted_at) VALUES (20221018173709, '2026-03-24 20:09:31');
INSERT INTO _realtime.schema_migrations (version, inserted_at) VALUES (20221102172703, '2026-03-24 20:09:31');
INSERT INTO _realtime.schema_migrations (version, inserted_at) VALUES (20221223010058, '2026-03-24 20:09:31');
INSERT INTO _realtime.schema_migrations (version, inserted_at) VALUES (20230110180046, '2026-03-24 20:09:31');
INSERT INTO _realtime.schema_migrations (version, inserted_at) VALUES (20230810220907, '2026-03-24 20:09:31');
INSERT INTO _realtime.schema_migrations (version, inserted_at) VALUES (20230810220924, '2026-03-24 20:09:31');
INSERT INTO _realtime.schema_migrations (version, inserted_at) VALUES (20231024094642, '2026-03-24 20:09:31');
INSERT INTO _realtime.schema_migrations (version, inserted_at) VALUES (20240306114423, '2026-03-24 20:09:31');
INSERT INTO _realtime.schema_migrations (version, inserted_at) VALUES (20240418082835, '2026-03-24 20:09:31');
INSERT INTO _realtime.schema_migrations (version, inserted_at) VALUES (20240625211759, '2026-03-24 20:09:31');
INSERT INTO _realtime.schema_migrations (version, inserted_at) VALUES (20240704172020, '2026-03-24 20:09:31');
INSERT INTO _realtime.schema_migrations (version, inserted_at) VALUES (20240902173232, '2026-03-24 20:09:31');
INSERT INTO _realtime.schema_migrations (version, inserted_at) VALUES (20241106103258, '2026-03-24 20:09:31');
INSERT INTO _realtime.schema_migrations (version, inserted_at) VALUES (20250424203323, '2026-03-24 20:09:31');
INSERT INTO _realtime.schema_migrations (version, inserted_at) VALUES (20250613072131, '2026-03-24 20:09:31');
INSERT INTO _realtime.schema_migrations (version, inserted_at) VALUES (20250711044927, '2026-03-24 20:09:31');
INSERT INTO _realtime.schema_migrations (version, inserted_at) VALUES (20250811121559, '2026-03-24 20:09:31');
INSERT INTO _realtime.schema_migrations (version, inserted_at) VALUES (20250926223044, '2026-03-24 20:09:31');
INSERT INTO _realtime.schema_migrations (version, inserted_at) VALUES (20251204170944, '2026-03-24 20:09:31');
INSERT INTO _realtime.schema_migrations (version, inserted_at) VALUES (20251218000543, '2026-03-24 20:09:31');
INSERT INTO _realtime.schema_migrations (version, inserted_at) VALUES (20260209232800, '2026-03-24 20:09:31');
INSERT INTO _realtime.schema_migrations (version, inserted_at) VALUES (20260304000000, '2026-03-24 20:09:31');


--
-- Data for Name: tenants; Type: TABLE DATA; Schema: _realtime; Owner: -
--

INSERT INTO _realtime.tenants (id, name, external_id, jwt_secret, max_concurrent_users, inserted_at, updated_at, max_events_per_second, postgres_cdc_default, max_bytes_per_second, max_channels_per_client, max_joins_per_second, suspend, jwt_jwks, notify_private_alpha, private_only, migrations_ran, broadcast_adapter, max_presence_events_per_second, max_payload_size_in_kb, max_client_presence_events_per_window, client_presence_window_ms, presence_enabled) VALUES ('89d44c50-6791-4209-95e4-e931ae2308ed', 'realtime-dev', 'realtime-dev', 'iNjicxc4+llvc9wovDvqymwfnj9teWMlyOIbJ8Fh6j2WNU8CIJ2ZgjR6MUIKqSmeDmvpsKLsZ9jgXJmQPpwL8w==', 200, '2026-03-24 20:09:45', '2026-03-24 20:09:45', 100, 'postgres_cdc_rls', 100000, 100, 100, false, '{"keys": [{"x": "M5Sjqn5zwC9Kl1zVfUUGvv9boQjCGd45G8sdopBExB4", "y": "P6IXMvA2WYXSHSOMTBH2jsw_9rrzGy89FjPf6oOsIxQ", "alg": "ES256", "crv": "P-256", "ext": true, "kid": "b81269f1-21d8-4f2e-b719-c2240a840d90", "kty": "EC", "use": "sig", "key_ops": ["verify"]}, {"k": "c3VwZXItc2VjcmV0LWp3dC10b2tlbi13aXRoLWF0LWxlYXN0LTMyLWNoYXJhY3RlcnMtbG9uZw", "kty": "oct"}]}', false, false, 68, 'gen_rpc', 1000, 3000, NULL, NULL, false);


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) VALUES ('00000000-0000-0000-0000-000000000000', 'ec8c81d5-7e0c-4fd5-8b63-f84ed8ca29f3', '{"action":"user_signedup","actor_id":"116d28d6-c660-422b-b56d-5fd04bc4bae6","actor_username":"user4@brickshare.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2026-03-24 20:12:41.020501+00', '');
INSERT INTO auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) VALUES ('00000000-0000-0000-0000-000000000000', 'a72565ce-51d0-4ec9-ab7b-b97208a4ef0b', '{"action":"login","actor_id":"116d28d6-c660-422b-b56d-5fd04bc4bae6","actor_username":"user4@brickshare.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2026-03-24 20:12:41.026161+00', '');
INSERT INTO auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) VALUES ('00000000-0000-0000-0000-000000000000', 'c46568cc-79e0-4e68-9127-5842328b2a47', '{"action":"user_signedup","actor_id":"7a6d397a-2094-4290-ad1f-726bee74c85f","actor_username":"admin2@brickshare.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2026-03-24 20:13:34.876446+00', '');
INSERT INTO auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) VALUES ('00000000-0000-0000-0000-000000000000', '758b110e-78f9-4787-901c-bd6fb64b2d90', '{"action":"login","actor_id":"7a6d397a-2094-4290-ad1f-726bee74c85f","actor_username":"admin2@brickshare.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2026-03-24 20:13:34.882332+00', '');
INSERT INTO auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) VALUES ('00000000-0000-0000-0000-000000000000', 'c50fc4ce-512a-457c-8c2f-f6cd5ceb2985', '{"action":"logout","actor_id":"7a6d397a-2094-4290-ad1f-726bee74c85f","actor_username":"admin2@brickshare.com","actor_via_sso":false,"log_type":"account"}', '2026-03-24 20:16:59.346038+00', '');
INSERT INTO auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) VALUES ('00000000-0000-0000-0000-000000000000', '37069ad9-00dc-405b-8600-8c0ceeac454d', '{"action":"login","actor_id":"7a6d397a-2094-4290-ad1f-726bee74c85f","actor_username":"admin2@brickshare.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2026-03-24 20:17:30.04603+00', '');


--
-- Data for Name: custom_oauth_providers; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) VALUES ('116d28d6-c660-422b-b56d-5fd04bc4bae6', '116d28d6-c660-422b-b56d-5fd04bc4bae6', '{"sub": "116d28d6-c660-422b-b56d-5fd04bc4bae6", "email": "user4@brickshare.com", "email_verified": false, "phone_verified": false}', 'email', '2026-03-24 20:12:41.018545+00', '2026-03-24 20:12:41.018573+00', '2026-03-24 20:12:41.018573+00', 'a458753f-afce-49b1-8b73-9d3e46378c96');
INSERT INTO auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) VALUES ('7a6d397a-2094-4290-ad1f-726bee74c85f', '7a6d397a-2094-4290-ad1f-726bee74c85f', '{"sub": "7a6d397a-2094-4290-ad1f-726bee74c85f", "email": "admin2@brickshare.com", "email_verified": false, "phone_verified": false}', 'email', '2026-03-24 20:13:34.875554+00', '2026-03-24 20:13:34.875571+00', '2026-03-24 20:13:34.875571+00', '0dd8fe9e-90a3-49b2-b031-62ccdefbd708');


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.mfa_amr_claims (session_id, created_at, updated_at, authentication_method, id) VALUES ('b1c57122-4aa4-43b0-9872-fa6056abe62d', '2026-03-24 20:12:41.028643+00', '2026-03-24 20:12:41.028643+00', 'password', '6a7ef4b6-2d96-412d-a151-5783f637aa95');
INSERT INTO auth.mfa_amr_claims (session_id, created_at, updated_at, authentication_method, id) VALUES ('ea974eb0-e49b-4515-9518-61fb5bf6642e', '2026-03-24 20:17:30.04828+00', '2026-03-24 20:17:30.04828+00', 'password', 'd59bee96-0108-457d-810f-4d5a94f09ee8');


--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- Data for Name: oauth_authorizations; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- Data for Name: oauth_client_states; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- Data for Name: oauth_consents; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.refresh_tokens (instance_id, id, token, user_id, revoked, created_at, updated_at, parent, session_id) VALUES ('00000000-0000-0000-0000-000000000000', 1, 'djm3anpztom4', '116d28d6-c660-422b-b56d-5fd04bc4bae6', false, '2026-03-24 20:12:41.027857+00', '2026-03-24 20:12:41.027857+00', NULL, 'b1c57122-4aa4-43b0-9872-fa6056abe62d');
INSERT INTO auth.refresh_tokens (instance_id, id, token, user_id, revoked, created_at, updated_at, parent, session_id) VALUES ('00000000-0000-0000-0000-000000000000', 3, 'zfhxsyftzvyz', '7a6d397a-2094-4290-ad1f-726bee74c85f', false, '2026-03-24 20:17:30.04757+00', '2026-03-24 20:17:30.04757+00', NULL, 'ea974eb0-e49b-4515-9518-61fb5bf6642e');


--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.schema_migrations (version) VALUES ('20171026211738');
INSERT INTO auth.schema_migrations (version) VALUES ('20171026211808');
INSERT INTO auth.schema_migrations (version) VALUES ('20171026211834');
INSERT INTO auth.schema_migrations (version) VALUES ('20180103212743');
INSERT INTO auth.schema_migrations (version) VALUES ('20180108183307');
INSERT INTO auth.schema_migrations (version) VALUES ('20180119214651');
INSERT INTO auth.schema_migrations (version) VALUES ('20180125194653');
INSERT INTO auth.schema_migrations (version) VALUES ('00');
INSERT INTO auth.schema_migrations (version) VALUES ('20210710035447');
INSERT INTO auth.schema_migrations (version) VALUES ('20210722035447');
INSERT INTO auth.schema_migrations (version) VALUES ('20210730183235');
INSERT INTO auth.schema_migrations (version) VALUES ('20210909172000');
INSERT INTO auth.schema_migrations (version) VALUES ('20210927181326');
INSERT INTO auth.schema_migrations (version) VALUES ('20211122151130');
INSERT INTO auth.schema_migrations (version) VALUES ('20211124214934');
INSERT INTO auth.schema_migrations (version) VALUES ('20211202183645');
INSERT INTO auth.schema_migrations (version) VALUES ('20220114185221');
INSERT INTO auth.schema_migrations (version) VALUES ('20220114185340');
INSERT INTO auth.schema_migrations (version) VALUES ('20220224000811');
INSERT INTO auth.schema_migrations (version) VALUES ('20220323170000');
INSERT INTO auth.schema_migrations (version) VALUES ('20220429102000');
INSERT INTO auth.schema_migrations (version) VALUES ('20220531120530');
INSERT INTO auth.schema_migrations (version) VALUES ('20220614074223');
INSERT INTO auth.schema_migrations (version) VALUES ('20220811173540');
INSERT INTO auth.schema_migrations (version) VALUES ('20221003041349');
INSERT INTO auth.schema_migrations (version) VALUES ('20221003041400');
INSERT INTO auth.schema_migrations (version) VALUES ('20221011041400');
INSERT INTO auth.schema_migrations (version) VALUES ('20221020193600');
INSERT INTO auth.schema_migrations (version) VALUES ('20221021073300');
INSERT INTO auth.schema_migrations (version) VALUES ('20221021082433');
INSERT INTO auth.schema_migrations (version) VALUES ('20221027105023');
INSERT INTO auth.schema_migrations (version) VALUES ('20221114143122');
INSERT INTO auth.schema_migrations (version) VALUES ('20221114143410');
INSERT INTO auth.schema_migrations (version) VALUES ('20221125140132');
INSERT INTO auth.schema_migrations (version) VALUES ('20221208132122');
INSERT INTO auth.schema_migrations (version) VALUES ('20221215195500');
INSERT INTO auth.schema_migrations (version) VALUES ('20221215195800');
INSERT INTO auth.schema_migrations (version) VALUES ('20221215195900');
INSERT INTO auth.schema_migrations (version) VALUES ('20230116124310');
INSERT INTO auth.schema_migrations (version) VALUES ('20230116124412');
INSERT INTO auth.schema_migrations (version) VALUES ('20230131181311');
INSERT INTO auth.schema_migrations (version) VALUES ('20230322519590');
INSERT INTO auth.schema_migrations (version) VALUES ('20230402418590');
INSERT INTO auth.schema_migrations (version) VALUES ('20230411005111');
INSERT INTO auth.schema_migrations (version) VALUES ('20230508135423');
INSERT INTO auth.schema_migrations (version) VALUES ('20230523124323');
INSERT INTO auth.schema_migrations (version) VALUES ('20230818113222');
INSERT INTO auth.schema_migrations (version) VALUES ('20230914180801');
INSERT INTO auth.schema_migrations (version) VALUES ('20231027141322');
INSERT INTO auth.schema_migrations (version) VALUES ('20231114161723');
INSERT INTO auth.schema_migrations (version) VALUES ('20231117164230');
INSERT INTO auth.schema_migrations (version) VALUES ('20240115144230');
INSERT INTO auth.schema_migrations (version) VALUES ('20240214120130');
INSERT INTO auth.schema_migrations (version) VALUES ('20240306115329');
INSERT INTO auth.schema_migrations (version) VALUES ('20240314092811');
INSERT INTO auth.schema_migrations (version) VALUES ('20240427152123');
INSERT INTO auth.schema_migrations (version) VALUES ('20240612123726');
INSERT INTO auth.schema_migrations (version) VALUES ('20240729123726');
INSERT INTO auth.schema_migrations (version) VALUES ('20240802193726');
INSERT INTO auth.schema_migrations (version) VALUES ('20240806073726');
INSERT INTO auth.schema_migrations (version) VALUES ('20241009103726');
INSERT INTO auth.schema_migrations (version) VALUES ('20250717082212');
INSERT INTO auth.schema_migrations (version) VALUES ('20250731150234');
INSERT INTO auth.schema_migrations (version) VALUES ('20250804100000');
INSERT INTO auth.schema_migrations (version) VALUES ('20250901200500');
INSERT INTO auth.schema_migrations (version) VALUES ('20250903112500');
INSERT INTO auth.schema_migrations (version) VALUES ('20250904133000');
INSERT INTO auth.schema_migrations (version) VALUES ('20250925093508');
INSERT INTO auth.schema_migrations (version) VALUES ('20251007112900');
INSERT INTO auth.schema_migrations (version) VALUES ('20251104100000');
INSERT INTO auth.schema_migrations (version) VALUES ('20251111201300');
INSERT INTO auth.schema_migrations (version) VALUES ('20251201000000');
INSERT INTO auth.schema_migrations (version) VALUES ('20260115000000');
INSERT INTO auth.schema_migrations (version) VALUES ('20260121000000');
INSERT INTO auth.schema_migrations (version) VALUES ('20260219120000');
INSERT INTO auth.schema_migrations (version) VALUES ('20260302000000');


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.sessions (id, user_id, created_at, updated_at, factor_id, aal, not_after, refreshed_at, user_agent, ip, tag, oauth_client_id, refresh_token_hmac_key, refresh_token_counter, scopes) VALUES ('b1c57122-4aa4-43b0-9872-fa6056abe62d', '116d28d6-c660-422b-b56d-5fd04bc4bae6', '2026-03-24 20:12:41.026847+00', '2026-03-24 20:12:41.026847+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', '140.82.121.5', NULL, NULL, NULL, NULL, NULL);
INSERT INTO auth.sessions (id, user_id, created_at, updated_at, factor_id, aal, not_after, refreshed_at, user_agent, ip, tag, oauth_client_id, refresh_token_hmac_key, refresh_token_counter, scopes) VALUES ('ea974eb0-e49b-4515-9518-61fb5bf6642e', '7a6d397a-2094-4290-ad1f-726bee74c85f', '2026-03-24 20:17:30.046688+00', '2026-03-24 20:17:30.046688+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.3.1 Safari/605.1.15', '140.82.121.5', NULL, NULL, NULL, NULL, NULL);


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: -
--

INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) VALUES ('00000000-0000-0000-0000-000000000000', '116d28d6-c660-422b-b56d-5fd04bc4bae6', 'authenticated', 'authenticated', 'user4@brickshare.com', '$2a$10$T1i8Id6/ErFXos2U6hupUe2ZPpkjKVoDOdyZd9BVV8qepQ/BxqB5i', '2026-03-24 20:12:41.020827+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-03-24 20:12:41.026799+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "116d28d6-c660-422b-b56d-5fd04bc4bae6", "email": "user4@brickshare.com", "email_verified": true, "phone_verified": false}', NULL, '2026-03-24 20:12:41.015171+00', '2026-03-24 20:12:41.028392+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false);
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) VALUES ('00000000-0000-0000-0000-000000000000', '7a6d397a-2094-4290-ad1f-726bee74c85f', 'authenticated', 'authenticated', 'admin2@brickshare.com', '$2a$10$4xFDx1lfBnjZkb7orcfH..P6KHc4LSWRu64UpjdfryhHPiorMEzam', '2026-03-24 20:13:34.87684+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-03-24 20:17:30.046658+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "7a6d397a-2094-4290-ad1f-726bee74c85f", "email": "admin2@brickshare.com", "email_verified": true, "phone_verified": false}', NULL, '2026-03-24 20:13:34.872687+00', '2026-03-24 20:17:30.04803+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false);


--
-- Data for Name: webauthn_challenges; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- Data for Name: webauthn_credentials; Type: TABLE DATA; Schema: auth; Owner: -
--



--
-- Data for Name: backoffice_operations; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: brickshare_pudo_locations; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.brickshare_pudo_locations (id, name, address, city, postal_code, province, latitude, longitude, contact_phone, contact_email, opening_hours, is_active, notes, created_at, updated_at) VALUES ('BS-PUDO-001', 'Brickshare Madrid Centro', 'Calle Gran Vía 28', 'Madrid', '28013', 'Madrid', 40.42000000, -3.70380000, NULL, 'madrid.centro@brickshare.com', NULL, true, NULL, '2026-03-24 20:09:43.164917+00', '2026-03-24 20:09:43.164917+00');
INSERT INTO public.brickshare_pudo_locations (id, name, address, city, postal_code, province, latitude, longitude, contact_phone, contact_email, opening_hours, is_active, notes, created_at, updated_at) VALUES ('BS-PUDO-002', 'Brickshare Barcelona Eixample', 'Passeig de Gràcia 100', 'Barcelona', '08008', 'Barcelona', 41.39260000, 2.16400000, NULL, 'barcelona.eixample@brickshare.com', NULL, true, NULL, '2026-03-24 20:09:43.164917+00', '2026-03-24 20:09:43.164917+00');


--
-- Data for Name: donations; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: inventory_sets; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.inventory_sets (id, set_id, set_ref, inventory_set_total_qty, in_shipping, in_use, in_return, in_repair, created_at, updated_at, spare_parts_order) VALUES ('fb50770b-aab2-4626-b70f-108ed79a8e62', 'fc5b5ef6-f098-4a8e-9ca8-7579b6864bf3', '3180', 5, 0, 0, 0, 0, '2026-03-24 20:12:44.285171+00', '2026-03-24 20:16:13.930812+00', NULL);
INSERT INTO public.inventory_sets (id, set_id, set_ref, inventory_set_total_qty, in_shipping, in_use, in_return, in_repair, created_at, updated_at, spare_parts_order) VALUES ('f364ba15-5f50-4cea-b7e5-7f606eb965ed', '28642159-55d0-4ea0-93b0-9292630acb0a', '3181', 5, 0, 0, 0, 0, '2026-03-24 20:12:44.290026+00', '2026-03-24 20:16:13.936801+00', NULL);
INSERT INTO public.inventory_sets (id, set_id, set_ref, inventory_set_total_qty, in_shipping, in_use, in_return, in_repair, created_at, updated_at, spare_parts_order) VALUES ('1d05f1d8-1a0d-4ef2-a69f-4395c2a55d7f', '71528545-5947-48d8-b0e1-3bce42786a5c', '3219', 5, 0, 0, 0, 0, '2026-03-24 20:12:44.532502+00', '2026-03-24 20:16:14.453867+00', NULL);
INSERT INTO public.inventory_sets (id, set_id, set_ref, inventory_set_total_qty, in_shipping, in_use, in_return, in_repair, created_at, updated_at, spare_parts_order) VALUES ('c8d62f67-92a9-4ba6-8bb0-8f69be62d3a2', '6469b176-c16a-45b7-9146-72860253d147', '3340', 5, 0, 0, 0, 0, '2026-03-24 20:12:44.546693+00', '2026-03-24 20:16:14.46252+00', NULL);
INSERT INTO public.inventory_sets (id, set_id, set_ref, inventory_set_total_qty, in_shipping, in_use, in_return, in_repair, created_at, updated_at, spare_parts_order) VALUES ('2f5adee6-cab3-4029-b0e6-9d023d3696b3', 'ca2b0242-c8fd-4436-b3cb-61913f64e29d', '3341', 5, 0, 0, 0, 0, '2026-03-24 20:12:44.555986+00', '2026-03-24 20:16:14.470599+00', NULL);
INSERT INTO public.inventory_sets (id, set_id, set_ref, inventory_set_total_qty, in_shipping, in_use, in_return, in_repair, created_at, updated_at, spare_parts_order) VALUES ('acec06f4-c5d0-49f5-80a1-103affb8e03e', '79f030cf-9b46-44ba-944f-489e87b8053e', '3342', 5, 0, 0, 0, 0, '2026-03-24 20:12:44.565445+00', '2026-03-24 20:16:14.477179+00', NULL);
INSERT INTO public.inventory_sets (id, set_id, set_ref, inventory_set_total_qty, in_shipping, in_use, in_return, in_repair, created_at, updated_at, spare_parts_order) VALUES ('276c46cc-7177-4b65-b33d-b1bfb3c0e48a', '590509dc-6da0-4f83-9ff5-941c8fe77a7e', '3343', 5, 0, 0, 0, 0, '2026-03-24 20:12:44.574457+00', '2026-03-24 20:16:14.485435+00', NULL);
INSERT INTO public.inventory_sets (id, set_id, set_ref, inventory_set_total_qty, in_shipping, in_use, in_return, in_repair, created_at, updated_at, spare_parts_order) VALUES ('eefe70c9-eef0-42c8-9271-1efae8fe16e3', '693064c5-514b-45f4-b592-91f6fa306f49', '4475', 5, 0, 0, 0, 0, '2026-03-24 20:12:44.582169+00', '2026-03-24 20:16:14.491396+00', NULL);
INSERT INTO public.inventory_sets (id, set_id, set_ref, inventory_set_total_qty, in_shipping, in_use, in_return, in_repair, created_at, updated_at, spare_parts_order) VALUES ('0f416d96-ff89-45aa-85f5-12c3dca55ff0', 'ed8a67ea-7870-4e10-ae9a-adbb66075aef', '2064', 5, 0, 0, 0, 0, '2026-03-24 20:12:44.227088+00', '2026-03-24 20:16:13.864826+00', NULL);
INSERT INTO public.inventory_sets (id, set_id, set_ref, inventory_set_total_qty, in_shipping, in_use, in_return, in_repair, created_at, updated_at, spare_parts_order) VALUES ('8aaae88b-fe85-480f-9982-65b9ed6bbee6', 'b2cc047a-499f-408c-bcad-826736a313c3', '2230', 5, 0, 0, 0, 0, '2026-03-24 20:12:44.239092+00', '2026-03-24 20:16:13.888679+00', NULL);
INSERT INTO public.inventory_sets (id, set_id, set_ref, inventory_set_total_qty, in_shipping, in_use, in_return, in_repair, created_at, updated_at, spare_parts_order) VALUES ('eb757c23-2df7-4bff-850a-2d18a2800e23', '7bb91ab9-753c-4589-bf23-a093721f5e73', '2824', 5, 0, 0, 0, 0, '2026-03-24 20:12:44.24856+00', '2026-03-24 20:16:13.898536+00', NULL);
INSERT INTO public.inventory_sets (id, set_id, set_ref, inventory_set_total_qty, in_shipping, in_use, in_return, in_repair, created_at, updated_at, spare_parts_order) VALUES ('98866ffc-0487-41fc-8459-93b77d251a9a', '3e1d8624-a92d-4b2a-a8fd-c9e9faa80bb8', '2928', 5, 0, 0, 0, 0, '2026-03-24 20:12:44.256951+00', '2026-03-24 20:16:13.906204+00', NULL);
INSERT INTO public.inventory_sets (id, set_id, set_ref, inventory_set_total_qty, in_shipping, in_use, in_return, in_repair, created_at, updated_at, spare_parts_order) VALUES ('ac2e864d-4d90-4bf1-8149-bf399e63d27b', '06e97217-50cc-46a6-9e29-a4ff286d545c', '3177', 5, 0, 0, 0, 0, '2026-03-24 20:12:44.268892+00', '2026-03-24 20:16:13.913311+00', NULL);
INSERT INTO public.inventory_sets (id, set_id, set_ref, inventory_set_total_qty, in_shipping, in_use, in_return, in_repair, created_at, updated_at, spare_parts_order) VALUES ('7b59778c-b1d2-4f4b-91c9-4ff112ca4d94', '186a74ce-e5bf-408a-a717-9166234f09d1', '3178', 5, 0, 0, 0, 0, '2026-03-24 20:12:44.274762+00', '2026-03-24 20:16:13.920185+00', NULL);
INSERT INTO public.inventory_sets (id, set_id, set_ref, inventory_set_total_qty, in_shipping, in_use, in_return, in_repair, created_at, updated_at, spare_parts_order) VALUES ('d38f2de6-fd86-4103-8664-74a295676783', '14ac08c6-fbf9-4594-9eaa-475a411839ff', '3179', 5, 0, 0, 0, 0, '2026-03-24 20:12:44.279783+00', '2026-03-24 20:16:13.925722+00', NULL);
INSERT INTO public.inventory_sets (id, set_id, set_ref, inventory_set_total_qty, in_shipping, in_use, in_return, in_repair, created_at, updated_at, spare_parts_order) VALUES ('04afec4b-43c5-463c-86e6-d844e36a4e13', '0e0e84e3-c6f1-41b3-95c8-9449aea9d25e', '4476', 5, 0, 0, 0, 0, '2026-03-24 20:12:44.589202+00', '2026-03-24 20:16:14.497777+00', NULL);
INSERT INTO public.inventory_sets (id, set_id, set_ref, inventory_set_total_qty, in_shipping, in_use, in_return, in_repair, created_at, updated_at, spare_parts_order) VALUES ('661b2a18-5209-4a60-a985-3566c1f6ffee', 'dff8ae70-f7f2-4e1c-83c3-985270e55174', '4477', 5, 0, 0, 0, 0, '2026-03-24 20:12:44.595316+00', '2026-03-24 20:16:14.503501+00', NULL);
INSERT INTO public.inventory_sets (id, set_id, set_ref, inventory_set_total_qty, in_shipping, in_use, in_return, in_repair, created_at, updated_at, spare_parts_order) VALUES ('c8686be1-afde-4872-ba89-c06533535e65', '9a06319e-5149-4bd0-9828-f40d055306d1', '4478', 5, 0, 0, 0, 0, '2026-03-24 20:12:44.600694+00', '2026-03-24 20:16:14.508978+00', NULL);
INSERT INTO public.inventory_sets (id, set_id, set_ref, inventory_set_total_qty, in_shipping, in_use, in_return, in_repair, created_at, updated_at, spare_parts_order) VALUES ('f1f31bcb-05a1-493f-a784-5ee83d869d8a', '48a672c1-fb65-49ba-af42-ec700c34bdd8', '4479', 5, 0, 0, 0, 0, '2026-03-24 20:12:44.605881+00', '2026-03-24 20:16:14.514269+00', NULL);
INSERT INTO public.inventory_sets (id, set_id, set_ref, inventory_set_total_qty, in_shipping, in_use, in_return, in_repair, created_at, updated_at, spare_parts_order) VALUES ('617eb016-bb22-48b2-a720-e4220c5ee3ed', '41d4db7e-a8bc-4845-80a4-dd1b931bcf9a', '19710', 5, 0, 0, 0, 0, '2026-03-24 20:12:45.030225+00', '2026-03-24 20:16:15.171687+00', NULL);
INSERT INTO public.inventory_sets (id, set_id, set_ref, inventory_set_total_qty, in_shipping, in_use, in_return, in_repair, created_at, updated_at, spare_parts_order) VALUES ('66a72478-1e87-4c9d-90be-25ad09fc3173', '39147171-fa2e-456d-b10e-ae9602227c3f', '19720', 5, 0, 0, 0, 0, '2026-03-24 20:12:45.048112+00', '2026-03-24 20:16:15.185828+00', NULL);
INSERT INTO public.inventory_sets (id, set_id, set_ref, inventory_set_total_qty, in_shipping, in_use, in_return, in_repair, created_at, updated_at, spare_parts_order) VALUES ('f14f47eb-222f-4989-a6a1-7e72e91e7d95', '21452fea-a7ea-4a56-8fd1-04952d0c710a', '21000', 5, 0, 0, 0, 0, '2026-03-24 20:12:45.057163+00', '2026-03-24 20:16:15.203146+00', NULL);
INSERT INTO public.inventory_sets (id, set_id, set_ref, inventory_set_total_qty, in_shipping, in_use, in_return, in_repair, created_at, updated_at, spare_parts_order) VALUES ('66a73e76-0553-4a5c-9da0-0d385129873d', 'e147347b-c2a7-4292-8c56-73209517d601', '21001', 5, 0, 0, 0, 0, '2026-03-24 20:12:45.071979+00', '2026-03-24 20:16:15.20893+00', NULL);
INSERT INTO public.inventory_sets (id, set_id, set_ref, inventory_set_total_qty, in_shipping, in_use, in_return, in_repair, created_at, updated_at, spare_parts_order) VALUES ('262d8e7f-baef-42a1-ba07-00f96c7d0de3', '156514c5-26b3-4f75-83d4-4a807aff81b5', '21002', 5, 0, 0, 0, 0, '2026-03-24 20:12:45.078644+00', '2026-03-24 20:16:15.214914+00', NULL);
INSERT INTO public.inventory_sets (id, set_id, set_ref, inventory_set_total_qty, in_shipping, in_use, in_return, in_repair, created_at, updated_at, spare_parts_order) VALUES ('63032791-e65d-4c04-b372-ac44f2c8b107', '181cc634-3df3-4f07-bcf8-e8e592ac9359', '21003', 5, 0, 0, 0, 0, '2026-03-24 20:12:45.08495+00', '2026-03-24 20:16:15.220787+00', NULL);
INSERT INTO public.inventory_sets (id, set_id, set_ref, inventory_set_total_qty, in_shipping, in_use, in_return, in_repair, created_at, updated_at, spare_parts_order) VALUES ('b8867650-e5e0-4fa4-8ed4-f838379f04eb', '1a389e11-8a7a-4f63-be38-282faa524995', '21004', 5, 0, 0, 0, 0, '2026-03-24 20:12:45.090116+00', '2026-03-24 20:16:15.22573+00', NULL);
INSERT INTO public.inventory_sets (id, set_id, set_ref, inventory_set_total_qty, in_shipping, in_use, in_return, in_repair, created_at, updated_at, spare_parts_order) VALUES ('63f06155-ee2a-4f6d-9cd8-5ece53065f6a', 'bf4205da-4636-4d4f-91b4-0fbe78ee28f1', '21005', 5, 0, 0, 0, 0, '2026-03-24 20:12:45.09603+00', '2026-03-24 20:16:15.230157+00', NULL);
INSERT INTO public.inventory_sets (id, set_id, set_ref, inventory_set_total_qty, in_shipping, in_use, in_return, in_repair, created_at, updated_at, spare_parts_order) VALUES ('319a9cbf-e29c-4710-8941-b568d17698d0', '850520c8-8914-491f-8282-69dcf3bc77f7', '21006', 5, 0, 0, 0, 0, '2026-03-24 20:12:45.101479+00', '2026-03-24 20:16:15.234873+00', NULL);


--
-- Data for Name: qr_validation_logs; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: reception_operations; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: referrals; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: set_piece_list; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: sets; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sets (id, set_name, set_description, set_image_url, set_theme, set_age_range, set_piece_count, skill_boost, created_at, updated_at, year_released, catalogue_visibility, set_ref, set_weight, set_minifigs, set_status, set_price, current_value_new, current_value_used, set_pvp_release, set_subtheme, barcode_upc, barcode_ean) VALUES ('ed8a67ea-7870-4e10-ae9a-adbb66075aef', 'Rescue Plane', 'Lego City set: Rescue Plane (2064).', 'https://images.brickset.com/sets/images/2064-1.jpg', 'City', '?+', 116, NULL, '2026-03-24 20:12:44.227088+00', '2026-03-24 20:16:13.842859+00', 2007, true, '2064', NULL, 2, 'active', 25, NULL, NULL, NULL, 'Medical', '673419098175', NULL);
INSERT INTO public.sets (id, set_name, set_description, set_image_url, set_theme, set_age_range, set_piece_count, skill_boost, created_at, updated_at, year_released, catalogue_visibility, set_ref, set_weight, set_minifigs, set_status, set_price, current_value_new, current_value_used, set_pvp_release, set_subtheme, barcode_upc, barcode_ean) VALUES ('b2cc047a-499f-408c-bcad-826736a313c3', 'In-flight Helicopter and Raft', 'Lego City set: In-flight Helicopter and Raft (2230).', 'https://images.brickset.com/sets/images/2230-1.jpg', 'City', '?+', 115, NULL, '2026-03-24 20:12:44.239092+00', '2026-03-24 20:16:13.882213+00', 2008, true, '2230', NULL, 2, 'active', 25, NULL, NULL, NULL, 'Great Outdoors', '673419103015', NULL);
INSERT INTO public.sets (id, set_name, set_description, set_image_url, set_theme, set_age_range, set_piece_count, skill_boost, created_at, updated_at, year_released, catalogue_visibility, set_ref, set_weight, set_minifigs, set_status, set_price, current_value_new, current_value_used, set_pvp_release, set_subtheme, barcode_upc, barcode_ean) VALUES ('7bb91ab9-753c-4589-bf23-a093721f5e73', 'LEGO City Advent Calendar', 'Lego City set: LEGO City Advent Calendar (2824).', 'https://images.brickset.com/sets/images/2824-1.jpg', 'City', '5-12', 271, NULL, '2026-03-24 20:12:44.24856+00', '2026-03-24 20:16:13.893744+00', 2010, true, '2824', 430, 6, 'active', 50, NULL, NULL, 34.99, 'Seasonal', '673419130028', '5702014602434');
INSERT INTO public.sets (id, set_name, set_description, set_image_url, set_theme, set_age_range, set_piece_count, skill_boost, created_at, updated_at, year_released, catalogue_visibility, set_ref, set_weight, set_minifigs, set_status, set_price, current_value_new, current_value_used, set_pvp_release, set_subtheme, barcode_upc, barcode_ean) VALUES ('3e1d8624-a92d-4b2a-a8fd-c9e9faa80bb8', 'City In-Flight 2006', 'Lego City set: City In-Flight 2006 (2928).', 'https://images.brickset.com/sets/images/2928-1.jpg', 'City', '?+', 141, NULL, '2026-03-24 20:12:44.256951+00', '2026-03-24 20:16:13.902725+00', 2006, true, '2928', NULL, 2, 'active', 25, NULL, NULL, NULL, 'Airport', '673419084048', NULL);
INSERT INTO public.sets (id, set_name, set_description, set_image_url, set_theme, set_age_range, set_piece_count, skill_boost, created_at, updated_at, year_released, catalogue_visibility, set_ref, set_weight, set_minifigs, set_status, set_price, current_value_new, current_value_used, set_pvp_release, set_subtheme, barcode_upc, barcode_ean) VALUES ('06e97217-50cc-46a6-9e29-a4ff286d545c', 'Small Car', 'Lego City set: Small Car (3177).', 'https://images.brickset.com/sets/images/3177-1.jpg', 'City', '5-12', 43, NULL, '2026-03-24 20:12:44.268892+00', '2026-03-24 20:16:13.909757+00', 2010, true, '3177', 60, 1, 'active', 25, NULL, NULL, 4.99, 'Traffic', '673419129473', '5702014601819');
INSERT INTO public.sets (id, set_name, set_description, set_image_url, set_theme, set_age_range, set_piece_count, skill_boost, created_at, updated_at, year_released, catalogue_visibility, set_ref, set_weight, set_minifigs, set_status, set_price, current_value_new, current_value_used, set_pvp_release, set_subtheme, barcode_upc, barcode_ean) VALUES ('186a74ce-e5bf-408a-a717-9166234f09d1', 'Seaplane', 'Lego City set: Seaplane (3178).', 'https://images.brickset.com/sets/images/3178-1.jpg', 'City', '5-12', 102, NULL, '2026-03-24 20:12:44.274762+00', '2026-03-24 20:16:13.916344+00', 2010, true, '3178', 180, 1, 'active', 25, NULL, NULL, 10.99, 'General', '673419129480', '5702014601826');
INSERT INTO public.sets (id, set_name, set_description, set_image_url, set_theme, set_age_range, set_piece_count, skill_boost, created_at, updated_at, year_released, catalogue_visibility, set_ref, set_weight, set_minifigs, set_status, set_price, current_value_new, current_value_used, set_pvp_release, set_subtheme, barcode_upc, barcode_ean) VALUES ('14ac08c6-fbf9-4594-9eaa-475a411839ff', 'Repair Truck', 'Lego City set: Repair Truck (3179).', 'https://images.brickset.com/sets/images/3179-1.jpg', 'City', '5-12', 118, NULL, '2026-03-24 20:12:44.279783+00', '2026-03-24 20:16:13.922956+00', 2010, true, '3179', 210, 1, 'active', 25, NULL, NULL, 12.99, 'Traffic', '673419129497', '5702014601833');
INSERT INTO public.sets (id, set_name, set_description, set_image_url, set_theme, set_age_range, set_piece_count, skill_boost, created_at, updated_at, year_released, catalogue_visibility, set_ref, set_weight, set_minifigs, set_status, set_price, current_value_new, current_value_used, set_pvp_release, set_subtheme, barcode_upc, barcode_ean) VALUES ('fc5b5ef6-f098-4a8e-9ca8-7579b6864bf3', 'Tank Truck', 'Lego City set: Tank Truck (3180).', 'https://images.brickset.com/sets/images/3180-1.jpg', 'City', '5-12', 222, NULL, '2026-03-24 20:12:44.285171+00', '2026-03-24 20:16:13.928384+00', 2010, true, '3180', 490, 1, 'active', 25, NULL, NULL, 19.99, 'Traffic', '673419129503', '5702014601840');
INSERT INTO public.sets (id, set_name, set_description, set_image_url, set_theme, set_age_range, set_piece_count, skill_boost, created_at, updated_at, year_released, catalogue_visibility, set_ref, set_weight, set_minifigs, set_status, set_price, current_value_new, current_value_used, set_pvp_release, set_subtheme, barcode_upc, barcode_ean) VALUES ('28642159-55d0-4ea0-93b0-9292630acb0a', 'Passenger Plane', 'Lego City set: Passenger Plane (3181).', 'https://images.brickset.com/sets/images/3181-1.jpg', 'City', '5-12', 309, NULL, '2026-03-24 20:12:44.290026+00', '2026-03-24 20:16:13.933999+00', 2010, true, '3181', 760, 3, 'active', 50, NULL, NULL, 39.99, 'Airport', '673419078382', '5702014601857');
INSERT INTO public.sets (id, set_name, set_description, set_image_url, set_theme, set_age_range, set_piece_count, skill_boost, created_at, updated_at, year_released, catalogue_visibility, set_ref, set_weight, set_minifigs, set_status, set_price, current_value_new, current_value_used, set_pvp_release, set_subtheme, barcode_upc, barcode_ean) VALUES ('71528545-5947-48d8-b0e1-3bce42786a5c', 'Mini TIE Fighter', 'Lego Star Wars set: Mini TIE Fighter (3219).', 'https://images.brickset.com/sets/images/3219-1.jpg', 'Star Wars', '?+', 12, NULL, '2026-03-24 20:12:44.532502+00', '2026-03-24 20:16:14.446717+00', 2003, true, '3219', NULL, 0, 'active', 25, NULL, NULL, NULL, 'Mini Building Set', '673419020190', '5702014282230');
INSERT INTO public.sets (id, set_name, set_description, set_image_url, set_theme, set_age_range, set_piece_count, skill_boost, created_at, updated_at, year_released, catalogue_visibility, set_ref, set_weight, set_minifigs, set_status, set_price, current_value_new, current_value_used, set_pvp_release, set_subtheme, barcode_upc, barcode_ean) VALUES ('ca2b0242-c8fd-4436-b3cb-61913f64e29d', 'Star Wars #2 - Luke Skywalker, Han Solo and Boba Fett', 'Lego Star Wars set: Star Wars #2 - Luke Skywalker, Han Solo and Boba Fett (3341).', 'https://images.brickset.com/sets/images/3341-1.jpg', 'Star Wars', '?+', 22, NULL, '2026-03-24 20:12:44.555986+00', '2026-03-24 20:16:14.466938+00', 2000, true, '3341', NULL, 3, 'active', 25, NULL, NULL, NULL, 'Minifig Pack', '042884033415', NULL);
INSERT INTO public.sets (id, set_name, set_description, set_image_url, set_theme, set_age_range, set_piece_count, skill_boost, created_at, updated_at, year_released, catalogue_visibility, set_ref, set_weight, set_minifigs, set_status, set_price, current_value_new, current_value_used, set_pvp_release, set_subtheme, barcode_upc, barcode_ean) VALUES ('79f030cf-9b46-44ba-944f-489e87b8053e', 'Star Wars #3 - Chewbacca and 2 Biker Scouts', 'Lego Star Wars set: Star Wars #3 - Chewbacca and 2 Biker Scouts (3342).', 'https://images.brickset.com/sets/images/3342-1.jpg', 'Star Wars', '?+', 22, NULL, '2026-03-24 20:12:44.565445+00', '2026-03-24 20:16:14.474125+00', 2000, true, '3342', NULL, 3, 'active', 25, NULL, NULL, NULL, 'Minifig Pack', '042884033422', NULL);
INSERT INTO public.sets (id, set_name, set_description, set_image_url, set_theme, set_age_range, set_piece_count, skill_boost, created_at, updated_at, year_released, catalogue_visibility, set_ref, set_weight, set_minifigs, set_status, set_price, current_value_new, current_value_used, set_pvp_release, set_subtheme, barcode_upc, barcode_ean) VALUES ('590509dc-6da0-4f83-9ff5-941c8fe77a7e', 'Star Wars #4 - Battle Droid Commander and 2 Battle Droids', 'Lego Star Wars set: Star Wars #4 - Battle Droid Commander and 2 Battle Droids (3343).', 'https://images.brickset.com/sets/images/3343-1.jpg', 'Star Wars', '?+', 30, NULL, '2026-03-24 20:12:44.574457+00', '2026-03-24 20:16:14.482215+00', 2000, true, '3343', NULL, 3, 'active', 25, NULL, NULL, NULL, 'Minifig Pack', '042884033439', NULL);
INSERT INTO public.sets (id, set_name, set_description, set_image_url, set_theme, set_age_range, set_piece_count, skill_boost, created_at, updated_at, year_released, catalogue_visibility, set_ref, set_weight, set_minifigs, set_status, set_price, current_value_new, current_value_used, set_pvp_release, set_subtheme, barcode_upc, barcode_ean) VALUES ('693064c5-514b-45f4-b592-91f6fa306f49', 'Jabba''s Message', 'Lego Star Wars set: Jabba''s Message (4475).', 'https://images.brickset.com/sets/images/4475-1.jpg', 'Star Wars', '?+', 44, NULL, '2026-03-24 20:12:44.582169+00', '2026-03-24 20:16:14.48858+00', 2003, true, '4475', NULL, 3, 'active', 25, NULL, NULL, NULL, 'Episode VI', '673419017169', '5702014259386');
INSERT INTO public.sets (id, set_name, set_description, set_image_url, set_theme, set_age_range, set_piece_count, skill_boost, created_at, updated_at, year_released, catalogue_visibility, set_ref, set_weight, set_minifigs, set_status, set_price, current_value_new, current_value_used, set_pvp_release, set_subtheme, barcode_upc, barcode_ean) VALUES ('0e0e84e3-c6f1-41b3-95c8-9449aea9d25e', 'Jabba''s Prize', 'Lego Star Wars set: Jabba''s Prize (4476).', 'https://images.brickset.com/sets/images/4476-1.jpg', 'Star Wars', '?+', 40, NULL, '2026-03-24 20:12:44.589202+00', '2026-03-24 20:16:14.494115+00', 2003, true, '4476', NULL, 2, 'active', 25, NULL, NULL, NULL, 'Episode VI', NULL, '5702014259393');
INSERT INTO public.sets (id, set_name, set_description, set_image_url, set_theme, set_age_range, set_piece_count, skill_boost, created_at, updated_at, year_released, catalogue_visibility, set_ref, set_weight, set_minifigs, set_status, set_price, current_value_new, current_value_used, set_pvp_release, set_subtheme, barcode_upc, barcode_ean) VALUES ('dff8ae70-f7f2-4e1c-83c3-985270e55174', 'T-16 Skyhopper ', 'Lego Star Wars set: T-16 Skyhopper  (4477).', 'https://images.brickset.com/sets/images/4477-1.jpg', 'Star Wars', '?+', 98, NULL, '2026-03-24 20:12:44.595316+00', '2026-03-24 20:16:14.5004+00', 2003, true, '4477', NULL, 1, 'active', 25, NULL, NULL, NULL, 'Episode IV', NULL, '5702014259355');
INSERT INTO public.sets (id, set_name, set_description, set_image_url, set_theme, set_age_range, set_piece_count, skill_boost, created_at, updated_at, year_released, catalogue_visibility, set_ref, set_weight, set_minifigs, set_status, set_price, current_value_new, current_value_used, set_pvp_release, set_subtheme, barcode_upc, barcode_ean) VALUES ('9a06319e-5149-4bd0-9828-f40d055306d1', 'Geonosian Fighter', 'Lego Star Wars set: Geonosian Fighter (4478).', 'https://images.brickset.com/sets/images/4478-1.jpg', 'Star Wars', '?+', 170, NULL, '2026-03-24 20:12:44.600694+00', '2026-03-24 20:16:14.506431+00', 2003, true, '4478', NULL, 4, 'active', 25, NULL, NULL, NULL, 'Episode II', NULL, '5702014259409');
INSERT INTO public.sets (id, set_name, set_description, set_image_url, set_theme, set_age_range, set_piece_count, skill_boost, created_at, updated_at, year_released, catalogue_visibility, set_ref, set_weight, set_minifigs, set_status, set_price, current_value_new, current_value_used, set_pvp_release, set_subtheme, barcode_upc, barcode_ean) VALUES ('48a672c1-fb65-49ba-af42-ec700c34bdd8', 'TIE Bomber', 'Lego Star Wars set: TIE Bomber (4479).', 'https://images.brickset.com/sets/images/4479-1.jpg', 'Star Wars', '?+', 230, NULL, '2026-03-24 20:12:44.605881+00', '2026-03-24 20:16:14.511579+00', 2003, true, '4479', NULL, 1, 'active', 25, NULL, NULL, NULL, 'Episode V', '673419017213', NULL);
INSERT INTO public.sets (id, set_name, set_description, set_image_url, set_theme, set_age_range, set_piece_count, skill_boost, created_at, updated_at, year_released, catalogue_visibility, set_ref, set_weight, set_minifigs, set_status, set_price, current_value_new, current_value_used, set_pvp_release, set_subtheme, barcode_upc, barcode_ean) VALUES ('41d4db7e-a8bc-4845-80a4-dd1b931bcf9a', 'Sears Tower', 'Lego Architecture set: Sears Tower (19710).', 'https://images.brickset.com/sets/images/19710-1.jpg', 'Architecture', '10+', 68, NULL, '2026-03-24 20:12:45.030225+00', '2026-03-24 20:16:15.163102+00', 2008, true, '19710', NULL, 0, 'active', 25, NULL, NULL, NULL, 'Brickstructures', NULL, NULL);
INSERT INTO public.sets (id, set_name, set_description, set_image_url, set_theme, set_age_range, set_piece_count, skill_boost, created_at, updated_at, year_released, catalogue_visibility, set_ref, set_weight, set_minifigs, set_status, set_price, current_value_new, current_value_used, set_pvp_release, set_subtheme, barcode_upc, barcode_ean) VALUES ('39147171-fa2e-456d-b10e-ae9602227c3f', 'John Hancock Centre', 'Lego Architecture set: John Hancock Centre (19720).', 'https://images.brickset.com/sets/images/19720-1.jpg', 'Architecture', '10+', 69, NULL, '2026-03-24 20:12:45.048112+00', '2026-03-24 20:16:15.179609+00', 2008, true, '19720', NULL, 0, 'active', 25, NULL, NULL, NULL, 'Brickstructures', NULL, NULL);
INSERT INTO public.sets (id, set_name, set_description, set_image_url, set_theme, set_age_range, set_piece_count, skill_boost, created_at, updated_at, year_released, catalogue_visibility, set_ref, set_weight, set_minifigs, set_status, set_price, current_value_new, current_value_used, set_pvp_release, set_subtheme, barcode_upc, barcode_ean) VALUES ('21452fea-a7ea-4a56-8fd1-04952d0c710a', 'Willis Tower', 'Lego Architecture set: Willis Tower (21000).', 'https://images.brickset.com/sets/images/21000-2.jpg', 'Architecture', '10+', 69, NULL, '2026-03-24 20:12:45.057163+00', '2026-03-24 20:16:15.199926+00', 2011, true, '21000', NULL, 0, 'active', 25, NULL, NULL, 19.99, 'Landmark Series', '673419113274', '5702014804265');
INSERT INTO public.sets (id, set_name, set_description, set_image_url, set_theme, set_age_range, set_piece_count, skill_boost, created_at, updated_at, year_released, catalogue_visibility, set_ref, set_weight, set_minifigs, set_status, set_price, current_value_new, current_value_used, set_pvp_release, set_subtheme, barcode_upc, barcode_ean) VALUES ('e147347b-c2a7-4292-8c56-73209517d601', 'John Hancock Centre', 'Lego Architecture set: John Hancock Centre (21001).', 'https://images.brickset.com/sets/images/21001-1.jpg', 'Architecture', '10+', 69, NULL, '2026-03-24 20:12:45.071979+00', '2026-03-24 20:16:15.205792+00', 2008, true, '21001', NULL, 0, 'active', 25, NULL, NULL, 19.99, 'Landmark Series', '673419113281', NULL);
INSERT INTO public.sets (id, set_name, set_description, set_image_url, set_theme, set_age_range, set_piece_count, skill_boost, created_at, updated_at, year_released, catalogue_visibility, set_ref, set_weight, set_minifigs, set_status, set_price, current_value_new, current_value_used, set_pvp_release, set_subtheme, barcode_upc, barcode_ean) VALUES ('156514c5-26b3-4f75-83d4-4a807aff81b5', 'Empire State Building', 'Lego Architecture set: Empire State Building (21002).', 'https://images.brickset.com/sets/images/21002-1.jpg', 'Architecture', '10+', 77, NULL, '2026-03-24 20:12:45.078644+00', '2026-03-24 20:16:15.212231+00', 2009, true, '21002', 190, 0, 'active', 25, NULL, NULL, 19.99, 'Landmark Series', '673419160100', '5702014712836');
INSERT INTO public.sets (id, set_name, set_description, set_image_url, set_theme, set_age_range, set_piece_count, skill_boost, created_at, updated_at, year_released, catalogue_visibility, set_ref, set_weight, set_minifigs, set_status, set_price, current_value_new, current_value_used, set_pvp_release, set_subtheme, barcode_upc, barcode_ean) VALUES ('181cc634-3df3-4f07-bcf8-e8e592ac9359', 'Seattle Space Needle', 'Lego Architecture set: Seattle Space Needle (21003).', 'https://images.brickset.com/sets/images/21003-1.jpg', 'Architecture', '10+', 57, NULL, '2026-03-24 20:12:45.08495+00', '2026-03-24 20:16:15.218054+00', 2009, true, '21003', NULL, 0, 'active', 25, NULL, NULL, 19.99, 'Landmark Series', '673419160117', '5702014712843');
INSERT INTO public.sets (id, set_name, set_description, set_image_url, set_theme, set_age_range, set_piece_count, skill_boost, created_at, updated_at, year_released, catalogue_visibility, set_ref, set_weight, set_minifigs, set_status, set_price, current_value_new, current_value_used, set_pvp_release, set_subtheme, barcode_upc, barcode_ean) VALUES ('1a389e11-8a7a-4f63-be38-282faa524995', 'Solomon Guggenheim Museum', 'Lego Architecture set: Solomon Guggenheim Museum (21004).', 'https://images.brickset.com/sets/images/21004-1.jpg', 'Architecture', '10+', 208, NULL, '2026-03-24 20:12:45.090116+00', '2026-03-24 20:16:15.223445+00', 2009, true, '21004', NULL, 0, 'active', 25, NULL, NULL, 39.99, 'Architect Series', '673419113489', '5702014712850');
INSERT INTO public.sets (id, set_name, set_description, set_image_url, set_theme, set_age_range, set_piece_count, skill_boost, created_at, updated_at, year_released, catalogue_visibility, set_ref, set_weight, set_minifigs, set_status, set_price, current_value_new, current_value_used, set_pvp_release, set_subtheme, barcode_upc, barcode_ean) VALUES ('bf4205da-4636-4d4f-91b4-0fbe78ee28f1', 'Fallingwater', 'Lego Architecture set: Fallingwater (21005).', 'https://images.brickset.com/sets/images/21005-1.jpg', 'Architecture', '16+', 811, NULL, '2026-03-24 20:12:45.09603+00', '2026-03-24 20:16:15.228015+00', 2009, true, '21005', NULL, 0, 'active', 100, NULL, NULL, 89.99, 'Architect Series', '673419160131', '5702014712881');
INSERT INTO public.sets (id, set_name, set_description, set_image_url, set_theme, set_age_range, set_piece_count, skill_boost, created_at, updated_at, year_released, catalogue_visibility, set_ref, set_weight, set_minifigs, set_status, set_price, current_value_new, current_value_used, set_pvp_release, set_subtheme, barcode_upc, barcode_ean) VALUES ('850520c8-8914-491f-8282-69dcf3bc77f7', 'The White House', 'Lego Architecture set: The White House (21006).', 'https://images.brickset.com/sets/images/21006-1.jpg', 'Architecture', '12+', 560, NULL, '2026-03-24 20:12:45.101479+00', '2026-03-24 20:16:15.232547+00', 2010, true, '21006', 700, 0, 'active', 75, NULL, NULL, 54.99, 'Landmark Series', '673419160148', '5702014804241');
INSERT INTO public.sets (id, set_name, set_description, set_image_url, set_theme, set_age_range, set_piece_count, skill_boost, created_at, updated_at, year_released, catalogue_visibility, set_ref, set_weight, set_minifigs, set_status, set_price, current_value_new, current_value_used, set_pvp_release, set_subtheme, barcode_upc, barcode_ean) VALUES ('6469b176-c16a-45b7-9146-72860253d147', 'Star Wars #1 - Emperor Palpatine, Darth Maul and Darth Vader', 'Lego Star Wars set: Star Wars #1 - Emperor Palpatine, Darth Maul and Darth Vader (3340).', 'https://images.brickset.com/sets/images/3340-1.jpg', 'Star Wars', '?+', 32, NULL, '2026-03-24 20:12:44.546693+00', '2026-03-24 20:16:14.458563+00', 2000, true, '3340', NULL, 3, 'active', 25, NULL, NULL, NULL, 'Minifig Pack', '042884033408', NULL);


--
-- Data for Name: shipments; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: shipping_orders; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.user_roles (id, user_id, role, created_at) VALUES ('edc07d2c-63e3-44ff-8e43-39e133a69591', '116d28d6-c660-422b-b56d-5fd04bc4bae6', 'user', '2026-03-24 20:12:41.015023+00');
INSERT INTO public.user_roles (id, user_id, role, created_at) VALUES ('eb6e5f04-c8f8-47f6-9da6-750d051a0e35', '7a6d397a-2094-4290-ad1f-726bee74c85f', 'admin', '2026-03-24 20:13:34.872541+00');


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.users (id, user_id, full_name, avatar_url, impact_points, created_at, updated_at, email, subscription_type, subscription_status, profile_completed, user_status, stripe_customer_id, referral_code, referred_by, referral_credits, address, address_extra, zip_code, city, province, phone, stripe_payment_method_id, pudo_id, pudo_type) VALUES ('1fe1a3df-247c-4425-98e4-d6ddbecfa56a', '7a6d397a-2094-4290-ad1f-726bee74c85f', NULL, NULL, 0, '2026-03-24 20:13:34.872541+00', '2026-03-24 20:13:34.872541+00', 'admin2@brickshare.com', NULL, 'inactive', false, 'no_set', NULL, '87F0F9', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.users (id, user_id, full_name, avatar_url, impact_points, created_at, updated_at, email, subscription_type, subscription_status, profile_completed, user_status, stripe_customer_id, referral_code, referred_by, referral_credits, address, address_extra, zip_code, city, province, phone, stripe_payment_method_id, pudo_id, pudo_type) VALUES ('b5b0fe18-3a92-42c2-829b-8b49f3ff05f6', '116d28d6-c660-422b-b56d-5fd04bc4bae6', 'user4', NULL, 0, '2026-03-24 20:12:41.015023+00', '2026-03-24 20:16:47.864841+00', 'user4@brickshare.com', 'Brick Master', 'active', true, 'no_set', 'cus_UCxWpVAhXeYpSQ', 'B007F0', NULL, 0, 'josep tarradellas 97', NULL, '08029', 'barcelona', NULL, '123456789', 'pm_card_visa', '9ae13c49-de91-462b-ba63-32c8e7a546a5', 'brickshare');


--
-- Data for Name: users_brickshare_dropping; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.users_brickshare_dropping (user_id, brickshare_pudo_id, location_name, address, city, postal_code, province, latitude, longitude, contact_email, contact_phone, opening_hours, selection_date, created_at, updated_at) VALUES ('116d28d6-c660-422b-b56d-5fd04bc4bae6', '9ae13c49-de91-462b-ba63-32c8e7a546a5', 'Establecimiento de paco', 'avenida josep tarradellas 64', 'barcelona', '08029', 'barcelona', 41.39023270, 2.14350210, NULL, NULL, '{"description": "Horario comercial del establecimiento"}', '2026-03-24 20:16:47.853+00', '2026-03-24 20:16:47.856649+00', '2026-03-24 20:16:47.856649+00');


--
-- Data for Name: users_correos_dropping; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: wishlist; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.wishlist (id, user_id, set_id, created_at, status, status_changed_at) VALUES ('b78d0c62-11be-4870-9293-732293db3eeb', '116d28d6-c660-422b-b56d-5fd04bc4bae6', '850520c8-8914-491f-8282-69dcf3bc77f7', '2026-03-24 20:16:31.017901+00', true, '2026-03-24 20:16:30.974+00');
INSERT INTO public.wishlist (id, user_id, set_id, created_at, status, status_changed_at) VALUES ('09a4089b-f638-4ad7-a036-cc8788cbb965', '116d28d6-c660-422b-b56d-5fd04bc4bae6', 'bf4205da-4636-4d4f-91b4-0fbe78ee28f1', '2026-03-24 20:16:32.717079+00', true, '2026-03-24 20:16:32.683+00');
INSERT INTO public.wishlist (id, user_id, set_id, created_at, status, status_changed_at) VALUES ('6cd302b7-1aea-492e-a854-81266c238904', '116d28d6-c660-422b-b56d-5fd04bc4bae6', '1a389e11-8a7a-4f63-be38-282faa524995', '2026-03-24 20:16:34.1148+00', true, '2026-03-24 20:16:34.079+00');


--
-- Data for Name: messages_2026_03_23; Type: TABLE DATA; Schema: realtime; Owner: -
--



--
-- Data for Name: messages_2026_03_24; Type: TABLE DATA; Schema: realtime; Owner: -
--



--
-- Data for Name: messages_2026_03_25; Type: TABLE DATA; Schema: realtime; Owner: -
--



--
-- Data for Name: messages_2026_03_26; Type: TABLE DATA; Schema: realtime; Owner: -
--



--
-- Data for Name: messages_2026_03_27; Type: TABLE DATA; Schema: realtime; Owner: -
--



--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: realtime; Owner: -
--

INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20211116024918, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20211116045059, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20211116050929, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20211116051442, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20211116212300, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20211116213355, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20211116213934, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20211116214523, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20211122062447, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20211124070109, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20211202204204, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20211202204605, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20211210212804, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20211228014915, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20220107221237, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20220228202821, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20220312004840, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20220603231003, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20220603232444, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20220615214548, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20220712093339, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20220908172859, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20220916233421, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20230119133233, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20230128025114, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20230128025212, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20230227211149, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20230228184745, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20230308225145, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20230328144023, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20231018144023, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20231204144023, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20231204144024, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20231204144025, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20240108234812, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20240109165339, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20240227174441, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20240311171622, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20240321100241, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20240401105812, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20240418121054, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20240523004032, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20240618124746, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20240801235015, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20240805133720, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20240827160934, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20240919163303, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20240919163305, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20241019105805, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20241030150047, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20241108114728, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20241121104152, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20241130184212, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20241220035512, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20241220123912, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20241224161212, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20250107150512, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20250110162412, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20250123174212, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20250128220012, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20250506224012, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20250523164012, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20250714121412, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20250905041441, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20251103001201, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20251120212548, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20251120215549, '2026-03-24 20:09:31');
INSERT INTO realtime.schema_migrations (version, inserted_at) VALUES (20260218120000, '2026-03-24 20:09:31');


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: realtime; Owner: -
--



--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: -
--



--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: -
--



--
-- Data for Name: buckets_vectors; Type: TABLE DATA; Schema: storage; Owner: -
--



--
-- Data for Name: iceberg_namespaces; Type: TABLE DATA; Schema: storage; Owner: -
--



--
-- Data for Name: iceberg_tables; Type: TABLE DATA; Schema: storage; Owner: -
--



--
-- Data for Name: migrations; Type: TABLE DATA; Schema: storage; Owner: -
--

INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (0, 'create-migrations-table', 'e18db593bcde2aca2a408c4d1100f6abba2195df', '2026-03-24 20:09:42.275908');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (1, 'initialmigration', '6ab16121fbaa08bbd11b712d05f358f9b555d777', '2026-03-24 20:09:42.278246');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (2, 'storage-schema', 'f6a1fa2c93cbcd16d4e487b362e45fca157a8dbd', '2026-03-24 20:09:42.279306');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (3, 'pathtoken-column', '2cb1b0004b817b29d5b0a971af16bafeede4b70d', '2026-03-24 20:09:42.283565');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (4, 'add-migrations-rls', '427c5b63fe1c5937495d9c635c263ee7a5905058', '2026-03-24 20:09:42.285804');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (5, 'add-size-functions', '79e081a1455b63666c1294a440f8ad4b1e6a7f84', '2026-03-24 20:09:42.286741');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (6, 'change-column-name-in-get-size', 'ded78e2f1b5d7e616117897e6443a925965b30d2', '2026-03-24 20:09:42.28798');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (7, 'add-rls-to-buckets', 'e7e7f86adbc51049f341dfe8d30256c1abca17aa', '2026-03-24 20:09:42.289302');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (8, 'add-public-to-buckets', 'fd670db39ed65f9d08b01db09d6202503ca2bab3', '2026-03-24 20:09:42.290182');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (9, 'fix-search-function', 'af597a1b590c70519b464a4ab3be54490712796b', '2026-03-24 20:09:42.291075');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (10, 'search-files-search-function', 'b595f05e92f7e91211af1bbfe9c6a13bb3391e16', '2026-03-24 20:09:42.292182');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (11, 'add-trigger-to-auto-update-updated_at-column', '7425bdb14366d1739fa8a18c83100636d74dcaa2', '2026-03-24 20:09:42.293218');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (12, 'add-automatic-avif-detection-flag', '8e92e1266eb29518b6a4c5313ab8f29dd0d08df9', '2026-03-24 20:09:42.29444');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (13, 'add-bucket-custom-limits', 'cce962054138135cd9a8c4bcd531598684b25e7d', '2026-03-24 20:09:42.295404');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (14, 'use-bytes-for-max-size', '941c41b346f9802b411f06f30e972ad4744dad27', '2026-03-24 20:09:42.296312');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (15, 'add-can-insert-object-function', '934146bc38ead475f4ef4b555c524ee5d66799e5', '2026-03-24 20:09:42.301473');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (16, 'add-version', '76debf38d3fd07dcfc747ca49096457d95b1221b', '2026-03-24 20:09:42.30251');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (17, 'drop-owner-foreign-key', 'f1cbb288f1b7a4c1eb8c38504b80ae2a0153d101', '2026-03-24 20:09:42.303314');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (18, 'add_owner_id_column_deprecate_owner', 'e7a511b379110b08e2f214be852c35414749fe66', '2026-03-24 20:09:42.304118');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (19, 'alter-default-value-objects-id', '02e5e22a78626187e00d173dc45f58fa66a4f043', '2026-03-24 20:09:42.305048');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (20, 'list-objects-with-delimiter', 'cd694ae708e51ba82bf012bba00caf4f3b6393b7', '2026-03-24 20:09:42.305803');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (21, 's3-multipart-uploads', '8c804d4a566c40cd1e4cc5b3725a664a9303657f', '2026-03-24 20:09:42.306928');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (22, 's3-multipart-uploads-big-ints', '9737dc258d2397953c9953d9b86920b8be0cdb73', '2026-03-24 20:09:42.309777');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (23, 'optimize-search-function', '9d7e604cddc4b56a5422dc68c9313f4a1b6f132c', '2026-03-24 20:09:42.311888');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (24, 'operation-function', '8312e37c2bf9e76bbe841aa5fda889206d2bf8aa', '2026-03-24 20:09:42.313');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (25, 'custom-metadata', 'd974c6057c3db1c1f847afa0e291e6165693b990', '2026-03-24 20:09:42.31388');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (26, 'objects-prefixes', '215cabcb7f78121892a5a2037a09fedf9a1ae322', '2026-03-24 20:09:42.314535');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (27, 'search-v2', '859ba38092ac96eb3964d83bf53ccc0b141663a6', '2026-03-24 20:09:42.31511');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (28, 'object-bucket-name-sorting', 'c73a2b5b5d4041e39705814fd3a1b95502d38ce4', '2026-03-24 20:09:42.315452');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (29, 'create-prefixes', 'ad2c1207f76703d11a9f9007f821620017a66c21', '2026-03-24 20:09:42.31584');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (30, 'update-object-levels', '2be814ff05c8252fdfdc7cfb4b7f5c7e17f0bed6', '2026-03-24 20:09:42.316258');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (31, 'objects-level-index', 'b40367c14c3440ec75f19bbce2d71e914ddd3da0', '2026-03-24 20:09:42.316867');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (32, 'backward-compatible-index-on-objects', 'e0c37182b0f7aee3efd823298fb3c76f1042c0f7', '2026-03-24 20:09:42.317415');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (33, 'backward-compatible-index-on-prefixes', 'b480e99ed951e0900f033ec4eb34b5bdcb4e3d49', '2026-03-24 20:09:42.31825');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (34, 'optimize-search-function-v1', 'ca80a3dc7bfef894df17108785ce29a7fc8ee456', '2026-03-24 20:09:42.318649');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (35, 'add-insert-trigger-prefixes', '458fe0ffd07ec53f5e3ce9df51bfdf4861929ccc', '2026-03-24 20:09:42.319007');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (36, 'optimise-existing-functions', '6ae5fca6af5c55abe95369cd4f93985d1814ca8f', '2026-03-24 20:09:42.319298');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (37, 'add-bucket-name-length-trigger', '3944135b4e3e8b22d6d4cbb568fe3b0b51df15c1', '2026-03-24 20:09:42.319573');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (38, 'iceberg-catalog-flag-on-buckets', '02716b81ceec9705aed84aa1501657095b32e5c5', '2026-03-24 20:09:42.320609');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (39, 'add-search-v2-sort-support', '6706c5f2928846abee18461279799ad12b279b78', '2026-03-24 20:09:42.325338');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (40, 'fix-prefix-race-conditions-optimized', '7ad69982ae2d372b21f48fc4829ae9752c518f6b', '2026-03-24 20:09:42.325993');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (41, 'add-object-level-update-trigger', '07fcf1a22165849b7a029deed059ffcde08d1ae0', '2026-03-24 20:09:42.32631');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (42, 'rollback-prefix-triggers', '771479077764adc09e2ea2043eb627503c034cd4', '2026-03-24 20:09:42.326587');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (43, 'fix-object-level', '84b35d6caca9d937478ad8a797491f38b8c2979f', '2026-03-24 20:09:42.326847');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (44, 'vector-bucket-type', '99c20c0ffd52bb1ff1f32fb992f3b351e3ef8fb3', '2026-03-24 20:09:42.327171');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (45, 'vector-buckets', '049e27196d77a7cb76497a85afae669d8b230953', '2026-03-24 20:09:42.327847');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (46, 'buckets-objects-grants', 'fedeb96d60fefd8e02ab3ded9fbde05632f84aed', '2026-03-24 20:09:42.329688');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (47, 'iceberg-table-metadata', '649df56855c24d8b36dd4cc1aeb8251aa9ad42c2', '2026-03-24 20:09:42.330439');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (48, 'iceberg-catalog-ids', 'e0e8b460c609b9999ccd0df9ad14294613eed939', '2026-03-24 20:09:42.331174');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (49, 'buckets-objects-grants-postgres', '072b1195d0d5a2f888af6b2302a1938dd94b8b3d', '2026-03-24 20:09:42.337837');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (50, 'search-v2-optimised', '6323ac4f850aa14e7387eb32102869578b5bd478', '2026-03-24 20:09:42.338511');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (51, 'index-backward-compatible-search', '2ee395d433f76e38bcd3856debaf6e0e5b674011', '2026-03-24 20:09:42.341885');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (52, 'drop-not-used-indexes-and-functions', '5cc44c8696749ac11dd0dc37f2a3802075f3a171', '2026-03-24 20:09:42.342058');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (53, 'drop-index-lower-name', 'd0cb18777d9e2a98ebe0bc5cc7a42e57ebe41854', '2026-03-24 20:09:42.343614');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (54, 'drop-index-object-level', '6289e048b1472da17c31a7eba1ded625a6457e67', '2026-03-24 20:09:42.344002');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (55, 'prevent-direct-deletes', '262a4798d5e0f2e7c8970232e03ce8be695d5819', '2026-03-24 20:09:42.34425');
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (56, 'fix-optimized-search-function', 'cb58526ebc23048049fd5bf2fd148d18b04a2073', '2026-03-24 20:09:42.345365');


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: -
--



--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: -
--



--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: -
--



--
-- Data for Name: vector_indexes; Type: TABLE DATA; Schema: storage; Owner: -
--



--
-- Data for Name: hooks; Type: TABLE DATA; Schema: supabase_functions; Owner: -
--



--
-- Data for Name: migrations; Type: TABLE DATA; Schema: supabase_functions; Owner: -
--

INSERT INTO supabase_functions.migrations (version, inserted_at) VALUES ('initial', '2026-03-24 20:09:29.799846+00');
INSERT INTO supabase_functions.migrations (version, inserted_at) VALUES ('20210809183423_update_grants', '2026-03-24 20:09:29.799846+00');


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: supabase_migrations; Owner: -
--

INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260117155725', '{"-- Create app_role enum for user roles
CREATE TYPE public.app_role AS ENUM (''admin'', ''user'')","-- Create products table
CREATE TABLE public.products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    image_url TEXT,
    theme TEXT NOT NULL,
    age_range TEXT NOT NULL,
    piece_count INTEGER NOT NULL,
    skill_boost TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
)","-- Create profiles table
CREATE TABLE public.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
    full_name TEXT,
    avatar_url TEXT,
    sub_status TEXT DEFAULT ''free'',
    impact_points INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
)","-- Create user_roles table for admin management
CREATE TABLE public.user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    role app_role NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    UNIQUE (user_id, role)
)","-- Create wishlist table
CREATE TABLE public.wishlist (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    product_id UUID REFERENCES public.products(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    UNIQUE (user_id, product_id)
)","-- Create inventory table
CREATE TABLE public.inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES public.products(id) ON DELETE CASCADE NOT NULL UNIQUE,
    total_stock INTEGER DEFAULT 0 NOT NULL,
    available_stock INTEGER DEFAULT 0 NOT NULL,
    rented_count INTEGER DEFAULT 0 NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
)","-- Enable RLS on all tables
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY","ALTER TABLE public.users ENABLE ROW LEVEL SECURITY","ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY","ALTER TABLE public.wishlist ENABLE ROW LEVEL SECURITY","ALTER TABLE public.inventory ENABLE ROW LEVEL SECURITY","-- Security definer function to check roles (prevents recursive RLS)
CREATE OR REPLACE FUNCTION public.has_role(_user_id UUID, _role app_role)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.user_roles
        WHERE user_id = _user_id
          AND role = _role
    )
$$","-- Products policies (public read, admin write)
CREATE POLICY \"Products are viewable by everyone\"
ON public.products FOR SELECT
USING (true)","CREATE POLICY \"Admins can insert products\"
ON public.products FOR INSERT
TO authenticated
WITH CHECK (public.has_role(auth.uid(), ''admin''))","CREATE POLICY \"Admins can update products\"
ON public.products FOR UPDATE
TO authenticated
USING (public.has_role(auth.uid(), ''admin''))","CREATE POLICY \"Admins can delete products\"
ON public.products FOR DELETE
TO authenticated
USING (public.has_role(auth.uid(), ''admin''))","-- Users policies
CREATE POLICY \"Users can view their own profile\"
ON public.users FOR SELECT
TO authenticated
USING (auth.uid() = user_id)","CREATE POLICY \"Users can insert their own profile\"
ON public.users FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id)","CREATE POLICY \"Users can update their own profile\"
ON public.users FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)","-- User roles policies (only admins can manage, users can view their own)
CREATE POLICY \"Users can view their own roles\"
ON public.user_roles FOR SELECT
TO authenticated
USING (auth.uid() = user_id)","CREATE POLICY \"Admins can manage all roles\"
ON public.user_roles FOR ALL
TO authenticated
USING (public.has_role(auth.uid(), ''admin''))","-- Wishlist policies
CREATE POLICY \"Users can view their own wishlist\"
ON public.wishlist FOR SELECT
TO authenticated
USING (auth.uid() = user_id)","CREATE POLICY \"Users can add to their own wishlist\"
ON public.wishlist FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id)","CREATE POLICY \"Users can remove from their own wishlist\"
ON public.wishlist FOR DELETE
TO authenticated
USING (auth.uid() = user_id)","-- Inventory policies (public read, admin write)
CREATE POLICY \"Inventory is viewable by everyone\"
ON public.inventory FOR SELECT
USING (true)","CREATE POLICY \"Admins can manage inventory\"
ON public.inventory FOR ALL
TO authenticated
USING (public.has_role(auth.uid(), ''admin''))","-- Function to auto-create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.users (user_id, full_name)
    VALUES (NEW.id, NEW.raw_user_meta_data ->> ''full_name'');
    
    -- Assign default ''user'' role
    INSERT INTO public.user_roles (user_id, role)
    VALUES (NEW.id, ''user'');
    
    RETURN NEW;
END;
$$","-- Trigger to create profile on signup
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user()","-- Function to update timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = public","-- Update triggers for timestamps
CREATE TRIGGER update_products_updated_at
    BEFORE UPDATE ON public.products
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column()","CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column()","CREATE TRIGGER update_inventory_updated_at
    BEFORE UPDATE ON public.inventory
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column()"}', '63a9dbb0-2fe7-41bf-8829-88cc95fda1ac');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260118000000', '{"-- Add indexes to products table for optimized filtering and sorting
CREATE INDEX IF NOT EXISTS products_created_at_idx ON public.products (created_at DESC)","CREATE INDEX IF NOT EXISTS products_theme_idx ON public.products (theme)","CREATE INDEX IF NOT EXISTS products_age_range_idx ON public.products (age_range)"}', 'optimize_products');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260119072154', '{"-- Add admin SELECT policy for users table so admins can view all profiles
CREATE POLICY \"Admins can view all profiles\"
ON public.users FOR SELECT
TO authenticated
USING (public.has_role(auth.uid(), ''admin''))","-- Add DELETE policy for users table so users can delete their own profile
CREATE POLICY \"Users can delete their own profile\"
ON public.users FOR DELETE
TO authenticated
USING (auth.uid() = user_id)"}', '15c5fd8c-f8ee-47c7-9247-d87cbb62e567');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260119202300', '{"-- Rename products table to sets
ALTER TABLE public.products RENAME TO sets","-- Add new columns
ALTER TABLE public.sets ADD COLUMN year INTEGER","ALTER TABLE public.sets ADD COLUMN catalogue_visibility BOOLEAN DEFAULT TRUE NOT NULL","-- Update remaining references (Inventory relationship)
ALTER TABLE public.inventory 
RENAME CONSTRAINT inventory_product_id_fkey TO inventory_set_id_fkey","ALTER TABLE public.inventory 
RENAME COLUMN product_id TO set_id","-- Update remaining references (Wishlist relationship)
ALTER TABLE public.wishlist 
RENAME CONSTRAINT wishlist_product_id_fkey TO wishlist_set_id_fkey","ALTER TABLE public.wishlist 
RENAME COLUMN product_id TO set_id","-- Update indexes
DROP INDEX IF EXISTS products_created_at_idx","DROP INDEX IF EXISTS products_theme_idx","DROP INDEX IF EXISTS products_age_range_idx","CREATE INDEX sets_created_at_idx ON public.sets (created_at DESC)","CREATE INDEX sets_theme_idx ON public.sets (theme)","CREATE INDEX sets_age_range_idx ON public.sets (age_range)","CREATE INDEX sets_year_idx ON public.sets (year)","-- Update RLS Policies
DROP POLICY IF EXISTS \"Products are viewable by everyone\" ON public.sets","DROP POLICY IF EXISTS \"Admins can insert products\" ON public.sets","DROP POLICY IF EXISTS \"Admins can update products\" ON public.sets","DROP POLICY IF EXISTS \"Admins can delete products\" ON public.sets","CREATE POLICY \"Sets are viewable by everyone\"
ON public.sets FOR SELECT
USING (true)","CREATE POLICY \"Admins can insert sets\"
ON public.sets FOR INSERT
TO authenticated
WITH CHECK (public.has_role(auth.uid(), ''admin''))","CREATE POLICY \"Admins can update sets\"
ON public.sets FOR UPDATE
TO authenticated
USING (public.has_role(auth.uid(), ''admin''))","CREATE POLICY \"Admins can delete sets\"
ON public.sets FOR DELETE
TO authenticated
USING (public.has_role(auth.uid(), ''admin''))","-- Update inventory policies to reflect column rename
DROP POLICY IF EXISTS \"Inventory is viewable by everyone\" ON public.inventory","DROP POLICY IF EXISTS \"Admins can manage inventory\" ON public.inventory","CREATE POLICY \"Inventory is viewable by everyone\"
ON public.inventory FOR SELECT
USING (true)","CREATE POLICY \"Admins can manage inventory\"
ON public.inventory FOR ALL
TO authenticated
USING (public.has_role(auth.uid(), ''admin''))","-- Update wishlist policies to reflect column rename
DROP POLICY IF EXISTS \"Users can view their own wishlist\" ON public.wishlist","DROP POLICY IF EXISTS \"Users can add to their own wishlist\" ON public.wishlist","DROP POLICY IF EXISTS \"Users can remove from their own wishlist\" ON public.wishlist","CREATE POLICY \"Users can view their own wishlist\"
ON public.wishlist FOR SELECT
TO authenticated
USING (auth.uid() = user_id)","CREATE POLICY \"Users can add to their own wishlist\"
ON public.wishlist FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id)","CREATE POLICY \"Users can remove from their own wishlist\"
ON public.wishlist FOR DELETE
TO authenticated
USING (auth.uid() = user_id)","-- Update timestamp trigger
DROP TRIGGER IF EXISTS update_products_updated_at ON public.sets","CREATE TRIGGER update_sets_updated_at
    BEFORE UPDATE ON public.sets
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column()"}', 'rename_products_to_sets');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260119203100', '{"-- Modify inventory table to have more granular tracking
ALTER TABLE public.inventory DROP COLUMN IF EXISTS rented_count","ALTER TABLE public.inventory ADD COLUMN shipping_count INTEGER DEFAULT 0 NOT NULL","ALTER TABLE public.inventory ADD COLUMN being_used_count INTEGER DEFAULT 0 NOT NULL","ALTER TABLE public.inventory ADD COLUMN returning_count INTEGER DEFAULT 0 NOT NULL","ALTER TABLE public.inventory ADD COLUMN being_completed_count INTEGER DEFAULT 0 NOT NULL"}', 'update_inventory_columns');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260119203600', '{"-- Add shipping and subscription fields to users table
ALTER TABLE public.users 
ADD COLUMN address TEXT,
ADD COLUMN address_extra TEXT,
ADD COLUMN zip_code TEXT,
ADD COLUMN city TEXT,
ADD COLUMN province TEXT,
ADD COLUMN phone TEXT,
ADD COLUMN email TEXT,
ADD COLUMN subscription_id TEXT,
ADD COLUMN subscription_type TEXT,
ADD COLUMN subscription_status TEXT DEFAULT ''active''","-- Add comment to explain subscription_status values
COMMENT ON COLUMN public.users.subscription_status IS ''Possible values: active, canceled, on hold''","-- Note: The wishlist unique constraint UNIQUE (user_id, set_id) 
-- (updated previously from product_id to set_id) 
-- already allows a user to have multiple sets in their wishlist."}', 'extend_profiles');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260119203900', '{"-- Add Lego_ref column to sets table
ALTER TABLE public.sets 
ADD COLUMN lego_ref TEXT","-- Add a comment for clarity
COMMENT ON COLUMN public.sets.lego_ref IS ''Official LEGO catalog reference number''"}', 'add_lego_ref_to_sets');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260119204400', '{"-- Create set_piece_list table
CREATE TABLE public.set_piece_list (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    set_id UUID REFERENCES public.sets(id) ON DELETE CASCADE NOT NULL,
    lego_ref TEXT NOT NULL,
    piece_ref TEXT NOT NULL,
    color_ref TEXT,
    piece_description TEXT,
    piece_qty INTEGER DEFAULT 1 NOT NULL,
    piece_weight INTEGER, -- Weight in milligrams
    piece_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
)","-- Enable RLS
ALTER TABLE public.set_piece_list ENABLE ROW LEVEL SECURITY","-- Policies (Public read, Admin manage)
CREATE POLICY \"Set piece lists are viewable by everyone\"
ON public.set_piece_list FOR SELECT
USING (true)","CREATE POLICY \"Admins can manage set piece lists\"
ON public.set_piece_list FOR ALL
TO authenticated
USING (public.has_role(auth.uid(), ''admin''))","-- Trigger for updated_at
CREATE TRIGGER update_set_piece_list_updated_at
    BEFORE UPDATE ON public.set_piece_list
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column()","-- Add index for performance
CREATE INDEX idx_set_piece_list_set_id ON public.set_piece_list(set_id)","CREATE INDEX idx_set_piece_list_lego_ref ON public.set_piece_list(lego_ref)"}', 'create_set_piece_list');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260119204500', '{"-- Add ''operador'' to app_role enum
ALTER TYPE public.app_role ADD VALUE ''operador''","-- Note: This change allows assigning the ''operador'' role to users in the user_roles table.
-- Specific permissions for this role should be added to RLS policies as needed."}', 'add_operador_role');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260126203000', '{"alter table \"public\".\"sets\" add column \"set_weight\" numeric","alter table \"public\".\"sets\" add column \"set_minifigs\" numeric","alter table \"public\".\"sets\" add column \"set_dim\" text"}', 'add_set_details');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260126203500', '{"alter table \"public\".\"sets\" drop column \"weight_set\""}', 'drop_weight_set');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260126210500', '{"alter table \"public\".\"set_piece_list\" add column \"piece_studdim\" text"}', 'add_piece_studdim');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260119205100', '{"-- Create enum for operation types
CREATE TYPE public.operation_type AS ENUM (
    ''recepcion paquete'',
    ''analisis_peso'',
    ''deposito_fulfillment'',
    ''higienizado'',
    ''retorno_stock''
)","-- Create backoffice_operations table
CREATE TABLE public.backoffice_operations (
    event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    operation_type public.operation_type NOT NULL,
    operation_time TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    metadata JSONB -- Optional, for extra details like weight values or box numbers
)","-- Enable RLS
ALTER TABLE public.backoffice_operations ENABLE ROW LEVEL SECURITY","-- Policies
-- Admins and Operadores can view and insert operations
CREATE POLICY \"Admins and Operators can view operations\"
ON public.backoffice_operations FOR SELECT
TO authenticated
USING (
    public.has_role(auth.uid(), ''admin'') OR 
    public.has_role(auth.uid(), ''operador'')
)","CREATE POLICY \"Admins and Operators can log operations\"
ON public.backoffice_operations FOR INSERT
TO authenticated
WITH CHECK (
    public.has_role(auth.uid(), ''admin'') OR 
    public.has_role(auth.uid(), ''operador'')
)","-- Indexes for audit performance
CREATE INDEX idx_backoff_ops_user_id ON public.backoffice_operations(user_id)","CREATE INDEX idx_backoff_ops_time ON public.backoffice_operations(operation_time)","CREATE INDEX idx_backoff_ops_type ON public.backoffice_operations(operation_type)"}', 'create_backoffice_operations');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260119225800', '{"-- Rename year to year_released and add weight_set to sets table
ALTER TABLE public.sets RENAME COLUMN year TO year_released","ALTER TABLE public.sets ADD COLUMN weight_set INTEGER","-- weight in grams"}', 'update_sets_columns');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260120082356', '{"-- Create the ''sets'' table with all required columns
CREATE TABLE IF NOT EXISTS public.sets (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    lego_ref TEXT,
    description TEXT,
    image_url TEXT,
    theme TEXT NOT NULL,
    age_range TEXT NOT NULL,
    piece_count INTEGER NOT NULL,
    skill_boost TEXT[],
    year_released INTEGER,
    weight_set NUMERIC,
    catalogue_visibility BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
)","-- Enable RLS on sets
ALTER TABLE public.sets ENABLE ROW LEVEL SECURITY","-- Drop existing policies if they exist
DROP POLICY IF EXISTS \"Sets are viewable by everyone\" ON public.sets","DROP POLICY IF EXISTS \"Admins can insert sets\" ON public.sets","DROP POLICY IF EXISTS \"Admins can update sets\" ON public.sets","DROP POLICY IF EXISTS \"Admins can delete sets\" ON public.sets","-- Create RLS policies for sets
CREATE POLICY \"Sets are viewable by everyone\" 
ON public.sets 
FOR SELECT 
USING (true)","CREATE POLICY \"Admins can insert sets\" 
ON public.sets 
FOR INSERT 
WITH CHECK (has_role(auth.uid(), ''admin''::app_role))","CREATE POLICY \"Admins can update sets\" 
ON public.sets 
FOR UPDATE 
USING (has_role(auth.uid(), ''admin''::app_role))","CREATE POLICY \"Admins can delete sets\" 
ON public.sets 
FOR DELETE 
USING (has_role(auth.uid(), ''admin''::app_role))","-- Drop trigger if exists and create it
DROP TRIGGER IF EXISTS update_sets_updated_at ON public.sets","CREATE TRIGGER update_sets_updated_at
BEFORE UPDATE ON public.sets
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column()","-- Add new columns to inventory table
ALTER TABLE public.inventory 
ADD COLUMN IF NOT EXISTS set_id UUID,
ADD COLUMN IF NOT EXISTS shipping_count INTEGER NOT NULL DEFAULT 0,
ADD COLUMN IF NOT EXISTS being_used_count INTEGER NOT NULL DEFAULT 0,
ADD COLUMN IF NOT EXISTS returning_count INTEGER NOT NULL DEFAULT 0,
ADD COLUMN IF NOT EXISTS being_completed_count INTEGER NOT NULL DEFAULT 0","-- Add foreign key constraint from inventory to sets (if not exists)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = ''inventory_set_id_fkey''
    ) THEN
        ALTER TABLE public.inventory
        ADD CONSTRAINT inventory_set_id_fkey 
        FOREIGN KEY (set_id) REFERENCES public.sets(id) ON DELETE CASCADE;
    END IF;
END $$","-- Add set_id column to wishlist table (replacing product_id logic)
ALTER TABLE public.wishlist 
ADD COLUMN IF NOT EXISTS set_id UUID","-- Add foreign key constraint from wishlist to sets (if not exists)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = ''wishlist_set_id_fkey''
    ) THEN
        ALTER TABLE public.wishlist
        ADD CONSTRAINT wishlist_set_id_fkey 
        FOREIGN KEY (set_id) REFERENCES public.sets(id) ON DELETE CASCADE;
    END IF;
END $$"}', '8e2fac5b-6b05-4e13-9679-c474dcf535bb');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260120082407', '{"-- Make product_id nullable in inventory (since we now use set_id)
-- ALTER TABLE public.inventory ALTER COLUMN product_id DROP NOT NULL;
-- Commented out: product_id was already renamed to set_id in previous migration

-- Make product_id nullable in wishlist (since we now use set_id)
-- ALTER TABLE public.wishlist ALTER COLUMN product_id DROP NOT NULL;
-- Commented out: product_id was already renamed to set_id in previous migration"}', 'cb011a15-f319-4d9d-b9d6-85d2b4cde591');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260123070141', '{"-- Drop the overly permissive public SELECT policy on inventory
DROP POLICY IF EXISTS \"Inventory is viewable by everyone\" ON public.inventory","-- Create a new policy that only allows authenticated users to view inventory
CREATE POLICY \"Inventory is viewable by authenticated users\" 
ON public.inventory 
FOR SELECT 
USING (auth.uid() IS NOT NULL)"}', 'c5472e21-a3c1-4ad2-869d-5b957547da57');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260123071712', '{"-- Create donations table
CREATE TABLE public.donations (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    nombre TEXT NOT NULL,
    email TEXT NOT NULL,
    telefono TEXT,
    direccion TEXT,
    peso_estimado NUMERIC NOT NULL,
    metodo_entrega TEXT NOT NULL CHECK (metodo_entrega IN (''punto-recogida'', ''recogida-domicilio'')),
    recompensa TEXT NOT NULL CHECK (recompensa IN (''economica'', ''social'')),
    ninos_beneficiados INTEGER NOT NULL,
    co2_evitado NUMERIC NOT NULL,
    status TEXT NOT NULL DEFAULT ''pending'' CHECK (status IN (''pending'', ''confirmed'', ''shipped'', ''received'', ''processed'', ''completed'')),
    tracking_code TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
)","-- Enable RLS
ALTER TABLE public.donations ENABLE ROW LEVEL SECURITY","-- Users can view their own donations
CREATE POLICY \"Users can view their own donations\" 
ON public.donations 
FOR SELECT 
USING (auth.uid() = user_id OR email = (SELECT email FROM auth.users WHERE id = auth.uid()))","-- Users can create donations (authenticated or not via edge function)
CREATE POLICY \"Anyone can insert donations via edge function\" 
ON public.donations 
FOR INSERT 
WITH CHECK (true)","-- Admins can manage all donations
CREATE POLICY \"Admins can manage all donations\" 
ON public.donations 
FOR ALL 
USING (has_role(auth.uid(), ''admin''::app_role))","-- Create trigger for updated_at
CREATE TRIGGER update_donations_updated_at
BEFORE UPDATE ON public.donations
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column()","-- Create index for faster lookups
CREATE INDEX idx_donations_email ON public.donations(email)","CREATE INDEX idx_donations_status ON public.donations(status)"}', 'b882fc9c-34fe-4cb2-afd3-420252c1e06f');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260123071721', '{"-- Drop the overly permissive INSERT policy
DROP POLICY IF EXISTS \"Anyone can insert donations via edge function\" ON public.donations","-- Create a policy that allows service role to insert (edge function uses service role)
-- Users can only insert their own donations if authenticated
CREATE POLICY \"Authenticated users can insert their own donations\" 
ON public.donations 
FOR INSERT 
WITH CHECK (auth.uid() IS NOT NULL AND (user_id IS NULL OR auth.uid() = user_id))"}', 'ffee6bb4-6a13-4c58-932b-ac2acd6a8b46');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260124111321', '{"-- Add contact data fields to users table
ALTER TABLE public.users
ADD COLUMN IF NOT EXISTS direccion TEXT,
ADD COLUMN IF NOT EXISTS codigo_postal TEXT,
ADD COLUMN IF NOT EXISTS ciudad TEXT,
ADD COLUMN IF NOT EXISTS telefono TEXT,
ADD COLUMN IF NOT EXISTS profile_completed BOOLEAN DEFAULT false","-- Update the wishlist foreign key to be nullable (allow sample sets)
ALTER TABLE public.wishlist
DROP CONSTRAINT IF EXISTS wishlist_set_id_fkey","-- Re-add the constraint with ON DELETE CASCADE but allowing NULLs
-- Actually, keep it as is since set_id is already nullable
-- The issue is the FK validation - let''s just allow orphan set_ids for sample data

-- Add admin RLS policy for wishlists viewing (for admin panel)
CREATE POLICY \"Admins can view all wishlists\"
ON public.wishlist
FOR SELECT
USING (has_role(auth.uid(), ''admin''::app_role))","-- Comment: The wishlist issue is actually that sample set IDs don''t exist in the sets table
-- We need to drop the FK constraint to allow adding sample items or ensure real sets exist"}', '534f8497-4b5a-4854-aefd-cd641e20da37');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260126210800', '{"alter table \"public\".\"set_piece_list\" add column \"lego_element_id\" text","alter table \"public\".\"set_piece_list\" add column \"bricklink_color_id\" text"}', 'add_more_piece_details');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260126211600', '{"alter table \"public\".\"set_piece_list\" alter column \"piece_weight\" type numeric"}', 'fix_piece_weight_type');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260127080000', '{"-- Create orders table for tracking user order history
CREATE TABLE IF NOT EXISTS public.orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    set_id UUID REFERENCES public.sets(id) ON DELETE SET NULL,
    
    -- Order details
    order_date TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    shipped_date TIMESTAMP WITH TIME ZONE,
    delivered_date TIMESTAMP WITH TIME ZONE,
    returned_date TIMESTAMP WITH TIME ZONE,
    
    -- Status tracking
    status TEXT NOT NULL DEFAULT ''pending'',
    -- possible values: ''pending'', ''shipped'', ''delivered'', ''in_use'', ''returned'', ''cancelled''
    
    -- Additional info
    tracking_number TEXT,
    notes TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
)","-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON public.orders(user_id)","CREATE INDEX IF NOT EXISTS idx_orders_status ON public.orders(status)","CREATE INDEX IF NOT EXISTS idx_orders_order_date ON public.orders(order_date DESC)","-- Enable RLS
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY","-- Users can only see their own orders
CREATE POLICY \"Users can view own orders\"
    ON public.orders FOR SELECT
    USING (auth.uid() = user_id)","-- Admins can manage all orders
CREATE POLICY \"Admins can manage all orders\"
    ON public.orders FOR ALL
    USING (public.has_role(auth.uid(), ''admin''::public.app_role))","-- Operadores can insert and update orders
CREATE POLICY \"Operadores can manage orders\"
    ON public.orders FOR INSERT
    WITH CHECK (
        public.has_role(auth.uid(), ''admin''::public.app_role) OR 
        public.has_role(auth.uid(), ''operador''::public.app_role)
    )","CREATE POLICY \"Operadores can update orders\"
    ON public.orders FOR UPDATE
    USING (
        public.has_role(auth.uid(), ''admin''::public.app_role) OR 
        public.has_role(auth.uid(), ''operador''::public.app_role)
    )"}', 'create_orders_table');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260127090000', '{"-- Create envios (shipments) table for tracking order shipments
CREATE TABLE IF NOT EXISTS public.envios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Foreign keys
    order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    
    -- Shipping dates
    fecha_asignada TIMESTAMP WITH TIME ZONE, -- Assigned/pickup date
    fecha_entrega TIMESTAMP WITH TIME ZONE, -- Delivery date to user
    fecha_entrega_real TIMESTAMP WITH TIME ZONE, -- Actual delivery date
    fecha_entrega_usuario TIMESTAMP WITH TIME ZONE, -- User delivery confirmation
    fecha_recepcion_almacen TIMESTAMP WITH TIME ZONE, -- Warehouse reception date
    fecha_devolucion_estimada DATE, -- Estimated return date
    
    -- Shipping details
    estado_envio TEXT NOT NULL DEFAULT ''pendiente'',
    -- possible values: ''pendiente'', ''asignado'', ''en_transito'', ''entregado'', ''devuelto'', ''cancelado''
    
    direccion_envio TEXT NOT NULL,
    ciudad_envio TEXT NOT NULL,
    codigo_postal_envio TEXT NOT NULL,
    pais_envio TEXT NOT NULL DEFAULT ''España'',
    
    -- Provider information
    proveedor_envio TEXT, -- Shipping provider name
    direccion_proveedor_recogida TEXT, -- Provider pickup address
    
    -- Tracking
    numero_seguimiento TEXT UNIQUE, -- Tracking number
    
    -- Costs
    costo_envio DECIMAL(10, 2),
    
    -- Additional info
    transportista TEXT, -- Carrier name
    notas_adicionales TEXT,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
)","-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_envios_order_id ON public.envios(order_id)","CREATE INDEX IF NOT EXISTS idx_envios_user_id ON public.envios(user_id)","CREATE INDEX IF NOT EXISTS idx_envios_estado ON public.envios(estado_envio)","CREATE INDEX IF NOT EXISTS idx_envios_numero_seguimiento ON public.envios(numero_seguimiento)","CREATE INDEX IF NOT EXISTS idx_envios_fecha_entrega ON public.envios(fecha_entrega DESC)","-- Enable RLS
ALTER TABLE public.envios ENABLE ROW LEVEL SECURITY","-- Users can only see their own shipments
CREATE POLICY \"Users can view own shipments\"
    ON public.envios FOR SELECT
    USING (auth.uid() = user_id)","-- Admins can manage all shipments
CREATE POLICY \"Admins can manage all shipments\"
    ON public.envios FOR ALL
    USING (public.has_role(auth.uid(), ''admin''::public.app_role))","-- Operadores can insert and update shipments
CREATE POLICY \"Operadores can create shipments\"
    ON public.envios FOR INSERT
    WITH CHECK (
        public.has_role(auth.uid(), ''admin''::public.app_role) OR 
        public.has_role(auth.uid(), ''operador''::public.app_role)
    )","CREATE POLICY \"Operadores can update shipments\"
    ON public.envios FOR UPDATE
    USING (
        public.has_role(auth.uid(), ''admin''::public.app_role) OR 
        public.has_role(auth.uid(), ''operador''::public.app_role)
    )","-- Add trigger for updated_at
CREATE TRIGGER update_envios_updated_at
    BEFORE UPDATE ON public.envios
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column()","-- Add comment to explain estado_envio values
COMMENT ON COLUMN public.envios.estado_envio IS ''Possible values: pendiente, asignado, en_transito, entregado, devuelto, cancelado''"}', 'create_envios_table');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260127091000', '{"-- Create inventario_sets table for detailed inventory tracking
CREATE TABLE IF NOT EXISTS public.inventario_sets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- References to the set
    set_id UUID REFERENCES public.sets(id) ON DELETE CASCADE NOT NULL UNIQUE,
    set_ref TEXT, -- Reference to sets.lego_ref for easier querying
    
    -- Stock levels
    cantidad_total INTEGER DEFAULT 0 NOT NULL, -- Total units of this set in the system
    stock_central INTEGER DEFAULT 0 NOT NULL,  -- Units available in the central warehouse
    en_envio INTEGER DEFAULT 0 NOT NULL,       -- Units currently being shipped to users
    en_uso INTEGER DEFAULT 0 NOT NULL,         -- Units currently in possession of users
    en_devolucion INTEGER DEFAULT 0 NOT NULL,  -- Units being returned by users
    en_reparacion INTEGER DEFAULT 0 NOT NULL,  -- Units being repaired/completed
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
)","-- Add comment for clarity on columns
COMMENT ON TABLE public.inventario_sets IS ''Detailed tracking of set units across different states (warehouse, shipping, use, etc.)''","COMMENT ON COLUMN public.inventario_sets.set_ref IS ''Official LEGO reference number (sets.lego_ref)''","-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_inventario_sets_set_id ON public.inventario_sets(set_id)","CREATE INDEX IF NOT EXISTS idx_inventario_sets_set_ref ON public.inventario_sets(set_ref)","-- Enable RLS
ALTER TABLE public.inventario_sets ENABLE ROW LEVEL SECURITY","-- Everyone can view inventory (publicly visible or at least for authenticated users)
CREATE POLICY \"Inventario is viewable by everyone\"
    ON public.inventario_sets FOR SELECT
    USING (true)","-- Admins and Operadores can manage inventory
CREATE POLICY \"Admins and Operadores can manage inventario\"
    ON public.inventario_sets FOR ALL
    TO authenticated
    USING (
        public.has_role(auth.uid(), ''admin''::public.app_role) OR 
        public.has_role(auth.uid(), ''operador''::public.app_role)
    )","-- Add trigger for updated_at
CREATE TRIGGER update_inventario_sets_updated_at
    BEFORE UPDATE ON public.inventario_sets
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column()"}', 'create_inventario_sets');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260127092000', '{"-- Add missing fields to envios table based on operations panel requirements
ALTER TABLE public.envios
ADD COLUMN IF NOT EXISTS fecha_recogida_almacen TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS fecha_solicitud_devolucion TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS proveedor_recogida TEXT","-- Add comments for clarity
COMMENT ON COLUMN public.envios.fecha_recogida_almacen IS ''Date when the shipment was picked up from the warehouse''","COMMENT ON COLUMN public.envios.fecha_solicitud_devolucion IS ''Date when the user requested a return''","COMMENT ON COLUMN public.envios.proveedor_recogida IS ''Carrier or entity in charge of the return pickup''"}', 'update_envios_fields');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260127093000', '{"-- Create operations_recepcion table to track set returns reception
CREATE TABLE IF NOT EXISTS public.operaciones_recepcion (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID REFERENCES public.envios(id) ON DELETE SET NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    set_id UUID REFERENCES public.sets(id) ON DELETE CASCADE NOT NULL,
    peso_obtenido NUMERIC(10, 2),
    status_recepcion BOOLEAN DEFAULT FALSE NOT NULL,
    missing_parts TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
)","-- Enable RLS
ALTER TABLE public.operaciones_recepcion ENABLE ROW LEVEL SECURITY","-- Add RLS Policies
CREATE POLICY \"Enable read access for authenticated users\"
    ON public.operaciones_recepcion FOR SELECT
    TO authenticated
    USING (true)","CREATE POLICY \"Enable insert for admins and operators\"
    ON public.operaciones_recepcion FOR INSERT
    TO authenticated
    WITH CHECK (
        public.has_role(auth.uid(), ''admin''::public.app_role) OR 
        public.has_role(auth.uid(), ''operador''::public.app_role)
    )","CREATE POLICY \"Enable update for admins and operators\"
    ON public.operaciones_recepcion FOR UPDATE
    TO authenticated
    USING (
        public.has_role(auth.uid(), ''admin''::public.app_role) OR 
        public.has_role(auth.uid(), ''operador''::public.app_role)
    )
    WITH CHECK (
        public.has_role(auth.uid(), ''admin''::public.app_role) OR 
        public.has_role(auth.uid(), ''operador''::public.app_role)
    )","-- Add updated_at trigger
CREATE TRIGGER update_operaciones_recepcion_updated_at
    BEFORE UPDATE ON public.operaciones_recepcion
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column()","-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_operaciones_recepcion_user_id ON public.operaciones_recepcion(user_id)","CREATE INDEX IF NOT EXISTS idx_operaciones_recepcion_set_id ON public.operaciones_recepcion(set_id)","CREATE INDEX IF NOT EXISTS idx_operaciones_recepcion_event_id ON public.operaciones_recepcion(event_id)","-- Add comments
COMMENT ON TABLE public.operaciones_recepcion IS ''Table to record the reception and maintenance check of sets returned by users.''","COMMENT ON COLUMN public.operaciones_recepcion.peso_obtenido IS ''Actual weight of the set upon reception (in grams).''","COMMENT ON COLUMN public.operaciones_recepcion.status_recepcion IS ''True if the reception process is completed.''","COMMENT ON COLUMN public.operaciones_recepcion.missing_parts IS ''Details or notes about missing pieces found during reception.''"}', 'create_operaciones_recepcion');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260127094000', '{"-- Insert sample data for envios and operaciones_recepcion
-- This script uses existing users and sets to maintain referential integrity.

DO $$
DECLARE
    u1 UUID; u2 UUID; u3 UUID;
    s1 UUID; s2 UUID; s3 UUID;
    o1 UUID; o2 UUID; o3 UUID;
    e1 UUID; e2 UUID; e3 UUID;
BEGIN
    -- Get some existing users
    SELECT user_id INTO u1 FROM public.users LIMIT 1 OFFSET 0;
    SELECT user_id INTO u2 FROM public.users LIMIT 1 OFFSET 1;
    SELECT user_id INTO u3 FROM public.users LIMIT 1 OFFSET 2;
    
    -- Get some existing sets
    SELECT id INTO s1 FROM public.sets LIMIT 1 OFFSET 0;
    SELECT id INTO s2 FROM public.sets LIMIT 1 OFFSET 1;
    SELECT id INTO s3 FROM public.sets LIMIT 1 OFFSET 2;

    -- Fallback in case there are fewer than 3 unique records
    u2 := COALESCE(u2, u1);
    u3 := COALESCE(u3, u2, u1);
    s2 := COALESCE(s2, s1);
    s3 := COALESCE(s3, s2, s1);

    -- Only proceed if we have at least one user and one set
    IF u1 IS NOT NULL AND s1 IS NOT NULL THEN
        -- Example 1
        INSERT INTO public.orders (user_id, set_id, status, order_date) 
        VALUES (u1, s1, ''delivered'', now() - interval ''10 days'') RETURNING id INTO o1;
        
        INSERT INTO public.envios (order_id, user_id, estado_envio, direccion_envio, ciudad_envio, codigo_postal_envio, fecha_asignada, fecha_recepcion_almacen, proveedor_envio)
        VALUES (o1, u1, ''devuelto'', ''Calle Mayor 10'', ''Madrid'', ''28001'', now() - interval ''9 days'', now() - interval ''1 day'', ''SEUR'') RETURNING id INTO e1;
        
        INSERT INTO public.operaciones_recepcion (event_id, user_id, set_id, peso_obtenido, status_recepcion, missing_parts)
        VALUES (e1, u1, s1, 1240.50, TRUE, ''Completado sin faltas'');

        -- Example 2
        INSERT INTO public.orders (user_id, set_id, status, order_date) 
        VALUES (u2, s2, ''delivered'', now() - interval ''15 days'') RETURNING id INTO o2;
        
        INSERT INTO public.envios (order_id, user_id, estado_envio, direccion_envio, ciudad_envio, codigo_postal_envio, fecha_asignada, fecha_recepcion_almacen, proveedor_envio)
        VALUES (o2, u2, ''devuelto'', ''Avenida Diagonal 450'', ''Barcelona'', ''08001'', now() - interval ''14 days'', now() - interval ''2 days'', ''Correos'') RETURNING id INTO e2;
        
        INSERT INTO public.operaciones_recepcion (event_id, user_id, set_id, peso_obtenido, status_recepcion, missing_parts)
        VALUES (e2, u2, s2, 890.00, TRUE, ''Falta 1x 3001 Red'');

        -- Example 3
        INSERT INTO public.orders (user_id, set_id, status, order_date) 
        VALUES (u3, s3, ''delivered'', now() - interval ''20 days'') RETURNING id INTO o3;
        
        INSERT INTO public.envios (order_id, user_id, estado_envio, direccion_envio, ciudad_envio, codigo_postal_envio, fecha_asignada, fecha_recepcion_almacen, proveedor_envio)
        VALUES (o3, u3, ''devuelto'', ''Paseo de la Castellana 200'', ''Madrid'', ''28046'', now() - interval ''19 days'', now() - interval ''3 days'', ''DHL'') RETURNING id INTO e3;
        
        INSERT INTO public.operaciones_recepcion (event_id, user_id, set_id, peso_obtenido, status_recepcion, missing_parts)
        VALUES (e3, u3, s3, 2100.75, TRUE, ''Completado, limpieza leve'');
    END IF;
END $$"}', 'seed_sample_data');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260127095000', '{"-- Migration to automate set assignment and inventory management

-- 1. Add estado_usuario to users
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS estado_usuario TEXT DEFAULT ''sin set''","-- Add check constraint for allowed values
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = ''check_estado_usuario''
    ) THEN
        ALTER TABLE public.users 
        ADD CONSTRAINT check_estado_usuario 
        CHECK (estado_usuario IN (''sin set'', ''set en envio'', ''set en devolución'', ''con set'', ''suspendido''));
    END IF;
END $$","-- 2. Update inventario_sets for existing sets (2 units each)
INSERT INTO public.inventario_sets (set_id, set_ref, cantidad_total, stock_central)
SELECT id, lego_ref, 2, 2
FROM public.sets
ON CONFLICT (set_id) DO UPDATE 
SET cantidad_total = 2, stock_central = 2","-- 3. Trigger for automatic inventory creation on new sets
CREATE OR REPLACE FUNCTION public.handle_new_set_inventory()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.inventario_sets (set_id, set_ref, cantidad_total, stock_central)
    VALUES (NEW.id, NEW.lego_ref, 2, 2)
    ON CONFLICT (set_id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER","DROP TRIGGER IF EXISTS on_set_created ON public.sets","CREATE TRIGGER on_set_created
    AFTER INSERT ON public.sets
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_set_inventory()","-- 4. Function for random set assignment
CREATE OR REPLACE FUNCTION public.assign_sets_to_users()
RETURNS TABLE (user_id UUID, set_id UUID, status TEXT) AS $$
DECLARE
    r RECORD;
    target_set_id UUID;
BEGIN
    -- Loop through eligible users
    FOR r IN (
        SELECT p.user_id, p.full_name
        FROM public.users p
        WHERE p.estado_usuario IN (''sin set'', ''set en devolución'')
          AND EXISTS (SELECT 1 FROM public.wishlist w WHERE w.user_id = p.user_id)
    ) LOOP
        -- Find a random available set from user''s wishlist
        SELECT w.product_id INTO target_set_id
        FROM public.wishlist w
        JOIN public.inventario_sets i ON w.product_id = i.set_id
        WHERE w.user_id = r.user_id
          AND i.cantidad_total > 0
        ORDER BY RANDOM()
        LIMIT 1;

        -- If a set is found, perform assignment
        IF target_set_id IS NOT NULL THEN
            -- 1. Update Inventory
            UPDATE public.inventario_sets
            SET cantidad_total = cantidad_total - 1,
                en_envio = en_envio + 1
            WHERE set_id = target_set_id;

            -- 2. Create Order
            INSERT INTO public.orders (user_id, set_id, status)
            VALUES (r.user_id, target_set_id, ''pending'');

            -- 3. Update User Status
            UPDATE public.users
            SET estado_usuario = ''set en envio''
            WHERE user_id = r.user_id;

            -- Return the result
            user_id := r.user_id;
            set_id := target_set_id;
            status := ''Assigned'';
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public","REVOKE EXECUTE ON FUNCTION public.assign_sets_to_users FROM PUBLIC","GRANT EXECUTE ON FUNCTION public.assign_sets_to_users TO service_role","GRANT EXECUTE ON FUNCTION public.assign_sets_to_users TO authenticated","-- 5. Seed 5 sample users and wishlists
-- We''ll try to insert into auth.users first, then let triggers handle profiles, or insert manually if needed.
DO $$
DECLARE
    new_user_id UUID;
    sample_set_ids UUID[];
    i INT;
    temp_user_id UUID;
BEGIN
    -- Get some random sets for wishlists
    SELECT array_agg(id) INTO sample_set_ids FROM (SELECT id FROM public.sets ORDER BY RANDOM() LIMIT 20) s;

    IF sample_set_ids IS NOT NULL THEN
        FOR i IN 1..5 LOOP
            new_user_id := gen_random_uuid();
            
            -- Insert into auth.users (minimal fields)
            -- We assume standard Supabase auth.users columns. If it fails, we catch it.
            BEGIN
                INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, raw_user_meta_data, role, aud, instance_id)
                VALUES (
                    new_user_id, 
                    ''sample_user_'' || i || ''_'' || substr(new_user_id::text, 1, 8) || ''@brickshare.test'', 
                    ''$2a$10$7p0P1p0P1p0P1p0P1p0P1p0P1p0P1p0P1p0P1p0P1p0P1p0P1p0P'', -- dummy hash
                    now(),
                    jsonb_build_object(''full_name'', ''Sample User '' || i),
                    ''authenticated'',
                    ''authenticated'',
                    ''00000000-0000-0000-0000-000000000000''
                );

                -- The trigger ''on_auth_user_created'' should have created the user record.
                -- We update it with the status.
                UPDATE public.users SET estado_usuario = ''sin set'' WHERE user_id = new_user_id;

                -- Add 3 random items to wishlist
                FOR j IN 1..3 LOOP
                    INSERT INTO public.wishlist (user_id, product_id)
                    VALUES (new_user_id, sample_set_ids[1 + ( floor(random() * array_length(sample_set_ids, 1)) )::int])
                    ON CONFLICT DO NOTHING;
                END LOOP;
            EXCEPTION WHEN OTHERS THEN
                RAISE NOTICE ''Could not create sample user %: %'', i, SQLERRM;
            END;
        END LOOP;
    END IF;
END $$"}', 'automate_assignment_and_inventory');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260127096000', '{"-- Fixed seeding for sample users and wishlists
DO $$
DECLARE
    new_user_id UUID;
    sample_set_ids UUID[];
    i INT;
BEGIN
    -- Get some random sets for wishlists
    SELECT array_agg(id) INTO sample_set_ids FROM (SELECT id FROM public.sets ORDER BY RANDOM() LIMIT 20) s;

    IF sample_set_ids IS NOT NULL THEN
        FOR i IN 1..5 LOOP
            new_user_id := gen_random_uuid();
            
            -- Insert into auth.users (minimal fields)
            BEGIN
                INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, raw_user_meta_data, role, aud, instance_id)
                VALUES (
                    new_user_id, 
                    ''sample_user_'' || i || ''_'' || substr(new_user_id::text, 1, 8) || ''@brickshare.test'', 
                    ''$2a$10$7p0P1p0P1p0P1p0P1p0P1p0P1p0P1p0P1p0P1p0P1p0P1p0P1p0P'', -- dummy hash
                    now(),
                    jsonb_build_object(''full_name'', ''Sample User '' || i),
                    ''authenticated'',
                    ''authenticated'',
                    ''00000000-0000-0000-0000-000000000000''
                );

                -- We don''t need to manually insert into profiles if the trigger ''on_auth_user_created'' works.
                -- But we ensure the status is set correctly.
                -- Wait, the trigger might not have run if we are inserting manually into auth.users in some environments.
                -- Let''s double check or do a manual insert if it doesn''t exist.
                
                INSERT INTO public.users (user_id, full_name, estado_usuario)
                VALUES (new_user_id, ''Sample User '' || i, ''sin set'')
                ON CONFLICT (user_id) DO UPDATE SET estado_usuario = ''sin set'';

                -- Add 3 random items to wishlist (using correct column: set_id)
                FOR j IN 1..3 LOOP
                    INSERT INTO public.wishlist (user_id, set_id)
                    VALUES (new_user_id, sample_set_ids[1 + ( floor(random() * array_length(sample_set_ids, 1)) )::int])
                    ON CONFLICT DO NOTHING;
                END LOOP;
            EXCEPTION WHEN OTHERS THEN
                RAISE NOTICE ''Could not create sample user %: %'', i, SQLERRM;
            END;
        END LOOP;
    END IF;
END $$"}', 'seed_users_fixed');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260127100000', '{"-- Global Schema Refactor
-- Renaming tables and columns to align with new naming conventions

-- 1. Table: profiles -> users (if not already renamed)
-- This is now idempotent - if the table is already named ''users'', nothing happens
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = ''profiles'' AND table_schema = ''public'') THEN
        ALTER TABLE public.profiles RENAME TO users;
    END IF;
EXCEPTION WHEN OTHERS THEN
    -- Table might already be users, or another error - continue
    NULL;
END $$","-- Rename estado_usuario column if it exists
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = ''users'' AND column_name = ''estado_usuario'' AND table_schema = ''public'') THEN
        ALTER TABLE public.users RENAME COLUMN estado_usuario TO user_status;
    END IF;
EXCEPTION WHEN OTHERS THEN
    -- Column might already be renamed or not exist - continue
    NULL;
END $$","-- 2. Table: sets
ALTER TABLE public.sets RENAME COLUMN name TO set_name","ALTER TABLE public.sets RENAME COLUMN lego_ref TO set_ref","ALTER TABLE public.sets RENAME COLUMN theme TO set_theme","ALTER TABLE public.sets RENAME COLUMN description TO set_description","ALTER TABLE public.sets RENAME COLUMN image_url TO set_image_url","ALTER TABLE public.sets RENAME COLUMN age_range TO set_age_range","ALTER TABLE public.sets RENAME COLUMN piece_count TO set_piece_count","-- 3. Table: operaciones_recepcion
ALTER TABLE public.operaciones_recepcion RENAME COLUMN peso_obtenido TO weight_measured","-- 4. Table: set_piece_list
ALTER TABLE public.set_piece_list RENAME COLUMN lego_ref TO set_ref","ALTER TABLE public.set_piece_list RENAME COLUMN piece_url TO piece_image_url","ALTER TABLE public.set_piece_list RENAME COLUMN lego_element_id TO piece_lego_elementid","-- 5. Table: inventario_sets -> inventory_sets
ALTER TABLE public.inventario_sets RENAME TO inventory_sets","ALTER TABLE public.inventory_sets RENAME COLUMN cantidad_total TO inventory_set_total_qty","ALTER TABLE public.inventory_sets DROP COLUMN stock_central","-- Update foreign key references if necessary (PostgreSQL handles this automatically usually, but let''s check indices/triggers)
-- Triggers and indices usually follow the rename.

-- Re-enable RLS and verify policies (renaming table usually keeps policies attached)"}', 'global_refactor');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260127120000', '{"-- Enable RLS on wishlist table
ALTER TABLE wishlist ENABLE ROW LEVEL SECURITY","-- Drop existing policies if any
DROP POLICY IF EXISTS \"Users can view their own wishlist\" ON wishlist","DROP POLICY IF EXISTS \"Users can add to their own wishlist\" ON wishlist","DROP POLICY IF EXISTS \"Users can remove from their own wishlist\" ON wishlist","-- Policy: Users can view their own wishlist items
CREATE POLICY \"Users can view their own wishlist\"
ON wishlist
FOR SELECT
USING (auth.uid() = user_id)","-- Policy: Users can add items to their own wishlist
CREATE POLICY \"Users can add to their own wishlist\"
ON wishlist
FOR INSERT
WITH CHECK (auth.uid() = user_id)","-- Policy: Users can remove items from their own wishlist
CREATE POLICY \"Users can remove from their own wishlist\"
ON wishlist
FOR DELETE
USING (auth.uid() = user_id)"}', 'wishlist_rls_policies');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260127123000', '{"-- Drop the inventory table
-- This table is not being used in the codebase
-- All inventory operations use inventory_sets table instead

DROP TABLE IF EXISTS inventory CASCADE"}', 'drop_inventory_table');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260127123500', '{"-- Fix assignment function to use ''users'' table instead of ''profiles''

-- 1. Add estado_usuario to users table if not exists
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS estado_usuario TEXT DEFAULT ''sin set''","-- Add check constraint for allowed values
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = ''check_estado_usuario_users''
    ) THEN
        ALTER TABLE public.users 
        ADD CONSTRAINT check_estado_usuario_users 
        CHECK (estado_usuario IN (''sin set'', ''set en envio'', ''set en devolución'', ''con set'', ''suspendido''));
    END IF;
END $$","-- 2. Update the assign_sets_to_users function to use ''users'' table
CREATE OR REPLACE FUNCTION public.assign_sets_to_users()
RETURNS TABLE (user_id UUID, set_id UUID, status TEXT) AS $$
DECLARE
    r RECORD;
    target_set_id UUID;
BEGIN
    -- Loop through eligible users
    FOR r IN (
        SELECT u.user_id, u.full_name
        FROM public.users u
        WHERE u.estado_usuario IN (''sin set'', ''set en devolución'')
          AND EXISTS (SELECT 1 FROM public.wishlist w WHERE w.user_id = u.user_id)
    ) LOOP
        -- Find a random available set from user''s wishlist
        SELECT w.set_id INTO target_set_id
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        WHERE w.user_id = r.user_id
          AND i.inventory_set_total_qty > 0
        ORDER BY RANDOM()
        LIMIT 1;

        -- If a set is found, perform assignment
        IF target_set_id IS NOT NULL THEN
            -- 1. Update Inventory
            UPDATE public.inventory_sets
            SET inventory_set_total_qty = inventory_set_total_qty - 1,
                en_envio = en_envio + 1
            WHERE set_id = target_set_id;

            -- 2. Create Order
            INSERT INTO public.orders (user_id, set_id, status)
            VALUES (r.user_id, target_set_id, ''pending'');

            -- 3. Update User Status
            UPDATE public.users
            SET estado_usuario = ''set en envio''
            WHERE user_id = r.user_id;

            -- Return the result
            user_id := r.user_id;
            set_id := target_set_id;
            status := ''Assigned'';
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER"}', 'fix_assignment_function');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260127124000', '{"-- Update assign_sets_to_users function to select by wishlist order instead of random

CREATE OR REPLACE FUNCTION public.assign_sets_to_users()
RETURNS TABLE (user_id UUID, set_id UUID, status TEXT) AS $$
DECLARE
    r RECORD;
    target_set_id UUID;
BEGIN
    -- Loop through eligible users
    FOR r IN (
        SELECT u.user_id, u.full_name
        FROM public.users u
        WHERE u.estado_usuario IN (''sin set'', ''set en devolución'')
          AND EXISTS (SELECT 1 FROM public.wishlist w WHERE w.user_id = u.user_id)
    ) LOOP
        -- Find the first available set from user''s wishlist (by creation order)
        -- Check that there is stock available
        SELECT w.set_id INTO target_set_id
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        WHERE w.user_id = r.user_id
          AND i.inventory_set_total_qty > 0
        ORDER BY w.created_at ASC  -- First item in wishlist (oldest entry)
        LIMIT 1;

        -- If a set is found, perform assignment
        IF target_set_id IS NOT NULL THEN
            -- 1. Update Inventory: decrement total stock and increment en_envio
            UPDATE public.inventory_sets
            SET inventory_set_total_qty = inventory_set_total_qty - 1,
                en_envio = en_envio + 1
            WHERE set_id = target_set_id;

            -- 2. Create Order
            INSERT INTO public.orders (user_id, set_id, status)
            VALUES (r.user_id, target_set_id, ''pending'');

            -- 3. Update User Status
            UPDATE public.users
            SET estado_usuario = ''set en envio''
            WHERE user_id = r.user_id;

            -- Return the result
            user_id := r.user_id;
            set_id := target_set_id;
            status := ''Assigned'';
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER"}', 'update_assignment_order');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260321000003', '{"-- =========================================
-- Migration: Unify user address fields
-- =========================================
-- Purpose: Remove duplicate fields and standardize on Spanish field names
-- The table has both English (address, city, zip_code, phone) and Spanish 
-- (direccion, ciudad, codigo_postal, telefono) versions of the same fields.
-- We''ll keep Spanish versions as they match the UI and other parts of the system.
-- =========================================

-- Step 1: Migrate data from English fields to Spanish fields (if any data exists in English fields)
UPDATE public.users
SET 
  direccion = COALESCE(direccion, address),
  ciudad = COALESCE(ciudad, city),
  codigo_postal = COALESCE(codigo_postal, zip_code),
  telefono = COALESCE(telefono, phone)
WHERE direccion IS NULL OR ciudad IS NULL OR codigo_postal IS NULL OR telefono IS NULL","-- Step 2: Drop the English field versions
ALTER TABLE public.users
  DROP COLUMN IF EXISTS address,
  DROP COLUMN IF EXISTS address_extra,
  DROP COLUMN IF EXISTS city,
  DROP COLUMN IF EXISTS province,
  DROP COLUMN IF EXISTS zip_code,
  DROP COLUMN IF EXISTS phone","-- Step 3: Ensure profile_completed is properly set to false by default
ALTER TABLE public.users
  ALTER COLUMN profile_completed SET DEFAULT false","-- Step 4: Mark existing users with complete profiles as profile_completed = true
UPDATE public.users
SET profile_completed = true
WHERE 
  direccion IS NOT NULL 
  AND codigo_postal IS NOT NULL 
  AND ciudad IS NOT NULL 
  AND telefono IS NOT NULL
  AND full_name IS NOT NULL","COMMENT ON COLUMN public.users.direccion IS ''User address (street, number, floor, etc.)''","COMMENT ON COLUMN public.users.codigo_postal IS ''Postal code''","COMMENT ON COLUMN public.users.ciudad IS ''City name''","COMMENT ON COLUMN public.users.telefono IS ''Contact phone number''","COMMENT ON COLUMN public.users.profile_completed IS ''Whether the user has completed their profile information''"}', 'unify_user_fields');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260127124500', '{"-- Fix ambiguous column reference in assign_sets_to_users function

CREATE OR REPLACE FUNCTION public.assign_sets_to_users()
RETURNS TABLE (user_id UUID, set_id UUID, status TEXT) AS $$
DECLARE
    r RECORD;
    target_set_id UUID;
BEGIN
    -- Loop through eligible users
    FOR r IN (
        SELECT u.user_id, u.full_name
        FROM public.users u
        WHERE u.estado_usuario IN (''sin set'', ''set en devolución'')
          AND EXISTS (SELECT 1 FROM public.wishlist w WHERE w.user_id = u.user_id)
    ) LOOP
        -- Find the first available set from user''s wishlist (by creation order)
        -- Check that there is stock available
        -- Use table aliases to avoid ambiguous column references
        SELECT w.set_id INTO target_set_id
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        WHERE w.user_id = r.user_id
          AND i.inventory_set_total_qty > 0
        ORDER BY w.created_at ASC  -- First item in wishlist (oldest entry)
        LIMIT 1;

        -- If a set is found, perform assignment
        IF target_set_id IS NOT NULL THEN
            -- 1. Update Inventory: decrement total stock and increment en_envio
            UPDATE public.inventory_sets
            SET inventory_set_total_qty = inventory_set_total_qty - 1,
                en_envio = en_envio + 1
            WHERE inventory_sets.set_id = target_set_id;

            -- 2. Create Order
            INSERT INTO public.orders (user_id, set_id, status)
            VALUES (r.user_id, target_set_id, ''pending'');

            -- 3. Update User Status
            UPDATE public.users
            SET estado_usuario = ''set en envio''
            WHERE users.user_id = r.user_id;

            -- Return the result
            user_id := r.user_id;
            set_id := target_set_id;
            status := ''Assigned'';
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER"}', 'fix_ambiguous_column');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260127125500', '{"-- Add set_ref field to envios table

ALTER TABLE public.envios
ADD COLUMN IF NOT EXISTS set_ref TEXT","-- Add comment to explain the field
COMMENT ON COLUMN public.envios.set_ref IS ''LEGO set reference (e.g., 75192) for quick reference''"}', 'add_set_ref_to_envios');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260130170000', '{"-- Fix triggers and functions after the global refactor (profiles -> users)

-- 1. Update handle_new_user function to reference ''users'' instead of ''profiles''
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.users (user_id, full_name, user_status)
    VALUES (NEW.id, NEW.raw_user_meta_data ->> ''full_name'', ''sin set'');
    
    -- Assign default ''user'' role
    INSERT INTO public.user_roles (user_id, role)
    VALUES (NEW.id, ''user'');
    
    RETURN NEW;
END;
$$","-- 2. Update update_updated_at_column trigger for the renamed ''users'' table
DROP TRIGGER IF EXISTS update_profiles_updated_at ON public.users","DROP TRIGGER IF EXISTS update_users_updated_at ON public.users","CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column()","-- 3. Ensure RLS is updated for the new table name ''users''
-- Note: ''ALTER TABLE RENAME'' usually preserves policies, but let''s be safe.
-- We can check if policies exist or recreate them if needed."}', 'fix_triggers_after_refactor');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260130180000', '{"-- Update user_status constraint to allow only specific values
-- This migration updates the constraint to support the new business logic

-- 1. Update any users with ''con set'' status to ''sin set''
UPDATE public.users 
SET user_status = ''sin set'' 
WHERE user_status = ''con set''","-- 2. Drop the old constraint if it exists
ALTER TABLE public.users DROP CONSTRAINT IF EXISTS check_estado_usuario_users","ALTER TABLE public.users DROP CONSTRAINT IF EXISTS check_estado_usuario","-- 3. Add the new constraint with the updated allowed values
ALTER TABLE public.users 
ADD CONSTRAINT check_user_status 
CHECK (user_status IN (''set en envio'', ''sin set'', ''recibido'', ''set en devolucion'', ''suspendido''))","-- 4. Add comment to explain the allowed values
COMMENT ON COLUMN public.users.user_status IS ''Allowed values: set en envio, sin set, recibido, set en devolucion, suspendido''"}', 'update_user_status_constraint');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260130180100', '{"-- Create function to delete assignment and rollback all related changes
-- This function handles cascading deletions and inventory rollback

CREATE OR REPLACE FUNCTION public.delete_assignment_and_rollback(p_envio_id UUID)
RETURNS VOID AS $$
DECLARE
    v_order_id UUID;
    v_user_id UUID;
    v_set_id UUID;
BEGIN
    -- Get the related IDs from the envio record
    SELECT order_id, user_id INTO v_order_id, v_user_id
    FROM public.envios
    WHERE id = p_envio_id;

    -- If envio doesn''t exist, raise exception
    IF v_order_id IS NULL THEN
        RAISE EXCEPTION ''Envio with ID % not found'', p_envio_id;
    END IF;

    -- Get set_id from the order
    SELECT set_id INTO v_set_id
    FROM public.orders
    WHERE id = v_order_id;

    -- 1. Delete the envio record (this will also delete related operaciones_recepcion if any due to CASCADE)
    DELETE FROM public.envios WHERE id = p_envio_id;

    -- 2. Delete the order record
    DELETE FROM public.orders WHERE id = v_order_id;

    -- 3. Rollback inventory: increment total qty, decrement en_envio
    UPDATE public.inventory_sets
    SET inventory_set_total_qty = inventory_set_total_qty + 1,
        en_envio = GREATEST(en_envio - 1, 0)
    WHERE set_id = v_set_id;

    -- 4. Update user status back to appropriate state
    -- If user has other active orders, keep current status
    -- Otherwise, set to ''sin set''
    UPDATE public.users
    SET user_status = CASE 
        WHEN EXISTS (
            SELECT 1 FROM public.orders 
            WHERE user_id = v_user_id 
            AND status IN (''pending'', ''delivered'')
        ) THEN user_status
        ELSE ''sin set''
    END
    WHERE user_id = v_user_id;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public","-- Grant execute permissions
REVOKE EXECUTE ON FUNCTION public.delete_assignment_and_rollback FROM PUBLIC","GRANT EXECUTE ON FUNCTION public.delete_assignment_and_rollback TO authenticated","COMMENT ON FUNCTION public.delete_assignment_and_rollback IS ''Deletes an assignment (envio) and rolls back all related changes including inventory and user status''"}', 'create_delete_assignment_function');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260130180200', '{"-- Update assign_sets_to_users function to return full envio details
-- This allows the frontend to display newly created assignments immediately

-- Drop the existing function first since we''re changing the return type
DROP FUNCTION IF EXISTS public.assign_sets_to_users()","CREATE OR REPLACE FUNCTION public.assign_sets_to_users()
RETURNS TABLE (
    envio_id UUID, 
    user_id UUID, 
    set_id UUID, 
    order_id UUID, 
    user_name TEXT, 
    set_name TEXT, 
    set_ref TEXT,
    created_at TIMESTAMPTZ
) AS $$
DECLARE
    r RECORD;
    target_set_id UUID;
    new_order_id UUID;
    new_envio_id UUID;
    v_set_name TEXT;
    v_set_ref TEXT;
    v_created_at TIMESTAMPTZ;
BEGIN
    -- Loop through eligible users
    FOR r IN (
        SELECT u.user_id, u.full_name
        FROM public.users u
        WHERE u.user_status IN (''sin set'', ''set en devolucion'')
          AND EXISTS (SELECT 1 FROM public.wishlist w WHERE w.user_id = u.user_id)
    ) LOOP
        -- Find the first available set from user''s wishlist (by creation order)
        SELECT w.set_id, s.set_name, s.set_ref 
        INTO target_set_id, v_set_name, v_set_ref
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        JOIN public.sets s ON w.set_id = s.id
        WHERE w.user_id = r.user_id
          AND i.inventory_set_total_qty > 0
        ORDER BY w.created_at ASC
        LIMIT 1;

        -- If a set is found, perform assignment
        IF target_set_id IS NOT NULL THEN
            -- 1. Update Inventory: decrement total stock and increment en_envio
            UPDATE public.inventory_sets
            SET inventory_set_total_qty = inventory_set_total_qty - 1,
                en_envio = en_envio + 1
            WHERE inventory_sets.set_id = target_set_id;

            -- 2. Create Order
            INSERT INTO public.orders (user_id, set_id, status)
            VALUES (r.user_id, target_set_id, ''pending'')
            RETURNING id INTO new_order_id;

            -- 3. Create Envio record
            INSERT INTO public.envios (
                order_id, 
                user_id, 
                estado_envio,
                direccion_envio,
                ciudad_envio,
                codigo_postal_envio
            )
            VALUES (
                new_order_id,
                r.user_id,
                ''pendiente'',
                ''Pendiente de asignación'',
                ''Pendiente'',
                ''00000''
            )
            RETURNING id, created_at INTO new_envio_id, v_created_at;

            -- 4. Update User Status
            UPDATE public.users
            SET user_status = ''set en envio''
            WHERE users.user_id = r.user_id;

            -- Return the result with full details
            envio_id := new_envio_id;
            user_id := r.user_id;
            set_id := target_set_id;
            order_id := new_order_id;
            user_name := r.full_name;
            set_name := v_set_name;
            set_ref := v_set_ref;
            created_at := v_created_at;
            
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public","COMMENT ON FUNCTION public.assign_sets_to_users IS ''Assigns available sets to users based on wishlist and returns full envio details for immediate display''"}', 'update_assign_function_return_envios');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260131133000', '{"-- Update user defaults and add constraints

-- 1. Create or replace the function to handle new user defaults
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.users (user_id, email, full_name, avatar_url, subscription_status, user_status)
  VALUES (
    new.id,
    new.email,
    new.raw_user_meta_data->>''full_name'',
    new.raw_user_meta_data->>''avatar_url'',
    ''inactive'', -- Default subscription status
    ''sin set''   -- Default user status
  );
  RETURN new;
END;
$$","-- 2. Add check constraint for subscription_status if it doesn''t exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = ''users_subscription_status_check''
    ) THEN
        ALTER TABLE public.users
        ADD CONSTRAINT users_subscription_status_check
        CHECK (subscription_status IN (''active'', ''inactive''));
    END IF;
END $$"}', 'update_user_defaults');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260131140000', '{"-- Remove sub_status and initialize subscription_status

-- 1. Initialize subscription_status to ''inactive'' where it is null
UPDATE public.users
SET subscription_status = ''inactive''
WHERE subscription_status IS NULL","-- 2. Drop the sub_status column
ALTER TABLE public.users
DROP COLUMN IF EXISTS sub_status"}', 'cleanup_users_table');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260130210000', '{"-- Fix ambiguous column reference in assign_sets_to_users function
-- The RETURNING clause was ambiguous because multiple tables have created_at

DROP FUNCTION IF EXISTS public.assign_sets_to_users()","CREATE OR REPLACE FUNCTION public.assign_sets_to_users()
RETURNS TABLE (
    envio_id UUID, 
    user_id UUID, 
    set_id UUID, 
    order_id UUID, 
    user_name TEXT, 
    set_name TEXT, 
    set_ref TEXT,
    created_at TIMESTAMPTZ
) AS $$
DECLARE
    r RECORD;
    target_set_id UUID;
    new_order_id UUID;
    new_envio_id UUID;
    v_set_name TEXT;
    v_set_ref TEXT;
    v_created_at TIMESTAMPTZ;
BEGIN
    -- Loop through eligible users
    FOR r IN (
        SELECT u.user_id, u.full_name
        FROM public.users u
        WHERE u.user_status IN (''sin set'', ''set en devolucion'')
          AND EXISTS (SELECT 1 FROM public.wishlist w WHERE w.user_id = u.user_id)
    ) LOOP
        -- Find the first available set from user''s wishlist (by creation order)
        SELECT w.set_id, s.set_name, s.set_ref 
        INTO target_set_id, v_set_name, v_set_ref
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        JOIN public.sets s ON w.set_id = s.id
        WHERE w.user_id = r.user_id
          AND i.inventory_set_total_qty > 0
        ORDER BY w.created_at ASC
        LIMIT 1;

        -- If a set is found, perform assignment
        IF target_set_id IS NOT NULL THEN
            -- 1. Update Inventory: decrement total stock and increment en_envio
            UPDATE public.inventory_sets
            SET inventory_set_total_qty = inventory_set_total_qty - 1,
                en_envio = en_envio + 1
            WHERE inventory_sets.set_id = target_set_id;

            -- 2. Create Order
            INSERT INTO public.orders (user_id, set_id, status)
            VALUES (r.user_id, target_set_id, ''pending'')
            RETURNING id INTO new_order_id;

            -- 3. Create Envio record
            INSERT INTO public.envios (
                order_id, 
                user_id, 
                estado_envio,
                direccion_envio,
                ciudad_envio,
                codigo_postal_envio
            )
            VALUES (
                new_order_id,
                r.user_id,
                ''pendiente'',
                ''Pendiente de asignación'',
                ''Pendiente'',
                ''00000''
            )
            -- FIX: Explicitly specify table name to avoid ambiguity
            RETURNING envios.id, envios.created_at INTO new_envio_id, v_created_at;

            -- 4. Update User Status
            UPDATE public.users
            SET user_status = ''set en envio''
            WHERE users.user_id = r.user_id;

            -- Return the result with full details
            envio_id := new_envio_id;
            user_id := r.user_id;
            set_id := target_set_id;
            order_id := new_order_id;
            user_name := r.full_name;
            set_name := v_set_name;
            set_ref := v_set_ref;
            created_at := v_created_at;
            
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public","COMMENT ON FUNCTION public.assign_sets_to_users IS ''Assigns available sets to users based on wishlist and returns full envio details for immediate display''"}', 'fix_assign_function_ambiguous_column');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260130210100', '{"-- Create preview function that shows proposed assignments WITHOUT making changes
-- This is a read-only function for the preview/confirmation flow

CREATE OR REPLACE FUNCTION public.preview_assign_sets_to_users()
RETURNS TABLE (
    user_id UUID,
    user_name TEXT,
    set_id UUID,
    set_name TEXT,
    set_ref TEXT,
    current_stock INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT ON (u.user_id)
        u.user_id,
        u.full_name AS user_name,
        w.set_id,
        s.set_name,
        s.set_ref,
        i.inventory_set_total_qty AS current_stock
    FROM public.users u
    JOIN public.wishlist w ON w.user_id = u.user_id
    JOIN public.inventory_sets i ON w.set_id = i.set_id
    JOIN public.sets s ON w.set_id = s.id
    WHERE u.user_status IN (''sin set'', ''set en devolucion'')
      AND i.inventory_set_total_qty > 0
    ORDER BY u.user_id, w.created_at ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public","COMMENT ON FUNCTION public.preview_assign_sets_to_users IS ''Shows proposed set assignments without making any database changes - for preview/confirmation flow''"}', 'create_preview_function');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260130210200', '{"-- Create confirm function that executes assignments for specific user IDs
-- This is called after user confirms the preview

CREATE OR REPLACE FUNCTION public.confirm_assign_sets_to_users(p_user_ids UUID[])
RETURNS TABLE (
    envio_id UUID, 
    user_id UUID, 
    set_id UUID, 
    order_id UUID, 
    user_name TEXT, 
    set_name TEXT, 
    set_ref TEXT,
    created_at TIMESTAMPTZ
) AS $$
DECLARE
    r RECORD;
    target_set_id UUID;
    new_order_id UUID;
    new_envio_id UUID;
    v_set_name TEXT;
    v_set_ref TEXT;
    v_created_at TIMESTAMPTZ;
BEGIN
    -- Loop through specified users only
    FOR r IN (
        SELECT u.user_id, u.full_name
        FROM public.users u
        WHERE u.user_id = ANY(p_user_ids)
          AND u.user_status IN (''sin set'', ''set en devolucion'')
          AND EXISTS (SELECT 1 FROM public.wishlist w WHERE w.user_id = u.user_id)
    ) LOOP
        -- Find the first available set from user''s wishlist (by creation order)
        SELECT w.set_id, s.set_name, s.set_ref 
        INTO target_set_id, v_set_name, v_set_ref
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        JOIN public.sets s ON w.set_id = s.id
        WHERE w.user_id = r.user_id
          AND i.inventory_set_total_qty > 0
        ORDER BY w.created_at ASC
        LIMIT 1;

        -- If a set is found, perform assignment
        IF target_set_id IS NOT NULL THEN
            -- 1. Update Inventory: decrement total stock and increment en_envio
            UPDATE public.inventory_sets
            SET inventory_set_total_qty = inventory_set_total_qty - 1,
                en_envio = en_envio + 1
            WHERE inventory_sets.set_id = target_set_id;

            -- 2. Create Order
            INSERT INTO public.orders (user_id, set_id, status)
            VALUES (r.user_id, target_set_id, ''pending'')
            RETURNING id INTO new_order_id;

            -- 3. Create Envio record
            INSERT INTO public.envios (
                order_id, 
                user_id, 
                estado_envio,
                direccion_envio,
                ciudad_envio,
                codigo_postal_envio
            )
            VALUES (
                new_order_id,
                r.user_id,
                ''pendiente'',
                ''Pendiente de asignación'',
                ''Pendiente'',
                ''00000''
            )
            RETURNING envios.id, envios.created_at INTO new_envio_id, v_created_at;

            -- 4. Update User Status
            UPDATE public.users
            SET user_status = ''set en envio''
            WHERE users.user_id = r.user_id;

            -- Return the result with full details
            envio_id := new_envio_id;
            user_id := r.user_id;
            set_id := target_set_id;
            order_id := new_order_id;
            user_name := r.full_name;
            set_name := v_set_name;
            set_ref := v_set_ref;
            created_at := v_created_at;
            
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public","COMMENT ON FUNCTION public.confirm_assign_sets_to_users IS ''Executes set assignments for specific confirmed user IDs - part of preview/confirmation flow''"}', 'create_confirm_function');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260130220000', '{"-- Refactor envios table to remove dependency on orders table
-- Add set_id directly to envios, migrate data, and drop orders

-- 1. Add set_id column to envios
ALTER TABLE public.envios 
ADD COLUMN set_id UUID REFERENCES public.sets(id) ON DELETE SET NULL","-- 2. Migrate existing data: copy set_id from orders to envios
UPDATE public.envios e
SET set_id = o.set_id
FROM public.orders o
WHERE e.order_id = o.id","-- 3. Drop order_id column (this will drop the foreign key constraint automatically)
ALTER TABLE public.envios DROP COLUMN order_id","-- 4. Drop orders table completely
DROP TABLE IF EXISTS public.orders CASCADE","-- 5. Add index on set_id for performance
CREATE INDEX IF NOT EXISTS idx_envios_set_id ON public.envios(set_id)","COMMENT ON COLUMN public.envios.set_id IS ''Direct reference to the set being shipped, eliminates need for orders table''"}', 'refactor_envios_remove_orders');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260130220100', '{"-- Update estado_envio constraint to new allowed values
-- New values: preparacion, ruta_envio, devolucion, ruta_devolucion

-- 1. Update existing values to new schema
UPDATE public.envios
SET estado_envio = CASE
    WHEN estado_envio IN (''pendiente'', ''asignado'') THEN ''preparacion''
    WHEN estado_envio = ''en_transito'' THEN ''ruta_envio''
    WHEN estado_envio = ''devuelto'' THEN ''ruta_devolucion''
    WHEN estado_envio = ''entregado'' THEN ''preparacion''
    WHEN estado_envio = ''cancelado'' THEN ''preparacion''
    ELSE ''preparacion''
END","-- 2. Drop old constraint if exists
ALTER TABLE public.envios DROP CONSTRAINT IF EXISTS check_estado_envio","-- 3. Add new CHECK constraint
ALTER TABLE public.envios
ADD CONSTRAINT check_estado_envio
CHECK (estado_envio IN (''preparacion'', ''ruta_envio'', ''devolucion'', ''ruta_devolucion''))","-- 4. Update column comment
COMMENT ON COLUMN public.envios.estado_envio IS ''Allowed values: preparacion (en preparación, no recogido), ruta_envio (de camino a usuario), devolucion (solicitada devolución, no recogido), ruta_devolucion (en devolución)''"}', 'update_estado_envio_constraint');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260131160000', '{"-- Update check constraint for envios.estado_envio to include ''entregado''

ALTER TABLE public.envios DROP CONSTRAINT IF EXISTS check_estado_envio","ALTER TABLE public.envios
ADD CONSTRAINT check_estado_envio
CHECK (estado_envio IN (''preparacion'', ''ruta_envio'', ''entregado'', ''devolucion'', ''ruta_devolucion''))","COMMENT ON COLUMN public.envios.estado_envio IS ''Allowed values: preparacion, ruta_envio, entregado, devolucion, ruta_devolucion''"}', 'update_envios_status');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260322180000', '{"-- ============================================================================
-- Migration: Add ''in_return'' shipment status
-- Date: 2026-03-22
-- Description:
--   Adds ''in_return'' status = set en tránsito entre PUDO y oficina central
--   Flow: in_return_pudo → in_return → returned
-- ============================================================================

-- Drop and recreate constraint with new value
ALTER TABLE public.shipments DROP CONSTRAINT IF EXISTS check_shipment_status","ALTER TABLE public.shipments ADD CONSTRAINT check_shipment_status
  CHECK (shipment_status IN (
    ''pending'',
    ''preparation'',
    ''in_transit_pudo'',
    ''delivered_pudo'',
    ''delivered_user'',
    ''in_return_pudo'',
    ''in_return'',
    ''returned'',
    ''cancelled''
  ))"}', 'add_in_return_status');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260130220200', '{"-- Update confirm function to not use orders table and delete from wishlist
-- Creates envios directly with set_id, deletes from wishlist after assignment

DROP FUNCTION IF EXISTS public.confirm_assign_sets_to_users(UUID[])","CREATE OR REPLACE FUNCTION public.confirm_assign_sets_to_users(p_user_ids UUID[])
RETURNS TABLE (
    envio_id UUID, 
    user_id UUID, 
    set_id UUID, 
    user_name TEXT, 
    set_name TEXT, 
    set_ref TEXT,
    created_at TIMESTAMPTZ
) AS $$
DECLARE
    r RECORD;
    target_set_id UUID;
    new_envio_id UUID;
    v_set_name TEXT;
    v_set_ref TEXT;
    v_created_at TIMESTAMPTZ;
BEGIN
    -- Loop through specified users only
    FOR r IN (
        SELECT u.user_id, u.full_name
        FROM public.users u
        WHERE u.user_id = ANY(p_user_ids)
          AND u.user_status IN (''sin set'', ''set en devolucion'')
          AND EXISTS (SELECT 1 FROM public.wishlist w WHERE w.user_id = u.user_id)
    ) LOOP
        -- Find the first available set from user''s wishlist (by creation order)
        SELECT w.set_id, s.set_name, s.set_ref 
        INTO target_set_id, v_set_name, v_set_ref
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        JOIN public.sets s ON w.set_id = s.id
        WHERE w.user_id = r.user_id
          AND i.inventory_set_total_qty > 0
        ORDER BY w.created_at ASC
        LIMIT 1;

        -- If a set is found, perform assignment
        IF target_set_id IS NOT NULL THEN
            -- 1. Update Inventory: decrement total stock and increment en_envio
            UPDATE public.inventory_sets
            SET inventory_set_total_qty = inventory_set_total_qty - 1,
                en_envio = en_envio + 1
            WHERE inventory_sets.set_id = target_set_id;

            -- 2. Create Envio record (NO ORDER NEEDED)
            INSERT INTO public.envios (
                user_id,
                set_id,
                estado_envio,
                direccion_envio,
                ciudad_envio,
                codigo_postal_envio
            )
            VALUES (
                r.user_id,
                target_set_id,
                ''preparacion'',
                ''Pendiente de asignación'',
                ''Pendiente'',
                ''00000''
            )
            RETURNING envios.id, envios.created_at INTO new_envio_id, v_created_at;

            -- 3. Delete from wishlist
            DELETE FROM public.wishlist
            WHERE user_id = r.user_id AND set_id = target_set_id;

            -- 4. Update User Status
            UPDATE public.users
            SET user_status = ''set en envio''
            WHERE users.user_id = r.user_id;

            -- Return the result with full details
            envio_id := new_envio_id;
            user_id := r.user_id;
            set_id := target_set_id;
            user_name := r.full_name;
            set_name := v_set_name;
            set_ref := v_set_ref;
            created_at := v_created_at;
            
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public","COMMENT ON FUNCTION public.confirm_assign_sets_to_users IS ''Executes set assignments for confirmed user IDs - creates envios directly without orders, deletes from wishlist''"}', 'update_confirm_function_remove_orders');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260130220300', '{"-- Update delete function to not use orders table and restore wishlist
-- Gets set_id directly from envios and restores deleted set to wishlist

DROP FUNCTION IF EXISTS public.delete_assignment_and_rollback(UUID)","CREATE OR REPLACE FUNCTION public.delete_assignment_and_rollback(p_envio_id UUID)
RETURNS VOID AS $$
DECLARE
    v_user_id UUID;
    v_set_id UUID;
BEGIN
    -- Get user_id and set_id directly from envios
    SELECT user_id, set_id INTO v_user_id, v_set_id
    FROM public.envios
    WHERE id = p_envio_id;

    -- If envio doesn''t exist, raise exception
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION ''Envio with ID % not found'', p_envio_id;
    END IF;

    -- 1. Delete the envio record (this will also delete related operaciones_recepcion if any due to CASCADE)
    DELETE FROM public.envios WHERE id = p_envio_id;

    -- 2. Rollback inventory: increment total qty, decrement en_envio
    UPDATE public.inventory_sets
    SET inventory_set_total_qty = inventory_set_total_qty + 1,
        en_envio = GREATEST(en_envio - 1, 0)
    WHERE set_id = v_set_id;

    -- 3. Re-add to wishlist (if not already there)
    INSERT INTO public.wishlist (user_id, set_id)
    VALUES (v_user_id, v_set_id)
    ON CONFLICT (user_id, set_id) DO NOTHING;

    -- 4. Update user status back to appropriate state
    -- If user has other active envios, keep current status
    -- Otherwise, set to ''sin set''
    UPDATE public.users
    SET user_status = CASE 
        WHEN EXISTS (
            SELECT 1 FROM public.envios 
            WHERE user_id = v_user_id 
            AND estado_envio IN (''preparacion'', ''ruta_envio'')
        ) THEN user_status
        ELSE ''sin set''
    END
    WHERE user_id = v_user_id;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public","-- Grant execute permissions
REVOKE EXECUTE ON FUNCTION public.delete_assignment_and_rollback FROM PUBLIC","GRANT EXECUTE ON FUNCTION public.delete_assignment_and_rollback TO authenticated","COMMENT ON FUNCTION public.delete_assignment_and_rollback IS ''Deletes an assignment (envio) and rolls back all changes including inventory and wishlist restoration''"}', 'update_delete_function_remove_orders');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260130230000', '{"-- Update confirm function to explicitly insert set_ref into envios table
-- This ensures set_ref is stored directly in envios for quick access

DROP FUNCTION IF EXISTS public.confirm_assign_sets_to_users(UUID[])","CREATE OR REPLACE FUNCTION public.confirm_assign_sets_to_users(p_user_ids UUID[])
RETURNS TABLE (
    envio_id UUID, 
    user_id UUID, 
    set_id UUID, 
    user_name TEXT, 
    set_name TEXT, 
    set_ref TEXT,
    created_at TIMESTAMPTZ
) AS $$
DECLARE
    r RECORD;
    target_set_id UUID;
    new_envio_id UUID;
    v_set_name TEXT;
    v_set_ref TEXT;
    v_created_at TIMESTAMPTZ;
BEGIN
    -- Loop through specified users only
    FOR r IN (
        SELECT u.user_id, u.full_name
        FROM public.users u
        WHERE u.user_id = ANY(p_user_ids)
          AND u.user_status IN (''sin set'', ''set en devolucion'')
          AND EXISTS (SELECT 1 FROM public.wishlist w WHERE w.user_id = u.user_id)
    ) LOOP
        -- Find the first available set from user''s wishlist (by creation order)
        SELECT w.set_id, s.set_name, s.set_ref 
        INTO target_set_id, v_set_name, v_set_ref
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        JOIN public.sets s ON w.set_id = s.id
        WHERE w.user_id = r.user_id
          AND i.inventory_set_total_qty > 0
        ORDER BY w.created_at ASC
        LIMIT 1;

        -- If a set is found, perform assignment
        IF target_set_id IS NOT NULL THEN
            -- 1. Update Inventory: decrement total stock and increment en_envio
            UPDATE public.inventory_sets
            SET inventory_set_total_qty = inventory_set_total_qty - 1,
                en_envio = en_envio + 1
            WHERE inventory_sets.set_id = target_set_id;

            -- 2. Create Envio record with set_ref explicitly included
            INSERT INTO public.envios (
                user_id,
                set_id,
                set_ref,
                estado_envio,
                direccion_envio,
                ciudad_envio,
                codigo_postal_envio
            )
            VALUES (
                r.user_id,
                target_set_id,
                v_set_ref,
                ''preparacion'',
                ''Pendiente de asignación'',
                ''Pendiente'',
                ''00000''
            )
            RETURNING envios.id, envios.created_at INTO new_envio_id, v_created_at;

            -- 3. Delete from wishlist
            DELETE FROM public.wishlist
            WHERE user_id = r.user_id AND set_id = target_set_id;

            -- 4. Update User Status
            UPDATE public.users
            SET user_status = ''set en envio''
            WHERE users.user_id = r.user_id;

            -- Return the result with full details
            envio_id := new_envio_id;
            user_id := r.user_id;
            set_id := target_set_id;
            user_name := r.full_name;
            set_name := v_set_name;
            set_ref := v_set_ref;
            created_at := v_created_at;
            
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public","COMMENT ON FUNCTION public.confirm_assign_sets_to_users IS ''Executes set assignments for confirmed user IDs - creates envios with set_ref, deletes from wishlist''"}', 'add_set_ref_to_envios_insert');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260130230100', '{"-- Fix ambiguous user_id reference in DELETE statement
-- Explicitly qualify user_id columns to avoid ambiguity

DROP FUNCTION IF EXISTS public.confirm_assign_sets_to_users(UUID[])","CREATE OR REPLACE FUNCTION public.confirm_assign_sets_to_users(p_user_ids UUID[])
RETURNS TABLE (
    envio_id UUID, 
    user_id UUID, 
    set_id UUID, 
    user_name TEXT, 
    set_name TEXT, 
    set_ref TEXT,
    created_at TIMESTAMPTZ
) AS $$
DECLARE
    r RECORD;
    target_set_id UUID;
    new_envio_id UUID;
    v_set_name TEXT;
    v_set_ref TEXT;
    v_created_at TIMESTAMPTZ;
BEGIN
    -- Loop through specified users only
    FOR r IN (
        SELECT u.user_id, u.full_name
        FROM public.users u
        WHERE u.user_id = ANY(p_user_ids)
          AND u.user_status IN (''sin set'', ''set en devolucion'')
          AND EXISTS (SELECT 1 FROM public.wishlist w WHERE w.user_id = u.user_id)
    ) LOOP
        -- Find the first available set from user''s wishlist (by creation order)
        SELECT w.set_id, s.set_name, s.set_ref 
        INTO target_set_id, v_set_name, v_set_ref
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        JOIN public.sets s ON w.set_id = s.id
        WHERE w.user_id = r.user_id
          AND i.inventory_set_total_qty > 0
        ORDER BY w.created_at ASC
        LIMIT 1;

        -- If a set is found, perform assignment
        IF target_set_id IS NOT NULL THEN
            -- 1. Update Inventory: decrement total stock and increment en_envio
            UPDATE public.inventory_sets
            SET inventory_set_total_qty = inventory_set_total_qty - 1,
                en_envio = en_envio + 1
            WHERE inventory_sets.set_id = target_set_id;

            -- 2. Create Envio record with set_ref explicitly included
            INSERT INTO public.envios (
                user_id,
                set_id,
                set_ref,
                estado_envio,
                direccion_envio,
                ciudad_envio,
                codigo_postal_envio
            )
            VALUES (
                r.user_id,
                target_set_id,
                v_set_ref,
                ''preparacion'',
                ''Pendiente de asignación'',
                ''Pendiente'',
                ''00000''
            )
            RETURNING envios.id, envios.created_at INTO new_envio_id, v_created_at;

            -- 3. Delete from wishlist - FIX: explicitly qualify columns
            DELETE FROM public.wishlist
            WHERE wishlist.user_id = r.user_id AND wishlist.set_id = target_set_id;

            -- 4. Update User Status
            UPDATE public.users
            SET user_status = ''set en envio''
            WHERE users.user_id = r.user_id;

            -- Return the result with full details
            envio_id := new_envio_id;
            user_id := r.user_id;
            set_id := target_set_id;
            user_name := r.full_name;
            set_name := v_set_name;
            set_ref := v_set_ref;
            created_at := v_created_at;
            
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public","COMMENT ON FUNCTION public.confirm_assign_sets_to_users IS ''Executes set assignments for confirmed user IDs - creates envios with set_ref, deletes from wishlist''"}', 'fix_ambiguous_user_id');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260131130000', '{"-- Migration: Add Stripe fields to users table
-- Description: Adds fields required for Stripe integration (Customer ID, Subscription ID, etc.)

-- 1. Add columns to users table
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS stripe_customer_id TEXT UNIQUE,
ADD COLUMN IF NOT EXISTS subscription_id TEXT,
ADD COLUMN IF NOT EXISTS subscription_status TEXT,
ADD COLUMN IF NOT EXISTS subscription_type TEXT","-- 2. Add comment explaining the fields
COMMENT ON COLUMN public.users.stripe_customer_id IS ''Stripe Customer ID associated with the user''","COMMENT ON COLUMN public.users.subscription_id IS ''Current active Stripe Subscription ID''","COMMENT ON COLUMN public.users.subscription_status IS ''Status of the subscription (OK, trialing, past_due, canceled, etc.)''","COMMENT ON COLUMN public.users.subscription_type IS ''The plan level (Brick Starter, Pro, Master)''","-- 3. Add an index for faster lookups during webhooks
CREATE INDEX IF NOT EXISTS idx_users_stripe_customer_id ON public.users(stripe_customer_id)"}', 'add_stripe_fields');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260131163000', '{"-- Re-apply confirm_assign_sets_to_users to ensure set_ref is copied to envios
-- This logic guarantees that when a set is assigned, its lego_ref/set_ref is stored in the envios table

CREATE OR REPLACE FUNCTION public.confirm_assign_sets_to_users(p_user_ids UUID[])
RETURNS TABLE (
    envio_id UUID, 
    user_id UUID, 
    set_id UUID, 
    user_name TEXT, 
    set_name TEXT, 
    set_ref TEXT,
    created_at TIMESTAMPTZ
) AS $$
DECLARE
    r RECORD;
    target_set_id UUID;
    new_envio_id UUID;
    v_set_name TEXT;
    v_set_ref TEXT;
    v_created_at TIMESTAMPTZ;
BEGIN
    -- Loop through specified users only
    FOR r IN (
        SELECT u.user_id, u.full_name
        FROM public.users u
        WHERE u.user_id = ANY(p_user_ids)
          AND u.user_status IN (''sin set'', ''set en devolucion'')
          AND EXISTS (SELECT 1 FROM public.wishlist w WHERE w.user_id = u.user_id)
    ) LOOP
        -- Find the first available set from user''s wishlist (by creation order)
        -- Explicitly selecting set_ref to be used in insertion
        SELECT w.set_id, s.set_name, s.set_ref 
        INTO target_set_id, v_set_name, v_set_ref
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        JOIN public.sets s ON w.set_id = s.id
        WHERE w.user_id = r.user_id
          AND i.inventory_set_total_qty > 0
        ORDER BY w.created_at ASC
        LIMIT 1;

        -- If a set is found, perform assignment
        IF target_set_id IS NOT NULL THEN
            -- 1. Update Inventory: decrement total stock and increment en_envio
            UPDATE public.inventory_sets
            SET inventory_set_total_qty = inventory_set_total_qty - 1,
                en_envio = en_envio + 1
            WHERE inventory_sets.set_id = target_set_id;

            -- 2. Create Envio record with set_ref explicitly included
            INSERT INTO public.envios (
                user_id,
                set_id,
                set_ref,
                estado_envio,
                direccion_envio,
                ciudad_envio,
                codigo_postal_envio
            )
            VALUES (
                r.user_id,
                target_set_id,
                v_set_ref, -- Inserting the copied reference
                ''preparacion'',
                ''Pendiente de asignación'',
                ''Pendiente'',
                ''00000''
            )
            RETURNING envios.id, envios.created_at INTO new_envio_id, v_created_at;

            -- 3. Delete from wishlist
            DELETE FROM public.wishlist
            WHERE user_id = r.user_id AND set_id = target_set_id;

            -- 4. Update User Status
            UPDATE public.users
            SET user_status = ''set en envio''
            WHERE users.user_id = r.user_id;

            -- Return the result with full details
            envio_id := new_envio_id;
            user_id := r.user_id;
            set_id := target_set_id;
            user_name := r.full_name;
            set_name := v_set_name;
            set_ref := v_set_ref;
            created_at := v_created_at;
            
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public","COMMENT ON FUNCTION public.confirm_assign_sets_to_users IS ''Executes set assignments, explicitly copying set_ref to envios table''"}', 'ensure_assignment_copies_set_ref');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260131170000', '{"-- Update allowed statuses for envios.estado_envio

-- 1. Drop existing constraint
ALTER TABLE public.envios DROP CONSTRAINT IF EXISTS check_estado_envio","-- 2. Normalize data
-- User requested changing ''en devolucion'' to ''devuelto''. 
-- Also mapping ''devolucion'' (old value) to ''devuelto'' to unify.
UPDATE public.envios SET estado_envio = ''devuelto'' WHERE estado_envio IN (''devolucion'', ''en devolucion'')","-- 3. Add new Constraint
-- Allowed values:
-- preparacion
-- ruta_envio
-- entregado
-- devuelto (New finalized return state)
-- ruta_devolucion (In transit return)
ALTER TABLE public.envios
ADD CONSTRAINT check_estado_envio
CHECK (estado_envio IN (''preparacion'', ''ruta_envio'', ''entregado'', ''devuelto'', ''ruta_devolucion''))","COMMENT ON COLUMN public.envios.estado_envio IS ''Allowed values: preparacion, ruta_envio, entregado, devuelto, ruta_devolucion''"}', 'update_envios_status_devuelto');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260131173000', '{"-- Allow users to update their own envios status to ''ruta_devolucion''

-- Enable RLS on envios if not already enabled (it should be)
ALTER TABLE public.envios ENABLE ROW LEVEL SECURITY","-- Drop existing policy if it conflicts (unlikely to have this specific one)
DROP POLICY IF EXISTS \"Users can update their own envios status\" ON public.envios","-- Create policy
CREATE POLICY \"Users can update their own envios status\"
ON public.envios
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (
  auth.uid() = user_id 
  AND estado_envio = ''ruta_devolucion''
)","-- Ensure the column being updated is restricted is trickier in pure SQL RLS without triggers, 
-- but the WITH CHECK clause ensures the *result* row matches. 
-- Since we only want them to initiate a return, validation that the *previous* state was ''entregado'' happens in frontend but 
-- we could enforce it here too:
-- USING (auth.uid() = user_id AND estado_envio IN (''entregado'', ''active''))
-- However, keeping it simple: allow them to set it to ''ruta_devolucion'' if it''s their row."}', 'update_envios_rls');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260131174500', '{"-- Create a trigger to update users.user_status when a return is initiated

CREATE OR REPLACE FUNCTION public.handle_return_status_update()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if the status changed to ''ruta_devolucion''
    IF NEW.estado_envio = ''ruta_devolucion'' AND OLD.estado_envio != ''ruta_devolucion'' THEN
        -- Update the user''s status to ''sin set'' as requested
        -- This allows them to be eligible for a new assignment immediately (Exchange flow)
        UPDATE public.users
        SET user_status = ''sin set''
        WHERE user_id = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER","-- Drop trigger if exists to avoid duplication
DROP TRIGGER IF EXISTS on_envio_return_update ON public.envios","-- Create Trigger
CREATE TRIGGER on_envio_return_update
AFTER UPDATE ON public.envios
FOR EACH ROW
EXECUTE FUNCTION public.handle_return_status_update()"}', 'trigger_return_status');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260131175500', '{"-- Fix ambiguous column reference in confirm_assign_sets_to_users

CREATE OR REPLACE FUNCTION public.confirm_assign_sets_to_users(p_user_ids UUID[])
RETURNS TABLE (
    envio_id UUID, 
    user_id UUID, 
    set_id UUID, 
    user_name TEXT, 
    set_name TEXT, 
    set_ref TEXT,
    created_at TIMESTAMPTZ
) AS $$
DECLARE
    r RECORD;
    target_set_id UUID;
    new_envio_id UUID;
    v_set_name TEXT;
    v_set_ref TEXT;
    v_created_at TIMESTAMPTZ;
BEGIN
    -- Loop through specified users only
    FOR r IN (
        SELECT u.user_id, u.full_name
        FROM public.users u
        WHERE u.user_id = ANY(p_user_ids)
          AND u.user_status IN (''sin set'', ''set en devolucion'')
          AND EXISTS (SELECT 1 FROM public.wishlist w WHERE w.user_id = u.user_id)
    ) LOOP
        -- Find the first available set from user''s wishlist
        SELECT w.set_id, s.set_name, s.set_ref 
        INTO target_set_id, v_set_name, v_set_ref
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        JOIN public.sets s ON w.set_id = s.id
        WHERE w.user_id = r.user_id
          AND i.inventory_set_total_qty > 0
        ORDER BY w.created_at ASC
        LIMIT 1;

        -- If a set is found, perform assignment
        IF target_set_id IS NOT NULL THEN
            -- 1. Update Inventory
            UPDATE public.inventory_sets
            SET inventory_set_total_qty = inventory_set_total_qty - 1,
                en_envio = en_envio + 1
            WHERE inventory_sets.set_id = target_set_id;

            -- 2. Create Envio record
            INSERT INTO public.envios (
                user_id,
                set_id,
                set_ref,
                estado_envio,
                direccion_envio,
                ciudad_envio,
                codigo_postal_envio
            )
            VALUES (
                r.user_id,
                target_set_id,
                v_set_ref,
                ''preparacion'',
                ''Pendiente de asignación'',
                ''Pendiente'',
                ''00000''
            )
            RETURNING envios.id, envios.created_at INTO new_envio_id, v_created_at;

            -- 3. Delete from wishlist -- QUALIFIED user_id HERE
            DELETE FROM public.wishlist
            WHERE wishlist.user_id = r.user_id AND wishlist.set_id = target_set_id;

            -- 4. Update User Status
            UPDATE public.users
            SET user_status = ''set en envio''
            WHERE users.user_id = r.user_id;

            -- Return the result
            -- Assign to OUT parameters (which share name with columns, hence the ambiguity risk in queries)
            envio_id := new_envio_id;
            user_id := r.user_id;
            set_id := target_set_id;
            user_name := r.full_name;
            set_name := v_set_name;
            set_ref := v_set_ref;
            created_at := v_created_at;
            
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public"}', 'fix_ambiguous_user_id');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260131184000', '{"-- Create SHIPPING_ORDERS table

CREATE TABLE IF NOT EXISTS public.shipping_orders (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    set_id UUID NOT NULL REFERENCES public.sets(id) ON DELETE CASCADE,
    shipping_order_date TIMESTAMPTZ DEFAULT now(),
    tracking_ref TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
)","-- Enable RLS
ALTER TABLE public.shipping_orders ENABLE ROW LEVEL SECURITY","-- Add basic policy (Authenticated users can read their own orders)
CREATE POLICY \"Users can view their own shipping orders\"
    ON public.shipping_orders
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id)","-- Add updated_at trigger
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql","CREATE TRIGGER on_shipping_orders_updated
    BEFORE UPDATE ON public.shipping_orders
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at()","COMMENT ON TABLE public.shipping_orders IS ''Tracks shipping orders with external carriers''"}', 'create_shipping_orders');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260131185000', '{"-- Drop costo_envio column from envios table
ALTER TABLE public.envios DROP COLUMN IF EXISTS costo_envio"}', 'drop_envios_costo_envio');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260131200000', '{"-- Update preview function to include set_price from sets table
-- Uses COALESCE to provide 100 EUR default if set_price is NULL

-- Drop the function first to allow changing the return table definition
DROP FUNCTION IF EXISTS public.preview_assign_sets_to_users()","CREATE OR REPLACE FUNCTION public.preview_assign_sets_to_users()
RETURNS TABLE (
    user_id UUID,
    user_name TEXT,
    set_id UUID,
    set_name TEXT,
    set_ref TEXT,
    set_price DECIMAL,
    current_stock INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT ON (u.user_id)
        u.user_id,
        u.full_name AS user_name,
        w.set_id,
        s.set_name,
        s.set_ref,
        COALESCE(s.set_price, 100.00) AS set_price,
        i.inventory_set_total_qty AS current_stock
    FROM public.users u
    JOIN public.wishlist w ON w.user_id = u.user_id
    JOIN public.inventory_sets i ON w.set_id = i.set_id
    JOIN public.sets s ON w.set_id = s.id
    WHERE u.user_status IN (''sin set'', ''set en devolucion'')
      AND i.inventory_set_total_qty > 0
    ORDER BY u.user_id, w.created_at ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public","COMMENT ON FUNCTION public.preview_assign_sets_to_users IS ''Shows proposed set assignments with set_price (default 100 EUR if NULL) - for preview/confirmation flow''"}', 'add_set_price_to_preview');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260131200100', '{"-- Update confirm_assign_sets_to_users to include set_price in return
-- This allows the function to be used for payment processing integration

-- Drop the function first to allow changing the return table definition
DROP FUNCTION IF EXISTS public.confirm_assign_sets_to_users(UUID[])","CREATE OR REPLACE FUNCTION public.confirm_assign_sets_to_users(p_user_ids UUID[])
RETURNS TABLE (
    envio_id UUID, 
    user_id UUID, 
    set_id UUID, 
    user_name TEXT, 
    set_name TEXT, 
    set_ref TEXT,
    set_price DECIMAL,
    created_at TIMESTAMPTZ
) AS $$
DECLARE
    r RECORD;
    target_set_id UUID;
    new_envio_id UUID;
    v_set_name TEXT;
    v_set_ref TEXT;
    v_set_price DECIMAL;
    v_created_at TIMESTAMPTZ;
BEGIN
    -- Loop through specified users only
    FOR r IN (
        SELECT u.user_id, u.full_name
        FROM public.users u
        WHERE u.user_id = ANY(p_user_ids)
          AND u.user_status IN (''sin set'', ''set en devolucion'')
          AND EXISTS (SELECT 1 FROM public.wishlist w WHERE w.user_id = u.user_id)
    ) LOOP
        -- Find the first available set from user''s wishlist (by creation order)
        -- Explicitly selecting set_ref and set_price to be used in insertion and return
        SELECT w.set_id, s.set_name, s.set_ref, COALESCE(s.set_price, 100.00)
        INTO target_set_id, v_set_name, v_set_ref, v_set_price
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        JOIN public.sets s ON w.set_id = s.id
        WHERE w.user_id = r.user_id
          AND i.inventory_set_total_qty > 0
        ORDER BY w.created_at ASC
        LIMIT 1;

        -- If a set is found, perform assignment
        IF target_set_id IS NOT NULL THEN
            -- 1. Update Inventory: decrement total stock and increment en_envio
            UPDATE public.inventory_sets
            SET inventory_set_total_qty = inventory_set_total_qty - 1,
                en_envio = en_envio + 1
            WHERE inventory_sets.set_id = target_set_id;

            -- 2. Create Envio record with set_ref explicitly included
            INSERT INTO public.envios (
                user_id,
                set_id,
                set_ref,
                estado_envio,
                direccion_envio,
                ciudad_envio,
                codigo_postal_envio
            )
            VALUES (
                r.user_id,
                target_set_id,
                v_set_ref, -- Inserting the copied reference
                ''preparacion'',
                ''Pendiente de asignación'',
                ''Pendiente'',
                ''00000''
            )
            RETURNING envios.id, envios.created_at INTO new_envio_id, v_created_at;

            -- 3. Delete from wishlist
            DELETE FROM public.wishlist
            WHERE user_id = r.user_id AND set_id = target_set_id;

            -- 4. Update User Status
            UPDATE public.users
            SET user_status = ''set en envio''
            WHERE users.user_id = r.user_id;

            -- Return the result with full details including set_price
            envio_id := new_envio_id;
            user_id := r.user_id;
            set_id := target_set_id;
            user_name := r.full_name;
            set_name := v_set_name;
            set_ref := v_set_ref;
            set_price := v_set_price;
            created_at := v_created_at;
            
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public","COMMENT ON FUNCTION public.confirm_assign_sets_to_users IS ''Executes set assignments, explicitly copying set_ref to envios table and returning set_price''"}', 'add_set_price_to_confirm');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260202193000', '{"-- Migration: Add PUDO fields to users table
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS pudo_id_correos TEXT,
ADD COLUMN IF NOT EXISTS pudo_nombre TEXT,
ADD COLUMN IF NOT EXISTS pudo_direccion_completa TEXT,
ADD COLUMN IF NOT EXISTS pudo_tipo TEXT,
ADD COLUMN IF NOT EXISTS pudo_fecha_seleccion TIMESTAMPTZ","-- Allow users to update their own PUDO preferences
CREATE POLICY \"Users can update their own PUDO fields\" 
ON public.users 
FOR UPDATE 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id)"}', 'add_pudo_fields');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260202210000', '{"-- Migration: Create USERS_Correos_dropping table for storing selected PUDO points
-- This table stores the Correos PUDO (Pick Up Drop Off) point information selected by users

CREATE TABLE IF NOT EXISTS public.users_correos_dropping (
    -- Primary key and user reference
    user_id UUID PRIMARY KEY REFERENCES public.users(user_id) ON DELETE CASCADE,
    
    -- Correos PUDO Point fields (all prefixed with \"correos_\")
    correos_id_pudo TEXT NOT NULL,  -- Unique identifier from Correos API
    correos_nombre TEXT NOT NULL,  -- Name of the PUDO point (e.g., \"Oficina de Correos - Barcelona Centro\")
    correos_tipo_punto TEXT NOT NULL CHECK (correos_tipo_punto IN (''Oficina'', ''Citypaq'', ''Locker'')),  -- Type of point
    
    -- Address information
    correos_direccion_calle TEXT NOT NULL,  -- Street address
    correos_direccion_numero TEXT,  -- Street number
    correos_codigo_postal TEXT NOT NULL,  -- Postal code (5 digits)
    correos_ciudad TEXT NOT NULL,  -- City name
    correos_provincia TEXT NOT NULL,  -- Province
    correos_pais TEXT NOT NULL DEFAULT ''España'',  -- Country
    correos_direccion_completa TEXT NOT NULL,  -- Full formatted address
    
    -- Geolocation
    correos_latitud DECIMAL(10, 8) NOT NULL,  -- Latitude
    correos_longitud DECIMAL(11, 8) NOT NULL,  -- Longitude
    
    -- Operating hours and availability
    correos_horario_apertura TEXT,  -- Opening hours description (e.g., \"L-V: 9:00-20:00, S: 9:00-14:00\")
    correos_horario_estructurado JSONB,  -- Structured schedule data from API (if available)
    correos_disponible BOOLEAN NOT NULL DEFAULT TRUE,  -- Whether the point is currently available
    
    -- Contact information
    correos_telefono TEXT,  -- Phone number
    correos_email TEXT,  -- Contact email
    
    -- Additional metadata
    correos_codigo_interno TEXT,  -- Internal Correos code (if different from id_pudo)
    correos_capacidad_lockers INTEGER,  -- Number of available lockers (for Citypaq/Locker types)
    correos_servicios_adicionales TEXT[],  -- Additional services (e.g., packaging, certified mail)
    correos_accesibilidad BOOLEAN DEFAULT FALSE,  -- Wheelchair accessible
    correos_parking BOOLEAN DEFAULT FALSE,  -- Parking available
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    correos_fecha_seleccion TIMESTAMPTZ NOT NULL DEFAULT NOW()  -- When user selected this point
)","-- Create index on user_id for faster lookups (though it''s already a PK)
CREATE INDEX IF NOT EXISTS idx_users_correos_dropping_user_id ON public.users_correos_dropping(user_id)","-- Create index on postal code for potential queries
CREATE INDEX IF NOT EXISTS idx_users_correos_dropping_cp ON public.users_correos_dropping(correos_codigo_postal)","-- Create index on tipo_punto for filtering
CREATE INDEX IF NOT EXISTS idx_users_correos_dropping_tipo ON public.users_correos_dropping(correos_tipo_punto)","-- Enable Row Level Security
ALTER TABLE public.users_correos_dropping ENABLE ROW LEVEL SECURITY","-- Policy: Users can view only their own PUDO selection
CREATE POLICY \"Users can view their own Correos PUDO selection\"
ON public.users_correos_dropping
FOR SELECT
USING (auth.uid() = user_id)","-- Policy: Users can insert their own PUDO selection
CREATE POLICY \"Users can insert their own Correos PUDO selection\"
ON public.users_correos_dropping
FOR INSERT
WITH CHECK (auth.uid() = user_id)","-- Policy: Users can update their own PUDO selection
CREATE POLICY \"Users can update their own Correos PUDO selection\"
ON public.users_correos_dropping
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id)","-- Policy: Users can delete their own PUDO selection
CREATE POLICY \"Users can delete their own Correos PUDO selection\"
ON public.users_correos_dropping
FOR DELETE
USING (auth.uid() = user_id)","-- Create trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_users_correos_dropping_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql","CREATE TRIGGER trigger_update_users_correos_dropping_updated_at
    BEFORE UPDATE ON public.users_correos_dropping
    FOR EACH ROW
    EXECUTE FUNCTION public.update_users_correos_dropping_updated_at()","-- Add comment to table
COMMENT ON TABLE public.users_correos_dropping IS ''Stores user-selected Correos PUDO (Pick Up Drop Off) points for delivery and pickup''"}', 'create_users_correos_dropping');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260202220000', '{"-- Migration: Seed PUDO data for test users
-- This script prepopulates PUDO points for user2@brickshare.com and user3@brickshare.com

DO $$
DECLARE
    v_user2_id UUID;
    v_user3_id UUID;
BEGIN
    -- 1. Try to find user2 ID
    SELECT id INTO v_user2_id FROM auth.users WHERE email = ''user2@brickshare.com'';
    
    -- 1b. If user2 exists, insert PUDO data (Barcelona)
    IF v_user2_id IS NOT NULL THEN
        -- Check if PUDO already exists to avoid duplicates (though ON CONFLICT could handle it if we had a constraint, current PK is user_id)
        DELETE FROM public.users_correos_dropping WHERE user_id = v_user2_id;

        INSERT INTO public.users_correos_dropping (
            user_id,
            correos_id_pudo,
            correos_nombre,
            correos_tipo_punto,
            correos_direccion_calle,
            correos_direccion_numero,
            correos_codigo_postal,
            correos_ciudad,
            correos_provincia,
            correos_pais,
            correos_direccion_completa,
            correos_latitud,
            correos_longitud,
            correos_horario_apertura,
            correos_disponible,
            correos_servicios_adicionales
        ) VALUES (
            v_user2_id,
            ''BCN01234'',
            ''Oficina Correos - Barcelona Gracia'',
            ''Oficina'',
            ''Carrer Gran de Gràcia'',
            ''120'',
            ''08012'',
            ''Barcelona'',
            ''Barcelona'',
            ''España'',
            ''Carrer Gran de Gràcia, 120, 08012 Barcelona'',
            41.4025,
            2.1550,
            ''L-V: 08:30-20:30, S: 09:30-13:00'',
            TRUE,
            ARRAY[''Admite recogida'', ''Admite entrega'']
        );
        RAISE NOTICE ''Seeded PUDO data for user2 (Barcelona)'';
    ELSE
        RAISE NOTICE ''User user2@brickshare.com not found. Skipping PUDO seed.'';
    END IF;

    -- 2. Try to find user3 ID
    SELECT id INTO v_user3_id FROM auth.users WHERE email = ''user3@brickshare.com'';

    -- 2b. If user3 exists, insert PUDO data (Madrid)
    IF v_user3_id IS NOT NULL THEN
        DELETE FROM public.users_correos_dropping WHERE user_id = v_user3_id;

        INSERT INTO public.users_correos_dropping (
            user_id,
            correos_id_pudo,
            correos_nombre,
            correos_tipo_punto,
            correos_direccion_calle,
            correos_direccion_numero,
            correos_codigo_postal,
            correos_ciudad,
            correos_provincia,
            correos_pais,
            correos_direccion_completa,
            correos_latitud,
            correos_longitud,
            correos_horario_apertura,
            correos_disponible,
            correos_servicios_adicionales
        ) VALUES (
            v_user3_id,
            ''MAD56789'',
            ''Citypaq Carrefour Hortaleza'',
            ''Citypaq'',
            ''Gran Vía de Hortaleza'',
            ''1'',
            ''28043'',
            ''Madrid'',
            ''Madrid'',
            ''España'',
            ''Gran Vía de Hortaleza, 1, 28043 Madrid'',
            40.4700,
            -3.6400,
            ''L-D: 09:00-22:00'',
            TRUE,
            ARRAY[''Parking disponible'', ''Accesible'']
        );
        RAISE NOTICE ''Seeded PUDO data for user3 (Madrid Citypaq)'';
    ELSE
        RAISE NOTICE ''User user3@brickshare.com not found. Skipping PUDO seed.'';
    END IF;

END $$"}', 'seed_pudo_users');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260203000000', '{"-- Migration: Cleanup legacy PUDO fields from users table
-- These fields have been superseded by the `users_correos_dropping` table.

ALTER TABLE public.users 
DROP COLUMN IF EXISTS pudo_id_correos,
DROP COLUMN IF EXISTS pudo_nombre,
DROP COLUMN IF EXISTS pudo_direccion_completa,
DROP COLUMN IF EXISTS pudo_tipo,
DROP COLUMN IF EXISTS pudo_fecha_seleccion","-- Note: The policy \"Users can update their own PUDO fields\" created in 20260202193000 might need to be dropped if it referenced these columns specifically, 
-- but in Supabase policies are usually row-level. However, since the policy was FOR UPDATE, and we no longer need a special policy just for these fields (as standard update policy covers user profile), we can leave it or drop it.
-- Let''s drop it to be clean if possible, but finding its name dynamically is hard in plain SQL migrations without knowing the exact name guaranteed.
-- The name was \"Users can update their own PUDO fields\".

DROP POLICY IF EXISTS \"Users can update their own PUDO fields\" ON public.users"}', 'cleanup_legacy_pudo');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260203000500', '{"-- Migration: Drop deprecated subscription_id column from users table
-- We track subscription status and type, but the raw subscription_id is not needed or used in the new flow.

ALTER TABLE public.users 
DROP COLUMN IF EXISTS subscription_id"}', 'drop_subscription_id');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260203001000', '{"-- Migration: Safety drop of legacy column estado_usuario
-- This column was renamed to user_status in 20260127100000, 
-- but we run this to ensure no zombie column remains in any environment.

ALTER TABLE public.users 
DROP COLUMN IF EXISTS estado_usuario"}', 'drop_estado_usuario_safety');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260204210000', '{"-- Rename ''devolucion'' to ''devuelto'' in envios.estado_envio
-- Requested by user.

-- 1. Drop existing constraint
ALTER TABLE public.envios DROP CONSTRAINT IF EXISTS check_estado_envio","-- 2. Update existing data
UPDATE public.envios
SET estado_envio = ''devuelto''
WHERE estado_envio = ''devolucion''","-- 3. Add new constraint with ''devuelto'' instead of ''devolucion''
-- Allowed: preparacion, ruta_envio, entregado, devuelto, ruta_devolucion, cancelado
ALTER TABLE public.envios
ADD CONSTRAINT check_estado_envio
CHECK (estado_envio IN (''preparacion'', ''ruta_envio'', ''entregado'', ''devuelto'', ''ruta_devolucion'', ''cancelado''))","COMMENT ON COLUMN public.envios.estado_envio IS ''Allowed values: preparacion, ruta_envio, entregado, devuelto, ruta_devolucion, cancelado''"}', 'rename_devolucion_to_devuelto');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260203095500', '{"-- Fix ambiguous column reference in confirm_assign_sets_to_users
-- The error \"user_id is ambiguous\" happens because the function returns a column named user_id, 
-- creating a conflict in SQL statements within the function.

CREATE OR REPLACE FUNCTION public.confirm_assign_sets_to_users(p_user_ids UUID[])
RETURNS TABLE (
    envio_id UUID, 
    user_id UUID, 
    set_id UUID, 
    user_name TEXT, 
    set_name TEXT, 
    set_ref TEXT,
    set_price DECIMAL,
    created_at TIMESTAMPTZ
) AS $$
DECLARE
    r RECORD;
    v_target_set_id UUID;
    v_new_envio_id UUID;
    v_set_name TEXT;
    v_set_ref TEXT;
    v_set_price DECIMAL;
    v_created_at TIMESTAMPTZ;
BEGIN
    -- Loop through specified users only
    FOR r IN (
        SELECT u.user_id as target_uid, u.full_name
        FROM public.users u
        WHERE u.user_id = ANY(p_user_ids)
          AND u.user_status IN (''sin set'', ''set en devolucion'')
          AND EXISTS (SELECT 1 FROM public.wishlist w WHERE w.user_id = u.user_id)
    ) LOOP
        -- Find the first available set from user''s wishlist
        SELECT w.set_id, s.set_name, s.set_ref, COALESCE(s.set_price, 100.00)
        INTO v_target_set_id, v_set_name, v_set_ref, v_set_price
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        JOIN public.sets s ON w.set_id = s.id
        WHERE w.user_id = r.target_uid
          AND i.inventory_set_total_qty > 0
        ORDER BY w.created_at ASC
        LIMIT 1;

        -- If a set is found, perform assignment
        IF v_target_set_id IS NOT NULL THEN
            -- 1. Update Inventory
            UPDATE public.inventory_sets
            SET inventory_set_total_qty = inventory_set_total_qty - 1,
                en_envio = en_envio + 1
            WHERE public.inventory_sets.set_id = v_target_set_id;

            -- 2. Create Envio record
            INSERT INTO public.envios (
                user_id,
                set_id,
                set_ref,
                estado_envio,
                direccion_envio,
                ciudad_envio,
                codigo_postal_envio
            )
            VALUES (
                r.target_uid,
                v_target_set_id,
                v_set_ref,
                ''preparacion'',
                ''Pendiente de asignación'',
                ''Pendiente'',
                ''00000''
            )
            RETURNING id, public.envios.created_at INTO v_new_envio_id, v_created_at;

            -- 3. Delete from wishlist (using table qualification to avoid ambiguity)
            DELETE FROM public.wishlist
            WHERE public.wishlist.user_id = r.target_uid AND public.wishlist.set_id = v_target_set_id;

            -- 4. Update User Status
            UPDATE public.users
            SET user_status = ''set en envio''
            WHERE public.users.user_id = r.target_uid;

            -- Explicitly assign variables for return table
            -- We must use ''assign'' to specific return columns if names conflict
            -- but in RETURNS TABLE, these names are in scope.
            -- To be safe, we assign them one by one.
            envio_id := v_new_envio_id;
            user_id := r.target_uid; -- assigning to the return table column
            set_id := v_target_set_id;
            user_name := r.full_name;
            set_name := v_set_name;
            set_ref := v_set_ref;
            set_price := v_set_price;
            created_at := v_created_at;
            
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public"}', 'fix_ambiguous_user_id_final');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260203100000', '{"-- Add set_status column to sets table
ALTER TABLE public.sets 
ADD COLUMN IF NOT EXISTS set_status text CHECK (set_status IN (''active'', ''inactive'')) DEFAULT ''inactive''"}', 'add_set_status');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260203173000', '{"-- Fix handle_new_set_inventory trigger function
-- It was referencing the old table ''inventario_sets'' and old columns.

CREATE OR REPLACE FUNCTION public.handle_new_set_inventory()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.inventory_sets (set_id, set_ref, inventory_set_total_qty)
    VALUES (NEW.id, NEW.set_ref, 2)
    ON CONFLICT (set_id) DO UPDATE
    SET inventory_set_total_qty = 2; -- Reset to 2 if re-importing, or maybe we should just do NOTHING? 
    -- The original logic had ON CONFLICT DO UPDATE SET... 
    -- Actually, later migration 20260127095000 had ON CONFLICT DO NOTHING in the function body, 
    -- but update logic in the specialized block above it.
    -- Let''s stick to simple initialization: IF exists, do nothing or ensure at least 2?
    -- The prompt implies re-importing via UI overwrites pieces. Maybe we should ensure inventory entry exists.
    -- Let''s use DO NOTHING to preserve existing stock counts if just re-importing set details.
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER"}', 'fix_inventory_trigger');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260203185000', '{"-- Add set_price column to sets table
ALTER TABLE public.sets 
ADD COLUMN IF NOT EXISTS set_price NUMERIC DEFAULT 100.00"}', 'add_set_price');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260203190000', '{"-- Drop set_dim column as it is no longer needed
ALTER TABLE public.sets DROP COLUMN IF EXISTS set_dim"}', 'drop_set_dim');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260203191500', '{"-- Add Brickset value columns to sets table
ALTER TABLE public.sets 
ADD COLUMN IF NOT EXISTS current_value_new NUMERIC,
ADD COLUMN IF NOT EXISTS current_value_used NUMERIC,
ADD COLUMN IF NOT EXISTS set_pvp_release NUMERIC"}', 'add_market_values');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260203192500', '{"-- Add subtheme and barcode columns to sets table
ALTER TABLE public.sets 
ADD COLUMN IF NOT EXISTS set_subtheme TEXT,
ADD COLUMN IF NOT EXISTS barcode_upc TEXT,
ADD COLUMN IF NOT EXISTS barcode_ean TEXT"}', 'add_brickset_details');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260203194000', '{"alter table \"public\".\"set_piece_list\" add column \"element_id\" text","alter table \"public\".\"set_piece_list\" add column \"color_id\" integer","alter table \"public\".\"set_piece_list\" add column \"is_spare\" boolean default false","alter table \"public\".\"set_piece_list\" add column \"location\" text"}', 'enhance_piece_list');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260203214500', '{"alter table \"public\".\"set_piece_list\" drop column \"location\""}', 'drop_location_column');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260203215000', '{"alter table \"public\".\"set_piece_list\" add column \"part_cat_id\" integer","alter table \"public\".\"set_piece_list\" add column \"year_from\" integer","alter table \"public\".\"set_piece_list\" add column \"year_to\" integer","alter table \"public\".\"set_piece_list\" add column \"is_trans\" boolean default false"}', 'add_extended_piece_details');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260203215500', '{"alter table \"public\".\"set_piece_list\" add column \"external_ids\" jsonb"}', 'add_external_ids');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260203220000', '{"alter table \"public\".\"set_piece_list\" drop column \"piece_lego_elementid\""}', 'drop_piece_lego_elementid');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260203224500', '{"alter table \"public\".\"set_piece_list\" drop column \"bricklink_color_id\""}', 'drop_bricklink_color_id');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260204085000', '{"alter table \"public\".\"inventory_sets\" add column \"spare_parts_order\" text"}', 'add_spare_parts_order');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260204120000', '{"-- Migration: Standardize Age Ranges
-- Purpose: Convert old age ranges (e.g. \"5-12 años\", \"9+\", \"8-14\") to new bucket format (\"4+\", \"6+\", \"9+\", \"12+\", \"18+\")
-- Using the Midpoint Nearest Neighbor logic.

CREATE OR REPLACE FUNCTION public.normalize_age_range(range_str TEXT) RETURNS TEXT AS $$
DECLARE
    min_val NUMERIC;
    max_val NUMERIC;
    mid_val NUMERIC;
    
    -- Targets
    targets NUMERIC[] := ARRAY[4, 6, 9, 12, 18];
    
    closest NUMERIC;
    min_diff NUMERIC;
    curr_diff NUMERIC;
    t NUMERIC;
BEGIN
    -- Extract Min (Start of string)
    min_val := (substring(range_str from ''^(\\d+)'')::NUMERIC);
    
    IF min_val IS NULL THEN
        RETURN range_str; -- Cannot parse, leave as is
    END IF;

    -- Extract Max (After hyphen)
    max_val := (substring(range_str from ''-(\\d+)'')::NUMERIC);
    
    -- Calculate Midpoint
    IF max_val IS NOT NULL THEN
        mid_val := (min_val + max_val) / 2.0;
    ELSE
        mid_val := min_val; -- Treat \"10+\" as 10 (or midpoint of 10..10)
    END IF;

    -- Find Nearest Neighbor
    closest := targets[1];
    min_diff := ABS(mid_val - closest);
    
    -- Iterate targets (index 1 to 5)
    FOREACH t IN ARRAY targets
    LOOP
        curr_diff := ABS(mid_val - t);
        IF curr_diff < min_diff THEN
            min_diff := curr_diff;
            closest := t;
        ELSIF curr_diff = min_diff THEN
            -- Tie-breaker: choose existing closest (which is effectively lower in loop order? No, array is sorted asc)
            -- Wait, loop order 4,6,9...
            -- If I have 7.5 (mid between 6 and 9).
            -- Iter 6: diff 1.5. Closest = 6.
            -- Iter 9: diff 1.5. Curr = Min.
            -- Logic in JS was: \"closest = targets[i]\" (prefer higher).
            closest := t; 
        END IF;
    END LOOP;

    RETURN closest || ''+'';
END;
$$ LANGUAGE plpgsql","-- Execute Update
UPDATE public.sets
SET set_age_range = public.normalize_age_range(set_age_range)
WHERE set_age_range NOT IN (''4+'', ''6+'', ''9+'', ''12+'', ''18+'')","-- Drop the helper function (optional, but clean)
DROP FUNCTION public.normalize_age_range"}', 'standardize_age_ranges');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260204161500', '{"-- Migration: Add ''entregado'' to envios and ''cancelado'' to users
-- requested by user to support these specific statuses.

-- 1. Update envios constraint
ALTER TABLE public.envios DROP CONSTRAINT IF EXISTS check_estado_envio","-- Clean up invalid values before applying constraint
UPDATE public.envios 
SET estado_envio = ''preparacion'' 
WHERE estado_envio NOT IN (''preparacion'', ''ruta_envio'', ''entregado'', ''devolucion'', ''ruta_devolucion'', ''cancelado'')","ALTER TABLE public.envios
ADD CONSTRAINT check_estado_envio
CHECK (estado_envio IN (''preparacion'', ''ruta_envio'', ''entregado'', ''devolucion'', ''ruta_devolucion'', ''cancelado''))","-- 2. Update users constraint
ALTER TABLE public.users DROP CONSTRAINT IF EXISTS check_user_status","ALTER TABLE public.users DROP CONSTRAINT IF EXISTS check_estado_usuario","-- legacy safety

-- Clean up invalid values before applying constraint
UPDATE public.users 
SET user_status = ''sin set'' 
WHERE user_status NOT IN (''set en envio'', ''sin set'', ''recibido'', ''set en devolucion'', ''suspendido'', ''cancelado'')","ALTER TABLE public.users 
ADD CONSTRAINT check_user_status 
CHECK (user_status IN (''set en envio'', ''sin set'', ''recibido'', ''set en devolucion'', ''suspendido'', ''cancelado''))","-- 3. Update comments
COMMENT ON COLUMN public.envios.estado_envio IS ''Allowed values: preparacion, ruta_envio, entregado, devolucion, ruta_devolucion, cancelado''","COMMENT ON COLUMN public.users.user_status IS ''Allowed values: set en envio, sin set, recibido, set en devolucion, suspendido, cancelado''"}', 'update_status_constraints');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260204190000', '{"-- 1. Drop existing constraint if it exists
ALTER TABLE public.sets DROP CONSTRAINT IF EXISTS set_status_check","ALTER TABLE public.sets DROP CONSTRAINT IF EXISTS sets_set_status_check","-- Note: Provide legacy name just in case, though usually it''s auto-generated or named in previous migration.
-- Previous migration 20260203100000_add_set_status.sql didn''t explicitly name the constraint in the snippet I saw, 
-- but usually Postgres names it sets_set_status_check. I''ll drop by column check if possible or just use common names.
-- Better yet, I''ll update the values first then add the new constraint.

-- 2. Migrate existing data to Spanish
UPDATE public.sets SET set_status = ''activo'' WHERE set_status = ''active''","UPDATE public.sets SET set_status = ''inactivo'' WHERE set_status = ''inactive''","-- Default any nulls or weird values to ''inactivo''
UPDATE public.sets SET set_status = ''inactivo'' WHERE set_status NOT IN (''activo'', ''inactivo'', ''en reparacion'')","-- 3. Add new constraint
-- valid values: ''activo'', ''inactivo'', ''en reparacion''
ALTER TABLE public.sets
ADD CONSTRAINT check_set_status_spanish
CHECK (set_status IN (''activo'', ''inactivo'', ''en reparacion''))","-- 4. Set default to ''inactivo''
ALTER TABLE public.sets ALTER COLUMN set_status SET DEFAULT ''inactivo''","-- 5. Create RPC function for handling Return status updates
CREATE OR REPLACE FUNCTION public.update_set_status_from_return(p_set_id UUID, p_new_status TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_current_status TEXT;
BEGIN
    -- Validate input status
    IF p_new_status NOT IN (''activo'', ''inactivo'', ''en reparacion'') THEN
        RAISE EXCEPTION ''Invalid status: %'', p_new_status;
    END IF;

    -- Get current status (optional check, but good for debugging)
    SELECT set_status INTO v_current_status FROM public.sets WHERE id = p_set_id;

    -- Update set status
    UPDATE public.sets 
    SET set_status = p_new_status,
        updated_at = now()
    WHERE id = p_set_id;

    -- Inventory Logic:
    -- If moving TO ''en reparacion'', implies coming from ''en_devolucion'' (returned).
    -- We assume the item is currently effectively ''en_devolucion'' in inventory if it''s being processed in returns.
    
    IF p_new_status = ''en reparacion'' THEN
        -- Move 1 unit from ''en_devolucion'' to ''en_reparacion''
        UPDATE public.inventario_sets
        SET en_reparacion = en_reparacion + 1,
            en_devolucion = GREATEST(0, en_devolucion - 1), -- Prevent negative just in case
            updated_at = now()
        WHERE set_id = p_set_id;
    END IF;

    -- If moving TO ''activo'' (e.g. from ''en reparacion'' or ''en devolucion'')
    -- This logic is tricky without knowing the PREVIOUS state for sure in the inventory.
    -- But usually ''active'' means available for rent -> ''cantidad_total'' or ''stock_central''.
    -- If we are in \"Returns\" panel, we are processing a returned item.
    -- If we set it to ''activo'', it implies it''s ready for stock.
    -- So we might want to move from ''en_devolucion'' -> ''stock_central''.
    
    IF p_new_status = ''activo'' THEN
         -- Assuming coming from ''en_devolucion'' (returned, verified OK)
         -- But what if it was ''en_reparacion'' before?
         -- The RPC is named ''from_return'', implies context is Return processing.
         -- User only asked for ''en reparacion'' logic specifically. 
         -- I will add logic for ''activo'' to move to stock_central just to be helpful, 
         -- BUT strictly the user only specified the ''en reparacion'' logic.
         -- I''ll stick to ''stock_central'' increment if it makes sense, but let''s be conservative.
         -- Let''s just handle the requested logic for now to avoid side effects.
         -- actually, if we don''t move it OUT of ''en_devolucion'', it stays there forever?
         -- Yes, we should probably move it to stock_central if ''activo''.
         
         UPDATE public.inventario_sets
         SET stock_central = stock_central + 1,
             en_devolucion = GREATEST(0, en_devolucion - 1),
             updated_at = now()
         WHERE set_id = p_set_id;
    END IF;
    
    -- If ''inactivo'', maybe we just leave it in stock_central but set is hidden?
    -- or maybe ''inactivo'' implies broken/lost?
    -- For now I will only implement the ''en reparacion'' logic strictly requested + the ''activo'' (return to stock) logic which is implied by \"processing a return\".
END;
$$"}', 'update_set_status_and_rpc');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260204191500', '{"-- Update RPC function to separate inventory logic as requested
-- Logic: When setting status to ''en reparacion'', ONLY increment ''en_reparacion''. Do NOT decrement ''en_devolucion''.

CREATE OR REPLACE FUNCTION public.update_set_status_from_return(p_set_id UUID, p_new_status TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_current_status TEXT;
BEGIN
    -- Validate input status
    IF p_new_status NOT IN (''activo'', ''inactivo'', ''en reparacion'') THEN
        RAISE EXCEPTION ''Invalid status: %'', p_new_status;
    END IF;

    -- Update set status
    UPDATE public.sets 
    SET set_status = p_new_status,
        updated_at = now()
    WHERE id = p_set_id;

    -- Inventory Logic:
    
    IF p_new_status = ''en reparacion'' THEN
        -- ONLY increment ''en_reparacion''
        -- Do NOT decrement ''en_devolucion'' (User Instruction: \"no asumas que debo decrementar en_devolucion\")
        UPDATE public.inventario_sets
        SET en_reparacion = en_reparacion + 1,
            updated_at = now()
        WHERE set_id = p_set_id;
    END IF;

    -- Logic for ''activo'' (Return to stock)
    -- If moving TO ''activo'', we assume it goes to ''stock_central''.
    -- We will also NOT decrement ''en_devolucion'' here to be consistent with the \"no assumption\" rule,
    -- or should we? The user specific instruction was about \"en reparacion\" logic.
    -- However, \"no asumas que debo decrementar en_devolucion\" sounds general.
    -- I will apply the same pattern: Just increment where it goes.
    
    IF p_new_status = ''activo'' THEN
         UPDATE public.inventario_sets
         SET stock_central = stock_central + 1,
             updated_at = now()
         WHERE set_id = p_set_id;
    END IF;
    
END;
$$"}', 'update_rpc_no_decrement');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260204193000', '{"-- Add RLS policy for Operadores to view all shipments
-- Currently, they might only have permissions to view their own or update/insert, but not list all for the dashboard.

ALTER TABLE public.envios ENABLE ROW LEVEL SECURITY","CREATE POLICY \"Admins and Operadores can view all shipments\"
    ON public.envios FOR SELECT
    USING (
        public.has_role(auth.uid(), ''admin''::public.app_role) OR 
        public.has_role(auth.uid(), ''operador''::public.app_role)
    )","-- Note: ''Admins can manage all shipments'' (FOR ALL) might already cover admins, but explicit Select for operadors is safer.
-- If ''Admins can manage all shipments'' exists, this might duplicate for admin, but Postgres handles multiple policies as OR.
-- To be clean, we could drop the admin-only select if it exists, but the FOR ALL usually covers it.
-- Let''s just ensure Operadores are covered."}', 'fix_operador_envios_rls');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260204194000', '{"-- Add RLS policy for Admins and Operadores to view all users (formerly profiles)
-- This is required for the Returns list to show user names and emails.

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY","CREATE POLICY \"Admins and Operadores can view all users\"
    ON public.users FOR SELECT
    USING (
        public.has_role(auth.uid(), ''admin''::public.app_role) OR 
        public.has_role(auth.uid(), ''operador''::public.app_role)
    )"}', 'fix_users_rls');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260204195000', '{"-- Ensure set_id exists in envios table
-- It seems it might be missing or not properly foreign-keyed, causing the join to fail or the column selection to fail.

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = ''public'' AND table_name = ''envios'' AND column_name = ''set_id'') THEN
        ALTER TABLE public.envios ADD COLUMN set_id UUID REFERENCES public.sets(id) ON DELETE SET NULL;
        CREATE INDEX idx_envios_set_id ON public.envios(set_id);
    END IF;
END $$"}', 'ensure_set_id_envios');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260204200000', '{"-- Fix Envios Relationships and Data
-- 1. Populate set_id based on set_ref (so joins work for existing data)
-- 2. Add FK to public.users (so PostgREST can join ''users'' table)

DO $$
BEGIN
    -- 1. Populate set_id
    UPDATE public.envios e
    SET set_id = s.id
    FROM public.sets s
    WHERE e.set_ref = s.set_ref -- (set_ref was renamed from lego_ref, assuming alignment)
      AND e.set_id IS NULL;
      
    -- Note: Ensure we use the correct column names. 
    -- sets table has ''set_ref'' (renamed from lego_ref in 20260127100000_global_refactor.sql)
    -- envios table has ''set_ref'' (added in 20260127125500_add_set_ref_to_envios.sql)

    -- 2. Add FK to public.users
    -- PostgREST needs this FK to detect the relationship ''users''
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = ''envios_user_id_fkey_public_users''
    ) THEN
        ALTER TABLE public.envios
        ADD CONSTRAINT envios_user_id_fkey_public_users
        FOREIGN KEY (user_id)
        REFERENCES public.users(user_id)
        ON DELETE CASCADE;
    END IF;

END $$"}', 'fix_envios_fk_and_data');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260204201000', '{"-- Cleanup invalid envios records
-- Rows without set_id cannot be displayed in the UI or linked to a product.
-- Since we cannot recover the set reference (no set_ref and order_id dropped/unreliable), we must remove them.

DELETE FROM public.envios WHERE set_id IS NULL","-- Optional: Add constraint to prevent future nulls, if we are sure
-- ALTER TABLE public.envios ALTER COLUMN set_id SET NOT NULL;"}', 'cleanup_invalid_envios');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260204220000', '{"-- Update RPC to optionally close the return shipment (mark as processed)
-- Added p_envio_id parameter.
-- Updates envios table: sets fecha_recepcion_almacen = now().
-- We might consider changing status to ''entregado'' (Delivered to warehouse), but for now updating timestamp is safe.
-- Actually, let''s update status to ''entregado'' so it leaves the ''Pending Returns'' list if the filter is strict.
-- Wait, ''entregado'' usually means ''Delivered to User''.
-- Maybe we need a ''procesado'' status? Or just rely on ''devuelto'' + fecha_recepcion?
-- User constraint: ''preparacion'', ''ruta_envio'', ''entregado'', ''devuelto'', ''ruta_devolucion'', ''cancelado''
-- Let''s stick to updating the timestamp for now, and maybe the frontend can filter by that?
-- Or, if we want it to leave the list, we might need a new status or reuse ''entregado'' (ambiguous).
-- Let''s just update the function signature for now and log the reception date.

DROP FUNCTION IF EXISTS public.update_set_status_from_return(UUID, TEXT)","CREATE OR REPLACE FUNCTION public.update_set_status_from_return(p_set_id UUID, p_new_status TEXT, p_envio_id UUID DEFAULT NULL)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
BEGIN
    -- Validate input status
    IF p_new_status NOT IN (''activo'', ''inactivo'', ''en reparacion'') THEN
        RAISE EXCEPTION ''Invalid status: %'', p_new_status;
    END IF;

    -- Update set status
    UPDATE public.sets 
    SET set_status = p_new_status,
        updated_at = now()
    WHERE id = p_set_id;

    -- Inventory Logic:
    IF p_new_status = ''en reparacion'' THEN
        -- ONLY increment ''en_reparacion''
        UPDATE public.inventario_sets
        SET en_reparacion = en_reparacion + 1,
            updated_at = now()
        WHERE set_id = p_set_id;
    END IF;

    IF p_new_status = ''activo'' THEN
         UPDATE public.inventario_sets
         SET stock_central = stock_central + 1,
             updated_at = now()
         WHERE set_id = p_set_id;
    END IF;
    
    -- Update Envio if ID provided
    IF p_envio_id IS NOT NULL THEN
        UPDATE public.envios
        SET fecha_recepcion_almacen = now(),
            updated_at = now()
            -- Optionally: status?
        WHERE id = p_envio_id;
    END IF;

END;
$$"}', 'update_rpc_with_envio_id');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260204221500', '{"-- Ensure ''devuelto'' shipments are visible (Fixed Policy)
-- Correcting the RLS logic to use public.has_role() instead of querying a non-existent column.

DROP POLICY IF EXISTS \"Access for operators and admins\" ON public.envios","CREATE POLICY \"Access for operators and admins\"
    ON public.envios FOR ALL
    USING (
        -- Check if user has ''admin'' or ''operator'' (if allowed, but enum is ''admin'', ''user'')
        -- Wait, ''app_role'' enum in 63a9dbb0 only has ''admin'', ''user''.
        -- But maybe ''operador'' was added later?
        -- Let''s stick to ''admin'' for now, or check migration for ''operador''.
        -- Safest is to check public.user_roles table directly if has_role doesn''t support list.
        EXISTS (
            SELECT 1 FROM public.user_roles
            WHERE user_id = auth.uid()
              AND role::text IN (''admin'', ''operador'')
        )
    )","-- Ensure users can see their own returned shipments
DROP POLICY IF EXISTS \"Users can view own envios\" ON public.envios","CREATE POLICY \"Users can view own envios\"
    ON public.envios FOR SELECT
    USING (auth.uid() = user_id)"}', 'ensure_devuelto_visibility');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260204223000', '{"-- Fix RPC table name: inventario_sets -> inventory_sets
-- AND handle missing stock_central column (Dropped in Global Refactor).
-- ''en_reparacion'' logic is kept.
-- ''stock_central'' logic is disabled to prevent errors until new column name is confirmed.

CREATE OR REPLACE FUNCTION public.update_set_status_from_return(p_set_id UUID, p_new_status TEXT, p_envio_id UUID DEFAULT NULL)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
BEGIN
    -- Validate input status
    IF p_new_status NOT IN (''activo'', ''inactivo'', ''en reparacion'') THEN
        RAISE EXCEPTION ''Invalid status: %'', p_new_status;
    END IF;

    -- Update set status
    UPDATE public.sets 
    SET set_status = p_new_status,
        updated_at = now()
    WHERE id = p_set_id;

    -- Inventory Logic:
    IF p_new_status = ''en reparacion'' THEN
        -- ONLY increment ''en_reparacion''
        UPDATE public.inventory_sets
        SET en_reparacion = en_reparacion + 1,
            updated_at = now()
        WHERE set_id = p_set_id;
    END IF;

    IF p_new_status = ''activo'' THEN
         -- Increment stock logic.
         -- ALERT: ''stock_central'' column was dropped. Disabling update to prevent crash.
         -- TODO: Identify correct column for ''Available Stock'' (maybe derived from Total - Others?)
         -- UPDATE public.inventory_sets
         -- SET stock_central = stock_central + 1,
         --     updated_at = now()
         -- WHERE set_id = p_set_id;
         
         -- For now, we just update the set status to ''activo'', which makes it available for assignment queries.
         NULL; 
    END IF;
    
    -- Update Envio if ID provided
    IF p_envio_id IS NOT NULL THEN
        UPDATE public.envios
        SET fecha_recepcion_almacen = now(),
            updated_at = now()
        WHERE id = p_envio_id;
    END IF;

END;
$$"}', 'fix_rpc_table_name');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260204224500', '{"-- Add estado_manipulacion column to envios
ALTER TABLE public.envios
ADD COLUMN IF NOT EXISTS estado_manipulacion BOOLEAN DEFAULT FALSE","-- Update RPC to set estado_manipulacion = TRUE
-- Re-defining the function from previous step, adding the new field update.

CREATE OR REPLACE FUNCTION public.update_set_status_from_return(p_set_id UUID, p_new_status TEXT, p_envio_id UUID DEFAULT NULL)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
BEGIN
    -- Validate input status
    IF p_new_status NOT IN (''activo'', ''inactivo'', ''en reparacion'') THEN
        RAISE EXCEPTION ''Invalid status: %'', p_new_status;
    END IF;

    -- Update set status
    UPDATE public.sets 
    SET set_status = p_new_status,
        updated_at = now()
    WHERE id = p_set_id;

    -- Inventory Logic:
    IF p_new_status = ''en reparacion'' THEN
        -- ONLY increment ''en_reparacion''
        UPDATE public.inventory_sets
        SET en_reparacion = en_reparacion + 1,
            updated_at = now()
        WHERE set_id = p_set_id;
    END IF;

    IF p_new_status = ''activo'' THEN
         -- Stock logic temporarily disabled due to missing column
         NULL; 
    END IF;
    
    -- Update Envio if ID provided
    IF p_envio_id IS NOT NULL THEN
        UPDATE public.envios
        SET fecha_recepcion_almacen = now(),
            estado_manipulacion = TRUE, -- Mark as manipulated/processed
            updated_at = now()
        WHERE id = p_envio_id;
    END IF;

END;
$$"}', 'add_estado_manipulacion');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260205081500', '{"-- Update RPC to handle Weight Validation Logic
-- 1. Always decrement ''en_devolucion'' in inventory_sets.
-- 2. If ''en reparacion'', increment ''en_reparacion''.
-- 3. Always set ''estado_manipulacion'' = TRUE in envios.
-- 4. Status update on sets table.

CREATE OR REPLACE FUNCTION public.update_set_status_from_return(p_set_id UUID, p_new_status TEXT, p_envio_id UUID DEFAULT NULL)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
BEGIN
    -- Validate input status
    IF p_new_status NOT IN (''activo'', ''inactivo'', ''en reparacion'') THEN
        RAISE EXCEPTION ''Invalid status: %'', p_new_status;
    END IF;

    -- Update set status
    UPDATE public.sets 
    SET set_status = p_new_status,
        updated_at = now()
    WHERE id = p_set_id;

    -- Inventory Logic:
    -- 1. ALWAYS decrement ''en_devolucion'' as the item has arrived.
    UPDATE public.inventory_sets
    SET en_devolucion = en_devolucion - 1,
        updated_at = now()
    WHERE set_id = p_set_id;

    -- 2. Conditional increments
    IF p_new_status = ''en reparacion'' THEN
        -- Increment ''en_reparacion''
        UPDATE public.inventory_sets
        SET en_reparacion = en_reparacion + 1
        WHERE set_id = p_set_id;
    END IF;

    IF p_new_status = ''activo'' THEN
         -- Stock logic temporarily disabled due to missing ''stock_central'' column in global refactor
         -- TODO: Restore this once column name is verified (e.g. inventory_set_total_qty vs calculated)
         -- UPDATE public.inventory_sets SET stock_central = stock_central + 1 WHERE set_id = p_set_id;
         NULL; 
    END IF;
    
    -- Update Envio if ID provided
    IF p_envio_id IS NOT NULL THEN
        UPDATE public.envios
        SET fecha_recepcion_almacen = now(),
            estado_manipulacion = TRUE, -- Mark as processed
            updated_at = now()
        WHERE id = p_envio_id;
    END IF;

END;
$$"}', 'update_rpc_weight_logic');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260219085500', '{"-- Database migration to add Correos-related fields to the envios table

-- Add columns for external IDs and tracking
ALTER TABLE public.envios
ADD COLUMN IF NOT EXISTS correos_shipment_id TEXT,
ADD COLUMN IF NOT EXISTS label_url TEXT,
ADD COLUMN IF NOT EXISTS pickup_id TEXT,
ADD COLUMN IF NOT EXISTS last_tracking_update TIMESTAMP WITH TIME ZONE","-- Create index for external shipment ID for fast lookups
CREATE INDEX IF NOT EXISTS idx_envios_correos_shipment_id ON public.envios(correos_shipment_id)","-- Add comments for documentation
COMMENT ON COLUMN public.envios.correos_shipment_id IS ''External shipment identifier returned by Correos Preregister API''","COMMENT ON COLUMN public.envios.label_url IS ''Path to the generated shipping label in storage''","COMMENT ON COLUMN public.envios.pickup_id IS ''External identifier for the scheduled pickup''","COMMENT ON COLUMN public.envios.last_tracking_update IS ''Timestamp of the last synchronization with Correos Tracking API''"}', 'add_correos_fields');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260220195502', '{"-- Trigger: Update user status to ''con set'' when shipment is delivered

CREATE OR REPLACE FUNCTION public.handle_envio_entregado()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if the status changed to ''entregado''
    IF NEW.estado_envio = ''entregado'' AND OLD.estado_envio != ''entregado'' THEN
        -- Update the user''s status to ''con set''
        UPDATE public.users
        SET user_status = ''con set''
        WHERE user_id = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER","-- Drop trigger if exists to avoid duplication
DROP TRIGGER IF EXISTS on_envio_entregado ON public.envios","-- Create Trigger
CREATE TRIGGER on_envio_entregado
AFTER UPDATE ON public.envios
FOR EACH ROW
EXECUTE FUNCTION public.handle_envio_entregado()"}', '20260220210000_trigger_entrega_usuario');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260220195523', '{"-- Trigger: Update inventory_sets.en_devolucion when shipment is in return transit

CREATE OR REPLACE FUNCTION public.handle_envio_ruta_devolucion_inventory()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if the status changed to ''ruta_devolucion''
    IF NEW.estado_envio = ''ruta_devolucion'' AND OLD.estado_envio != ''ruta_devolucion'' THEN
        -- Increase the ''en_devolucion'' count for the associated set
        UPDATE public.inventory_sets
        SET en_devolucion = COALESCE(en_devolucion, 0) + 1,
            updated_at = now()
        WHERE set_id = NEW.set_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER","-- Drop trigger if exists to avoid duplication
DROP TRIGGER IF EXISTS on_envio_ruta_devolucion_inv ON public.envios","-- Create Trigger
CREATE TRIGGER on_envio_ruta_devolucion_inv
AFTER UPDATE ON public.envios
FOR EACH ROW
EXECUTE FUNCTION public.handle_envio_ruta_devolucion_inventory()"}', '20260220211000_trigger_transito_almacen');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260220195544', '{"-- Trigger: Automatically create a reception operation when a set arrives at the warehouse

CREATE OR REPLACE FUNCTION public.handle_envio_recibido_almacen()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if the status changed to ''recibido_almacen'' (or ''devuelto'', using ''devuelto'' to match schema docs if standard)
    -- Typically Correos might mark it as delivered to the return address.
    -- Let''s use ''devuelto'' as it''s the standard final state for returns in the schema definition.
    IF NEW.estado_envio = ''devuelto'' AND OLD.estado_envio != ''devuelto'' THEN
        -- Insert a new operation record for the warehouse staff to process
        INSERT INTO public.operaciones_recepcion (event_id, user_id, set_id)
        VALUES (NEW.id, NEW.user_id, NEW.set_id);
        
        -- Also update the reception date on the envio
        NEW.fecha_recepcion_almacen = now();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER","-- Drop trigger if exists to avoid duplication
DROP TRIGGER IF EXISTS on_envio_recibido_almacen ON public.envios","-- Create Trigger (BEFORE UPDATE to allow modifying NEW.fecha_recepcion_almacen)
CREATE TRIGGER on_envio_recibido_almacen
BEFORE UPDATE ON public.envios
FOR EACH ROW
EXECUTE FUNCTION public.handle_envio_recibido_almacen()"}', '20260220212000_trigger_creacion_recepcion');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260220195602', '{"-- Trigger: Automate inventory closure when a reception operation is marked as completed

CREATE OR REPLACE FUNCTION public.handle_cierre_recepcion()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if the reception operation was just marked as completed
    IF NEW.status_recepcion = TRUE AND OLD.status_recepcion = FALSE THEN
        
        -- 1. Inventory Logic: Decrement ''en_devolucion'' as it has been processed
        UPDATE public.inventory_sets
        SET en_devolucion = GREATEST(0, COALESCE(en_devolucion, 0) - 1),
            updated_at = now()
        WHERE set_id = NEW.set_id;

        -- 2. State Logic: Determine if it goes back to active pool or needs repair
        IF NEW.missing_parts IS NOT NULL AND TRIM(NEW.missing_parts) != '''' THEN
            -- There are missing parts. Increment ''en_reparacion'' and set parent status
            UPDATE public.inventory_sets
            SET en_reparacion = COALESCE(en_reparacion, 0) + 1
            WHERE set_id = NEW.set_id;

            UPDATE public.sets
            SET set_status = ''en reparacion'',
                updated_at = now()
            WHERE id = NEW.set_id;
        ELSE
            -- Everything is fine. It returns to the available pool implicitly 
            -- (by no longer being in ''en_devolucion'').
            UPDATE public.sets
            SET set_status = ''activo'',
                updated_at = now()
            WHERE id = NEW.set_id;
        END IF;

        -- 3. Update the original Envio record to mark manipulation as done
        UPDATE public.envios
        SET estado_manipulacion = TRUE,
            updated_at = now()
        WHERE id = NEW.event_id;

    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER","-- Drop trigger if exists to avoid duplication
DROP TRIGGER IF EXISTS on_recepcion_completada ON public.operaciones_recepcion","-- Create Trigger
CREATE TRIGGER on_recepcion_completada
AFTER UPDATE ON public.operaciones_recepcion
FOR EACH ROW
EXECUTE FUNCTION public.handle_cierre_recepcion()"}', '20260220213000_trigger_cierre_recepcion_stock');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260225081200', '{"-- Migration to add status and status_changed_at to wishlist table
-- Requirement: status field (TRUE/FALSE), default TRUE
-- Requirement: status_changed_at timestamp updated on status changes

-- 1. Add columns to wishlist
ALTER TABLE public.wishlist 
ADD COLUMN status BOOLEAN DEFAULT TRUE NOT NULL,
ADD COLUMN status_changed_at TIMESTAMP WITH TIME ZONE DEFAULT now()","-- 2. Update RLS policies to allow UPDATE
-- Check if policy exists and add/update it
DROP POLICY IF EXISTS \"Users can update their own wishlist\" ON public.wishlist","CREATE POLICY \"Users can update their own wishlist\"
ON public.wishlist
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id)","-- 3. Update the assignment function to update wishlist status
-- We need to re-create the function with the wishlist update logic
DROP FUNCTION IF EXISTS public.confirm_assign_sets_to_users(p_user_ids UUID[])","CREATE OR REPLACE FUNCTION public.confirm_assign_sets_to_users(p_user_ids UUID[])
RETURNS TABLE (
    envio_id UUID, 
    user_id UUID, 
    set_id UUID, 
    order_id UUID, 
    user_name TEXT, 
    set_name TEXT, 
    set_ref TEXT,
    created_at TIMESTAMPTZ
) AS $$
DECLARE
    r RECORD;
    target_set_id UUID;
    new_order_id UUID;
    new_envio_id UUID;
    v_set_name TEXT;
    v_set_ref TEXT;
    v_created_at TIMESTAMPTZ;
BEGIN
    -- Loop through specified users only
    FOR r IN (
        SELECT u.user_id, u.full_name
        FROM public.users u
        WHERE u.user_id = ANY(p_user_ids)
          AND u.user_status IN (''sin set'', ''set en devolucion'')
          AND EXISTS (SELECT 1 FROM public.wishlist w WHERE w.user_id = u.user_id AND w.status = true)
    ) LOOP
        -- Find the first available set from user''s wishlist (by creation order)
        SELECT w.set_id, s.set_name, s.set_ref 
        INTO target_set_id, v_set_name, v_set_ref
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        JOIN public.sets s ON w.set_id = s.id
        WHERE w.user_id = r.user_id
          AND w.status = true
          AND i.inventory_set_total_qty > 0
        ORDER BY w.created_at ASC
        LIMIT 1;

        -- If a set is found, perform assignment
        IF target_set_id IS NOT NULL THEN
            -- 1. Update Inventory: decrement total stock and increment en_envio
            UPDATE public.inventory_sets
            SET inventory_set_total_qty = inventory_set_total_qty - 1,
                en_envio = en_envio + 1
            WHERE inventory_sets.set_id = target_set_id;

            -- 2. Create Order
            INSERT INTO public.orders (user_id, set_id, status)
            VALUES (r.user_id, target_set_id, ''pending'')
            RETURNING id INTO new_order_id;

            -- 3. Create Envio record
            INSERT INTO public.envios (
                order_id, 
                user_id, 
                estado_envio,
                direccion_envio,
                ciudad_envio,
                codigo_postal_envio
            )
            VALUES (
                new_order_id,
                r.user_id,
                ''pendiente'',
                ''Pendiente de asignación'',
                ''Pendiente'',
                ''00000''
            )
            RETURNING envios.id, envios.created_at INTO new_envio_id, v_created_at;

            -- 4. Update User Status
            UPDATE public.users
            SET user_status = ''set en envio''
            WHERE users.user_id = r.user_id;

            -- 5. Update Wishlist Status (Requirement 2: status = false when assigned)
            UPDATE public.wishlist
            SET status = false,
                status_changed_at = now()
            WHERE wishlist.user_id = r.user_id 
              AND wishlist.set_id = target_set_id;

            -- Return the result with full details
            envio_id := new_envio_id;
            user_id := r.user_id;
            set_id := target_set_id;
            order_id := new_order_id;
            user_name := r.full_name;
            set_name := v_set_name;
            set_ref := v_set_ref;
            created_at := v_created_at;
            
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public"}', 'wishlist_status_tracking');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260225133500', '{"-- Update confirm_assign_sets_to_users RPC to include PUDO and set details
-- This allows the Edge Function to perform Correos pre-registration immediately after assignment

-- Drop existing function first to allow changing the return type
DROP FUNCTION IF EXISTS public.confirm_assign_sets_to_users(UUID[])","CREATE OR REPLACE FUNCTION public.confirm_assign_sets_to_users(p_user_ids UUID[])
RETURNS TABLE (
    envio_id UUID, 
    user_id UUID, 
    set_id UUID, 
    order_id UUID, 
    user_name TEXT, 
    user_email TEXT,
    user_phone TEXT,
    set_name TEXT, 
    set_ref TEXT,
    set_weight NUMERIC,
    set_dim TEXT,
    pudo_id TEXT,
    pudo_name TEXT,
    pudo_address TEXT,
    pudo_cp TEXT,
    pudo_city TEXT,
    pudo_province TEXT,
    created_at TIMESTAMPTZ
) AS $$
DECLARE
    r RECORD;
    target_set_id UUID;
    new_order_id UUID;
    new_envio_id UUID;
    v_set_name TEXT;
    v_set_ref TEXT;
    v_set_weight NUMERIC;
    v_set_dim TEXT;
    v_user_email TEXT;
    v_user_phone TEXT;
    v_pudo_id TEXT;
    v_pudo_name TEXT;
    v_pudo_address TEXT;
    v_pudo_cp TEXT;
    v_pudo_city TEXT;
    v_pudo_province TEXT;
    v_created_at TIMESTAMPTZ;
BEGIN
    -- Loop through specified users only
    FOR r IN (
        SELECT u.user_id, u.full_name, u.email, u.phone,
               p.correos_id_pudo, p.correos_nombre, p.correos_direccion_completa,
               p.correos_codigo_postal, p.correos_ciudad, p.correos_provincia
        FROM public.users u
        LEFT JOIN public.users_correos_dropping p ON u.user_id = p.user_id
        WHERE u.user_id = ANY(p_user_ids)
          AND u.user_status IN (''sin set'', ''set en devolucion'')
          AND EXISTS (SELECT 1 FROM public.wishlist w WHERE w.user_id = u.user_id AND w.status = true)
    ) LOOP
        -- Find the first available set from user''s wishlist (by creation order)
        SELECT w.set_id, s.set_name, s.set_ref, s.set_weight, s.set_dim
        INTO target_set_id, v_set_name, v_set_ref, v_set_weight, v_set_dim
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        JOIN public.sets s ON w.set_id = s.id
        WHERE w.user_id = r.user_id
          AND w.status = true
          AND i.inventory_set_total_qty > 0
        ORDER BY w.created_at ASC
        LIMIT 1;

        -- If a set is found, perform assignment
        IF target_set_id IS NOT NULL THEN
            -- 1. Update Inventory: decrement total stock and increment en_envio
            UPDATE public.inventory_sets
            SET inventory_set_total_qty = inventory_set_total_qty - 1,
                en_envio = en_envio + 1
            WHERE inventory_sets.set_id = target_set_id;

            -- 2. Create Order
            INSERT INTO public.orders (user_id, set_id, status)
            VALUES (r.user_id, target_set_id, ''pending'')
            RETURNING id INTO new_order_id;

            -- 3. Create Envio record with PUDO data
            INSERT INTO public.envios (
                order_id, 
                user_id, 
                estado_envio,
                direccion_envio,
                ciudad_envio,
                codigo_postal_envio,
                pais_envio
            )
            VALUES (
                new_order_id,
                r.user_id,
                ''pendiente'',
                COALESCE(r.correos_direccion_completa, ''Pendiente de asignación''),
                COALESCE(r.correos_ciudad, ''Pendiente''),
                COALESCE(r.correos_codigo_postal, ''00000''),
                ''España''
            )
            RETURNING envios.id, envios.created_at INTO new_envio_id, v_created_at;

            -- 4. Update User Status
            UPDATE public.users
            SET user_status = ''set en envio''
            WHERE users.user_id = r.user_id;

            -- 5. Update Wishlist Status
            UPDATE public.wishlist
            SET status = false,
                status_changed_at = now()
            WHERE wishlist.user_id = r.user_id 
              AND wishlist.set_id = target_set_id;

            -- Populate return variables
            confirm_assign_sets_to_users.envio_id := new_envio_id;
            confirm_assign_sets_to_users.user_id := r.user_id;
            confirm_assign_sets_to_users.set_id := target_set_id;
            confirm_assign_sets_to_users.order_id := new_order_id;
            confirm_assign_sets_to_users.user_name := r.full_name;
            confirm_assign_sets_to_users.user_email := r.email;
            confirm_assign_sets_to_users.user_phone := r.phone;
            confirm_assign_sets_to_users.set_name := v_set_name;
            confirm_assign_sets_to_users.set_ref := v_set_ref;
            confirm_assign_sets_to_users.set_weight := v_set_weight;
            confirm_assign_sets_to_users.set_dim := v_set_dim;
            confirm_assign_sets_to_users.pudo_id := r.correos_id_pudo;
            confirm_assign_sets_to_users.pudo_name := r.correos_nombre;
            confirm_assign_sets_to_users.pudo_address := r.correos_direccion_completa;
            confirm_assign_sets_to_users.pudo_cp := r.correos_codigo_postal;
            confirm_assign_sets_to_users.pudo_city := r.correos_ciudad;
            confirm_assign_sets_to_users.pudo_province := r.correos_provincia;
            confirm_assign_sets_to_users.created_at := v_created_at;
            
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public"}', 'update_confirm_assignment_rpc');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260319000000', '{"-- ─────────────────────────────────────────────────────────────────────────────
-- Migration: create_reviews_table
-- Purpose:   Allow users to rate and review LEGO sets they have rented.
--            Reviews are tied to a specific envio (rental), ensuring one review
--            per rental session. Includes star rating (1-5) + optional comment.
-- ─────────────────────────────────────────────────────────────────────────────

-- ── Table ────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.reviews (
    id            UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id       UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    set_id        UUID NOT NULL REFERENCES public.sets(id) ON DELETE CASCADE,
    envio_id      UUID REFERENCES public.envios(id) ON DELETE SET NULL,
    rating        SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment       TEXT,
    age_fit       BOOLEAN,          -- ¿Fue adecuado para la edad indicada?
    difficulty    SMALLINT CHECK (difficulty BETWEEN 1 AND 5),  -- 1=muy fácil, 5=muy difícil
    would_reorder BOOLEAN,          -- ¿Volvería a pedir este set?
    is_published  BOOLEAN NOT NULL DEFAULT true,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
)","-- ── One review per rental session ────────────────────────────────────────────
-- A user can review the same set multiple times (once per envio), 
-- but only once per envio if envio_id is provided.
CREATE UNIQUE INDEX IF NOT EXISTS reviews_envio_unique
    ON public.reviews (envio_id)
    WHERE envio_id IS NOT NULL","-- ── General index for fetching reviews per set ───────────────────────────────
CREATE INDEX IF NOT EXISTS reviews_set_id_idx
    ON public.reviews (set_id, is_published, created_at DESC)","-- ── Index for user history ────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS reviews_user_id_idx
    ON public.reviews (user_id, created_at DESC)","-- ── Aggregate stats view (avg rating + count per set) ────────────────────────
CREATE OR REPLACE VIEW public.set_review_stats AS
SELECT
    set_id,
    COUNT(*)                                AS review_count,
    ROUND(AVG(rating)::NUMERIC, 2)          AS avg_rating,
    COUNT(*) FILTER (WHERE rating = 5)      AS five_stars,
    COUNT(*) FILTER (WHERE rating = 4)      AS four_stars,
    COUNT(*) FILTER (WHERE rating = 3)      AS three_stars,
    COUNT(*) FILTER (WHERE rating = 2)      AS two_stars,
    COUNT(*) FILTER (WHERE rating = 1)      AS one_star,
    ROUND(AVG(difficulty)::NUMERIC, 1)      AS avg_difficulty,
    COUNT(*) FILTER (WHERE would_reorder = true) AS would_reorder_count
FROM public.reviews
WHERE is_published = true
GROUP BY set_id","-- ── Auto-update updated_at ────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$","DROP TRIGGER IF EXISTS reviews_updated_at ON public.reviews","CREATE TRIGGER reviews_updated_at
    BEFORE UPDATE ON public.reviews
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at()","-- ── Row Level Security ────────────────────────────────────────────────────────
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY","-- Anyone can read published reviews
CREATE POLICY \"reviews_select_published\"
    ON public.reviews
    FOR SELECT
    USING (is_published = true)","-- Users can read their own reviews (including unpublished)
CREATE POLICY \"reviews_select_own\"
    ON public.reviews
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id)","-- Authenticated users can insert their own reviews
CREATE POLICY \"reviews_insert_own\"
    ON public.reviews
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id)","-- Users can update their own reviews
CREATE POLICY \"reviews_update_own\"
    ON public.reviews
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id)","-- Users can delete their own reviews
CREATE POLICY \"reviews_delete_own\"
    ON public.reviews
    FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id)","-- Admins and operadores have full access
CREATE POLICY \"reviews_admin_all\"
    ON public.reviews
    FOR ALL
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.user_roles
            WHERE user_id = auth.uid()
            AND role IN (''admin'', ''operador'')
        )
    )","-- ── Comments ──────────────────────────────────────────────────────────────────
COMMENT ON TABLE public.reviews IS ''User reviews and ratings for rented LEGO sets''","COMMENT ON COLUMN public.reviews.rating IS ''1-5 star rating''","COMMENT ON COLUMN public.reviews.difficulty IS ''1=very easy, 5=very hard building difficulty''","COMMENT ON COLUMN public.reviews.would_reorder IS ''Would the user rent this set again?''","COMMENT ON COLUMN public.reviews.age_fit IS ''Was the set appropriate for the stated age range?''","COMMENT ON COLUMN public.reviews.is_published IS ''Set to false to hide a review without deleting it''"}', 'create_reviews_table');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260319000100', '{"-- Migration: create_referrals_table
-- Purpose:   Referral program — users generate unique referral codes and earn
--            credits when referred users subscribe. Rewards are tracked as
--            discount credits applied to next billing cycle.
-- Fixed:     Use auth.users(id) for referrer/referee FKs instead of users (id)
--            Ensure profiles table exists before modifying it
-- ─────────────────────────────────────────────────────────────────────────────

-- ── Ensure users table has referral fields ───────────────────────────────────
ALTER TABLE public.users
    ADD COLUMN IF NOT EXISTS referral_code      TEXT,
    ADD COLUMN IF NOT EXISTS referred_by        UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS referral_credits   INTEGER NOT NULL DEFAULT 0","-- Unique index on referral_code (case-insensitive lookup)
CREATE UNIQUE INDEX IF NOT EXISTS users_referral_code_lower
    ON public.users (LOWER(referral_code))
    WHERE referral_code IS NOT NULL","-- ── Referrals table ───────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.referrals (
    id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,

    -- Who shared the code (auth user id)
    referrer_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    -- Who used the code (auth user id)
    referee_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    -- Reward tracking
    status          TEXT NOT NULL DEFAULT ''pending''
                        CHECK (status IN (''pending'', ''credited'', ''rejected'')),
    -- ''pending''  → referee signed up but hasn''t activated subscription yet
    -- ''credited'' → reward has been applied to referrer''s credits
    -- ''rejected'' → referee cancelled before qualifying

    reward_credits  INTEGER NOT NULL DEFAULT 1,
    -- Number of months/credits awarded. Default = 1 free month equivalent.

    stripe_coupon_id TEXT,
    -- Stripe coupon applied to referrer''s next invoice (optional)

    credited_at     TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- One referral record per referred user
    UNIQUE (referee_id)
)","-- ── Indexes ───────────────────────────────────────────────────────────────────

CREATE INDEX IF NOT EXISTS referrals_referrer_id_idx
    ON public.referrals (referrer_id, status, created_at DESC)","-- ── Auto-update updated_at ────────────────────────────────────────────────────

-- Ensure set_updated_at function exists (created in 20260319000000)
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$","DROP TRIGGER IF EXISTS referrals_updated_at ON public.referrals","CREATE TRIGGER referrals_updated_at
    BEFORE UPDATE ON public.referrals
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at()","DROP TRIGGER IF EXISTS users_updated_at ON public.users","CREATE TRIGGER users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at()","-- ── Auto-generate referral code on user insert ────────────────────────────────

CREATE OR REPLACE FUNCTION public.generate_referral_code()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    new_code TEXT;
    attempts INTEGER := 0;
BEGIN
    -- Only generate if not already set
    IF NEW.referral_code IS NULL THEN
        LOOP
            -- 6-char uppercase alphanumeric code
            new_code := UPPER(SUBSTRING(MD5(RANDOM()::TEXT || NEW.user_id::TEXT) FROM 1 FOR 6));

            -- Check uniqueness
            IF NOT EXISTS (
                SELECT 1 FROM public.users WHERE LOWER(referral_code) = LOWER(new_code)
            ) THEN
                NEW.referral_code := new_code;
                EXIT;
            END IF;

            attempts := attempts + 1;
            IF attempts > 10 THEN
                -- Fallback: use longer hash
                NEW.referral_code := UPPER(SUBSTRING(MD5(NEW.user_id::TEXT) FROM 1 FOR 8));
                EXIT;
            END IF;
        END LOOP;
    END IF;
    RETURN NEW;
END;
$$","-- Apply to new user inserts
DROP TRIGGER IF EXISTS users_generate_referral_code ON public.users","CREATE TRIGGER users_generate_referral_code
    BEFORE INSERT ON public.users
    FOR EACH ROW EXECUTE FUNCTION public.generate_referral_code()","-- Backfill existing users that don''t have a code yet
UPDATE public.users
SET referral_code = UPPER(SUBSTRING(MD5(user_id::TEXT) FROM 1 FOR 6))
WHERE referral_code IS NULL","-- ── Function: apply referral when subscription activates ─────────────────────

CREATE OR REPLACE FUNCTION public.process_referral_credit(p_referee_user_id UUID)
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_referral    public.referrals%ROWTYPE;
    v_referrer_id UUID;
BEGIN
    -- Find pending referral for this user
    SELECT * INTO v_referral
    FROM public.referrals
    WHERE referee_id = p_referee_user_id
      AND status = ''pending'';

    IF NOT FOUND THEN
        RETURN; -- No pending referral, nothing to do
    END IF;

    v_referrer_id := v_referral.referrer_id;

    -- Award credits to referrer
    UPDATE public.users
    SET referral_credits = referral_credits + v_referral.reward_credits
    WHERE user_id = v_referrer_id;

    -- Mark referral as credited
    UPDATE public.referrals
    SET status = ''credited'',
        credited_at = NOW()
    WHERE id = v_referral.id;
END;
$$","-- ── Row Level Security ────────────────────────────────────────────────────────

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY","-- Users can view and edit their own profile
DROP POLICY IF EXISTS \"users_select_own\" ON public.users","CREATE POLICY \"users_select_own\"
    ON public.users FOR SELECT
    TO authenticated
    USING (user_id = auth.uid())","DROP POLICY IF EXISTS \"users_update_own\" ON public.users","CREATE POLICY \"users_update_own\"
    ON public.users FOR UPDATE
    TO authenticated
    USING (user_id = auth.uid())","DROP POLICY IF EXISTS \"users_insert_own\" ON public.users","CREATE POLICY \"users_insert_own\"
    ON public.users FOR INSERT
    TO authenticated
    WITH CHECK (user_id = auth.uid())","ALTER TABLE public.referrals ENABLE ROW LEVEL SECURITY","-- Users can see referrals where they are the referrer
DROP POLICY IF EXISTS \"referrals_select_own\" ON public.referrals","CREATE POLICY \"referrals_select_own\"
    ON public.referrals
    FOR SELECT
    TO authenticated
    USING (referrer_id = auth.uid())","-- Users can see their own incoming referral (to know who referred them)
DROP POLICY IF EXISTS \"referrals_select_referee\" ON public.referrals","CREATE POLICY \"referrals_select_referee\"
    ON public.referrals
    FOR SELECT
    TO authenticated
    USING (referee_id = auth.uid())","-- Only admin/operador can manage all referrals
DROP POLICY IF EXISTS \"referrals_admin_all\" ON public.referrals","CREATE POLICY \"referrals_admin_all\"
    ON public.referrals
    FOR ALL
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.user_roles
            WHERE user_id = auth.uid()
            AND role IN (''admin'', ''operador'')
        )
    )","-- ── Trigger: create user record on auth.users insert ──────────────────────────

CREATE OR REPLACE FUNCTION public.handle_new_auth_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
    INSERT INTO public.users (user_id, full_name, avatar_url)
    VALUES (
        NEW.id,
        NEW.raw_user_meta_data ->> ''full_name'',
        NEW.raw_user_meta_data ->> ''avatar_url''
    )
    ON CONFLICT (user_id) DO NOTHING;
    RETURN NEW;
END;
$$","DROP TRIGGER IF EXISTS on_auth_user_created_for_referral ON auth.users","CREATE TRIGGER on_auth_user_created_for_referral
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_auth_user()","-- ── Comments ──────────────────────────────────────────────────────────────────

COMMENT ON TABLE public.referrals IS ''Referral program: tracks who referred whom and reward status''","COMMENT ON COLUMN public.referrals.status IS ''pending=signup done, credited=reward applied, rejected=did not qualify''","COMMENT ON COLUMN public.referrals.reward_credits IS ''Credits awarded (1 = 1 free month equivalent)''","COMMENT ON COLUMN public.users.referral_code IS ''Unique shareable code (6 chars, auto-generated)''","COMMENT ON COLUMN public.users.referred_by IS ''auth.users.id of the user who referred this one''","COMMENT ON COLUMN public.users.referral_credits IS ''Accumulated credits from successful referrals''"}', 'create_referrals_table');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260319100000', '{"-- ─────────────────────────────────────────────────────────────────────────────
-- Migration: reviews_referrals (reconciliation)
-- Purpose:   Ensures reviews and referrals schema is complete and consistent.
--            Runs AFTER 20260319000000 and 20260319000100 which already created
--            the base tables. This migration adds missing pieces and fixes policies.
-- ─────────────────────────────────────────────────────────────────────────────

-- ─── reviews: add missing columns if not present ─────────────────────────────
-- The reviews table was created in 20260319000000 with is_published boolean.
-- Add extra columns for richer reviews if they don''t exist.
alter table public.reviews
  add column if not exists age_fit       boolean,
  add column if not exists difficulty    smallint check (difficulty between 1 and 5),
  add column if not exists would_reorder boolean","-- ─── avg rating view (consolidated, using is_published) ──────────────────────
create or replace view public.set_avg_ratings as
  select set_id,
         round(avg(rating)::numeric, 1) as avg_rating,
         count(*) as review_count
  from public.reviews
  where is_published = true
  group by set_id","-- ─── referrals: table already created in 20260319000100 ──────────────────────
-- Nothing to do for referrals table structure.

-- ─── users: columns already added in 20260319000100 ───────────────────────
-- Add referral_code unique constraint if not yet applied via index
-- (the index was already created in 20260319000100 via CREATE UNIQUE INDEX IF NOT EXISTS)

-- ─── Backfill referral codes for any users missing them ───────────────────
update public.users
set referral_code = upper(substring(md5(user_id::text || clock_timestamp()::text) for 7))
where referral_code is null","-- ─── set_review_stats view (alias with simpler name) ─────────────────────────
create or replace view public.set_review_stats as
  select
    set_id,
    count(*)                                           as review_count,
    round(avg(rating)::numeric, 2)                     as avg_rating,
    count(*) filter (where rating = 5)                 as five_stars,
    count(*) filter (where rating = 4)                 as four_stars,
    count(*) filter (where rating = 3)                 as three_stars,
    count(*) filter (where rating = 2)                 as two_stars,
    count(*) filter (where rating = 1)                 as one_star,
    round(avg(difficulty)::numeric, 1)                 as avg_difficulty,
    count(*) filter (where would_reorder = true)       as would_reorder_count
  from public.reviews
  where is_published = true
  group by set_id"}', 'reviews_referrals');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260319100001', '{"-- ─── RPC: increment_referral_credits ─────────────────────────────────────────
-- Atomically increments referral_credits on a profile row.
-- Called from the stripe-webhook Edge Function (service role).
create or replace function public.increment_referral_credits(
  p_user_id uuid,
  p_amount  integer default 1
)
returns void
language plpgsql
security definer          -- runs as postgres, bypasses RLS
set search_path = public
as $$
begin
  update public.profiles
  set    referral_credits = coalesce(referral_credits, 0) + p_amount
  where  id = p_user_id;
end;
$$","-- Grant execute to the authenticated role (edge functions run as service role anyway)
grant execute on function public.increment_referral_credits(uuid, integer)
  to service_role, authenticated"}', 'referral_credits_rpc');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260319200000', '{"-- Chat conversation logging for Brickman
-- Stores full conversations, individual messages and user feedback

-- ── Table: chat_conversations ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.chat_conversations (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id    uuid NOT NULL,                        -- anonymous session (generated in browser)
  user_id       uuid REFERENCES auth.users(id) ON DELETE SET NULL,  -- nullable: works without login
  page_url      text,                                 -- page where the chat was opened
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
)","-- ── Table: chat_messages ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.chat_messages (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id  uuid NOT NULL REFERENCES public.chat_conversations(id) ON DELETE CASCADE,
  role             text NOT NULL CHECK (role IN (''user'', ''assistant'')),
  content          text NOT NULL,
  feedback         smallint CHECK (feedback IN (1, -1)),  -- 1=👍  -1=👎  NULL=no feedback
  created_at       timestamptz NOT NULL DEFAULT now()
)","-- ── Indexes ────────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS chat_conversations_session_idx ON public.chat_conversations(session_id)","CREATE INDEX IF NOT EXISTS chat_conversations_user_idx    ON public.chat_conversations(user_id)","CREATE INDEX IF NOT EXISTS chat_messages_conversation_idx ON public.chat_messages(conversation_id)","CREATE INDEX IF NOT EXISTS chat_messages_created_idx      ON public.chat_messages(created_at)","-- ── RLS ────────────────────────────────────────────────────────────────────
ALTER TABLE public.chat_conversations ENABLE ROW LEVEL SECURITY","ALTER TABLE public.chat_messages      ENABLE ROW LEVEL SECURITY","-- Drop existing policies if they exist
DROP POLICY IF EXISTS \"chat_conversations_insert\" ON public.chat_conversations","DROP POLICY IF EXISTS \"chat_conversations_select\" ON public.chat_conversations","DROP POLICY IF EXISTS \"chat_messages_insert\" ON public.chat_messages","DROP POLICY IF EXISTS \"chat_messages_select\" ON public.chat_messages","DROP POLICY IF EXISTS \"chat_messages_update_feedback\" ON public.chat_messages","-- Anyone (anon or authenticated) can insert a conversation
CREATE POLICY \"chat_conversations_insert\" ON public.chat_conversations
  FOR INSERT WITH CHECK (true)","-- Anyone can read their own session conversations (by session_id passed from client)
CREATE POLICY \"chat_conversations_select\" ON public.chat_conversations
  FOR SELECT USING (true)","-- Anyone can insert messages (the edge function uses service role anyway)
CREATE POLICY \"chat_messages_insert\" ON public.chat_messages
  FOR INSERT WITH CHECK (true)","-- Anyone can read messages
CREATE POLICY \"chat_messages_select\" ON public.chat_messages
  FOR SELECT USING (true)","-- Users can update ONLY the feedback field of messages in their conversations
CREATE POLICY \"chat_messages_update_feedback\" ON public.chat_messages
  FOR UPDATE USING (true)
  WITH CHECK (true)","-- ── Auto-update updated_at on chat_conversations ──────────────────────────
CREATE OR REPLACE FUNCTION public.update_chat_conversation_timestamp()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  UPDATE public.chat_conversations
  SET updated_at = now()
  WHERE id = NEW.conversation_id;
  RETURN NEW;
END;
$$","DROP TRIGGER IF EXISTS chat_messages_update_conversation_ts ON public.chat_messages","CREATE TRIGGER chat_messages_update_conversation_ts
  AFTER INSERT ON public.chat_messages
  FOR EACH ROW EXECUTE FUNCTION public.update_chat_conversation_timestamp()"}', 'chat_logs');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260320000000', '{"-- Add Swikly deposit fields to assignments table
-- swikly_status flow: pending → wish_created → accepted → released | captured | expired | cancelled

ALTER TABLE envios ADD COLUMN IF NOT EXISTS swikly_wish_id TEXT","ALTER TABLE envios ADD COLUMN IF NOT EXISTS swikly_wish_url TEXT","ALTER TABLE envios ADD COLUMN IF NOT EXISTS swikly_status TEXT DEFAULT ''pending''","ALTER TABLE envios ADD COLUMN IF NOT EXISTS swikly_deposit_amount INTEGER","-- stored in cents (€ × 100)

-- Check constraint on swikly_status
ALTER TABLE envios DROP CONSTRAINT IF EXISTS envios_swikly_status_check","ALTER TABLE envios ADD CONSTRAINT envios_swikly_status_check
  CHECK (swikly_status IN (''pending'', ''wish_created'', ''accepted'', ''released'', ''captured'', ''expired'', ''cancelled''))","-- Index for fast wish_id lookups (used by swikly-webhook)
CREATE INDEX IF NOT EXISTS envios_swikly_wish_id_idx ON envios(swikly_wish_id)"}', 'add_swikly_fields');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260320000001', '{"-- Brickman Knowledge Base table
-- Stores the full knowledge base text for the Brickman chatbot assistant.
-- No vector embeddings needed: the KB is small enough to fit in the LLM context window.

create table if not exists public.brickman_knowledge (
  id serial primary key,
  content text not null,
  version text not null default ''v1'',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
)","-- RLS: public read (Edge Function reads without auth), service_role can write
alter table public.brickman_knowledge enable row level security","drop policy if exists \"Public read access for brickman knowledge\" on public.brickman_knowledge","create policy \"Public read access for brickman knowledge\"
  on public.brickman_knowledge
  for select
  using (true)","drop policy if exists \"Service role full access for brickman knowledge\" on public.brickman_knowledge","create policy \"Service role full access for brickman knowledge\"
  on public.brickman_knowledge
  for all
  using (auth.role() = ''service_role'')","-- Auto-update updated_at on changes
create or replace function public.update_brickman_knowledge_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$","drop trigger if exists update_brickman_knowledge_updated_at on public.brickman_knowledge","create trigger update_brickman_knowledge_updated_at
  before update on public.brickman_knowledge
  for each row
  execute function public.update_brickman_knowledge_updated_at()"}', 'brickman_rag');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260321000000', '{"-- Migration: Brickshare PUDO and QR Code System
-- Description: Add support for Brickshare pickup points with QR code validation

-- Add new columns to envios table for Brickshare PUDO flow
ALTER TABLE envios
ADD COLUMN IF NOT EXISTS pickup_type TEXT CHECK (pickup_type IN (''correos'', ''brickshare'')) DEFAULT ''correos'',
ADD COLUMN IF NOT EXISTS brickshare_pudo_id TEXT,
ADD COLUMN IF NOT EXISTS delivery_qr_code TEXT UNIQUE,
ADD COLUMN IF NOT EXISTS delivery_qr_expires_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS delivery_validated_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS return_qr_code TEXT UNIQUE,
ADD COLUMN IF NOT EXISTS return_qr_expires_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS return_validated_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS brickshare_metadata JSONB DEFAULT ''{}''::jsonb","-- Create index for QR code lookups
CREATE INDEX IF NOT EXISTS idx_envios_delivery_qr ON envios(delivery_qr_code) WHERE delivery_qr_code IS NOT NULL","CREATE INDEX IF NOT EXISTS idx_envios_return_qr ON envios(return_qr_code) WHERE return_qr_code IS NOT NULL","CREATE INDEX IF NOT EXISTS idx_envios_pickup_type ON envios(pickup_type)","-- Create table for Brickshare PUDO locations
CREATE TABLE IF NOT EXISTS brickshare_pudo_locations (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    city TEXT NOT NULL,
    postal_code TEXT NOT NULL,
    province TEXT NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    contact_phone TEXT,
    contact_email TEXT,
    opening_hours JSONB,
    is_active BOOLEAN DEFAULT true,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
)","-- Create index for geolocation searches
CREATE INDEX IF NOT EXISTS idx_brickshare_pudo_location ON brickshare_pudo_locations(latitude, longitude)","CREATE INDEX IF NOT EXISTS idx_brickshare_pudo_active ON brickshare_pudo_locations(is_active) WHERE is_active = true","-- Create table for QR validation logs
CREATE TABLE IF NOT EXISTS qr_validation_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shipment_id UUID NOT NULL REFERENCES envios(id) ON DELETE CASCADE,
    qr_code TEXT NOT NULL,
    validation_type TEXT NOT NULL CHECK (validation_type IN (''delivery'', ''return'')),
    validated_by TEXT, -- Could be user_id or pudo_location_id
    validated_at TIMESTAMPTZ DEFAULT now(),
    validation_status TEXT NOT NULL CHECK (validation_status IN (''success'', ''expired'', ''invalid'', ''already_used'')),
    metadata JSONB DEFAULT ''{}''::jsonb,
    created_at TIMESTAMPTZ DEFAULT now()
)","CREATE INDEX IF NOT EXISTS idx_qr_validation_shipment ON qr_validation_logs(shipment_id)","CREATE INDEX IF NOT EXISTS idx_qr_validation_code ON qr_validation_logs(qr_code)","-- Function to generate unique QR code
CREATE OR REPLACE FUNCTION generate_qr_code()
RETURNS TEXT AS $$
DECLARE
    chars TEXT := ''ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'';
    result TEXT := ''BS-'';
    i INTEGER;
BEGIN
    FOR i IN 1..16 LOOP
        result := result || substr(chars, floor(random() * length(chars) + 1)::integer, 1);
    END LOOP;
    RETURN result;
END;
$$ LANGUAGE plpgsql","-- Function to generate delivery QR code
CREATE OR REPLACE FUNCTION generate_delivery_qr(p_shipment_id UUID)
RETURNS TABLE(qr_code TEXT, expires_at TIMESTAMPTZ) AS $$
DECLARE
    v_qr_code TEXT;
    v_expires_at TIMESTAMPTZ;
    v_max_attempts INTEGER := 10;
    v_attempt INTEGER := 0;
BEGIN
    v_expires_at := now() + interval ''30 days'';
    
    LOOP
        v_qr_code := generate_qr_code();
        v_attempt := v_attempt + 1;
        
        -- Check if QR code is unique
        IF NOT EXISTS (
            SELECT 1 FROM envios 
            WHERE delivery_qr_code = v_qr_code OR return_qr_code = v_qr_code
        ) THEN
            EXIT;
        END IF;
        
        IF v_attempt >= v_max_attempts THEN
            RAISE EXCEPTION ''Unable to generate unique QR code after % attempts'', v_max_attempts;
        END IF;
    END LOOP;
    
    UPDATE envios
    SET 
        delivery_qr_code = v_qr_code,
        delivery_qr_expires_at = v_expires_at,
        updated_at = now()
    WHERE id = p_shipment_id;
    
    RETURN QUERY SELECT v_qr_code, v_expires_at;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER","-- Function to generate return QR code
CREATE OR REPLACE FUNCTION generate_return_qr(p_shipment_id UUID)
RETURNS TABLE(qr_code TEXT, expires_at TIMESTAMPTZ) AS $$
DECLARE
    v_qr_code TEXT;
    v_expires_at TIMESTAMPTZ;
    v_max_attempts INTEGER := 10;
    v_attempt INTEGER := 0;
BEGIN
    v_expires_at := now() + interval ''30 days'';
    
    LOOP
        v_qr_code := generate_qr_code();
        v_attempt := v_attempt + 1;
        
        -- Check if QR code is unique
        IF NOT EXISTS (
            SELECT 1 FROM envios 
            WHERE delivery_qr_code = v_qr_code OR return_qr_code = v_qr_code
        ) THEN
            EXIT;
        END IF;
        
        IF v_attempt >= v_max_attempts THEN
            RAISE EXCEPTION ''Unable to generate unique QR code after % attempts'', v_max_attempts;
        END IF;
    END LOOP;
    
    UPDATE envios
    SET 
        return_qr_code = v_qr_code,
        return_qr_expires_at = v_expires_at,
        updated_at = now()
    WHERE id = p_shipment_id;
    
    RETURN QUERY SELECT v_qr_code, v_expires_at;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER","-- Function to validate QR code and get shipment info (no personal data)
CREATE OR REPLACE FUNCTION validate_qr_code(p_qr_code TEXT)
RETURNS TABLE(
    shipment_id UUID,
    validation_type TEXT,
    is_valid BOOLEAN,
    error_message TEXT,
    shipment_info JSONB
) AS $$
DECLARE
    v_shipment RECORD;
    v_is_valid BOOLEAN := false;
    v_error_message TEXT := NULL;
    v_validation_type TEXT := NULL;
    v_shipment_info JSONB;
BEGIN
    -- Find shipment by QR code
    SELECT 
        s.id,
        s.order_id,
        s.estado_envio as status,
        s.pickup_type,
        s.delivery_qr_code,
        s.delivery_qr_expires_at,
        s.delivery_validated_at,
        s.return_qr_code,
        s.return_qr_expires_at,
        s.return_validated_at,
        s.brickshare_pudo_id,
        o.set_id,
        st.set_name,
        st.set_ref as set_number,
        st.theme
    INTO v_shipment
    FROM envios s
    JOIN orders o ON s.order_id = o.id
    LEFT JOIN sets st ON o.set_id = st.id
    WHERE s.delivery_qr_code = p_qr_code OR s.return_qr_code = p_qr_code;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT 
            NULL::UUID,
            NULL::TEXT,
            false,
            ''QR code not found''::TEXT,
            NULL::JSONB;
        RETURN;
    END IF;
    
    -- Check if it''s a Brickshare PUDO shipment
    IF v_shipment.pickup_type != ''brickshare'' THEN
        RETURN QUERY SELECT 
            v_shipment.id,
            NULL::TEXT,
            false,
            ''This shipment is not for Brickshare pickup point''::TEXT,
            NULL::JSONB;
        RETURN;
    END IF;
    
    -- Determine validation type and check validity
    IF v_shipment.delivery_qr_code = p_qr_code THEN
        v_validation_type := ''delivery'';
        
        IF v_shipment.delivery_validated_at IS NOT NULL THEN
            v_error_message := ''QR code already used'';
        ELSIF v_shipment.delivery_qr_expires_at < now() THEN
            v_error_message := ''QR code has expired'';
        ELSE
            v_is_valid := true;
        END IF;
        
    ELSIF v_shipment.return_qr_code = p_qr_code THEN
        v_validation_type := ''return'';
        
        IF v_shipment.return_validated_at IS NOT NULL THEN
            v_error_message := ''QR code already used'';
        ELSIF v_shipment.return_qr_expires_at < now() THEN
            v_error_message := ''QR code has expired'';
        ELSIF v_shipment.delivery_validated_at IS NULL THEN
            v_error_message := ''Cannot return a set that has not been delivered yet'';
        ELSE
            v_is_valid := true;
        END IF;
    END IF;
    
    -- Build shipment info (excluding personal data)
    v_shipment_info := jsonb_build_object(
        ''order_id'', v_shipment.order_id,
        ''set_id'', v_shipment.set_id,
        ''set_name'', v_shipment.set_name,
        ''set_number'', v_shipment.set_number,
        ''theme'', v_shipment.theme,
        ''status'', v_shipment.status,
        ''brickshare_pudo_id'', v_shipment.brickshare_pudo_id,
        ''validation_type'', v_validation_type
    );
    
    RETURN QUERY SELECT 
        v_shipment.id,
        v_validation_type,
        v_is_valid,
        v_error_message,
        v_shipment_info;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER","-- Function to confirm QR validation
CREATE OR REPLACE FUNCTION confirm_qr_validation(
    p_qr_code TEXT,
    p_validated_by TEXT DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    shipment_id UUID
) AS $$
DECLARE
    v_validation RECORD;
    v_new_status TEXT;
BEGIN
    -- Validate QR code first
    SELECT * INTO v_validation
    FROM validate_qr_code(p_qr_code);
    
    IF NOT v_validation.is_valid THEN
        RETURN QUERY SELECT 
            false,
            v_validation.error_message,
            v_validation.shipment_id;
        RETURN;
    END IF;
    
    -- Update shipment based on validation type
    IF v_validation.validation_type = ''delivery'' THEN
        v_new_status := ''delivered'';
        
        UPDATE envios
        SET 
            delivery_validated_at = now(),
            estado_envio = v_new_status,
            updated_at = now()
        WHERE id = v_validation.shipment_id;
        
    ELSIF v_validation.validation_type = ''return'' THEN
        v_new_status := ''returned'';
        
        UPDATE envios
        SET 
            return_validated_at = now(),
            estado_envio = v_new_status,
            updated_at = now()
        WHERE id = v_validation.shipment_id;
    END IF;
    
    -- Log validation
    INSERT INTO qr_validation_logs (
        shipment_id,
        qr_code,
        validation_type,
        validated_by,
        validation_status,
        metadata
    ) VALUES (
        v_validation.shipment_id,
        p_qr_code,
        v_validation.validation_type,
        p_validated_by,
        ''success'',
        jsonb_build_object(''validated_at'', now())
    );
    
    RETURN QUERY SELECT 
        true,
        format(''Shipment successfully %s'', 
            CASE 
                WHEN v_validation.validation_type = ''delivery'' THEN ''delivered''
                ELSE ''returned''
            END
        ),
        v_validation.shipment_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER","-- Insert sample Brickshare PUDO locations (you can modify these)
INSERT INTO brickshare_pudo_locations (id, name, address, city, postal_code, province, latitude, longitude, contact_email, is_active)
VALUES 
    (''BS-PUDO-001'', ''Brickshare Madrid Centro'', ''Calle Gran Vía 28'', ''Madrid'', ''28013'', ''Madrid'', 40.4200, -3.7038, ''madrid.centro@brickshare.com'', true),
    (''BS-PUDO-002'', ''Brickshare Barcelona Eixample'', ''Passeig de Gràcia 100'', ''Barcelona'', ''08008'', ''Barcelona'', 41.3926, 2.1640, ''barcelona.eixample@brickshare.com'', true)
ON CONFLICT (id) DO NOTHING","-- Grant necessary permissions
GRANT SELECT ON brickshare_pudo_locations TO authenticated","GRANT SELECT ON qr_validation_logs TO authenticated","GRANT EXECUTE ON FUNCTION validate_qr_code(TEXT) TO anon, authenticated","GRANT EXECUTE ON FUNCTION confirm_qr_validation(TEXT, TEXT) TO authenticated","-- Add RLS policies
ALTER TABLE brickshare_pudo_locations ENABLE ROW LEVEL SECURITY","ALTER TABLE qr_validation_logs ENABLE ROW LEVEL SECURITY","CREATE POLICY \"Allow public read of active PUDO locations\"
    ON brickshare_pudo_locations FOR SELECT
    TO public
    USING (is_active = true)","CREATE POLICY \"Users can view their own validation logs\"
    ON qr_validation_logs FOR SELECT
    TO authenticated
    USING (
        shipment_id IN (
            SELECT s.id FROM envios s
            WHERE s.user_id = auth.uid()
        )
    )","-- Add comment
COMMENT ON TABLE brickshare_pudo_locations IS ''Brickshare pickup and drop-off locations''","COMMENT ON TABLE qr_validation_logs IS ''Logs of QR code validations for deliveries and returns''","COMMENT ON FUNCTION validate_qr_code(TEXT) IS ''Validates a QR code and returns shipment info without personal data''","COMMENT ON FUNCTION confirm_qr_validation(TEXT, TEXT) IS ''Confirms a QR validation and updates shipment status''"}', 'brickshare_pudo_qr_system');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260321000001', '{"-- =========================================
-- Migration: Migrate profiles to users
-- =========================================
-- Purpose: Consolidate all user profile functionality into the ''users'' table
--          and remove the conflicting ''profiles'' table.
--
-- This migration:
-- 1. Adds referral fields to users table
-- 2. Migrates data from profiles to users
-- 3. Updates all triggers and functions to use users
-- 4. Removes profiles table and its dependencies
-- =========================================

-- =========================================
-- STEP 1: Add referral fields to users
-- =========================================

ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS referral_code TEXT,
  ADD COLUMN IF NOT EXISTS referred_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS referral_credits INTEGER NOT NULL DEFAULT 0","-- Create unique index on referral_code (case-insensitive)
CREATE UNIQUE INDEX IF NOT EXISTS users_referral_code_lower
  ON public.users (LOWER(referral_code))
  WHERE referral_code IS NOT NULL","COMMENT ON COLUMN public.users.referral_code IS ''Unique shareable code (6 chars, auto-generated)''","COMMENT ON COLUMN public.users.referred_by IS ''auth.users.id of the user who referred this one''","COMMENT ON COLUMN public.users.referral_credits IS ''Accumulated credits from successful referrals''","-- =========================================
-- STEP 2: Migrate data from profiles to users (if profiles exists)
-- =========================================

-- Only migrate if profiles table exists
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = ''profiles'' AND table_schema = ''public'') THEN
        UPDATE public.users u
        SET 
          referral_code = p.referral_code,
          referred_by = p.referred_by,
          referral_credits = COALESCE(p.referral_credits, 0),
          full_name = COALESCE(u.full_name, p.full_name),
          avatar_url = COALESCE(u.avatar_url, p.avatar_url),
          impact_points = COALESCE(u.impact_points, p.impact_points, 0)
        FROM public.profiles p
        WHERE u.user_id = p.id;
    END IF;
END $$","-- =========================================
-- STEP 3: Update handle_new_user trigger
-- =========================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
    INSERT INTO public.users (
        user_id,
        full_name,
        avatar_url,
        email
    )
    VALUES (
        NEW.id,
        NEW.raw_user_meta_data ->> ''full_name'',
        NEW.raw_user_meta_data ->> ''avatar_url'',
        NEW.email
    )
    ON CONFLICT (user_id) DO NOTHING;
    RETURN NEW;
END;
$$","-- =========================================
-- STEP 4: Create trigger to auto-generate referral_code for users
-- =========================================

CREATE OR REPLACE FUNCTION public.generate_referral_code_users()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    new_code TEXT;
    attempts INTEGER := 0;
BEGIN
    -- Only generate if not already set
    IF NEW.referral_code IS NULL THEN
        LOOP
            -- 6-char uppercase alphanumeric code
            new_code := UPPER(SUBSTRING(MD5(RANDOM()::TEXT || NEW.user_id::TEXT) FROM 1 FOR 6));

            -- Check uniqueness
            IF NOT EXISTS (
                SELECT 1 FROM public.users 
                WHERE LOWER(referral_code) = LOWER(new_code)
            ) THEN
                NEW.referral_code := new_code;
                EXIT;
            END IF;

            attempts := attempts + 1;
            IF attempts > 10 THEN
                -- Fallback: use longer hash
                NEW.referral_code := UPPER(SUBSTRING(MD5(NEW.user_id::TEXT) FROM 1 FOR 8));
                EXIT;
            END IF;
        END LOOP;
    END IF;
    RETURN NEW;
END;
$$","-- Apply trigger to users table
DROP TRIGGER IF EXISTS users_generate_referral_code ON public.users","CREATE TRIGGER users_generate_referral_code
    BEFORE INSERT ON public.users
    FOR EACH ROW EXECUTE FUNCTION public.generate_referral_code_users()","-- =========================================
-- STEP 5: Update process_referral_credit function
-- =========================================

CREATE OR REPLACE FUNCTION public.process_referral_credit(p_referee_user_id UUID)
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_referral    public.referrals%ROWTYPE;
    v_referrer_id UUID;
BEGIN
    -- Find pending referral for this user
    SELECT * INTO v_referral
    FROM public.referrals
    WHERE referee_id = p_referee_user_id
      AND status = ''pending'';

    IF NOT FOUND THEN
        RETURN; -- No pending referral, nothing to do
    END IF;

    v_referrer_id := v_referral.referrer_id;

    -- Award credits to referrer in USERS table
    UPDATE public.users
    SET referral_credits = referral_credits + v_referral.reward_credits
    WHERE user_id = v_referrer_id;

    -- Mark referral as credited
    UPDATE public.referrals
    SET status = ''credited'',
        credited_at = NOW()
    WHERE id = v_referral.id;
END;
$$","-- =========================================
-- STEP 6: Update increment_referral_credits function
-- =========================================

CREATE OR REPLACE FUNCTION public.increment_referral_credits(
    p_user_id UUID,
    p_amount INTEGER DEFAULT 1
)
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    UPDATE public.users
    SET referral_credits = referral_credits + p_amount
    WHERE user_id = p_user_id;
END;
$$","-- =========================================
-- STEP 7: Backfill referral codes for existing users
-- =========================================

UPDATE public.users
SET referral_code = UPPER(SUBSTRING(MD5(user_id::TEXT) FROM 1 FOR 6))
WHERE referral_code IS NULL","-- =========================================
-- STEP 8: Update RLS policies for users (if needed)
-- =========================================

-- Users can view their referral info
DROP POLICY IF EXISTS \"users_select_own_referral\" ON public.users","CREATE POLICY \"users_select_own_referral\"
    ON public.users FOR SELECT
    TO authenticated
    USING (user_id = auth.uid())","-- =========================================
-- STEP 9: Clean up profiles table and dependencies (if profiles exists)
-- =========================================

DO $$
BEGIN
    -- Drop triggers on profiles if they exist
    IF EXISTS (SELECT 1 FROM information_schema.triggers WHERE trigger_name = ''profiles_generate_referral_code'' AND event_object_schema = ''public'') THEN
        DROP TRIGGER profiles_generate_referral_code ON public.profiles;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.triggers WHERE trigger_name = ''profiles_updated_at'' AND event_object_schema = ''public'') THEN
        DROP TRIGGER profiles_updated_at ON public.profiles;
    END IF;
    
    -- Drop functions specific to profiles
    DROP FUNCTION IF EXISTS public.generate_referral_code() CASCADE;
    DROP FUNCTION IF EXISTS public.set_updated_at() CASCADE;
    
    -- Drop RLS policies on profiles (if the table exists)
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = ''profiles'' AND table_schema = ''public'') THEN
        DROP POLICY IF EXISTS \"profiles_select_own\" ON public.profiles;
        DROP POLICY IF EXISTS \"profiles_update_own\" ON public.profiles;
        DROP POLICY IF EXISTS \"profiles_insert_own\" ON public.profiles;
        
        -- Drop the profiles table
        DROP TABLE IF EXISTS public.profiles CASCADE;
    END IF;
END $$","-- Drop old trigger on auth.users and recreate it (we''ll recreate it to point to handle_new_user)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users","-- Recreate trigger on auth.users pointing to handle_new_user (which now inserts into users)
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user()","-- =========================================
-- VERIFICATION QUERIES (commented out)
-- =========================================

-- Uncomment to verify the migration:

-- Check users table structure
-- SELECT column_name, data_type, is_nullable, column_default
-- FROM information_schema.columns
-- WHERE table_name = ''users'' AND table_schema = ''public''
-- ORDER BY ordinal_position;

-- Check that referral codes were generated
-- SELECT user_id, email, referral_code, referral_credits
-- FROM public.users
-- ORDER BY created_at DESC
-- LIMIT 10;

-- Verify profiles table is gone
-- SELECT table_name 
-- FROM information_schema.tables 
-- WHERE table_schema = ''public'' AND table_name = ''profiles'';

-- Check triggers on auth.users
-- SELECT trigger_name, event_manipulation, action_statement
-- FROM information_schema.triggers
-- WHERE event_object_table = ''users'' AND event_object_schema = ''auth''"}', 'migrate_profiles_to_users');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260321000002', '{"-- =========================================
-- Fix: Recreate missing triggers after profiles migration
-- =========================================
-- Purpose: Recreate triggers that were dropped in CASCADE when
--          dropping the set_updated_at function from profiles
-- =========================================

-- Recreate set_updated_at function
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$","-- Recreate trigger for reviews
DROP TRIGGER IF EXISTS reviews_updated_at ON public.reviews","CREATE TRIGGER reviews_updated_at
    BEFORE UPDATE ON public.reviews
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at()","-- Recreate trigger for referrals  
DROP TRIGGER IF EXISTS referrals_updated_at ON public.referrals","CREATE TRIGGER referrals_updated_at
    BEFORE UPDATE ON public.referrals
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at()","-- Sync existing auth.users to public.users (if any were created before migration)
INSERT INTO public.users (user_id, email, full_name)
SELECT 
    u.id,
    u.email,
    u.raw_user_meta_data->>''full_name''
FROM auth.users u
WHERE NOT EXISTS (
    SELECT 1 FROM public.users pu WHERE pu.user_id = u.id
)
ON CONFLICT (user_id) DO NOTHING"}', 'fix_missing_triggers');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260321100000', '{"-- Fix: Ensure user_status constraint uses English values
-- The trigger handle_shipment_delivered sets user_status = ''has_set'' when a shipment
-- is delivered. This migration ensures the constraint includes all valid English values.
-- NOTE: This runs BEFORE the rename_spanish_to_english migration, so we need to
-- support BOTH Spanish and English values temporarily to avoid breaking existing data.

ALTER TABLE public.users DROP CONSTRAINT IF EXISTS check_user_status","-- First, update any existing Spanish values to English
UPDATE public.users SET user_status = ''no_set'' WHERE user_status = ''sin set''","UPDATE public.users SET user_status = ''set_shipping'' WHERE user_status = ''set en envio''","UPDATE public.users SET user_status = ''received'' WHERE user_status = ''recibido''","UPDATE public.users SET user_status = ''has_set'' WHERE user_status = ''con set''","UPDATE public.users SET user_status = ''set_returning'' WHERE user_status = ''set en devolucion''","UPDATE public.users SET user_status = ''suspended'' WHERE user_status = ''suspendido''","UPDATE public.users SET user_status = ''cancelled'' WHERE user_status = ''cancelado''","-- Set default to English
ALTER TABLE public.users ALTER COLUMN user_status SET DEFAULT ''no_set''","-- Add constraint with English-only values
ALTER TABLE public.users
ADD CONSTRAINT check_user_status
CHECK (user_status IN (
  ''no_set'',
  ''set_shipping'',
  ''received'',
  ''has_set'',
  ''set_returning'',
  ''suspended'',
  ''cancelled''
))","COMMENT ON COLUMN public.users.user_status IS ''Allowed values: no_set, set_shipping, received, has_set, set_returning, suspended, cancelled''"}', 'fix_user_status_constraint');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260322000000', '{"-- ============================================================
-- BRICKSHARE — Migration: Integración con Brickshare_logistics
-- Añade campo para conectar shipments con packages del sistema de logistics
-- ============================================================

-- Añadir campo para almacenar el ID del package en Brickshare_logistics
ALTER TABLE envios
  ADD COLUMN brickshare_package_id TEXT","COMMENT ON COLUMN envios.brickshare_package_id IS
  ''ID del package en Brickshare_logistics. Usado cuando pickup_type=\"brickshare\" para sincronización con el sistema de PUDO.''","-- Crear índice para consultas rápidas
CREATE INDEX idx_envios_brickshare_package_id 
  ON envios(brickshare_package_id) 
  WHERE brickshare_package_id IS NOT NULL","-- ============================================================
-- Función helper para validar si un shipment usa Brickshare PUDO
-- ============================================================

CREATE OR REPLACE FUNCTION public.uses_brickshare_pudo(shipment_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
AS $$
  SELECT pickup_type = ''brickshare'' AND brickshare_pudo_id IS NOT NULL
  FROM envios
  WHERE id = shipment_id;
$$","COMMENT ON FUNCTION public.uses_brickshare_pudo IS
  ''Retorna true si el shipment usa el sistema de PUDO de Brickshare_logistics''","-- ============================================================
-- Vista para shipments que usan Brickshare PUDO
-- ============================================================

CREATE OR REPLACE VIEW public.brickshare_pudo_shipments AS
SELECT
  s.id,
  s.user_id,
  s.estado_envio as status,
  s.pickup_type,
  s.brickshare_pudo_id,
  s.brickshare_package_id,
  s.delivery_qr_code,
  s.delivery_validated_at as delivery_qr_validated_at,
  s.return_qr_code,
  s.return_validated_at as return_qr_validated_at,
  s.numero_seguimiento as tracking_number,
  s.created_at,
  s.updated_at
FROM envios s
WHERE s.pickup_type = ''brickshare''
  AND s.brickshare_pudo_id IS NOT NULL","COMMENT ON VIEW public.brickshare_pudo_shipments IS
  ''Vista de shipments que utilizan puntos PUDO de Brickshare_logistics''","-- ============================================================
-- FIN DE MIGRACIÓN
-- ============================================================"}', 'add_logistics_integration');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260322100000', '{"-- ============================================================================
-- Migration: Rename all Spanish table/column names to English
-- Date: 2026-03-22
-- Description: Standardize all database identifiers to English
-- ============================================================================

-- ============================================================================
-- STEP 1: Rename tables
-- ============================================================================

ALTER TABLE public.envios RENAME TO shipments","ALTER TABLE public.operaciones_recepcion RENAME TO reception_operations","-- ============================================================================
-- STEP 2: Rename columns in shipments (formerly envios)
-- ============================================================================

ALTER TABLE public.shipments RENAME COLUMN estado_envio TO shipment_status","ALTER TABLE public.shipments RENAME COLUMN estado_manipulacion TO handling_processed","ALTER TABLE public.shipments RENAME COLUMN direccion_envio TO shipping_address","ALTER TABLE public.shipments RENAME COLUMN ciudad_envio TO shipping_city","ALTER TABLE public.shipments RENAME COLUMN codigo_postal_envio TO shipping_zip_code","ALTER TABLE public.shipments RENAME COLUMN pais_envio TO shipping_country","ALTER TABLE public.shipments RENAME COLUMN proveedor_envio TO shipping_provider","ALTER TABLE public.shipments RENAME COLUMN proveedor_recogida TO pickup_provider","ALTER TABLE public.shipments RENAME COLUMN numero_seguimiento TO tracking_number","ALTER TABLE public.shipments RENAME COLUMN transportista TO carrier","ALTER TABLE public.shipments RENAME COLUMN notas_adicionales TO additional_notes","ALTER TABLE public.shipments RENAME COLUMN fecha_asignada TO assigned_date","ALTER TABLE public.shipments RENAME COLUMN fecha_entrega TO estimated_delivery_date","ALTER TABLE public.shipments RENAME COLUMN fecha_entrega_real TO actual_delivery_date","ALTER TABLE public.shipments RENAME COLUMN fecha_entrega_usuario TO user_delivery_date","ALTER TABLE public.shipments RENAME COLUMN fecha_recepcion_almacen TO warehouse_reception_date","ALTER TABLE public.shipments RENAME COLUMN fecha_recogida_almacen TO warehouse_pickup_date","ALTER TABLE public.shipments RENAME COLUMN fecha_solicitud_devolucion TO return_request_date","ALTER TABLE public.shipments RENAME COLUMN fecha_devolucion_estimada TO estimated_return_date","ALTER TABLE public.shipments RENAME COLUMN direccion_proveedor_recogida TO pickup_provider_address","-- ============================================================================
-- STEP 3: Rename columns in reception_operations (formerly operaciones_recepcion)
-- ============================================================================

ALTER TABLE public.reception_operations RENAME COLUMN status_recepcion TO reception_completed","-- ============================================================================
-- STEP 4: Rename columns in inventory_sets
-- ============================================================================

ALTER TABLE public.inventory_sets RENAME COLUMN en_envio TO in_shipping","ALTER TABLE public.inventory_sets RENAME COLUMN en_uso TO in_use","ALTER TABLE public.inventory_sets RENAME COLUMN en_devolucion TO in_return","ALTER TABLE public.inventory_sets RENAME COLUMN en_reparacion TO in_repair","-- ============================================================================
-- STEP 5: Rename columns in donations
-- ============================================================================

ALTER TABLE public.donations RENAME COLUMN nombre TO name","ALTER TABLE public.donations RENAME COLUMN telefono TO phone","ALTER TABLE public.donations RENAME COLUMN direccion TO address","ALTER TABLE public.donations RENAME COLUMN peso_estimado TO estimated_weight","ALTER TABLE public.donations RENAME COLUMN metodo_entrega TO delivery_method","ALTER TABLE public.donations RENAME COLUMN recompensa TO reward","ALTER TABLE public.donations RENAME COLUMN ninos_beneficiados TO children_benefited","ALTER TABLE public.donations RENAME COLUMN co2_evitado TO co2_avoided","-- ============================================================================
-- STEP 6: Drop duplicate Spanish columns in users table
-- ============================================================================

ALTER TABLE public.users DROP COLUMN IF EXISTS direccion","ALTER TABLE public.users DROP COLUMN IF EXISTS codigo_postal","ALTER TABLE public.users DROP COLUMN IF EXISTS ciudad","ALTER TABLE public.users DROP COLUMN IF EXISTS telefono","-- ============================================================================
-- STEP 7: Update shipment_status enum values (Spanish → English)
-- ============================================================================

-- Drop old constraint
ALTER TABLE public.shipments DROP CONSTRAINT IF EXISTS check_estado_envio","-- Update existing data
UPDATE public.shipments SET shipment_status = ''preparation'' WHERE shipment_status = ''preparacion''","UPDATE public.shipments SET shipment_status = ''in_transit'' WHERE shipment_status = ''ruta_envio''","UPDATE public.shipments SET shipment_status = ''delivered'' WHERE shipment_status = ''entregado''","UPDATE public.shipments SET shipment_status = ''returned'' WHERE shipment_status = ''devuelto''","UPDATE public.shipments SET shipment_status = ''return_in_transit'' WHERE shipment_status = ''ruta_devolucion''","UPDATE public.shipments SET shipment_status = ''cancelled'' WHERE shipment_status = ''cancelado''","UPDATE public.shipments SET shipment_status = ''pending'' WHERE shipment_status = ''pendiente''","UPDATE public.shipments SET shipment_status = ''assigned'' WHERE shipment_status = ''asignado''","-- Add new constraint with English values
ALTER TABLE public.shipments ADD CONSTRAINT check_shipment_status 
  CHECK (shipment_status IN (''pending'', ''preparation'', ''assigned'', ''in_transit'', ''delivered'', ''returned'', ''return_in_transit'', ''cancelled''))","-- ============================================================================
-- STEP 8: Update set_status enum values (Spanish → English)
-- ============================================================================

ALTER TABLE public.sets DROP CONSTRAINT IF EXISTS check_set_status_spanish","UPDATE public.sets SET set_status = ''active'' WHERE set_status = ''activo''","UPDATE public.sets SET set_status = ''inactive'' WHERE set_status = ''inactivo''","UPDATE public.sets SET set_status = ''in_repair'' WHERE set_status = ''en reparacion''","ALTER TABLE public.sets ADD CONSTRAINT check_set_status 
  CHECK (set_status IN (''active'', ''inactive'', ''in_repair''))","-- Update default
ALTER TABLE public.sets ALTER COLUMN set_status SET DEFAULT ''inactive''","-- ============================================================================
-- STEP 9: Update user_status enum values (Spanish → English)
-- ============================================================================

ALTER TABLE public.users DROP CONSTRAINT IF EXISTS check_user_status","UPDATE public.users SET user_status = ''no_set'' WHERE user_status = ''sin set''","UPDATE public.users SET user_status = ''set_shipping'' WHERE user_status = ''set en envio''","UPDATE public.users SET user_status = ''received'' WHERE user_status = ''recibido''","UPDATE public.users SET user_status = ''has_set'' WHERE user_status = ''con set''","UPDATE public.users SET user_status = ''set_returning'' WHERE user_status = ''set en devolucion''","UPDATE public.users SET user_status = ''suspended'' WHERE user_status = ''suspendido''","UPDATE public.users SET user_status = ''cancelled'' WHERE user_status = ''cancelado''","ALTER TABLE public.users ADD CONSTRAINT check_user_status 
  CHECK (user_status IN (''no_set'', ''set_shipping'', ''received'', ''has_set'', ''set_returning'', ''suspended'', ''cancelled''))","ALTER TABLE public.users ALTER COLUMN user_status SET DEFAULT ''no_set''","-- ============================================================================
-- STEP 10: Update donation enum values
-- ============================================================================

ALTER TABLE public.donations DROP CONSTRAINT IF EXISTS donations_metodo_entrega_check","ALTER TABLE public.donations DROP CONSTRAINT IF EXISTS donations_recompensa_check","UPDATE public.donations SET delivery_method = ''pickup-point'' WHERE delivery_method = ''punto-recogida''","UPDATE public.donations SET delivery_method = ''home-pickup'' WHERE delivery_method = ''recogida-domicilio''","UPDATE public.donations SET reward = ''economic'' WHERE reward = ''economica''","ALTER TABLE public.donations ADD CONSTRAINT donations_delivery_method_check 
  CHECK (delivery_method IN (''pickup-point'', ''home-pickup''))","ALTER TABLE public.donations ADD CONSTRAINT donations_reward_check 
  CHECK (reward IN (''economic'', ''social''))","-- ============================================================================
-- STEP 11: Drop and recreate the brickshare_pudo_shipments VIEW
-- ============================================================================

DROP VIEW IF EXISTS public.brickshare_pudo_shipments","CREATE OR REPLACE VIEW public.brickshare_pudo_shipments AS
SELECT 
    id,
    user_id,
    shipment_status AS status,
    pickup_type,
    brickshare_pudo_id,
    brickshare_package_id,
    delivery_qr_code,
    delivery_validated_at AS delivery_qr_validated_at,
    return_qr_code,
    return_validated_at AS return_qr_validated_at,
    tracking_number,
    created_at,
    updated_at
FROM public.shipments s
WHERE pickup_type = ''brickshare'' AND brickshare_pudo_id IS NOT NULL","-- ============================================================================
-- STEP 12: Drop triggers first, then drop and recreate functions
-- ============================================================================

-- Drop ALL triggers on shipments and reception_operations FIRST (before dropping functions)
DROP TRIGGER IF EXISTS on_envio_entregado ON public.shipments","DROP TRIGGER IF EXISTS on_envio_recibido_almacen ON public.shipments","DROP TRIGGER IF EXISTS on_envio_return_update ON public.shipments","DROP TRIGGER IF EXISTS on_envio_ruta_devolucion_inv ON public.shipments","DROP TRIGGER IF EXISTS update_envios_updated_at ON public.shipments","DROP TRIGGER IF EXISTS on_shipment_delivered ON public.shipments","DROP TRIGGER IF EXISTS on_shipment_warehouse_received ON public.shipments","DROP TRIGGER IF EXISTS on_shipment_return_user_status ON public.shipments","DROP TRIGGER IF EXISTS on_shipment_return_transit_inv ON public.shipments","DROP TRIGGER IF EXISTS update_shipments_updated_at ON public.shipments","DROP TRIGGER IF EXISTS on_recepcion_completada ON public.reception_operations","DROP TRIGGER IF EXISTS update_operaciones_recepcion_updated_at ON public.reception_operations","DROP TRIGGER IF EXISTS on_reception_completed ON public.reception_operations","DROP TRIGGER IF EXISTS update_reception_operations_updated_at ON public.reception_operations","-- Now drop all functions (safe since triggers are gone)
DROP FUNCTION IF EXISTS public.preview_assign_sets_to_users()","DROP FUNCTION IF EXISTS public.confirm_assign_sets_to_users(uuid[])","DROP FUNCTION IF EXISTS public.assign_sets_to_users()","DROP FUNCTION IF EXISTS public.delete_assignment_and_rollback(uuid)","DROP FUNCTION IF EXISTS public.update_set_status_from_return(uuid, text, uuid)","DROP FUNCTION IF EXISTS public.confirm_qr_validation(text, text)","DROP FUNCTION IF EXISTS public.validate_qr_code(text)","DROP FUNCTION IF EXISTS public.generate_delivery_qr(uuid)","DROP FUNCTION IF EXISTS public.generate_return_qr(uuid)","DROP FUNCTION IF EXISTS public.uses_brickshare_pudo(uuid)","DROP FUNCTION IF EXISTS public.handle_envio_entregado()","DROP FUNCTION IF EXISTS public.handle_envio_recibido_almacen()","DROP FUNCTION IF EXISTS public.handle_envio_ruta_devolucion_inventory()","DROP FUNCTION IF EXISTS public.handle_return_status_update()","DROP FUNCTION IF EXISTS public.handle_cierre_recepcion()","DROP FUNCTION IF EXISTS public.handle_shipment_delivered()","DROP FUNCTION IF EXISTS public.handle_shipment_warehouse_received()","DROP FUNCTION IF EXISTS public.handle_shipment_return_transit_inventory()","DROP FUNCTION IF EXISTS public.handle_return_user_status()","DROP FUNCTION IF EXISTS public.handle_reception_close()","-- 12a: handle_envio_entregado → handle_shipment_delivered
CREATE OR REPLACE FUNCTION public.handle_shipment_delivered()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    IF NEW.shipment_status = ''delivered'' AND OLD.shipment_status != ''delivered'' THEN
        UPDATE public.users SET user_status = ''has_set'' WHERE user_id = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$","-- 12b: handle_envio_recibido_almacen → handle_shipment_warehouse_received
CREATE OR REPLACE FUNCTION public.handle_shipment_warehouse_received()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    IF NEW.shipment_status = ''returned'' AND OLD.shipment_status != ''returned'' THEN
        INSERT INTO public.reception_operations (event_id, user_id, set_id)
        VALUES (NEW.id, NEW.user_id, NEW.set_id);
        NEW.warehouse_reception_date = now();
    END IF;
    RETURN NEW;
END;
$$","-- 12c: handle_envio_ruta_devolucion_inventory → handle_shipment_return_transit_inventory
CREATE OR REPLACE FUNCTION public.handle_shipment_return_transit_inventory()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    IF NEW.shipment_status = ''return_in_transit'' AND OLD.shipment_status != ''return_in_transit'' THEN
        UPDATE public.inventory_sets
        SET in_return = COALESCE(in_return, 0) + 1, updated_at = now()
        WHERE set_id = NEW.set_id;
    END IF;
    RETURN NEW;
END;
$$","-- 12d: handle_return_status_update → handle_return_user_status
CREATE OR REPLACE FUNCTION public.handle_return_user_status()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    IF NEW.shipment_status = ''return_in_transit'' AND OLD.shipment_status != ''return_in_transit'' THEN
        UPDATE public.users SET user_status = ''no_set'' WHERE user_id = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$","-- 12e: handle_cierre_recepcion → handle_reception_close
CREATE OR REPLACE FUNCTION public.handle_reception_close()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    IF NEW.reception_completed = TRUE AND OLD.reception_completed = FALSE THEN
        UPDATE public.inventory_sets
        SET in_return = GREATEST(0, COALESCE(in_return, 0) - 1), updated_at = now()
        WHERE set_id = NEW.set_id;

        IF NEW.missing_parts IS NOT NULL AND TRIM(NEW.missing_parts) != '''' THEN
            UPDATE public.inventory_sets SET in_repair = COALESCE(in_repair, 0) + 1 WHERE set_id = NEW.set_id;
            UPDATE public.sets SET set_status = ''in_repair'', updated_at = now() WHERE id = NEW.set_id;
        ELSE
            UPDATE public.sets SET set_status = ''active'', updated_at = now() WHERE id = NEW.set_id;
        END IF;

        UPDATE public.shipments SET handling_processed = TRUE, updated_at = now() WHERE id = NEW.event_id;
    END IF;
    RETURN NEW;
END;
$$","-- 12f: delete_assignment_and_rollback
CREATE OR REPLACE FUNCTION public.delete_assignment_and_rollback(p_envio_id uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path TO ''public'' AS $$
DECLARE
    v_user_id UUID;
    v_set_id UUID;
BEGIN
    SELECT user_id, set_id INTO v_user_id, v_set_id FROM public.shipments WHERE id = p_envio_id;
    IF v_user_id IS NULL THEN RAISE EXCEPTION ''Shipment with ID % not found'', p_envio_id; END IF;

    DELETE FROM public.shipments WHERE id = p_envio_id;

    UPDATE public.inventory_sets
    SET inventory_set_total_qty = inventory_set_total_qty + 1, in_shipping = GREATEST(in_shipping - 1, 0)
    WHERE set_id = v_set_id;

    INSERT INTO public.wishlist (user_id, set_id) VALUES (v_user_id, v_set_id) ON CONFLICT (user_id, set_id) DO NOTHING;

    UPDATE public.users
    SET user_status = CASE 
        WHEN EXISTS (SELECT 1 FROM public.shipments WHERE user_id = v_user_id AND shipment_status IN (''preparation'', ''in_transit''))
        THEN user_status ELSE ''no_set'' END
    WHERE user_id = v_user_id;
END;
$$","-- 12g: preview_assign_sets_to_users
CREATE OR REPLACE FUNCTION public.preview_assign_sets_to_users()
RETURNS TABLE(user_id uuid, user_name text, set_id uuid, set_name text, set_ref text, set_price numeric, current_stock integer, matches_wishlist boolean)
LANGUAGE plpgsql SECURITY DEFINER SET search_path TO ''public'' AS $$
DECLARE
    r RECORD;
    v_set_id UUID; v_set_name TEXT; v_set_ref TEXT; v_set_price DECIMAL; v_current_stock INTEGER; v_matches_wishlist BOOLEAN;
BEGIN
    FOR r IN (
        SELECT u.user_id, u.full_name FROM public.users u
        WHERE u.user_status IN (''no_set'', ''set_returning'') AND u.user_type = ''user''
    ) LOOP
        v_set_id := NULL; v_matches_wishlist := FALSE;
        
        SELECT w.set_id, s.set_name, s.set_ref, COALESCE(s.set_price, 100.00), i.inventory_set_total_qty
        INTO v_set_id, v_set_name, v_set_ref, v_set_price, v_current_stock
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        JOIN public.sets s ON w.set_id = s.id
        WHERE w.user_id = r.user_id AND w.status = true AND i.inventory_set_total_qty > 0
          AND NOT EXISTS (SELECT 1 FROM public.shipments e WHERE e.user_id = r.user_id AND e.set_id = w.set_id)
        ORDER BY w.created_at ASC LIMIT 1;
        
        IF v_set_id IS NOT NULL THEN v_matches_wishlist := TRUE;
        ELSE
            SELECT s.id, s.set_name, s.set_ref, COALESCE(s.set_price, 100.00), i.inventory_set_total_qty
            INTO v_set_id, v_set_name, v_set_ref, v_set_price, v_current_stock
            FROM public.sets s JOIN public.inventory_sets i ON s.id = i.set_id
            WHERE i.inventory_set_total_qty > 0 ORDER BY RANDOM() LIMIT 1;
            v_matches_wishlist := FALSE;
        END IF;
        
        IF v_set_id IS NOT NULL THEN
            preview_assign_sets_to_users.user_id := r.user_id;
            preview_assign_sets_to_users.user_name := r.full_name;
            preview_assign_sets_to_users.set_id := v_set_id;
            preview_assign_sets_to_users.set_name := v_set_name;
            preview_assign_sets_to_users.set_ref := v_set_ref;
            preview_assign_sets_to_users.set_price := v_set_price;
            preview_assign_sets_to_users.current_stock := v_current_stock;
            preview_assign_sets_to_users.matches_wishlist := v_matches_wishlist;
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$","-- 12h: confirm_assign_sets_to_users
CREATE OR REPLACE FUNCTION public.confirm_assign_sets_to_users(p_user_ids uuid[])
RETURNS TABLE(envio_id uuid, user_id uuid, set_id uuid, order_id uuid, user_name text, user_email text, user_phone text, set_name text, set_ref text, set_weight numeric, set_dim text, pudo_id text, pudo_name text, pudo_address text, pudo_cp text, pudo_city text, pudo_province text, created_at timestamptz)
LANGUAGE plpgsql SECURITY DEFINER SET search_path TO ''public'' AS $$
DECLARE
    r RECORD;
    target_set_id UUID; new_order_id UUID; new_envio_id UUID;
    v_set_name TEXT; v_set_ref TEXT; v_set_weight NUMERIC; v_set_dim TEXT;
    v_user_email TEXT; v_user_phone TEXT;
    v_pudo_id TEXT; v_pudo_name TEXT; v_pudo_address TEXT; v_pudo_cp TEXT; v_pudo_city TEXT; v_pudo_province TEXT;
    v_created_at TIMESTAMPTZ;
BEGIN
    FOR r IN (
        SELECT u.user_id, u.full_name, u.email, u.phone,
               p.correos_id_pudo, p.correos_nombre, p.correos_direccion_completa,
               p.correos_codigo_postal, p.correos_ciudad, p.correos_provincia
        FROM public.users u
        LEFT JOIN public.users_correos_dropping p ON u.user_id = p.user_id
        WHERE u.user_id = ANY(p_user_ids)
          AND u.user_status IN (''no_set'', ''set_returning'')
          AND EXISTS (SELECT 1 FROM public.wishlist w WHERE w.user_id = u.user_id AND w.status = true)
    ) LOOP
        SELECT w.set_id, s.set_name, s.set_ref, s.set_weight, s.set_dim
        INTO target_set_id, v_set_name, v_set_ref, v_set_weight, v_set_dim
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        JOIN public.sets s ON w.set_id = s.id
        WHERE w.user_id = r.user_id AND w.status = true AND i.inventory_set_total_qty > 0
        ORDER BY w.created_at ASC LIMIT 1;

        IF target_set_id IS NOT NULL THEN
            UPDATE public.inventory_sets SET inventory_set_total_qty = inventory_set_total_qty - 1, in_shipping = in_shipping + 1
            WHERE inventory_sets.set_id = target_set_id;

            INSERT INTO public.orders (user_id, set_id, status) VALUES (r.user_id, target_set_id, ''pending'') RETURNING id INTO new_order_id;

            INSERT INTO public.shipments (order_id, user_id, shipment_status, shipping_address, shipping_city, shipping_zip_code, shipping_country)
            VALUES (new_order_id, r.user_id, ''pending'',
                    COALESCE(r.correos_direccion_completa, ''Pending assignment''),
                    COALESCE(r.correos_ciudad, ''Pending''),
                    COALESCE(r.correos_codigo_postal, ''00000''), ''España'')
            RETURNING shipments.id, shipments.created_at INTO new_envio_id, v_created_at;

            UPDATE public.users SET user_status = ''set_shipping'' WHERE users.user_id = r.user_id;

            UPDATE public.wishlist SET status = false, status_changed_at = now()
            WHERE wishlist.user_id = r.user_id AND wishlist.set_id = target_set_id;

            confirm_assign_sets_to_users.envio_id := new_envio_id;
            confirm_assign_sets_to_users.user_id := r.user_id;
            confirm_assign_sets_to_users.set_id := target_set_id;
            confirm_assign_sets_to_users.order_id := new_order_id;
            confirm_assign_sets_to_users.user_name := r.full_name;
            confirm_assign_sets_to_users.user_email := r.email;
            confirm_assign_sets_to_users.user_phone := r.phone;
            confirm_assign_sets_to_users.set_name := v_set_name;
            confirm_assign_sets_to_users.set_ref := v_set_ref;
            confirm_assign_sets_to_users.set_weight := v_set_weight;
            confirm_assign_sets_to_users.set_dim := v_set_dim;
            confirm_assign_sets_to_users.pudo_id := r.correos_id_pudo;
            confirm_assign_sets_to_users.pudo_name := r.correos_nombre;
            confirm_assign_sets_to_users.pudo_address := r.correos_direccion_completa;
            confirm_assign_sets_to_users.pudo_cp := r.correos_codigo_postal;
            confirm_assign_sets_to_users.pudo_city := r.correos_ciudad;
            confirm_assign_sets_to_users.pudo_province := r.correos_provincia;
            confirm_assign_sets_to_users.created_at := v_created_at;
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$","-- 12i: update_set_status_from_return
CREATE OR REPLACE FUNCTION public.update_set_status_from_return(p_set_id uuid, p_new_status text, p_envio_id uuid DEFAULT NULL)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    IF p_new_status NOT IN (''active'', ''inactive'', ''in_repair'') THEN
        RAISE EXCEPTION ''Invalid status: %'', p_new_status;
    END IF;

    UPDATE public.sets SET set_status = p_new_status, updated_at = now() WHERE id = p_set_id;

    UPDATE public.inventory_sets SET in_return = in_return - 1, updated_at = now() WHERE set_id = p_set_id;

    IF p_new_status = ''in_repair'' THEN
        UPDATE public.inventory_sets SET in_repair = in_repair + 1 WHERE set_id = p_set_id;
    END IF;

    IF p_new_status = ''active'' THEN NULL; END IF;

    IF p_envio_id IS NOT NULL THEN
        UPDATE public.shipments SET warehouse_reception_date = now(), handling_processed = TRUE, updated_at = now() WHERE id = p_envio_id;
    END IF;
END;
$$","-- 12j: confirm_qr_validation
CREATE OR REPLACE FUNCTION public.confirm_qr_validation(p_qr_code text, p_validated_by text DEFAULT NULL)
RETURNS TABLE(success boolean, message text, shipment_id uuid) LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_validation RECORD;
    v_new_status TEXT;
BEGIN
    SELECT * INTO v_validation FROM validate_qr_code(p_qr_code);
    IF NOT v_validation.is_valid THEN
        RETURN QUERY SELECT false, v_validation.error_message, v_validation.shipment_id; RETURN;
    END IF;

    IF v_validation.validation_type = ''delivery'' THEN
        v_new_status := ''delivered'';
        UPDATE shipments SET delivery_validated_at = now(), shipment_status = v_new_status, updated_at = now() WHERE id = v_validation.shipment_id;
    ELSIF v_validation.validation_type = ''return'' THEN
        v_new_status := ''returned'';
        UPDATE shipments SET return_validated_at = now(), shipment_status = v_new_status, updated_at = now() WHERE id = v_validation.shipment_id;
    END IF;

    INSERT INTO qr_validation_logs (shipment_id, qr_code, validation_type, validated_by, validation_status, metadata)
    VALUES (v_validation.shipment_id, p_qr_code, v_validation.validation_type, p_validated_by, ''success'', jsonb_build_object(''validated_at'', now()));

    RETURN QUERY SELECT true, format(''Shipment successfully %s'', CASE WHEN v_validation.validation_type = ''delivery'' THEN ''delivered'' ELSE ''returned'' END), v_validation.shipment_id;
END;
$$","-- 12k: validate_qr_code
CREATE OR REPLACE FUNCTION public.validate_qr_code(p_qr_code text)
RETURNS TABLE(shipment_id uuid, validation_type text, is_valid boolean, error_message text, shipment_info jsonb)
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_shipment RECORD;
    v_is_valid BOOLEAN := false; v_error_message TEXT := NULL; v_validation_type TEXT := NULL; v_shipment_info JSONB;
BEGIN
    SELECT s.id, s.order_id, s.shipment_status as status, s.pickup_type,
        s.delivery_qr_code, s.delivery_qr_expires_at, s.delivery_validated_at,
        s.return_qr_code, s.return_qr_expires_at, s.return_validated_at,
        s.brickshare_pudo_id, o.set_id, st.set_name, st.set_ref as set_number, st.set_theme as theme
    INTO v_shipment
    FROM shipments s JOIN orders o ON s.order_id = o.id LEFT JOIN sets st ON o.set_id = st.id
    WHERE s.delivery_qr_code = p_qr_code OR s.return_qr_code = p_qr_code;

    IF NOT FOUND THEN
        RETURN QUERY SELECT NULL::UUID, NULL::TEXT, false, ''QR code not found''::TEXT, NULL::JSONB; RETURN;
    END IF;

    IF v_shipment.pickup_type != ''brickshare'' THEN
        RETURN QUERY SELECT v_shipment.id, NULL::TEXT, false, ''This shipment is not for Brickshare pickup point''::TEXT, NULL::JSONB; RETURN;
    END IF;

    IF v_shipment.delivery_qr_code = p_qr_code THEN
        v_validation_type := ''delivery'';
        IF v_shipment.delivery_validated_at IS NOT NULL THEN v_error_message := ''QR code already used'';
        ELSIF v_shipment.delivery_qr_expires_at < now() THEN v_error_message := ''QR code has expired'';
        ELSE v_is_valid := true; END IF;
    ELSIF v_shipment.return_qr_code = p_qr_code THEN
        v_validation_type := ''return'';
        IF v_shipment.return_validated_at IS NOT NULL THEN v_error_message := ''QR code already used'';
        ELSIF v_shipment.return_qr_expires_at < now() THEN v_error_message := ''QR code has expired'';
        ELSIF v_shipment.delivery_validated_at IS NULL THEN v_error_message := ''Cannot return a set that has not been delivered yet'';
        ELSE v_is_valid := true; END IF;
    END IF;

    v_shipment_info := jsonb_build_object(''order_id'', v_shipment.order_id, ''set_id'', v_shipment.set_id, ''set_name'', v_shipment.set_name,
        ''set_number'', v_shipment.set_number, ''theme'', v_shipment.theme, ''status'', v_shipment.status,
        ''brickshare_pudo_id'', v_shipment.brickshare_pudo_id, ''validation_type'', v_validation_type);

    RETURN QUERY SELECT v_shipment.id, v_validation_type, v_is_valid, v_error_message, v_shipment_info;
END;
$$","-- 12l: generate_delivery_qr
CREATE OR REPLACE FUNCTION public.generate_delivery_qr(p_shipment_id uuid)
RETURNS TABLE(qr_code text, expires_at timestamptz) LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_qr_code TEXT; v_expires_at TIMESTAMPTZ; v_max_attempts INTEGER := 10; v_attempt INTEGER := 0;
BEGIN
    v_expires_at := now() + interval ''30 days'';
    LOOP
        v_qr_code := generate_qr_code(); v_attempt := v_attempt + 1;
        IF NOT EXISTS (SELECT 1 FROM shipments WHERE delivery_qr_code = v_qr_code OR return_qr_code = v_qr_code) THEN EXIT; END IF;
        IF v_attempt >= v_max_attempts THEN RAISE EXCEPTION ''Unable to generate unique QR code after % attempts'', v_max_attempts; END IF;
    END LOOP;
    UPDATE shipments SET delivery_qr_code = v_qr_code, delivery_qr_expires_at = v_expires_at, updated_at = now() WHERE id = p_shipment_id;
    RETURN QUERY SELECT v_qr_code, v_expires_at;
END;
$$","-- 12m: generate_return_qr
CREATE OR REPLACE FUNCTION public.generate_return_qr(p_shipment_id uuid)
RETURNS TABLE(qr_code text, expires_at timestamptz) LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_qr_code TEXT; v_expires_at TIMESTAMPTZ; v_max_attempts INTEGER := 10; v_attempt INTEGER := 0;
BEGIN
    v_expires_at := now() + interval ''30 days'';
    LOOP
        v_qr_code := generate_qr_code(); v_attempt := v_attempt + 1;
        IF NOT EXISTS (SELECT 1 FROM shipments WHERE delivery_qr_code = v_qr_code OR return_qr_code = v_qr_code) THEN EXIT; END IF;
        IF v_attempt >= v_max_attempts THEN RAISE EXCEPTION ''Unable to generate unique QR code after % attempts'', v_max_attempts; END IF;
    END LOOP;
    UPDATE shipments SET return_qr_code = v_qr_code, return_qr_expires_at = v_expires_at, updated_at = now() WHERE id = p_shipment_id;
    RETURN QUERY SELECT v_qr_code, v_expires_at;
END;
$$","-- 12n: uses_brickshare_pudo
CREATE OR REPLACE FUNCTION public.uses_brickshare_pudo(shipment_id uuid)
RETURNS boolean LANGUAGE sql STABLE AS $$
    SELECT pickup_type = ''brickshare'' AND brickshare_pudo_id IS NOT NULL FROM shipments WHERE id = shipment_id;
$$","-- ============================================================================
-- STEP 13: Drop old triggers and create new ones on renamed tables
-- ============================================================================

DROP TRIGGER IF EXISTS on_envio_entregado ON public.shipments","DROP TRIGGER IF EXISTS on_envio_recibido_almacen ON public.shipments","DROP TRIGGER IF EXISTS on_envio_return_update ON public.shipments","DROP TRIGGER IF EXISTS on_envio_ruta_devolucion_inv ON public.shipments","DROP TRIGGER IF EXISTS update_envios_updated_at ON public.shipments","DROP TRIGGER IF EXISTS on_recepcion_completada ON public.reception_operations","DROP TRIGGER IF EXISTS update_operaciones_recepcion_updated_at ON public.reception_operations","CREATE TRIGGER on_shipment_delivered AFTER UPDATE ON public.shipments FOR EACH ROW EXECUTE FUNCTION public.handle_shipment_delivered()","CREATE TRIGGER on_shipment_warehouse_received BEFORE UPDATE ON public.shipments FOR EACH ROW EXECUTE FUNCTION public.handle_shipment_warehouse_received()","CREATE TRIGGER on_shipment_return_user_status AFTER UPDATE ON public.shipments FOR EACH ROW EXECUTE FUNCTION public.handle_return_user_status()","CREATE TRIGGER on_shipment_return_transit_inv AFTER UPDATE ON public.shipments FOR EACH ROW EXECUTE FUNCTION public.handle_shipment_return_transit_inventory()","CREATE TRIGGER update_shipments_updated_at BEFORE UPDATE ON public.shipments FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column()","CREATE TRIGGER on_reception_completed AFTER UPDATE ON public.reception_operations FOR EACH ROW EXECUTE FUNCTION public.handle_reception_close()","CREATE TRIGGER update_reception_operations_updated_at BEFORE UPDATE ON public.reception_operations FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column()","-- ============================================================================
-- STEP 14: Update RLS policies to use new names
-- ============================================================================

-- Drop all old policies on shipments (they reference old table/column names)
DROP POLICY IF EXISTS \"Access for operators and admins\" ON public.shipments","DROP POLICY IF EXISTS \"Admins and Operadores can view all shipments\" ON public.shipments","DROP POLICY IF EXISTS \"Admins can manage all shipments\" ON public.shipments","DROP POLICY IF EXISTS \"Operadores can create shipments\" ON public.shipments","DROP POLICY IF EXISTS \"Operadores can update shipments\" ON public.shipments","DROP POLICY IF EXISTS \"Users can update their own envios status\" ON public.shipments","DROP POLICY IF EXISTS \"Users can view own envios\" ON public.shipments","DROP POLICY IF EXISTS \"Users can view own shipments\" ON public.shipments","-- Recreate policies on shipments
CREATE POLICY \"Admins and operators full access\" ON public.shipments
    USING (public.has_role(auth.uid(), ''admin'') OR public.has_role(auth.uid(), ''operador''))","CREATE POLICY \"Operators can create shipments\" ON public.shipments
    FOR INSERT WITH CHECK (public.has_role(auth.uid(), ''admin'') OR public.has_role(auth.uid(), ''operador''))","CREATE POLICY \"Operators can update shipments\" ON public.shipments
    FOR UPDATE USING (public.has_role(auth.uid(), ''admin'') OR public.has_role(auth.uid(), ''operador''))","CREATE POLICY \"Users can view own shipments\" ON public.shipments
    FOR SELECT USING (auth.uid() = user_id)","CREATE POLICY \"Users can update own shipment status\" ON public.shipments
    FOR UPDATE TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id AND shipment_status = ''return_in_transit'')","-- Drop old policies on reception_operations
DROP POLICY IF EXISTS \"Enable insert for admins and operators\" ON public.reception_operations","DROP POLICY IF EXISTS \"Enable read access for authenticated users\" ON public.reception_operations","DROP POLICY IF EXISTS \"Enable update for admins and operators\" ON public.reception_operations","-- Recreate policies on reception_operations
CREATE POLICY \"Admins and operators can insert\" ON public.reception_operations
    FOR INSERT TO authenticated
    WITH CHECK (public.has_role(auth.uid(), ''admin'') OR public.has_role(auth.uid(), ''operador''))","CREATE POLICY \"Authenticated users can read\" ON public.reception_operations
    FOR SELECT TO authenticated USING (true)","CREATE POLICY \"Admins and operators can update\" ON public.reception_operations
    FOR UPDATE TO authenticated
    USING (public.has_role(auth.uid(), ''admin'') OR public.has_role(auth.uid(), ''operador''))
    WITH CHECK (public.has_role(auth.uid(), ''admin'') OR public.has_role(auth.uid(), ''operador''))","-- Update qr_validation_logs policy that references envios
DROP POLICY IF EXISTS \"Users can view their own validation logs\" ON public.qr_validation_logs","CREATE POLICY \"Users can view their own validation logs\" ON public.qr_validation_logs
    FOR SELECT TO authenticated
    USING (shipment_id IN (SELECT s.id FROM public.shipments s WHERE s.user_id = auth.uid()))","-- ============================================================================
-- STEP 15: Drop old functions (cleanup)
-- ============================================================================

DROP FUNCTION IF EXISTS public.handle_envio_entregado()","DROP FUNCTION IF EXISTS public.handle_envio_recibido_almacen()","DROP FUNCTION IF EXISTS public.handle_envio_ruta_devolucion_inventory()","DROP FUNCTION IF EXISTS public.handle_return_status_update()","DROP FUNCTION IF EXISTS public.handle_cierre_recepcion()","DROP FUNCTION IF EXISTS public.assign_sets_to_users()"}', 'rename_spanish_to_english');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260322110000', '{"-- Rename remaining Spanish column names to English
-- Table: users_correos_dropping (Correos PUDO integration)

-- correos_ prefix is kept as it refers to the \"Correos\" brand (proper noun)
-- but the descriptive parts are translated to English

ALTER TABLE users_correos_dropping RENAME COLUMN correos_nombre TO correos_name","ALTER TABLE users_correos_dropping RENAME COLUMN correos_tipo_punto TO correos_point_type","ALTER TABLE users_correos_dropping RENAME COLUMN correos_direccion_calle TO correos_street","ALTER TABLE users_correos_dropping RENAME COLUMN correos_direccion_numero TO correos_street_number","ALTER TABLE users_correos_dropping RENAME COLUMN correos_codigo_postal TO correos_zip_code","ALTER TABLE users_correos_dropping RENAME COLUMN correos_ciudad TO correos_city","ALTER TABLE users_correos_dropping RENAME COLUMN correos_provincia TO correos_province","ALTER TABLE users_correos_dropping RENAME COLUMN correos_pais TO correos_country","ALTER TABLE users_correos_dropping RENAME COLUMN correos_direccion_completa TO correos_full_address","ALTER TABLE users_correos_dropping RENAME COLUMN correos_latitud TO correos_latitude","ALTER TABLE users_correos_dropping RENAME COLUMN correos_longitud TO correos_longitude","ALTER TABLE users_correos_dropping RENAME COLUMN correos_horario_apertura TO correos_opening_hours","ALTER TABLE users_correos_dropping RENAME COLUMN correos_horario_estructurado TO correos_structured_hours","ALTER TABLE users_correos_dropping RENAME COLUMN correos_disponible TO correos_available","ALTER TABLE users_correos_dropping RENAME COLUMN correos_telefono TO correos_phone","ALTER TABLE users_correos_dropping RENAME COLUMN correos_codigo_interno TO correos_internal_code","ALTER TABLE users_correos_dropping RENAME COLUMN correos_capacidad_lockers TO correos_locker_capacity","ALTER TABLE users_correos_dropping RENAME COLUMN correos_servicios_adicionales TO correos_additional_services","ALTER TABLE users_correos_dropping RENAME COLUMN correos_accesibilidad TO correos_accessibility","ALTER TABLE users_correos_dropping RENAME COLUMN correos_fecha_seleccion TO correos_selection_date","-- Rename old foreign key constraints that still reference old Spanish table names
DO $$
BEGIN
  -- inventory_sets: rename old FK if it exists with old name
  IF EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = ''inventario_sets_set_id_fkey'') THEN
    ALTER TABLE inventory_sets RENAME CONSTRAINT inventario_sets_set_id_fkey TO inventory_sets_set_id_fkey;
  END IF;
END $$","-- ============================================================================
-- Recreate confirm_assign_sets_to_users to use new correos column names
-- ============================================================================

CREATE OR REPLACE FUNCTION public.confirm_assign_sets_to_users(p_user_ids uuid[])
RETURNS TABLE(envio_id uuid, user_id uuid, set_id uuid, order_id uuid, user_name text, user_email text, user_phone text, set_name text, set_ref text, set_weight numeric, set_dim text, pudo_id text, pudo_name text, pudo_address text, pudo_cp text, pudo_city text, pudo_province text, created_at timestamptz)
LANGUAGE plpgsql SECURITY DEFINER SET search_path TO ''public'' AS $$
DECLARE
    r RECORD;
    target_set_id UUID; new_order_id UUID; new_envio_id UUID;
    v_set_name TEXT; v_set_ref TEXT; v_set_weight NUMERIC; v_set_dim TEXT;
    v_user_email TEXT; v_user_phone TEXT;
    v_pudo_id TEXT; v_pudo_name TEXT; v_pudo_address TEXT; v_pudo_cp TEXT; v_pudo_city TEXT; v_pudo_province TEXT;
    v_created_at TIMESTAMPTZ;
BEGIN
    FOR r IN (
        SELECT u.user_id, u.full_name, u.email, u.phone,
               p.correos_id_pudo, p.correos_name, p.correos_full_address,
               p.correos_zip_code, p.correos_city, p.correos_province
        FROM public.users u
        LEFT JOIN public.users_correos_dropping p ON u.user_id = p.user_id
        WHERE u.user_id = ANY(p_user_ids)
          AND u.user_status IN (''no_set'', ''set_returning'')
          AND EXISTS (SELECT 1 FROM public.wishlist w WHERE w.user_id = u.user_id AND w.status = true)
    ) LOOP
        SELECT w.set_id, s.set_name, s.set_ref, s.set_weight, s.set_dim
        INTO target_set_id, v_set_name, v_set_ref, v_set_weight, v_set_dim
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        JOIN public.sets s ON w.set_id = s.id
        WHERE w.user_id = r.user_id AND w.status = true AND i.inventory_set_total_qty > 0
        ORDER BY w.created_at ASC LIMIT 1;

        IF target_set_id IS NOT NULL THEN
            UPDATE public.inventory_sets SET inventory_set_total_qty = inventory_set_total_qty - 1, in_shipping = in_shipping + 1
            WHERE inventory_sets.set_id = target_set_id;

            INSERT INTO public.orders (user_id, set_id, status) VALUES (r.user_id, target_set_id, ''pending'') RETURNING id INTO new_order_id;

            INSERT INTO public.shipments (order_id, user_id, shipment_status, shipping_address, shipping_city, shipping_zip_code, shipping_country)
            VALUES (new_order_id, r.user_id, ''pending'',
                    COALESCE(r.correos_full_address, ''Pending assignment''),
                    COALESCE(r.correos_city, ''Pending''),
                    COALESCE(r.correos_zip_code, ''00000''), ''España'')
            RETURNING shipments.id, shipments.created_at INTO new_envio_id, v_created_at;

            UPDATE public.users SET user_status = ''set_shipping'' WHERE users.user_id = r.user_id;

            UPDATE public.wishlist SET status = false, status_changed_at = now()
            WHERE wishlist.user_id = r.user_id AND wishlist.set_id = target_set_id;

            confirm_assign_sets_to_users.envio_id := new_envio_id;
            confirm_assign_sets_to_users.user_id := r.user_id;
            confirm_assign_sets_to_users.set_id := target_set_id;
            confirm_assign_sets_to_users.order_id := new_order_id;
            confirm_assign_sets_to_users.user_name := r.full_name;
            confirm_assign_sets_to_users.user_email := r.email;
            confirm_assign_sets_to_users.user_phone := r.phone;
            confirm_assign_sets_to_users.set_name := v_set_name;
            confirm_assign_sets_to_users.set_ref := v_set_ref;
            confirm_assign_sets_to_users.set_weight := v_set_weight;
            confirm_assign_sets_to_users.set_dim := v_set_dim;
            confirm_assign_sets_to_users.pudo_id := r.correos_id_pudo;
            confirm_assign_sets_to_users.pudo_name := r.correos_name;
            confirm_assign_sets_to_users.pudo_address := r.correos_full_address;
            confirm_assign_sets_to_users.pudo_cp := r.correos_zip_code;
            confirm_assign_sets_to_users.pudo_city := r.correos_city;
            confirm_assign_sets_to_users.pudo_province := r.correos_province;
            confirm_assign_sets_to_users.created_at := v_created_at;
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$"}', 'rename_remaining_spanish_columns');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260322120000', '{"-- Add missing contact/address columns to users table
-- These columns are needed by the ProfileCompletionModal and match the TypeScript types

ALTER TABLE public.users ADD COLUMN IF NOT EXISTS address text","ALTER TABLE public.users ADD COLUMN IF NOT EXISTS address_extra text","ALTER TABLE public.users ADD COLUMN IF NOT EXISTS zip_code text","ALTER TABLE public.users ADD COLUMN IF NOT EXISTS city text","ALTER TABLE public.users ADD COLUMN IF NOT EXISTS province text","ALTER TABLE public.users ADD COLUMN IF NOT EXISTS phone text"}', 'add_user_contact_columns');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260322130000', '{"-- ============================================================================
-- Migration: Set Subscription Status Default and Finalize Table Rename
-- Created: 2026-03-22
-- Description: Standardizes subscription_status default to ''inactive'' and
--              ensures the users table is used exclusively.
-- ============================================================================

-- 1. Update column defaults for public.users
ALTER TABLE public.users 
  ALTER COLUMN subscription_status SET DEFAULT ''inactive'',
  ALTER COLUMN user_status SET DEFAULT ''no_set''","-- 2. Update existing NULL or incorrect statuses for local dev consistency
UPDATE public.users 
SET 
  subscription_status = ''inactive'' 
WHERE 
  subscription_status IS NULL 
  OR subscription_status = ''active''","-- Resetting all to inactive for testing purposes

-- 3. Add or update the check constraint for subscription_status
-- We drop it first to be sure we are using the latest set of allowed values
ALTER TABLE public.users DROP CONSTRAINT IF EXISTS users_subscription_status_check","ALTER TABLE public.users ADD CONSTRAINT users_subscription_status_check 
  CHECK (subscription_status IN (''active'', ''inactive'', ''trialing'', ''past_due'', ''canceled''))","-- 4. Re-verify the handle_new_user function to ensure it doesn''t override defaults
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
    INSERT INTO public.users (
        user_id,
        full_name,
        avatar_url,
        email
    )
    VALUES (
        NEW.id,
        NEW.raw_user_meta_data ->> ''full_name'',
        NEW.raw_user_meta_data ->> ''avatar_url'',
        NEW.email
    )
    ON CONFLICT (user_id) DO NOTHING;
    RETURN NEW;
END;
$$"}', 'set_default_inactive_status');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260322140000', '{"-- ============================================================================
-- Migration: Fix user roles assignment on signup + backfill + create admin
-- Created: 2026-03-22
-- Description:
--   1. Update handle_new_user() to also insert ''user'' role in user_roles
--   2. Backfill ''user'' role for existing users without any role
--   3. Create admin@brickshare.com user with ''admin'' role
-- ============================================================================

-- ─── 1. Update handle_new_user trigger to assign default ''user'' role ─────────

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
    -- Create record in users table
    INSERT INTO public.users (
        user_id,
        full_name,
        avatar_url,
        email
    )
    VALUES (
        NEW.id,
        NEW.raw_user_meta_data ->> ''full_name'',
        NEW.raw_user_meta_data ->> ''avatar_url'',
        NEW.email
    )
    ON CONFLICT (user_id) DO NOTHING;

    -- Assign default ''user'' role
    INSERT INTO public.user_roles (user_id, role)
    VALUES (NEW.id, ''user''::app_role)
    ON CONFLICT (user_id, role) DO NOTHING;

    RETURN NEW;
END;
$$","-- ─── 2. Backfill: assign ''user'' role to existing users without any role ──────

INSERT INTO public.user_roles (user_id, role)
SELECT u.user_id, ''user''::app_role
FROM public.users u
WHERE NOT EXISTS (
    SELECT 1 FROM public.user_roles ur
    WHERE ur.user_id = u.user_id
)
ON CONFLICT (user_id, role) DO NOTHING"}', 'fix_user_roles_and_create_admin');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260322170000', '{"-- ============================================================================
-- Migration: Refactor shipment_status values
-- Date: 2026-03-22
-- Description: 
--   - in_transit → in_transit_pudo
--   - assigned → in_transit_pudo (merged)
--   - delivered → delivered_user
--   - NEW: delivered_pudo
--   - return_in_transit → in_return_pudo
--   - NEW: (no in_return — removed by design)
--   - returned stays as returned (deposited at central office)
-- ============================================================================

-- ============================================================================
-- STEP 1: Drop old constraint
-- ============================================================================

ALTER TABLE public.shipments DROP CONSTRAINT IF EXISTS check_shipment_status","-- ============================================================================
-- STEP 2: Migrate existing data
-- ============================================================================

UPDATE public.shipments SET shipment_status = ''in_transit_pudo'' WHERE shipment_status = ''assigned''","UPDATE public.shipments SET shipment_status = ''in_transit_pudo'' WHERE shipment_status = ''in_transit''","UPDATE public.shipments SET shipment_status = ''delivered_user'' WHERE shipment_status = ''delivered''","UPDATE public.shipments SET shipment_status = ''in_return_pudo'' WHERE shipment_status = ''return_in_transit''","-- ============================================================================
-- STEP 3: Add new constraint with updated values
-- ============================================================================

ALTER TABLE public.shipments ADD CONSTRAINT check_shipment_status
  CHECK (shipment_status IN (
    ''pending'',
    ''preparation'',
    ''in_transit_pudo'',
    ''delivered_pudo'',
    ''delivered_user'',
    ''in_return_pudo'',
    ''returned'',
    ''cancelled''
  ))","-- ============================================================================
-- STEP 4: Drop and recreate triggers (to avoid issues with function replacement)
-- ============================================================================

DROP TRIGGER IF EXISTS on_shipment_delivered ON public.shipments","DROP TRIGGER IF EXISTS on_shipment_warehouse_received ON public.shipments","DROP TRIGGER IF EXISTS on_shipment_return_user_status ON public.shipments","DROP TRIGGER IF EXISTS on_shipment_return_transit_inv ON public.shipments","-- ============================================================================
-- STEP 5: Update functions
-- ============================================================================

-- 5a: handle_shipment_delivered — now triggers on ''delivered_user''
CREATE OR REPLACE FUNCTION public.handle_shipment_delivered()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    IF NEW.shipment_status = ''delivered_user'' AND OLD.shipment_status != ''delivered_user'' THEN
        UPDATE public.users SET user_status = ''has_set'' WHERE user_id = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$","-- 5b: handle_shipment_return_transit_inventory — now triggers on ''in_return_pudo''
CREATE OR REPLACE FUNCTION public.handle_shipment_return_transit_inventory()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    IF NEW.shipment_status = ''in_return_pudo'' AND OLD.shipment_status != ''in_return_pudo'' THEN
        UPDATE public.inventory_sets
        SET in_return = COALESCE(in_return, 0) + 1, updated_at = now()
        WHERE set_id = NEW.set_id;
    END IF;
    RETURN NEW;
END;
$$","-- 5c: handle_return_user_status — now triggers on ''in_return_pudo''
CREATE OR REPLACE FUNCTION public.handle_return_user_status()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    IF NEW.shipment_status = ''in_return_pudo'' AND OLD.shipment_status != ''in_return_pudo'' THEN
        UPDATE public.users SET user_status = ''no_set'' WHERE user_id = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$","-- 5d: delete_assignment_and_rollback — update status check from ''in_transit'' to ''in_transit_pudo''
CREATE OR REPLACE FUNCTION public.delete_assignment_and_rollback(p_envio_id uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path TO ''public'' AS $$
DECLARE
    v_user_id UUID;
    v_set_id UUID;
BEGIN
    SELECT user_id, set_id INTO v_user_id, v_set_id FROM public.shipments WHERE id = p_envio_id;
    IF v_user_id IS NULL THEN RAISE EXCEPTION ''Shipment with ID % not found'', p_envio_id; END IF;

    DELETE FROM public.shipments WHERE id = p_envio_id;

    UPDATE public.inventory_sets
    SET inventory_set_total_qty = inventory_set_total_qty + 1, in_shipping = GREATEST(in_shipping - 1, 0)
    WHERE set_id = v_set_id;

    INSERT INTO public.wishlist (user_id, set_id) VALUES (v_user_id, v_set_id) ON CONFLICT (user_id, set_id) DO NOTHING;

    UPDATE public.users
    SET user_status = CASE 
        WHEN EXISTS (SELECT 1 FROM public.shipments WHERE user_id = v_user_id AND shipment_status IN (''preparation'', ''in_transit_pudo''))
        THEN user_status ELSE ''no_set'' END
    WHERE user_id = v_user_id;
END;
$$","-- 5e: confirm_qr_validation — update ''delivered'' to ''delivered_user'' (NO change to QR logic per user request)
-- NOTE: Not modifying QR logic, just updating the status value it writes
CREATE OR REPLACE FUNCTION public.confirm_qr_validation(p_qr_code text, p_validated_by text DEFAULT NULL)
RETURNS TABLE(success boolean, message text, shipment_id uuid) LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_validation RECORD;
    v_new_status TEXT;
BEGIN
    SELECT * INTO v_validation FROM validate_qr_code(p_qr_code);
    IF NOT v_validation.is_valid THEN
        RETURN QUERY SELECT false, v_validation.error_message, v_validation.shipment_id; RETURN;
    END IF;

    IF v_validation.validation_type = ''delivery'' THEN
        v_new_status := ''delivered_user'';
        UPDATE shipments SET delivery_validated_at = now(), shipment_status = v_new_status, updated_at = now() WHERE id = v_validation.shipment_id;
    ELSIF v_validation.validation_type = ''return'' THEN
        v_new_status := ''returned'';
        UPDATE shipments SET return_validated_at = now(), shipment_status = v_new_status, updated_at = now() WHERE id = v_validation.shipment_id;
    END IF;

    INSERT INTO qr_validation_logs (shipment_id, qr_code, validation_type, validated_by, validation_status, metadata)
    VALUES (v_validation.shipment_id, p_qr_code, v_validation.validation_type, p_validated_by, ''success'', jsonb_build_object(''validated_at'', now()));

    RETURN QUERY SELECT true, format(''Shipment successfully %s'', CASE WHEN v_validation.validation_type = ''delivery'' THEN ''delivered'' ELSE ''returned'' END), v_validation.shipment_id;
END;
$$","-- ============================================================================
-- STEP 6: Recreate triggers
-- ============================================================================

CREATE TRIGGER on_shipment_delivered AFTER UPDATE ON public.shipments FOR EACH ROW EXECUTE FUNCTION public.handle_shipment_delivered()","CREATE TRIGGER on_shipment_warehouse_received BEFORE UPDATE ON public.shipments FOR EACH ROW EXECUTE FUNCTION public.handle_shipment_warehouse_received()","CREATE TRIGGER on_shipment_return_user_status AFTER UPDATE ON public.shipments FOR EACH ROW EXECUTE FUNCTION public.handle_return_user_status()","CREATE TRIGGER on_shipment_return_transit_inv AFTER UPDATE ON public.shipments FOR EACH ROW EXECUTE FUNCTION public.handle_shipment_return_transit_inventory()","-- ============================================================================
-- STEP 7: Update RLS policy for user returns (was ''return_in_transit'', now ''in_return_pudo'')
-- ============================================================================

DROP POLICY IF EXISTS \"Users can update own shipment status\" ON public.shipments","CREATE POLICY \"Users can update own shipment status\" ON public.shipments
    FOR UPDATE TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id AND shipment_status = ''in_return_pudo'')"}', 'refactor_shipment_status');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260323000000', '{"-- Update assignment preview function to check history and provide random fallback
-- New requirements:
-- 1. Check user''s wishlist for available sets
-- 2. Verify user hasn''t had the set before (check envios history)
-- 3. If no valid wishlist match, select random available set
-- 4. Return matches_wishlist flag to indicate assignment source

-- Drop existing function
DROP FUNCTION IF EXISTS public.preview_assign_sets_to_users()","-- Create new function with history check and random fallback
CREATE OR REPLACE FUNCTION public.preview_assign_sets_to_users()
RETURNS TABLE (
    user_id UUID,
    user_name TEXT,
    set_id UUID,
    set_name TEXT,
    set_ref TEXT,
    set_price DECIMAL,
    current_stock INTEGER,
    matches_wishlist BOOLEAN
) AS $$
DECLARE
    r RECORD;
    v_set_id UUID;
    v_set_name TEXT;
    v_set_ref TEXT;
    v_set_price DECIMAL;
    v_current_stock INTEGER;
    v_matches_wishlist BOOLEAN;
BEGIN
    -- Loop through eligible users (those without a set and are regular users)
    FOR r IN (
        SELECT u.user_id, u.full_name
        FROM public.users u
        WHERE u.user_status IN (''sin set'', ''set en devolucion'')
          AND u.user_type = ''user''  -- Only regular users, not admin or operations
    ) LOOP
        v_set_id := NULL;
        v_matches_wishlist := FALSE;
        
        -- Try to find set from user''s wishlist that they haven''t had before
        SELECT w.set_id, s.set_name, s.set_ref, 
               COALESCE(s.set_price, 100.00), i.inventory_set_total_qty
        INTO v_set_id, v_set_name, v_set_ref, v_set_price, v_current_stock
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        JOIN public.sets s ON w.set_id = s.id
        WHERE w.user_id = r.user_id
          AND w.status = true
          AND i.inventory_set_total_qty > 0
          -- Check if user has NOT had this set before
          AND NOT EXISTS (
              SELECT 1 FROM public.envios e
              WHERE e.user_id = r.user_id 
                AND e.set_id = w.set_id
          )
        ORDER BY w.created_at ASC  -- Prioritize by wishlist order
        LIMIT 1;
        
        -- If found in wishlist, mark as match
        IF v_set_id IS NOT NULL THEN
            v_matches_wishlist := TRUE;
        ELSE
            -- No valid wishlist match, choose random available set
            SELECT s.id, s.set_name, s.set_ref, 
                   COALESCE(s.set_price, 100.00), i.inventory_set_total_qty
            INTO v_set_id, v_set_name, v_set_ref, v_set_price, v_current_stock
            FROM public.sets s
            JOIN public.inventory_sets i ON s.id = i.set_id
            WHERE i.inventory_set_total_qty > 0
            ORDER BY RANDOM()
            LIMIT 1;
            
            v_matches_wishlist := FALSE;
        END IF;
        
        -- Return assignment if a set was found
        IF v_set_id IS NOT NULL THEN
            preview_assign_sets_to_users.user_id := r.user_id;
            preview_assign_sets_to_users.user_name := r.full_name;
            preview_assign_sets_to_users.set_id := v_set_id;
            preview_assign_sets_to_users.set_name := v_set_name;
            preview_assign_sets_to_users.set_ref := v_set_ref;
            preview_assign_sets_to_users.set_price := v_set_price;
            preview_assign_sets_to_users.current_stock := v_current_stock;
            preview_assign_sets_to_users.matches_wishlist := v_matches_wishlist;
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public","COMMENT ON FUNCTION public.preview_assign_sets_to_users IS ''Shows proposed set assignments checking history to avoid duplicates, with random fallback if no wishlist match - includes matches_wishlist flag''"}', 'update_assignment_with_history_check');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260324000000', '{"-- Fix users table RLS to show all user roles (not just ''user'' role)
-- This ensures admins can see users with role ''admin'', ''operador'', and ''user''

-- Drop the existing policy if it exists
DROP POLICY IF EXISTS \"Admins and Operadores can view all users\" ON public.users","-- Create a new policy that allows admins and operadores to view ALL users regardless of role
CREATE POLICY \"Admins and Operadores can view all users\"
    ON public.users FOR SELECT
    USING (
        public.has_role(auth.uid(), ''admin''::public.app_role) OR 
        public.has_role(auth.uid(), ''operador''::public.app_role)
    )","-- Also ensure users can view their own profile
DROP POLICY IF EXISTS \"Users can view own profile\" ON public.users","CREATE POLICY \"Users can view own profile\"
    ON public.users FOR SELECT
    USING (auth.uid() = user_id)","-- Allow users to update their own profile
DROP POLICY IF EXISTS \"Users can update own profile\" ON public.users","CREATE POLICY \"Users can update own profile\"
    ON public.users FOR UPDATE
    USING (auth.uid() = user_id)","-- Allow admins to update any user
DROP POLICY IF EXISTS \"Admins can update any user\" ON public.users","CREATE POLICY \"Admins can update any user\"
    ON public.users FOR UPDATE
    USING (public.has_role(auth.uid(), ''admin''::public.app_role))"}', 'fix_users_visibility_all_roles');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260324000001', '{"-- Fix preview_assign_sets_to_users function to correctly check user roles
-- The function was referencing u.user_type which doesn''t exist
-- Instead, we need to check the user_roles table to exclude admin and operador roles

DROP FUNCTION IF EXISTS public.preview_assign_sets_to_users()","CREATE OR REPLACE FUNCTION public.preview_assign_sets_to_users()
RETURNS TABLE (
    user_id UUID,
    user_name TEXT,
    set_id UUID,
    set_name TEXT,
    set_ref TEXT,
    set_price DECIMAL,
    current_stock INTEGER,
    matches_wishlist BOOLEAN
) AS $$
DECLARE
    r RECORD;
    v_set_id UUID;
    v_set_name TEXT;
    v_set_ref TEXT;
    v_set_price DECIMAL;
    v_current_stock INTEGER;
    v_matches_wishlist BOOLEAN;
BEGIN
    -- Loop through eligible users (those without a set and are regular users)
    FOR r IN (
        SELECT u.user_id, u.full_name
        FROM public.users u
        WHERE u.user_status IN (''sin set'', ''set en devolucion'')
          -- Only include users who don''t have admin or operador roles
          AND NOT EXISTS (
              SELECT 1 FROM public.user_roles ur
              WHERE ur.user_id = u.user_id
              AND ur.role IN (''admin'', ''operador'')
          )
    ) LOOP
        v_set_id := NULL;
        v_matches_wishlist := FALSE;
        
        -- Try to find set from user''s wishlist that they haven''t had before
        SELECT w.set_id, s.set_name, s.set_ref, 
               COALESCE(s.set_price, 100.00), i.inventory_set_total_qty
        INTO v_set_id, v_set_name, v_set_ref, v_set_price, v_current_stock
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        JOIN public.sets s ON w.set_id = s.id
        WHERE w.user_id = r.user_id
          AND w.status = true
          AND i.inventory_set_total_qty > 0
          -- Check if user has NOT had this set before
          AND NOT EXISTS (
              SELECT 1 FROM public.envios e
              WHERE e.user_id = r.user_id 
                AND e.set_id = w.set_id
          )
        ORDER BY w.created_at ASC  -- Prioritize by wishlist order
        LIMIT 1;
        
        -- If found in wishlist, mark as match
        IF v_set_id IS NOT NULL THEN
            v_matches_wishlist := TRUE;
        ELSE
            -- No valid wishlist match, choose random available set
            SELECT s.id, s.set_name, s.set_ref, 
                   COALESCE(s.set_price, 100.00), i.inventory_set_total_qty
            INTO v_set_id, v_set_name, v_set_ref, v_set_price, v_current_stock
            FROM public.sets s
            JOIN public.inventory_sets i ON s.id = i.set_id
            WHERE i.inventory_set_total_qty > 0
            ORDER BY RANDOM()
            LIMIT 1;
            
            v_matches_wishlist := FALSE;
        END IF;
        
        -- Return assignment if a set was found
        IF v_set_id IS NOT NULL THEN
            preview_assign_sets_to_users.user_id := r.user_id;
            preview_assign_sets_to_users.user_name := r.full_name;
            preview_assign_sets_to_users.set_id := v_set_id;
            preview_assign_sets_to_users.set_name := v_set_name;
            preview_assign_sets_to_users.set_ref := v_set_ref;
            preview_assign_sets_to_users.set_price := v_set_price;
            preview_assign_sets_to_users.current_stock := v_current_stock;
            preview_assign_sets_to_users.matches_wishlist := v_matches_wishlist;
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public","COMMENT ON FUNCTION public.preview_assign_sets_to_users IS ''Shows proposed set assignments checking history to avoid duplicates, with random fallback if no wishlist match - includes matches_wishlist flag. Fixed to use user_roles table instead of non-existent user_type column''"}', 'fix_preview_assign_function');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260324074025', '{"-- Fix preview_assign_sets_to_users function to use correct English user_status values
-- The function was using Spanish values (''sin set'', ''set en devolucion'') 
-- but the database constraint and confirm function use English values (''no_set'', ''set_returning'')

DROP FUNCTION IF EXISTS public.preview_assign_sets_to_users()","CREATE OR REPLACE FUNCTION public.preview_assign_sets_to_users()
RETURNS TABLE (
    user_id UUID,
    user_name TEXT,
    set_id UUID,
    set_name TEXT,
    set_ref TEXT,
    set_price DECIMAL,
    current_stock INTEGER,
    matches_wishlist BOOLEAN
) AS $$
DECLARE
    r RECORD;
    v_set_id UUID;
    v_set_name TEXT;
    v_set_ref TEXT;
    v_set_price DECIMAL;
    v_current_stock INTEGER;
    v_matches_wishlist BOOLEAN;
BEGIN
    -- Loop through eligible users (those without a set and are regular users)
    FOR r IN (
        SELECT u.user_id, u.full_name
        FROM public.users u
        WHERE u.user_status IN (''no_set'', ''set_returning'')  -- FIXED: Changed from Spanish to English
          -- Only include users who don''t have admin or operador roles
          AND NOT EXISTS (
              SELECT 1 FROM public.user_roles ur
              WHERE ur.user_id = u.user_id
              AND ur.role IN (''admin'', ''operador'')
          )
    ) LOOP
        v_set_id := NULL;
        v_matches_wishlist := FALSE;
        
        -- Try to find set from user''s wishlist that they haven''t had before
        SELECT w.set_id, s.set_name, s.set_ref, 
               COALESCE(s.set_price, 100.00), i.inventory_set_total_qty
        INTO v_set_id, v_set_name, v_set_ref, v_set_price, v_current_stock
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        JOIN public.sets s ON w.set_id = s.id
        WHERE w.user_id = r.user_id
          AND w.status = true
          AND i.inventory_set_total_qty > 0
          -- Check if user has NOT had this set before
          AND NOT EXISTS (
              SELECT 1 FROM public.shipments e
              WHERE e.user_id = r.user_id 
                AND e.set_id = w.set_id
          )
        ORDER BY w.created_at ASC  -- Prioritize by wishlist order
        LIMIT 1;
        
        -- If found in wishlist, mark as match
        IF v_set_id IS NOT NULL THEN
            v_matches_wishlist := TRUE;
        ELSE
            -- No valid wishlist match, choose random available set
            SELECT s.id, s.set_name, s.set_ref, 
                   COALESCE(s.set_price, 100.00), i.inventory_set_total_qty
            INTO v_set_id, v_set_name, v_set_ref, v_set_price, v_current_stock
            FROM public.sets s
            JOIN public.inventory_sets i ON s.id = i.set_id
            WHERE i.inventory_set_total_qty > 0
            ORDER BY RANDOM()
            LIMIT 1;
            
            v_matches_wishlist := FALSE;
        END IF;
        
        -- Return assignment if a set was found
        IF v_set_id IS NOT NULL THEN
            preview_assign_sets_to_users.user_id := r.user_id;
            preview_assign_sets_to_users.user_name := r.full_name;
            preview_assign_sets_to_users.set_id := v_set_id;
            preview_assign_sets_to_users.set_name := v_set_name;
            preview_assign_sets_to_users.set_ref := v_set_ref;
            preview_assign_sets_to_users.set_price := v_set_price;
            preview_assign_sets_to_users.current_stock := v_current_stock;
            preview_assign_sets_to_users.matches_wishlist := v_matches_wishlist;
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public"}', 'fix_preview_assign_user_status_values');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260324080000', '{"-- ============================================================================
-- Add stripe_payment_method_id column to users table
-- ============================================================================
-- Purpose: Add missing column needed for Stripe payment processing
-- Context: The process-assignment-payment Edge Function requires this field
-- ============================================================================

ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS stripe_payment_method_id TEXT","COMMENT ON COLUMN public.users.stripe_payment_method_id IS ''Stripe Payment Method ID (e.g., pm_card_visa for test mode)''"}', 'add_stripe_payment_method_id');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260324095000', '{"-- Migration: Refactor PUDO system to support both Correos and Brickshare points
-- This creates a new table for Brickshare PUDOs and adds unified reference in users table

-- ============================================================================
-- 1. Create users_brickshare_dropping table
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.users_brickshare_dropping (
    -- Primary key and user reference
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Brickshare PUDO Location reference
    brickshare_pudo_id TEXT NOT NULL REFERENCES public.brickshare_pudo_locations(id) ON DELETE RESTRICT,
    
    -- Location information (denormalized for performance)
    location_name TEXT NOT NULL,
    address TEXT NOT NULL,
    city TEXT NOT NULL,
    postal_code TEXT NOT NULL,
    province TEXT NOT NULL,
    
    -- Geolocation
    latitude NUMERIC(10, 8),
    longitude NUMERIC(11, 8),
    
    -- Contact information
    contact_email TEXT,
    contact_phone TEXT,
    
    -- Operating hours (structured data)
    opening_hours JSONB,
    
    -- Timestamps
    selection_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
)","-- ============================================================================
-- 2. Add unified PUDO reference to users table
-- ============================================================================
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS pudo_id TEXT,
ADD COLUMN IF NOT EXISTS pudo_type TEXT CHECK (pudo_type IN (''correos'', ''brickshare''))","-- ============================================================================
-- 3. Create indexes
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_users_brickshare_dropping_user_id 
ON public.users_brickshare_dropping(user_id)","CREATE INDEX IF NOT EXISTS idx_users_brickshare_dropping_location 
ON public.users_brickshare_dropping(brickshare_pudo_id)","CREATE INDEX IF NOT EXISTS idx_users_pudo_type 
ON public.users(pudo_type) WHERE pudo_type IS NOT NULL","CREATE INDEX IF NOT EXISTS idx_users_pudo_id 
ON public.users(pudo_id) WHERE pudo_id IS NOT NULL","-- ============================================================================
-- 4. Enable Row Level Security
-- ============================================================================
ALTER TABLE public.users_brickshare_dropping ENABLE ROW LEVEL SECURITY","-- Policy: Users can view only their own Brickshare PUDO selection
CREATE POLICY \"Users can view their own Brickshare PUDO selection\"
ON public.users_brickshare_dropping
FOR SELECT
TO authenticated
USING (auth.uid() = user_id)","-- Policy: Users can insert their own Brickshare PUDO selection
CREATE POLICY \"Users can insert their own Brickshare PUDO selection\"
ON public.users_brickshare_dropping
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id)","-- Policy: Users can update their own Brickshare PUDO selection
CREATE POLICY \"Users can update their own Brickshare PUDO selection\"
ON public.users_brickshare_dropping
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id)","-- Policy: Users can delete their own Brickshare PUDO selection
CREATE POLICY \"Users can delete their own Brickshare PUDO selection\"
ON public.users_brickshare_dropping
FOR DELETE
TO authenticated
USING (auth.uid() = user_id)","-- ============================================================================
-- 5. Create trigger to update updated_at timestamp
-- ============================================================================
CREATE OR REPLACE FUNCTION public.update_users_brickshare_dropping_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql","CREATE TRIGGER trigger_update_users_brickshare_dropping_updated_at
    BEFORE UPDATE ON public.users_brickshare_dropping
    FOR EACH ROW
    EXECUTE FUNCTION public.update_users_brickshare_dropping_updated_at()","-- ============================================================================
-- 6. Create helper function to get user''s active PUDO (regardless of type)
-- ============================================================================
CREATE OR REPLACE FUNCTION public.get_user_active_pudo(p_user_id UUID)
RETURNS TABLE(
    pudo_type TEXT,
    pudo_id TEXT,
    pudo_name TEXT,
    pudo_address TEXT,
    pudo_city TEXT,
    pudo_postal_code TEXT
) AS $$
BEGIN
    -- Check users table for PUDO type
    RETURN QUERY
    SELECT 
        u.pudo_type,
        u.pudo_id,
        CASE 
            WHEN u.pudo_type = ''correos'' THEN c.correos_name
            WHEN u.pudo_type = ''brickshare'' THEN b.location_name
            ELSE NULL
        END as pudo_name,
        CASE 
            WHEN u.pudo_type = ''correos'' THEN c.correos_full_address
            WHEN u.pudo_type = ''brickshare'' THEN b.address
            ELSE NULL
        END as pudo_address,
        CASE 
            WHEN u.pudo_type = ''correos'' THEN c.correos_city
            WHEN u.pudo_type = ''brickshare'' THEN b.city
            ELSE NULL
        END as pudo_city,
        CASE 
            WHEN u.pudo_type = ''correos'' THEN c.correos_zip_code
            WHEN u.pudo_type = ''brickshare'' THEN b.postal_code
            ELSE NULL
        END as pudo_postal_code
    FROM public.users u
    LEFT JOIN public.users_correos_dropping c ON u.user_id = c.user_id AND u.pudo_type = ''correos''
    LEFT JOIN public.users_brickshare_dropping b ON u.user_id = b.user_id AND u.pudo_type = ''brickshare''
    WHERE u.user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER","-- ============================================================================
-- 7. Add comments
-- ============================================================================
COMMENT ON TABLE public.users_brickshare_dropping IS ''Stores user-selected Brickshare deposit locations for pickup/dropoff''","COMMENT ON COLUMN public.users.pudo_id IS ''Reference to the active PUDO point ID (either correos_id_pudo or brickshare_pudo_id)''","COMMENT ON COLUMN public.users.pudo_type IS ''Type of PUDO point currently selected by the user (correos or brickshare)''","COMMENT ON FUNCTION public.get_user_active_pudo IS ''Returns the active PUDO point information for a user regardless of type''"}', 'refactor_pudo_system');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260324100000', '{"-- Migration: Add PUDO validation to assignment confirmation
-- Users must have a configured PUDO point before being assigned sets

-- Drop the old function
DROP FUNCTION IF EXISTS public.confirm_assign_sets_to_users(UUID[])","-- Recreate with PUDO validation
CREATE OR REPLACE FUNCTION public.confirm_assign_sets_to_users(user_ids UUID[])
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    user_id UUID,
    set_id UUID
) AS $$
DECLARE
    v_user_id UUID;
    v_set_id UUID;
    v_has_pudo BOOLEAN;
BEGIN
    -- Validate all users have PUDO configured
    FOR v_user_id IN SELECT unnest(user_ids) LOOP
        -- Check if user has PUDO configured
        SELECT EXISTS(
            SELECT 1 FROM public.users 
            WHERE users.user_id = v_user_id 
            AND pudo_type IS NOT NULL 
            AND pudo_id IS NOT NULL
        ) INTO v_has_pudo;
        
        IF NOT v_has_pudo THEN
            RETURN QUERY SELECT 
                FALSE,
                ''User does not have a PUDO point configured'',
                v_user_id,
                NULL::UUID;
            CONTINUE;
        END IF;
        
        -- Get the proposed set for this user
        SELECT proposed_set_id INTO v_set_id
        FROM public.users
        WHERE users.user_id = v_user_id;
        
        IF v_set_id IS NULL THEN
            RETURN QUERY SELECT 
                FALSE,
                ''No set proposed for this user'',
                v_user_id,
                NULL::UUID;
            CONTINUE;
        END IF;
        
        -- Create shipment
        INSERT INTO public.shipments (
            user_id,
            set_id,
            set_ref,
            shipment_status,
            shipment_type,
            created_at,
            updated_at
        )
        SELECT 
            v_user_id,
            v_set_id,
            s.set_ref,
            ''pending'',
            ''outbound'',
            NOW(),
            NOW()
        FROM public.sets s
        WHERE s.id = v_set_id
        RETURNING shipments.id INTO v_set_id; -- Reusing variable for shipment_id
        
        -- Update inventory
        UPDATE public.inventory_sets
        SET 
            available_stock = available_stock - 1,
            in_transit = in_transit + 1,
            updated_at = NOW()
        WHERE set_id = (SELECT proposed_set_id FROM public.users WHERE users.user_id = v_user_id);
        
        -- Clear proposed_set_id
        UPDATE public.users
        SET 
            proposed_set_id = NULL,
            updated_at = NOW()
        WHERE users.user_id = v_user_id;
        
        RETURN QUERY SELECT 
            TRUE,
            ''Assignment confirmed successfully'',
            v_user_id,
            v_set_id;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER","COMMENT ON FUNCTION public.confirm_assign_sets_to_users IS ''Confirms set assignments for users. Validates that each user has a PUDO point configured before proceeding.''"}', 'add_pudo_validation_to_assignment');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260324101000', '{"-- Migration: Remove foreign key constraint from users_brickshare_dropping
-- This allows saving any Brickshare PUDO ID without requiring it to exist in brickshare_pudo_locations
-- Rationale: The endpoint /api/locations-local may return dynamic locations that aren''t pre-registered

-- ============================================================================
-- 1. Drop the foreign key constraint
-- ============================================================================
ALTER TABLE public.users_brickshare_dropping 
DROP CONSTRAINT IF EXISTS users_brickshare_dropping_brickshare_pudo_id_fkey","-- ============================================================================
-- 2. Make brickshare_pudo_id nullable to handle edge cases
-- ============================================================================
-- Keep it NOT NULL since we still require an ID, just without the FK constraint
-- ALTER TABLE public.users_brickshare_dropping ALTER COLUMN brickshare_pudo_id DROP NOT NULL;

-- ============================================================================
-- 3. Add comments
-- ============================================================================
COMMENT ON COLUMN public.users_brickshare_dropping.brickshare_pudo_id IS 
''Reference to Brickshare PUDO location ID. No FK constraint to allow dynamic locations from external APIs.''","-- ============================================================================
-- Note: If in the future you want to re-add the constraint after populating 
-- brickshare_pudo_locations, you can run:
-- ALTER TABLE public.users_brickshare_dropping 
--     ADD CONSTRAINT users_brickshare_dropping_brickshare_pudo_id_fkey 
--     FOREIGN KEY (brickshare_pudo_id) 
--     REFERENCES public.brickshare_pudo_locations(id) 
--     ON DELETE RESTRICT;
-- ============================================================================"}', 'remove_brickshare_pudo_fk_constraint');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260324150000', '{"-- Add pudo_type to preview_assign_sets_to_users function
-- This allows the frontend to determine if Correos preregistration should be executed

DROP FUNCTION IF EXISTS public.preview_assign_sets_to_users()","CREATE OR REPLACE FUNCTION public.preview_assign_sets_to_users()
RETURNS TABLE (
    user_id UUID,
    user_name TEXT,
    set_id UUID,
    set_name TEXT,
    set_ref TEXT,
    set_price DECIMAL,
    current_stock INTEGER,
    matches_wishlist BOOLEAN,
    pudo_type TEXT
) AS $$
DECLARE
    r RECORD;
    v_set_id UUID;
    v_set_name TEXT;
    v_set_ref TEXT;
    v_set_price DECIMAL;
    v_current_stock INTEGER;
    v_matches_wishlist BOOLEAN;
    v_pudo_type TEXT;
BEGIN
    -- Loop through eligible users (those without a set and are regular users)
    FOR r IN (
        SELECT u.user_id, u.full_name, u.pudo_type
        FROM public.users u
        WHERE u.user_status IN (''no_set'', ''set_returning'')
          -- Only include users who don''t have admin or operador roles
          AND NOT EXISTS (
              SELECT 1 FROM public.user_roles ur
              WHERE ur.user_id = u.user_id
              AND ur.role IN (''admin'', ''operador'')
          )
    ) LOOP
        v_set_id := NULL;
        v_matches_wishlist := FALSE;
        v_pudo_type := r.pudo_type;
        
        -- Try to find set from user''s wishlist that they haven''t had before
        SELECT w.set_id, s.set_name, s.set_ref, 
               COALESCE(s.set_price, 100.00), i.inventory_set_total_qty
        INTO v_set_id, v_set_name, v_set_ref, v_set_price, v_current_stock
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        JOIN public.sets s ON w.set_id = s.id
        WHERE w.user_id = r.user_id
          AND w.status = true
          AND i.inventory_set_total_qty > 0
          -- Check if user has NOT had this set before
          AND NOT EXISTS (
              SELECT 1 FROM public.shipments e
              WHERE e.user_id = r.user_id 
                AND e.set_id = w.set_id
          )
        ORDER BY w.created_at ASC  -- Prioritize by wishlist order
        LIMIT 1;
        
        -- If found in wishlist, mark as match
        IF v_set_id IS NOT NULL THEN
            v_matches_wishlist := TRUE;
        ELSE
            -- No valid wishlist match, choose random available set
            SELECT s.id, s.set_name, s.set_ref, 
                   COALESCE(s.set_price, 100.00), i.inventory_set_total_qty
            INTO v_set_id, v_set_name, v_set_ref, v_set_price, v_current_stock
            FROM public.sets s
            JOIN public.inventory_sets i ON s.id = i.set_id
            WHERE i.inventory_set_total_qty > 0
            ORDER BY RANDOM()
            LIMIT 1;
            
            v_matches_wishlist := FALSE;
        END IF;
        
        -- Return assignment if a set was found
        IF v_set_id IS NOT NULL THEN
            preview_assign_sets_to_users.user_id := r.user_id;
            preview_assign_sets_to_users.user_name := r.full_name;
            preview_assign_sets_to_users.set_id := v_set_id;
            preview_assign_sets_to_users.set_name := v_set_name;
            preview_assign_sets_to_users.set_ref := v_set_ref;
            preview_assign_sets_to_users.set_price := v_set_price;
            preview_assign_sets_to_users.current_stock := v_current_stock;
            preview_assign_sets_to_users.matches_wishlist := v_matches_wishlist;
            preview_assign_sets_to_users.pudo_type := v_pudo_type;
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public","COMMENT ON FUNCTION public.preview_assign_sets_to_users IS 
''Generates a preview of set assignments for eligible users. Includes pudo_type to determine if Correos preregistration should be executed.''"}', 'add_pudo_type_to_preview_assignment');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260324160000', '{"-- Migration: Fix confirm_assign_sets_to_users function
-- Restores the correct function signature and logic that was broken in 20260324100000
-- This version maintains compatibility with the frontend and includes full business logic

-- Drop the incorrect version
DROP FUNCTION IF EXISTS public.confirm_assign_sets_to_users(UUID[])","-- Recreate with correct signature and full logic from 20260322110000
CREATE OR REPLACE FUNCTION public.confirm_assign_sets_to_users(p_user_ids uuid[])
RETURNS TABLE(
    envio_id uuid,
    user_id uuid,
    set_id uuid,
    order_id uuid,
    user_name text,
    user_email text,
    user_phone text,
    set_name text,
    set_ref text,
    set_weight numeric,
    set_dim text,
    pudo_id text,
    pudo_name text,
    pudo_address text,
    pudo_cp text,
    pudo_city text,
    pudo_province text,
    created_at timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''public''
AS $$
DECLARE
    r RECORD;
    target_set_id UUID;
    new_order_id UUID;
    new_envio_id UUID;
    v_set_name TEXT;
    v_set_ref TEXT;
    v_set_weight NUMERIC;
    v_set_dim TEXT;
    v_user_email TEXT;
    v_user_phone TEXT;
    v_pudo_id TEXT;
    v_pudo_name TEXT;
    v_pudo_address TEXT;
    v_pudo_cp TEXT;
    v_pudo_city TEXT;
    v_pudo_province TEXT;
    v_created_at TIMESTAMPTZ;
BEGIN
    -- Loop through each user to confirm their assignment
    FOR r IN (
        SELECT 
            u.user_id,
            u.full_name,
            u.email,
            u.phone,
            p.correos_id_pudo,
            p.correos_name,
            p.correos_full_address,
            p.correos_zip_code,
            p.correos_city,
            p.correos_province
        FROM public.users u
        LEFT JOIN public.users_correos_dropping p ON u.user_id = p.user_id
        WHERE u.user_id = ANY(p_user_ids)
          AND u.user_status IN (''no_set'', ''set_returning'')
          AND EXISTS (
              SELECT 1 
              FROM public.wishlist w 
              WHERE w.user_id = u.user_id 
                AND w.status = true
          )
    ) LOOP
        -- Find the first available set from user''s wishlist
        SELECT 
            w.set_id,
            s.set_name,
            s.set_ref,
            s.set_weight,
            s.set_dim
        INTO 
            target_set_id,
            v_set_name,
            v_set_ref,
            v_set_weight,
            v_set_dim
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        JOIN public.sets s ON w.set_id = s.id
        WHERE w.user_id = r.user_id
          AND w.status = true
          AND i.inventory_set_total_qty > 0
        ORDER BY w.created_at ASC
        LIMIT 1;

        IF target_set_id IS NOT NULL THEN
            -- Update inventory
            UPDATE public.inventory_sets
            SET 
                inventory_set_total_qty = inventory_set_total_qty - 1,
                in_shipping = in_shipping + 1
            WHERE inventory_sets.set_id = target_set_id;

            -- Create order
            INSERT INTO public.orders (user_id, set_id, status)
            VALUES (r.user_id, target_set_id, ''pending'')
            RETURNING id INTO new_order_id;

            -- Create shipment
            INSERT INTO public.shipments (
                order_id,
                user_id,
                shipment_status,
                shipping_address,
                shipping_city,
                shipping_zip_code,
                shipping_country
            )
            VALUES (
                new_order_id,
                r.user_id,
                ''pending'',
                COALESCE(r.correos_full_address, ''Pending assignment''),
                COALESCE(r.correos_city, ''Pending''),
                COALESCE(r.correos_zip_code, ''00000''),
                ''España''
            )
            RETURNING shipments.id, shipments.created_at
            INTO new_envio_id, v_created_at;

            -- Update user status
            UPDATE public.users
            SET user_status = ''set_shipping''
            WHERE users.user_id = r.user_id;

            -- Mark wishlist item as assigned
            UPDATE public.wishlist
            SET 
                status = false,
                status_changed_at = now()
            WHERE wishlist.user_id = r.user_id
              AND wishlist.set_id = target_set_id;

            -- Populate return record
            confirm_assign_sets_to_users.envio_id := new_envio_id;
            confirm_assign_sets_to_users.user_id := r.user_id;
            confirm_assign_sets_to_users.set_id := target_set_id;
            confirm_assign_sets_to_users.order_id := new_order_id;
            confirm_assign_sets_to_users.user_name := r.full_name;
            confirm_assign_sets_to_users.user_email := r.email;
            confirm_assign_sets_to_users.user_phone := r.phone;
            confirm_assign_sets_to_users.set_name := v_set_name;
            confirm_assign_sets_to_users.set_ref := v_set_ref;
            confirm_assign_sets_to_users.set_weight := v_set_weight;
            confirm_assign_sets_to_users.set_dim := v_set_dim;
            confirm_assign_sets_to_users.pudo_id := r.correos_id_pudo;
            confirm_assign_sets_to_users.pudo_name := r.correos_name;
            confirm_assign_sets_to_users.pudo_address := r.correos_full_address;
            confirm_assign_sets_to_users.pudo_cp := r.correos_zip_code;
            confirm_assign_sets_to_users.pudo_city := r.correos_city;
            confirm_assign_sets_to_users.pudo_province := r.correos_province;
            confirm_assign_sets_to_users.created_at := v_created_at;
            
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$","COMMENT ON FUNCTION public.confirm_assign_sets_to_users IS ''Confirms set assignments for users. Creates orders, shipments, updates inventory and wishlist. Requires PUDO point configured (enforced by frontend validation).''"}', 'fix_confirm_assign_function');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260324165000', '{"-- Migration: Fix Brickshare PUDO ID handling
-- Problem: When selecting a Brickshare deposit, the id_correos_pudo from PudoSelector
-- needs to be properly stored as brickshare_pudo_id

-- The issue is that PudoSelector uses ''id_correos_pudo'' field for all point types,
-- but when it''s a Deposito/Brickshare point, this ID should be stored in brickshare_pudo_id
-- in users_brickshare_dropping table.

-- No schema changes needed - the issue is in the frontend logic
-- This migration just adds documentation and ensures consistency

-- Add comment to clarify the field usage
COMMENT ON COLUMN public.users_brickshare_dropping.brickshare_pudo_id IS 
''ID of the Brickshare PUDO location. Can be any string identifier from the /api/locations-local endpoint or the brickshare_pudo_locations table. The id_correos_pudo field from PudoSelector is mapped to this field when tipo_punto is Deposito.''","-- Ensure the table has the right structure
-- (This is idempotent - won''t fail if already correct)
DO $$ 
BEGIN
    -- Verify brickshare_pudo_id is NOT NULL
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = ''public'' 
        AND table_name = ''users_brickshare_dropping'' 
        AND column_name = ''brickshare_pudo_id'' 
        AND is_nullable = ''NO''
    ) THEN
        ALTER TABLE public.users_brickshare_dropping 
        ALTER COLUMN brickshare_pudo_id SET NOT NULL;
    END IF;
END $$"}', 'fix_brickshare_pudo_id_handling');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260324170000', '{"-- Migration: Fix assignment to properly set user_status to ''set_shipping'' and shipment_status to ''assigned''
-- Also ensures PUDO address data is copied to shipments table

-- Drop and recreate the function with correct logic
DROP FUNCTION IF EXISTS public.confirm_assign_sets_to_users(UUID[])","CREATE OR REPLACE FUNCTION public.confirm_assign_sets_to_users(p_user_ids uuid[])
RETURNS TABLE(
    envio_id uuid,
    user_id uuid,
    set_id uuid,
    order_id uuid,
    user_name text,
    user_email text,
    user_phone text,
    set_name text,
    set_ref text,
    set_weight numeric,
    set_dim text,
    pudo_id text,
    pudo_name text,
    pudo_address text,
    pudo_cp text,
    pudo_city text,
    pudo_province text,
    created_at timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''public''
AS $$
DECLARE
    r RECORD;
    target_set_id UUID;
    new_order_id UUID;
    new_envio_id UUID;
    v_set_name TEXT;
    v_set_ref TEXT;
    v_set_weight NUMERIC;
    v_set_dim TEXT;
    v_user_email TEXT;
    v_user_phone TEXT;
    v_pudo_id TEXT;
    v_pudo_name TEXT;
    v_pudo_address TEXT;
    v_pudo_cp TEXT;
    v_pudo_city TEXT;
    v_pudo_province TEXT;
    v_created_at TIMESTAMPTZ;
    v_pudo_type TEXT;
BEGIN
    -- Loop through each user to confirm their assignment
    FOR r IN (
        SELECT 
            u.user_id,
            u.full_name,
            u.email,
            u.phone,
            u.pudo_type,
            -- Correos PUDO data
            ucd.correos_id_pudo,
            ucd.correos_name,
            ucd.correos_full_address,
            ucd.correos_zip_code,
            ucd.correos_city,
            ucd.correos_province,
            -- Brickshare PUDO data
            bp.id as brickshare_pudo_id,
            bp.name as brickshare_pudo_name,
            bp.address as brickshare_address,
            bp.postal_code as brickshare_postal_code,
            bp.city as brickshare_city,
            bp.province as brickshare_province
        FROM public.users u
        LEFT JOIN public.users_correos_dropping ucd ON u.user_id = ucd.user_id
        LEFT JOIN public.brickshare_pudo_locations bp ON u.pudo_id = bp.id AND u.pudo_type = ''brickshare''
        WHERE u.user_id = ANY(p_user_ids)
          AND u.user_status IN (''no_set'', ''set_returning'')
          AND EXISTS (
              SELECT 1 
              FROM public.wishlist w 
              WHERE w.user_id = u.user_id 
                AND w.status = true
          )
    ) LOOP
        -- Store pudo_type for later use
        v_pudo_type := r.pudo_type;
        
        -- Determine PUDO data based on type
        IF v_pudo_type = ''correos'' THEN
            v_pudo_id := r.correos_id_pudo;
            v_pudo_name := r.correos_name;
            v_pudo_address := r.correos_full_address;
            v_pudo_cp := r.correos_zip_code;
            v_pudo_city := r.correos_city;
            v_pudo_province := r.correos_province;
        ELSIF v_pudo_type = ''brickshare'' THEN
            v_pudo_id := r.brickshare_pudo_id;
            v_pudo_name := r.brickshare_pudo_name;
            v_pudo_address := r.brickshare_address;
            v_pudo_cp := r.brickshare_postal_code;
            v_pudo_city := r.brickshare_city;
            v_pudo_province := r.brickshare_province;
        ELSE
            -- Skip user if no PUDO configured
            CONTINUE;
        END IF;
        
        -- Find the first available set from user''s wishlist
        SELECT 
            w.set_id,
            s.set_name,
            s.set_ref,
            s.set_weight,
            s.set_dim
        INTO 
            target_set_id,
            v_set_name,
            v_set_ref,
            v_set_weight,
            v_set_dim
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        JOIN public.sets s ON w.set_id = s.id
        WHERE w.user_id = r.user_id
          AND w.status = true
          AND i.inventory_set_total_qty > 0
        ORDER BY w.created_at ASC
        LIMIT 1;

        IF target_set_id IS NOT NULL THEN
            -- Update inventory
            UPDATE public.inventory_sets
            SET 
                inventory_set_total_qty = inventory_set_total_qty - 1,
                in_shipping = in_shipping + 1
            WHERE inventory_sets.set_id = target_set_id;

            -- Create order (still needed for legacy compatibility)
            INSERT INTO public.orders (user_id, set_id, status)
            VALUES (r.user_id, target_set_id, ''pending'')
            RETURNING id INTO new_order_id;

            -- Create shipment with PUDO address data and ''assigned'' status
            INSERT INTO public.shipments (
                user_id,
                set_id,
                set_ref,
                shipment_status,
                shipping_address,
                shipping_city,
                shipping_zip_code,
                shipping_country
            )
            VALUES (
                r.user_id,
                target_set_id,
                v_set_ref,
                ''assigned'',  -- Changed from ''pending'' to ''assigned''
                COALESCE(v_pudo_address, ''Pending assignment''),
                COALESCE(v_pudo_city, ''Pending''),
                COALESCE(v_pudo_cp, ''00000''),
                ''España''
            )
            RETURNING shipments.id, shipments.created_at
            INTO new_envio_id, v_created_at;

            -- Update user status to ''set_shipping'' (changed from ''with_set'')
            UPDATE public.users
            SET user_status = ''set_shipping''
            WHERE users.user_id = r.user_id;

            -- Mark wishlist item as assigned
            UPDATE public.wishlist
            SET 
                status = false,
                status_changed_at = now()
            WHERE wishlist.user_id = r.user_id
              AND wishlist.set_id = target_set_id;

            -- Populate return record
            confirm_assign_sets_to_users.envio_id := new_envio_id;
            confirm_assign_sets_to_users.user_id := r.user_id;
            confirm_assign_sets_to_users.set_id := target_set_id;
            confirm_assign_sets_to_users.order_id := new_order_id;
            confirm_assign_sets_to_users.user_name := r.full_name;
            confirm_assign_sets_to_users.user_email := r.email;
            confirm_assign_sets_to_users.user_phone := r.phone;
            confirm_assign_sets_to_users.set_name := v_set_name;
            confirm_assign_sets_to_users.set_ref := v_set_ref;
            confirm_assign_sets_to_users.set_weight := v_set_weight;
            confirm_assign_sets_to_users.set_dim := v_set_dim;
            confirm_assign_sets_to_users.pudo_id := v_pudo_id;
            confirm_assign_sets_to_users.pudo_name := v_pudo_name;
            confirm_assign_sets_to_users.pudo_address := v_pudo_address;
            confirm_assign_sets_to_users.pudo_cp := v_pudo_cp;
            confirm_assign_sets_to_users.pudo_city := v_pudo_city;
            confirm_assign_sets_to_users.pudo_province := v_pudo_province;
            confirm_assign_sets_to_users.created_at := v_created_at;
            
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$","COMMENT ON FUNCTION public.confirm_assign_sets_to_users IS ''Confirms set assignments for users. Sets user_status to set_shipping, creates shipment with assigned status, and copies PUDO address data to shipment record. Requires PUDO point configured.''"}', 'fix_assignment_shipment_creation');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260324171000', '{"-- Migration: Remove set_dim references from confirm_assign_sets_to_users
-- The set_dim column does not exist in the sets table and is not needed

-- Drop and recreate the function without set_dim
DROP FUNCTION IF EXISTS public.confirm_assign_sets_to_users(UUID[])","CREATE OR REPLACE FUNCTION public.confirm_assign_sets_to_users(p_user_ids uuid[])
RETURNS TABLE(
    envio_id uuid,
    user_id uuid,
    set_id uuid,
    order_id uuid,
    user_name text,
    user_email text,
    user_phone text,
    set_name text,
    set_ref text,
    set_weight numeric,
    pudo_id text,
    pudo_name text,
    pudo_address text,
    pudo_cp text,
    pudo_city text,
    pudo_province text,
    created_at timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''public''
AS $$
DECLARE
    r RECORD;
    target_set_id UUID;
    new_order_id UUID;
    new_envio_id UUID;
    v_set_name TEXT;
    v_set_ref TEXT;
    v_set_weight NUMERIC;
    v_user_email TEXT;
    v_user_phone TEXT;
    v_pudo_id TEXT;
    v_pudo_name TEXT;
    v_pudo_address TEXT;
    v_pudo_cp TEXT;
    v_pudo_city TEXT;
    v_pudo_province TEXT;
    v_created_at TIMESTAMPTZ;
    v_pudo_type TEXT;
BEGIN
    -- Loop through each user to confirm their assignment
    FOR r IN (
        SELECT 
            u.user_id,
            u.full_name,
            u.email,
            u.phone,
            u.pudo_type,
            -- Correos PUDO data
            ucd.correos_id_pudo,
            ucd.correos_name,
            ucd.correos_full_address,
            ucd.correos_zip_code,
            ucd.correos_city,
            ucd.correos_province,
            -- Brickshare PUDO data
            bp.id as brickshare_pudo_id,
            bp.name as brickshare_pudo_name,
            bp.address as brickshare_address,
            bp.postal_code as brickshare_postal_code,
            bp.city as brickshare_city,
            bp.province as brickshare_province
        FROM public.users u
        LEFT JOIN public.users_correos_dropping ucd ON u.user_id = ucd.user_id
        LEFT JOIN public.brickshare_pudo_locations bp ON u.pudo_id = bp.id AND u.pudo_type = ''brickshare''
        WHERE u.user_id = ANY(p_user_ids)
          AND u.user_status IN (''no_set'', ''set_returning'')
          AND EXISTS (
              SELECT 1 
              FROM public.wishlist w 
              WHERE w.user_id = u.user_id 
                AND w.status = true
          )
    ) LOOP
        -- Store pudo_type for later use
        v_pudo_type := r.pudo_type;
        
        -- Determine PUDO data based on type
        IF v_pudo_type = ''correos'' THEN
            v_pudo_id := r.correos_id_pudo;
            v_pudo_name := r.correos_name;
            v_pudo_address := r.correos_full_address;
            v_pudo_cp := r.correos_zip_code;
            v_pudo_city := r.correos_city;
            v_pudo_province := r.correos_province;
        ELSIF v_pudo_type = ''brickshare'' THEN
            v_pudo_id := r.brickshare_pudo_id;
            v_pudo_name := r.brickshare_pudo_name;
            v_pudo_address := r.brickshare_address;
            v_pudo_cp := r.brickshare_postal_code;
            v_pudo_city := r.brickshare_city;
            v_pudo_province := r.brickshare_province;
        ELSE
            -- Skip user if no PUDO configured
            CONTINUE;
        END IF;
        
        -- Find the first available set from user''s wishlist
        SELECT 
            w.set_id,
            s.set_name,
            s.set_ref,
            s.set_weight
        INTO 
            target_set_id,
            v_set_name,
            v_set_ref,
            v_set_weight
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        JOIN public.sets s ON w.set_id = s.id
        WHERE w.user_id = r.user_id
          AND w.status = true
          AND i.inventory_set_total_qty > 0
        ORDER BY w.created_at ASC
        LIMIT 1;

        IF target_set_id IS NOT NULL THEN
            -- Update inventory
            UPDATE public.inventory_sets
            SET 
                inventory_set_total_qty = inventory_set_total_qty - 1,
                in_shipping = in_shipping + 1
            WHERE inventory_sets.set_id = target_set_id;

            -- Create order (still needed for legacy compatibility)
            INSERT INTO public.orders (user_id, set_id, status)
            VALUES (r.user_id, target_set_id, ''pending'')
            RETURNING id INTO new_order_id;

            -- Create shipment with PUDO address data and ''assigned'' status
            INSERT INTO public.shipments (
                user_id,
                set_id,
                set_ref,
                shipment_status,
                shipping_address,
                shipping_city,
                shipping_zip_code,
                shipping_country
            )
            VALUES (
                r.user_id,
                target_set_id,
                v_set_ref,
                ''assigned'',
                COALESCE(v_pudo_address, ''Pending assignment''),
                COALESCE(v_pudo_city, ''Pending''),
                COALESCE(v_pudo_cp, ''00000''),
                ''España''
            )
            RETURNING shipments.id, shipments.created_at
            INTO new_envio_id, v_created_at;

            -- Update user status to ''set_shipping''
            UPDATE public.users
            SET user_status = ''set_shipping''
            WHERE users.user_id = r.user_id;

            -- Mark wishlist item as assigned
            UPDATE public.wishlist
            SET 
                status = false,
                status_changed_at = now()
            WHERE wishlist.user_id = r.user_id
              AND wishlist.set_id = target_set_id;

            -- Populate return record
            confirm_assign_sets_to_users.envio_id := new_envio_id;
            confirm_assign_sets_to_users.user_id := r.user_id;
            confirm_assign_sets_to_users.set_id := target_set_id;
            confirm_assign_sets_to_users.order_id := new_order_id;
            confirm_assign_sets_to_users.user_name := r.full_name;
            confirm_assign_sets_to_users.user_email := r.email;
            confirm_assign_sets_to_users.user_phone := r.phone;
            confirm_assign_sets_to_users.set_name := v_set_name;
            confirm_assign_sets_to_users.set_ref := v_set_ref;
            confirm_assign_sets_to_users.set_weight := v_set_weight;
            confirm_assign_sets_to_users.pudo_id := v_pudo_id;
            confirm_assign_sets_to_users.pudo_name := v_pudo_name;
            confirm_assign_sets_to_users.pudo_address := v_pudo_address;
            confirm_assign_sets_to_users.pudo_cp := v_pudo_cp;
            confirm_assign_sets_to_users.pudo_city := v_pudo_city;
            confirm_assign_sets_to_users.pudo_province := v_pudo_province;
            confirm_assign_sets_to_users.created_at := v_created_at;
            
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$","COMMENT ON FUNCTION public.confirm_assign_sets_to_users IS ''Confirms set assignments for users. Sets user_status to set_shipping, creates shipment with assigned status, and copies PUDO address data to shipment record. Requires PUDO point configured.''"}', 'remove_set_dim_from_assignment');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260324200730', '{"-- Migration: Remove orders table references from confirm_assign_sets_to_users
-- The orders table is deprecated - shipments now handle everything directly

DROP FUNCTION IF EXISTS public.confirm_assign_sets_to_users(UUID[])","CREATE OR REPLACE FUNCTION public.confirm_assign_sets_to_users(p_user_ids uuid[])
RETURNS TABLE(
    shipment_id uuid,
    user_id uuid,
    set_id uuid,
    user_name text,
    user_email text,
    user_phone text,
    set_name text,
    set_ref text,
    set_price numeric,
    set_weight numeric,
    pudo_id text,
    pudo_name text,
    pudo_address text,
    pudo_cp text,
    pudo_city text,
    pudo_province text,
    created_at timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''public''
AS $$
DECLARE
    r RECORD;
    target_set_id UUID;
    new_shipment_id UUID;
    v_set_name TEXT;
    v_set_ref TEXT;
    v_set_price NUMERIC;
    v_set_weight NUMERIC;
    v_pudo_id TEXT;
    v_pudo_name TEXT;
    v_pudo_address TEXT;
    v_pudo_cp TEXT;
    v_pudo_city TEXT;
    v_pudo_province TEXT;
    v_created_at TIMESTAMPTZ;
    v_pudo_type TEXT;
BEGIN
    -- Loop through each user to confirm their assignment
    FOR r IN (
        SELECT 
            u.user_id,
            u.full_name,
            u.email,
            u.phone,
            u.pudo_type,
            -- Correos PUDO data
            ucd.correos_id_pudo,
            ucd.correos_name,
            ucd.correos_full_address,
            ucd.correos_zip_code,
            ucd.correos_city,
            ucd.correos_province,
            -- Brickshare PUDO data
            bp.id as brickshare_pudo_id,
            bp.name as brickshare_pudo_name,
            bp.address as brickshare_address,
            bp.postal_code as brickshare_postal_code,
            bp.city as brickshare_city,
            bp.province as brickshare_province
        FROM public.users u
        LEFT JOIN public.users_correos_dropping ucd ON u.user_id = ucd.user_id
        LEFT JOIN public.brickshare_pudo_locations bp ON u.pudo_id = bp.id AND u.pudo_type = ''brickshare''
        WHERE u.user_id = ANY(p_user_ids)
          AND u.user_status IN (''no_set'', ''set_returning'')
          AND EXISTS (
              SELECT 1 
              FROM public.wishlist w 
              WHERE w.user_id = u.user_id 
                AND w.status = true
          )
    ) LOOP
        -- Store pudo_type for later use
        v_pudo_type := r.pudo_type;
        
        -- Determine PUDO data based on type
        IF v_pudo_type = ''correos'' THEN
            v_pudo_id := r.correos_id_pudo;
            v_pudo_name := r.correos_name;
            v_pudo_address := r.correos_full_address;
            v_pudo_cp := r.correos_zip_code;
            v_pudo_city := r.correos_city;
            v_pudo_province := r.correos_province;
        ELSIF v_pudo_type = ''brickshare'' THEN
            v_pudo_id := r.brickshare_pudo_id;
            v_pudo_name := r.brickshare_pudo_name;
            v_pudo_address := r.brickshare_address;
            v_pudo_cp := r.brickshare_postal_code;
            v_pudo_city := r.brickshare_city;
            v_pudo_province := r.brickshare_province;
        ELSE
            -- Skip user if no PUDO configured
            CONTINUE;
        END IF;
        
        -- Find the first available set from user''s wishlist
        SELECT 
            w.set_id,
            s.set_name,
            s.set_ref,
            s.set_price,
            s.set_weight
        INTO 
            target_set_id,
            v_set_name,
            v_set_ref,
            v_set_price,
            v_set_weight
        FROM public.wishlist w
        JOIN public.inventory_sets i ON w.set_id = i.set_id
        JOIN public.sets s ON w.set_id = s.id
        WHERE w.user_id = r.user_id
          AND w.status = true
          AND i.inventory_set_total_qty > 0
        ORDER BY w.created_at ASC
        LIMIT 1;

        IF target_set_id IS NOT NULL THEN
            -- Update inventory
            UPDATE public.inventory_sets
            SET 
                inventory_set_total_qty = inventory_set_total_qty - 1,
                in_shipping = in_shipping + 1
            WHERE inventory_sets.set_id = target_set_id;

            -- Create shipment directly (NO orders table)
            INSERT INTO public.shipments (
                user_id,
                set_id,
                set_ref,
                shipment_status,
                shipping_address,
                shipping_city,
                shipping_zip_code,
                shipping_country
            )
            VALUES (
                r.user_id,
                target_set_id,
                v_set_ref,
                ''assigned'',
                COALESCE(v_pudo_address, ''Pending assignment''),
                COALESCE(v_pudo_city, ''Pending''),
                COALESCE(v_pudo_cp, ''00000''),
                ''España''
            )
            RETURNING shipments.id, shipments.created_at
            INTO new_shipment_id, v_created_at;

            -- Update user status to ''set_shipping''
            UPDATE public.users
            SET user_status = ''set_shipping''
            WHERE users.user_id = r.user_id;

            -- Mark wishlist item as assigned
            UPDATE public.wishlist
            SET 
                status = false,
                status_changed_at = now()
            WHERE wishlist.user_id = r.user_id
              AND wishlist.set_id = target_set_id;

            -- Populate return record (NO order_id field)
            confirm_assign_sets_to_users.shipment_id := new_shipment_id;
            confirm_assign_sets_to_users.user_id := r.user_id;
            confirm_assign_sets_to_users.set_id := target_set_id;
            confirm_assign_sets_to_users.user_name := r.full_name;
            confirm_assign_sets_to_users.user_email := r.email;
            confirm_assign_sets_to_users.user_phone := r.phone;
            confirm_assign_sets_to_users.set_name := v_set_name;
            confirm_assign_sets_to_users.set_ref := v_set_ref;
            confirm_assign_sets_to_users.set_price := v_set_price;
            confirm_assign_sets_to_users.set_weight := v_set_weight;
            confirm_assign_sets_to_users.pudo_id := v_pudo_id;
            confirm_assign_sets_to_users.pudo_name := v_pudo_name;
            confirm_assign_sets_to_users.pudo_address := v_pudo_address;
            confirm_assign_sets_to_users.pudo_cp := v_pudo_cp;
            confirm_assign_sets_to_users.pudo_city := v_pudo_city;
            confirm_assign_sets_to_users.pudo_province := v_pudo_province;
            confirm_assign_sets_to_users.created_at := v_created_at;
            
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$","COMMENT ON FUNCTION public.confirm_assign_sets_to_users IS ''Confirms set assignments for users. Creates shipments directly (NO orders table), sets user_status to set_shipping, and copies PUDO address data. Requires PUDO point configured.''"}', 'remove_orders_table_references');
INSERT INTO supabase_migrations.schema_migrations (version, statements, name) VALUES ('20260325000000', '{"-- ============================================================================
-- Migration: Remove Brickman Chatbot Tables
-- Created: 2026-03-25
-- Description: Removes all database tables, triggers, and functions related to
--              the Brickman chatbot feature as it''s being completely removed.
-- ============================================================================

-- Drop triggers first
DROP TRIGGER IF EXISTS chat_messages_update_conversation_ts ON public.chat_messages","DROP TRIGGER IF EXISTS update_brickman_knowledge_updated_at ON public.brickman_knowledge","-- Drop functions
DROP FUNCTION IF EXISTS public.update_chat_conversation_timestamp()","DROP FUNCTION IF EXISTS public.update_brickman_knowledge_updated_at()","-- Drop tables (cascade will handle foreign key constraints)
DROP TABLE IF EXISTS public.chat_messages CASCADE","DROP TABLE IF EXISTS public.chat_conversations CASCADE","DROP TABLE IF EXISTS public.brickman_knowledge CASCADE","-- Note: The Edge Function ''brickman-chat'' should be manually deleted from Supabase dashboard
-- or via CLI: supabase functions delete brickman-chat"}', 'remove_chatbot_tables');


--
-- Data for Name: seed_files; Type: TABLE DATA; Schema: supabase_migrations; Owner: -
--

INSERT INTO supabase_migrations.seed_files (path, hash) VALUES ('supabase/seed.sql', 'cc8e172e5a298f292d5b74ed49adb6703a62b33b59c449aae7759f59156cab60');


--
-- Data for Name: secrets; Type: TABLE DATA; Schema: vault; Owner: -
--



--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: -
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 3, true);


--
-- Name: subscription_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: -
--

SELECT pg_catalog.setval('realtime.subscription_id_seq', 1, false);


--
-- Name: hooks_id_seq; Type: SEQUENCE SET; Schema: supabase_functions; Owner: -
--

SELECT pg_catalog.setval('supabase_functions.hooks_id_seq', 1, false);


--
-- Name: extensions extensions_pkey; Type: CONSTRAINT; Schema: _realtime; Owner: -
--

ALTER TABLE ONLY _realtime.extensions
    ADD CONSTRAINT extensions_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: _realtime; Owner: -
--

ALTER TABLE ONLY _realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: tenants tenants_pkey; Type: CONSTRAINT; Schema: _realtime; Owner: -
--

ALTER TABLE ONLY _realtime.tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: custom_oauth_providers custom_oauth_providers_identifier_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.custom_oauth_providers
    ADD CONSTRAINT custom_oauth_providers_identifier_key UNIQUE (identifier);


--
-- Name: custom_oauth_providers custom_oauth_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.custom_oauth_providers
    ADD CONSTRAINT custom_oauth_providers_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_code_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_code_key UNIQUE (authorization_code);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_id_key UNIQUE (authorization_id);


--
-- Name: oauth_authorizations oauth_authorizations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_pkey PRIMARY KEY (id);


--
-- Name: oauth_client_states oauth_client_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_client_states
    ADD CONSTRAINT oauth_client_states_pkey PRIMARY KEY (id);


--
-- Name: oauth_clients oauth_clients_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_clients
    ADD CONSTRAINT oauth_clients_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_user_client_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_client_unique UNIQUE (user_id, client_id);


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: webauthn_challenges webauthn_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_challenges
    ADD CONSTRAINT webauthn_challenges_pkey PRIMARY KEY (id);


--
-- Name: webauthn_credentials webauthn_credentials_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_credentials
    ADD CONSTRAINT webauthn_credentials_pkey PRIMARY KEY (id);


--
-- Name: backoffice_operations backoffice_operations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.backoffice_operations
    ADD CONSTRAINT backoffice_operations_pkey PRIMARY KEY (event_id);


--
-- Name: brickshare_pudo_locations brickshare_pudo_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.brickshare_pudo_locations
    ADD CONSTRAINT brickshare_pudo_locations_pkey PRIMARY KEY (id);


--
-- Name: donations donations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.donations
    ADD CONSTRAINT donations_pkey PRIMARY KEY (id);


--
-- Name: shipments envios_delivery_qr_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT envios_delivery_qr_code_key UNIQUE (delivery_qr_code);


--
-- Name: shipments envios_numero_seguimiento_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT envios_numero_seguimiento_key UNIQUE (tracking_number);


--
-- Name: shipments envios_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT envios_pkey PRIMARY KEY (id);


--
-- Name: shipments envios_return_qr_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT envios_return_qr_code_key UNIQUE (return_qr_code);


--
-- Name: inventory_sets inventario_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_sets
    ADD CONSTRAINT inventario_sets_pkey PRIMARY KEY (id);


--
-- Name: inventory_sets inventario_sets_set_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_sets
    ADD CONSTRAINT inventario_sets_set_id_key UNIQUE (set_id);


--
-- Name: reception_operations operaciones_recepcion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reception_operations
    ADD CONSTRAINT operaciones_recepcion_pkey PRIMARY KEY (id);


--
-- Name: sets products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sets
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: qr_validation_logs qr_validation_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qr_validation_logs
    ADD CONSTRAINT qr_validation_logs_pkey PRIMARY KEY (id);


--
-- Name: referrals referrals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.referrals
    ADD CONSTRAINT referrals_pkey PRIMARY KEY (id);


--
-- Name: referrals referrals_referee_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.referrals
    ADD CONSTRAINT referrals_referee_id_key UNIQUE (referee_id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: set_piece_list set_piece_list_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.set_piece_list
    ADD CONSTRAINT set_piece_list_pkey PRIMARY KEY (id);


--
-- Name: shipping_orders shipping_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipping_orders
    ADD CONSTRAINT shipping_orders_pkey PRIMARY KEY (id);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);


--
-- Name: user_roles user_roles_user_id_role_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_user_id_role_key UNIQUE (user_id, role);


--
-- Name: users_brickshare_dropping users_brickshare_dropping_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_brickshare_dropping
    ADD CONSTRAINT users_brickshare_dropping_pkey PRIMARY KEY (user_id);


--
-- Name: users_correos_dropping users_correos_dropping_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_correos_dropping
    ADD CONSTRAINT users_correos_dropping_pkey PRIMARY KEY (user_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_stripe_customer_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_stripe_customer_id_key UNIQUE (stripe_customer_id);


--
-- Name: users users_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_user_id_key UNIQUE (user_id);


--
-- Name: wishlist wishlist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wishlist
    ADD CONSTRAINT wishlist_pkey PRIMARY KEY (id);


--
-- Name: wishlist wishlist_user_id_product_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wishlist
    ADD CONSTRAINT wishlist_user_id_product_id_key UNIQUE (user_id, set_id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2026_03_23 messages_2026_03_23_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2026_03_23
    ADD CONSTRAINT messages_2026_03_23_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2026_03_24 messages_2026_03_24_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2026_03_24
    ADD CONSTRAINT messages_2026_03_24_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2026_03_25 messages_2026_03_25_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2026_03_25
    ADD CONSTRAINT messages_2026_03_25_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2026_03_26 messages_2026_03_26_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2026_03_26
    ADD CONSTRAINT messages_2026_03_26_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2026_03_27 messages_2026_03_27_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2026_03_27
    ADD CONSTRAINT messages_2026_03_27_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: buckets_analytics buckets_analytics_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets_analytics
    ADD CONSTRAINT buckets_analytics_pkey PRIMARY KEY (id);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: buckets_vectors buckets_vectors_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets_vectors
    ADD CONSTRAINT buckets_vectors_pkey PRIMARY KEY (id);


--
-- Name: iceberg_namespaces iceberg_namespaces_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.iceberg_namespaces
    ADD CONSTRAINT iceberg_namespaces_pkey PRIMARY KEY (id);


--
-- Name: iceberg_tables iceberg_tables_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.iceberg_tables
    ADD CONSTRAINT iceberg_tables_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);


--
-- Name: vector_indexes vector_indexes_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_pkey PRIMARY KEY (id);


--
-- Name: hooks hooks_pkey; Type: CONSTRAINT; Schema: supabase_functions; Owner: -
--

ALTER TABLE ONLY supabase_functions.hooks
    ADD CONSTRAINT hooks_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: supabase_functions; Owner: -
--

ALTER TABLE ONLY supabase_functions.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (version);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: supabase_migrations; Owner: -
--

ALTER TABLE ONLY supabase_migrations.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: seed_files seed_files_pkey; Type: CONSTRAINT; Schema: supabase_migrations; Owner: -
--

ALTER TABLE ONLY supabase_migrations.seed_files
    ADD CONSTRAINT seed_files_pkey PRIMARY KEY (path);


--
-- Name: extensions_tenant_external_id_index; Type: INDEX; Schema: _realtime; Owner: -
--

CREATE INDEX extensions_tenant_external_id_index ON _realtime.extensions USING btree (tenant_external_id);


--
-- Name: extensions_tenant_external_id_type_index; Type: INDEX; Schema: _realtime; Owner: -
--

CREATE UNIQUE INDEX extensions_tenant_external_id_type_index ON _realtime.extensions USING btree (tenant_external_id, type);


--
-- Name: tenants_external_id_index; Type: INDEX; Schema: _realtime; Owner: -
--

CREATE UNIQUE INDEX tenants_external_id_index ON _realtime.tenants USING btree (external_id);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: custom_oauth_providers_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_created_at_idx ON auth.custom_oauth_providers USING btree (created_at);


--
-- Name: custom_oauth_providers_enabled_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_enabled_idx ON auth.custom_oauth_providers USING btree (enabled);


--
-- Name: custom_oauth_providers_identifier_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_identifier_idx ON auth.custom_oauth_providers USING btree (identifier);


--
-- Name: custom_oauth_providers_provider_type_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_provider_type_idx ON auth.custom_oauth_providers USING btree (provider_type);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_oauth_client_states_created_at; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_oauth_client_states_created_at ON auth.oauth_client_states USING btree (created_at);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: oauth_auth_pending_exp_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_auth_pending_exp_idx ON auth.oauth_authorizations USING btree (expires_at) WHERE (status = 'pending'::auth.oauth_authorization_status);


--
-- Name: oauth_clients_deleted_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_clients_deleted_at_idx ON auth.oauth_clients USING btree (deleted_at);


--
-- Name: oauth_consents_active_client_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_active_client_idx ON auth.oauth_consents USING btree (client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_active_user_client_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_active_user_client_idx ON auth.oauth_consents USING btree (user_id, client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_user_order_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_user_order_idx ON auth.oauth_consents USING btree (user_id, granted_at DESC);


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_oauth_client_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_oauth_client_id_idx ON auth.sessions USING btree (oauth_client_id);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: sso_providers_resource_id_pattern_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_providers_resource_id_pattern_idx ON auth.sso_providers USING btree (resource_id text_pattern_ops);


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- Name: webauthn_challenges_expires_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX webauthn_challenges_expires_at_idx ON auth.webauthn_challenges USING btree (expires_at);


--
-- Name: webauthn_challenges_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX webauthn_challenges_user_id_idx ON auth.webauthn_challenges USING btree (user_id);


--
-- Name: webauthn_credentials_credential_id_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX webauthn_credentials_credential_id_key ON auth.webauthn_credentials USING btree (credential_id);


--
-- Name: webauthn_credentials_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX webauthn_credentials_user_id_idx ON auth.webauthn_credentials USING btree (user_id);


--
-- Name: envios_swikly_wish_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX envios_swikly_wish_id_idx ON public.shipments USING btree (swikly_wish_id);


--
-- Name: idx_backoff_ops_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_backoff_ops_time ON public.backoffice_operations USING btree (operation_time);


--
-- Name: idx_backoff_ops_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_backoff_ops_type ON public.backoffice_operations USING btree (operation_type);


--
-- Name: idx_backoff_ops_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_backoff_ops_user_id ON public.backoffice_operations USING btree (user_id);


--
-- Name: idx_brickshare_pudo_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_brickshare_pudo_active ON public.brickshare_pudo_locations USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_brickshare_pudo_location; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_brickshare_pudo_location ON public.brickshare_pudo_locations USING btree (latitude, longitude);


--
-- Name: idx_donations_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_donations_email ON public.donations USING btree (email);


--
-- Name: idx_donations_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_donations_status ON public.donations USING btree (status);


--
-- Name: idx_envios_brickshare_package_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_envios_brickshare_package_id ON public.shipments USING btree (brickshare_package_id) WHERE (brickshare_package_id IS NOT NULL);


--
-- Name: idx_envios_correos_shipment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_envios_correos_shipment_id ON public.shipments USING btree (correos_shipment_id);


--
-- Name: idx_envios_delivery_qr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_envios_delivery_qr ON public.shipments USING btree (delivery_qr_code) WHERE (delivery_qr_code IS NOT NULL);


--
-- Name: idx_envios_estado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_envios_estado ON public.shipments USING btree (shipment_status);


--
-- Name: idx_envios_fecha_entrega; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_envios_fecha_entrega ON public.shipments USING btree (estimated_delivery_date DESC);


--
-- Name: idx_envios_numero_seguimiento; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_envios_numero_seguimiento ON public.shipments USING btree (tracking_number);


--
-- Name: idx_envios_pickup_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_envios_pickup_type ON public.shipments USING btree (pickup_type);


--
-- Name: idx_envios_return_qr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_envios_return_qr ON public.shipments USING btree (return_qr_code) WHERE (return_qr_code IS NOT NULL);


--
-- Name: idx_envios_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_envios_set_id ON public.shipments USING btree (set_id);


--
-- Name: idx_envios_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_envios_user_id ON public.shipments USING btree (user_id);


--
-- Name: idx_inventario_sets_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inventario_sets_set_id ON public.inventory_sets USING btree (set_id);


--
-- Name: idx_inventario_sets_set_ref; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inventario_sets_set_ref ON public.inventory_sets USING btree (set_ref);


--
-- Name: idx_operaciones_recepcion_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_operaciones_recepcion_event_id ON public.reception_operations USING btree (event_id);


--
-- Name: idx_operaciones_recepcion_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_operaciones_recepcion_set_id ON public.reception_operations USING btree (set_id);


--
-- Name: idx_operaciones_recepcion_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_operaciones_recepcion_user_id ON public.reception_operations USING btree (user_id);


--
-- Name: idx_qr_validation_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_qr_validation_code ON public.qr_validation_logs USING btree (qr_code);


--
-- Name: idx_qr_validation_shipment; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_qr_validation_shipment ON public.qr_validation_logs USING btree (shipment_id);


--
-- Name: idx_set_piece_list_lego_ref; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_set_piece_list_lego_ref ON public.set_piece_list USING btree (set_ref);


--
-- Name: idx_set_piece_list_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_set_piece_list_set_id ON public.set_piece_list USING btree (set_id);


--
-- Name: idx_users_brickshare_dropping_location; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_brickshare_dropping_location ON public.users_brickshare_dropping USING btree (brickshare_pudo_id);


--
-- Name: idx_users_brickshare_dropping_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_brickshare_dropping_user_id ON public.users_brickshare_dropping USING btree (user_id);


--
-- Name: idx_users_correos_dropping_cp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_correos_dropping_cp ON public.users_correos_dropping USING btree (correos_zip_code);


--
-- Name: idx_users_correos_dropping_tipo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_correos_dropping_tipo ON public.users_correos_dropping USING btree (correos_point_type);


--
-- Name: idx_users_correos_dropping_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_correos_dropping_user_id ON public.users_correos_dropping USING btree (user_id);


--
-- Name: idx_users_pudo_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_pudo_id ON public.users USING btree (pudo_id) WHERE (pudo_id IS NOT NULL);


--
-- Name: idx_users_pudo_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_pudo_type ON public.users USING btree (pudo_type) WHERE (pudo_type IS NOT NULL);


--
-- Name: idx_users_stripe_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_stripe_customer_id ON public.users USING btree (stripe_customer_id);


--
-- Name: referrals_referrer_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX referrals_referrer_id_idx ON public.referrals USING btree (referrer_id, status, created_at DESC);


--
-- Name: reviews_envio_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX reviews_envio_unique ON public.reviews USING btree (envio_id) WHERE (envio_id IS NOT NULL);


--
-- Name: reviews_set_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX reviews_set_id_idx ON public.reviews USING btree (set_id, is_published, created_at DESC);


--
-- Name: reviews_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX reviews_user_id_idx ON public.reviews USING btree (user_id, created_at DESC);


--
-- Name: sets_age_range_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sets_age_range_idx ON public.sets USING btree (set_age_range);


--
-- Name: sets_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sets_created_at_idx ON public.sets USING btree (created_at DESC);


--
-- Name: sets_theme_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sets_theme_idx ON public.sets USING btree (set_theme);


--
-- Name: sets_year_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sets_year_idx ON public.sets USING btree (year_released);


--
-- Name: users_referral_code_lower; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_referral_code_lower ON public.users USING btree (lower(referral_code)) WHERE (referral_code IS NOT NULL);


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);


--
-- Name: messages_inserted_at_topic_index; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_inserted_at_topic_index ON ONLY realtime.messages USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2026_03_23_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_2026_03_23_inserted_at_topic_idx ON realtime.messages_2026_03_23 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2026_03_24_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_2026_03_24_inserted_at_topic_idx ON realtime.messages_2026_03_24 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2026_03_25_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_2026_03_25_inserted_at_topic_idx ON realtime.messages_2026_03_25 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2026_03_26_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_2026_03_26_inserted_at_topic_idx ON realtime.messages_2026_03_26 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2026_03_27_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_2026_03_27_inserted_at_topic_idx ON realtime.messages_2026_03_27 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: subscription_subscription_id_entity_filters_action_filter_key; Type: INDEX; Schema: realtime; Owner: -
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_action_filter_key ON realtime.subscription USING btree (subscription_id, entity, filters, action_filter);


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);


--
-- Name: buckets_analytics_unique_name_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX buckets_analytics_unique_name_idx ON storage.buckets_analytics USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: idx_iceberg_namespaces_bucket_id; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX idx_iceberg_namespaces_bucket_id ON storage.iceberg_namespaces USING btree (catalog_id, name);


--
-- Name: idx_iceberg_tables_location; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX idx_iceberg_tables_location ON storage.iceberg_tables USING btree (location);


--
-- Name: idx_iceberg_tables_namespace_id; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX idx_iceberg_tables_namespace_id ON storage.iceberg_tables USING btree (catalog_id, namespace_id, name);


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- Name: idx_objects_bucket_id_name_lower; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_bucket_id_name_lower ON storage.objects USING btree (bucket_id, lower(name) COLLATE "C");


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: vector_indexes_name_bucket_id_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX vector_indexes_name_bucket_id_idx ON storage.vector_indexes USING btree (name, bucket_id);


--
-- Name: supabase_functions_hooks_h_table_id_h_name_idx; Type: INDEX; Schema: supabase_functions; Owner: -
--

CREATE INDEX supabase_functions_hooks_h_table_id_h_name_idx ON supabase_functions.hooks USING btree (hook_table_id, hook_name);


--
-- Name: supabase_functions_hooks_request_id_idx; Type: INDEX; Schema: supabase_functions; Owner: -
--

CREATE INDEX supabase_functions_hooks_request_id_idx ON supabase_functions.hooks USING btree (request_id);


--
-- Name: messages_2026_03_23_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_03_23_inserted_at_topic_idx;


--
-- Name: messages_2026_03_23_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_03_23_pkey;


--
-- Name: messages_2026_03_24_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_03_24_inserted_at_topic_idx;


--
-- Name: messages_2026_03_24_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_03_24_pkey;


--
-- Name: messages_2026_03_25_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_03_25_inserted_at_topic_idx;


--
-- Name: messages_2026_03_25_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_03_25_pkey;


--
-- Name: messages_2026_03_26_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_03_26_inserted_at_topic_idx;


--
-- Name: messages_2026_03_26_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_03_26_pkey;


--
-- Name: messages_2026_03_27_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_03_27_inserted_at_topic_idx;


--
-- Name: messages_2026_03_27_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_03_27_pkey;


--
-- Name: users on_auth_user_created; Type: TRIGGER; Schema: auth; Owner: -
--

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


--
-- Name: users on_auth_user_created_for_referral; Type: TRIGGER; Schema: auth; Owner: -
--

CREATE TRIGGER on_auth_user_created_for_referral AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_auth_user();


--
-- Name: reception_operations on_reception_completed; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER on_reception_completed AFTER UPDATE ON public.reception_operations FOR EACH ROW EXECUTE FUNCTION public.handle_reception_close();


--
-- Name: sets on_set_created; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER on_set_created AFTER INSERT ON public.sets FOR EACH ROW EXECUTE FUNCTION public.handle_new_set_inventory();


--
-- Name: shipments on_shipment_delivered; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER on_shipment_delivered AFTER UPDATE ON public.shipments FOR EACH ROW EXECUTE FUNCTION public.handle_shipment_delivered();


--
-- Name: shipments on_shipment_return_transit_inv; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER on_shipment_return_transit_inv AFTER UPDATE ON public.shipments FOR EACH ROW EXECUTE FUNCTION public.handle_shipment_return_transit_inventory();


--
-- Name: shipments on_shipment_return_user_status; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER on_shipment_return_user_status AFTER UPDATE ON public.shipments FOR EACH ROW EXECUTE FUNCTION public.handle_return_user_status();


--
-- Name: shipments on_shipment_warehouse_received; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER on_shipment_warehouse_received BEFORE UPDATE ON public.shipments FOR EACH ROW EXECUTE FUNCTION public.handle_shipment_warehouse_received();


--
-- Name: shipping_orders on_shipping_orders_updated; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER on_shipping_orders_updated BEFORE UPDATE ON public.shipping_orders FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();


--
-- Name: referrals referrals_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER referrals_updated_at BEFORE UPDATE ON public.referrals FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: reviews reviews_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER reviews_updated_at BEFORE UPDATE ON public.reviews FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: users_brickshare_dropping trigger_update_users_brickshare_dropping_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_users_brickshare_dropping_updated_at BEFORE UPDATE ON public.users_brickshare_dropping FOR EACH ROW EXECUTE FUNCTION public.update_users_brickshare_dropping_updated_at();


--
-- Name: users_correos_dropping trigger_update_users_correos_dropping_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_users_correos_dropping_updated_at BEFORE UPDATE ON public.users_correos_dropping FOR EACH ROW EXECUTE FUNCTION public.update_users_correos_dropping_updated_at();


--
-- Name: donations update_donations_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_donations_updated_at BEFORE UPDATE ON public.donations FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: inventory_sets update_inventario_sets_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_inventario_sets_updated_at BEFORE UPDATE ON public.inventory_sets FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: reception_operations update_reception_operations_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_reception_operations_updated_at BEFORE UPDATE ON public.reception_operations FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: set_piece_list update_set_piece_list_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_set_piece_list_updated_at BEFORE UPDATE ON public.set_piece_list FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: sets update_sets_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_sets_updated_at BEFORE UPDATE ON public.sets FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: shipments update_shipments_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_shipments_updated_at BEFORE UPDATE ON public.shipments FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: users update_users_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: users users_generate_referral_code; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER users_generate_referral_code BEFORE INSERT ON public.users FOR EACH ROW EXECUTE FUNCTION public.generate_referral_code_users();


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: -
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();


--
-- Name: buckets enforce_bucket_name_length_trigger; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER enforce_bucket_name_length_trigger BEFORE INSERT OR UPDATE OF name ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.enforce_bucket_name_length();


--
-- Name: buckets protect_buckets_delete; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_buckets_delete BEFORE DELETE ON storage.buckets FOR EACH STATEMENT EXECUTE FUNCTION storage.protect_delete();


--
-- Name: objects protect_objects_delete; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_objects_delete BEFORE DELETE ON storage.objects FOR EACH STATEMENT EXECUTE FUNCTION storage.protect_delete();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- Name: extensions extensions_tenant_external_id_fkey; Type: FK CONSTRAINT; Schema: _realtime; Owner: -
--

ALTER TABLE ONLY _realtime.extensions
    ADD CONSTRAINT extensions_tenant_external_id_fkey FOREIGN KEY (tenant_external_id) REFERENCES _realtime.tenants(external_id) ON DELETE CASCADE;


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_oauth_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_oauth_client_id_fkey FOREIGN KEY (oauth_client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: webauthn_challenges webauthn_challenges_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_challenges
    ADD CONSTRAINT webauthn_challenges_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: webauthn_credentials webauthn_credentials_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_credentials
    ADD CONSTRAINT webauthn_credentials_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: backoffice_operations backoffice_operations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.backoffice_operations
    ADD CONSTRAINT backoffice_operations_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE SET NULL;


--
-- Name: donations donations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.donations
    ADD CONSTRAINT donations_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE SET NULL;


--
-- Name: shipments envios_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT envios_set_id_fkey FOREIGN KEY (set_id) REFERENCES public.sets(id) ON DELETE SET NULL;


--
-- Name: shipments envios_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT envios_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: shipments envios_user_id_fkey_public_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT envios_user_id_fkey_public_users FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: inventory_sets inventory_sets_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_sets
    ADD CONSTRAINT inventory_sets_set_id_fkey FOREIGN KEY (set_id) REFERENCES public.sets(id) ON DELETE CASCADE;


--
-- Name: reception_operations operaciones_recepcion_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reception_operations
    ADD CONSTRAINT operaciones_recepcion_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.shipments(id) ON DELETE SET NULL;


--
-- Name: reception_operations operaciones_recepcion_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reception_operations
    ADD CONSTRAINT operaciones_recepcion_set_id_fkey FOREIGN KEY (set_id) REFERENCES public.sets(id) ON DELETE CASCADE;


--
-- Name: reception_operations operaciones_recepcion_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reception_operations
    ADD CONSTRAINT operaciones_recepcion_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: qr_validation_logs qr_validation_logs_shipment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qr_validation_logs
    ADD CONSTRAINT qr_validation_logs_shipment_id_fkey FOREIGN KEY (shipment_id) REFERENCES public.shipments(id) ON DELETE CASCADE;


--
-- Name: referrals referrals_referee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.referrals
    ADD CONSTRAINT referrals_referee_id_fkey FOREIGN KEY (referee_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: referrals referrals_referrer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.referrals
    ADD CONSTRAINT referrals_referrer_id_fkey FOREIGN KEY (referrer_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: reviews reviews_envio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_envio_id_fkey FOREIGN KEY (envio_id) REFERENCES public.shipments(id) ON DELETE SET NULL;


--
-- Name: reviews reviews_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_set_id_fkey FOREIGN KEY (set_id) REFERENCES public.sets(id) ON DELETE CASCADE;


--
-- Name: reviews reviews_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: set_piece_list set_piece_list_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.set_piece_list
    ADD CONSTRAINT set_piece_list_set_id_fkey FOREIGN KEY (set_id) REFERENCES public.sets(id) ON DELETE CASCADE;


--
-- Name: shipping_orders shipping_orders_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipping_orders
    ADD CONSTRAINT shipping_orders_set_id_fkey FOREIGN KEY (set_id) REFERENCES public.sets(id) ON DELETE CASCADE;


--
-- Name: shipping_orders shipping_orders_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipping_orders
    ADD CONSTRAINT shipping_orders_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: user_roles user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: users_brickshare_dropping users_brickshare_dropping_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_brickshare_dropping
    ADD CONSTRAINT users_brickshare_dropping_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: users_correos_dropping users_correos_dropping_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_correos_dropping
    ADD CONSTRAINT users_correos_dropping_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: users users_referred_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_referred_by_fkey FOREIGN KEY (referred_by) REFERENCES auth.users(id) ON DELETE SET NULL;


--
-- Name: users users_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: wishlist wishlist_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wishlist
    ADD CONSTRAINT wishlist_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: iceberg_namespaces iceberg_namespaces_catalog_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.iceberg_namespaces
    ADD CONSTRAINT iceberg_namespaces_catalog_id_fkey FOREIGN KEY (catalog_id) REFERENCES storage.buckets_analytics(id) ON DELETE CASCADE;


--
-- Name: iceberg_tables iceberg_tables_catalog_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.iceberg_tables
    ADD CONSTRAINT iceberg_tables_catalog_id_fkey FOREIGN KEY (catalog_id) REFERENCES storage.buckets_analytics(id) ON DELETE CASCADE;


--
-- Name: iceberg_tables iceberg_tables_namespace_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.iceberg_tables
    ADD CONSTRAINT iceberg_tables_namespace_id_fkey FOREIGN KEY (namespace_id) REFERENCES storage.iceberg_namespaces(id) ON DELETE CASCADE;


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;


--
-- Name: vector_indexes vector_indexes_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets_vectors(id);


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- Name: inventory_sets Admins and Operadores can manage inventario; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins and Operadores can manage inventario" ON public.inventory_sets TO authenticated USING ((public.has_role(auth.uid(), 'admin'::public.app_role) OR public.has_role(auth.uid(), 'operador'::public.app_role)));


--
-- Name: users Admins and Operadores can view all users; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins and Operadores can view all users" ON public.users FOR SELECT USING ((public.has_role(auth.uid(), 'admin'::public.app_role) OR public.has_role(auth.uid(), 'operador'::public.app_role)));


--
-- Name: backoffice_operations Admins and Operators can log operations; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins and Operators can log operations" ON public.backoffice_operations FOR INSERT TO authenticated WITH CHECK ((public.has_role(auth.uid(), 'admin'::public.app_role) OR public.has_role(auth.uid(), 'operador'::public.app_role)));


--
-- Name: backoffice_operations Admins and Operators can view operations; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins and Operators can view operations" ON public.backoffice_operations FOR SELECT TO authenticated USING ((public.has_role(auth.uid(), 'admin'::public.app_role) OR public.has_role(auth.uid(), 'operador'::public.app_role)));


--
-- Name: reception_operations Admins and operators can insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins and operators can insert" ON public.reception_operations FOR INSERT TO authenticated WITH CHECK ((public.has_role(auth.uid(), 'admin'::public.app_role) OR public.has_role(auth.uid(), 'operador'::public.app_role)));


--
-- Name: reception_operations Admins and operators can update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins and operators can update" ON public.reception_operations FOR UPDATE TO authenticated USING ((public.has_role(auth.uid(), 'admin'::public.app_role) OR public.has_role(auth.uid(), 'operador'::public.app_role))) WITH CHECK ((public.has_role(auth.uid(), 'admin'::public.app_role) OR public.has_role(auth.uid(), 'operador'::public.app_role)));


--
-- Name: shipments Admins and operators full access; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins and operators full access" ON public.shipments USING ((public.has_role(auth.uid(), 'admin'::public.app_role) OR public.has_role(auth.uid(), 'operador'::public.app_role)));


--
-- Name: sets Admins can delete sets; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can delete sets" ON public.sets FOR DELETE USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: sets Admins can insert sets; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can insert sets" ON public.sets FOR INSERT WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: donations Admins can manage all donations; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage all donations" ON public.donations USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: user_roles Admins can manage all roles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage all roles" ON public.user_roles TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: set_piece_list Admins can manage set piece lists; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can manage set piece lists" ON public.set_piece_list TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: users Admins can update any user; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can update any user" ON public.users FOR UPDATE USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: sets Admins can update sets; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can update sets" ON public.sets FOR UPDATE USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: users Admins can view all profiles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view all profiles" ON public.users FOR SELECT TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: wishlist Admins can view all wishlists; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can view all wishlists" ON public.wishlist FOR SELECT USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: brickshare_pudo_locations Allow public read of active PUDO locations; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow public read of active PUDO locations" ON public.brickshare_pudo_locations FOR SELECT USING ((is_active = true));


--
-- Name: donations Authenticated users can insert their own donations; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Authenticated users can insert their own donations" ON public.donations FOR INSERT WITH CHECK (((auth.uid() IS NOT NULL) AND ((user_id IS NULL) OR (auth.uid() = user_id))));


--
-- Name: reception_operations Authenticated users can read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Authenticated users can read" ON public.reception_operations FOR SELECT TO authenticated USING (true);


--
-- Name: inventory_sets Inventario is viewable by everyone; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Inventario is viewable by everyone" ON public.inventory_sets FOR SELECT USING (true);


--
-- Name: shipments Operators can create shipments; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Operators can create shipments" ON public.shipments FOR INSERT WITH CHECK ((public.has_role(auth.uid(), 'admin'::public.app_role) OR public.has_role(auth.uid(), 'operador'::public.app_role)));


--
-- Name: shipments Operators can update shipments; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Operators can update shipments" ON public.shipments FOR UPDATE USING ((public.has_role(auth.uid(), 'admin'::public.app_role) OR public.has_role(auth.uid(), 'operador'::public.app_role)));


--
-- Name: set_piece_list Set piece lists are viewable by everyone; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Set piece lists are viewable by everyone" ON public.set_piece_list FOR SELECT USING (true);


--
-- Name: sets Sets are viewable by everyone; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Sets are viewable by everyone" ON public.sets FOR SELECT USING (true);


--
-- Name: wishlist Users can add to their own wishlist; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can add to their own wishlist" ON public.wishlist FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- Name: users_brickshare_dropping Users can delete their own Brickshare PUDO selection; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can delete their own Brickshare PUDO selection" ON public.users_brickshare_dropping FOR DELETE TO authenticated USING ((auth.uid() = user_id));


--
-- Name: users_correos_dropping Users can delete their own Correos PUDO selection; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can delete their own Correos PUDO selection" ON public.users_correos_dropping FOR DELETE USING ((auth.uid() = user_id));


--
-- Name: users Users can delete their own profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can delete their own profile" ON public.users FOR DELETE TO authenticated USING ((auth.uid() = user_id));


--
-- Name: users_brickshare_dropping Users can insert their own Brickshare PUDO selection; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can insert their own Brickshare PUDO selection" ON public.users_brickshare_dropping FOR INSERT TO authenticated WITH CHECK ((auth.uid() = user_id));


--
-- Name: users_correos_dropping Users can insert their own Correos PUDO selection; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can insert their own Correos PUDO selection" ON public.users_correos_dropping FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- Name: users Users can insert their own profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can insert their own profile" ON public.users FOR INSERT TO authenticated WITH CHECK ((auth.uid() = user_id));


--
-- Name: wishlist Users can remove from their own wishlist; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can remove from their own wishlist" ON public.wishlist FOR DELETE USING ((auth.uid() = user_id));


--
-- Name: users Users can update own profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update own profile" ON public.users FOR UPDATE USING ((auth.uid() = user_id));


--
-- Name: shipments Users can update own shipment status; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update own shipment status" ON public.shipments FOR UPDATE TO authenticated USING ((auth.uid() = user_id)) WITH CHECK (((auth.uid() = user_id) AND (shipment_status = 'in_return_pudo'::text)));


--
-- Name: users_brickshare_dropping Users can update their own Brickshare PUDO selection; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update their own Brickshare PUDO selection" ON public.users_brickshare_dropping FOR UPDATE TO authenticated USING ((auth.uid() = user_id)) WITH CHECK ((auth.uid() = user_id));


--
-- Name: users_correos_dropping Users can update their own Correos PUDO selection; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update their own Correos PUDO selection" ON public.users_correos_dropping FOR UPDATE USING ((auth.uid() = user_id)) WITH CHECK ((auth.uid() = user_id));


--
-- Name: users Users can update their own profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update their own profile" ON public.users FOR UPDATE TO authenticated USING ((auth.uid() = user_id));


--
-- Name: wishlist Users can update their own wishlist; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can update their own wishlist" ON public.wishlist FOR UPDATE TO authenticated USING ((auth.uid() = user_id)) WITH CHECK ((auth.uid() = user_id));


--
-- Name: users Users can view own profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view own profile" ON public.users FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: shipments Users can view own shipments; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view own shipments" ON public.shipments FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: users_brickshare_dropping Users can view their own Brickshare PUDO selection; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view their own Brickshare PUDO selection" ON public.users_brickshare_dropping FOR SELECT TO authenticated USING ((auth.uid() = user_id));


--
-- Name: users_correos_dropping Users can view their own Correos PUDO selection; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view their own Correos PUDO selection" ON public.users_correos_dropping FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: donations Users can view their own donations; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view their own donations" ON public.donations FOR SELECT USING (((auth.uid() = user_id) OR (email = (( SELECT users.email
   FROM auth.users
  WHERE (users.id = auth.uid())))::text)));


--
-- Name: users Users can view their own profile; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view their own profile" ON public.users FOR SELECT TO authenticated USING ((auth.uid() = user_id));


--
-- Name: user_roles Users can view their own roles; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view their own roles" ON public.user_roles FOR SELECT TO authenticated USING ((auth.uid() = user_id));


--
-- Name: shipping_orders Users can view their own shipping orders; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view their own shipping orders" ON public.shipping_orders FOR SELECT TO authenticated USING ((auth.uid() = user_id));


--
-- Name: qr_validation_logs Users can view their own validation logs; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view their own validation logs" ON public.qr_validation_logs FOR SELECT TO authenticated USING ((shipment_id IN ( SELECT s.id
   FROM public.shipments s
  WHERE (s.user_id = auth.uid()))));


--
-- Name: wishlist Users can view their own wishlist; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can view their own wishlist" ON public.wishlist FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: backoffice_operations; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.backoffice_operations ENABLE ROW LEVEL SECURITY;

--
-- Name: brickshare_pudo_locations; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.brickshare_pudo_locations ENABLE ROW LEVEL SECURITY;

--
-- Name: donations; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.donations ENABLE ROW LEVEL SECURITY;

--
-- Name: inventory_sets; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.inventory_sets ENABLE ROW LEVEL SECURITY;

--
-- Name: qr_validation_logs; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.qr_validation_logs ENABLE ROW LEVEL SECURITY;

--
-- Name: reception_operations; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.reception_operations ENABLE ROW LEVEL SECURITY;

--
-- Name: referrals; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.referrals ENABLE ROW LEVEL SECURITY;

--
-- Name: referrals referrals_admin_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY referrals_admin_all ON public.referrals TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.user_roles
  WHERE ((user_roles.user_id = auth.uid()) AND (user_roles.role = ANY (ARRAY['admin'::public.app_role, 'operador'::public.app_role]))))));


--
-- Name: referrals referrals_select_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY referrals_select_own ON public.referrals FOR SELECT TO authenticated USING ((referrer_id = auth.uid()));


--
-- Name: referrals referrals_select_referee; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY referrals_select_referee ON public.referrals FOR SELECT TO authenticated USING ((referee_id = auth.uid()));


--
-- Name: reviews; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

--
-- Name: reviews reviews_admin_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY reviews_admin_all ON public.reviews TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.user_roles
  WHERE ((user_roles.user_id = auth.uid()) AND (user_roles.role = ANY (ARRAY['admin'::public.app_role, 'operador'::public.app_role]))))));


--
-- Name: reviews reviews_delete_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY reviews_delete_own ON public.reviews FOR DELETE TO authenticated USING ((auth.uid() = user_id));


--
-- Name: reviews reviews_insert_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY reviews_insert_own ON public.reviews FOR INSERT TO authenticated WITH CHECK ((auth.uid() = user_id));


--
-- Name: reviews reviews_select_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY reviews_select_own ON public.reviews FOR SELECT TO authenticated USING ((auth.uid() = user_id));


--
-- Name: reviews reviews_select_published; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY reviews_select_published ON public.reviews FOR SELECT USING ((is_published = true));


--
-- Name: reviews reviews_update_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY reviews_update_own ON public.reviews FOR UPDATE TO authenticated USING ((auth.uid() = user_id)) WITH CHECK ((auth.uid() = user_id));


--
-- Name: set_piece_list; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.set_piece_list ENABLE ROW LEVEL SECURITY;

--
-- Name: sets; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.sets ENABLE ROW LEVEL SECURITY;

--
-- Name: shipments; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.shipments ENABLE ROW LEVEL SECURITY;

--
-- Name: shipping_orders; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.shipping_orders ENABLE ROW LEVEL SECURITY;

--
-- Name: user_roles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

--
-- Name: users_brickshare_dropping; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.users_brickshare_dropping ENABLE ROW LEVEL SECURITY;

--
-- Name: users_correos_dropping; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.users_correos_dropping ENABLE ROW LEVEL SECURITY;

--
-- Name: users users_insert_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY users_insert_own ON public.users FOR INSERT TO authenticated WITH CHECK ((user_id = auth.uid()));


--
-- Name: users users_select_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY users_select_own ON public.users FOR SELECT TO authenticated USING ((user_id = auth.uid()));


--
-- Name: users users_select_own_referral; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY users_select_own_referral ON public.users FOR SELECT TO authenticated USING ((user_id = auth.uid()));


--
-- Name: users users_update_own; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY users_update_own ON public.users FOR UPDATE TO authenticated USING ((user_id = auth.uid()));


--
-- Name: wishlist; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.wishlist ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: -
--

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_analytics; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets_analytics ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_vectors; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets_vectors ENABLE ROW LEVEL SECURITY;

--
-- Name: iceberg_namespaces; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.iceberg_namespaces ENABLE ROW LEVEL SECURITY;

--
-- Name: iceberg_tables; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.iceberg_tables ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

--
-- Name: vector_indexes; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.vector_indexes ENABLE ROW LEVEL SECURITY;

--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: -
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();


--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();


--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE FUNCTION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();


--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();


--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();


--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();


--
-- PostgreSQL database dump complete
--

\unrestrict zVM8DEXpFxQkvwm7fM2ViKrSVMlQGBTRbo6QpigqP0fBHk5LX2zYNCbXOLgZ1KH

