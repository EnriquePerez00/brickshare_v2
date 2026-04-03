# Migración del Sistema de Códigos QR - 2026-03-04

## ⚠️ Cambio Crítico

**Sistema Anterior (DEPRECADO)**:
- ❌ `BS-DEL-` → QR enviado al usuario
- ❌ `BS-REC-` → QR temporal de recepción (no almacenado en BD)

**Sistema Actual (CORRECTO)**:
- ✅ `BS-DEL-` → QR impreso en **etiqueta física** para PUDO
- ✅ `BS-PCK-` → QR enviado al **email del usuario** para recoger
- ✅ `BS-RET-` → QR enviado al **email del usuario** para devolver

---

## Resumen de Cambios

### 1. Eliminado `BS-REC-`

El código `BS-REC-` generaba confusión porque:
- Era temporal y aleatorio (no relacionado con el shipment)
- No se almacenaba en la base de datos
- Su función ahora la cumple `BS-DEL-`

### 2. Nuevo Propósito de `BS-DEL-`

**Antes**: Email al usuario
**Ahora**: Etiqueta física impresa que viaja con el paquete

El personal del PUDO escanea `BS-DEL-` cuando el paquete **llega** al punto de recogida.

### 3. Nuevo Código `BS-PCK-`

**Nuevo**: Email al usuario para recoger el set

El usuario presenta `BS-PCK-` en el PUDO para **recoger** su set LEGO.

### 4. Mantenido `BS-RET-`

Sin cambios. Se usa para devoluciones.

---

## Campos en Base de Datos

```sql
-- Tabla: shipments
delivery_qr_code TEXT,  -- BS-DEL-xxx (etiqueta física)
pickup_qr_code TEXT,    -- BS-PCK-xxx (email usuario)  
return_qr_code TEXT     -- BS-RET-xxx (email devolución)
```

**Eliminado**: Ningún campo `reception_qr_code` (nunca existió en BD)

---

## Flujo Correcto

```
1. Admin genera etiqueta
   ├─→ delivery_qr_code = BS-DEL-4BCD6EB3-C99  (etiqueta física)
   └─→ pickup_qr_code = BS-PCK-4BCD6EB3-C99    (email usuario)

2. Paquete llega a PUDO
   └─→ Personal escanea BS-DEL-xxx de la etiqueta

3. Usuario recoge set
   └─→ Usuario muestra BS-PCK-xxx de su email

4. Usuario solicita devolución
   └─→ return_qr_code = BS-RET-4BCD6EB3-C99    (email usuario)
```

---

## Archivos Actualizados

### Código
- ✅ `supabase/functions/send-brickshare-qr-email/index.ts`
  - Eliminada función `generateReceptionQRCode()`
  - Ahora genera `BS-DEL-` y `BS-PCK-` correctamente
  - Email muestra `BS-PCK-`, etiqueta muestra `BS-DEL-`

### Documentación Actualizada
- ✅ `docs/QR_CODES_SPECIFICATION.md` (NUEVO - Documento principal)
- ✅ `docs/QR_CODES_DUAL_SYSTEM.md` (Reescrito completamente)
- ⚠️ `docs/BRICKSHARE_PUDO_LABEL_GENERATION.md` (Necesita actualización)
- ⚠️ `docs/EMAIL_FORMAT_USER3_DELIVERY_RETURN.md` (Necesita actualización)
- ⚠️ `docs/PUDO_LABEL_SPECIFICATIONS.md` (Necesita actualización)

### Documentación Pendiente (Contienen referencias a BS-REC)
Los siguientes documentos mencionan `BS-REC-` y deberían actualizarse cuando sea necesario:
- `docs/QR_CODE_FORMAT_SPECIFICATION.md`
- `docs/QR_CODE_PREFIX_IMPLEMENTATION_SUMMARY.md`
- `docs/QR_CODE_IMPLEMENTATION_VISUAL_GUIDE.md`
- `docs/QR_CODE_IMPLEMENTATION_FINAL_SUMMARY.md`
- `docs/BRICKSHARE_PUDO_QR_API.md`
- `docs/PICKUP_QR_CODE_IMPLEMENTATION.md`

---

## Impacto en Operaciones

### Para Admins
- ✅ Generar etiqueta funciona igual
- ✅ La etiqueta ahora muestra el QR correcto (`BS-DEL-`)
- ✅ El email al usuario muestra el QR correcto (`BS-PCK-`)

### Para Personal PUDO
- ✅ Al recibir paquete: Escanean `BS-DEL-` de la etiqueta
- ✅ Al entregar a cliente: Escanean `BS-PCK-` del móvil del cliente
- ✅ Al recibir devolución: Escanean `BS-RET-` del móvil del cliente

### Para Usuarios
- ✅ Reciben email con `BS-PCK-` para recoger
- ✅ Reciben email con `BS-RET-` para devolver
- ℹ️ No ven nunca `BS-DEL-` (está en la etiqueta del paquete)

---

## Verificación

### ✅ Código Correcto
```typescript
// send-brickshare-qr-email/index.ts

// Email de entrega (type='delivery')
deliveryQR = generateQRCode(shipment_id, 'DEL');  // Para etiqueta
pickupQR = generateQRCode(shipment_id, 'PCK');    // Para email

// Email muestra BS-PCK-xxx
qrCode = pickupQR;

// Etiqueta muestra BS-DEL-xxx
labelHTML = `...${deliveryQR}...`;
```

### ❌ Código Incorrecto (Eliminado)
```typescript
// ❌ ELIMINADO - No usar
receptionQRCode = await generateReceptionQRCode(shipment_id);
// ❌ Generaba BS-REC-xxx aleatorio
```

---

## Checklist de Migración

- [x] Actualizar Edge Function `send-brickshare-qr-email`
- [x] Eliminar función `generateReceptionQRCode()`
- [x] Crear `docs/QR_CODES_SPECIFICATION.md`
- [x] Actualizar `docs/QR_CODES_DUAL_SYSTEM.md`
- [ ] Actualizar `docs/BRICKSHARE_PUDO_LABEL_GENERATION.md`
- [ ] Actualizar `docs/EMAIL_FORMAT_USER3_DELIVERY_RETURN.md`
- [ ] Actualizar `docs/PUDO_LABEL_SPECIFICATIONS.md`
- [ ] Probar flujo completo con nuevo sistema
- [ ] Actualizar documentos adicionales según necesidad

---

## Referencias

**Documentos Principales**:
- [QR Codes Specification](./QR_CODES_SPECIFICATION.md) ← **Leer primero**
- [QR Codes Triple System](./QR_CODES_DUAL_SYSTEM.md)

**Código**:
- `supabase/functions/send-brickshare-qr-email/index.ts`
- `supabase/functions/request-return/index.ts`
- `supabase/functions/brickshare-qr-api/index.ts`

**Base de Datos**:
- Tabla `shipments`: `delivery_qr_code`, `pickup_qr_code`, `return_qr_code`

---

## Preguntas Frecuentes

### ¿Por qué se eliminó BS-REC-?
Era redundante. Su función (validar recepción en PUDO) ahora la cumple `BS-DEL-` que además se almacena en BD y es determinístico.

### ¿Qué QR muestra la etiqueta impresa?
`BS-DEL-xxx` - El personal del PUDO lo escanea cuando llega el paquete.

### ¿Qué QR recibe el usuario por email?
`BS-PCK-xxx` - El usuario lo muestra para recoger su set.

### ¿Los tres QR son iguales excepto el prefijo?
Sí, todos usan los primeros 12 caracteres del UUID del shipment:
- `BS-DEL-4BCD6EB3-C99`
- `BS-PCK-4BCD6EB3-C99`
- `BS-RET-4BCD6EB3-C99`

### ¿Qué pasa con los envíos antiguos con BS-REC?
No hay envíos con `BS-REC-` en BD porque nunca se almacenó. Era temporal solo para la sesión de generación de etiqueta.

---

**Última actualización**: 2026-03-04  
**Autor**: Sistema de documentación automática  
**Versión**: 1.0.0