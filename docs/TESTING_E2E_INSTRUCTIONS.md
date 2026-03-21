# Instrucciones para Ejecutar el Test End-to-End

## Prerequisitos

### 1. Obtener el Service Role Key de Supabase

El test requiere el `SUPABASE_SERVICE_ROLE_KEY` para poder crear y modificar datos en la base de datos.

**Pasos para obtenerlo:**

1. Ve al dashboard de Supabase: https://supabase.com/dashboard
2. Selecciona tu proyecto: `tevoogkifiszfontzkgd`
3. Ve a **Settings** → **API**
4. En la sección **Project API keys**, busca el **service_role key** (es el que tiene prefijo `eyJhbGc...`)
5. Copia esta clave

### 2. Agregar la clave al archivo .env

Agrega esta línea al archivo `.env` en la raíz del proyecto:

```bash
SUPABASE_SERVICE_ROLE_KEY=eyJhbGc... (tu clave aquí)
```

**IMPORTANTE:** Esta clave tiene permisos de administrador. NO la compartas ni la subas a git.

### 3. Verificar que existen datos de prueba

El test requiere:

- Un usuario con email: `user2@brickshare.com`
- Al menos un punto PUDO Brickshare activo en `brickshare_pudo_locations`
- Al menos un assignment activo para ese usuario

## Ejecutar el Test

Una vez configurado todo, ejecuta:

```bash
npx tsx scripts/test-logistics-integration-e2e.ts
```

## Qué hace el test

El script simula el flujo completo de envío y devolución:

### Fase 1: DELIVERY (Envío al cliente)
1. ✅ Obtiene usuario de test
2. ✅ Obtiene punto PUDO Brickshare
3. ✅ Obtiene assignment activo del usuario
4. ✅ Crea shipment de delivery en Brickshare
5. ✅ Crea package en Brickshare_logistics
6. ✅ Simula recepción del paquete en PUDO
7. ✅ Genera QR de entrega y envía email
8. ✅ Simula validación del QR (cliente recoge)

### Fase 2: RETURN (Devolución)
9. ✅ Crea shipment de devolución en Brickshare
10. ✅ Crea package de devolución en Brickshare_logistics
11. ✅ Genera QR estático de devolución
12. ✅ Simula entrega del cliente en PUDO (validación QR)
13. ✅ Verifica trazabilidad completa en BD

## Verificación de Resultados

Al finalizar, el test mostrará:

- IDs de shipments creados
- IDs de packages creados en Logistics
- Tracking codes generados
- QR codes generados
- Estados finales de cada envío
- Queries SQL para verificar los datos en la BD

### Verificar en Brickshare

```sql
SELECT 
  id, 
  direction, 
  status, 
  pickup_type, 
  brickshare_package_id, 
  tracking_number,
  delivery_qr_code,
  return_qr_code
FROM shipments 
WHERE assignment_id = '<assignment_id>';
```

### Verificar en Brickshare_logistics

```sql
SELECT 
  id, 
  type, 
  status, 
  tracking_code, 
  external_shipment_id, 
  source_system,
  dynamic_qr_hash,
  static_qr_hash
FROM packages 
WHERE source_system = 'brickshare'
ORDER BY created_at DESC
LIMIT 10;
```

## Solución de Problemas

### Error: "supabaseKey is required"
- Asegúrate de tener `SUPABASE_SERVICE_ROLE_KEY` en el `.env`
- Verifica que no hay espacios antes o después de la clave

### Error: "Usuario no encontrado"
- Crea el usuario `user2@brickshare.com` en Supabase Auth
- O modifica la constante `TEST_USER_EMAIL` en el script

### Error: "No hay PUDOs activos"
- Inserta al menos un punto PUDO en `brickshare_pudo_locations` con `is_active = true`

### Error: "No hay assignments activos"
- Crea un assignment para el usuario de test
- O modifica el script para usar un assignment existente

### Error: "Error creando package en Logistics"
- Verifica que la URL de Logistics es correcta (variable `LOGISTICS_URL`)
- Verifica que el secret es correcto (variable `LOGISTICS_SECRET`)
- Asegúrate de que Brickshare_logistics está desplegado y funcionando

## Configuración Avanzada

Puedes modificar estas constantes al inicio del script:

```typescript
const TEST_USER_EMAIL = 'user2@brickshare.com';
const LOGISTICS_URL = 'https://qumjzvhtotcvnzpjgjkl.supabase.co';
const LOGISTICS_SECRET = 'test-secret-123';
```

## Notas de Seguridad

- El `SERVICE_ROLE_KEY` NO debe subirse a git
- Está incluido en `.gitignore`
- Solo úsalo en desarrollo/testing
- En producción, usa las Edge Functions con permisos limitados