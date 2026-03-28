# Fix: Edge Function send-brickshare-qr-email no desplegada

**Fecha:** 25/03/2026
**Estado:** ✅ RESUELTO

## Problema

Al intentar generar etiquetas para envíos con PUDO tipo "brickshare", el proceso fallaba con el siguiente error:

```
POST http://localhost:54331/functions/v1/send-brickshare-qr-email 404 (Not Found)
Label generation error: Error enviando email QR: Edge Function returned a non-2xx status code
```

## Causa Raíz

La Edge Function `send-brickshare-qr-email` existía en el código fuente (`supabase/functions/send-brickshare-qr-email/index.ts`) pero **NO estaba desplegada** en el proyecto de Supabase.

Al ejecutar `supabase functions list`, la función no aparecía en la lista de funciones activas, provocando que las llamadas desde el frontend devolvieran 404.

## Solución

Desplegar la Edge Function manualmente:

```bash
supabase functions deploy send-brickshare-qr-email
```

### Verificación

Confirmar que la función aparece en la lista:

```bash
supabase functions list
```

Debe aparecer:
```
205cc66e-eacb-468f-97d1-1bb5a82af01c | send-brickshare-qr-email | send-brickshare-qr-email | ACTIVE | 1 | 2026-03-25 20:52:27
```

## Contexto Técnico

### Flujo de Generación de Etiquetas

1. **Admin** hace clic en "Generar Etiqueta" en `LabelGeneration.tsx`
2. El componente verifica el `pudo_type` del envío
3. Para `pudo_type === 'brickshare'`:
   - Se verifica/genera el `delivery_qr_code`
   - Se llama a la Edge Function `send-brickshare-qr-email`
   - La función genera un email con QR embebido
   - El email se envía vía Resend API
4. El estado del envío se actualiza a `in_transit_pudo`

### Edge Function send-brickshare-qr-email

**Propósito:** Enviar emails con códigos QR para entrega/devolución en puntos Brickshare

**Parámetros:**
```typescript
{
  shipment_id: string,
  type: 'delivery' | 'return'
}
```

**Dependencias:**
- `RESEND_API_KEY` (variable de entorno)
- API de QR Server (https://api.qrserver.com) para generar imágenes QR
- Datos de `shipments`, `users`, `sets`, `brickshare_pudo_locations`

## Prevención

### Checklist de Edge Functions

Al crear una nueva Edge Function, asegurarse de:

1. ✅ Crear el archivo en `supabase/functions/<nombre>/index.ts`
2. ✅ Configurar variables de entorno necesarias en `supabase/.env`
3. ✅ **Desplegar la función** con `supabase functions deploy <nombre>`
4. ✅ Verificar con `supabase functions list`
5. ✅ Probar la función manualmente antes de integrar en UI

### Script de Verificación

Crear un script para verificar que todas las funciones del código estén desplegadas:

```bash
#!/bin/bash
# scripts/verify-edge-functions.sh

echo "Funciones en el código:"
ls -1 supabase/functions/

echo -e "\nFunciones desplegadas:"
supabase functions list --format name

echo -e "\nVerificar que todas las funciones estén desplegadas."
```

## Funciones Relacionadas

Otras Edge Functions del ecosistema logístico:

- `correos-logistics`: Crear envíos con Correos API
- `correos-pudo`: Consultar puntos PUDO de Correos
- `brickshare-qr-api`: API de validación de QR en puntos Brickshare

## Testing

Para probar el flujo completo:

1. Crear usuario con suscripción activa
2. Asignar set con `pudo_type = 'brickshare'`
3. Ir a "Operaciones" → "Generación de Etiquetas"
4. Click en "Generar Etiqueta" para el envío
5. Verificar que:
   - ✅ QR code se genera (formato: `BS-DEL-<shipment_id>`)
   - ✅ Email se envía correctamente
   - ✅ Estado cambia a `in_transit_pudo`
   - ✅ No hay errores 404 en consola

## Referencias

- Componente: `apps/web/src/components/admin/operations/LabelGeneration.tsx`
- Edge Function: `supabase/functions/send-brickshare-qr-email/index.ts`
- Documentación: `docs/LABEL_GENERATION_FEATURE.md`
- Configuración: `supabase/config.toml`

## Lecciones Aprendidas

1. **Siempre verificar el despliegue:** No asumir que porque el código existe, la función está disponible
2. **Logs claros:** El error 404 indica claramente que la función no existe en el servidor
3. **Checklist de desarrollo:** Incluir paso de despliegue en workflow de nuevas features
4. **CI/CD:** Considerar automatizar el despliegue de Edge Functions en el pipeline

---

**Autor:** Sistema de desarrollo Brickshare  
**Última actualización:** 25/03/2026