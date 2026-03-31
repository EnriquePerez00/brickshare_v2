-- Add admin SELECT policy for users table so admins can view all profiles
CREATE POLICY "Admins can view all profiles"
ON public.users FOR SELECT
TO authenticated
USING (public.has_role(auth.uid(), 'admin'));

-- Add DELETE policy for users table so users can delete their own profile
CREATE POLICY "Users can delete their own profile"
ON public.users FOR DELETE
TO authenticated
USING (auth.uid() = user_id);
