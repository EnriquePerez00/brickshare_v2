# Sistema de Generación de Etiquetas para PUDO Brickshare

**Fecha**: 28/3/2026  
**Versión**: 1.0.0  
**Estado**: ✅ Implementado

## 📋 Resumen

Sistema mejorado para generar etiquetas físicas (10cm x 5cm) para envíos a puntos PUDO Brickshare. Las etiquetas se usan en el almacén para identificar paquetes destinados a recepción en puntos PUDO.

### Cambios Principales

1. **QR Dual**: Generación de dos códigos QR independientes
   - **QR Usuario** (`delivery_qr_code`): Enviado al cliente para recogida
   - **QR Recepción** (nuevo): Generado para personal de almacén/PUDO

2. **Etiqueta HTML 10x5cm**: Template optimizado para impresión
   - Código QR recepción (3cm x 3cm)
   - Nombre del usuario
   - Nombre del establecimiento PUDO
   - Dirección completa del PUDO

3. **Sin Datos Personales Sensibles**: La etiqueta NO incluye
   - Email del usuario
   - Teléfono del usuario
   - Información de pago
   - Detalles del set LEGO
   - Precio de suscripción

---

## 🏗️ Arquitectura

### Flujo de Generación

```
Admin → "Generar Etiqueta" (Brickshare)
   ↓
Frontend: LabelGeneration.tsx
   ├─ Verifica QR usuario existe
   ├─ Llama send-brickshare-qr-email (type='delivery')
   │
   ↓
Edge Function: send-brickshare-qr-email
   ├─ Genera QR usuario (delivery) → Envía email al cliente
   ├─ Genera QR recepción (independiente) → Para almacén
   ├─ Genera HTML etiqueta (10x5cm)
   └─ Retorna:
      ├─ email_id
      ├─ qr_code (usuario)
      ├─ reception_qr_code (almacén) 🆕
      └─ label_html (etiqueta para imprimir) 🆕
   ↓
Frontend: Abre ventana de impresión
   ├─ Muestra preview etiqueta
   ├─ Usuario selecciona impresora
   └─ Imprime etiqueta 10x5cm
```

---

## 📊 Especificaciones Técnicas

### Códigos QR

#### QR Usuario (Entrega)
- **Formato**: `BS-DEL-XXXXXXXXXXXXXXXX`
- **Contenido**: Identificador único de entrega
- **Uso**: Cliente presenta en punto PUDO para recogida
- **Expiración**: 30 días
- **Base de Datos**: Tabla `shipments`, columna `delivery_qr_code`

#### QR Recepción (Almacén) 🆕
- **Formato**: `BS-REC-XXXXXX-XXXXXX` (timestamp + random)
- **Contenido**: Identificador único de recepción
- **Uso**: Personal almacén/PUDO escanea al recibir paquete
- **Temporal**: Solo en sesión (no se almacena)
- **Generación**: Cada vez que se genera la etiqueta

### Etiqueta Física

**Dimensiones**: 10cm × 5cm (formato thermal label)

**Componentes**:
1. **QR Code** (3cm × 3cm)
   - Código QR de recepción
   - Escaneable por dispositivo móvil
   - Posicionado en la sección superior

2. **Datos Texto**:
   - **Nombre Usuario**: "Entrega: Juan Pérez" (9pt, bold)
   - **Nombre PUDO**: "Brickshare Madrid Centro" (8pt, bold)
   - **Dirección PUDO**: "Calle Gran Vía 28 - 28013 Madrid" (7pt)

**CSS Print Optimizado**:
- Sin márgenes innecesarios
- Border para referencia de corte
- Fuentes legibles incluso en baja resolución

---

## 🔧 Implementación Técnica

### Edge Function: `send-brickshare-qr-email`

#### Cambios Realizados

1. **Función Nueva**: `generateReceptionQRCode(shipmentId: string): Promise<string>`
   ```typescript
   // Genera código QR de recepción DIFERENTE al del usuario
   // Formato: BS-REC-<timestamp>-<random>
   ```

2. **Para Delivery** (type='delivery'):
   - Genera QR usuario (ya existía)
   - Genera QR recepción 🆕
   - Genera imagen QR para cada uno
   - Crea HTML etiqueta con QR recepción 🆕

3. **Respuesta JSON**:
   ```json
   {
     "success": true,
     "message": "QR code email sent successfully",
     "email_id": "string",
     "qr_code": "BS-DEL-XXXXXXXXXXXXXXXX",
     "reception_qr_code": "BS-REC-XXXXXX-XXXXXX",
     "label_html": "<html>...</html>"
   }
   ```

### Frontend: `LabelGeneration.tsx`

#### Cambios Realizados

1. **Nueva Función**: `openLabelPrintWindow(shipmentId, labelHTML)`
   - Abre ventana emergente con etiqueta
   - Dispara diálogo de impresión automáticamente
   - Ajustado para impresoras térmicas 10x5cm

2. **Integración en `generateBrickshareLabel()`**:
   ```typescript
   // Después de enviar email al usuario:
   if (data?.label_html) {
     sessionStorage.setItem(`label-${shipmentId}`, data.label_html);
     setTimeout(() => {
       openLabelPrintWindow(shipmentId, data.label_html);
     }, 500);
   }
   ```

3. **Flujo Mejorado**:
   - ✅ Email QR enviado al usuario
   - ✅ Toast confirma envío
   - ✅ Ventana de impresión abre automáticamente
   - ✅ Admin puede imprimir etiqueta para almacén

---

## 📱 Guía de Uso

### Para Admin (Generación)

1. **En Operaciones** → "Generación de Etiquetas"
2. Selecciona envío Brickshare PUDO pendiente
3. Haz clic en "Generar Etiqueta"
4. Sistema:
   - ✅ Envía email QR al usuario
   - ✅ Abre ventana de impresión
5. **Selecciona impresora térmica** (10x5cm)
6. **Imprime etiqueta**
7. **Pega en paquete** antes de enviar a PUDO

### Para Personal PUDO (Recepción)

1. **Recibe paquete con etiqueta**
2. **Abre app móvil** Brickshare_logistics
3. **Escanea QR de recepción** (BS-REC-...)
4. Sistema valida y confirma recepción
5. **Almacena paquete** en ubicación asignada

### Para Cliente (Recogida)

1. **Recibe email** con QR de entrega (BS-DEL-...)
2. **Presenta QR en punto PUDO**
3. Personal escanea → Valida recogida
4. **Recibe set LEGO**

---

## 🗄️ Base de Datos

### Cambios BD

**NO se requieren migraciones nuevas**. El sistema usa:
- `shipments.delivery_qr_code` (existente)
- QR de recepción NO se almacena en BD (es temporal)

### Campos Utilizados

```sql
-- Tabla: shipments
delivery_qr_code TEXT          -- QR usuario (ya existe)
user_id UUID                   -- Enlace usuario
brickshare_pudo_id TEXT        -- Enlace PUDO
pudo_type TEXT                 -- 'brickshare' | 'correos'

-- Tabla: brickshare_pudo_locations
id TEXT                        -- ID PUDO
name TEXT                      -- Nombre establecimiento
address TEXT                   -- Dirección
city TEXT                      -- Ciudad
postal_code TEXT               -- Código postal
contact_email TEXT             -- Email PUDO
```

---

## 🖨️ Especificaciones de Impresión

### Hardware Recomendado

- **Impresora**: Térmica o laser 10x5cm
- **Etiquetas**: Térmica compatible 10x5cm
- **Resolución**: 300 DPI mínimo
- **Soporte**: Windows, Mac, Linux

### Configuración Recomendada

1. **Márgenes**: 0mm (sin márgenes)
2. **Escala**: 100% (sin zoom)
3. **Orientación**: Horizontal
4. **Papel**: Custom 10cm × 5cm
5. **Copias**: 1 (o más según necesidad)

### Pasos de Impresión

```
1. Haz clic "Generar Etiqueta"
   ↓
2. Se abre ventana de impresión
   ↓
3. Selecciona impresora térmica
   ↓
4. Verifica vista previa (10x5cm)
   ↓
5. Haz clic "Imprimir"
   ↓
6. Espera a que salga la etiqueta
   ↓
7. Pega en paquete antes de envío
```

---

## 🔐 Seguridad

### Datos en Etiqueta (SÍ)
- QR de recepción (BS-REC-...)
- Nombre usuario (nombre + apellidos)
- Nombre PUDO (público)
- Dirección PUDO (pública)

### Datos NO en Etiqueta (✓)
- Email usuario
- Teléfono usuario
- Información de pago
- Datos bancarios
- Dirección personal usuario
- Precio/suscripción
- Detalles set LEGO

### Variables de Entorno

No se requieren nuevas variables. Usa:
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `RESEND_API_KEY` (para email)

---

## 📚 Integración con Otros Sistemas

### Brickshare_logistics (App Móvil)

El QR recepción `BS-REC-XXXXXX-XXXXXX` puede ser validado por:

1. **App móvil** (escaneo QR)
2. **API brickshare-qr-api** (si existe)
3. **Manual** si es necesario

### Correos vs Brickshare

| Aspecto | Correos | Brickshare |
|---------|---------|-----------|
| Etiqueta | PDF Correos | HTML 10x5cm |
| QR Usuario | Tracking Correos | BS-DEL-... |
| QR Recepción | No | BS-REC-... |
| Impresión | Desde Edge Func | Desde Frontend |
| Almacenamiento BD | Sí | No (temporal) |

---

## 🧪 Testing

### Verificación Manual

```typescript
// 1. Generar etiqueta desde UI
// 2. Verificar email recibido (usuario)
// 3. Verificar ventana de impresión abierta
// 4. Verificar preview muestra:
//    - QR de recepción
//    - Nombre usuario
//    - PUDO info
//    - Tamaño 10x5cm

// 5. Imprime en papel
// 6. Verifica código legible
```

### Logs a Verificar

```bash
# En consola navegador:
- "Email con QR enviado al usuario"
- Ventana print abierta automáticamente

# En consola Supabase:
- send-brickshare-qr-email completado
- Respuesta contiene reception_qr_code
- Respuesta contiene label_html
```

---

## 🐛 Troubleshooting

| Problema | Causa | Solución |
|----------|-------|----------|
| No abre ventana print | Bloqueador popup | Permitir popups para Brickshare |
| Etiqueta ve pequeña | Zoom navegador | Establece zoom 100% |
| QR no legible | Baja resolución | Usa impresora 300 DPI mínimo |
| Email no llega | RESEND_API_KEY | Verifica API key en .env |
| HTML malformado | Error servidor | Revisa logs Edge Function |

---

## 📊 Diferencias vs Implementación Anterior

### Antes (Solo Email)
- ✅ QR enviado al usuario por email
- ❌ No había etiqueta para almacén
- ❌ No se diferenciaban QR (usuario vs recepción)
- ❌ Admin no podía imprimir fácilmente

### Ahora (Email + Etiqueta)
- ✅ QR usuario enviado por email
- ✅ **Etiqueta física para almacén**
- ✅ **QR recepción independiente**
- ✅ **Admin imprime etiqueta directamente**
- ✅ Workflow completo almacén→PUDO→cliente

---

## 📝 Próximas Mejoras Potenciales

1. **Almacenar QR Recepción**: Guardar en BD para auditoría
2. **Integración Impresora**: API para impresoras térmicas
3. **Batch Print**: Imprimir múltiples etiquetas a la vez
4. **Codes128/Ean**: Añadir código barras numérico
5. **Multiidioma**: Etiqueta en diferentes idiomas
6. **Logística API**: Auto-generar etiquetas por API

---

## 📞 Soporte

**Para problemas o preguntas:**
- Consultar esta documentación
- Revisar `LABEL_GENERATION_RESEND_FIX.md`
- Revisar `BRICKSHARE_PUDO.md`
- Verificar logs en Supabase Dashboard

---

**Versión**: 1.0.0  
**Última actualización**: 28/3/2026  
**Estado**: ✅ Producción Ready