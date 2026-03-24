# Lectura de Códigos QR en Depósito Brickshare - Análisis Completo

## 1. Flujo Completo del Proceso de Asignación y Recogida

### 1.1 Fase de Asignación (Admin Panel)

```
Admin ejecuta preview_assign_sets_to_users()
    ↓
Sistema genera propuesta de asignación
    ↓
Admin revisa y confirma con confirm_assign_sets_to_users(user_ids)
    ↓
Para cada usuario:
  - Se selecciona un set de la wishlist
  - Se crea registro en `shipments` tabla
  - Se genera QR único con formato: BS-{SHIPMENT_ID}-{TIMESTAMP}
  - Se decrementa inventario (in_shipping++)
  - Se actualiza estado usuario a 'set_shipping'
  - Se elimina set de wishlist
    ↓
Se retorna array con detalles de shipments
```

### 1.2 Fase de Email (Automática vía Resend)

```
Trigger en insert de `shipments` → send_qr_email_on_shipment_creation()
    ↓
O manualmente: Edge Function send-brickshare-qr-email
    ↓
Email incluye:
  - Código QR (imagen PNG embebida)
  - Texto QR legible: "BS-{SHIPMENT_ID}-{TIMESTAMP}"
  - Instrucciones para recogida
  - Nombre del set
  - Dirección del depósito PUDO
    ↓
Email enviado a: user.email (ej: enriquepeto@yahoo.es)
```

### 1.3 Fase de Entrega Física (Correos/Logística)

```
Set preparado en almacén
    ↓
Se genera etiqueta con QR
    ↓
Correos recoge paquete
    ↓
Paquete llega a PUDO (depósito Brickshare seleccionado)
    ↓
Depósito notifica usuario (SMS/email)
    ↓
Usuario acude al depósito con código QR
```

### 1.4 Fase de Recogida (Operador/Depositario)

```
Usuario llega al depósito con:
  - Email con QR impreso/digital
  - Código QR del email
  - DNI/identificación
    ↓
Operador escanea código QR con:
  - App Brickshare (Tablet/Terminal en PUDO)
  - O smartphone con App de validación
    ↓
Sistema valida QR:
  - ¿QR pertenece a este PUDO?
  - ¿QR ya fue usado?
  - ¿Shipment está en estado "delivered"?
    ↓
Si válido:
  - Mostrar nombre del usuario
  - Mostrar nombre/referencia del set
  - Mostrar peso/dimensiones (para verificación física)
    ↓
Operador entrega set físico al usuario
    ↓
Operador marca QR como "USADO" en app
    ↓
Estado shipment → "received_by_user"
    ↓
Sistema envía confirmación a usuario (email/SMS)
```

## 2. Estructura de Datos del QR

### 2.1 Formato del Código QR

```
Estructura: BS-{SHIPMENT_UUID}-{UNIX_TIMESTAMP}

Ejemplo:
  BS-550e8400-e29b-41d4-a716-446655440000-1711270800

Información decodificada:
  - Prefijo: BS (Brickshare)
  - UUID del shipment: 550e8400-e29b-41d4-a716-446655440000
  - Timestamp: 1711270800 (para expiración/auditoría)
```

### 2.2 Datos asociados en Base de Datos

```sql
-- Tabla: shipments
SELECT
  id,                           -- UUID del shipment (en QR)
  user_id,                      -- Usuario que recoge
  set_id,                       -- Set que se entrega
  shipment_status,              -- Estado: pending, delivered, received_by_user, in_return
  qr_code,                      -- Texto QR: BS-{id}-{timestamp}
  qr_scanned_at,                -- Timestamp de validación en PUDO
  delivery_pudo_id,             -- PUDO de recogida
  created_at,                   -- Fecha de asignación
  delivered_at                  -- Fecha de entrega a usuario
FROM shipments
WHERE id = 'shipment_uuid';
```

### 2.3 Tabla de Validación QR

```sql
-- Tabla: qr_validation_logs
SELECT
  id,
  shipment_id,                  -- QR escaneado
  pudo_id,                      -- PUDO donde se escaneó
  operator_id,                  -- Operador que escaneó
  validation_type,              -- 'delivery' o 'return'
  valid,                         -- true/false
  error_reason,                 -- Si invalid: por qué
  scanned_at                    -- Timestamp del escaneo
FROM qr_validation_logs
ORDER BY scanned_at DESC;
```

## 3. Edge Function: brickshare-qr-api

### 3.1 Endpoint de Validación

```
POST /functions/v1/brickshare-qr-api/validate

Request:
{
  "qr_code": "BS-550e8400-e29b-41d4-a716-446655440000-1711270800",
  "pudo_id": "00123456",           // ID Correos del PUDO
  "operator_id": "user_uuid",       // Operador que escanea
  "type": "delivery"                // o "return"
}

Response (success):
{
  "valid": true,
  "shipment_id": "550e8400-e29b-41d4-a716-446655440000",
  "user_name": "Enrique Pérez",
  "set_name": "LEGO Star Wars 75192",
  "set_ref": "75192",
  "set_weight": 2.5,
  "pudo_name": "Correos Paseo de Gracia",
  "delivery_type": "delivery",
  "status": "ready_for_pickup",
  "instructions": "Entregar set al usuario"
}

Response (invalid):
{
  "valid": false,
  "error": "QR_ALREADY_USED",
  "message": "Este QR ya fue escaneado",
  "scanned_by": "operator_name",
  "scanned_at": "2025-03-23T10:30:00Z"
}
```

### 3.2 Validaciones Implementadas

```javascript
// En Edge Function: supabase/functions/brickshare-qr-api/index.ts

1. Parsing QR
   - Verificar formato BS-{UUID}-{TIMESTAMP}
   - Extraer shipment_id

2. Buscar Shipment
   - SELECT * FROM shipments WHERE id = shipment_id
   - Si no existe → ERROR: "QR_NOT_FOUND"

3. Verificar PUDO
   - ¿El shipment corresponde a este PUDO?
   - Si no → ERROR: "WRONG_PUDO"

4. Verificar Estado
   - ¿shipment_status === 'delivered'?
   - Si no → ERROR: "SHIPMENT_NOT_READY"

5. Verificar uso anterior
   - ¿qr_scanned_at IS NOT NULL?
   - Si sí → ERROR: "QR_ALREADY_USED"

6. Verificar expiración (opcional)
   - ¿created_at > NOW() - INTERVAL '30 days'?
   - Si no → ERROR: "QR_EXPIRED"

7. Si todo válido:
   - Insertar en qr_validation_logs
   - UPDATE shipments SET qr_scanned_at = NOW()
   - UPDATE shipments SET shipment_status = 'received_by_user'
   - UPDATE users SET user_status = 'set_using'
   - Retornar detalles para operador

8. Enviar confirmación
   - Email a usuario confirmando recogida
```

## 4. Aplicación de Escaneo QR en Depósito

### 4.1 Arquitectura Esperada

```
Depósito Brickshare
├── Terminal/Tablet (Android)
│   ├── App Brickshare Operator
│   │   ├── Pantalla de Login (Operador)
│   │   ├── Pantalla de Escaneo QR
│   │   │   ├── Cámara en vivo
│   │   │   ├── Detección automática de QR
│   │   │   └── Botón manual para ingresar código
│   │   ├── Pantalla de Confirmación
│   │   │   ├── Detalles del usuario
│   │   │   ├── Detalles del set
│   │   │   ├── Foto/preview del set
│   │   │   └── Botones: Confirmar | Cancelar
│   │   ├── Pantalla de Historial
│   │   └── Offline Mode (sincronizar después)
│   │
│   └── Backend Sync:
│       ├── Si hay conexión → Validación inmediata en servidor
│       └── Si sin conexión → Validación local + sync posterior
│
└── Servidor Brickshare
    ├── Edge Function: brickshare-qr-api
    ├── Tabla: qr_validation_logs
    └── Notificaciones (Resend/SMS)
```

### 4.2 Flujo de Escaneo en App

```
1. Operador abre app → autenticado como "operador"

2. Pantalla de Escaneo QR
   - Cámara abierta
   - Esperando escaneo

3. Opción A: Escaneo automático
   - Usuario acerca el email/documento con QR impreso
   - Cámara detecta QR automáticamente
   - Parsea: BS-{UUID}-{TIMESTAMP}

4. Opción B: Entrada manual
   - Usuario ingresa código manualmente
   - O escanea código de barras alternativo

5. Validación
   - POST /functions/v1/brickshare-qr-api/validate
   - {qr_code, pudo_id, operator_id, type: 'delivery'}

6. Respuesta del servidor
   - Si válido:
     * Mostrar "✓ QR válido"
     * Mostrar detalles del usuario y set
     * Audio/vibración de confirmación
   - Si error:
     * Mostrar motivo del error en rojo
     * Opción de reintentar o llamar al soporte

7. Confirmación
   - Operador verifica identidad del usuario
   - Compara foto en app con usuario (opcional)
   - Presiona "Confirmar entrega"

8. Post-confirmación
   - QR marcado como USADO
   - Shipment status actualizado
   - Log creado en qr_validation_logs
   - Usuario recibe confirmación por email
   - Pantalla vuelve a escaneo vacía
```

### 4.3 Experiencia del Usuario en PUDO

```
Flujo físico en el depósito:

1. Usuario llega al PUDO
   - "Vengo a recoger mi set LEGO de Brickshare"

2. Operador:
   - "¿Tienes el código QR del email?"
   - O "¿Tu DNI, por favor?"

3. Usuario muestra:
   - Email impreso (con QR)
   - O código QR digital en smartphone

4. Operador escanea QR con tablet
   - App valida automáticamente
   - Muestra: "✓ Enrique Pérez - LEGO 75192"

5. Verificaciones:
   - Operador: "¿Eres Enrique Pérez?"
   - Usuario confirma + muestra DNI

6. Entrega:
   - Operador obtiene set del almacén
   - Verifica físicamente peso/dimensiones (coinciden)
   - Entrega al usuario

7. Cierre:
   - Operador presiona "Confirmar entrega"
   - Sistema registra entrega
   - Usuario recibe email: "Has recogido tu set en PUDO XYZ"

8. Usuario se va con el set
```

## 5. Casos de Error y Recuperación

### 5.1 Errores Comunes

```
1. QR_NOT_FOUND
   - Causa: QR inválido o mal escaneado
   - Acción: Reintentar escaneo, verificar email

2. QR_ALREADY_USED
   - Causa: QR fue escaneado hace poco
   - Acción: Usuario ya recogió el set
   - Acción alt: Contactar soporte si es un error

3. WRONG_PUDO
   - Causa: Usuario fue a PUDO equivocado
   - Acción: Indicarle PUDO correcto
   - Acción alt: Cambiar PUDO si está disponible

4. SHIPMENT_NOT_READY
   - Causa: Set no ha llegado al PUDO aún
   - Acción: Consultar con logística, informar usuario

5. QR_EXPIRED
   - Causa: Pasaron >30 días sin recoger
   - Acción: Set devuelto a almacén, notificar usuario

6. OFFLINE_MODE
   - Si app sin conexión:
     * Almacenar QR localmente
     * Mostrar "Validando..."
     * Sincronizar cuando hay conexión
     * Si hay conflicto: mostrar error y solicitar reconexión
```

### 5.2 Recuperación de Errores

```sql
-- Si operador escanea mal y marca como entregado erróneamente:
UPDATE shipments 
SET shipment_status = 'delivered', qr_scanned_at = NULL
WHERE id = 'shipment_id';

DELETE FROM qr_validation_logs 
WHERE shipment_id = 'shipment_id' 
  AND scanned_at > NOW() - INTERVAL '5 minutes';

-- Admin puede deshacer desde backoffice
-- Email de notificación al usuario
```

## 6. Estadísticas y Monitoreo

### 6.1 Métricas Importantes

```sql
-- Tasas de recogida por PUDO
SELECT
  pudo_id,
  COUNT(*) as total_shipments,
  COUNT(CASE WHEN qr_scanned_at IS NOT NULL THEN 1 END) as picked_up,
  ROUND(100.0 * COUNT(CASE WHEN qr_scanned_at IS NOT NULL THEN 1 END) 
        / COUNT(*), 2) as pickup_rate
FROM shipments
WHERE created_at > NOW() - INTERVAL '30 days'
GROUP BY pudo_id;

-- Tiempo promedio entre entrega y recogida
SELECT
  pudo_id,
  ROUND(AVG(EXTRACT(EPOCH FROM (qr_scanned_at - delivered_at))/3600)::numeric, 2) as avg_hours_to_pickup
FROM shipments
WHERE qr_scanned_at IS NOT NULL
GROUP BY pudo_id;

-- Errores de validación QR
SELECT
  error,
  COUNT(*) as count,
  ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM qr_validation_logs WHERE valid = false), 2) as percent
FROM qr_validation_logs
WHERE valid = false
GROUP BY error
ORDER BY count DESC;
```

## 7. Integración con Retornos

### 7.1 Flujo de Devolución

```
Usuario quiere devolver el set:

1. Usuario llega al PUDO
   - "Quiero devolver mi set"

2. Operador:
   - Abre app con QR de RETORNO
   - (QR diferente, generado en shipments.return_qr)

3. Proceso similar:
   - Valida QR de retorno
   - type: "return" (no "delivery")
   - Verifica identidad usuario
   - Recibe set físicamente

4. Verificaciones:
   - ¿Set completo?
   - ¿Sin daños graves?
   - Toma foto si hay desperfectos

5. Cierre:
   - Presiona "Confirmar devolución"
   - Sistema actualiza shipment_status = "in_return"
   - Usuario se va sin set

6. Backend:
   - Crea registro en reception_operations
   - Inicia proceso de inspección/limpieza
   - Eventualmente set vuelve a inventario
```

## 8. Resumen de Archivos Involucrados

| Archivo | Función |
|---------|----------|
| `supabase/functions/brickshare-qr-api` | Validación QR servidor |
| `supabase/functions/send-brickshare-qr-email` | Envío de email con QR |
| `apps/web/src/components/admin/operations/ShipmentsList` | Admin panel |
| `apps/web/src/hooks/useShipments` | Hook para gestionar shipments |
| `supabase/migrations/20260321000000_brickshare_pudo_qr_system.sql` | Schema QR |
| `docs/BRICKSHARE_PUDO_QR_API.md` | Documentación técnica |

---

**Versión**: 1.0  
**Última actualización**: 23 Marzo 2025  
**Estatus**: Implementación pendiente de app operador