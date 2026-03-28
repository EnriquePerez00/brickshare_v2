# Reset Auth Users Script

## 📋 Descripción

Script para resetear completamente los usuarios de Supabase Auth y crear 3 usuarios de prueba con perfiles completos.

## 🎯 Usuarios Creados

El script crea automáticamente 3 usuarios:

### 1. Admin User
- **Email**: `admin@brickshare.com`
- **Password**: `Admin1test`
- **Role**: `admin`
- **Descripción**: Usuario administrador con acceso total al backoffice

### 2. Enrique Perez
- **Email**: `enriquepeto@yahoo.es`
- **Password**: `User1test`
- **Role**: `user`
- **Descripción**: Usuario suscriptor regular

### 3. User Two
- **Email**: `user2@brickshare.com`
- **Password**: `User2test`
- **Role**: `user`
- **Descripción**: Usuario suscriptor regular

## 📍 Perfil Común (todos los usuarios)

Todos los usuarios tienen el mismo perfil completo:

- **Suscripción**: `brick_master` (activa)
- **Estado**: `no_set`
- **Dirección**: Josep Tarradellas 97-101
- **Ciudad**: Barcelona
- **Código Postal**: 08029
- **Teléfono**: +34600123456
- **Método de Pago**: `pm_card_visa` (Stripe test card)
- **Perfil Completado**: ✅ Sí

## 🚀 Uso

```bash
# Asegúrate de que Supabase esté corriendo
supabase start

# Ejecuta el script
./scripts/reset-auth-users.sh
```

## ⚠️ Advertencias

1. **Solo funciona en entorno local** - El script verifica que estés conectado a localhost antes de ejecutarse
2. **Elimina TODOS los usuarios** - Borra todos los usuarios existentes en `auth.users` y `public.users`
3. **Elimina datos relacionados** - Borra wishlist, reviews, shipments, y otros datos asociados a usuarios
4. **Preserva sets e inventario** - NO toca las tablas de sets, inventory_sets, ni otras tablas no relacionadas con usuarios
5. **Requiere confirmación** - Pide confirmación antes de ejecutar

## 🔍 Qué Hace el Script

### 1. Validaciones
- ✅ Verifica que Supabase esté corriendo
- ✅ Verifica que estés en entorno local (localhost)
- ⚠️ Pide confirmación antes de proceder

### 2. Limpieza
Elimina datos de las siguientes tablas:
- `auth.users`
- `auth.identities`
- `public.users`
- `public.user_roles`
- `public.wishlist`
- `public.reviews`
- `public.referrals`
- `public.shipments`
- `public.donations`
- `public.users_correos_dropping`
- `public.reception_operations`
- `public.backoffice_operations`
- `public.shipping_orders`
- `public.qr_validation_logs`

### 3. Creación de Usuarios
Para cada usuario:
1. Crea entrada en `auth.users` con password hasheado (bcrypt)
2. Crea entrada en `auth.identities` (email provider)
3. Crea perfil completo en `public.users`
4. Asigna rol en `public.user_roles`

### 4. Verificación
- 📊 Muestra tabla con los usuarios creados
- ✅ Verifica que todos los datos se insertaron correctamente

## 📝 Ejemplo de Output

```
═══════════════════════════════════════════════════════════════
  🔄 Reset Auth Users & Create Test Users
═══════════════════════════════════════════════════════════════

⚠️  ADVERTENCIA: Esta operación eliminará TODOS los usuarios existentes
   y creará 3 nuevos usuarios de prueba.

Usuarios que se crearán:
  1. admin@brickshare.com / Admin1test (admin)
  2. enriquepeto@yahoo.es / User1test (user)
  3. user2@brickshare.com / User2test (user)

Todos tendrán:
  - Suscripción: brick_master (activa)
  - Dirección: Josep Tarradellas 97-101, Barcelona 08029
  - Método de pago: pm_card_visa

¿Continuar? (y/N): y

🗑️  Eliminando usuarios existentes...
✅ Usuarios eliminados exitosamente

👥 Creando usuarios de prueba...
NOTICE:  ✅ Created: admin@brickshare.com (admin role) - ID: xxx
NOTICE:  ✅ Created: enriquepeto@yahoo.es (user role) - ID: xxx
NOTICE:  ✅ Created: user2@brickshare.com (user role) - ID: xxx

📊 Usuarios creados:

            email            |    full_name     | role  | subscription_type | subscription_status |   city    | stripe_payment_method_id
-----------------------------+------------------+-------+-------------------+---------------------+-----------+-------------------------
 admin@brickshare.com        | Admin Brickshare | admin | brick_master      | active              | Barcelona | pm_card_visa
 enriquepeto@yahoo.es        | Enrique Perez    | user  | brick_master      | active              | Barcelona | pm_card_visa
 user2@brickshare.com        | User Two         | user  | brick_master      | active              | Barcelona | pm_card_visa

✅ Usuarios creados exitosamente
```

## 🔐 Seguridad

- Las contraseñas se hashean con **bcrypt** usando `crypt()` de PostgreSQL
- Compatible con Supabase Auth
- Los usuarios pueden hacer login inmediatamente después de la creación

## 🔗 Relación con Otros Scripts

- **Complementa**: `safe-db-reset.sh` (reset completo de BD)
- **Alternativa a**: `create-enrique-test-user.sql` (crea solo 1 usuario)
- **Usa misma lógica que**: `sync-auth-to-public-users.ts` (sincronización auth → public)

## 💡 Tips

### Para login rápido:
```bash
# En el navegador, ve a http://localhost:5173/auth
# Usa cualquiera de estos usuarios:
# - admin@brickshare.com / Admin1test
# - enriquepeto@yahoo.es / User1test
# - user2@brickshare.com / User2test
```

### Para verificar usuarios desde psql:
```bash
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres

SELECT u.email, ur.role, u.subscription_status 
FROM users u 
LEFT JOIN user_roles ur ON ur.user_id = u.user_id;
```

### Para eliminar un usuario específico:
```bash
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres

DELETE FROM auth.users WHERE email = 'user@example.com';
```

## 🐛 Troubleshooting

### Error: "Supabase no está corriendo"
```bash
supabase start
```

### Error: "Este script solo funciona en entorno local"
- Verifica que estés usando la BD local (puerto 54322)
- NO uses este script en producción

### Los usuarios no aparecen en el frontend
1. Verifica que estén en la BD:
   ```bash
   psql postgresql://postgres:postgres@127.0.0.1:54322/postgres -c "SELECT email FROM auth.users;"
   ```
2. Limpia caché del navegador
3. Verifica que las credenciales sean correctas

### Error al hacer login
- Verifica que la contraseña sea exactamente la especificada
- Los passwords son case-sensitive: `Admin1test` ≠ `admin1test`

## 📚 Referencias

- [Supabase Auth](https://supabase.com/docs/guides/auth)
- [PostgreSQL crypt()](https://www.postgresql.org/docs/current/pgcrypto.html)
- [Bcrypt](https://en.wikipedia.org/wiki/Bcrypt)