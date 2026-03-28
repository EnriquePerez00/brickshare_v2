# Estado: Sistema de Generación de QR para PUDO Brickshare

**Fecha**: 27/3/2026
**Estado**: ✅ Base de datos actualizada y lista para implementación

## Resumen de Cambios

Se han aplicado exitosamente las migraciones para preparar la infraestructura de base de datos para generar **dos códigos QR** cuando se genera una etiqueta de envío a un PUDO de Brickshare:

1. **QR para Usuario** - Se genera y envía por email (existente)
2. **QR para PUDO** - Se genera, almacena en BD y se prepara para impresión local

## Migraciones Aplicadas

### 1. `20260327150000_fix_pudo_ids_format.sql`
- Normaliza los IDs de PUDO al formato `brickshare-XXX`
- Actualiza datos existentes en tablas relacionadas
- Elimina datos con formato antiguo

### 2. `20260327151934_fix_pudo_ids_format.sql`
- Migración complementaria de normalización

### 3. `20260327160000_populate_brickshare_pudo_id_in_shipments.sql`
- Asegura que todos los shipments con `pudo_type = 'brickshare'` tengan `brickshare_pudo_id` poblado

## Cambios en Base de Datos

### Columna Agregada en `shipments`
```sql
ALTER TABLE shipments ADD COLUMN pudo_reception_qr_code TEXT;
```

**Tipo**: TEXT  
**Nullable**: TRUE  
**Propósito**: Almacenar el código QR generado para validación de recepción en el punto PUDO

**Almacena**: Datos del código QR (URL o imagen base64) para escaneo móvil por personal de PUDO

## Tipos TypeScript Regenerados

Los tipos en `src/types/supabase.ts` han sido actualizados para incluir:
```typescript
pudo_reception_qr_code?: string | null;  // En tabla Shipments
```

## Próximos Pasos para Implementación

### 1. **Edge Function: `generate-label-with-pudo-qr`**
   - Generar dos QR códigos usando biblioteca `qrcode`
   - QR Usuario: contiene código de tracking + ID shipment
   - QR PUDO: contiene shipment_id + metadata para recepción

### 2. **Formato de Etiqueta PUDO (10cm x 5cm)**
   Datos a incluir:
   ```
   ┌─────────────────────────────┐
   │ [QR CODE - 3cm x 3cm]       │  <- QR de recepción PUDO
   │                              │
   ├─────────────────────────────┤
   │ ENTREGA: Nombre Apellido     │
   │ Establecimiento: Brickshare  │
   │ Dirección: [address]         │
   │ Ciudad: [city], [postal]     │
   └─────────────────────────────┘
   ```

### 3. **Implementación en Frontend**
   - Modificar `LabelGeneration.tsx` para:
     - Generar segundo QR para PUDO
     - Guardar en BD con `UPDATE shipments SET pudo_reception_qr_code = ...`
     - Mostrar opción de "Imprimir etiqueta PUDO" (10x5cm)
   
### 4. **Servicio de Impresión Local (Desarrollo)**
   - Usar librería `react-to-print` o similar
   - Template HTML para formato 10x5cm
   - En producción: integración con API de impresora térmica

### 5. **Email a PUDO**
   - Enviar email al `contact_email` del PUDO
   - Incluir QR de recepción como attachment
   - Datos del shipment (usuario, set, tracking)

## Base de Datos - Estado de Tablas Clave

### `shipments`
- ✅ Columna `pudo_reception_qr_code` agregada
- ✅ Todos los envíos a Brickshare PUDO normalizados

### `brickshare_pudo_locations`
- ✅ IDs en formato `brickshare-XXX`
- ✅ Datos de contacto disponibles
- ✅ 2 ubicaciones de prueba (Madrid, Barcelona)

### `users`
- ✅ `pudo_id` y `pudo_type` sincronizados
- ✅ Referencia correcta a ubicación PUDO

## Verificación de Migraciones

```bash
# Ver estado
supabase status

# Aplicar migraciones (si es necesario)
supabase migration up

# Regenerar tipos
supabase gen types typescript --local > src/types/supabase.ts
```

## Variables de Entorno Necesarias (Futura)

Para la Edge Function de generación de QR:
```env
QRCODE_VERSION=latest  # Si se usa librería externa
PRINTER_ENABLED=false  # En desarrollo
```

## Notas Importantes

1. **QR PUDO vs QR Usuario**: Son códigos diferentes con datos distintos
2. **Almacenamiento**: El QR PUDO se guarda en BD para auditoría y reimpresión
3. **Impresión Local**: En desarrollo no imprime, solo muestra preview
4. **Formato**: 10cm x 5cm permite código QR legible + datos legibles

## Documentación Asociada

- `docs/LABEL_GENERATION_FEATURE.md` - Generación de etiquetas (usuario QR)
- `docs/BRICKSHARE_PUDO_QR_API.md` - Especificación de QR API
- `docs/BRICKSHARE_LOGISTICS_INTEGRATION.md` - Integración logística completa

