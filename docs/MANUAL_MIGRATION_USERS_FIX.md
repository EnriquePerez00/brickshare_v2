# Manual Migration: Fix Users Visibility in Admin Panel

## Issue
El panel de administración en la sección "Gestión de Usuarios" solo muestra usuarios con rol "user", ocultando usuarios con roles "admin" y "operador".

## Causa
Las políticas RLS (Row Level Security) en la tabla `users` podrían estar filtrando incorrectamente los usuarios por rol, o falta una política que permita a los administradores ver todos los usuarios independientemente de su rol.

## Solución
Se ha creado una migración SQL que actualiza las políticas RLS para asegurar que los administradores puedan ver TODOS los usuarios (user, admin, operador).

## Cómo Aplicar la Migración Manualmente

### Opción 1: Desde Supabase Dashboard (Recomendado)

1. Accede a tu proyecto en [Supabase Dashboard](https://supabase.com/dashboard)
2. Ve a la sección **SQL Editor**
3. Crea una nueva query
4. Copia y pega el siguiente código SQL:

```sql
-- Fix users table RLS to show all user roles (not just 'user' role)
-- This ensures admins can see users with role 'admin', 'operador', and 'user'

-- Drop the existing policy if it exists
DROP POLICY IF EXISTS "Admins and Operadores can view all users" ON public.users;

-- Create a new policy that allows admins and operadores to view ALL users regardless of role
CREATE POLICY "Admins and Operadores can view all users"
    ON public.users FOR SELECT
    USING (
        public.has_role(auth.uid(), 'admin'::public.app_role) OR 
        public.has_role(auth.uid(), 'operador'::public.app_role)
    );

-- Also ensure users can view their own profile
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;

CREATE POLICY "Users can view own profile"
    ON public.users FOR SELECT
    USING (auth.uid() = user_id);

-- Allow users to update their own profile
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;

CREATE POLICY "Users can update own profile"
    ON public.users FOR UPDATE
    USING (auth.uid() = user_id);

-- Allow admins to update any user
DROP POLICY IF EXISTS "Admins can update any user" ON public.users;

CREATE POLICY "Admins can update any user"
    ON public.users FOR UPDATE
    USING (public.has_role(auth.uid(), 'admin'::public.app_role));
```

5. Ejecuta la query haciendo clic en **Run** o presionando `Cmd/Ctrl + Enter`
6. Verifica que no hay errores en la ejecución

### Opción 2: Desde Supabase CLI (Requiere autenticación)

Si tienes las credenciales configuradas:

```bash
# Asegúrate de estar autenticado
npx supabase login

# Enlaza el proyecto

# Aplica las migraciones pendientes
npx supabase db reset
```

## Verificación

Después de aplicar la migración:

1. Accede al panel de administración como usuario admin
2. Ve a la sección "Gestión de Usuarios"
3. Verifica que ahora puedes ver usuarios con todos los roles:
   - Usuarios tipo "user"
   - Usuarios tipo "admin"
   - Usuarios tipo "operador"

## Archivo de Migración

El archivo de migración se encuentra en:
```
supabase/migrations/20260324000000_fix_users_visibility_all_roles.sql
```

## Notas Adicionales

- Esta migración es segura de ejecutar múltiples veces (usa `DROP POLICY IF EXISTS`)
- No modifica ningún dato, solo actualiza las políticas de seguridad RLS
- Las políticas anteriores se reemplazan completamente por las nuevas
- Los usuarios normales seguirán viendo solo su propio perfil
- Los administradores y operadores verán todos los usuarios

## Troubleshooting

### Si todavía no ves todos los usuarios después de aplicar la migración:

1. **Verifica que las políticas se aplicaron correctamente:**
   ```sql
   SELECT * FROM pg_policies WHERE tablename = 'users';
   ```

2. **Verifica que tu usuario tiene el rol correcto:**
   ```sql
   SELECT user_id, email, role FROM public.users WHERE user_id = auth.uid();
   ```

3. **Limpia la caché del navegador y recarga la página**

4. **Verifica que la función `has_role` existe:**
   ```sql
   SELECT proname FROM pg_proc WHERE proname = 'has_role';
   ```

Si el problema persiste, contacta con el equipo de desarrollo.