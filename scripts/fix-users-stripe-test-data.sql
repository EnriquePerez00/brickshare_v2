-- ============================================================================
-- Fix Users: Add Email and Stripe Test Data
-- ============================================================================
-- Purpose: Configure all existing users with:
--   1. Email (enriquepeto@yahoo.es)
--   2. Stripe test Customer ID
--   3. Stripe test Payment Method ID (pm_card_visa)
--   4. Active subscription status
-- ============================================================================

BEGIN;

-- Step 1: Update all users with email and Stripe test data
-- Excludes users who already have valid stripe_payment_method_id
UPDATE public.users
SET 
  email = COALESCE(NULLIF(email, ''), 'enriquepeto@yahoo.es'),
  stripe_customer_id = CASE 
    WHEN stripe_customer_id IS NULL OR stripe_customer_id = '' 
    THEN 'cus_test_' || SUBSTRING(user_id::text, 1, 12)
    ELSE stripe_customer_id
  END,
  stripe_payment_method_id = CASE
    WHEN stripe_payment_method_id IS NULL OR stripe_payment_method_id = ''
    THEN 'pm_card_visa'  -- Stripe test card (always succeeds)
    ELSE stripe_payment_method_id
  END,
  subscription_status = COALESCE(NULLIF(subscription_status, ''), 'active'),
  updated_at = NOW()
WHERE 
  -- Only update users without complete Stripe setup
  (email IS NULL OR email = '' 
   OR stripe_customer_id IS NULL OR stripe_customer_id = ''
   OR stripe_payment_method_id IS NULL OR stripe_payment_method_id = ''
   OR subscription_status IS NULL OR subscription_status = '');

-- Step 2: Sync email to auth.users if user exists there
-- (In case some users were created in both tables)
UPDATE auth.users au
SET 
  email = 'enriquepeto@yahoo.es',
  email_confirmed_at = COALESCE(email_confirmed_at, NOW())
FROM public.users u
WHERE au.id = u.user_id
  AND (au.email IS NULL OR au.email = '' OR au.email != u.email);

-- Step 3: Show summary of changes
SELECT 
  'Summary' as report_type,
  COUNT(*) as total_users,
  COUNT(*) FILTER (WHERE email = 'enriquepeto@yahoo.es') as users_with_email,
  COUNT(*) FILTER (WHERE stripe_customer_id LIKE 'cus_test_%') as users_with_test_customer,
  COUNT(*) FILTER (WHERE stripe_payment_method_id = 'pm_card_visa') as users_with_test_pm,
  COUNT(*) FILTER (WHERE subscription_status = 'active') as users_with_active_sub
FROM public.users;

-- Step 4: Show users ready for assignment
SELECT 
  user_id,
  full_name,
  email,
  user_status,
  stripe_customer_id,
  stripe_payment_method_id,
  subscription_status,
  (SELECT COUNT(*) FROM wishlist w WHERE w.user_id = u.user_id AND w.status = true) as wishlist_count
FROM public.users u
WHERE user_status IN ('no_set', 'set_returning')
  -- Exclude admin/operador roles
  AND NOT EXISTS (
    SELECT 1 FROM user_roles ur
    WHERE ur.user_id = u.user_id
    AND ur.role IN ('admin', 'operador')
  )
ORDER BY full_name;

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES (uncomment to run individually)
-- ============================================================================

-- Query 1: Check all users configuration
-- SELECT 
--   user_id,
--   full_name,
--   email,
--   stripe_customer_id,
--   stripe_payment_method_id,
--   subscription_status,
--   user_status
-- FROM public.users
-- ORDER BY created_at DESC;

-- Query 2: Test assignment preview (should now work without errors)
-- SELECT * FROM preview_assign_sets_to_users();