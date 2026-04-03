-- ================================================================
-- FIX: Agregar políticas RLS a tabla shipments
-- Problema: RLS habilitado sin políticas bloquea acceso vía API
-- Solución: Crear políticas que permitan acceso con service_role
-- ================================================================

-- 1. Permitir acceso completo con service_role key (para Edge Functions)
CREATE POLICY "Allow service role full access on shipments" 
ON public.shipments
FOR ALL 
TO service_role
USING (true)
WITH CHECK (true);

-- 2. Permitir lectura a usuarios autenticados
CREATE POLICY "Allow authenticated users to read shipments" 
ON public.shipments
FOR SELECT 
TO authenticated
USING (true);

-- 3. Permitir a usuarios autenticados actualizar sus propios shipments
CREATE POLICY "Allow authenticated users to update own shipments" 
ON public.shipments
FOR UPDATE 
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Verificar políticas creadas
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'shipments';
