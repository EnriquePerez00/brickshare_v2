-- =====================================================
-- SEED: 5 Usuarios Operativos Brick Pro
-- =====================================================
-- Descripción: Crea 5 usuarios completamente funcionales
-- listos para recibir asignaciones de sets
--
-- Detalles:
-- - Password: Test0test (todos los usuarios)
-- - Suscripción: brick_pro (3 sets simultáneos)
-- - PUDO: Depósito Brickshare (gratuito)
-- - Wishlist: 5 sets por usuario
-- - Stripe: IDs mock para testing
-- - Email: enriqueperezbcn1973+test{N}@gmail.com
--
-- Ejecución:
--   PGPASSWORD=postgres psql -h 127.0.0.1 -p 5433 \
--     -U postgres -d postgres < scripts/generar_5_usuarios_operativos.sql
-- =====================================================

DO $$
DECLARE
  -- UUIDs para los 5 usuarios
  user1_id UUID := gen_random_uuid();
  user2_id UUID := gen_random_uuid();
  user3_id UUID := gen_random_uuid();
  user4_id UUID := gen_random_uuid();
  user5_id UUID := gen_random_uuid();
  
  -- Variables de configuración
  brickshare_pudo_id TEXT;
  available_sets UUID[];
  password_hash TEXT;
  set_count INT;
  
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'SEED: 5 Usuarios Operativos Brick Pro';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  
  -- ========================================
  -- PASO 1: Preparar datos base
  -- ========================================
  
  RAISE NOTICE '📋 Paso 1: Preparando datos base...';
  
  -- Generar hash de password "Test0test" con bcrypt
  password_hash := crypt('Test0test', gen_salt('bf'));
  
  -- Obtener primer PUDO Brickshare disponible
  SELECT id INTO brickshare_pudo_id
  FROM brickshare_pudo_locations
  WHERE is_active = true
    AND (name ILIKE '%brickshare%' OR address ILIKE '%brick%')
  LIMIT 1;
  
  -- Si no hay PUDO Brickshare específico, crear uno
  IF brickshare_pudo_id IS NULL THEN
    RAISE NOTICE '  ⚠️  No existe PUDO Brickshare, creando...';
    INSERT INTO brickshare_pudo_locations (
      id, name, address, city, postal_code, province,
      latitude, longitude, contact_email, is_active, created_at, updated_at
    ) VALUES (
      'BS-PUDO-TEST-001',
      'Brickshare Barcelona Test',
      'Carrer de Mallorca 123',
      'Barcelona', '08029', 'Barcelona',
      41.3926, 2.1640,
      'test@brickshare.com',
      true,
      NOW(), NOW()
    )
    RETURNING id INTO brickshare_pudo_id;
    RAISE NOTICE '  ✅ PUDO Brickshare creado: %', brickshare_pudo_id;
  ELSE
    RAISE NOTICE '  ✅ PUDO Brickshare encontrado: %', brickshare_pudo_id;
  END IF;
  
  -- Obtener sets disponibles con stock para wishlist
  SELECT ARRAY_AGG(s.id)
  INTO available_sets
  FROM sets s
  JOIN inventory_sets i ON s.id = i.set_id
  WHERE i.inventory_set_total_qty > 3
    AND s.catalogue_visibility = true
    AND s.set_status = 'active'
  ORDER BY RANDOM()
  LIMIT 50;
  
  set_count := COALESCE(ARRAY_LENGTH(available_sets, 1), 0);
  RAISE NOTICE '  ✅ Sets disponibles para wishlist: %', set_count;
  
  IF set_count < 5 THEN
    RAISE WARNING '⚠️  ADVERTENCIA: Hay menos de 5 sets disponibles. Se necesitan al menos 5 sets distintos.';
  END IF;
  
  RAISE NOTICE '';
  
  -- ========================================
  -- PASO 2: Crear Usuario 1 - María García López
  -- ========================================
  
  RAISE NOTICE '👤 Usuario 1: María García López';
  
  -- Crear en auth.users
  INSERT INTO auth.users (
    instance_id, id, aud, role, email,
    encrypted_password,
    email_confirmed_at, phone_confirmed_at,
    raw_user_meta_data, raw_app_meta_data,
    created_at, updated_at,
    confirmation_token, email_change,
    email_change_token_new, recovery_token
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    user1_id,
    'authenticated',
    'authenticated',
    'enriqueperezbcn1973+test1@gmail.com',
    password_hash,
    NOW(), NOW(),
    jsonb_build_object('full_name', 'María García López'),
    jsonb_build_object('provider', 'email', 'providers', ARRAY['email']),
    NOW(), NOW(),
    '', '', '', ''
  );
  
  -- Crear identity
  INSERT INTO auth.identities (
    provider_id, user_id, identity_data, provider,
    last_sign_in_at, created_at, updated_at
  ) VALUES (
    user1_id::text,
    user1_id,
    jsonb_build_object(
      'sub', user1_id::text,
      'email', 'enriqueperezbcn1973+test1@gmail.com',
      'email_verified', true,
      'phone_verified', true
    ),
    'email',
    NOW(), NOW(), NOW()
  );
  
  -- Actualizar perfil en users (trigger crea el registro básico)
  UPDATE users SET
    email = 'enriqueperezbcn1973@gmail.com',
    full_name = 'María García López',
    phone = '+34612345001',
    address = 'Carrer de Mallorca, 150',
    city = 'Barcelona',
    province = 'Barcelona',
    zip_code = '08029',
    subscription_status = 'active',
    subscription_type = 'brick_pro',
    user_status = 'no_set',
    profile_completed = true,
    stripe_customer_id = 'cus_test_user1_' || substring(user1_id::text, 1, 8),
    stripe_payment_method_id = 'pm_test_card_001',
    pudo_id = brickshare_pudo_id,
    pudo_type = 'brickshare',
    updated_at = NOW()
  WHERE user_id = user1_id;
  
  -- Asignar PUDO Brickshare
  INSERT INTO users_brickshare_dropping (
    user_id, brickshare_pudo_id, location_name,
    address, city, postal_code, province,
    created_at, updated_at
  ) SELECT
    user1_id, brickshare_pudo_id, name,
    address, city, postal_code, province,
    NOW(), NOW()
  FROM brickshare_pudo_locations
  WHERE id = brickshare_pudo_id;
  
  -- Asignar rol user
  INSERT INTO user_roles (user_id, role, created_at)
  VALUES (user1_id, 'user'::app_role, NOW())
  ON CONFLICT (user_id, role) DO NOTHING;
  
  -- Crear wishlist (5 sets)
  FOR i IN 1..5 LOOP
    INSERT INTO wishlist (user_id, set_id, created_at, status)
    VALUES (
      user1_id,
      available_sets[1 + ((i - 1 + (random() * (set_count - 5))::int) % COALESCE(set_count, 1))],
      NOW(),
      true
    )
    ON CONFLICT (user_id, set_id) DO NOTHING;
  END LOOP;
  
  RAISE NOTICE '  ✅ Email: enriqueperezbcn1973+test1@gmail.com';
  RAISE NOTICE '  ✅ Password: Test0test';
  RAISE NOTICE '';
  
  -- ========================================
  -- PASO 3: Crear Usuario 2 - Carlos Martínez Ruiz
  -- ========================================
  
  RAISE NOTICE '👤 Usuario 2: Carlos Martínez Ruiz';
  
  INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, phone_confirmed_at, raw_user_meta_data, raw_app_meta_data, created_at, updated_at, confirmation_token, email_change, email_change_token_new, recovery_token)
  VALUES ('00000000-0000-0000-0000-000000000000', user2_id, 'authenticated', 'authenticated', 'enriqueperezbcn1973+test2@gmail.com', password_hash, NOW(), NOW(), jsonb_build_object('full_name', 'Carlos Martínez Ruiz'), jsonb_build_object('provider', 'email', 'providers', ARRAY['email']), NOW(), NOW(), '', '', '', '');
  
  INSERT INTO auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
  VALUES (user2_id::text, user2_id, jsonb_build_object('sub', user2_id::text, 'email', 'enriqueperezbcn1973+test2@gmail.com', 'email_verified', true, 'phone_verified', true), 'email', NOW(), NOW(), NOW());
  
  UPDATE users SET
    email = 'enriqueperezbcn1973@gmail.com',
    full_name = 'Carlos Martínez Ruiz',
    phone = '+34612345002',
    address = 'Carrer de Sants, 45',
    city = 'Barcelona',
    province = 'Barcelona',
    zip_code = '08014',
    subscription_status = 'active',
    subscription_type = 'brick_pro',
    user_status = 'no_set',
    profile_completed = true,
    stripe_customer_id = 'cus_test_user2_' || substring(user2_id::text, 1, 8),
    stripe_payment_method_id = 'pm_test_card_002',
    pudo_id = brickshare_pudo_id,
    pudo_type = 'brickshare',
    updated_at = NOW()
  WHERE user_id = user2_id;
  
  INSERT INTO users_brickshare_dropping (user_id, brickshare_pudo_id, location_name, address, city, postal_code, province, created_at, updated_at)
  SELECT user2_id, brickshare_pudo_id, name, address, city, postal_code, province, NOW(), NOW()
  FROM brickshare_pudo_locations WHERE id = brickshare_pudo_id;
  
  INSERT INTO user_roles (user_id, role, created_at)
  VALUES (user2_id, 'user'::app_role, NOW())
  ON CONFLICT (user_id, role) DO NOTHING;
  
  FOR i IN 1..5 LOOP
    INSERT INTO wishlist (user_id, set_id, created_at, status)
    VALUES (user2_id, available_sets[1 + ((i - 1 + (random() * (set_count - 5))::int) % COALESCE(set_count, 1))], NOW(), true)
    ON CONFLICT (user_id, set_id) DO NOTHING;
  END LOOP;
  
  RAISE NOTICE '  ✅ Email: enriqueperezbcn1973+test2@gmail.com';
  RAISE NOTICE '';
  
  -- ========================================
  -- PASO 4: Crear Usuario 3 - Laura López Fernández
  -- ========================================
  
  RAISE NOTICE '👤 Usuario 3: Laura López Fernández';
  
  INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, phone_confirmed_at, raw_user_meta_data, raw_app_meta_data, created_at, updated_at, confirmation_token, email_change, email_change_token_new, recovery_token)
  VALUES ('00000000-0000-0000-0000-000000000000', user3_id, 'authenticated', 'authenticated', 'enriqueperezbcn1973+test3@gmail.com', password_hash, NOW(), NOW(), jsonb_build_object('full_name', 'Laura López Fernández'), jsonb_build_object('provider', 'email', 'providers', ARRAY['email']), NOW(), NOW(), '', '', '', '');
  
  INSERT INTO auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
  VALUES (user3_id::text, user3_id, jsonb_build_object('sub', user3_id::text, 'email', 'enriqueperezbcn1973+test3@gmail.com', 'email_verified', true, 'phone_verified', true), 'email', NOW(), NOW(), NOW());
  
  UPDATE users SET
    email = 'enriqueperezbcn1973@gmail.com',
    full_name = 'Laura López Fernández',
    phone = '+34612345003',
    address = 'Carrer Gran de Gràcia, 78',
    city = 'Barcelona',
    province = 'Barcelona',
    zip_code = '08012',
    subscription_status = 'active',
    subscription_type = 'brick_pro',
    user_status = 'no_set',
    profile_completed = true,
    stripe_customer_id = 'cus_test_user3_' || substring(user3_id::text, 1, 8),
    stripe_payment_method_id = 'pm_test_card_003',
    pudo_id = brickshare_pudo_id,
    pudo_type = 'brickshare',
    updated_at = NOW()
  WHERE user_id = user3_id;
  
  INSERT INTO users_brickshare_dropping (user_id, brickshare_pudo_id, location_name, address, city, postal_code, province, created_at, updated_at)
  SELECT user3_id, brickshare_pudo_id, name, address, city, postal_code, province, NOW(), NOW()
  FROM brickshare_pudo_locations WHERE id = brickshare_pudo_id;
  
  INSERT INTO user_roles (user_id, role, created_at)
  VALUES (user3_id, 'user'::app_role, NOW())
  ON CONFLICT (user_id, role) DO NOTHING;
  
  FOR i IN 1..5 LOOP
    INSERT INTO wishlist (user_id, set_id, created_at, status)
    VALUES (user3_id, available_sets[1 + ((i - 1 + (random() * (set_count - 5))::int) % COALESCE(set_count, 1))], NOW(), true)
    ON CONFLICT (user_id, set_id) DO NOTHING;
  END LOOP;
  
  RAISE NOTICE '  ✅ Email: enriqueperezbcn1973+test3@gmail.com';
  RAISE NOTICE '';
  
  -- ========================================
  -- PASO 5: Crear Usuario 4 - Javier Fernández Gil
  -- ========================================
  
  RAISE NOTICE '👤 Usuario 4: Javier Fernández Gil';
  
  INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, phone_confirmed_at, raw_user_meta_data, raw_app_meta_data, created_at, updated_at, confirmation_token, email_change, email_change_token_new, recovery_token)
  VALUES ('00000000-0000-0000-0000-000000000000', user4_id, 'authenticated', 'authenticated', 'enriqueperezbcn1973+test4@gmail.com', password_hash, NOW(), NOW(), jsonb_build_object('full_name', 'Javier Fernández Gil'), jsonb_build_object('provider', 'email', 'providers', ARRAY['email']), NOW(), NOW(), '', '', '', '');
  
  INSERT INTO auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
  VALUES (user4_id::text, user4_id, jsonb_build_object('sub', user4_id::text, 'email', 'enriqueperezbcn1973+test4@gmail.com', 'email_verified', true, 'phone_verified', true), 'email', NOW(), NOW(), NOW());
  
  UPDATE users SET
    email = 'enriqueperezbcn1973@gmail.com',
    full_name = 'Javier Fernández Gil',
    phone = '+34612345004',
    address = 'Carrer de Horta, 23',
    city = 'Barcelona',
    province = 'Barcelona',
    zip_code = '08032',
    subscription_status = 'active',
    subscription_type = 'brick_pro',
    user_status = 'no_set',
    profile_completed = true,
    stripe_customer_id = 'cus_test_user4_' || substring(user4_id::text, 1, 8),
    stripe_payment_method_id = 'pm_test_card_004',
    pudo_id = brickshare_pudo_id,
    pudo_type = 'brickshare',
    updated_at = NOW()
  WHERE user_id = user4_id;
  
  INSERT INTO users_brickshare_dropping (user_id, brickshare_pudo_id, location_name, address, city, postal_code, province, created_at, updated_at)
  SELECT user4_id, brickshare_pudo_id, name, address, city, postal_code, province, NOW(), NOW()
  FROM brickshare_pudo_locations WHERE id = brickshare_pudo_id;
  
  INSERT INTO user_roles (user_id, role, created_at)
  VALUES (user4_id, 'user'::app_role, NOW())
  ON CONFLICT (user_id, role) DO NOTHING;
  
  FOR i IN 1..5 LOOP
    INSERT INTO wishlist (user_id, set_id, created_at, status)
    VALUES (user4_id, available_sets[1 + ((i - 1 + (random() * (set_count - 5))::int) % COALESCE(set_count, 1))], NOW(), true)
    ON CONFLICT (user_id, set_id) DO NOTHING;
  END LOOP;
  
  RAISE NOTICE '  ✅ Email: enriqueperezbcn1973+test4@gmail.com';
  RAISE NOTICE '';
  
  -- ========================================
  -- PASO 6: Crear Usuario 5 - Ana Rodríguez Pérez
  -- ========================================
  
  RAISE NOTICE '👤 Usuario 5: Ana Rodríguez Pérez';
  
  INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, phone_confirmed_at, raw_user_meta_data, raw_app_meta_data, created_at, updated_at, confirmation_token, email_change, email_change_token_new, recovery_token)
  VALUES ('00000000-0000-0000-0000-000000000000', user5_id, 'authenticated', 'authenticated', 'enriqueperezbcn1973+test5@gmail.com', password_hash, NOW(), NOW(), jsonb_build_object('full_name', 'Ana Rodríguez Pérez'), jsonb_build_object('provider', 'email', 'providers', ARRAY['email']), NOW(), NOW(), '', '', '', '');
  
  INSERT INTO auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
  VALUES (user5_id::text, user5_id, jsonb_build_object('sub', user5_id::text, 'email', 'enriqueperezbcn1973+test5@gmail.com', 'email_verified', true, 'phone_verified', true), 'email', NOW(), NOW(), NOW());
  
  UPDATE users SET
    email = 'enriqueperezbcn1973@gmail.com',
    full_name = 'Ana Rodríguez Pérez',
    phone = '+34612345005',
    address = 'Carrer de Sant Andreu, 90',
    city = 'Barcelona',
    province = 'Barcelona',
    zip_code = '08030',
    subscription_status = 'active',
    subscription_type = 'brick_pro',
    user_status = 'no_set',
    profile_completed = true,
    stripe_customer_id = 'cus_test_user5_' || substring(user5_id::text, 1, 8),
    stripe_payment_method_id = 'pm_test_card_005',
    pudo_id = brickshare_pudo_id,
    pudo_type = 'brickshare',
    updated_at = NOW()
  WHERE user_id = user5_id;
  
  INSERT INTO users_brickshare_dropping (user_id, brickshare_pudo_id, location_name, address, city, postal_code, province, created_at, updated_at)
  SELECT user5_id, brickshare_pudo_id, name, address, city, postal_code, province, NOW(), NOW()
  FROM brickshare_pudo_locations WHERE id = brickshare_pudo_id;
  
  INSERT INTO user_roles (user_id, role, created_at)
  VALUES (user5_id, 'user'::app_role, NOW())
  ON CONFLICT (user_id, role) DO NOTHING;
  
  FOR i IN 1..5 LOOP
    INSERT INTO wishlist (user_id, set_id, created_at, status)
    VALUES (user5_id, available_sets[1 + ((i - 1 + (random() * (set_count - 5))::int) % COALESCE(set_count, 1))], NOW(), true)
    ON CONFLICT (user_id, set_id) DO NOTHING;
  END LOOP;
  
  RAISE NOTICE '  ✅ Email: enriqueperezbcn1973+test5@gmail.com';
  RAISE NOTICE '';
  
  -- ========================================
  -- PASO 7: Resumen Final
  -- ========================================
  
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ SEED COMPLETADO EXITOSAMENTE';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'Usuarios creados: 5';
  RAISE NOTICE 'Email: enriqueperezbcn1973+test{1-5}@gmail.com';
  RAISE NOTICE 'Password: Test0test (todos)';
  RAISE NOTICE 'Suscripción: brick_pro (active)';
  RAISE NOTICE 'PUDO: % (Brickshare)', brickshare_pudo_id;
  RAISE NOTICE 'Wishlist: 5 sets por usuario (25 total)';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';

END $$;

-- ========================================
-- VERIFICACIÓN POST-SEED
-- ========================================

RAISE NOTICE '📊 VERIFICACIÓN DE USUARIOS CREADOS';
RAISE NOTICE '====================================';

SELECT 
  RAISE NOTICE '  👤 % | % | %s | %', 
    u.full_name, 
    u.email, 
    u.subscription_type,
    COUNT(w.set_id)
FROM users u
LEFT JOIN wishlist w ON w.user_id = u.user_id
WHERE u.email LIKE 'enriqueperezbcn1973+test%'
GROUP BY u.user_id, u.full_name, u.email, u.subscription_type;

RAISE NOTICE '';
RAISE NOTICE '📋 CANDIDATOS PARA ASIGNACIÓN';
RAISE NOTICE '====================================';

SELECT 
  RAISE NOTICE '  👤 %: %s', u.full_name, COUNT(*)
FROM (
  SELECT * FROM preview_assign_sets_to_users()
  WHERE user_id IN (
    SELECT user_id FROM users WHERE email LIKE 'enriqueperezbcn1973+test%'
  )
) t
JOIN users u ON u.user_id = t.user_id
GROUP BY u.user_id, u.full_name;

RAISE NOTICE '';
RAISE NOTICE '✅ SEED COMPLETADO Y VERIFICADO';