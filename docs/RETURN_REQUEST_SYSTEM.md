# Sistema de Solicitud de Devoluciones - Dual Flow (Brickshare + Correos)

## 📋 Descripción General

Sistema completo para que usuarios soliciten devoluciones de sets de LEGO. Soporta dos flujos paralelos:

- **Brickshare PUDO**: Genera QR único, envía email al usuario, usuario devuelve en punto Brickshare
- **Correos PUDO**: Registra retorno con API Correos, crea envío desde PUDO usuario a almacén central

---

## 🏗️ Arquitectura

### Componentes

```
┌─────────────────────────────────────────────────────────────┐
│                    FRONTEND (Dashboard)                      │
│                  apps/web/src/pages/Dashboard.tsx            │
│                                                               │
│  Tabla "Mi Histórico" → Columna "Acciones"                  │
│  Botón: "Tramitar Devolución" (visible si status='delivered') │
│  └─ Dialog confirmación → onClick: useReturnSet.mutate()    │
└────────────────┬────────────────────────────────────────────┘
                 │
                 │ shipment_id
                 ↓
┌─────────────────────────────────────────────────────────────┐
│              HOOK: useReturnSet                              │
│         apps/web/src/hooks/useOrders.ts                     │
│                                                               │
│  Mutation: supabase.functions.invoke('request-return')      │
│  Body: { shipment_id }                                      │
│  onSuccess: Toast + Invalidate queries                      │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────────────────────────┐
│         EDGE FUNCTION: request-return                        │
│    supabase/functions/request-return/index.ts               │
│                                                               │
│  1. Validación:                                              │
│     - JWT verificado ✅                                      │
│     - Shipment pertenece al usuario ✅                       │
│     - Status = 'delivered_user' ✅                           │
│     - No hay devolución previa ✅                            │
│                                                               │
│  2. Enrutamiento por pudo_type:                             │
│     ├─ 'brickshare' → handleBrickshareReturn()             │
│     └─ 'correos'    → handleCorreosReturn()                │
└────────────┬────────────────┬───────────────────────────────┘
             │                │
    ┌────────▼────┐  ┌────────▼──────┐
    │ BRICKSHARE  │  │   CORREOS     │
    │   FLOW      │  │    FLOW       │
    └────────┬────┘  └────────┬──────┘
             │                │
             │                └─ 2. Call correos-logistics
             │                   action: 'return_preregister'
             │                   API Correos crea envío
             │                   Almacena código en tracking_number
             │
             └─ 1. Genera QR: BS-RET-{id}-{random}
                2. Update shipments:
                   - return_qr_code
                   - return_qr_at
                   - status = 'in_return_pudo'
                3. Invoke send-brickshare-qr-email
                   type: 'return'
                   QR Code + PUDO info + instrucciones
```

---

## 📊 Tabla: shipments

### Nuevas Columnas (Migración 20260401000000)

```sql
ALTER TABLE shipments ADD COLUMN IF NOT EXISTS return_qr_code TEXT;
ALTER TABLE shipments ADD COLUMN IF NOT EXISTS return_qr_at TIMESTAMP WITH TIME ZONE;

CREATE INDEX idx_shipments_return_qr_code ON shipments(return_qr_code) 
WHERE return_qr_code IS NOT NULL;
```

### Estados de Transición

```
delivered_user
    ↓
[Click "Tramitar Devolución"]
    ↓
request-return edge function
    ├─ if pudo_type='brickshare':
    │    ├─ genera return_qr_code (BS-RET-...)
    │    ├─ registra return_qr_at
    │    ├─ status → in_return_pudo
    │    └─ envía email con QR
    │
    └─ if pudo_type='correos':
         ├─ llama correos-logistics
         ├─ API crea envío retorno
         ├─ status → in_return_pudo
         └─ NO envía email
```

---

## 🔧 Edge Function: request-return

**Ubicación**: `supabase/functions/request-return/index.ts`

### Validaciones Iniciales

```typescript
✅ Authorization header presente
✅ JWT válido
✅ Shipment existe
✅ Shipment pertenece al usuario autenticado
✅ Status actual = 'delivered_user'
✅ No hay return_qr_code previo (una sola devolución por shipment)
```

### Flujo Brickshare: handleBrickshareReturn()

```typescript
1. Generar QR: `BS-RET-{shipment_id.substring(0, 8)}-{nanoid(8)}`
   → Ejemplo: BS-RET-a1b2c3d4-xK9pL2mN

2. Actualizar shipments:
   {
     return_qr_code: 'BS-RET-...',
     return_qr_at: NOW(),
     status: 'in_return_pudo',
     updated_at: NOW()
   }

3. Invocar send-brickshare-qr-email:
   {
     shipment_id,
     email,
     full_name,
     set_name,
     set_ref,
     set_image_url,
     qr_code: returnQrCode,           // BASE64 SVG
     qr_type: 'return',               // NUEVO
     pudo_info: {
       type: 'brickshare',
       name: 'Punto Brickshare XYZ',
       address: 'Calle Mayor 123',
       city: 'Madrid',
       postal_code: '28001'
     }
   }

4. Respuesta:
   {
     message: 'Return requested successfully (Brickshare PUDO)',
     shipment_id,
     return_qr_code,
     pudo_type: 'brickshare'
   }
```

### Flujo Correos: handleCorreosReturn()

```typescript
1. Validar usuario tiene PUDO Correos configurado
   → SELECT FROM users_correos_dropping WHERE user_id = ?

2. Invocar correos-logistics:
   {
     action: 'return_preregister',
     p_shipment_id: shipment.id
   }

3. Correos API:
   - Origen: PUDO del usuario (users_correos_dropping)
   - Destino: OFFICE_ADDRESS (almacén central)
   - Crea etiqueta sin etiqueta ("Sin Etiqueta")
   - Retorna código: correosData.return_code

4. Actualizar shipments:
   {
     shipment_status: 'in_return_pudo',
     tracking_number: return_code,  // Ya actualizado por correos-logistics
     updated_at: NOW()
   }

5. Respuesta:
   {
     message: 'Return requested successfully (Correos)',
     shipment_id,
     return_code: 'ETIQUETA_SIN_ETIQUETA_CODE',
     pudo_type: 'correos'
   }

   ⚠️ NO se envía email al usuario
```

---

## 💌 Email: send-brickshare-qr-email (Actualizado)

**Ubicación**: `supabase/functions/send-brickshare-qr-email/index.ts`

### Parámetros

```typescript
interface EmailPayload {
  shipment_id: string;
  email: string;
  full_name: string;
  set_name: string;
  set_ref: string;
  set_image_url?: string;
  qr_code: string;              // BASE64 SVG
  qr_type: 'delivery' | 'return';  // NUEVO
  pudo_info: {
    type: 'brickshare' | 'correos';
    name: string;
    address: string;
    postal_code: string;
    city: string;
  };
}
```

### Cambios Principales

**Antes**:
```typescript
// Solo soportaba delivery
if (qr_code && pudo_info) {
  // Template genérico
}
```

**Ahora**:
```typescript
if (qr_type === 'return') {
  // Template específico para devoluciones
  // Encabezado: "Tu código de devolución Brickshare"
  // Instrucciones: prepara paquete → va a PUDO → presenta QR → devuelve
} else {
  // Template para recogida (default)
  // Encabezado: "Tu código QR de recogida está listo"
  // Instrucciones: dirígete a PUDO → presenta QR → recibe set
}
```

### Ejemplo Email (Return)

```
Asunto: Tu código de devolución Brickshare

Cuerpo:
¡Hola Juan!
Has solicitado la devolución de tu set de LEGO Seattle Space Needle (Ref. 21003).
Aquí está el código QR para entregarla en tu punto de retorno:

[QR Code SVG]

PUNTO DE RETORNO:
Punto Brickshare Madrid Centro
Calle Mayor 123
28001 Madrid

Pasos a seguir:
1. Prepara el set de LEGO de forma segura
2. Dirígete al punto de retorno indicado
3. Muestra el código QR
4. El personal recepcionará tu devolución

Gracias por usar Brickshare. ¡Esperamos tu próxima suscripción!
```

---

## 🎯 Hook: useReturnSet

**Ubicación**: `apps/web/src/hooks/useOrders.ts`

```typescript
export const useReturnSet = () => {
    const queryClient = useQueryClient();
    const { toast } = useToast();

    return useMutation({
        mutationFn: async (shipmentId: string) => {
            // Llama a edge function request-return
            const { data, error } = await supabase.functions.invoke('request-return', {
                body: { shipment_id: shipmentId }
            });

            if (error) throw new Error(error.message);
            return data;
        },
        onSuccess: (data) => {
            // Toast diferente según pudo_type
            const message = data?.pudo_type === 'brickshare'
                ? "Devolución iniciada. Recibirás un email con el código QR..."
                : "Devolución iniciada a través de Correos.";

            toast({
                title: "Devolución solicitada",
                description: message,
            });
            queryClient.invalidateQueries({ queryKey: ["orders"] });
        },
        onError: (error: Error) => {
            toast({
                title: "Error",
                description: "No se pudo procesar la devolución: " + error.message,
                variant: "destructive",
            });
        },
    });
};
```

---

## 🖼️ Frontend: Dashboard

**Ubicación**: `apps/web/src/pages/Dashboard.tsx`

### Tabla "Mi Histórico"

Columna **Acciones**:
- Botón "Tramitar Devolución" aparece si:
  - `shipment_status === 'delivered_user'`
  - Es el envío más reciente (`index === 0`)

```typescript
const canReturn = index === 0 && order.shipment_status === 'delivered_user';

if (canReturn) {
  <Button
    onClick={() => handleReturnClick(order.id)}
    disabled={returnMutation.isPending}
  >
    <ArrowLeftRight className="h-3.5 w-3.5" />
    Solicitar devolución
  </Button>
}
```

### Dialog de Confirmación

```typescript
<AlertDialog open={returnDialogOpen}>
  <AlertDialogHeader>
    <AlertDialogTitle>¿Confirmar devolución?</AlertDialogTitle>
    <AlertDialogDescription>
      Se cambiará el estado del envío a "En Ruta (Devolución)".
      Asegúrate de preparar el paquete para su recogida.
    </AlertDialogDescription>
  </AlertDialogHeader>
  <AlertDialogAction onClick={handleConfirmReturn}>
    Confirmar Devolución
  </AlertDialogAction>
</AlertDialog>
```

---

## ✅ Flujos de Éxito

### Caso 1: Brickshare PUDO

```
Usuario en Dashboard
    ↓
Estado del envío: "Entregado"
    ↓
Click "Tramitar Devolución"
    ↓
Dialog confirmación
    ↓
Click "Confirmar Devolución"
    ↓
POST request-return { shipment_id }
    ↓
Backend:
    - Valida user + status
    - Genera QR: BS-RET-a1b2c3d4-xK9pL2mN
    - UPDATE shipments (return_qr_code, return_qr_at, status='in_return_pudo')
    - INVOKE send-brickshare-qr-email (qr_type='return')
    ↓
Email recibido:
    - Asunto: "Tu código de devolución Brickshare"
    - QR para escanear
    - Dirección del punto de retorno
    ↓
Usuario:
    - Prepara el paquete
    - Va al punto Brickshare
    - Presenta el código QR o lo escanea
    - Personal recepción verifica y recibe el set
    ↓
Estado actualizado: "Devolución en PUDO"
```

### Caso 2: Correos PUDO

```
Usuario en Dashboard
    ↓
Estado del envío: "Entregado"
    ↓
Click "Tramitar Devolución"
    ↓
Dialog confirmación
    ↓
Click "Confirmar Devolución"
    ↓
POST request-return { shipment_id }
    ↓
Backend:
    - Valida user + status
    - Verifica pudo_type='correos'
    - INVOKE correos-logistics { action: 'return_preregister' }
    - API Correos crea etiqueta "Sin Etiqueta"
    - Retorna código: "ETIQUETA_SIN_ETIQUETA_12345"
    - UPDATE shipments (status='in_return_pudo', tracking_number=codigo)
    ↓
Backend responde:
    {
      message: 'Return requested successfully (Correos)',
      return_code: 'ETIQUETA_SIN_ETIQUETA_12345',
      pudo_type: 'correos'
    }
    ↓
Toast: "Devolución iniciada a través de Correos"
    ↓
Usuario:
    - Recibe instrucciones vía SMS/WhatsApp de Correos (aparte)
    - Va al punto Correos
    - Presenta código de retorno
    - Correos genera etiqueta
    - Usuario devuelve paquete
    ↓
Estado actualizado: "Devolución en PUDO"
```

---

## 🚨 Casos de Error

| Error | Causa | Solución |
|-------|-------|----------|
| `Missing Authorization header` | Sin JWT | Usuario debe estar autenticado |
| `Unauthorized` | JWT inválido | Re-login requerido |
| `Shipment not found` | ID no existe | Refresh página / Try again |
| `Forbidden - Shipment does not belong to user` | Intento de acceso no autorizado | Error de seguridad |
| `Invalid shipment status` | No está en 'delivered_user' | Envío debe estar entregado |
| `Return already requested for this shipment` | Ya solicitó devolución | Devolución ya en proceso |
| `User has no Correos PUDO configured` | Correos sin PUDO | Usuario debe seleccionar PUDO |
| `Correos Logistics Error` | Error API Correos | Verificar credenciales Correos |

---

## 🧪 Testing

### Caso 1: Brickshare Return

```bash
# Verificar que shipment esté en 'delivered_user' con pudo_type='brickshare'
SELECT id, user_id, pudo_type, shipment_status 
FROM shipments 
WHERE pudo_type='brickshare' AND shipment_status='delivered_user' 
LIMIT 1;

# Ejecutar solicitud de devolución (vía Dashboard o curl)
curl -X POST http://localhost:54321/functions/v1/request-return \
  -H "Authorization: Bearer <USER_JWT>" \
  -H "Content-Type: application/json" \
  -d '{"shipment_id": "<SHIPMENT_ID>"}'

# Verificar actualización
SELECT return_qr_code, return_qr_at, shipment_status 
FROM shipments 
WHERE id='<SHIPMENT_ID>';
```

### Caso 2: Correos Return

```bash
# Similar, pero con pudo_type='correos'
SELECT id, user_id, pudo_type, shipment_status 
FROM shipments 
WHERE pudo_type='correos' AND shipment_status='delivered_user' 
LIMIT 1;

# Ejecutar solicitud
# Verificar que tracking_number se llena desde correos-logistics
SELECT tracking_number, shipment_status 
FROM shipments 
WHERE id='<SHIPMENT_ID>';
```

---

## 📝 Seguridad

✅ **JWT verificado** en edge function  
✅ **User ownership** validado (shipment.user_id === auth.uid())  
✅ **Status validation** (solo 'delivered_user')  
✅ **Rate limiting** (una sola devolución por shipment)  
✅ **No expone datos** de otros usuarios  
✅ **CORS headers** configurados correctamente  

---

## 📞 Soporte

Para problemas:
1. Revisar logs en Supabase Dashboard → Functions
2. Verificar que edge functions están desplegadas
3. Confirmar variables de entorno configuradas
4. Validar que migración BD se aplicó

Logs relevantes:
- `supabase functions logs request-return`
- `supabase functions logs send-brickshare-qr-email`
- `supabase functions logs correos-logistics` (para Correos returns)