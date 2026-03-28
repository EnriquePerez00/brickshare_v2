#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# Reset Auth Users and Create Test Users
# ═══════════════════════════════════════════════════════════════
# This script:
# 1. Clears all users from auth.users and public.users
# 2. Creates 3 test users with complete profiles
# 3. Assigns proper roles (admin and user)
#
# TEST USERS:
# - admin@brickshare.com / Admin1test (admin role)
# - enriquepeto@yahoo.es / User1test (user role)
# - user2@brickshare.com / User2test (user role)
# - user3@brickshare.com / User3test (user role)
#
# Usage: ./scripts/reset-auth-users.sh
# ═══════════════════════════════════════════════════════════════

set -e  # Exit on error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  🔄 Reset Auth Users & Create Test Users${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Verificar que Supabase esté corriendo
if ! supabase status > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: Supabase no está corriendo${NC}"
    echo -e "${YELLOW}💡 Ejecuta: supabase start${NC}"
    exit 1
fi

# Verificar que estamos en entorno local
DB_URL=$(supabase status 2>&1 | grep -E "URL.*postgresql" | grep -oE "postgresql://[^[:space:]]+")
if [[ -z "$DB_URL" ]] || [[ ! "$DB_URL" =~ "127.0.0.1" ]] && [[ ! "$DB_URL" =~ "localhost" ]]; then
    echo -e "${YELLOW}⚠️  No se pudo detectar la DB URL automáticamente${NC}"
    echo -e "${YELLOW}   Asumiendo entorno local (127.0.0.1:5433)${NC}"
    DB_URL="postgresql://postgres:postgres@127.0.0.1:5433/postgres"
fi

echo -e "${GREEN}✅ Conectando a: ${DB_URL}${NC}"

echo -e "${YELLOW}⚠️  ADVERTENCIA: Esta operación eliminará TODOS los usuarios existentes${NC}"
echo -e "${YELLOW}   y creará 3 nuevos usuarios de prueba.${NC}"
echo ""
echo -e "${CYAN}Usuarios que se crearán:${NC}"
echo -e "  1. ${GREEN}admin@brickshare.com${NC} / Admin1test ${BLUE}(admin)${NC}"
echo -e "  2. ${GREEN}enriquepeto@yahoo.es${NC} / User1test ${BLUE}(user)${NC}"
echo -e "  3. ${GREEN}user2@brickshare.com${NC} / User2test ${BLUE}(user)${NC}"
echo -e "  4. ${GREEN}user3@brickshare.com${NC} / User3test ${BLUE}(user)${NC}"
echo ""
echo -e "${YELLOW}Todos tendrán:${NC}"
echo -e "  - Suscripción: brick_master (activa)"
echo -e "  - Dirección: Josep Tarradellas 97-101, Barcelona 08029"
echo -e "  - Método de pago: pm_card_visa"
echo ""
read -p "¿Continuar? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Operación cancelada${NC}"
    exit 1
fi

# Usar la URL de conexión detectada o la por defecto
PSQL_URL="${DB_URL:-postgresql://postgres:postgres@127.0.0.1:5433/postgres}"

echo ""
echo -e "${YELLOW}🗑️  Eliminando usuarios existentes...${NC}"

# Ejecutar SQL para limpiar usuarios
psql "${PSQL_URL}" <<'EOSQL'
-- Desactivar triggers temporalmente para evitar conflictos
SET session_replication_role = replica;

-- Eliminar datos relacionados con usuarios
DELETE FROM public.wishlist;
DELETE FROM public.reviews;
DELETE FROM public.referrals;
DELETE FROM public.shipments;
DELETE FROM public.donations;
DELETE FROM public.users_correos_dropping;
DELETE FROM public.reception_operations;
DELETE FROM public.backoffice_operations;
DELETE FROM public.shipping_orders;
DELETE FROM public.qr_validation_logs;

-- Eliminar roles de usuarios
DELETE FROM public.user_roles;

-- Eliminar usuarios de la tabla pública
DELETE FROM public.users;

-- Eliminar de auth.identities
DELETE FROM auth.identities;

-- Eliminar de auth.users
DELETE FROM auth.users;

-- Reactivar triggers
SET session_replication_role = DEFAULT;

\echo '✅ Usuarios eliminados'
EOSQL

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Usuarios eliminados exitosamente${NC}"
else
    echo -e "${RED}❌ Error al eliminar usuarios${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}👥 Creando usuarios de prueba...${NC}"

# Crear usuarios
psql "${PSQL_URL}" <<'EOSQL'
-- =====================================================
-- Create 3 Test Users
-- =====================================================

DO $$
DECLARE
  v_admin_id uuid;
  v_user1_id uuid;
  v_user2_id uuid;
BEGIN
  
  -- ===========================================
  -- USER 1: ADMIN
  -- ===========================================
  
  INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_user_meta_data,
    raw_app_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'admin@brickshare.com',
    crypt('Admin1test', gen_salt('bf')),
    NOW(),
    '{"full_name": "Admin Brickshare"}'::jsonb,
    '{"provider": "email", "providers": ["email"]}'::jsonb,
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
  )
  RETURNING id INTO v_admin_id;

  -- Create identity for admin
  INSERT INTO auth.identities (
    provider_id,
    user_id,
    identity_data,
    provider,
    last_sign_in_at,
    created_at,
    updated_at
  ) VALUES (
    v_admin_id::text,
    v_admin_id,
    jsonb_build_object(
      'sub', v_admin_id::text,
      'email', 'admin@brickshare.com',
      'email_verified', false,
      'phone_verified', false
    ),
    'email',
    NOW(),
    NOW(),
    NOW()
  );

  -- Update profile (trigger already created basic record)
  UPDATE public.users SET
    full_name = 'Admin Brickshare',
    phone = '+34600123456',
    address = 'Josep Tarradellas 97-101',
    city = 'Barcelona',
    zip_code = '08029',
    subscription_status = 'active',
    subscription_type = 'brick_master',
    user_status = 'no_set',
    stripe_customer_id = 'cus_test_admin_' || substring(v_admin_id::text, 1, 8),
    stripe_payment_method_id = 'pm_card_visa',
    profile_completed = true,
    impact_points = 1000,
    pudo_type = 'brickshare',
    pudo_id = 'brickshare-001',
    updated_at = NOW()
  WHERE user_id = v_admin_id;

  -- Replace 'user' role with 'admin' role (trigger created 'user' by default)
  DELETE FROM public.user_roles WHERE user_id = v_admin_id AND role = 'user';
  INSERT INTO public.user_roles (user_id, role)
  VALUES (v_admin_id, 'admin');

  RAISE NOTICE '✅ Created: admin@brickshare.com (admin role) - ID: %', v_admin_id;

  -- ===========================================
  -- USER 2: ENRIQUE PEREZ
  -- ===========================================
  
  INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_user_meta_data,
    raw_app_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'enriquepeto@yahoo.es',
    crypt('User1test', gen_salt('bf')),
    NOW(),
    '{"full_name": "Enrique Perez"}'::jsonb,
    '{"provider": "email", "providers": ["email"]}'::jsonb,
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
  )
  RETURNING id INTO v_user1_id;

  -- Create identity
  INSERT INTO auth.identities (
    provider_id,
    user_id,
    identity_data,
    provider,
    last_sign_in_at,
    created_at,
    updated_at
  ) VALUES (
    v_user1_id::text,
    v_user1_id,
    jsonb_build_object(
      'sub', v_user1_id::text,
      'email', 'enriquepeto@yahoo.es',
      'email_verified', false,
      'phone_verified', false
    ),
    'email',
    NOW(),
    NOW(),
    NOW()
  );

  -- Update profile (trigger already created basic record)
  UPDATE public.users SET
    full_name = 'Enrique Perez',
    phone = '+34600123456',
    address = 'Josep Tarradellas 97-101',
    city = 'Barcelona',
    zip_code = '08029',
    subscription_status = 'active',
    subscription_type = 'brick_master',
    user_status = 'no_set',
    stripe_customer_id = 'cus_UCxWpVAhXeYpSQ',
    stripe_payment_method_id = 'pm_card_visa',
    profile_completed = true,
    impact_points = 500,
    pudo_type = 'brickshare',
    pudo_id = 'brickshare-001',
    updated_at = NOW()
  WHERE user_id = v_user1_id;

  -- 'user' role already assigned by trigger, no need to insert again

  RAISE NOTICE '✅ Created: enriquepeto@yahoo.es (user role) - ID: %', v_user1_id;

  -- ===========================================
  -- USER 3: USER2
  -- ===========================================
  
  INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_user_meta_data,
    raw_app_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'user2@brickshare.com',
    crypt('User2test', gen_salt('bf')),
    NOW(),
    '{"full_name": "User Two"}'::jsonb,
    '{"provider": "email", "providers": ["email"]}'::jsonb,
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
  )
  RETURNING id INTO v_user2_id;

  -- Create identity
  INSERT INTO auth.identities (
    provider_id,
    user_id,
    identity_data,
    provider,
    last_sign_in_at,
    created_at,
    updated_at
  ) VALUES (
    v_user2_id::text,
    v_user2_id,
    jsonb_build_object(
      'sub', v_user2_id::text,
      'email', 'user2@brickshare.com',
      'email_verified', false,
      'phone_verified', false
    ),
    'email',
    NOW(),
    NOW(),
    NOW()
  );

  -- Update profile (trigger already created basic record)
  UPDATE public.users SET
    full_name = 'User Two',
    phone = '+34600123456',
    address = 'Josep Tarradellas 97-101',
    city = 'Barcelona',
    zip_code = '08029',
    subscription_status = 'active',
    subscription_type = 'brick_master',
    user_status = 'no_set',
    stripe_customer_id = 'cus_UCyIEEkZdixSTI',
    stripe_payment_method_id = 'pm_card_visa',
    profile_completed = true,
    impact_points = 500,
    pudo_type = 'brickshare',
    pudo_id = 'brickshare-001',
    updated_at = NOW()
  WHERE user_id = v_user2_id;

  -- 'user' role already assigned by trigger, no need to insert again

  RAISE NOTICE '✅ Created: user2@brickshare.com (user role) - ID: %', v_user2_id;

  -- ===========================================
  -- USER 4: USER3
  -- ===========================================
  
  INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_user_meta_data,
    raw_app_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'user3@brickshare.com',
    crypt('User3test', gen_salt('bf')),
    NOW(),
    '{"full_name": "user3"}'::jsonb,
    '{"provider": "email", "providers": ["email"]}'::jsonb,
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
  )
  RETURNING id INTO v_user2_id;

  -- Create identity
  INSERT INTO auth.identities (
    provider_id,
    user_id,
    identity_data,
    provider,
    last_sign_in_at,
    created_at,
    updated_at
  ) VALUES (
    v_user2_id::text,
    v_user2_id,
    jsonb_build_object(
      'sub', v_user2_id::text,
      'email', 'user3@brickshare.com',
      'email_verified', false,
      'phone_verified', false
    ),
    'email',
    NOW(),
    NOW(),
    NOW()
  );

  -- Update profile (trigger already created basic record)
  UPDATE public.users SET
    full_name = 'user3',
    phone = '+34600123456',
    address = 'Josep Tarradellas 97-101',
    city = 'Barcelona',
    zip_code = '08029',
    subscription_status = 'active',
    subscription_type = 'brick_master',
    user_status = 'no_set',
    stripe_customer_id = 'cus_TrZatopplfcVJp',
    stripe_payment_method_id = 'pm_card_visa',
    profile_completed = true,
    impact_points = 500,
    pudo_type = 'brickshare',
    pudo_id = 'brickshare-001',
    updated_at = NOW()
  WHERE user_id = v_user2_id;

  -- 'user' role already assigned by trigger, no need to insert again

  RAISE NOTICE '✅ Created: user3@brickshare.com (user role) - ID: %', v_user2_id;

  RAISE NOTICE '';
  RAISE NOTICE '==============================================';
  RAISE NOTICE '✅ All users created successfully!';
  RAISE NOTICE '==============================================';

END $$;

-- Verify creation
\echo ''
\echo '📊 Usuarios creados:'
\echo ''

SELECT 
  u.email,
  u.full_name,
  ur.role,
  u.subscription_type,
  u.subscription_status,
  u.city,
  u.stripe_payment_method_id
FROM public.users u
LEFT JOIN public.user_roles ur ON ur.user_id = u.user_id
ORDER BY ur.role DESC, u.email;

EOSQL

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✅ Usuarios creados exitosamente${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}📋 Credenciales de acceso:${NC}"
    echo ""
    echo -e "${GREEN}1. Admin User:${NC}"
    echo -e "   Email:    ${YELLOW}admin@brickshare.com${NC}"
    echo -e "   Password: ${YELLOW}Admin1test${NC}"
    echo -e "   Role:     ${BLUE}admin${NC}"
    echo ""
    echo -e "${GREEN}2. Enrique Perez:${NC}"
    echo -e "   Email:    ${YELLOW}enriquepeto@yahoo.es${NC}"
    echo -e "   Password: ${YELLOW}User1test${NC}"
    echo -e "   Role:     ${BLUE}user${NC}"
    echo ""
echo -e "${GREEN}3. User Two:${NC}"
echo -e "   Email:    ${YELLOW}user2@brickshare.com${NC}"
echo -e "   Password: ${YELLOW}User2test${NC}"
echo -e "   Role:     ${BLUE}user${NC}"
echo ""
echo -e "${GREEN}4. User Three:${NC}"
echo -e "   Email:    ${YELLOW}user3@brickshare.com${NC}"
echo -e "   Password: ${YELLOW}User3test${NC}"
echo -e "   Role:     ${BLUE}user${NC}"
echo ""
    echo -e "${CYAN}📍 Todos los usuarios tienen:${NC}"
    echo -e "   • Suscripción: brick_master (activa)"
    echo -e "   • Dirección: Josep Tarradellas 97-101, Barcelona 08029"
    echo -e "   • Teléfono: +34600123456"
    echo -e "   • Método de pago: pm_card_visa"
    echo -e "   • Perfil completo: Sí"
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
else
    echo ""
    echo -e "${RED}❌ Error al crear usuarios${NC}"
    exit 1
fi