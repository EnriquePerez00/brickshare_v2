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