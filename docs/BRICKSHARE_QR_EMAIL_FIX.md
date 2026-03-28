# Brickshare QR Email Function Fix

## Fecha
25/03/2026

## Problema Reportado

Al intentar generar etiquetas para usuarios con PUDO tipo "Brickshare" desde el Panel de Operaciones, la Edge Function `send-brickshare-qr-email` devolvía un error **"non-2xx status code"**.

### Contexto
- **Usuario afectado**: user3@brickshare.com
- **Tipo de PUDO**: Brickshare
- **Ubicación PUDO**: Willis Tower (21000)
- **Error**: Edge Function returned a non-2xx status code

## Investigación

### Análisis del Código

Revisé la Edge Function `send-brickshare-qr-email` en `supabase/functions/send-brickshare-qr-email/index.ts` y encontré el bug en la **línea 76**:

```typescript
// ❌ CÓDIGO INCORRECTO (línea 76)
const { data: user } = await supabaseClient
  .from('users')
  .select('email, full_name')
  .eq('user_id', shipment.user_id)  // ❌ Campo 'user_id' no existe en tabla users
  .single();
```

### Causa Raíz

El problema era que la consulta intentaba filtrar por un campo llamado `user_id` en la tabla `users`, pero este campo **no existe**. 

En la tabla `users`:
- ✅ La columna primary key se llama **`id`**
- ❌ NO existe una columna llamada `user_id`

Por lo tanto, la consulta fallaba al no encontrar el campo, causando que la Edge Function devolviera un error 500.

## Solución Aplicada

### Corrección en la Edge Function

**Archivo**: `supabase/functions/send-brickshare-qr-email/index.ts`

**Línea 76 - Cambio realizado**:
```typescript
// ✅ CÓDIGO CORREGIDO
const { data: user } = await supabaseClient
  .from('users')
  .select('email, full_name')
  .eq('id', shipment.user_id)  // ✅ Usar 'id' en lugar de 'user_id'
  .single();
```

## Flujo Completo de Generación de Etiquetas Brickshare

### 1. Trigger desde UI
Usuario admin/operador en Panel de Operaciones → Generación de Etiquetas → Clic "Generar Etiqueta"

### 2. Componente Frontend
`apps/web/src/components/admin/operations/LabelGeneration.tsx`:
```typescript
// Detecta tipo de PUDO
if (shipment.pudo_type === 'brickshare') {
    await generateBrickshareLabel(shipment.id);
}

// Función que invoca la Edge Function
const generateBrickshareLabel = async (shipmentId: string) => {
    const { data, error } = await supabase.functions.invoke(
        'send-brickshare-qr-email',
        {
            body: {
                shipment_id: shipmentId,
                type: 'delivery'
            }
        }
    );

    if (error) throw error;
    toast.success('Email con QR enviado al usuario');
    return data;
};
```

### 3. Edge Function (CORREGIDA)
`supabase/functions/send-brickshare-qr-email/index.ts`:

```typescript
// 1. Obtener shipment
const { data: shipment } = await supabaseClient
  .from('shipments')
  .select('*')
  .eq('id', shipment_id)
  .single();

// 2. Obtener datos del usuario (✅ CORREGIDO)
const { data: user } = await supabaseClient
  .from('users')
  .select('email, full_name')
  .eq('id', shipment.user_id)  // ✅ Ahora usa 'id' correctamente
  .single();

// 3. Obtener datos del set
const { data: set } = await supabaseClient
  .from('sets')
  .select('set_name, set_ref, theme')
  .eq('id', shipment.set_id)
  .single();

// 4. Obtener datos del PUDO Brickshare
const { data: pudo } = shipment.brickshare_pudo_id
  ? await supabaseClient
      .from('brickshare_pudo_locations')
      .select('name, address, city, postal_code, contact_phone, opening_hours')
      .eq('id', shipment.brickshare_pudo_id)
      .single()
  : { data: null };

// 5. Generar QR code como imagen
const qrImageDataURL = await generateQRCodeDataURL(shipment.delivery_qr_code);

// 6. Construir HTML del email con QR embebido
const htmlContent = `...`;

// 7. Enviar email vía Resend
const emailResponse = await fetch('https://api.resend.com/emails', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${RESEND_API_KEY}`,
  },
  body: JSON.stringify({
    from: 'Brickshare <onboarding@resend.dev>',
    to: [userEmail],
    subject: subject,
    html: htmlContent,
  }),
});
```

### 4. Resultado
- ✅ Email enviado con código QR al usuario
- ✅ Toast notification de éxito en UI
- ✅ Estado del shipment actualizado a `in_transit_pudo`

## Testing

### Cómo Reproducir y Verificar el Fix

1. **Crear/verificar un shipment de prueba**:
```sql
-- Verificar que existe un shipment asignado con Brickshare PUDO
SELECT 
  s.id,
  s.shipment_status,
  s.pudo_type,
  s.delivery_qr_code,
  u.email,
  u.full_name,
  p.name as pudo_name
FROM shipments s
JOIN users u ON s.user_id = u.id
LEFT JOIN brickshare_pudo_locations p ON s.brickshare_pudo_id = p.id
WHERE s.shipment_status = 'assigned'
  AND s.pudo_type = 'brickshare';
```

2. **Reiniciar Edge Functions** (si no se hizo automáticamente):
```bash
# Ctrl+C en el terminal de functions si estaban corriendo
supabase functions serve --no-verify-jwt
```

3. **Generar etiqueta desde UI**:
   - Ir a Panel de Operaciones → Generación de Etiquetas
   - Buscar el usuario de prueba
   - Clic en "Generar Etiqueta"

4. **Verificar resultado esperado**:
   - ✅ Toast de éxito: "Email con QR enviado al usuario"
   - ✅ Usuario recibe email con código QR
   - ✅ Estado del shipment cambia a `in_transit_pudo`

### Verificar el Email Recibido

El email debe contener:
- ✅ Código QR como imagen embebida
- ✅ Código QR en texto (para backup)
- ✅ Datos del PUDO (nombre, dirección, teléfono)
- ✅ Instrucciones de recogida
- ✅ Datos del set LEGO

## Errores Relacionados Corregidos Previamente

Este es el segundo error encontrado en el flujo de generación de etiquetas:

1. **Error #1 - Campo incorrecto en actualización de estado** (CORREGIDO):
   - Archivo: `apps/web/src/lib/labelPrintService.ts`
   - Bug: Usaba `shipping_status` en lugar de `shipment_status`
   - Fix: [docs/SHIPMENT_STATUS_UPDATE_FIX.md](./SHIPMENT_STATUS_UPDATE_FIX.md)

2. **Error #2 - Campo incorrecto en consulta de usuarios** (ESTE FIX):
   - Archivo: `supabase/functions/send-brickshare-qr-email/index.ts`
   - Bug: Usaba `.eq('user_id', ...)` en lugar de `.eq('id', ...)`
   - Fix: Este documento

## Posibles Errores Similares en Otras Edge Functions

### Recomendación de Auditoría

Revisar otras Edge Functions que consulten la tabla `users` para asegurar que usan el campo correcto:

```bash
# Buscar posibles usos incorrectos del campo user_id
grep -r "\.eq('user_id'" supabase/functions/

# Debería devolver 0 resultados después de este fix
```

### Patrón Correcto

Cuando necesites filtrar por el ID del usuario en la tabla `users`:

```typescript
// ✅ CORRECTO
const { data: user } = await supabaseClient
  .from('users')
  .select('*')
  .eq('id', userId)  // La PK de users se llama 'id'
  .single();

// ❌ INCORRECTO
const { data: user } = await supabaseClient
  .from('users')
  .select('*')
  .eq('user_id', userId)  // Este campo NO existe
  .single();
```

## Estado Final

- ✅ Bug identificado y corregido
- ✅ Edge Functions reiniciadas con el código actualizado
- ✅ Flujo de generación de etiquetas Brickshare completamente funcional
- ✅ Documentación completa del fix

## Referencias

- [LABEL_GENERATION_FEATURE.md](./LABEL_GENERATION_FEATURE.md) - Documentación del feature completo
- [LABEL_GENERATION_TROUBLESHOOTING.md](./LABEL_GENERATION_TROUBLESHOOTING.md) - Guía de troubleshooting
- [SHIPMENT_STATUS_UPDATE_FIX.md](./SHIPMENT_STATUS_UPDATE_FIX.md) - Fix del error #1
- [QR_CODE_IMPROVEMENTS.md](./QR_CODE_IMPROVEMENTS.md) - Mejoras en sistema QR

## Archivos Modificados

- ✅ `supabase/functions/send-brickshare-qr-email/index.ts` - Línea 76 corregida

## Próximos Pasos

1. ✅ Testear en producción con usuarios reales
2. ⚠️ Considerar agregar más logging en la Edge Function para facilitar debugging futuro
3. ⚠️ Auditar otras Edge Functions buscando errores similares