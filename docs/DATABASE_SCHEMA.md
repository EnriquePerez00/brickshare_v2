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
| `nombre` | text | ✗ | - | - |
| `email` | text | ✗ | - | - |
| `telefono` | text | ✓ | - | - |
| `direccion` | text | ✓ | - | - |
| `peso_estimado` | numeric | ✗ | - | - |
| `metodo_entrega` | text | ✗ | - | - |
| `recompensa` | text | ✗ | - | - |
| `ninos_beneficiados` | integer | ✗ | - | - |
| `co2_evitado` | numeric | ✗ | - | - |
| `status` | text | ✗ | `'pending'::text` | - |
| `tracking_code` | text | ✓ | - | - |
| `created_at` | timestamp with time zone | ✗ | `now()` | - |
| `updated_at` | timestamp with time zone | ✗ | `now()` | - |


### envios

| Campo | Tipo | Nulo | Default | Descripción |
|-------|------|------|---------|-------------|
| `id` | uuid | ✗ | `gen_random_uuid()` | - |
| `user_id` | uuid | ✗ | - | - |
| `fecha_asignada` | timestamp with time zone | ✓ | - | - |
| `fecha_entrega` | timestamp with time zone | ✓ | - | - |
| `fecha_entrega_real` | timestamp with time zone | ✓ | - | - |
| `fecha_entrega_usuario` | timestamp with time zone | ✓ | - | - |
| `fecha_recepcion_almacen` | timestamp with time zone | ✓ | - | - |
| `fecha_devolucion_estimada` | date | ✓ | - | - |
| `estado_envio` | text | ✗ | `'pendiente'::text` | Allowed values: preparacion, ruta_envio, entregado, devuelto, ruta_devolucion, cancelado |
| `direccion_envio` | text | ✗ | - | - |
| `ciudad_envio` | text | ✗ | - | - |
| `codigo_postal_envio` | text | ✗ | - | - |
| `pais_envio` | text | ✗ | `'España'::text` | - |
| `proveedor_envio` | text | ✓ | - | - |
| `direccion_proveedor_recogida` | text | ✓ | - | - |
| `numero_seguimiento` | text | ✓ | - | - |
| `transportista` | text | ✓ | - | - |
| `notas_adicionales` | text | ✓ | - | - |
| `created_at` | timestamp with time zone | ✗ | `now()` | - |
| `updated_at` | timestamp with time zone | ✗ | `now()` | - |
| `fecha_recogida_almacen` | timestamp with time zone | ✓ | - | Date when the shipment was picked up from the warehouse |
| `fecha_solicitud_devolucion` | timestamp with time zone | ✓ | - | Date when the user requested a return |
| `proveedor_recogida` | text | ✓ | - | Carrier or entity in charge of the return pickup |
| `set_ref` | text | ✓ | - | LEGO set reference (e.g., 75192) for quick reference |
| `set_id` | uuid | ✓ | - | Direct reference to the set being shipped, eliminates need for orders table |
| `estado_manipulacion` | boolean | ✓ | `false` | - |
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


### inventory_sets

**Descripción**: Detailed tracking of set units across different states (warehouse, shipping, use, etc.)

| Campo | Tipo | Nulo | Default | Descripción |
|-------|------|------|---------|-------------|
| `id` | uuid | ✗ | `gen_random_uuid()` | - |
| `set_id` | uuid | ✗ | - | - |
| `set_ref` | text | ✓ | - | Official LEGO reference number (sets.lego_ref) |
| `inventory_set_total_qty` | integer | ✗ | `0` | - |
| `en_envio` | integer | ✗ | `0` | - |
| `en_uso` | integer | ✗ | `0` | - |
| `en_devolucion` | integer | ✗ | `0` | - |
| `en_reparacion` | integer | ✗ | `0` | - |
| `created_at` | timestamp with time zone | ✗ | `now()` | - |
| `updated_at` | timestamp with time zone | ✗ | `now()` | - |
| `spare_parts_order` | text | ✓ | - | - |


### operaciones_recepcion

**Descripción**: Table to record the reception and maintenance check of sets returned by users.

| Campo | Tipo | Nulo | Default | Descripción |
|-------|------|------|---------|-------------|
| `id` | uuid | ✗ | `gen_random_uuid()` | - |
| `event_id` | uuid | ✓ | - | - |
| `user_id` | uuid | ✗ | - | - |
| `set_id` | uuid | ✗ | - | - |
| `weight_measured` | numeric(10,2) | ✓ | - | Actual weight of the set upon reception (in grams). |
| `status_recepcion` | boolean | ✗ | `false` | True if the reception process is completed. |
| `missing_parts` | text | ✓ | - | Details or notes about missing pieces found during reception. |
| `created_at` | timestamp with time zone | ✗ | `now()` | - |
| `updated_at` | timestamp with time zone | ✗ | `now()` | - |


### profiles

| Campo | Tipo | Nulo | Default | Descripción |
|-------|------|------|---------|-------------|
| `id` | uuid | ✗ | - | - |
| `full_name` | text | ✓ | - | - |
| `avatar_url` | text | ✓ | - | - |
| `sub_status` | text | ✓ | `'free'::text` | - |
| `impact_points` | integer | ✓ | `0` | - |
| `referral_code` | text | ✓ | - | Unique shareable code (6 chars, auto-generated) |
| `referred_by` | uuid | ✓ | - | auth.users.id of the user who referred this one |
| `referral_credits` | integer | ✗ | `0` | Accumulated credits from successful referrals |
| `created_at` | timestamp with time zone | ✗ | `now()` | - |
| `updated_at` | timestamp with time zone | ✗ | `now()` | - |


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
| `set_status` | text | ✓ | `'inactivo'::text` | - |
| `set_price` | numeric | ✓ | `100.00` | - |
| `current_value_new` | numeric | ✓ | - | - |
| `current_value_used` | numeric | ✓ | - | - |
| `set_pvp_release` | numeric | ✓ | - | - |
| `set_subtheme` | text | ✓ | - | - |
| `barcode_upc` | text | ✓ | - | - |
| `barcode_ean` | text | ✓ | - | - |


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
| `address` | text | ✓ | - | - |
| `address_extra` | text | ✓ | - | - |
| `zip_code` | text | ✓ | - | - |
| `city` | text | ✓ | - | - |
| `province` | text | ✓ | - | - |
| `phone` | text | ✓ | - | - |
| `email` | text | ✓ | - | - |
| `subscription_type` | text | ✓ | - | - |
| `subscription_status` | text | ✓ | `'active'::text` | - |
| `direccion` | text | ✓ | - | - |
| `codigo_postal` | text | ✓ | - | - |
| `ciudad` | text | ✓ | - | - |
| `telefono` | text | ✓ | - | - |
| `profile_completed` | boolean | ✓ | `false` | - |
| `user_status` | text | ✓ | `'sin set'::text` | - |
| `stripe_customer_id` | text | ✓ | - | - |


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
| `address` | text | ✓ | - | - |
| `address_extra` | text | ✓ | - | - |
| `zip_code` | text | ✓ | - | - |
| `city` | text | ✓ | - | - |
| `province` | text | ✓ | - | - |
| `phone` | text | ✓ | - | - |
| `email` | text | ✓ | - | - |
| `subscription_type` | text | ✓ | - | The plan level (Brick Starter, Pro, Master) |
| `subscription_status` | text | ✓ | `'active'::text` | Status of the subscription (OK, trialing, past_due, canceled, etc.) |
| `direccion` | text | ✓ | - | - |
| `codigo_postal` | text | ✓ | - | - |
| `ciudad` | text | ✓ | - | - |
| `telefono` | text | ✓ | - | - |
| `profile_completed` | boolean | ✓ | `false` | - |
| `user_status` | text | ✓ | `'sin set'::text` | Allowed values: set en envio, sin set, recibido, set en devolucion, suspendido, cancelado |
| `stripe_customer_id` | text | ✓ | - | Stripe Customer ID associated with the user |


### users_correos_dropping

**Descripción**: Stores user-selected Correos PUDO (Pick Up Drop Off) points for delivery and pickup

| Campo | Tipo | Nulo | Default | Descripción |
|-------|------|------|---------|-------------|
| `user_id` | uuid | ✗ | - | - |
| `correos_id_pudo` | text | ✗ | - | - |
| `correos_nombre` | text | ✗ | - | - |
| `correos_tipo_punto` | text | ✗ | - | - |
| `correos_direccion_calle` | text | ✗ | - | - |
| `correos_direccion_numero` | text | ✓ | - | - |
| `correos_codigo_postal` | text | ✗ | - | - |
| `correos_ciudad` | text | ✗ | - | - |
| `correos_provincia` | text | ✗ | - | - |
| `correos_pais` | text | ✗ | `'España'::text` | - |
| `correos_direccion_completa` | text | ✗ | - | - |
| `correos_latitud` | numeric(10,8) | ✗ | - | - |
| `correos_longitud` | numeric(11,8) | ✗ | - | - |
| `correos_horario_apertura` | text | ✓ | - | - |
| `correos_horario_estructurado` | jsonb | ✓ | - | - |
| `correos_disponible` | boolean | ✗ | `true` | - |
| `correos_telefono` | text | ✓ | - | - |
| `correos_email` | text | ✓ | - | - |
| `correos_codigo_interno` | text | ✓ | - | - |
| `correos_capacidad_lockers` | integer | ✓ | - | - |
| `correos_servicios_adicionales` | ARRAY | ✓ | - | - |
| `correos_accesibilidad` | boolean | ✓ | `false` | - |
| `correos_parking` | boolean | ✓ | `false` | - |
| `created_at` | timestamp with time zone | ✗ | `now()` | - |
| `updated_at` | timestamp with time zone | ✗ | `now()` | - |
| `correos_fecha_seleccion` | timestamp with time zone | ✗ | `now()` | - |


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

### `assign_sets_to_users`

**Descripción**: Assigns available sets to users based on wishlist and returns full envio details for immediate display

**Parámetros**: Ninguno
**Retorna**: `TABLE(envio_id uuid, user_id uuid, set_id uuid, order_id uuid, user_name text, set_name text, set_ref text, created_at timestamp with time zone)`


### `confirm_assign_sets_to_users`

**Parámetros**: `p_user_ids uuid[]`
**Retorna**: `TABLE(envio_id uuid, user_id uuid, set_id uuid, order_id uuid, user_name text, user_email text, user_phone text, set_name text, set_ref text, set_weight numeric, set_dim text, pudo_id text, pudo_name text, pudo_address text, pudo_cp text, pudo_city text, pudo_province text, created_at timestamp with time zone)`


### `confirm_qr_validation`

**Descripción**: Confirms a QR validation and updates shipment status

**Parámetros**: `p_qr_code text, p_validated_by text DEFAULT NULL::text`
**Retorna**: `TABLE(success boolean, message text, shipment_id uuid)`


### `delete_assignment_and_rollback`

**Descripción**: Deletes an assignment (envio) and rolls back all changes including inventory and wishlist restoration

**Parámetros**: `p_envio_id uuid`
**Retorna**: `void`


### `generate_delivery_qr`

**Parámetros**: `p_shipment_id uuid`
**Retorna**: `TABLE(qr_code text, expires_at timestamp with time zone)`


### `generate_qr_code`

**Parámetros**: Ninguno
**Retorna**: `text`


### `generate_referral_code`

**Parámetros**: Ninguno
**Retorna**: `trigger`


### `generate_return_qr`

**Parámetros**: `p_shipment_id uuid`
**Retorna**: `TABLE(qr_code text, expires_at timestamp with time zone)`


### `handle_cierre_recepcion`

**Parámetros**: Ninguno
**Retorna**: `trigger`


### `handle_envio_entregado`

**Parámetros**: Ninguno
**Retorna**: `trigger`


### `handle_envio_recibido_almacen`

**Parámetros**: Ninguno
**Retorna**: `trigger`


### `handle_envio_ruta_devolucion_inventory`

**Parámetros**: Ninguno
**Retorna**: `trigger`


### `handle_new_set_inventory`

**Parámetros**: Ninguno
**Retorna**: `trigger`


### `handle_new_user`

**Parámetros**: Ninguno
**Retorna**: `trigger`


### `handle_return_status_update`

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

**Descripción**: Retorna true si el shipment usa el sistema de PUDO de Brickshare_logistics

**Parámetros**: `shipment_id uuid`
**Retorna**: `boolean`


### `validate_qr_code`

**Descripción**: Validates a QR code and returns shipment info without personal data

**Parámetros**: `p_qr_code text`
**Retorna**: `TABLE(shipment_id uuid, validation_type text, is_valid boolean, error_message text, shipment_info jsonb)`



---

## 🔔 Triggers

### donations

- **update_donations_updated_at**
  - Evento: UPDATE
  - Timing: BEFORE
  - Función: `EXECUTE FUNCTION update_updated_at_column()`


### envios

- **update_envios_updated_at**
  - Evento: UPDATE
  - Timing: BEFORE
  - Función: `EXECUTE FUNCTION update_updated_at_column()`

- **on_envio_return_update**
  - Evento: UPDATE
  - Timing: AFTER
  - Función: `EXECUTE FUNCTION handle_return_status_update()`

- **on_envio_entregado**
  - Evento: UPDATE
  - Timing: AFTER
  - Función: `EXECUTE FUNCTION handle_envio_entregado()`

- **on_envio_recibido_almacen**
  - Evento: UPDATE
  - Timing: BEFORE
  - Función: `EXECUTE FUNCTION handle_envio_recibido_almacen()`

- **on_envio_ruta_devolucion_inv**
  - Evento: UPDATE
  - Timing: AFTER
  - Función: `EXECUTE FUNCTION handle_envio_ruta_devolucion_inventory()`


### inventory_sets

- **update_inventario_sets_updated_at**
  - Evento: UPDATE
  - Timing: BEFORE
  - Función: `EXECUTE FUNCTION update_updated_at_column()`


### operaciones_recepcion

- **update_operaciones_recepcion_updated_at**
  - Evento: UPDATE
  - Timing: BEFORE
  - Función: `EXECUTE FUNCTION update_updated_at_column()`

- **on_recepcion_completada**
  - Evento: UPDATE
  - Timing: AFTER
  - Función: `EXECUTE FUNCTION handle_cierre_recepcion()`


### profiles

- **profiles_generate_referral_code**
  - Evento: INSERT
  - Timing: BEFORE
  - Función: `EXECUTE FUNCTION generate_referral_code()`

- **profiles_updated_at**
  - Evento: UPDATE
  - Timing: BEFORE
  - Función: `EXECUTE FUNCTION set_updated_at()`


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

- **Users can view their own donations**
  - Comando: `SELECT`
  - Roles: public
  - Usando: `((auth.uid() = user_id) OR (email = (( SELECT users.email
   FROM auth.users
  WHERE (users.id = auth.uid())))::text))`


- **Admins can manage all donations**
  - Comando: `ALL`
  - Roles: public
  - Usando: `has_role(auth.uid(), 'admin'::app_role)`


- **Authenticated users can insert their own donations**
  - Comando: `INSERT`
  - Roles: public
  - Usando: `true`
  - With check: `((auth.uid() IS NOT NULL) AND ((user_id IS NULL) OR (auth.uid() = user_id)))`


### Tabla: `envios`

- **Users can view own envios**
  - Comando: `SELECT`
  - Roles: public
  - Usando: `(auth.uid() = user_id)`


- **Admins and Operadores can view all shipments**
  - Comando: `SELECT`
  - Roles: public
  - Usando: `(has_role(auth.uid(), 'admin'::app_role) OR has_role(auth.uid(), 'operador'::app_role))`


- **Users can view own shipments**
  - Comando: `SELECT`
  - Roles: public
  - Usando: `(auth.uid() = user_id)`


- **Admins can manage all shipments**
  - Comando: `ALL`
  - Roles: public
  - Usando: `has_role(auth.uid(), 'admin'::app_role)`


- **Operadores can create shipments**
  - Comando: `INSERT`
  - Roles: public
  - Usando: `true`
  - With check: `(has_role(auth.uid(), 'admin'::app_role) OR has_role(auth.uid(), 'operador'::app_role))`

- **Operadores can update shipments**
  - Comando: `UPDATE`
  - Roles: public
  - Usando: `(has_role(auth.uid(), 'admin'::app_role) OR has_role(auth.uid(), 'operador'::app_role))`


- **Users can update their own envios status**
  - Comando: `UPDATE`
  - Roles: authenticated
  - Usando: `(auth.uid() = user_id)`
  - With check: `((auth.uid() = user_id) AND (estado_envio = 'ruta_devolucion'::text))`

- **Access for operators and admins**
  - Comando: `ALL`
  - Roles: public
  - Usando: `(EXISTS ( SELECT 1
   FROM user_roles
  WHERE ((user_roles.user_id = auth.uid()) AND ((user_roles.role)::text = ANY (ARRAY['admin'::text, 'operador'::text])))))`



### Tabla: `inventory_sets`

- **Admins and Operadores can manage inventario**
  - Comando: `ALL`
  - Roles: authenticated
  - Usando: `(has_role(auth.uid(), 'admin'::app_role) OR has_role(auth.uid(), 'operador'::app_role))`


- **Inventario is viewable by everyone**
  - Comando: `SELECT`
  - Roles: public
  - Usando: `true`



### Tabla: `operaciones_recepcion`

- **Enable update for admins and operators**
  - Comando: `UPDATE`
  - Roles: authenticated
  - Usando: `(has_role(auth.uid(), 'admin'::app_role) OR has_role(auth.uid(), 'operador'::app_role))`
  - With check: `(has_role(auth.uid(), 'admin'::app_role) OR has_role(auth.uid(), 'operador'::app_role))`

- **Enable insert for admins and operators**
  - Comando: `INSERT`
  - Roles: authenticated
  - Usando: `true`
  - With check: `(has_role(auth.uid(), 'admin'::app_role) OR has_role(auth.uid(), 'operador'::app_role))`

- **Enable read access for authenticated users**
  - Comando: `SELECT`
  - Roles: authenticated
  - Usando: `true`



### Tabla: `profiles`

- **profiles_select_own**
  - Comando: `SELECT`
  - Roles: authenticated
  - Usando: `(id = auth.uid())`


- **profiles_update_own**
  - Comando: `UPDATE`
  - Roles: authenticated
  - Usando: `(id = auth.uid())`


- **profiles_insert_own**
  - Comando: `INSERT`
  - Roles: authenticated
  - Usando: `true`
  - With check: `(id = auth.uid())`


### Tabla: `qr_validation_logs`

- **Users can view their own validation logs**
  - Comando: `SELECT`
  - Roles: authenticated
  - Usando: `(shipment_id IN ( SELECT s.id
   FROM envios s
  WHERE (s.user_id = auth.uid())))`



### Tabla: `referrals`

- **referrals_select_own**
  - Comando: `SELECT`
  - Roles: authenticated
  - Usando: `(referrer_id = auth.uid())`


- **referrals_select_referee**
  - Comando: `SELECT`
  - Roles: authenticated
  - Usando: `(referee_id = auth.uid())`


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


- **reviews_insert_own**
  - Comando: `INSERT`
  - Roles: authenticated
  - Usando: `true`
  - With check: `(auth.uid() = user_id)`

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


- **reviews_select_own**
  - Comando: `SELECT`
  - Roles: authenticated
  - Usando: `(auth.uid() = user_id)`


- **reviews_update_own**
  - Comando: `UPDATE`
  - Roles: authenticated
  - Usando: `(auth.uid() = user_id)`
  - With check: `(auth.uid() = user_id)`


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

- **Admins can insert sets**
  - Comando: `INSERT`
  - Roles: public
  - Usando: `true`
  - With check: `has_role(auth.uid(), 'admin'::app_role)`

- **Sets are viewable by everyone**
  - Comando: `SELECT`
  - Roles: public
  - Usando: `true`


- **Admins can update sets**
  - Comando: `UPDATE`
  - Roles: public
  - Usando: `has_role(auth.uid(), 'admin'::app_role)`


- **Admins can delete sets**
  - Comando: `DELETE`
  - Roles: public
  - Usando: `has_role(auth.uid(), 'admin'::app_role)`



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

- **Admins can update any user**
  - Comando: `UPDATE`
  - Roles: public
  - Usando: `has_role(auth.uid(), 'admin'::app_role)`


- **Users can delete their own profile**
  - Comando: `DELETE`
  - Roles: authenticated
  - Usando: `(auth.uid() = user_id)`


- **Users can view their own profile**
  - Comando: `SELECT`
  - Roles: authenticated
  - Usando: `(auth.uid() = user_id)`


- **Admins can view all profiles**
  - Comando: `SELECT`
  - Roles: authenticated
  - Usando: `has_role(auth.uid(), 'admin'::app_role)`


- **Users can update their own profile**
  - Comando: `UPDATE`
  - Roles: authenticated
  - Usando: `(auth.uid() = user_id)`


- **Users can insert their own profile**
  - Comando: `INSERT`
  - Roles: authenticated
  - Usando: `true`
  - With check: `(auth.uid() = user_id)`

- **Admins and Operadores can view all users**
  - Comando: `SELECT`
  - Roles: public
  - Usando: `(has_role(auth.uid(), 'admin'::app_role) OR has_role(auth.uid(), 'operador'::app_role))`


- **Users can view own profile**
  - Comando: `SELECT`
  - Roles: public
  - Usando: `(auth.uid() = user_id)`


- **Users can update own profile**
  - Comando: `UPDATE`
  - Roles: public
  - Usando: `(auth.uid() = user_id)`



### Tabla: `users_correos_dropping`

- **Users can delete their own Correos PUDO selection**
  - Comando: `DELETE`
  - Roles: public
  - Usando: `(auth.uid() = user_id)`


- **Users can view their own Correos PUDO selection**
  - Comando: `SELECT`
  - Roles: public
  - Usando: `(auth.uid() = user_id)`


- **Users can insert their own Correos PUDO selection**
  - Comando: `INSERT`
  - Roles: public
  - Usando: `true`
  - With check: `(auth.uid() = user_id)`

- **Users can update their own Correos PUDO selection**
  - Comando: `UPDATE`
  - Roles: public
  - Usando: `(auth.uid() = user_id)`
  - With check: `(auth.uid() = user_id)`


### Tabla: `wishlist`

- **Users can add to their own wishlist**
  - Comando: `INSERT`
  - Roles: public
  - Usando: `true`
  - With check: `(auth.uid() = user_id)`

- **Users can view their own wishlist**
  - Comando: `SELECT`
  - Roles: public
  - Usando: `(auth.uid() = user_id)`


- **Admins can view all wishlists**
  - Comando: `SELECT`
  - Roles: public
  - Usando: `has_role(auth.uid(), 'admin'::app_role)`


- **Users can update their own wishlist**
  - Comando: `UPDATE`
  - Roles: authenticated
  - Usando: `(auth.uid() = user_id)`
  - With check: `(auth.uid() = user_id)`

- **Users can remove from their own wishlist**
  - Comando: `DELETE`
  - Roles: public
  - Usando: `(auth.uid() = user_id)`




---

