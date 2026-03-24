# Refactorización del Sistema de Pagos Stripe

## Fecha
24 de Marzo de 2026

## Problema Identificado

El error reportado en el proceso de asignación de sets era:
```
Error al confirmar asignación: Error en base de datos: relation "public.orders" does not exist. 
El pago fue procesado pero la asignación no se guardó. Revisa Stripe Dashboard.
```

### Causas Raíz

1. **Tabla `orders` deprecada**: La función `confirm_assign_sets_to_users()` intentaba crear registros en la tabla `orders` que ya no existe. Los envíos ahora se gestionan directamente en `shipments`.

2. **Sistema de fianza innecesario**: Se cobraba una fianza (depósito) en custodia por el valor del set, lo cual no era el modelo de negocio deseado.

3. **Cobro indiscriminado**: Se cobraban gastos de transporte a todos los usuarios, sin distinguir entre usuarios de PUDO Correos vs Brickshare.

---

## Solución Implementada

### 1. Migración de Base de Datos

**Archivo**: `supabase/migrations/20260324200730_remove_orders_table_references.sql`

**Cambios**:
- ✅ Eliminada referencia a tabla `orders` en la función `confirm_assign_sets_to_users()`
- ✅ Los shipments se crean directamente sin intermediate `orders` table
- ✅ La función devuelve `shipment_id` en lugar de `order_id`

**Función actualizada**:
```sql
CREATE OR REPLACE FUNCTION public.confirm_assign_sets_to_users(p_user_ids uuid[])
RETURNS TABLE(
    shipment_id uuid,      -- NO order_id
    user_id uuid,
    set_id uuid,
    -- ... resto de campos
)
```

### 2. Edge Function: process-assignment-payment

**Archivo**: `supabase/functions/process-assignment-payment/index.ts`

**Cambios principales**:

#### Antes (Sistema antiguo):
```typescript
// ❌ Cobraba fianza en custodia
depositPaymentIntent = await stripe.paymentIntents.create({
    amount: setPrice * 100,  // Valor del set
    description: `Fianza en custodia por set ${setRef}`,
    metadata: { type: "deposit" }
});

// ❌ Cobraba transporte a todos
transportPaymentIntent = await stripe.paymentIntents.create({
    amount: shippingCost * 100,
    description: `Gastos de transporte - Set ${setRef}`,
});
```

#### Después (Sistema nuevo):
```typescript
// ✅ Verifica tipo de PUDO primero
if (pudoType !== 'correos') {
    return { 
        success: true, 
        message: "No charge required for Brickshare PUDO",
        transportAmount: 0 
    };
}

// ✅ Solo cobra transporte a usuarios Correos
transportPaymentIntent = await stripe.paymentIntents.create({
    amount: shippingCost * 100,
    description: `Gastos de transporte Correos - Set ${setRef}`,
    metadata: {
        type: "transport",
        pudo_type: "correos"
    }
});
```

**Lógica de negocio**:
- **PUDO Brickshare** (gratuito): No se cobra nada
- **PUDO Correos**: Se cobra solo fee de transporte (10€ por defecto desde `COSTE_ENVIO_DEVOLUCION`)
- **Sin fianza**: Eliminado completamente el concepto de depósito en custodia

### 3. Frontend: SetAssignment Component

**Archivo**: `apps/web/src/components/admin/operations/SetAssignment.tsx`

**Cambios**:
```typescript
// ❌ Antes: enviaba setPrice innecesario
body: {
    userId: assignment.user_id,
    setRef: assignment.set_ref,
    setPrice: assignment.set_price || 100.00  // ❌
}

// ✅ Ahora: envía pudoType para lógica condicional
body: {
    userId: assignment.user_id,
    setRef: assignment.set_ref,
    pudoType: assignment.pudo_type  // ✅
}
```

---

## Impacto y Beneficios

### ✅ Correcciones
1. **Error eliminado**: Ya no falla la función por tabla `orders` inexistente
2. **Modelo de negocio correcto**: Sin fianzas, solo fee logístico cuando aplique
3. **Experiencia mejorada**: Usuarios Brickshare no pagan nada extra

### 📊 Flujo de Cobro Actualizado

| Tipo PUDO | Fianza | Fee Transporte | Total Cobrado |
|-----------|--------|----------------|---------------|
| **Brickshare** | ❌ 0€ | ❌ 0€ | **0€** |
| **Correos** | ❌ 0€ | ✅ 10€ | **10€** |

### 🔄 Backward Compatibility
- ✅ Migraciones históricas intactas
- ✅ Datos existentes no afectados
- ✅ Solo afecta nuevas asignaciones

---

## Testing Recomendado

### Caso 1: Usuario con PUDO Brickshare
```bash
# Espera: Sin cargo, asignación exitosa
1. Usuario selecciona PUDO Brickshare
2. Admin genera propuesta de asignación
3. Admin confirma asignación
4. ✅ Resultado: No se procesa pago, shipment creado directamente
```

### Caso 2: Usuario con PUDO Correos
```bash
# Espera: Cargo de 10€, asignación exitosa
1. Usuario selecciona PUDO Correos
2. Admin genera propuesta de asignación
3. Admin confirma asignación
4. ✅ Resultado: Se cobra 10€ de transporte, shipment creado
```

### Caso 3: Usuario sin método de pago (Correos)
```bash
# Espera: Error claro, sin asignación
1. Usuario Correos sin tarjeta configurada
2. Admin intenta confirmar asignación
3. ❌ Resultado: Error "Usuario no tiene método de pago configurado"
4. ✅ No se crea shipment ni se afecta inventario
```

---

## Archivos Modificados

```
supabase/migrations/20260324200730_remove_orders_table_references.sql  [NUEVO]
supabase/functions/process-assignment-payment/index.ts                 [MODIFICADO]
apps/web/src/components/admin/operations/SetAssignment.tsx             [MODIFICADO]
docs/STRIPE_PAYMENT_REFACTOR.md                                         [NUEVO]
```

---

## Deployment Checklist

- [x] Migración SQL creada
- [x] Edge Function actualizada
- [x] Frontend actualizado
- [x] Documentación creada
- [ ] `supabase db reset` ejecutado localmente
- [ ] Pruebas con usuario Brickshare
- [ ] Pruebas con usuario Correos
- [ ] Deploy a producción (cuando se apruebe)

---

## Notas Importantes

### Variables de Entorno
```bash
COSTE_ENVIO_DEVOLUCION=10  # Fee en EUR para PUDO Correos (default: 10€)
```

### Metadata en Stripe
Los PaymentIntents ahora incluyen:
```json
{
  "user_id": "uuid",
  "set_ref": "75192",
  "type": "transport",
  "pudo_type": "correos"  // Nuevo campo para tracking
}
```

### Rollback Plan
Si es necesario revertir:
```bash
# 1. Revertir migración
git revert <commit-hash>

# 2. Restaurar Edge Function desde backup
git checkout HEAD~1 supabase/functions/process-assignment-payment/index.ts

# 3. Restaurar frontend
git checkout HEAD~1 apps/web/src/components/admin/operations/SetAssignment.tsx

# 4. Aplicar cambios
supabase db reset
```

---

## Contacto
Para preguntas o issues relacionados con esta refactorización, revisar:
- Error original en screenshot del usuario
- Este documento
- `docs/BRICKSHARE_PUDO.md` para contexto de PUDO types