# Fix: Validación de PUDO en Asignaciones

**Fecha:** 25 de marzo de 2026  
**Problema:** Error genérico "Edge Function returned a non-2xx status code" al confirmar asignación para usuarios sin PUDO configurado  
**Usuario afectado:** user2@brickshare.com (y potencialmente otros)

## 🐛 Problema Identificado

Al intentar confirmar la asignación de un set para `user2@brickshare.com`, el sistema mostraba un error genérico sin información específica sobre la causa.

### Causa Raíz

El usuario **no tenía configurado un punto PUDO** (`pudo_type` y `pudo_id` eran `NULL`).

La Edge Function `process-assignment-payment` tenía esta lógica:

```typescript
// ❌ ANTES: Lógica incorrecta
if (pudoType !== 'correos') {
    // Si NO es correos, no cobra
    return success;
}
// Si llegaba aquí con pudoType = null, intentaba procesar el pago
// y fallaba sin mensaje claro
```

**El problema:** Cuando `pudoType` es `null`, la condición `pudoType !== 'correos'` es `true`, así que saltaba el return y continuaba intentando procesar el pago, pero fallaba sin dar un error específico.

## ✅ Solución Implementada

### 1. Validación en Edge Function

Se agregó validación explícita en `supabase/functions/process-assignment-payment/index.ts`:

```typescript
// ✅ DESPUÉS: Validación explícita
// 2. Validate user has PUDO configured
if (!pudoType) {
    return new Response(JSON.stringify({
        success: false,
        error: "Usuario no tiene punto PUDO configurado. Debe seleccionar un punto de recogida antes de recibir asignaciones.",
        errorCode: "no_pudo_configured",
        failedOperation: "pudo_validation",
        userEmail: userProfile.email
    }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
}

// 3. Check if user has Correos PUDO - only charge if Correos
if (pudoType !== 'correos') {
    // Usuario tiene PUDO de Brickshare, no cobra
    return success;
}
```

### 2. Mensajes Específicos en Frontend

Se actualizó `apps/web/src/components/admin/operations/SetAssignment.tsx` para mostrar mensajes específicos según el código de error:

```typescript
{paymentErrorDialog.errorCode === "no_pudo_configured" && (
    <div className="mt-2 text-sm text-muted-foreground">
        El usuario debe seleccionar un punto de recogida (PUDO) antes de poder recibir asignaciones.
        Pídele que acceda a su Dashboard y configure su punto PUDO preferido.
    </div>
)}

{paymentErrorDialog.errorCode === "no_payment_method" && (
    <div className="mt-2 text-sm text-muted-foreground">
        El usuario no tiene un método de pago configurado.
        Debe agregar una tarjeta de crédito en su perfil.
    </div>
)}

{paymentErrorDialog.errorCode === "insufficient_funds" && (
    <div className="mt-2 text-sm text-muted-foreground">
        El usuario no tiene fondos suficientes para completar la transacción.
        La asignación no se ha realizado.
    </div>
)}
```

## 📋 Códigos de Error Definidos

| Código | Descripción | Acción Requerida |
|--------|-------------|------------------|
| `no_pudo_configured` | Usuario sin PUDO configurado | Configurar PUDO en Dashboard |
| `no_payment_method` | Usuario sin tarjeta de pago | Agregar tarjeta en perfil |
| `no_stripe_customer` | Usuario sin Stripe Customer ID | Verificar suscripción |
| `insufficient_funds` | Fondos insuficientes | Verificar saldo de tarjeta |
| `card_declined` | Tarjeta rechazada | Verificar tarjeta o usar otra |

## 🔧 Cómo Resolver para user2@brickshare.com

### Opción 1: Usuario configura PUDO (Recomendado)

1. El usuario accede a su Dashboard
2. En la sección de configuración de perfil, selecciona su punto PUDO preferido
3. Guarda los cambios
4. Ya puede recibir asignaciones

### Opción 2: Admin asigna PUDO manualmente

```sql
-- Asignar un PUDO de Brickshare
UPDATE users 
SET pudo_type = 'brickshare', 
    pudo_id = '1' -- ID de un punto Brickshare existente
WHERE email = 'user2@brickshare.com';

-- O asignar un PUDO de Correos (requiere tener registro en users_correos_dropping)
UPDATE users 
SET pudo_type = 'correos', 
    pudo_id = '<codigo_pudo_correos>' 
WHERE email = 'user2@brickshare.com';
```

## 🧪 Testing

Para verificar que el fix funciona:

1. Crear un usuario sin PUDO configurado
2. Intentar confirmar asignación desde el backoffice
3. Verificar que aparece el error específico "Usuario no tiene punto PUDO configurado"
4. Configurar PUDO para el usuario
5. Reintentar asignación → Debe funcionar correctamente

## 📝 Archivos Modificados

- `supabase/functions/process-assignment-payment/index.ts` - Validación de PUDO
- `apps/web/src/components/admin/operations/SetAssignment.tsx` - Mensajes de error específicos
- `docs/PUDO_VALIDATION_FIX.md` - Este documento

## 🚀 Despliegue

Para que la función esté disponible localmente:

```bash
supabase functions serve --no-verify-jwt
```

Esto hace que la función actualizada esté disponible en `http://127.0.0.1:54331/functions/v1/process-assignment-payment`

No se requieren migraciones de base de datos para este fix.

## 💡 Beneficios

1. ✅ **Error específico y claro** en lugar de mensaje genérico
2. ✅ **Validación temprana** antes de intentar procesar pagos
3. ✅ **Guía al usuario** sobre cómo resolver el problema
4. ✅ **Previene estados inconsistentes** en la base de datos
5. ✅ **Mejor experiencia** para admin y usuarios

## 📚 Referencias

- [Edge Function: process-assignment-payment](../supabase/functions/process-assignment-payment/index.ts)
- [Componente: SetAssignment](../apps/web/src/components/admin/operations/SetAssignment.tsx)
- [Documentación PUDO](./BRICKSHARE_PUDO.md)