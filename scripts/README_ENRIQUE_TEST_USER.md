# Test User: enriquepeto@yahoo.es

## User Details

Created: March 24, 2026

### Credentials
- **Email**: enriquepeto@yahoo.es
- **Password**: User1test

### Profile Information
- **Full Name**: Enrique Perez
- **Phone**: +34600123456
- **Address**: Calle Test 123, 28001 Madrid
- **Profile Completed**: Yes
- **Impact Points**: 500

### Subscription Details
- **Type**: Brick Master (Premium tier)
- **Status**: Active
- **Start Date**: Current date
- **End Date**: 1 year from creation
- **Stripe Customer ID**: `cus_test_enrique_*`
- **Stripe Subscription ID**: `sub_test_enrique_*`
- **Payment Method**: `pm_card_visa` (Stripe test card)

### Wishlist
The user has 5 LEGO sets added to their wishlist with priority ordering (1-5).

### User Role
- **Role**: user (standard customer)

## Usage

### Login via UI
1. Navigate to http://localhost:5173
2. Click "Iniciar sesión"
3. Enter email: `enriquepeto@yahoo.es`
4. Enter password: `User1test`

### Test Password Recovery
1. Click "¿Olvidaste tu contraseña?"
2. Enter email: `enriquepeto@yahoo.es`
3. Check Mailpit at http://127.0.0.1:54334 for recovery email

### Access Dashboard
After login, the user will be redirected to `/dashboard` with full access to:
- Catalog browsing
- Wishlist management
- Subscription details
- Shipment tracking
- Profile settings

## Technical Details

### Database Tables Populated
1. **auth.users** - Authentication credentials
2. **auth.identities** - Email provider identity
3. **users** - User profile and subscription data
4. **user_roles** - Role assignment (user)
5. **wishlist** - 5 LEGO sets with priorities

### Stripe Test Data
- Customer ID: Test format `cus_test_enrique_*`
- Subscription ID: Test format `sub_test_enrique_*`
- Payment Method: `pm_card_visa` (Always succeeds in test mode)

### How It Was Created

```bash
# Execute the creation script
psql postgresql://postgres:postgres@127.0.0.1:5433/postgres -f scripts/create-enrique-test-user.sql
```

### Verification Queries

```sql
-- Check auth user
SELECT id, email, email_confirmed_at 
FROM auth.users 
WHERE email = 'enriquepeto@yahoo.es';

-- Check user profile
SELECT user_id, email, subscription_type, subscription_status, stripe_payment_method_id
FROM users 
WHERE email = 'enriquepeto@yahoo.es';

-- Check wishlist
SELECT w.set_id, s.set_ref, s.name, w.priority 
FROM wishlist w
JOIN sets s ON s.set_id = w.set_id
JOIN users u ON u.user_id = w.user_id
WHERE u.email = 'enriquepeto@yahoo.es'
ORDER BY w.priority;
```

## Notes

- This is a **test user** for local development
- The password is hashed using bcrypt
- Email is confirmed automatically (email_confirmed_at is set)
- All Stripe IDs are test format and won't work with real Stripe API
- The user has a Brick Master subscription (highest tier)
- 5 sets were selected from available inventory and added to wishlist

## Cleanup

To delete this test user:

```sql
DO $$
DECLARE
  v_user_id uuid;
BEGIN
  -- Get user ID
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'enriquepeto@yahoo.es';
  
  -- Delete in reverse order of foreign keys
  DELETE FROM wishlist WHERE user_id = v_user_id;
  DELETE FROM user_roles WHERE user_id = v_user_id;
  DELETE FROM users WHERE user_id = v_user_id;
  DELETE FROM auth.identities WHERE user_id = v_user_id;
  DELETE FROM auth.users WHERE id = v_user_id;
  
  RAISE NOTICE 'Test user deleted successfully';
END $$;