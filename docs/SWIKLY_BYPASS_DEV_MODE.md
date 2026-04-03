# 🔧 Swikly Bypass Mode (Desarrollo)

## Descripción

Para desarrollo local, se ha implementado un **bypass de Swikly** que:

- ✅ Omite llamadas reales a la API de Swikly
- ✅ Genera depósitos MOCK con IDs ficticios
- ✅ Permite completar el flujo completo de asignación sin Swikly
- ✅ Se activa automáticamente en `localhost` con `SWIKLY_BYPASS_DEV=true`
- ✅ Se desactiva en producción configurando `SWIKLY_BYPASS_DEV=false`

## Cómo funciona

### 1. Edge Function (`create-swikly-wish-shipment/index.ts`)

Cuando `SWIKLY_BYPASS_DEV=true`:

```typescript
if (SWIKLY_BYPASS_DEV) {
  // Genera un ID mock: "mock-a1b2c3d4e5f6g7h8"
  wishId = `mock-${crypto.getRandomValues(new Uint8Array(8)).reduce(...)}`;
  wishUrl = `${APP_URL}/dashboard?deposit=mock&wish=${wishId}`;
  
  console.log(`[Swikly] 🔧 BYPASS MODE: Creating mock deposit for development`);
}
```

### 2. Frontend (`SetAssignment.tsx`)

El componente detecta depósitos mock:

```typescript
const isMockDeposit = data?.wish_id?.startsWith?.('mock-');
if (isMockDeposit) {
  toast.info(`🔧 Fianza MOCK creada en modo desarrollo (${data.wish_id})`);
}
```

Muestra un indicador visual `🔧` para que sea evidente que estamos en modo bypass.

### 3. Base de Datos

Los depósitos mock se guardan normalmente en `shipments.swikly_wish_id`:

```
swikly_wish_id: "mock-a1b2c3d4e5f6"
swikly_status: "wish_created"
swikly_deposit_amount: 5500 (55.00 EUR)
```

## Variables de Entorno

### `supabase/functions/.env`

```bash
# 🔧 Development bypass flag - skips real Swikly API calls in local environment
SWIKLY_BYPASS_DEV=true
```

**En producción, cambiar a `false`:**

```bash
SWIKLY_BYPASS_DEV=false
```

## Flujo de Desarrollo Completo

```
1. Admin → "Genera propuesta de asignación"
   ↓
2. Preview muestra usuarios con sets propuestos
   ↓
3. Admin → "Confirmar asignaciones"
   ↓
4. setConfirmedMutation → confirm_assign_sets_to_users()
   ↓ (Crea shipments en BD)
   ↓
5. createSwiklyDepositMutation → create-swikly-wish-shipment
   ↓
6. Edge Function detecta SWIKLY_BYPASS_DEV=true
   ↓
7. Genera depósito MOCK (sin llamar a API real)
   ↓
8. Guarda en shipments: swikly_wish_id="mock-xxx"
   ↓
9. Toast: "🔧 Fianza MOCK creada en modo desarrollo"
   ↓
10. Flujo continúa normalmente (etiquetas, etc)
```

## Logs Esperados

En la consola de Edge Functions (`supabase functions serve`):

```
[Swikly] Using sandbox environment: https://api.v2.sandbox.swikly.com/v1
[Swikly] 🔧 BYPASS MODE ENABLED - Using mock deposits for development
[Swikly] Creating deposit request for shipment 321801df-1804-4abe-89a3-b3663ae72250
[Swikly] 🔧 BYPASS MODE: Creating mock deposit for development
[Swikly] Mock Request created: mock-a1b2c3d4e5f6g7h8
[Swikly] Mock URL: http://localhost:5173/dashboard?deposit=mock&wish=mock-a1b2c3d4e5f6g7h8
[Swikly] Updating shipment 321801df-1804-4abe-89a3-b3663ae72250 with request ID: mock-a1b2c3d4e5f6g7h8
[Swikly] ✅ Request mock-a1b2c3d4e5f6g7h8 created for shipment 321801df-1804-4abe-89a3-b3663ae72250
```

## Testing

### 1. Verificar archivo `.env`

```bash
cat supabase/functions/.env | grep SWIKLY_BYPASS_DEV
```

Debe mostrar: `SWIKLY_BYPASS_DEV=true`

### 2. Reiniciar Supabase

```bash
supabase stop && sleep 2 && supabase start
```

### 3. Ejecutar asignación

1. Ir al Admin → Operations → Set Assignment
2. Click "Genera propuesta de asignación"
3. Click "Confirmar asignaciones (todas)"
4. Observar los toasts:
   - ✅ "¡Éxito! Se crearon X asignaciones. Procesando fianzas en Swikly..."
   - 🔧 "Fianza MOCK creada en modo desarrollo (mock-xxx)"

### 4. Verificar BD

```sql
SELECT shipment_id, swikly_wish_id, swikly_status, swikly_deposit_amount 
FROM shipments 
ORDER BY created_at DESC 
LIMIT 5;
```

Debe mostrar valores como:
```
swikly_wish_id: "mock-a1b2c3d4e5f6"
swikly_status: "wish_created"
swikly_deposit_amount: 5500
```

## Desactivar Bypass (Producción)

Cuando estés listo para usar Swikly real:

1. Editar `supabase/functions/.env`
   ```bash
   SWIKLY_BYPASS_DEV=false
   ```

2. Asegurarse de que `SWIKLY_ACCOUNT_ID` es correcto:
   ```
   SWIKLY_ACCOUNT_ID=d42ede22-7633-471d-b9a2-340949474bd4
   ```

3. Reiniciar Supabase
   ```bash
   supabase stop && supabase start
   ```

4. Probar nuevamente — ahora hará llamadas reales a Swikly

## Troubleshooting

### "SWIKLY_BYPASS_DEV not recognized"

Reinicia Supabase:
```bash
supabase stop && sleep 2 && supabase start
```

### Logs no muestran "BYPASS MODE ENABLED"

Verifica que el archivo `.env` tiene la variable:
```bash
supabase functions serve
# Busca en los logs: [Swikly] 🔧 BYPASS MODE ENABLED
```

### Depósitos reales no se crean

Asegúrate de que `SWIKLY_BYPASS_DEV=false` está en `.env`:
```bash
grep SWIKLY_BYPASS_DEV supabase/functions/.env
```

Debe retornar: `SWIKLY_BYPASS_DEV=false`

---

**Estado actual**: ✅ Bypass ACTIVADO para desarrollo
**Account ID**: d42ede22-7633-471d-b9a2-340949474bd4
**Última actualización**: 31/3/2026