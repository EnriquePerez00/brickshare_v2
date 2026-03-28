Output format is unaligned.
# 📊 Esquema de Base de Datos - Brickshare

> Documentación AUTO-GENERADA de la base de datos PostgreSQL

**Última actualización**:  || to_char(now(), YYYY-MM-DD HH24:MI:SS)

---

## 📋 Índice

- [Tablas](#tablas)
- [Tipos ENUM](#tipos-enum)
- [Funciones RPC](#funciones-rpc)
- [Triggers](#triggers)

---

## 📦 Tipos ENUM

### `app_role`

Valores posibles: `operador`, `user`, `admin`


### `operation_type`

Valores posibles: `retorno_stock`, `higienizado`, `deposito_fulfillment`, `analisis_peso`, `recepcion paquete`


---

## 📋 Tablas

### `backoffice_operations`

Campos de la tabla:\n
| Campo | Tipo | Nulo | Default |
|-------|------|------|---------|
| `event_id` | uuid | ✗ | gen_random_uuid() |
| `user_id` | uuid | ✓ | - |
| `operation_type` | USER-DEFINED | ✗ | - |
| `operation_time` | timestamp with time zone | ✗ | now() |
| `metadata` | jsonb | ✓ | - |


### `brickshare_pudo_locations`

Campos de la tabla:\n
| Campo | Tipo | Nulo | Default |
|-------|------|------|---------|
| `id` | text | ✗ | - |
| `name` | text | ✗ | - |
| `address` | text | ✗ | - |
| `city` | text | ✗ | - |
| `postal_code` | text | ✗ | - |
| `province` | text | ✗ | - |
| `latitude` | numeric(10,8) | ✓ | - |
| `longitude` | numeric(11,8) | ✓ | - |
| `contact_phone` | text | ✓ | - |
| `contact_email` | text | ✓ | - |
| `opening_hours` | jsonb | ✓ | - |
| `is_active` | boolean | ✓ | true |
| `notes` | text | ✓ | - |
| `created_at` | timestamp with time zone | ✓ | now() |
| `updated_at` | timestamp with time zone | ✓ | now() |


### `donations`

Campos de la tabla:\n
| Campo | Tipo | Nulo | Default |
|-------|------|------|---------|
| `id` | uuid | ✗ | gen_random_uuid() |
| `user_id` | uuid | ✓ | - |
| `name` | text | ✗ | - |
| `email` | text | ✗ | - |
| `phone` | text | ✓ | - |
| `address` | text | ✓ | - |
| `estimated_weight` | numeric | ✗ | - |
| `delivery_method` | text | ✗ | - |
| `reward` | text | ✗ | - |
| `children_benefited` | integer | ✗ | - |
| `co2_avoided` | numeric | ✗ | - |
| `status` | text | ✗ | 'pending'::text |
| `tracking_code` | text | ✓ | - |
| `created_at` | timestamp with time zone | ✗ | now() |
| `updated_at` | timestamp with time zone | ✗ | now() |


### `inventory_sets`

Campos de la tabla:\n
| Campo | Tipo | Nulo | Default |
|-------|------|------|---------|
| `id` | uuid | ✗ | gen_random_uuid() |
| `set_id` | uuid | ✗ | - |
| `set_ref` | text | ✓ | - |
| `inventory_set_total_qty` | integer | ✗ | 0 |
| `in_shipping` | integer | ✗ | 0 |
| `in_use` | integer | ✗ | 0 |
| `in_return` | integer | ✗ | 0 |
| `in_repair` | integer | ✗ | 0 |
| `created_at` | timestamp with time zone | ✗ | now() |
| `updated_at` | timestamp with time zone | ✗ | now() |
| `spare_parts_order` | text | ✓ | - |


### `qr_validation_logs`

Campos de la tabla:\n
| Campo | Tipo | Nulo | Default |
|-------|------|------|---------|
| `id` | uuid | ✗ | gen_random_uuid() |
| `shipment_id` | uuid | ✗ | - |
| `qr_code` | text | ✗ | - |
| `validation_type` | text | ✗ | - |
| `validated_by` | text | ✓ | - |
| `validated_at` | timestamp with time zone | ✓ | now() |
| `validation_status` | text | ✗ | - |
| `metadata` | jsonb | ✓ | '{}'::jsonb |
| `created_at` | timestamp with time zone | ✓ | now() |


### `reception_operations`

Campos de la tabla:\n
| Campo | Tipo | Nulo | Default |
|-------|------|------|---------|
| `id` | uuid | ✗ | gen_random_uuid() |
| `event_id` | uuid | ✓ | - |
| `user_id` | uuid | ✗ | - |
| `set_id` | uuid | ✗ | - |
| `weight_measured` | numeric(10,2) | ✓ | - |
| `reception_completed` | boolean | ✗ | false |
| `missing_parts` | text | ✓ | - |
| `created_at` | timestamp with time zone | ✗ | now() |
| `updated_at` | timestamp with time zone | ✗ | now() |


### `referrals`

Campos de la tabla:\n
| Campo | Tipo | Nulo | Default |
|-------|------|------|---------|
| `id` | uuid | ✗ | gen_random_uuid() |
| `referrer_id` | uuid | ✗ | - |
| `referee_id` | uuid | ✗ | - |
| `status` | text | ✗ | 'pending'::text |
| `reward_credits` | integer | ✗ | 1 |
| `stripe_coupon_id` | text | ✓ | - |
| `credited_at` | timestamp with time zone | ✓ | - |
| `created_at` | timestamp with time zone | ✗ | now() |
| `updated_at` | timestamp with time zone | ✗ | now() |


### `reviews`

Campos de la tabla:\n
| Campo | Tipo | Nulo | Default |
|-------|------|------|---------|
| `id` | uuid | ✗ | gen_random_uuid() |
| `user_id` | uuid | ✗ | - |
| `set_id` | uuid | ✗ | - |
| `envio_id` | uuid | ✓ | - |
| `rating` | smallint | ✗ | - |
| `comment` | text | ✓ | - |
| `age_fit` | boolean | ✓ | - |
| `difficulty` | smallint | ✓ | - |
| `would_reorder` | boolean | ✓ | - |
| `is_published` | boolean | ✗ | true |
| `created_at` | timestamp with time zone | ✗ | now() |
| `updated_at` | timestamp with time zone | ✗ | now() |


### `set_piece_list`

Campos de la tabla:\n
| Campo | Tipo | Nulo | Default |
|-------|------|------|---------|
| `id` | uuid | ✗ | gen_random_uuid() |
| `set_id` | uuid | ✗ | - |
| `set_ref` | text | ✗ | - |
| `piece_ref` | text | ✗ | - |
| `color_ref` | text | ✓ | - |
| `piece_description` | text | ✓ | - |
| `piece_qty` | integer | ✗ | 1 |
| `piece_weight` | numeric | ✓ | - |
| `piece_image_url` | text | ✓ | - |
| `created_at` | timestamp with time zone | ✗ | now() |
| `updated_at` | timestamp with time zone | ✗ | now() |
| `piece_studdim` | text | ✓ | - |
| `element_id` | text | ✓ | - |
| `color_id` | integer | ✓ | - |
| `is_spare` | boolean | ✓ | false |
| `part_cat_id` | integer | ✓ | - |
| `year_from` | integer | ✓ | - |
| `year_to` | integer | ✓ | - |
| `is_trans` | boolean | ✓ | false |
| `external_ids` | jsonb | ✓ | - |


### `sets`

Campos de la tabla:\n
| Campo | Tipo | Nulo | Default |
|-------|------|------|---------|
| `id` | uuid | ✗ | gen_random_uuid() |
| `set_name` | text | ✗ | - |
| `set_description` | text | ✓ | - |
| `set_image_url` | text | ✓ | - |
| `set_theme` | text | ✗ | - |
| `set_age_range` | text | ✗ | - |
| `set_piece_count` | integer | ✗ | - |
| `skill_boost` | ARRAY | ✓ | - |
| `created_at` | timestamp with time zone | ✗ | now() |
| `updated_at` | timestamp with time zone | ✗ | now() |
| `year_released` | integer | ✓ | - |
| `catalogue_visibility` | boolean | ✗ | true |
| `set_ref` | text | ✓ | - |
| `set_weight` | numeric | ✓ | - |
| `set_minifigs` | numeric | ✓ | - |
| `set_status` | text | ✓ | 'inactive'::text |
| `set_price` | numeric | ✓ | 100.00 |
| `current_value_new` | numeric | ✓ | - |
| `current_value_used` | numeric | ✓ | - |
| `set_pvp_release` | numeric | ✓ | - |
| `set_subtheme` | text | ✓ | - |
| `barcode_upc` | text | ✓ | - |
| `barcode_ean` | text | ✓ | - |


### `shipment_update_logs`

Campos de la tabla:\n
| Campo | Tipo | Nulo | Default |
|-------|------|------|---------|
| `id` | uuid | ✗ | gen_random_uuid() |
| `shipment_id` | uuid | ✗ | - |
| `updated_by` | text | ✗ | - |
| `updated_fields` | ARRAY | ✗ | - |
| `old_values` | jsonb | ✓ | - |
| `new_values` | jsonb | ✗ | - |
| `source_ip` | text | ✓ | - |
| `user_agent` | text | ✓ | - |
| `created_at` | timestamp with time zone | ✗ | now() |


### `shipments`

Campos de la tabla:\n
| Campo | Tipo | Nulo | Default |
|-------|------|------|---------|
| `id` | uuid | ✗ | gen_random_uuid() |
| `user_id` | uuid | ✗ | - |
| `assigned_date` | timestamp with time zone | ✓ | - |
| `actual_delivery_date` | timestamp with time zone | ✓ | - |
| `user_delivery_date` | timestamp with time zone | ✓ | - |
| `warehouse_reception_date` | timestamp with time zone | ✓ | - |
| `shipment_status` | text | ✗ | 'pendiente'::text |
| `shipping_address` | text | ✗ | - |
| `shipping_city` | text | ✗ | - |
| `shipping_zip_code` | text | ✗ | - |
| `shipping_country` | text | ✗ | 'España'::text |
| `shipping_provider` | text | ✓ | - |
| `pickup_provider_address` | text | ✓ | - |
| `tracking_number` | text | ✓ | - |
| `carrier` | text | ✓ | - |
| `additional_notes` | text | ✓ | - |
| `created_at` | timestamp with time zone | ✗ | now() |
| `updated_at` | timestamp with time zone | ✗ | now() |
| `return_request_date` | timestamp with time zone | ✓ | - |
| `pickup_provider` | text | ✓ | - |
| `set_ref` | text | ✓ | - |
| `set_id` | uuid | ✓ | - |
| `handling_processed` | boolean | ✓ | false |
| `correos_shipment_id` | text | ✓ | - |
| `label_url` | text | ✓ | - |
| `pickup_id` | text | ✓ | - |
| `swikly_wish_id` | text | ✓ | - |
| `swikly_wish_url` | text | ✓ | - |
| `swikly_status` | text | ✓ | 'pending'::text |
| `swikly_deposit_amount` | integer | ✓ | - |
| `pickup_type` | text | ✓ | 'correos'::text |
| `brickshare_pudo_id` | text | ✓ | - |
| `delivery_qr_code` | text | ✓ | - |
| `delivery_qr_expires_at` | timestamp with time zone | ✓ | - |
| `delivery_validated_at` | timestamp with time zone | ✓ | - |
| `return_qr_code` | text | ✓ | - |
| `return_qr_expires_at` | timestamp with time zone | ✓ | - |
| `return_validated_at` | timestamp with time zone | ✓ | - |
| `brickshare_metadata` | jsonb | ✓ | '{}'::jsonb |
| `brickshare_package_id` | text | ✓ | - |
| `pudo_type` | text | ✓ | - |
| `shipping_province` | text | ✓ | - |


### `shipping_orders`

Campos de la tabla:\n
| Campo | Tipo | Nulo | Default |
|-------|------|------|---------|
| `id` | uuid | ✗ | gen_random_uuid() |
| `user_id` | uuid | ✗ | - |
| `set_id` | uuid | ✗ | - |
| `shipping_order_date` | timestamp with time zone | ✓ | now() |
| `tracking_ref` | text | ✓ | - |
| `created_at` | timestamp with time zone | ✓ | now() |
| `updated_at` | timestamp with time zone | ✓ | now() |


### `user_roles`

Campos de la tabla:\n
| Campo | Tipo | Nulo | Default |
|-------|------|------|---------|
| `id` | uuid | ✗ | gen_random_uuid() |
| `user_id` | uuid | ✗ | - |
| `role` | USER-DEFINED | ✗ | - |
| `created_at` | timestamp with time zone | ✗ | now() |


### `users`

Campos de la tabla:\n
| Campo | Tipo | Nulo | Default |
|-------|------|------|---------|
| `id` | uuid | ✗ | gen_random_uuid() |
| `user_id` | uuid | ✗ | - |
| `full_name` | text | ✓ | - |
| `avatar_url` | text | ✓ | - |
| `impact_points` | integer | ✓ | 0 |
| `created_at` | timestamp with time zone | ✗ | now() |
| `updated_at` | timestamp with time zone | ✗ | now() |
| `email` | text | ✓ | - |
| `subscription_type` | text | ✓ | - |
| `subscription_status` | text | ✓ | 'inactive'::text |
| `profile_completed` | boolean | ✓ | false |
| `user_status` | text | ✓ | 'no_set'::text |
| `stripe_customer_id` | text | ✓ | - |
| `referral_code` | text | ✓ | - |
| `referred_by` | uuid | ✓ | - |
| `referral_credits` | integer | ✗ | 0 |
| `address` | text | ✓ | - |
| `address_extra` | text | ✓ | - |
| `zip_code` | text | ✓ | - |
| `city` | text | ✓ | - |
| `province` | text | ✓ | - |
| `phone` | text | ✓ | - |
| `stripe_payment_method_id` | text | ✓ | - |
| `pudo_id` | text | ✓ | - |
| `pudo_type` | text | ✓ | - |


### `users_brickshare_dropping`

Campos de la tabla:\n
| Campo | Tipo | Nulo | Default |
|-------|------|------|---------|
| `user_id` | uuid | ✗ | - |
| `brickshare_pudo_id` | text | ✗ | - |
| `location_name` | text | ✗ | - |
| `address` | text | ✗ | - |
| `city` | text | ✗ | - |
| `postal_code` | text | ✗ | - |
| `province` | text | ✗ | - |
| `latitude` | numeric(10,8) | ✓ | - |
| `longitude` | numeric(11,8) | ✓ | - |
| `contact_email` | text | ✓ | - |
| `contact_phone` | text | ✓ | - |
| `opening_hours` | jsonb | ✓ | - |
| `selection_date` | timestamp with time zone | ✗ | now() |
| `created_at` | timestamp with time zone | ✗ | now() |
| `updated_at` | timestamp with time zone | ✗ | now() |


### `users_correos_dropping`

Campos de la tabla:\n
| Campo | Tipo | Nulo | Default |
|-------|------|------|---------|
| `user_id` | uuid | ✗ | - |
| `correos_id_pudo` | text | ✗ | - |
| `correos_name` | text | ✗ | - |
| `correos_point_type` | text | ✗ | - |
| `correos_street` | text | ✗ | - |
| `correos_street_number` | text | ✓ | - |
| `correos_zip_code` | text | ✗ | - |
| `correos_city` | text | ✗ | - |
| `correos_province` | text | ✗ | - |
| `correos_country` | text | ✗ | 'España'::text |
| `correos_full_address` | text | ✗ | - |
| `correos_latitude` | numeric(10,8) | ✗ | - |
| `correos_longitude` | numeric(11,8) | ✗ | - |
| `correos_opening_hours` | text | ✓ | - |
| `correos_structured_hours` | jsonb | ✓ | - |
| `correos_available` | boolean | ✗ | true |
| `correos_phone` | text | ✓ | - |
| `correos_email` | text | ✓ | - |
| `correos_internal_code` | text | ✓ | - |
| `correos_locker_capacity` | integer | ✓ | - |
| `correos_additional_services` | ARRAY | ✓ | - |
| `correos_accessibility` | boolean | ✓ | false |
| `correos_parking` | boolean | ✓ | false |
| `created_at` | timestamp with time zone | ✗ | now() |
| `updated_at` | timestamp with time zone | ✗ | now() |
| `correos_selection_date` | timestamp with time zone | ✗ | now() |


### `wishlist`

Campos de la tabla:\n
| Campo | Tipo | Nulo | Default |
|-------|------|------|---------|
| `id` | uuid | ✗ | gen_random_uuid() |
| `user_id` | uuid | ✗ | - |
| `set_id` | uuid | ✗ | - |
| `created_at` | timestamp with time zone | ✗ | now() |
| `status` | boolean | ✗ | true |
| `status_changed_at` | timestamp with time zone | ✓ | now() |


---

## ⚙️ Funciones RPC

### `confirm_assign_sets_to_users`

Parámetros: `p_user_ids uuid[]`

Retorna: `TABLE(shipment_id uuid, user_id uuid, set_id uuid, user_name text, user_email text, user_phone text, set_name text, set_ref text, set_weight numeric, pudo_id text, pudo_name text, pudo_address text, pudo_cp text, pudo_city text, pudo_province text, created_at timestamp with time zone)`


### `confirm_qr_validation`

Parámetros: `p_qr_code text, p_validated_by text DEFAULT NULL::text`

Retorna: `TABLE(success boolean, message text, shipment_id uuid)`


### `delete_assignment_and_rollback`

Parámetros: `p_envio_id uuid`

Retorna: `void`


### `generate_delivery_qr`

Parámetros: `p_shipment_id uuid`

Retorna: `TABLE(qr_code text, expires_at timestamp with time zone)`


### `generate_qr_code`

Parámetros: Ninguno

Retorna: `text`


### `generate_referral_code_users`

Parámetros: Ninguno

Retorna: `trigger`


### `generate_return_qr`

Parámetros: `p_shipment_id uuid`

Retorna: `TABLE(qr_code text, expires_at timestamp with time zone)`


### `get_user_active_pudo`

Parámetros: `p_user_id uuid`

Retorna: `TABLE(pudo_type text, pudo_id text, pudo_name text, pudo_address text, pudo_city text, pudo_postal_code text)`


### `handle_new_auth_user`

Parámetros: Ninguno

Retorna: `trigger`


### `handle_new_set_inventory`

Parámetros: Ninguno

Retorna: `trigger`


### `handle_new_user`

Parámetros: Ninguno

Retorna: `trigger`


### `handle_reception_close`

Parámetros: Ninguno

Retorna: `trigger`


### `handle_return_user_status`

Parámetros: Ninguno

Retorna: `trigger`


### `handle_shipment_delivered`

Parámetros: Ninguno

Retorna: `trigger`


### `handle_shipment_return_transit_inventory`

Parámetros: Ninguno

Retorna: `trigger`


### `handle_shipment_warehouse_received`

Parámetros: Ninguno

Retorna: `trigger`


### `handle_updated_at`

Parámetros: Ninguno

Retorna: `trigger`


### `has_role`

Parámetros: `_user_id uuid, _role app_role`

Retorna: `boolean`


### `increment_referral_credits`

Parámetros: `p_user_id uuid, p_amount integer DEFAULT 1`

Retorna: `void`


### `preview_assign_sets_to_users`

Parámetros: Ninguno

Retorna: `TABLE(user_id uuid, user_name text, set_id uuid, set_name text, set_ref text, set_price numeric, current_stock integer, matches_wishlist boolean, pudo_type text)`


### `process_referral_credit`

Parámetros: `p_referee_user_id uuid`

Retorna: `void`


### `set_updated_at`

Parámetros: Ninguno

Retorna: `trigger`


### `update_set_status_from_return`

Parámetros: `p_set_id uuid, p_new_status text, p_envio_id uuid DEFAULT NULL::uuid`

Retorna: `void`


### `update_updated_at_column`

Parámetros: Ninguno

Retorna: `trigger`


### `update_users_brickshare_dropping_updated_at`

Parámetros: Ninguno

Retorna: `trigger`


### `update_users_correos_dropping_updated_at`

Parámetros: Ninguno

Retorna: `trigger`


### `uses_brickshare_pudo`

Parámetros: `shipment_id uuid`

Retorna: `boolean`


### `validate_qr_code`

Parámetros: `p_qr_code text`

Retorna: `TABLE(shipment_id uuid, validation_type text, is_valid boolean, error_message text, shipment_info jsonb)`



---

## 🔔 Triggers

### Tabla: `donations`

- **update_donations_updated_at**
  - Evento: UPDATE
  - Timing: BEFORE



### Tabla: `inventory_sets`

- **update_inventario_sets_updated_at**
  - Evento: UPDATE
  - Timing: BEFORE



### Tabla: `reception_operations`

- **update_reception_operations_updated_at**
  - Evento: UPDATE
  - Timing: BEFORE

- **on_reception_completed**
  - Evento: UPDATE
  - Timing: AFTER



### Tabla: `referrals`

- **referrals_updated_at**
  - Evento: UPDATE
  - Timing: BEFORE



### Tabla: `reviews`

- **reviews_updated_at**
  - Evento: UPDATE
  - Timing: BEFORE



### Tabla: `set_piece_list`

- **update_set_piece_list_updated_at**
  - Evento: UPDATE
  - Timing: BEFORE



### Tabla: `sets`

- **on_set_created**
  - Evento: INSERT
  - Timing: AFTER

- **update_sets_updated_at**
  - Evento: UPDATE
  - Timing: BEFORE



### Tabla: `shipments`

- **on_shipment_return_user_status**
  - Evento: UPDATE
  - Timing: AFTER

- **on_shipment_delivered**
  - Evento: UPDATE
  - Timing: AFTER

- **on_shipment_warehouse_received**
  - Evento: UPDATE
  - Timing: BEFORE

- **on_shipment_return_transit_inv**
  - Evento: UPDATE
  - Timing: AFTER

- **update_shipments_updated_at**
  - Evento: UPDATE
  - Timing: BEFORE



### Tabla: `shipping_orders`

- **on_shipping_orders_updated**
  - Evento: UPDATE
  - Timing: BEFORE



### Tabla: `users`

- **update_users_updated_at**
  - Evento: UPDATE
  - Timing: BEFORE

- **users_generate_referral_code**
  - Evento: INSERT
  - Timing: BEFORE



### Tabla: `users_brickshare_dropping`

- **trigger_update_users_brickshare_dropping_updated_at**
  - Evento: UPDATE
  - Timing: BEFORE



### Tabla: `users_correos_dropping`

- **trigger_update_users_correos_dropping_updated_at**
  - Evento: UPDATE
  - Timing: BEFORE



