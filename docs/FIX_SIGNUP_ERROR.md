# Fix: Error de Registro "Database error saving new user"

## Problema

Al intentar registrarse, aparecía el error:
```
Error al registrarse
Database error saving new user
```

Y la tabla `users` permanecía vacía después del intento de registro.

## Causa Raíz

La función `handle_new_user()` tenía dos migraciones conflictivas:

1. **Migración 20260323200000** - Intentaba insertar el campo `id` manualmente con `gen_random_uuid()`
2. **Campo `id` en tabla `users`** - Ya tiene `DEFAULT gen_random_uuid()` definido

Cuando la función intentaba insertar explícitamente el campo `id`, causaba un conflicto porque:
- El campo `id` es PRIMARY KEY
- Ya tiene un DEFAULT que genera UUIDs automáticamente
- Insertar manualmente un valor generado podría causar colisiones

## Solución Aplicada

### Migración: `20260323210000_fix_handle_new_user_final.sql`

La nueva migración corrige la función `handle_new_user()` para:

1. **NO insertar el campo `id`** - Se deja que se auto-genere
2. Solo insertar los campos necesarios:
   - `user_id` (referencia a `auth.users.id`)
   - `full_name`
   - `avatar_url`
   - `email`
   - `subscription_status`
   - `user_status`

3. Mantener el manejo de excepciones para no bloquear el signup de Supabase Auth

### Código Correcto

```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER 
LANGUAGE plpgsql 
SECURITY DEFINER 
SET search_path = 'public' 
AS $$
BEGIN
    -- Create record in users table (id auto-generated as PRIMARY KEY)
    INSERT INTO public.users (
        user_id,
        full_name,
        avatar_url,
        email,
        subscription_status,
        user_status
    )
    VALUES (
        NEW.id,  -- user_id references auth.users.id
        COALESCE(NEW.raw_user_meta_data ->> 'full_name', split_part(NEW.email, '@', 1)),
        NEW.raw_user_meta_data ->> 'avatar_url',
        NEW.email,
        'inactive',
        'no_set'
    )
    ON CONFLICT (user_id) DO NOTHING;

    -- Assign default 'user' role
    INSERT INTO public.user_roles (user_id, role)
    VALUES (NEW.id, 'user'::app_role)
    ON CONFLICT (user_id, role) DO NOTHING;

    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Error in handle_new_user for user %: %', NEW.id, SQLERRM;
        RETURN NEW;
END;
$$;
```

## Verificación

Después de aplicar la migración (`supabase db reset`), verificar:

1. **Función instalada correctamente:**
   ```sql
   SELECT pg_get_functiondef(oid) 
   FROM pg_proc 
   WHERE proname = 'handle_new_user';
   ```

2. **Trigger activo:**
   ```sql
   SELECT tgname, tgtype, tgenabled 
   FROM pg_trigger 
   WHERE tgrelid = 'auth.users'::regclass 
   AND tgname = 'on_auth_user_created';
   ```
   - `tgenabled = 'O'` significa que está activo

3. **Estructura de tabla `users`:**
   ```sql
   \d users
   ```
   - Campo `id` debe tener `DEFAULT gen_random_uuid()`

## Prueba de Registro

Para probar que funciona:

1. Inicia el frontend: `npm run dev` (en `apps/web/`)
2. Accede a `http://localhost:5173`
3. Click en "Crear cuenta"
4. Rellena email y contraseña
5. El registro debe completarse sin errores
6. Verifica en la BD:
   ```sql
   SELECT id, user_id, email, subscription_status, user_status 
   FROM users;
   ```

## Migraciones Relacionadas

- `20260321000001_migrate_profiles_to_users.sql` - Migración original de perfiles a users
- `20260323200000_fix_handle_new_user_missing_id.sql` - ⚠️ Versión incorrecta (insertaba `id`)
- `20260323210000_fix_handle_new_user_final.sql` - ✅ Versión correcta (NO inserta `id`)

## Lecciones Aprendidas

1. **NUNCA insertar campos con DEFAULT en funciones PL/pgSQL** - PostgreSQL los maneja automáticamente
2. **PRIMARY KEY con DEFAULT gen_random_uuid()** - Siempre se auto-genera, no hace falta insertarlo
3. **Trigger AFTER INSERT** - Se ejecuta después de que el registro ya está creado en `auth.users`
4. **SECURITY DEFINER** - La función se ejecuta con permisos del creador, no del usuario actual