-- =========================================
-- Migration: Unify user address fields
-- =========================================
-- Purpose: Remove duplicate fields and standardize on Spanish field names
-- The table has both English (address, city, zip_code, phone) and Spanish 
-- (direccion, ciudad, codigo_postal, telefono) versions of the same fields.
-- We'll keep Spanish versions as they match the UI and other parts of the system.
-- =========================================

-- Step 1: Migrate data from English fields to Spanish fields (if any data exists in English fields)
UPDATE public.users
SET 
  direccion = COALESCE(direccion, address),
  ciudad = COALESCE(ciudad, city),
  codigo_postal = COALESCE(codigo_postal, zip_code),
  telefono = COALESCE(telefono, phone)
WHERE direccion IS NULL OR ciudad IS NULL OR codigo_postal IS NULL OR telefono IS NULL;

-- Step 2: Drop the English field versions
ALTER TABLE public.users
  DROP COLUMN IF EXISTS address,
  DROP COLUMN IF EXISTS address_extra,
  DROP COLUMN IF EXISTS city,
  DROP COLUMN IF EXISTS province,
  DROP COLUMN IF EXISTS zip_code,
  DROP COLUMN IF EXISTS phone;

-- Step 3: Ensure profile_completed is properly set to false by default
ALTER TABLE public.users
  ALTER COLUMN profile_completed SET DEFAULT false;

-- Step 4: Mark existing users with complete profiles as profile_completed = true
UPDATE public.users
SET profile_completed = true
WHERE 
  direccion IS NOT NULL 
  AND codigo_postal IS NOT NULL 
  AND ciudad IS NOT NULL 
  AND telefono IS NOT NULL
  AND full_name IS NOT NULL;

COMMENT ON COLUMN public.users.direccion IS 'User address (street, number, floor, etc.)';
COMMENT ON COLUMN public.users.codigo_postal IS 'Postal code';
COMMENT ON COLUMN public.users.ciudad IS 'City name';
COMMENT ON COLUMN public.users.telefono IS 'Contact phone number';
COMMENT ON COLUMN public.users.profile_completed IS 'Whether the user has completed their profile information';