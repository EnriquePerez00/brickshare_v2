# 📚 Generar 5 Usuarios Operativos - Guía Completa

## 🎯 Objetivo

Crear 5 usuarios completamente funcionales con suscripción **brick_pro** listos para recibir asignaciones de sets LEGO.

## 📋 Características de los Usuarios

| Campo | Valor |
|-------|-------|
| **Password** | `Test0test` (todos) |
| **Suscripción** | `brick_pro` (3 sets simultáneos) |
| **Estado Suscripción** | `active` |
| **Estado Usuario** | `no_set` (listos para asignación) |
| **PUDO** | Depósito Brickshare (gratuito) |
| **Wishlist** | 4-5 sets por usuario |
| **Stripe** | IDs mock para testing |
| **Perfil** | Completado (100%) |

## 👥 Usuarios Creados

| # | Nombre | Email | Teléfono | Ciudad |
|---|--------|-------|----------|--------|
| 1 | María García López | `enriqueperezbcn1973+test1@gmail.com` | +34612345001 | Barcelona |
| 2 | Carlos Martínez Ruiz | `enriqueperezbcn1973+test2@gmail.com` | +34612345002 | Barcelona |
| 3 | Laura López Fernández | `enriqueperezbcn1973+test3@gmail.com` | +34612345003 | Barcelona |
| 4 | Javier Fernández Gil | `enriqueperezbcn1973+test4@gmail.com` | +34612345004 | Barcelona |
| 5 | Ana Rodríguez Pérez | `enriqueperezbcn1973+test5@gmail.com` | +34612345005 | Barcelona |

## 🚀 Ejecución

### Prerrequisitos

1. **Supabase debe estar corriendo**:
   ```bash
   supabase start
   ```

2. **Variables de entorno configuradas** en `.env.local`:
   ```bash
   VITE_SUPABASE_URL=http://127.0.0.1:54321
   SUPABASE_SERVICE_ROLE_KEY=<tu_service_role_key>
   ```

### Comando

```bash
npx tsx scripts/seed-5-usuarios-operativos.ts
```

## 🔍 Verificación Post-Ejecución

### 1. Verificar usuarios en la base de datos

```bash
supabase db psql -c "
SELECT 
  u.full_name,
  u.email,
  u.subscription_type,
  u.subscription_status,
  u.user_status,
  u.pudo_type,
  u.profile_completed,
  COUNT(w.id) as wishlist_count
FROM users u
LEFT JOIN wishlist w ON w.user_id = u.user_id
WHERE u.email LIKE 'enriqueperezbcn1973+test%'
GROUP BY u.user_id, u.full_name, u.email, u.subscription_type, 
         u.subscription_status, u.user_status, u.pudo_type, u.profile_completed
ORDER BY u.email;
"
```

**Resultado esperado:**
```
        full_name        |                  email                   | subscription_type | subscription_status | user_status | pudo_type  | profile_completed | wishlist_count 
-------------------------+------------------------------------------+-------------------+---------------------+-------------+------------+-------------------+----------------
 María García López      | enriqueperezbcn1973+test1@gmail.com     | brick_pro         | active              | no_set      | brickshare | t                 |              4
 Carlos Martínez Ruiz    | enriqueperezbcn1973+test2@gmail.com     | brick_pro         | active              | no_set      | brickshare | t                 |              5
 Laura López Fernández   | enriqueperezbcn1973+test3@gmail.com     | brick_pro         | active              | no_set      | brickshare | t                 |              4
 Javier Fernández Gil    | enriqueperezbcn1973+test4@gmail.com     | brick_pro         | active              | no_set      | brickshare | t                 |              5
 Ana Rodríguez Pérez     | enriqueperezbcn1973+test5@gmail.com     | brick_pro         | active              | no_set      | brickshare | t                 |              4
```

### 2. Verificar que aparecen en preview de asignación

```bash
supabase db psql -c "
SELECT 
  user_name,
  set_name,
  set_ref,
  current_stock,
  matches_wishlist
FROM preview_assign_sets_to_users()
WHERE user_name LIKE '%test%'
ORDER BY user_name;
"
```

### 3. Verificar PUDO asignado

```bash
supabase db psql -c "
SELECT 
  u.full_name,
  u.pudo_id,
  u.pudo_type,
  b.name as pudo_name,
  b.city as pudo_city
FROM users u
JOIN users_brickshare_dropping ub ON ub.user_id = u.user_id
JOIN brickshare_pudo_locations b ON b.id = ub.brickshare_pudo_id
WHERE u.email LIKE 'enriqueperezbcn1973+test%'
ORDER BY u.email;
"
```

## 🔧 Troubleshooting

### Error: "A user with this email address has already been registered"

**Causa**: Los usuarios ya existen en la base de datos.

**Soluciones**:

1. **Opción A - Eliminar usuarios existentes**:
   ```bash
   supabase db psql -c "
   DELETE FROM auth.users 
   WHERE email LIKE 'enriqueperezbcn1973+test%';
   "
   ```

2. **Opción B - Actualizar usuarios existentes**:
   ```bash
   npx tsx scripts/update-5-usuarios-operativos.ts
   ```

3. **Opción C - Reset completo de la base de datos**:
   ```bash
   ./scripts/safe-db-reset.sh
   ```

### Error: "Connection refused" al ejecutar psql

**Causa**: Supabase no está corriendo.

**Solución**:
```bash
supabase start
supabase status  # Verificar que todo está OK
```

### No aparecen en preview_assign_sets_to_users()

**Causa**: No hay sets disponibles que coincidan con su wishlist.

**Soluciones**:

1. Verificar stock de sets:
   ```bash
   supabase db psql -c "
   SELECT 
     s.set_name,
     s.set_ref,
     i.inventory_set_total_qty as stock
   FROM sets s
   JOIN inventory_sets i ON i.set_id = s.id
   WHERE s.catalogue_visibility = true 
     AND s.set_status = 'active'
     AND i.inventory_set_total_qty > 0
   ORDER BY i.inventory_set_total_qty DESC
   LIMIT 10;
   "
   ```

2. Añadir más sets al inventario si es necesario

3. Verificar que los sets en wishlist tienen stock disponible

## 📊 Estructura de Datos Creados

### Tabla `auth.users`
- Usuario con email confirmado
- Password hasheado con bcrypt
- Metadata con nombre completo

### Tabla `users`
- Perfil completo (nombre, email, teléfono, dirección)
- Suscripción brick_pro activa
- IDs de Stripe mock
- PUDO Brickshare asignado
- Estado `no_set` (listo para asignación)

### Tabla `user_roles`
- Rol `user` asignado

### Tabla `users_brickshare_dropping`
- Punto PUDO Brickshare seleccionado
- Datos de ubicación copiados

### Tabla `wishlist`
- 4-5 sets aleatorios por usuario
- Sets con stock disponible (>3 unidades)
- Estado activo

## 🎯 Uso en Testing

### Login en la aplicación

```typescript
// Cualquier usuario test
const email = 'enriqueperezbcn1973+test1@gmail.com';
const password = 'Test0test';

await supabase.auth.signInWithPassword({ email, password });
```

### Asignación de sets

```sql
-- Preview de asignación
SELECT * FROM preview_assign_sets_to_users();

-- Confirmar asignación para usuarios test
SELECT confirm_assign_sets_to_users(
  ARRAY[
    (SELECT user_id FROM users WHERE email = 'enriqueperezbcn1973+test1@gmail.com'),
    (SELECT user_id FROM users WHERE email = 'enriqueperezbcn1973+test2@gmail.com')
  ]
);
```

## 📝 Notas Importantes

1. **Password único**: Todos los usuarios comparten el mismo password (`Test0test`) para facilitar el testing.

2. **Emails con +**: Gmail permite usar `+` para crear aliases del mismo email. Todos los emails llegarán a `enriqueperezbcn1973@gmail.com`.

3. **IDs de Stripe mock**: Los `stripe_customer_id` y `stripe_payment_method_id` son valores de prueba. No funcionarán con Stripe real.

4. **PUDO Brickshare**: Se usa el primer PUDO Brickshare disponible. Si no existe, se crea uno automáticamente en Barcelona.

5. **Wishlist aleatoria**: Cada ejecución genera una wishlist diferente basada en los sets disponibles con stock.

## 🔄 Re-ejecución

Si necesitas volver a ejecutar el script:

1. El script detectará que los usuarios ya existen
2. Mostrará un error pero no fallará
3. Para recrearlos desde cero, elimínalos primero (ver Troubleshooting)

## ✅ Checklist de Validación

- [ ] Los 5 usuarios aparecen en `auth.users`
- [ ] Los 5 usuarios tienen perfil completo en `users`
- [ ] Todos tienen `subscription_type = 'brick_pro'`
- [ ] Todos tienen `subscription_status = 'active'`
- [ ] Todos tienen `user_status = 'no_set'`
- [ ] Todos tienen `profile_completed = true`
- [ ] Todos tienen PUDO asignado (`pudo_type = 'brickshare'`)
- [ ] Todos tienen rol `user` en `user_roles`
- [ ] Todos tienen 4-5 items en wishlist
- [ ] Puedes hacer login con cualquiera de ellos
- [ ] Aparecen en `preview_assign_sets_to_users()` (si hay stock)

## 🆘 Soporte

Si encuentras problemas:

1. Verifica que Supabase está corriendo: `supabase status`
2. Revisa los logs: `supabase logs`
3. Consulta la documentación del proyecto en `docs/`
4. Ejecuta el script con más detalle para debugging