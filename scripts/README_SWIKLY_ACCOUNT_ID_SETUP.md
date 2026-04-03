# 🔑 Obtener SWIKLY_ACCOUNT_ID

## Problema

Para que Swikly V2 funcione correctamente, necesitas configurar:
- `SWIKLY_ACCOUNT_ID` - UUID de tu cuenta en Swikly

Sin este valor, el código fallará con:
```
SWIKLY_ACCOUNT_ID not configured properly. Current value: "your_sandbox_account_uuid_here"
```

---

## 📋 Opciones para Obtener el ACCOUNT_ID

### Opción 1: Desde el Dashboard de Swikly (Recomendado)

1. **Ir al panel de Swikly:**
   ```
   https://dashboard.swikly.com/
   ```

2. **Buscar Settings o Configuración:**
   - Click en tu nombre/avatar (arriba a la derecha)
   - Seleccionar "Settings" / "Configuración"
   - O ir a: https://dashboard.swikly.com/settings

3. **Buscar "Account ID" o "Account UUID":**
   - Debería estar en la sección "General" o "API"
   - Formato: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
   - Ejemplo: `a1b2c3d4-e5f6-4g7h-8i9j-0k1l2m3n4o5p`

4. **Copiar el valor**

---

### Opción 2: Mediante API (si tienes acceso a terminal)

Si tienes `curl` instalado, puedes consultar la API directamente:

```bash
curl -X GET "https://api.v2.sandbox.swikly.com/v1/accounts" \
  -H "Authorization: Bearer api-37W9KF7vJMEt1f9S1VE1S7OYtNh4JqCiBl45HkfC2bcc28e3" \
  -H "Content-Type: application/json"
```

**Respuesta esperada:**
```json
{
  "id": "a1b2c3d4-e5f6-4g7h-8i9j-0k1l2m3n4o5p",
  "name": "Brickshare Sandbox",
  "type": "business",
  ...
}
```

Copia el valor de `"id"`.

---

### Opción 3: Script de Deno (si tienes Deno)

Crea un archivo `get-account-id.ts`:

```typescript
const token = "api-37W9KF7vJMEt1f9S1VE1S7OYtNh4JqCiBl45HkfC2bcc28e3";

const res = await fetch(
  "https://api.v2.sandbox.swikly.com/v1/accounts",
  {
    headers: {
      "Authorization": `Bearer ${token}`,
      "Content-Type": "application/json",
    },
  }
);

const data = await res.json();
console.log("ACCOUNT_ID:", data.id);
```

Ejecutar:
```bash
deno run -A get-account-id.ts
```

---

## ✅ Actualizar la Configuración

Una vez tengas el ACCOUNT_ID (ej: `a1b2c3d4-e5f6-4g7h-8i9j-0k1l2m3n4o5p`):

### 1. Actualizar `supabase/functions/.env`

```bash
# supabase/functions/.env

RESEND_API_KEY=re_test_local_development_key_123456
COSTE_ENVIO_DEVOLUCION=8

# Swikly V2 API — https://api.v2.sandbox.swikly.com/v1
# ⚠️ SANDBOX API KEY — Only for local development
SWIKLY_API_TOKEN_SANDBOX=api-37W9KF7vJMEt1f9S1VE1S7OYtNh4JqCiBl45HkfC2bcc28e3

# ✅ CAMBIAR ESTO:
SWIKLY_ACCOUNT_ID=a1b2c3d4-e5f6-4g7h-8i9j-0k1l2m3n4o5p

# ✅ Y ESTO (webhook secret de tu account):
SWIKLY_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxxxxxxxxxx

APP_URL=http://localhost:5173
```

### 2. Redeploy de Edge Functions

```bash
# Redeploy la función que crea depósitos
supabase functions deploy create-swikly-wish-shipment

# Redeploy el webhook
supabase functions deploy swikly-webhook
```

### 3. Verificar que se desplegó correctamente

```bash
supabase functions list
```

Debería mostrar:
- ✅ `create-swikly-wish-shipment` (deployed)
- ✅ `swikly-webhook` (deployed)

---

## 🧪 Probar que Funciona

### Test 1: Ver logs

```bash
# Terminal 1
supabase functions logs create-swikly-wish-shipment --follow
```

### Test 2: Crear asignación a user3

1. Ir a Panel Admin → Operations → Set Assignment
2. Seleccionar user3
3. Asignar un set
4. Ver que en los logs de Terminal 1 aparece:

```
[Swikly] Account ID: a1b2c3d4-e5f6-4g7h-8i9j-0k1l2m3n4o5p
[Swikly] API Token: ✓ Configured
[Swikly] Creating deposit request for shipment ship_xyz123
[Swikly] Sending request to API V2: https://api.v2.sandbox.swikly.com/v1/accounts/a1b2c3d4-e5f6-4g7h-8i9j-0k1l2m3n4o5p/requests
[Swikly] API Response (200): { "id": "req_xyz789", ... }
[Swikly] ✅ Request req_xyz789 created for shipment ship_xyz123
```

### Test 3: Verificar que user3 puede imprimir etiquetas

1. Ir a Admin → Operations → Label Generation
2. Buscar user3
3. Ver que aparece el set asignado
4. El depósito debe estar en estado "accepted"

---

## ❌ Si Sigue Sin Funcionar

### Error: DNS error

```
error sending request for url: dns error: failed to lookup address information
```

**Causa:** Sin conexión a internet en el entorno.
**Solución:** Si estás en desarrollo local offline, esta es una limitación esperada. Para testing, necesitarás internet o un mock del servicio.

### Error: 401 Unauthorized

```
Swikly API error 401: Unauthorized
```

**Causa:** Token de API inválido o expirado.
**Solución:**
1. Verificar que el token en `.env` es correcto
2. Ir a Swikly dashboard y regenerar el token si es necesario

### Error: 404 Account Not Found

```
Swikly API error 404: Account not found
```

**Causa:** ACCOUNT_ID incorrecto.
**Solución:**
1. Verificar que el ACCOUNT_ID está en formato UUID válido
2. Obtenerlo de nuevo desde el dashboard de Swikly

---

## 📞 Soporte

Si tienes problemas:

1. **Verificar que las variables están configuradas:**
   ```bash
   grep "SWIKLY" supabase/functions/.env
   ```

2. **Ver logs de la Edge Function:**
   ```bash
   supabase functions logs create-swikly-wish-shipment
   ```

3. **Consultar documentación de Swikly:**
   - https://api.v2.swikly.com/v1/docs
   - Sandbox: https://dashboard-sandbox.swikly.com/