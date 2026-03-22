# Brickshare — Valores fijos de campos de la base de datos

> Actualizado: 2026-03-22

---

## 1. `shipments.shipment_status`

| Valor | Descripción |
|---|---|
| `pending` | Pedido confirmado, pendiente de preparación |
| `preparation` | Set en preparación (inspección + embalaje) |
| `in_transit_pudo` | En tránsito hacia el punto PUDO de Correos |
| `delivered_pudo` | Disponible para recogida en el punto PUDO |
| `delivered_user` | Entregado al usuario final |
| `in_return_pudo` | Usuario ha depositado el set en el PUDO para devolución |
| `in_return` | Set en tránsito de retorno entre PUDO y oficina central |
| `returned` | Devuelto y recibido en almacén central de Brickshare |
| `cancelled` | Envío cancelado |

**Constraint SQL**: `check_shipment_status`

---

## 2. `users.user_status`

| Valor | Descripción |
|---|---|
| `no_set` | Usuario sin set activo |
| `set_shipping` | Set asignado y en proceso de envío |
| `received` | Set recibido por el usuario (legacy, equivale a `has_set`) |
| `has_set` | Usuario tiene un set en su poder |
| `set_returning` | Set en proceso de devolución |
| `suspended` | Cuenta suspendida |
| `cancelled` | Cuenta cancelada / baja |

**Constraint SQL**: `check_user_status`

---

## 3. `sets.set_status`

| Valor | Descripción |
|---|---|
| `active` | Set activo y disponible en el catálogo |
| `inactive` | Set inactivo (no visible en catálogo) |
| `in_repair` | Set en reparación (piezas faltantes) |

**Constraint SQL**: `check_set_status`  
**Default**: `inactive`

---

## 4. `donations.delivery_method`

| Valor | Descripción |
|---|---|
| `pickup-point` | Entrega en punto de recogida |
| `home-pickup` | Recogida a domicilio |

**Constraint SQL**: `donations_delivery_method_check`

---

## 5. `donations.reward`

| Valor | Descripción |
|---|---|
| `economic` | Recompensa económica (descuento) |
| `social` | Recompensa social (impacto) |

**Constraint SQL**: `donations_reward_check`

---

## 6. `user_roles.role` (tipo `app_role`)

| Valor | Descripción |
|---|---|
| `user` | Cliente suscriptor |
| `admin` | Administrador con acceso total |
| `operador` | Operador de logística |

---

## 7. `users.subscription_type`

| Valor | Descripción |
|---|---|
| `none` | Sin suscripción activa |
| `basic` | Plan Basic |
| `standard` | Plan Standard |
| `premium` | Plan Premium |

**Default**: `none`

---

## 8. `shipments.pickup_type`

| Valor | Descripción |
|---|---|
| `brickshare` | Punto PUDO gestionado por Brickshare |
| `correos` | Oficina/punto Correos estándar |

---

## 9. `wishlist.status`

| Valor | Descripción |
|---|---|
| `true` | Set activo en la wishlist |
| `false` | Set ya asignado / retirado de la wishlist |

---

## 10. `reception_operations.reception_completed`

| Valor | Descripción |
|---|---|
| `true` | Recepción y revisión completada |
| `false` | Pendiente de revisar |