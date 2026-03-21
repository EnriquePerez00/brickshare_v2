# Instrucciones para Aplicar la Nueva Función de Asignación de Sets

## 📋 Resumen de Cambios Implementados

Se ha modificado la función de asignación automática de Sets con la siguiente lógica mejorada:

### Nuevas Características

1. **Título actualizado**: "Asignación de Sets" (antes: "Asignación Automática de Sets")
2. **Lógica inteligente de asignación**:
   - Analiza la wishlist del usuario en orden de preferencia
   - Verifica el histórico para evitar duplicados (sets ya tenidos)
   - Si no hay coincidencias válidas en wishlist, selecciona uno al azar
3. **Interfaz mejorada**:
   - Nueva columna "Origen" que indica si el set proviene de la wishlist o es aleatorio
   - Badge verde "✓ Wishlist" para coincidencias
   - Badge naranja "🎲 Aleatorio" para asignaciones aleatorias

## 🗄️ Aplicar la Migración SQL

**IMPORTANTE**: Debes ejecutar la migración SQL manualmente en el dashboard de Supabase.

### Opción 1: Via Dashboard de Supabase

1. Ve a tu proyecto en https://supabase.com/dashboard
2. Navega a **SQL Editor**
3. Copia y pega el contenido del archivo: `supabase/migrations/20260323000000_update_assignment_with_history_check.sql`
4. Ejecuta la query

### Opción 2: Via psql (si tienes acceso directo)

```bash
# Conecta a tu base de datos Supabase
psql "postgresql://postgres:[TU_PASSWORD]@[TU_HOST]:5432/postgres"

# Ejecuta la migración
\i supabase/migrations/20260323000000_update_assignment_with_history_check.sql
```

### Opción 3: Configurar Supabase CLI correctamente

Si quieres usar `npx supabase db reset`, necesitas configurar las credenciales:

```bash
# Vincula tu proyecto

# Aplica las migraciones
npx supabase db reset
```

## 📝 Contenido de la Migración

La migración actualiza la función `preview_assign_sets_to_users()` para:

```sql
-- Nueva estructura de retorno incluye:
RETURNS TABLE (
    user_id UUID,
    user_name TEXT,
    set_id UUID,
    set_name TEXT,
    set_ref TEXT,
    set_price DECIMAL,
    current_stock INTEGER,
    matches_wishlist BOOLEAN  -- ✨ NUEVO CAMPO
)
```

**Lógica implementada**:
1. Busca usuarios con `user_status IN ('sin set', 'set en devolucion')` y `user_type = 'user'` (excluye admins y operaciones)
2. Para cada usuario elegible:
   - Intenta encontrar un set de su wishlist (ordenado por `created_at`)
   - Verifica que tenga stock disponible
   - **Verifica que NO lo haya tenido antes** (consulta tabla `envios`)
   - Si encuentra match válido: `matches_wishlist = TRUE`
   - Si NO encuentra match: selecciona set aleatorio con stock, `matches_wishlist = FALSE`

## ✅ Verificar la Implementación

Una vez aplicada la migración, verifica que todo funciona:

1. **Accede al panel de admin** en tu aplicación
2. Ve a la sección **"Asignación de Sets"**
3. Haz clic en **"Genera propuesta de asignación"**
4. Verifica que:
   - El título sea "Asignación de Sets" (sin "Automática")
   - La tabla muestre la columna "Origen"
   - Los badges muestren "✓ Wishlist" o "🎲 Aleatorio" correctamente
   - Las descripciones mencionen "histórico" y "stock disponible"

## 🧪 Casos de Prueba

### Caso 1: Usuario con wishlist válida
- Usuario tipo 'user' con sets en wishlist que NO ha tenido antes
- **Resultado esperado**: Asignación desde wishlist, badge verde "✓ Wishlist"

### Caso 2: Usuario con wishlist pero todos ya usados
- Usuario tipo 'user' con wishlist pero ya recibió todos esos sets
- **Resultado esperado**: Asignación aleatoria, badge naranja "🎲 Aleatorio"

### Caso 3: Usuario sin wishlist
- Usuario tipo 'user' sin items en wishlist
- **Resultado esperado**: Asignación aleatoria, badge naranja "🎲 Aleatorio"

### Caso 4: Admin u operador sin set
- Usuario con `user_type = 'admin'` o `user_type = 'operations'`
- **Resultado esperado**: NO aparece en la propuesta de asignación (filtrado automáticamente)

## 🔒 Restricciones de Seguridad

**Tipos de Usuario Elegibles**: Solo usuarios con `user_type = 'user'` son considerados para asignación automática.

**Tipos Excluidos**:
- `user_type = 'admin'` - Administradores
- `user_type = 'operations'` - Personal de operaciones

Esto previene que cuentas de staff reciban asignaciones automáticas por error.

## 📦 Archivos Modificados

1. **Backend (SQL)**:
   - `supabase/migrations/20260323000000_update_assignment_with_history_check.sql`
     - Filtro agregado: `AND u.user_type = 'user'`

2. **Frontend (React)**:
   - `src/components/admin/operations/SetAssignment.tsx`
     - Interface `PreviewAssignment` actualizada con `matches_wishlist: boolean`
     - Título cambiado a "Asignación de Sets"
     - Nueva columna "Origen" en tabla de preview
     - Badges visuales para identificar origen de asignación

## 🔧 Solución de Problemas

### Error: "column matches_wishlist does not exist"
- **Causa**: La migración SQL no se ha aplicado
- **Solución**: Ejecutar la migración en el dashboard de Supabase

### Error de autenticación con Supabase CLI
- **Causa**: Credenciales no configuradas o expiradas
- **Solución**: Usar el dashboard de Supabase para aplicar la migración manualmente

### Los badges no aparecen correctamente
- **Causa**: Caché del navegador
- **Solución**: Hacer hard refresh (Ctrl+Shift+R o Cmd+Shift+R)

## 📞 Soporte

Si encuentras problemas:
1. Verifica que la migración se aplicó correctamente en Supabase Dashboard
2. Revisa la consola del navegador para errores de TypeScript
3. Comprueba que el componente React se haya guardado correctamente

---

**Fecha de implementación**: 23/03/2026
**Versión**: 1.0.0