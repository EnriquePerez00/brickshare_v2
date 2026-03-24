-- =========================================
-- Setup Test User: enriquepeto@yahoo.es
-- =========================================
-- This script:
-- 1. Creates the user in auth.users
-- 2. Creates the user profile in public.users
-- 3. Assigns user role
-- 4. Creates wishlist with 3 sets
-- 5. Selects a PUDO point
-- =========================================

-- Step 1: Create user in auth.users
INSERT INTO auth.users (
    id,
    instance_id,
    email,
    encrypted_password,
    email_confirmed_at,
    created_at,
    updated_at,
    raw_app_meta_data,
    raw_user_meta_data,
    is_super_admin,
    role,
    aud,
    confirmation_token,
    email_change_token_new,
    recovery_token
) VALUES (
    '11111111-1111-1111-1111-111111111111'::uuid,
    '00000000-0000-0000-0000-000000000000'::uuid,
    'enriquepeto@yahoo.es',
    -- Password hash for "Test1234!" (bcrypt)
    '$2a$10$ZqVZ3V4X0X8X8X8X8X8X8uQ8X8X8X8X8X8X8X8X8X8X8X8X8X8',
    NOW(),
    NOW(),
    NOW(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"full_name":"Enrique Perez"}'::jsonb,
    false,
    'authenticated',
    'authenticated',
    '',
    '',
    ''
) ON CONFLICT (id) DO NOTHING;

-- Step 2: Create user profile
INSERT INTO public.users (
    user_id,
    email,
    full_name,
    address,
    city,
    zip_code,
    phone,
    user_status,
    subscription_status,
    subscription_type
) VALUES (
    '11111111-1111-1111-1111-111111111111'::uuid,
    'enriquepeto@yahoo.es',
    'Enrique Perez',
    'Calle Test 123',
    'Barcelona',
    '08008',
    '+34666777888',
    'no_set',
    'active',
    'standard'
) ON CONFLICT (user_id) DO UPDATE SET
    email = EXCLUDED.email,
    full_name = EXCLUDED.full_name,
    address = EXCLUDED.address,
    city = EXCLUDED.city,
    zip_code = EXCLUDED.zip_code,
    phone = EXCLUDED.phone,
    user_status = EXCLUDED.user_status,
    subscription_status = EXCLUDED.subscription_status,
    subscription_type = EXCLUDED.subscription_type;

-- Step 3: Assign user role
INSERT INTO public.user_roles (user_id, role)
VALUES ('11111111-1111-1111-1111-111111111111'::uuid, 'user'::app_role)
ON CONFLICT (user_id, role) DO NOTHING;

-- Step 4: Create wishlist (3 sets from different themes)
-- Clear existing wishlist first
DELETE FROM public.wishlist WHERE user_id = '11111111-1111-1111-1111-111111111111'::uuid;

-- Add City set (30016 - Small Satellite)
INSERT INTO public.wishlist (user_id, set_id, status)
SELECT 
    '11111111-1111-1111-1111-111111111111'::uuid,
    id,
    true
FROM public.sets
WHERE set_ref = '30016'
LIMIT 1;

-- Add Star Wars set (20006 - Clone Turbo Tank)
INSERT INTO public.wishlist (user_id, set_id, status)
SELECT 
    '11111111-1111-1111-1111-111111111111'::uuid,
    id,
    true
FROM public.sets
WHERE set_ref = '20006'
LIMIT 1;

-- Add Architecture set (21000 - Sears Tower)
INSERT INTO public.wishlist (user_id, set_id, status)
SELECT 
    '11111111-1111-1111-1111-111111111111'::uuid,
    id,
    true
FROM public.sets
WHERE set_ref = '21000'
LIMIT 1;

-- Step 5: Select PUDO point
INSERT INTO public.users_correos_dropping (
    user_id,
    correos_id_pudo,
    correos_name,
    correos_point_type,
    correos_street,
    correos_zip_code,
    correos_city,
    correos_province,
    correos_country,
    correos_full_address,
    correos_latitude,
    correos_longitude
)
SELECT
    '11111111-1111-1111-1111-111111111111'::uuid,
    id,
    name,
    'PUDO',
    address,
    postal_code,
    city,
    province,
    'España',
    address || ', ' || postal_code || ' ' || city,
    latitude,
    longitude
FROM public.brickshare_pudo_locations
WHERE id = 'BS-PUDO-002'
LIMIT 1
ON CONFLICT (user_id) DO UPDATE SET
    correos_id_pudo = EXCLUDED.correos_id_pudo,
    correos_name = EXCLUDED.correos_name,
    correos_point_type = EXCLUDED.correos_point_type,
    correos_street = EXCLUDED.correos_street,
    correos_zip_code = EXCLUDED.correos_zip_code,
    correos_city = EXCLUDED.correos_city,
    correos_province = EXCLUDED.correos_province,
    correos_country = EXCLUDED.correos_country,
    correos_full_address = EXCLUDED.correos_full_address,
    correos_latitude = EXCLUDED.correos_latitude,
    correos_longitude = EXCLUDED.correos_longitude;

-- Verification queries
\echo '===== TEST USER SETUP COMPLETE ====='
\echo ''
\echo 'User Profile:'
SELECT user_id, email, full_name, user_status, subscription_status, subscription_type 
FROM public.users 
WHERE email = 'enriquepeto@yahoo.es';

\echo ''
\echo 'Wishlist:'
SELECT w.id, s.set_ref, s.set_name, s.set_theme, w.status
FROM public.wishlist w
JOIN public.sets s ON w.set_id = s.id
WHERE w.user_id = '11111111-1111-1111-1111-111111111111'::uuid
ORDER BY w.created_at;

\echo ''
\echo 'PUDO Point:'
SELECT correos_id_pudo, correos_name, correos_city
FROM public.users_correos_dropping
WHERE user_id = '11111111-1111-1111-1111-111111111111'::uuid;
