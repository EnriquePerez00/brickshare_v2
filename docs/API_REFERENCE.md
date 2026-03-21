# Brickshare — Referencia de Edge Functions (API)

> Todas las Edge Functions se invocan via Supabase Functions.  
> Base URL: `https://<project-ref>.supabase.co/functions/v1/`  
> Autenticación: `Authorization: Bearer <JWT>` (excepto donde se indica)

---

## `create-checkout-session`

Crea una sesión de Checkout de Stripe para iniciar una suscripción.

**Método:** `POST`  
**Auth:** Requerida (usuario autenticado)

### Request Body
```json
{
  "priceId": "price_1234567890",
  "successUrl": "https://brickshare.es/dashboard?success=true",
  "cancelUrl": "https://brickshare.es/dashboard?canceled=true"
}
```

### Response `200`
```json
{
  "sessionId": "cs_test_...",
  "url": "https://checkout.stripe.com/pay/cs_test_..."
}
```

### Response `400`
```json
{ "error": "Missing required field: priceId" }
```

---

## `create-subscription-intent`

Crea un PaymentIntent de Stripe para suscripción manual (sin redirect).

**Método:** `POST`  
**Auth:** Requerida

### Request Body
```json
{
  "priceId": "price_1234567890",
  "customerId": "cus_optional_existing_customer"
}
```

### Response `200`
```json
{
  "clientSecret": "pi_..._secret_...",
  "customerId": "cus_..."
}
```

---

## `change-subscription`

Cambia el plan de suscripción o cancela la suscripción activa.

**Método:** `POST`  
**Auth:** Requerida

### Request Body
```json
{
  "action": "upgrade" | "downgrade" | "cancel",
  "newPriceId": "price_..."
}
```

### Response `200`
```json
{
  "success": true,
  "subscription": {
    "id": "sub_...",
    "status": "active",
    "plan": "premium",
    "current_period_end": "2026-04-19T00:00:00Z"
  }
}
```

---

## `stripe-webhook`

Receptor de eventos webhook de Stripe. **No requiere auth de usuario** — usa `Stripe-Signature` header.

**Método:** `POST`  
**Auth:** Stripe-Signature header (HMAC-SHA256)

### Eventos manejados
| Evento Stripe | Acción |
|---|---|
| `payment_intent.succeeded` | Actualiza `profiles.subscription_plan` |
| `customer.subscription.updated` | Sincroniza estado en `subscriptions` |
| `customer.subscription.deleted` | Cancela suscripción en BD |
| `invoice.payment_failed` | Marca suscripción como `past_due` |

### Response `200`
```json
{ "received": true }
```

---

## `process-assignment-payment`

Procesa el pago de asignación de un set específico a un pedido.

**Método:** `POST`  
**Auth:** Requerida (admin)

### Request Body
```json
{
  "orderId": "uuid",
  "inventarioSetId": "uuid",
  "amount": 1500
}
```

### Response `200`
```json
{
  "success": true,
  "paymentIntentId": "pi_..."
}
```

---

## `correos-logistics`

Crea un envío a través de la API de Correos de España.

**Método:** `POST`  
**Auth:** Requerida (admin u operador)

### Request Body
```json
{
  "orderId": "uuid",
  "recipientName": "Juan García",
  "recipientAddress": "Calle Mayor 1",
  "recipientCity": "Madrid",
  "recipientPostalCode": "28001",
  "recipientPhone": "+34600000000",
  "pudoPointId": "ES123456",
  "weight": 500,
  "dimensions": {
    "length": 30,
    "width": 20,
    "height": 15
  }
}
```

### Response `200`
```json
{
  "success": true,
  "shipmentId": "CORREOS_ID",
  "trackingCode": "ES123456789ES",
  "labelUrl": "https://...",
  "qrCodeUrl": "https://..."
}
```

---

## `correos-pudo`

Consulta puntos PUDO (Pick Up / Drop Off) de Correos cercanos.

**Método:** `POST`  
**Auth:** Opcional

### Request Body
```json
{
  "postalCode": "28001",
  "city": "Madrid",
  "maxResults": 10
}
```

### Response `200`
```json
{
  "pudoPoints": [
    {
      "id": "ES123456",
      "name": "Oficina Central Madrid",
      "address": "Calle Mayor 1",
      "city": "Madrid",
      "postalCode": "28001",
      "coordinates": {
        "lat": 40.4168,
        "lng": -3.7038
      },
      "openingHours": "L-V 9:00-14:00",
      "distance": 250
    }
  ]
}
```

---

## `send-email`

Envía un email transaccional via Resend.

**Método:** `POST`  
**Auth:** Requerida (service role o admin)

### Request Body
```json
{
  "to": "usuario@email.com",
  "subject": "Asunto del email",
  "template": "welcome" | "order_confirmed" | "shipped" | "delivered" | "return_requested",
  "data": {
    "userName": "Juan",
    "orderNumber": "ORD-001",
    "trackingCode": "ES123456789ES",
    "setName": "LEGO Star Wars Millennium Falcon"
  }
}
```

### Response `200`
```json
{
  "success": true,
  "messageId": "re_..."
}
```

---

## `submit-donation`

Registra una donación (de set o monetaria).

**Método:** `POST`  
**Auth:** Opcional (donaciones anónimas permitidas)

### Request Body
```json
{
  "donorName": "María López",
  "donorEmail": "maria@email.com",
  "type": "set" | "monetary",
  "amount": 2000,
  "setDescription": "LEGO City Set 60200, completo con instrucciones",
  "message": "Espero que sea útil para otros niños"
}
```

### Response `200`
```json
{
  "success": true,
  "donationId": "uuid",
  "message": "Donación registrada correctamente. Te enviaremos un email de confirmación."
}
```

---

## `fetch-lego-data`

Enriquece los datos de un set LEGO desde APIs externas (Rebrickable, BrickSet).

**Método:** `POST`  
**Auth:** Requerida (admin)

### Request Body
```json
{
  "legoRef": "75192",
  "setId": "uuid"
}
```

### Response `200`
```json
{
  "success": true,
  "enrichedData": {
    "name": "Millennium Falcon",
    "theme": "Star Wars",
    "pieceCount": 7541,
    "ageRange": "18+",
    "year": 2017,
    "imgUrl": "https://...",
    "description": "...",
    "retailPrice": 849.99
  }
}
```

---

## `add-lego-set`

Añade un nuevo set al catálogo (con enriquecimiento automático).

**Método:** `POST`  
**Auth:** Requerida (admin)

### Request Body
```json
{
  "legoRef": "75192",
  "rentalPrice": 15.99,
  "availableUnits": 3
}
```

### Response `200`
```json
{
  "success": true,
  "setId": "uuid",
  "inventarioIds": ["uuid1", "uuid2", "uuid3"]
}
```

---

## `delete-user`

Elimina una cuenta de usuario y todos sus datos asociados (GDPR).

**Método:** `POST`  
**Auth:** Requerida (usuario propio o admin)

### Request Body
```json
{
  "userId": "uuid",
  "confirmation": "DELETE_MY_ACCOUNT"
}
```

### Response `200`
```json
{
  "success": true,
  "message": "Cuenta eliminada correctamente"
}
```

### Response `400`
```json
{
  "error": "No se puede eliminar una cuenta con suscripción activa"
}
```

---

## Códigos de Error Comunes

| Código | Descripción |
|---|---|
| `400` | Request mal formado o datos inválidos |
| `401` | Token JWT inválido o expirado |
| `403` | Sin permisos para esta operación |
| `404` | Recurso no encontrado |
| `409` | Conflicto (ej: ya existe una suscripción activa) |
| `500` | Error interno del servidor |

---

## Supabase — Tablas Accesibles desde el Cliente

Las siguientes tablas son accesibles directamente desde el cliente via Supabase JS SDK (sujeto a políticas RLS):

| Tabla | Operaciones del cliente | Descripción |
|---|---|---|
| `sets` | SELECT | Catálogo público |
| `profiles` | SELECT, UPDATE (propio) | Perfil de usuario |
| `orders` | SELECT (propio), INSERT | Pedidos |
| `wishlist` | SELECT, INSERT, DELETE (propio) | Lista de deseos |
| `subscriptions` | SELECT (propio) | Estado de suscripción |
| `envios` | SELECT (propio) | Estado de envíos |
| `donations` | INSERT | Crear donaciones |
| `inventario_sets` | SELECT (admin/operador) | Inventario físico |

---

## Ejemplo de Uso desde el Frontend

```typescript
// Invocar Edge Function desde React
import { supabase } from '@/integrations/supabase/client';

const { data, error } = await supabase.functions.invoke('correos-pudo', {
  body: {
    postalCode: '28001',
    city: 'Madrid',
    maxResults: 5,
  },
});

if (error) {
  console.error('Error:', error);
  return;
}

console.log('PUDO Points:', data.pudoPoints);
```

```typescript
// Consultar tabla con RLS
const { data: orders, error } = await supabase
  .from('orders')
  .select(`
    *,
    sets (name, img_url),
    envios (tracking_code, status)
  `)
  .eq('user_id', user.id)
  .order('created_at', { ascending: false });