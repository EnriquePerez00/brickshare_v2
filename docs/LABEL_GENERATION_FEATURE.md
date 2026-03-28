# Sección de Generación de Etiquetas - Panel de Operaciones

## 📋 Resumen

Se ha implementado una nueva sección "Etiquetas" en el Panel de Operaciones que permite procesar envíos pendientes, generando etiquetas de envío y notificando a los usuarios.

## 🎯 Ubicación

**Ruta**: Panel de Operaciones → Tab "Etiquetas" (entre "Asignación sets" y "Envíos")

**URL**: `/operations` (requiere rol `admin` o `operador`)

## ✨ Características Implementadas

### 1. Vista de Envíos Pendientes

- **Filtro automático**: Muestra solo shipments con estado `"assigned"`
- **Información mostrada**:
  - Usuario (nombre + email)
  - Set asignado (nombre + ref)
  - Tipo de PUDO (Correos/Brickshare)
  - QR/Código existente
  - Botón de acción individual

### 2. Generación Individual de Etiquetas

Botón "Generar Etiqueta" para cada shipment que ejecuta:

#### Para **Correos PUDO**:
1. ✅ Preregistro con Correos API (si no está hecho)
2. ✅ Obtención de etiqueta PDF
3. ✅ Apertura del PDF en nueva ventana (impresión manual)
4. ✅ Actualización de estado a `"in_transit_pudo"`

#### Para **Brickshare PUDO**:
1. ✅ Envío de email con código QR al usuario
2. ✅ Actualización de estado a `"in_transit_pudo"`

### 3. Generación Masiva de Etiquetas

Botón "Generar Todas las Etiquetas" que:
- ✅ Procesa todos los shipments pendientes secuencialmente
- ✅ Maneja errores individuales sin detener el proceso completo
- ✅ Muestra resumen de éxitos y fallos al finalizar

### 4. Impresión Automática (Configurada pero Deshabilitada)

```typescript
// Print service helper - configured but not operational yet
const printLabelPDF = async (url: string, autoPrint: boolean = false) => {
    if (!autoPrint) {
        // Manual mode: open in new window
        window.open(url, '_blank');
        return;
    }

    // Auto-print mode (configured but disabled)
    // TODO: Enable when print infrastructure is ready
    console.log('[Auto-print] Would print:', url);
    
    // Future implementation:
    // const iframe = document.createElement('iframe');
    // iframe.style.display = 'none';
    // iframe.src = url;
    // document.body.appendChild(iframe);
    // iframe.onload = () => {
    //     iframe.contentWindow?.print();
    //     setTimeout(() => document.body.removeChild(iframe), 1000);
    // };
    
    // For now, fall back to manual
    window.open(url, '_blank');
};
```

**Para activar la impresión automática**:
1. Cambiar `autoPrint: false` a `autoPrint: true` en la línea 127 de `LabelGeneration.tsx`
2. Descomentar el código del iframe
3. Probar en diferentes navegadores (puede requerir permisos del usuario)

## 🔄 Flujo Completo del Proceso

```
Usuario Admin/Operador accede a Panel de Operaciones → Tab "Etiquetas"
    ↓
Sistema muestra shipments con estado "assigned"
    ↓
Operador hace clic en "Generar Etiqueta" (individual o todas)
    ↓
┌─────────────────────────────────────────┐
│ Para cada shipment:                     │
│                                         │
│ Si pudo_type = 'correos':              │
│   1. Preregistro en Correos API        │
│   2. Obtención de etiqueta PDF         │
│   3. Apertura del PDF (manual print)   │
│                                         │
│ Si pudo_type = 'brickshare':           │
│   1. Envío de email con QR             │
│                                         │
│ 4. Actualizar shipment_status →        │
│    'in_transit_pudo'                   │
└─────────────────────────────────────────┘
    ↓
Sistema invalida queries y actualiza vista
    ↓
Shipment desaparece de la lista de pendientes
```

## 📁 Archivos Creados/Modificados

### Nuevos Archivos
- ✅ `apps/web/src/components/admin/operations/LabelGeneration.tsx` (componente principal)

### Archivos Modificados
- ✅ `apps/web/src/pages/Operations.tsx` (añadido tab "Etiquetas")

## 🔌 Edge Functions Utilizadas

### 1. `correos-logistics`
**Acciones utilizadas**:
- `preregister`: Preregistro del envío en Correos
- `get_label`: Obtención del PDF de la etiqueta

**Request**:
```typescript
await supabase.functions.invoke('correos-logistics', {
    body: {
        action: 'preregister' | 'get_label',
        p_shipment_id: string
    }
});
```

### 2. `send-brickshare-qr-email`
**Request**:
```typescript
await supabase.functions.invoke('send-brickshare-qr-email', {
    body: {
        shipment_id: string,
        type: 'delivery'
    }
});
```

## 📊 Estados del Shipment

| Estado Antes | Estado Después | Visible en Etiquetas |
|--------------|----------------|---------------------|
| `assigned` | `in_transit_pudo` | ✅ Sí |
| `pending` | - | ❌ No (estado deprecado) |
| `in_transit_pudo` | - | ❌ No |
| `delivered_pudo` | - | ❌ No |

## 🎨 UI/UX

### Badges de Tipo PUDO
- **Correos**: Badge amarillo
- **Brickshare**: Badge morado

### Estados de Carga
- ✅ Spinner durante generación individual
- ✅ Botón deshabilitado durante proceso masivo
- ✅ Mensajes toast informativos

### Información Contextual
Banner informativo con:
- Explicación del proceso para Correos PUDO
- Explicación del proceso para Brickshare PUDO
- Estado de impresión automática (deshabilitada)

## 🔒 Permisos

**Roles permitidos**:
- ✅ `admin`
- ✅ `operador`

**Verificación**: Se realiza en `Operations.tsx` mediante `useAuth()` hook.

## 🧪 Testing Recomendado

### Test Manual
1. Crear un shipment con estado `"assigned"` y `pudo_type='correos'`
2. Crear un shipment con estado `"assigned"` y `pudo_type='brickshare'`
3. Acceder al Panel de Operaciones → Etiquetas
4. Verificar que ambos shipments aparecen
5. Generar etiqueta individual para Correos → verificar PDF
6. Generar etiqueta individual para Brickshare → verificar email
7. Verificar que ambos desaparecen de la lista
8. Verificar en tab "Envíos" que están con estado `"in_transit_pudo"`

### Test Automático (TODO)
```typescript
// apps/web/src/__tests__/integration/operator-flows/label-generation.integration.test.ts
describe('Label Generation Flow', () => {
    it('should generate Correos label and update status', async () => {
        // Test implementation
    });

    it('should generate Brickshare QR email and update status', async () => {
        // Test implementation
    });

    it('should handle batch generation with mixed PUDO types', async () => {
        // Test implementation
    });
});
```

## 🚨 Manejo de Errores

### Errores Individuales
- Se muestran con toast error específico por usuario
- No detienen el proceso masivo
- Se registran en consola para debugging

### Errores de Correos API
- Mostrados con detalles del error
- Shipment permanece en estado `"assigned"`
- Permite reintentar manualmente

### Errores de Email
- Mostrados con mensaje de error
- Shipment permanece en estado `"pending"`
- Permite reintentar manualmente

## 📝 Notas Importantes

1. **QR Codes Pre-generados**: Los QR codes de Brickshare se generan al confirmar la asignación, no en esta etapa.

2. **Correos Shipment ID**: Se genera durante el preregistro, no antes.

3. **Invalidación de Cache**: Se invalidan las queries `["pending-shipments"]` y `["admin-shipments"]` tras cada operación exitosa.

4. **Estado del Shipment**: El cambio a `"in_transit_pudo"` indica que el envío está en camino al PUDO, no que ha llegado.

## 🔮 Futuras Mejoras

- [ ] Activar impresión automática de PDFs
- [ ] Añadir preview del QR antes de enviar email
- [ ] Implementar reintento automático en caso de error
- [ ] Añadir filtros por PUDO type
- [ ] Exportar log de etiquetas generadas
- [ ] Integración con sistema de impresoras térmicas

## 📞 Soporte

Si encuentras algún problema:
1. Verificar logs de consola del navegador
2. Verificar logs de Supabase Edge Functions
3. Verificar estado del shipment en la base de datos
4. Contactar con el equipo de desarrollo

---

**Última actualización**: 25/03/2026  
**Versión**: 1.0.0  
**Autor**: Cline AI Assistant