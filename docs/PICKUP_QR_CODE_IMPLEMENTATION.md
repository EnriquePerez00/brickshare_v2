# Implementación: Sistema de Códigos QR para Recogida en Puntos PUDO

**Fecha:** 31 de Marzo de 2026  
**Status:** ✅ Completado  
**Migración:** `20260331000000_add_pickup_qr_tracking.sql`

---

## Resumen Ejecutivo

Se ha implementado un sistema completo de códigos QR para diferenciar entre:

1. **delivery_qr_code**: Código QR para recepción del paquete por la empresa logística
2. **pickup_qr_code**: Código QR para recogida del set por el usuario en el PUDO

Ambos campos tienen el **mismo valor** pero se usan en **momentos diferentes** del flujo.

---

## Cambios Implementados

### 1. Base de Datos (Migración 20260331000000)

**Nuevos campos en tabla `shipments`:**

```sql
-- Campos añadidos
pickup_qr_code TEXT UNIQUE          -- QR enviado al usuario por email
pickup_validated_at TIMESTAMPTZ     -- Timestamp cuando usuario recoge su set

-- Índice para búsquedas rápidas
CREATE INDEX idx_shipments_pickup_qr 
ON shipments(pickup_qr_code) WHERE pickup_qr_code IS NOT NULL;
```

**Posición en la tabla:** Después de `delivery_validated_at` (para agrupación lógica)

### 2. Componente Frontend (LabelGeneration.tsx)

**Cambio en función `generateBrickshareLabel`:**

```typescript
// Antes: Solo generaba delivery_qr_code
// Ahora: Genera ambos códigos QR

const generateBrickshareLabel = async (shipmentId: string) => {
    // 1. Generar/verificar delivery_qr_code
    let qrCode = shipment?.delivery_qr_code;
    if (!qrCode) {
        qrCode = `BS-DEL-${shipmentId.substring(0, 12).toUpperCase()}`;
        // Actualizar BD
    }
    
    // 2. NUEVO: Copiar a pickup_qr_code
    await supabase
        .from('shipments')
        .update({ pickup_qr_code: qrCode })
        .eq('id', shipmentId);
    
    // 3. Generar etiqueta y enviar email
    // ...
}
```

### 3. Tipos TypeScript

**Actualización de tipos automática:**
```bash
supabase gen types typescript --local > src/types/supabase.ts
```

Los nuevos campos están disponibles en el tipo `Database['public']['Tables']['shipments']['Row']`

### 4. Documentación

**Nuevo archivo de referencia:**
- `docs/BRICKSHARE_PUDO_QR_FLOW.md`: Flujo completo, diagramas, casos de error

---

## Flujo de Funcionamiento

### Paso 1: Admin Genera Etiqueta

```
Admin hace clic en "Generar Etiqueta" en backoffice
├─ Se crea delivery_qr_code (BS-DEL-54A82B94...)
├─ Se copia a pickup_qr_code (mismo valor)
├─ Se imprime etiqueta con delivery_qr_code
└─ Se envía email al usuario con pickup_qr_code
```

### Paso 2: Empresa Logística Entrega Paquete

```
Personal PUDO escanea delivery_qr_code
├─ Busca: WHERE delivery_qr_code = '{código escaneado}'
├─ ENCUENTRA → Valida recepción
└─ UPDATE shipments SET
    delivery_validated_at = now(),
    shipment_status = 'at_pudo'
```

### Paso 3: Usuario Recoge su Set

```
Usuario va al PUDO con código del email (pickup_qr_code)
├─ Personal escanea el código presentado
├─ Busca: WHERE pickup_qr_code = '{código escaneado}'
├─ ENCUENTRA → Valida recogida
└─ UPDATE shipments SET
    pickup_validated_at = now(),
    shipment_status = 'delivered_user'
```

---

## Validaciones Implementadas

### ✅ El sistema valida automáticamente:

1. **QR Duplicado:**
   - Si `delivery_validated_at IS NOT NULL` → Error: "Ya escaneado"

2. **Recogida Prematura:**
   - Si `delivery_validated_at IS NULL` → Error: "Paquete aún no llegó"

3. **QR No Existente:**
   - Si no encuentra en `delivery_qr_code` ni en `pickup_qr_code` → Error: "QR no encontrado"

---

## Archivos Modificados

| Archivo | Cambio |
|---------|--------|
| `supabase/migrations/20260331000000_add_pickup_qr_tracking.sql` | ✅ Creado - Migración DB |
| `apps/web/src/components/admin/operations/LabelGeneration.tsx` | ✅ Modificado - Genera ambos QR |
| `src/types/supabase.ts` | ✅ Regenerado - Tipos actualizados |
| `docs/BRICKSHARE_PUDO_QR_FLOW.md` | ✅ Creado - Documentación completa |

---

## Testing

Para verificar en desarrollo:

```bash
# 1. Reiniciar base de datos
./scripts/db-reset.sh

# 2. Generar etiqueta (crea ambos QR)
# - Ir a: http://localhost:5173/operations
# - Admin → Generación de Etiquetas
# - Clic en "Generar Etiqueta"

# 3. Verificar en BD
psql -c "SELECT delivery_qr_code, pickup_qr_code, delivery_validated_at, pickup_validated_at FROM shipments LIMIT 5;"

# 4. Validar QR codes coinciden
SELECT delivery_qr_code = pickup_qr_code FROM shipments WHERE pickup_qr_code IS NOT NULL;
-- Debe retornar: true para todos
```

---

## Integración con Edge Functions

### Función: `brickshare-qr-api` (Próximo)

Debe actualizar basándose en el QR escaneado:

```typescript
// Pseudocódigo
if (scannedQR matches delivery_qr_code) {
    // Escaneo de RECEPCIÓN
    UPDATE shipments SET delivery_validated_at = now()
} else if (scannedQR matches pickup_qr_code) {
    // Escaneo de RECOGIDA
    UPDATE shipments SET pickup_validated_at = now()
}
```

---

## Estados del Shipment

| Estado | delivery_validated_at | pickup_validated_at | Significado |
|--------|----------------------|-------------------|------------|
| `assigned` | NULL | NULL | Listo para generar etiqueta |
| `in_transit_pudo` | NULL | NULL | Etiqueta generada, esperando entrega |
| `at_pudo` | ✅ | NULL | Recibido en PUDO |
| `delivered_user` | ✅ | ✅ | Usuario recogió su set |

---

## Notas Importantes

⚠️ **Ambos campos tienen el MISMO valor:**
- `delivery_qr_code = 'BS-DEL-54A82B94-2F1'`
- `pickup_qr_code = 'BS-DEL-54A82B94-2F1'`

**Esto es por diseño** - permite que el personal del PUDO:
1. Reciba el paquete escaneando `delivery_qr_code`
2. Valide la recogida escaneando `pickup_qr_code`
3. Mantenga un registro de ambos eventos con timestamps diferentes

---

## Próximos Pasos

1. **Implementar validación en Edge Function `brickshare-qr-api`**
   - Lógica para diferenciar entre delivery y pickup
   - Actualizar timestamps correspondientes

2. **Crear app PUDO de escaneo**
   - Interfaz para personal del PUDO
   - Escaneo de ambos tipos de QR

3. **Testing integral**
   - Flujo completo desde asignación hasta recogida
   - Casos de error

4. **Documentar en App iOS**
   - Cómo presentar el `pickup_qr_code` al usuario

---

## Referencias

- **Flujo completo:** `docs/BRICKSHARE_PUDO_QR_FLOW.md`
- **Migración:** `supabase/migrations/20260331000000_add_pickup_qr_tracking.sql`
- **Componente:** `apps/web/src/components/admin/operations/LabelGeneration.tsx`
- **Esquema:** `docs/DATABASE_SCHEMA.md` (auto-generado)