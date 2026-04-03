-- Make sure we can insert "Deposito" into correos_point_type
DO $$ 
DECLARE
    c_name text;
BEGIN
    -- Find the check constraint on correos_point_type (or correos_tipo_punto)
    SELECT conname INTO c_name
    FROM pg_constraint
    WHERE conrelid = 'public.users_correos_dropping'::regclass
      AND contype = 'c';
      
    IF c_name IS NOT NULL THEN
        EXECUTE 'ALTER TABLE public.users_correos_dropping DROP CONSTRAINT ' || quote_ident(c_name);
    END IF;
END $$;

ALTER TABLE public.users_correos_dropping 
ADD CONSTRAINT users_correos_dropping_point_type_check 
CHECK (correos_point_type IN ('Oficina', 'Citypaq', 'Locker', 'Deposito'));
