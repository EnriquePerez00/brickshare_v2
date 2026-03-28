# Fix de Asignación para Laura López Fernández

## 📋 Resumen del Problema

**Fecha**: 26/03/2026
**Usuario afectado**: Laura López Fernández (ID: `82dfc7cb-029d-4f09-a403-f4ea077f8d49`)
**Error**: "Edge Function returned a non-2xx status code" al intentar asignar un set

## 🔍 Análisis del Problema

### Causa Raíz
El usuario tenía configurado:
- `pudo_type = 'brickshare'` ✅
- `pudo_id = '9ae13c49-de91-462b-ba63-32c8e7a546a5'` ❌ **ID INVÁLIDO**

El `pudo_id` asignado **NO existía** en la tabla `brickshare_pudo_locations`, causando que:
1. La función `confirm_assign_sets_to_users` hiciera un LEFT JOIN con `brickshare_pudo_locations`
2. El JOIN no encontraba el registro (pudo_id inválido)
3. Las variables PUDO quedaban NULL
4. El proceso de asignación fallaba

### Puntos PUDO Brickshare Disponibles

Solo existen 2 puntos PUDO de Brickshare en el sistema:

| ID | Nombre | Dirección | Ciudad | Estado |
|---|---|---|---|---|
| `BS-PUDO-001` | Brickshare Madrid Centro | Calle Gran Vía 28 | Madrid | Activo |
| `BS-PUDO-002` | Brickshare Barcelona Eixample | Passeig de Gràcia 100 | Barcelona | Activo |

## ✅ Solución Aplicada

Se actualizó el registro del usuario con un `pudo_id` válido:

```sql
UPDATE users 
SET pudo_id = 'BS-PUDO-002' 
WHERE id = '82dfc7cb-029d-4f09-a403-f4ea077f8d49';
```

### Configuración Final Correcta

```
Usuario: Laura López Fernández
ID: 82dfc7cb-029d-4f09-a403-f4ea077f8d49
Email: enriqueperezbcn1973+test3@gmail.com

✅ pudo_type: 'brickshare'
✅ pudo_id: 'BS-PUDO-002' (Brickshare Barcelona Eixample)
✅ subscription_status: 'active'
✅ subscription_type: 'brick_pro'
✅ stripe_customer_id: 'cus_test_user3_7a8e62e9'
✅ stripe_payment_method_id: 'pm_test_card_003'
```

## 🔧 Función confirm_assign_sets_to_users

La función SQL hace lo siguiente para usuarios Brickshare:

```sql
LEFT JOIN public.brickshare_pudo_locations bp 
  ON u.pudo_id = bp.id 
  AND u.pudo_type = 'brickshare'
```

Si el `pudo_id` no existe en `brickshare_pudo_locations`:
- El JOIN devuelve NULL para todos los campos de Brickshare
- Las variables `v_pudo_name`, `v_pudo_address`, etc., quedan NULL
- El shipment se crea pero con datos incompletos o falla

## 🎯 Cómo Prevenir Este Problema

### 1. Validación en Frontend (PudoSelector.tsx)
Asegurarse de que solo se muestren puntos PUDO que realmente existan en la BD.

### 2. Foreign Key Constraint
Considerar añadir una constraint en la tabla `users`:

```sql
ALTER TABLE users 
ADD CONSTRAINT fk_users_brickshare_pudo 
FOREIGN KEY (pudo_id) 
REFERENCES brickshare_pudo_locations(id)
WHERE pudo_type = 'brickshare';
```

**Nota**: Esto requeriría una solución para permitir NULLs cuando `pudo_type = 'correos'`.

### 3. Validación en Edge Function
La función `process-assignment-payment` debería validar que el `pudo_id` existe:

```typescript
if (pudoType === 'brickshare') {
    // Verificar que el pudo_id existe
    const { data: pudoExists } = await supabase
        .from('brickshare_pudo_locations')
        .select('id')
        .eq('id', user.pudo_id)
        .eq('is_active', true)
        .single();
    
    if (!pudoExists) {
        return error('Invalid Brickshare PUDO location');
    }
}
```

### 4. Trigger de Validación
Crear un trigger que valide el `pudo_id` cuando se actualiza:

```sql
CREATE OR REPLACE FUNCTION validate_pudo_id()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.pudo_type = 'brickshare' AND NEW.pudo_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM brickshare_pudo_locations 
            WHERE id = NEW.pudo_id AND is_active = true
        ) THEN
            RAISE EXCEPTION 'Invalid pudo_id: % does not exist in brickshare_pudo_locations', NEW.pudo_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_user_pudo_id
BEFORE INSERT OR UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION validate_pudo_id();
```

## 📝 Comandos de Verificación

### Verificar configuración de un usuario:
```sql
SELECT 
    id, 
    full_name, 
    pudo_type, 
    pudo_id,
    subscription_status
FROM users 
WHERE id = '82dfc7cb-029d-4f09-a403-f4ea077f8d49';
```

### Verificar que el pudo_id existe:
```sql
SELECT id, name, address, city, is_active 
FROM brickshare_pudo_locations 
WHERE id = 'BS-PUDO-002';
```

### Listar todos los usuarios con pudo_id inválidos:
```sql
SELECT 
    u.id,
    u.full_name,
    u.pudo_type,
    u.pudo_id
FROM users u
WHERE u.pudo_type = 'brickshare'
  AND u.pudo_id IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 
      FROM brickshare_pudo_locations bp 
      WHERE bp.id = u.pudo_id
  );
```

## ✨ Estado Actual

**RESUELTO**: Laura López ahora tiene un `pudo_id` válido (`BS-PUDO-002`) y la asignación de sets debería funcionar correctamente.

**Próximos pasos**: 
1. Intentar nuevamente la asignación desde el panel de admin
2. Verificar que el proceso completa sin errores
3. Considerar implementar alguna de las validaciones preventivas mencionadas