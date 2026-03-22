Output format is unaligned.
# 📊 Esquema de Base de Datos - Brickshare


---

## 📋 Índice

- [Tablas](#tablas)
- [Funciones RPC](#funciones-rpc)
- [Triggers](#triggers)
- [Políticas RLS](#políticas-rls)

---

## 📋 Tablas

### backoffice_operations

| Campo | Tipo | Nulo | Default | Descripción |
|-------|------|------|---------|-------------|
| `event_id` | uuid | ✗ | `gen_random_uuid()` | - |
| `user_id` | uuid | ✓ | - | - |
| `operation_type` | USER-DEFINED | ✗ | - | - |
| `operation_time` | timestamp with time zone | ✗ | `now()` | - |
| `metadata` | jsonb | ✓ | - | - |


### brickshare_pudo_locations

**Descripción**: Brickshare pickup and drop-off locations

| Campo | Tipo | Nulo | Default | Descripción |
|-------|------|------|---------|-------------|
| `id` | text | ✗ | - | - |
| `name` | text | ✗ | - | - |
| `address` | text | ✗ | - | - |
| `city` | text | ✗ | - | - |
| `postal_code` | text | ✗ | - | - |
| `province` | text | ✗ | - | - |
| `latitude` | numeric(10,8) | ✓ | - | - |
| `longitude` | numeric(11,8) | ✓ | - | - |
| `contact_phone` | text | ✓ | - | - |
| `contact_email` | text | ✓ | - | - |
| `opening_hours` | jsonb | ✓ | - | - |
| `is_active` | boolean | ✓ | `true` | - |
| `notes` | text | ✓ | - | - |
| `created_at` | timestamp with time zone | ✓ | `now()` | - |
| `updated_at` | timestamp with time zone | ✓ | `now()` | - |


### donations

| Campo | Tipo | Nulo | Default | Descripción |
|-------|------|------|---------|-------------|
| `id` | uuid | ✗ | `gen_random_uuid()` | - |
| `user_id` | uuid | ✓ | - | - |
| `name` | text | ✗ | - | - |
| `email` | text | ✗ | - | - |
| `phone` | text | ✓ | - | - |
| `address` | text | ✓ | - | - |
| `estimated_weight` | numeric | ✗ | - | - |
| `delivery_method` | text | ✗ | - | - |
| `reward` | text | ✗ | - | - |
| `children_benefited` | integer | ✗ | - | - |
| `co2_avoided` | numeric | ✗ | - | - |
| `status` | text | ✗ | `'pending'::text` | - |
| `tracking_code` | text | ✓ | - | - |
| `created_at` | timestamp with time zone | ✗ | `now()` | - |
| `updated_at` | timestamp with time zone | ✗ | `now()` | - |


### inventory_sets

**Descripción**: Detailed tracking of set units across different states (warehouse, shipping, use, etc.)

| Campo | Tipo | Nulo | Default | Descripción |
|-------|------|------|---------|-------------|
| `id` | uuid | ✗ | `gen_random_uuid()` | - |
| `set_id` | uuid | ✗ | - | - |
| `set_ref` | text | ✓ | - | Official LEGO reference number (sets.lego_ref) |
| `inventory_set_total_qty` | integer | ✗ | `0` | - |
| `in_shipping` | integer | ✗ | `0` | - |
| `in_use` | integer | ✗ | `0` | - |
| `in_return` | integer | ✗ | `0` | - |
| `in_repair` | integer | ✗ | `0` | - |
| `created_at` | timestamp with time zone | ✗ | `now()` | - |
| `updated_at` | timestamp with time zone | ✗ | `now()` | - |
| `spare_parts_order` | text | ✓ | - | - |


### qr_validation_logs

**Descripción**: Logs of QR code validations for deliveries and returns

| Campo | Tipo | Nulo | Default | Descripción |
|-------|------|------|---------|-------------|
| `id` | uuid | ✗ | `gen_random_uuid()` | - |
| `shipment_id` | uuid | ✗ | - | - |
| `qr_code` | text | ✗ | - | - |
| `validation_type` | text | ✗ | - | - |
| `validated_by` | text | ✓ | - | - |
| `validated_at` | timestamp with time zone | ✓ | `now()` | - |
| `validation_status` | text | ✗ | - | - |
| `metadata` | jsonb | ✓ | `'{}'::jsonb` | - |
| `created_at` | timestamp with time zone | ✓ | `now()` | - |


### reception_operations

**Descripción**: Table to record the reception and maintenance check of sets returned by users.

| Campo | Tipo | Nulo | Default | Descripción |
|-------|------|------|---------|-------------|
| `id` | uuid | ✗ | `gen_random_uuid()` | - |
| `event_id` | uuid | ✓ | - | - |
| `user_id` | uuid | ✗ | - | - |
| `set_id` | uuid | ✗ | - | - |
| `weight_measured` | numeric(10,2) | ✓ | - | Actual weight of the set upon reception (in grams). |
| `reception_completed` | boolean | ✗ | `false` | True if the reception process is completed. |
| `missing_parts` | text | ✓ | - | Details or notes about missing pieces found during reception. |
| `created_at` | timestamp with time zone | ✗ | `now()` | - |
| `updated_at` | timestamp with time zone | ✗ | `now()` | - |


### referrals

**Descripción**: Referral program: tracks who referred whom and reward status

| Campo | Tipo | Nulo | Default | Descripción |
|-------|------|------|---------|-------------|
| `id` | uuid | ✗ | `gen_random_uuid()` | - |
| `referrer_id` | uuid | ✗ | - | - |
| `referee_id` | uuid | ✗ | - | - |
| `status` | text | ✗ | `'pending'::text` | pending=signup done, credited=reward applied, rejected=did not qualify |
| `reward_credits` | integer | ✗ | `1` | Credits awarded (1 = 1 free month equivalent) |
| `stripe_coupon_id` | text | ✓ | - | - |
| `credited_at` | timestamp with time zone | ✓ | - | - |
| `created_at` | timestamp with time zone | ✗ | `now()` | - |
| `updated_at` | timestamp with time zone | ✗ | `now()` | - |


### reviews

**Descripción**: User reviews and ratings for rented LEGO sets

| Campo | Tipo | Nulo | Default | Descripción |
|-------|------|------|---------|-------------|
| `id` | uuid | ✗ | `gen_random_uuid()` | - |
| `user_id` | uuid | ✗ | - | - |
| `set_id` | uuid | ✗ | - | - |
| `envio_id` | uuid | ✓ | - | - |
| `rating` | smallint | ✗ | - | 1-5 star rating |
| `comment` | text | ✓ | - | - |
| `age_fit` | boolean | ✓ | - | Was the set appropriate for the stated age range? |
| `difficulty` | smallint | ✓ | - | 1=very easy, 5=very hard building difficulty |
| `would_reorder` | boolean | ✓ | - | Would the user rent this set again? |
| `is_published` | boolean | ✗ | `true` | Set to false to hide a review without deleting it |
| `created_at` | timestamp with time zone | ✗ | `now()` | - |
| `updated_at` | timestamp with time zone | ✗ | `now()` | - |


### set_piece_list

| Campo | Tipo | Nulo | Default | Descripción |
|-------|------|------|---------|-------------|
| `id` | uuid | ✗ | `gen_random_uuid()` | - |
| `set_id` | uuid | ✗ | - | - |
| `set_ref` | text | ✗ | - | - |
| `piece_ref` | text | ✗ | - | - |
| `color_ref` | text | ✓ | - | - |
| `piece_description` | text | ✓ | - | - |
| `piece_qty` | integer | ✗ | `1` | - |
| `piece_weight` | numeric | ✓ | - | - |
| `piece_image_url` | text | ✓ | - | - |
| `created_at` | timestamp with time zone | ✗ | `now()` | - |
| `updated_at` | timestamp with time zone | ✗ | `now()` | - |
| `piece_studdim` | text | ✓ | - | - |
| `element_id` | text | ✓ | - | - |
| `color_id` | integer | ✓ | - | - |
| `is_spare` | boolean | ✓ | `false` | - |
| `part_cat_id` | integer | ✓ | - | - |
| `year_from` | integer | ✓ | - | - |
| `year_to` | integer | ✓ | - | - |
| `is_trans` | boolean | ✓ | `false` | - |
| `external_ids` | jsonb | ✓ | - | - |


### sets

| Campo | Tipo | Nulo | Default | Descripción |
|-------|------|------|---------|-------------|
| `id` | uuid | ✗ | `gen_random_uuid()` | - |
| `set_name` | text | ✗ | - | - |
| `set_description` | text | ✓ | - | - |
| `set_image_url` | text | ✓ | - | - |
| `set_theme` | text | ✗ | - | - |
| `set_age_range` | text | ✗ | - | - |
| `set_piece_count` | integer | ✗ | - | - |
| `skill_boost` | ARRAY | ✓ | - | - |
| `created_at` | timestamp with time zone | ✗ | `now()` | - |
| `updated_at` | timestamp with time zone | ✗ | `now()` | - |
| `year_released` | integer | ✓ | - | - |
| `catalogue_visibility` | boolean | ✗ | `true` | - |
| `set_ref` | text | ✓ | - | Official LEGO catalog reference number |
| `set_weight` | numeric | ✓ | - | - |
| `set_minifigs` | numeric | ✓ | - | - |
| `set_status` | text | ✓ | `'inactive'::text` | - |
| `set_price` | numeric | ✓ | `100.00` | - |
| `current_value_new` | numeric | ✓ | - | - |
| `current_value_used` | numeric | ✓ | - | - |
| `set_pvp_release` | numeric | ✓ | - | - |
| `set_subtheme` | text | ✓ | - | - |
| `barcode_upc` | text | ✓ | - | - |
| `barcode_ean` | text | ✓ | - | - |


### shipments

| Campo | Tipo | Nulo | Default | Descripción |
|-------|------|------|---------|-------------|
| `id` | uuid | ✗ | `gen_random_uuid()` | - |
| `user_id` | uuid | ✗ | - | - |
| `assigned_date` | timestamp with time zone | ✓ | - | - |
| `estimated_delivery_date` | timestamp with time zone | ✓ | - | - |
| `actual_delivery_date` | timestamp with time zone | ✓ | - | - |
| `user_delivery_date` | timestamp with time zone | ✓ | - | - |
| `warehouse_reception_date` | timestamp with time zone | ✓ | - | - |
| `estimated_return_date` | date | ✓ | - | - |
| `shipment_status` | text | ✗ | `'pendiente'::text` | Allowed values: preparacion, ruta_envio, entregado, devuelto, ruta_devolucion, cancelado |
| `shipping_address` | text | ✗ | - | - |
| `shipping_city` | text | ✗ | - | - |
| `shipping_zip_code` | text | ✗ | - | - |
| `shipping_country` | text | ✗ | `'España'::text` | - |
| `shipping_provider` | text | ✓ | - | - |
| `pickup_provider_address` | text | ✓ | - | - |
| `tracking_number` | text | ✓ | - | - |
| `carrier` | text | ✓ | - | - |
| `additional_notes` | text | ✓ | - | - |
| `created_at` | timestamp with time zone | ✗ | `now()` | - |
| `updated_at` | timestamp with time zone | ✗ | `now()` | - |
| `warehouse_pickup_date` | timestamp with time zone | ✓ | - | Date when the shipment was picked up from the warehouse |
| `return_request_date` | timestamp with time zone | ✓ | - | Date when the user requested a return |
| `pickup_provider` | text | ✓ | - | Carrier or entity in charge of the return pickup |
| `set_ref` | text | ✓ | - | LEGO set reference (e.g., 75192) for quick reference |
| `set_id` | uuid | ✓ | - | Direct reference to the set being shipped, eliminates need for orders table |
| `handling_processed` | boolean | ✓ | `false` | - |
| `correos_shipment_id` | text | ✓ | - | External shipment identifier returned by Correos Preregister API |
| `label_url` | text | ✓ | - | Path to the generated shipping label in storage |
| `pickup_id` | text | ✓ | - | External identifier for the scheduled pickup |
| `last_tracking_update` | timestamp with time zone | ✓ | - | Timestamp of the last synchronization with Correos Tracking API |
| `swikly_wish_id` | text | ✓ | - | - |
| `swikly_wish_url` | text | ✓ | - | - |
| `swikly_status` | text | ✓ | `'pending'::text` | - |
| `swikly_deposit_amount` | integer | ✓ | - | - |
| `pickup_type` | text | ✓ | `'correos'::text` | - |
| `brickshare_pudo_id` | text | ✓ | - | - |
| `delivery_qr_code` | text | ✓ | - | - |
| `delivery_qr_expires_at` | timestamp with time zone | ✓ | - | - |
| `delivery_validated_at` | timestamp with time zone | ✓ | - | - |
| `return_qr_code` | text | ✓ | - | - |
| `return_qr_expires_at` | timestamp with time zone | ✓ | - | - |
| `return_validated_at` | timestamp with time zone | ✓ | - | - |
| `brickshare_metadata` | jsonb | ✓ | `'{}'::jsonb` | - |
| `brickshare_package_id` | text | ✓ | - | ID del package en Brickshare_logistics. Usado cuando pickup_type="brickshare" para sincronización con el sistema de PUDO. |


### shipping_orders

**Descripción**: Tracks shipping orders with external carriers

| Campo | Tipo | Nulo | Default | Descripción |
|-------|------|------|---------|-------------|
| `id` | uuid | ✗ | `gen_random_uuid()` | - |
| `user_id` | uuid | ✗ | - | - |
| `set_id` | uuid | ✗ | - | - |
| `shipping_order_date` | timestamp with time zone | ✓ | `now()` | - |
| `tracking_ref` | text | ✓ | - | - |
| `created_at` | timestamp with time zone | ✓ | `now()` | - |
| `updated_at` | timestamp with time zone | ✓ | `now()` | - |


### user_roles

| Campo | Tipo | Nulo | Default | Descripción |
|-------|------|------|---------|-------------|
| `id` | uuid | ✗ | `gen_random_uuid()` | - |
| `user_id` | uuid | ✗ | - | - |
| `role` | USER-DEFINED | ✗ | - | - |
| `created_at` | timestamp with time zone | ✗ | `now()` | - |


### users

**Descripción**: Auth: Stores user login data within a secure schema.

| Campo | Tipo | Nulo | Default | Descripción |
|-------|------|------|---------|-------------|
| `id` | uuid | ✗ | `gen_random_uuid()` | - |
| `user_id` | uuid | ✗ | - | - |
| `full_name` | text | ✓ | - | - |
| `avatar_url` | text | ✓ | - | - |
| `impact_points` | integer | ✓ | `0` | - |
| `created_at` | timestamp with time zone | ✗ | `now()` | - |
| `updated_at` | timestamp with time zone | ✗ | `now()` | - |
| `email` | text | ✓ | - | - |
| `subscription_type` | text | ✓ | - | - |
| `subscription_status` | text | ✓ | `'inactive'::text` | - |
| `profile_completed` | boolean | ✓ | `false` | - |
| `user_status` | text | ✓ | `'no_set'::text` | - |
| `stripe_customer_id` | text | ✓ | - | - |
| `referral_code` | text | ✓ | - | - |
| `referred_by` | uuid | ✓ | - | Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails. |
| `referral_credits` | integer | ✗ | `0` | - |
| `address` | text | ✓ | - | - |
| `address_extra` | text | ✓ | - | - |
| `zip_code` | text | ✓ | - | - |
| `city` | text | ✓ | - | - |
| `province` | text | ✓ | - | - |
| `phone` | text | ✓ | - | - |


### users

| Campo | Tipo | Nulo | Default | Descripción |
|-------|------|------|---------|-------------|
| `id` | uuid | ✗ | `gen_random_uuid()` | - |
| `user_id` | uuid | ✗ | - | - |
| `full_name` | text | ✓ | - | - |
| `avatar_url` | text | ✓ | - | - |
| `impact_points` | integer | ✓ | `0` | - |
| `created_at` | timestamp with time zone | ✗ | `now()` | - |
| `updated_at` | timestamp with time zone | ✗ | `now()` | - |
| `email` | text | ✓ | - | - |
| `subscription_type` | text | ✓ | - | The plan level (Brick Starter, Pro, Master) |
| `subscription_status` | text | ✓ | `'inactive'::text` | Status of the subscription (OK, trialing, past_due, canceled, etc.) |
| `profile_completed` | boolean | ✓ | `false` | Whether the user has completed their profile information |
| `user_status` | text | ✓ | `'no_set'::text` | Allowed values: no_set, set_shipping, received, has_set, set_returning, suspended, cancelled |
| `stripe_customer_id` | text | ✓ | - | Stripe Customer ID associated with the user |
| `referral_code` | text | ✓ | - | Unique shareable code (6 chars, auto-generated) |
| `referred_by` | uuid | ✓ | - | auth.users.id of the user who referred this one |
| `referral_credits` | integer | ✗ | `0` | Accumulated credits from successful referrals |
| `address` | text | ✓ | - | - |
| `address_extra` | text | ✓ | - | - |
| `zip_code` | text | ✓ | - | - |
| `city` | text | ✓ | - | - |
| `province` | text | ✓ | - | - |
| `phone` | text | ✓ | - | - |


### users_correos_dropping

**Descripción**: Stores user-selected Correos PUDO (Pick Up Drop Off) points for delivery and pickup

| Campo | Tipo | Nulo | Default | Descripción |
|-------|------|------|---------|-------------|
| `user_id` | uuid | ✗ | - | - |
| `correos_id_pudo` | text | ✗ | - | - |
| `correos_name` | text | ✗ | - | - |
| `correos_point_type` | text | ✗ | - | - |
| `correos_street` | text | ✗ | - | - |
| `correos_street_number` | text | ✓ | - | - |
| `correos_zip_code` | text | ✗ | - | - |
| `correos_city` | text | ✗ | - | - |
| `correos_province` | text | ✗ | - | - |
| `correos_country` | text | ✗ | `'España'::text` | - |
| `correos_full_address` | text | ✗ | - | - |
| `correos_latitude` | numeric(10,8) | ✗ | - | - |
| `correos_longitude` | numeric(11,8) | ✗ | - | - |
| `correos_opening_hours` | text | ✓ | - | - |
| `correos_structured_hours` | jsonb | ✓ | - | - |
| `correos_available` | boolean | ✗ | `true` | - |
| `correos_phone` | text | ✓ | - | - |
| `correos_email` | text | ✓ | - | - |
| `correos_internal_code` | text | ✓ | - | - |
| `correos_locker_capacity` | integer | ✓ | - | - |
| `correos_additional_services` | ARRAY | ✓ | - | - |
| `correos_accessibility` | boolean | ✓ | `false` | - |
| `correos_parking` | boolean | ✓ | `false` | - |
| `created_at` | timestamp with time zone | ✗ | `now()` | - |
| `updated_at` | timestamp with time zone | ✗ | `now()` | - |
| `correos_selection_date` | timestamp with time zone | ✗ | `now()` | - |


### wishlist

| Campo | Tipo | Nulo | Default | Descripción |
|-------|------|------|---------|-------------|
| `id` | uuid | ✗ | `gen_random_uuid()` | - |
| `user_id` | uuid | ✗ | - | - |
| `set_id` | uuid | ✗ | - | - |
| `created_at` | timestamp with time zone | ✗ | `now()` | - |
| `status` | boolean | ✗ | `true` | - |
| `status_changed_at` | timestamp with time zone | ✓ | `now()` | - |



---

## ⚙️ Funciones RPC

### `confirm_assign_sets_to_users`

**Parámetros**: `p_user_ids uuid[]`
**Retorna**: `TABLE(envio_id uuid, user_id uuid, set_id uuid, order_id uuid, user_name text, user_email text, user_phone text, set_name text, set_ref text, set_weight numeric, set_dim text, pudo_id text, pudo_name text, pudo_address text, pudo_cp text, pudo_city text, pudo_province text, created_at timestamp with time zone)`


### `confirm_qr_validation`

**Parámetros**: `p_qr_code text, p_validated_by text DEFAULT NULL::text`
**Retorna**: `TABLE(success boolean, message text, shipment_id uuid)`


### `delete_assignment_and_rollback`

**Parámetros**: `p_envio_id uuid`
**Retorna**: `void`


### `generate_delivery_qr`

**Parámetros**: `p_shipment_id uuid`
**Retorna**: `TABLE(qr_code text, expires_at timestamp with time zone)`


### `generate_qr_code`

**Parámetros**: Ninguno
**Retorna**: `text`


### `generate_referral_code_users`

**Parámetros**: Ninguno
**Retorna**: `trigger`


### `generate_return_qr`

**Parámetros**: `p_shipment_id uuid`
**Retorna**: `TABLE(qr_code text, expires_at timestamp with time zone)`


### `handle_new_set_inventory`

**Parámetros**: Ninguno
**Retorna**: `trigger`


### `handle_new_user`

**Parámetros**: Ninguno
**Retorna**: `trigger`


### `handle_reception_close`

**Parámetros**: Ninguno
**Retorna**: `trigger`


### `handle_return_user_status`

**Parámetros**: Ninguno
**Retorna**: `trigger`


### `handle_shipment_delivered`

**Parámetros**: Ninguno
**Retorna**: `trigger`


### `handle_shipment_return_transit_inventory`

**Parámetros**: Ninguno
**Retorna**: `trigger`


### `handle_shipment_warehouse_received`

**Parámetros**: Ninguno
**Retorna**: `trigger`


### `handle_updated_at`

**Parámetros**: Ninguno
**Retorna**: `trigger`


### `has_role`

**Parámetros**: `_user_id uuid, _role app_role`
**Retorna**: `boolean`


### `increment_referral_credits`

**Parámetros**: `p_user_id uuid, p_amount integer DEFAULT 1`
**Retorna**: `void`


### `preview_assign_sets_to_users`

**Descripción**: Shows proposed set assignments checking history to avoid duplicates, with random fallback if no wishlist match - includes matches_wishlist flag

**Parámetros**: Ninguno
**Retorna**: `TABLE(user_id uuid, user_name text, set_id uuid, set_name text, set_ref text, set_price numeric, current_stock integer, matches_wishlist boolean)`


### `process_referral_credit`

**Parámetros**: `p_referee_user_id uuid`
**Retorna**: `void`


### `set_updated_at`

**Parámetros**: Ninguno
**Retorna**: `trigger`


### `update_set_status_from_return`

**Parámetros**: `p_set_id uuid, p_new_status text, p_envio_id uuid DEFAULT NULL::uuid`
**Retorna**: `void`


### `update_updated_at_column`

**Parámetros**: Ninguno
**Retorna**: `trigger`


### `update_users_correos_dropping_updated_at`

**Parámetros**: Ninguno
**Retorna**: `trigger`


### `uses_brickshare_pudo`

**Parámetros**: `shipment_id uuid`
**Retorna**: `boolean`


### `validate_qr_code`

**Parámetros**: `p_qr_code text`
**Retorna**: `TABLE(shipment_id uuid, validation_type text, is_valid boolean, error_message text, shipment_info jsonb)`



---

## 🔔 Triggers

### donations

- **update_donations_updated_at**
  - Evento: UPDATE
  - Timing: BEFORE
  - Función: `EXECUTE FUNCTION update_updated_at_column()`


### inventory_sets

- **update_inventario_sets_updated_at**
  - Evento: UPDATE
  - Timing: BEFORE
  - Función: `EXECUTE FUNCTION update_updated_at_column()`


### reception_operations

- **update_reception_operations_updated_at**
  - Evento: UPDATE
  - Timing: BEFORE
  - Función: `EXECUTE FUNCTION update_updated_at_column()`

- **on_reception_completed**
  - Evento: UPDATE
  - Timing: AFTER
  - Función: `EXECUTE FUNCTION handle_reception_close()`


### referrals

- **referrals_updated_at**
  - Evento: UPDATE
  - Timing: BEFORE
  - Función: `EXECUTE FUNCTION set_updated_at()`


### reviews

- **reviews_updated_at**
  - Evento: UPDATE
  - Timing: BEFORE
  - Función: `EXECUTE FUNCTION set_updated_at()`


### set_piece_list

- **update_set_piece_list_updated_at**
  - Evento: UPDATE
  - Timing: BEFORE
  - Función: `EXECUTE FUNCTION update_updated_at_column()`


### sets

- **update_sets_updated_at**
  - Evento: UPDATE
  - Timing: BEFORE
  - Función: `EXECUTE FUNCTION update_updated_at_column()`

- **on_set_created**
  - Evento: INSERT
  - Timing: AFTER
  - Función: `EXECUTE FUNCTION handle_new_set_inventory()`


### shipments

- **on_shipment_warehouse_received**
  - Evento: UPDATE
  - Timing: BEFORE
  - Función: `EXECUTE FUNCTION handle_shipment_warehouse_received()`

- **on_shipment_delivered**
  - Evento: UPDATE
  - Timing: AFTER
  - Función: `EXECUTE FUNCTION handle_shipment_delivered()`

- **on_shipment_return_user_status**
  - Evento: UPDATE
  - Timing: AFTER
  - Función: `EXECUTE FUNCTION handle_return_user_status()`

- **on_shipment_return_transit_inv**
  - Evento: UPDATE
  - Timing: AFTER
  - Función: `EXECUTE FUNCTION handle_shipment_return_transit_inventory()`

- **update_shipments_updated_at**
  - Evento: UPDATE
  - Timing: BEFORE
  - Función: `EXECUTE FUNCTION update_updated_at_column()`


### shipping_orders

- **on_shipping_orders_updated**
  - Evento: UPDATE
  - Timing: BEFORE
  - Función: `EXECUTE FUNCTION handle_updated_at()`


### users

- **update_users_updated_at**
  - Evento: UPDATE
  - Timing: BEFORE
  - Función: `EXECUTE FUNCTION update_updated_at_column()`

- **users_generate_referral_code**
  - Evento: INSERT
  - Timing: BEFORE
  - Función: `EXECUTE FUNCTION generate_referral_code_users()`


### users_correos_dropping

- **trigger_update_users_correos_dropping_updated_at**
  - Evento: UPDATE
  - Timing: BEFORE
  - Función: `EXECUTE FUNCTION update_users_correos_dropping_updated_at()`



---

## 🔒 Políticas RLS (Row Level Security)

### Tabla: `backoffice_operations`

- **Admins and Operators can log operations**
  - Comando: `INSERT`
  - Roles: authenticated
  - Usando: `true`
  - With check: `(has_role(auth.uid(), 'admin'::app_role) OR has_role(auth.uid(), 'operador'::app_role))`

- **Admins and Operators can view operations**
  - Comando: `SELECT`
  - Roles: authenticated
  - Usando: `(has_role(auth.uid(), 'admin'::app_role) OR has_role(auth.uid(), 'operador'::app_role))`



### Tabla: `brickshare_pudo_locations`

- **Allow public read of active PUDO locations**
  - Comando: `SELECT`
  - Roles: public
  - Usando: `(is_active = true)`



### Tabla: `donations`

- **Admins can manage all donations**
  - Comando: `ALL`
  - Roles: public
  - Usando: `has_role(auth.uid(), 'admin'::app_role)`


- **Authenticated users can insert their own donations**
  - Comando: `INSERT`
  - Roles: public
  - Usando: `true`
  - With check: `((auth.uid() IS NOT NULL) AND ((user_id IS NULL) OR (auth.uid() = user_id)))`

- **Users can view their own donations**
  - Comando: `SELECT`
  - Roles: public
  - Usando: `((auth.uid() = user_id) OR (email = (( SELECT users.email
   FROM auth.users
  WHERE (users.id = auth.uid())))::text))`



### Tabla: `inventory_sets`

- **Inventario is viewable by everyone**
  - Comando: `SELECT`
  - Roles: public
  - Usando: `true`


- **Admins and Operadores can manage inventario**
  - Comando: `ALL`
  - Roles: authenticated
  - Usando: `(has_role(auth.uid(), 'admin'::app_role) OR has_role(auth.uid(), 'operador'::app_role))`



### Tabla: `qr_validation_logs`

- **Users can view their own validation logs**
  - Comando: `SELECT`
  - Roles: authenticated
  - Usando: `(shipment_id IN ( SELECT s.id
   FROM shipments s
  WHERE (s.user_id = auth.uid())))`



### Tabla: `reception_operations`

- **Admins and operators can insert**
  - Comando: `INSERT`
  - Roles: authenticated
  - Usando: `true`
  - With check: `(has_role(auth.uid(), 'admin'::app_role) OR has_role(auth.uid(), 'operador'::app_role))`

- **Authenticated users can read**
  - Comando: `SELECT`
  - Roles: authenticated
  - Usando: `true`


- **Admins and operators can update**
  - Comando: `UPDATE`
  - Roles: authenticated
  - Usando: `(has_role(auth.uid(), 'admin'::app_role) OR has_role(auth.uid(), 'operador'::app_role))`
  - With check: `(has_role(auth.uid(), 'admin'::app_role) OR has_role(auth.uid(), 'operador'::app_role))`


### Tabla: `referrals`

- **referrals_select_referee**
  - Comando: `SELECT`
  - Roles: authenticated
  - Usando: `(referee_id = auth.uid())`


- **referrals_select_own**
  - Comando: `SELECT`
  - Roles: authenticated
  - Usando: `(referrer_id = auth.uid())`


- **referrals_admin_all**
  - Comando: `ALL`
  - Roles: authenticated
  - Usando: `(EXISTS ( SELECT 1
   FROM user_roles
  WHERE ((user_roles.user_id = auth.uid()) AND (user_roles.role = ANY (ARRAY['admin'::app_role, 'operador'::app_role])))))`



### Tabla: `reviews`

- **reviews_select_published**
  - Comando: `SELECT`
  - Roles: public
  - Usando: `(is_published = true)`


- **reviews_admin_all**
  - Comando: `ALL`
  - Roles: authenticated
  - Usando: `(EXISTS ( SELECT 1
   FROM user_roles
  WHERE ((user_roles.user_id = auth.uid()) AND (user_roles.role = ANY (ARRAY['admin'::app_role, 'operador'::app_role])))))`


- **reviews_delete_own**
  - Comando: `DELETE`
  - Roles: authenticated
  - Usando: `(auth.uid() = user_id)`


- **reviews_update_own**
  - Comando: `UPDATE`
  - Roles: authenticated
  - Usando: `(auth.uid() = user_id)`
  - With check: `(auth.uid() = user_id)`

- **reviews_insert_own**
  - Comando: `INSERT`
  - Roles: authenticated
  - Usando: `true`
  - With check: `(auth.uid() = user_id)`

- **reviews_select_own**
  - Comando: `SELECT`
  - Roles: authenticated
  - Usando: `(auth.uid() = user_id)`



### Tabla: `set_piece_list`

- **Admins can manage set piece lists**
  - Comando: `ALL`
  - Roles: authenticated
  - Usando: `has_role(auth.uid(), 'admin'::app_role)`


- **Set piece lists are viewable by everyone**
  - Comando: `SELECT`
  - Roles: public
  - Usando: `true`



### Tabla: `sets`

- **Sets are viewable by everyone**
  - Comando: `SELECT`
  - Roles: public
  - Usando: `true`


- **Admins can delete sets**
  - Comando: `DELETE`
  - Roles: public
  - Usando: `has_role(auth.uid(), 'admin'::app_role)`


- **Admins can update sets**
  - Comando: `UPDATE`
  - Roles: public
  - Usando: `has_role(auth.uid(), 'admin'::app_role)`


- **Admins can insert sets**
  - Comando: `INSERT`
  - Roles: public
  - Usando: `true`
  - With check: `has_role(auth.uid(), 'admin'::app_role)`


### Tabla: `shipments`

- **Admins and operators full access**
  - Comando: `ALL`
  - Roles: public
  - Usando: `(has_role(auth.uid(), 'admin'::app_role) OR has_role(auth.uid(), 'operador'::app_role))`


- **Operators can create shipments**
  - Comando: `INSERT`
  - Roles: public
  - Usando: `true`
  - With check: `(has_role(auth.uid(), 'admin'::app_role) OR has_role(auth.uid(), 'operador'::app_role))`

- **Operators can update shipments**
  - Comando: `UPDATE`
  - Roles: public
  - Usando: `(has_role(auth.uid(), 'admin'::app_role) OR has_role(auth.uid(), 'operador'::app_role))`


- **Users can view own shipments**
  - Comando: `SELECT`
  - Roles: public
  - Usando: `(auth.uid() = user_id)`


- **Users can update own shipment status**
  - Comando: `UPDATE`
  - Roles: authenticated
  - Usando: `(auth.uid() = user_id)`
  - With check: `((auth.uid() = user_id) AND (shipment_status = 'return_in_transit'::text))`


### Tabla: `shipping_orders`

- **Users can view their own shipping orders**
  - Comando: `SELECT`
  - Roles: authenticated
  - Usando: `(auth.uid() = user_id)`



### Tabla: `user_roles`

- **Users can view their own roles**
  - Comando: `SELECT`
  - Roles: authenticated
  - Usando: `(auth.uid() = user_id)`


- **Admins can manage all roles**
  - Comando: `ALL`
  - Roles: authenticated
  - Usando: `has_role(auth.uid(), 'admin'::app_role)`



### Tabla: `users`

- **Users can delete their own profile**
  - Comando: `DELETE`
  - Roles: authenticated
  - Usando: `(auth.uid() = user_id)`


- **Admins can view all profiles**
  - Comando: `SELECT`
  - Roles: authenticated
  - Usando: `has_role(auth.uid(), 'admin'::app_role)`


- **users_select_own_referral**
  - Comando: `SELECT`
  - Roles: authenticated
  - Usando: `(user_id = auth.uid())`


- **Users can view their own profile**
  - Comando: `SELECT`
  - Roles: authenticated
  - Usando: `(auth.uid() = user_id)`


- **Admins and Operadores can view all users**
  - Comando: `SELECT`
  - Roles: public
  - Usando: `(has_role(auth.uid(), 'admin'::app_role) OR has_role(auth.uid(), 'operador'::app_role))`


- **Users can view own profile**
  - Comando: `SELECT`
  - Roles: public
  - Usando: `(auth.uid() = user_id)`


- **Admins can update any user**
  - Comando: `UPDATE`
  - Roles: public
  - Usando: `has_role(auth.uid(), 'admin'::app_role)`


- **Users can update own profile**
  - Comando: `UPDATE`
  - Roles: public
  - Usando: `(auth.uid() = user_id)`


- **Users can insert their own profile**
  - Comando: `INSERT`
  - Roles: authenticated
  - Usando: `true`
  - With check: `(auth.uid() = user_id)`

- **Users can update their own profile**
  - Comando: `UPDATE`
  - Roles: authenticated
  - Usando: `(auth.uid() = user_id)`



### Tabla: `users_correos_dropping`

- **Users can insert their own Correos PUDO selection**
  - Comando: `INSERT`
  - Roles: public
  - Usando: `true`
  - With check: `(auth.uid() = user_id)`

- **Users can delete their own Correos PUDO selection**
  - Comando: `DELETE`
  - Roles: public
  - Usando: `(auth.uid() = user_id)`


- **Users can update their own Correos PUDO selection**
  - Comando: `UPDATE`
  - Roles: public
  - Usando: `(auth.uid() = user_id)`
  - With check: `(auth.uid() = user_id)`

- **Users can view their own Correos PUDO selection**
  - Comando: `SELECT`
  - Roles: public
  - Usando: `(auth.uid() = user_id)`



### Tabla: `wishlist`

- **Users can remove from their own wishlist**
  - Comando: `DELETE`
  - Roles: public
  - Usando: `(auth.uid() = user_id)`


- **Users can update their own wishlist**
  - Comando: `UPDATE`
  - Roles: authenticated
  - Usando: `(auth.uid() = user_id)`
  - With check: `(auth.uid() = user_id)`

- **Admins can view all wishlists**
  - Comando: `SELECT`
  - Roles: public
  - Usando: `has_role(auth.uid(), 'admin'::app_role)`


- **Users can view their own wishlist**
  - Comando: `SELECT`
  - Roles: public
  - Usando: `(auth.uid() = user_id)`


- **Users can add to their own wishlist**
  - Comando: `INSERT`
  - Roles: public
  - Usando: `true`
  - With check: `(auth.uid() = user_id)`



---

