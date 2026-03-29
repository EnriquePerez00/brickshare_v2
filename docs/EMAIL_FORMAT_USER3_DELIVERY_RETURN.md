# 📧 Formato de Emails - User3 (Laura López Fernández) - Brickshare

## Información de User3

| Campo | Valor |
|-------|-------|
| **Nombre Completo** | Laura López Fernández |
| **Email** | enriqueperezbcn1973+test3@gmail.com |
| **User ID** | ddeb8bef-314e-45d3-b9f2-3631a2733dcc (generado dinámicamente) |
| **Suscripción** | brick_pro (3 sets simultáneos) |
| **PUDO Type** | brickshare |
| **PUDO Location** | Brickshare Barcelona Eixample |
| **PUDO Address** | Passeig de Gràcia 100, 08008 Barcelona |
| **Stripe Customer** | cus_test_user3_[UUID_segment] |
| **Payment Method** | pm_test_card_003 |
| **Rol** | user |
| **Status Perfil** | profile_completed = true |

---

## 1. EMAIL DE ENTREGA (Delivery QR)

### Detalles de Envío de Ejemplo

```
Shipment ID: 54a82b94-2f1a-4771-a8bf-7ef3e06e5d98
Set LEGO: City In-Flight 2006 (Set Ref: 2928)
Estado: in_transit_pudo
QR Código Usuario: BS-DEL-54A82B94-2F1
QR Código Recepción (Almacén): BS-REC-54A82B94-REC (diferente, para uso interno)
```

### Estructura del Email

**Encabezado:**
- De: Brickshare <onboarding@resend.dev>
- Para: enriqueperezbcn1973+test3@gmail.com
- Asunto: Tu código QR para recoger: City In-Flight 2006 (2928)

**Hero Section:**
- Gradiente: púrpura (#667eea → #764ba2)
- Texto: "¡Tu pedido está listo para recoger! 🎉"

**Body Content:**
1. **Saludo personalizado** con nombre del usuario
2. **Confirmación del set** que está listo
3. **Caja QR Principal:**
   - Imagen QR generada desde QR Server API
   - Código alfanumérico visible (BS-DEL-54A82B94-2F1)
   - Instrucción: "Presenta este código en el punto de recogida"
4. **Información del PUDO:**
   - Nombre: Brickshare Barcelona Eixample
   - Dirección completa
   - Teléfono (si disponible)
5. **Instrucciones paso a paso:**
   - Dirigirse al punto Brickshare
   - Mostrar QR al personal
   - Escaneo para validación
   - Recogida del set
6. **Pie personalizado:** "¡Que disfrutes construyendo!"

**Footer:**
- Copyright © 2026 Brickshare
- Aviso de email automático

---

## 2. EMAIL DE DEVOLUCIÓN (Return QR)

### Detalles de Ejemplo

```
Shipment ID: 54a82b94-2f1a-4771-a8bf-7ef3e06e5d98
Set LEGO: City In-Flight 2006 (Set Ref: 2928)
Estado: in_return_pudo
QR Código Usuario: BS-RET-54A82B94-2F1
```

### Estructura del Email

**Encabezado:**
- De: Brickshare <onboarding@resend.dev>
- Para: enriqueperezbcn1973+test3@gmail.com
- Asunto: Tu código QR para devolver: City In-Flight 2006 (2928)

**Hero Section:**
- Gradiente: rosa/rojo (#f093fb → #f5576c)
- Texto: "Código QR para Devolución 📦"

**Body Content:**
1. **Saludo personalizado** con confirmación de devolución
2. **Caja QR de Devolución:**
   - Imagen QR diferente (BS-RET-54A82B94-2F1)
   - Código alfanumérico visible
   - Instrucción: "Presenta este código al entregar el set"
3. **Información del PUDO de Devolución**
4. **Instrucciones de Devolución (5 pasos):**
   - Verificar integridad del set
   - Empaquetar de forma segura
   - Dirigirse al punto Brickshare
   - Mostrar QR al personal
   - Entregar para validación
5. **Nota sobre validación:** "Una vez validada la devolución, procesaremos la finalización de tu alquiler"

**Footer:** Igual al email de entrega

---

## 3. CÓDIGOS QR

### Formato de Códigos QR

| Tipo | Formato | Uso | Usuario |
|------|---------|-----|---------|
| **Delivery QR** | BS-DEL-[TIMESTAMP]-[RANDOM] | Presentado por usuario en PUDO para recoger | ✅ Usuario |
| **Reception QR** | BS-REC-[TIMESTAMP]-[RANDOM] | Impreso en etiqueta para almacén (escaneo interno) | ❌ Solo PUDO |
| **Return QR** | BS-RET-[TIMESTAMP]-[RANDOM] | Presentado por usuario para devolver | ✅ Usuario |

### Generación de QR

**API:** https://api.qrserver.com/v1/create-qr-code/
**Parámetros:**
- size: 300x300 (pantalla), 150x150 (etiqueta)
- data: [código alfanumérico a codificar]
- Formato: data:image/png;base64 (para embeber en email)

---

## 4. ETIQUETA PUDO (Impresión Almacén)

### Especificaciones

```
Dimensiones: 10cm x 5cm (1181px x 591px @ 300dpi)
Escala de Impresión: A4 (4 etiquetas por hoja)
Contenido: QR de recepción (diferente al usuario)
```

### Contenido de la Etiqueta

```
┌─────────────────────────────────────┐
│                                     │
│     [QR CODE 3cm x 3cm]             │
│     (BS-REC-54A82B94-REC)           │
│                                     │
├─────────────────────────────────────┤
│ Entrega: Laura López Fernández      │
│ Brickshare Barcelona Eixample       │
│ Passeig de Gràcia 100               │
│ 08008 Barcelona                     │
└─────────────────────────────────────┘
```

---

## 5. FLUJO DE EMAILS

```
┌─────────────────────────────────────────┐
│    Admin ejecuta: confirm_assign_sets   │
└──────────────┬──────────────────────────┘
               │
               ├─→ Crea shipment con estado "preparation"
               │
               ├─→ Genera delivery_qr_code: BS-DEL-54A82B94-2F1
               │
               ├─→ Genera return_qr_code: BS-RET-54A82B94-2F1
               │
               └─→ Actualiza estado a "in_transit_pudo"
                  │
                  └─→ Llama Edge Function: send-brickshare-qr-email
                     │
                     ├─ type: 'delivery'
                     ├─ shipment_id: 54a82b94-2f1a-4771-a8bf-7ef3e06e5d98
                     │
                     └─→ Genera QR de recepción diferente (BS-REC-54A82B94-REC)
                        │
                        ├─ Fetch shipment, user, set, PUDO info
                        ├─ Genera QR image como base64
                        ├─ Construye HTML del email
                        ├─ Genera label HTML (10x5cm)
                        │
                        └─→ Envía email vía Resend API
                           └─ Si test: log en consola
                           └─ Si prod: email real


┌─────────────────────────────────────────┐
│   Usuario solicita devolución/retorno   │
└──────────────┬──────────────────────────┘
               │
               ├─→ Shipment status → "in_return_pudo"
               │
               └─→ Llama Edge Function: send-brickshare-qr-email
                  │
                  ├─ type: 'return'
                  ├─ shipment_id: 54a82b94-2f1a-4771-a8bf-7ef3e06e5d98
                  │
                  └─→ Envía email con return_qr_code
                     └─ Usa return_qr_code existente
```

---

## 6. EDGE FUNCTION: send-brickshare-qr-email

### Ubicación
```
supabase/functions/send-brickshare-qr-email/index.ts
Runtime: Deno
```

### Parámetros Request

```json
{
  "shipment_id": "54a82b94-2f1a-4771-a8bf-7ef3e06e5d98",
  "type": "delivery" | "return"
}
```

### Respuesta

```json
{
  "success": true,
  "message": "QR code email sent successfully",
  "email_id": "resend_email_id_here",
  "qr_code": "BS-DEL-54A82B94-2F1",
  "reception_qr_code": "BS-REC-54A82B94-REC",
  "label_html": "<!DOCTYPE html>..."
}
```

### Validaciones

- ✅ shipment_id required + exists
- ✅ type required (delivery|return)
- ✅ user_id y set_ref en shipment
- ✅ Email de usuario existe
- ✅ PUDO configurado (brickshare o correos)
- ✅ QR code exists en shipment

---

## 7. VARIABLES DE ENTORNO (Edge Function)

```bash
RESEND_API_KEY=re_test_... (o re_... para producción)
SUPABASE_URL=http://127.0.0.1:54321 (local) o URL cloud
SUPABASE_SERVICE_ROLE_KEY=...
```

---

## 8. ARCHIVOS DE PREVIEW HTML

### Generados

1. **email-preview-user3-delivery-full.html**
   - Vista completa del email de entrega
   - Incluye header, body, footer, QR
   - Datos técnicos del envío
   - Preview de etiqueta PUDO

2. **email-preview-user3-return-full.html**
   - Vista completa del email de devolución
   - Incluye datos técnicos
   - Instrucciones de devolución

### Para Abrir

```bash
# En navegador
open email-preview-user3-delivery-full.html
open email-preview-user3-return-full.html
```

---

## 9. Estilos CSS del Email

### Colores

| Elemento | Color | Uso |
|----------|-------|-----|
| Hero (Entrega) | #667eea → #764ba2 | Gradiente púrpura |
| Hero (Devolución) | #f093fb → #f5576c | Gradiente rosa/rojo |
| QR Code (Entrega) | #667eea | Texto código |
| QR Code (Devolución) | #f5576c | Texto código |
| Border (Entrega) | #667eea | Caja info |
| Border (Devolución) | #f5576c | Caja info |

### Tipografía

- **Font Stack:** -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial
- **Heading:** 28px, bold, letter-spacing -0.5px
- **Body:** 14px, line-height 1.7
- **QR Code:** 22px, monospace, letter-spacing 3px

---

## 10. Notas Técnicas Importantes

### QR Diferente para Almacén

El sistema genera **dos QR diferentes** por shipment:

1. **User QR (BS-DEL-...)**: Enviado al usuario en email, usado para recoger
2. **Reception QR (BS-REC-...)**: Impreso en etiqueta, usado por PUDO para validar recepción

Esto permite:
- ✅ Control dual (usuario + almacén)
- ✅ Auditoría de entregas/recepciones
- ✅ Prevención de fraude
- ✅ Trazabilidad completa

### Validación de PUDO

Antes de enviar email se valida:
- PUDO type (brickshare o correos)
- PUDO location data
- Usuario tiene PUDO configurado
- PUDO activo en base de datos

### Manejo de Errores

Errores comunes y soluciones:

| Error | Causa | Solución |
|-------|-------|----------|
| Shipment not found | shipment_id inválido | Verificar ID en BD |
| User not found | usuario eliminado | Recrear usuario |
| Set not found | set_ref no existe | Agregar set a catálogo |
| PUDO not found | PUDO no configurado | Asignar PUDO a usuario |
| QR code not found | delivery_qr_code/return_qr_code null | Regenerar shipment |
| Email send failed | Resend API error | Verificar API key |

---

## 11. Testing del Email

### Prueba Local

```bash
# 1. Crear shipment de prueba
cd /Users/I764690/Code_personal/Brickshare
supabase start

# 2. Llamar Edge Function
curl -X POST http://localhost:54321/functions/v1/send-brickshare-qr-email \
  -H "Authorization: Bearer $ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "shipment_id": "54a82b94-2f1a-4771-a8bf-7ef3e06e5d98",
    "type": "delivery"
  }'

# 3. Abrir preview HTML
open email-preview-user3-delivery-full.html
```

### Verificación

- ✅ Email genera correctamente (sin errores)
- ✅ QR codes válidos (escaneable)
- ✅ Datos usuario correctos (Laura López)
- ✅ PUDO info actualizada (Barcelona Eixample)
- ✅ HTML renderiza correctamente
- ✅ Etiqueta PUDO generada

---

## 12. Referencia Rápida

### Para Enviar Email de Entrega
```bash
{ "shipment_id": "uuid", "type": "delivery" }
```

### Para Enviar Email de Devolución
```bash
{ "shipment_id": "uuid", "type": "return" }
```

### Datos de User3 (Test)
```
Email: enriqueperezbcn1973+test3@gmail.com
Password: Test0test
PUDO: BS-PUDO-002 (Barcelona Eixample)
Suscripción: brick_pro
```

---

**Última actualización:** 29 de Marzo de 2026
**Versión:** 1.0
**Estado:** Producción