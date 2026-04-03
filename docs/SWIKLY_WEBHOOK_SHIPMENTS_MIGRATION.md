# Swikly Webhook → Shipments Migration

**Fecha:** 2026-03-28
**Autor:** Cline

## Resumen

Se migró el `swikly-webhook` Edge Function para trabajar con la tabla `shipments` en lugar de la tabla `assignments` (que ya no existe en el esquema actual).

## Problema

El `swikly-webhook/index.ts` original estaba diseñado para buscar y actualizar registros en la tabla `assignments`:

```typescript
// ❌ ANTES — tabla inexistente
const { data: assignment } = await supabase
  .from("assignments")
  .select("id, user_id, swikly_status, ...")
  .eq("swikly_wish_id", wishId)
  .single();
```

Sin embargo, el esquema actual de Brickshare gestiona los envíos/asignaciones directamente en la tabla `shipments`, que ya incluye los campos Swikly (añadidos en la migración `20260328110000_add_swikly_to_shipments.sql`).

## Cambios Realizados

### 1. `supabase/functions/swikly-webhook/index.ts`

- **Tabla**: `assignments` → `shipments`
- **Columnas consultadas**: `id, user_id, set_ref, swikly_status, swikly_deposit_amount`
- **Lookup de usuario**: Ahora consulta `users` table + `auth.admin.getUserById()` como fallback
- **Lookup de set**: Consulta `sets` table usando `set_ref` del shipment (en lugar de join implícito)
- **Emails**: Se mantienen los 3 tipos de notificación:
  - `swikly_deposit_confirmed` (status: accepted)
  - `swikly_deposit_released` (status: released)  
  - `swikly_deposit_captured` (status: captured)

### 2. `supabase/config.toml`

Se añadieron las configuraciones JWT para las Edge Functions de Swikly:

```toml
[functions.create-swikly-wish-shipment]
verify_jwt = true

[functions.swikly-webhook]
verify_jwt = false  # Los webhooks externos no tienen JWT

[functions.swikly-manage-wish]
verify_jwt = true

[functions.process-assignment-payment]
verify_jwt = true
```

### 3. Variables de Entorno

Ya estaban configuradas en `supabase/functions/.env`:

| Variable | Valor (test) | Usado por |
|---|---|---|
| `SWIKLY_ACCOUNT_ID` | `test_account_id` | `create-swikly-wish-shipment` |
| `SWIKLY_SECRET_KEY` | `test_secret_key` | `create-swikly-wish-shipment`, `swikly-webhook` |
| `APP_URL` | `http://localhost:5173` | `create-swikly-wish-shipment` |
| `COSTE_ENVIO_DEVOLUCION` | `8` | `process-assignment-payment` |

## Flujo Completo de Swikly

```
1. Admin asigna set → confirm_assign_sets_to_users()
2. Se crea shipment con set_ref
3. Frontend/Backend llama create-swikly-wish-shipment con shipment_id
4. Edge Function:
   a. Lee set_pvp_release del set como monto del depósito
   b. Crea "wish" en API Swikly
   c. Guarda swikly_wish_id, swikly_wish_url, swikly_status en shipment
   d. Envía email al usuario con link para completar depósito
5. Usuario completa depósito en Swikly
6. Swikly envía callback → swikly-webhook
7. Webhook:
   a. Verifica firma HMAC
   b. Busca shipment por swikly_wish_id
   c. Actualiza swikly_status (accepted/released/captured/cancelled)
   d. Envía email de confirmación al usuario
```

## Campos Swikly en `shipments`

| Campo | Tipo | Descripción |
|---|---|---|
| `swikly_wish_id` | TEXT | ID del wish en Swikly |
| `swikly_wish_url` | TEXT | URL para que el usuario complete la garantía |
| `swikly_status` | TEXT | Estado: pending, wish_created, accepted, cancelled, expired, released, captured |
| `swikly_deposit_amount` | INTEGER | Monto en céntimos, basado en `sets.set_pvp_release` |

## Testing

Para probar el webhook localmente:

```bash
# Simular callback de Swikly (accepted)
curl -X POST http://127.0.0.1:54331/functions/v1/swikly-webhook \
  -H "Content-Type: application/json" \
  -d '{"wish_id": "WISH_ID_HERE", "status": "accepted"}'
```

> **Nota:** En desarrollo local, la verificación de firma se salta si no hay header `X-Api-Sig`.