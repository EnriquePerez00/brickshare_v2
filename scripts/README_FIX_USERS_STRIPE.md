# Fix Users Stripe Test Data

## Purpose
Configure existing users with test email and Stripe test credentials to allow assignment flow testing.

## What it does

1. **Email**: Sets `enriquepeto@yahoo.es` for all users without email
2. **Stripe Customer ID**: Generates test ID format `cus_test_XXXXXXXXXXXX`
3. **Stripe Payment Method**: Uses `pm_card_visa` (Stripe permanent test card)
4. **Subscription**: Sets status to `active` if missing

## Usage

```bash
# Connect to local Supabase database
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres

# Run the script
\i scripts/fix-users-stripe-test-data.sql

# Or run directly with psql
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres < scripts/fix-users-stripe-test-data.sql
```

## Verification

After running, verify users are ready:

```sql
-- Check user configuration
SELECT 
  full_name,
  email,
  stripe_customer_id,
  stripe_payment_method_id,
  subscription_status,
  user_status
FROM users
WHERE user_status IN ('no_set', 'set_returning');

-- Test assignment preview
SELECT * FROM preview_assign_sets_to_users();
```

## Stripe Test Cards Reference

The script uses `pm_card_visa` which is a permanent Stripe test payment method that:
- ✅ Always succeeds for charges
- ✅ No need to create it (permanent test ID)
- ✅ Works with any test Customer ID

Other available test payment methods:
- `pm_card_mastercard` - Mastercard
- `pm_card_amex` - American Express
- `pm_card_chargeDeclined` - Always fails (for error testing)
- `pm_card_insufficientFunds` - Insufficient funds error

## Important Notes

⚠️ **This is for LOCAL TESTING only**
- Uses fake Stripe IDs that won't work in production
- Email is shared across all users (for testing)
- Real users need real Stripe setup via checkout flow

⚠️ **Production Setup**
For production, users must:
1. Complete real signup via Supabase Auth
2. Complete checkout flow with real payment method
3. Stripe webhook will set real customer_id and payment_method_id

## What Gets Updated

| Field | Value | Condition |
|-------|-------|-----------|
| `email` | `enriquepeto@yahoo.es` | If NULL or empty |
| `stripe_customer_id` | `cus_test_` + user_id | If NULL or empty |
| `stripe_payment_method_id` | `pm_card_visa` | If NULL or empty |
| `subscription_status` | `active` | If NULL or empty |

## After Running

Users should now be able to:
1. ✅ Pass payment processing validation in `process-assignment-payment` Edge Function
2. ✅ Appear in `preview_assign_sets_to_users()` results
3. ✅ Successfully complete the "Confirmar asignaciones" flow
4. ✅ Have test payments created in Stripe (won't actually charge)

## Troubleshooting

### Error: "Usuario no tiene método de pago configurado"
- Run this script to add `pm_card_visa` to all users
- Verify with: `SELECT stripe_payment_method_id FROM users;`

### Error: "Email no disponible"
- Ensure script completed successfully
- Check: `SELECT email FROM users WHERE email IS NULL;`

### Test Payments Failing
- Remember: `pm_card_visa` only works in Stripe **test mode**
- Verify `STRIPE_SECRET_KEY` in `.env.local` starts with `<your_stripe_secret_key>`
- Check Stripe Dashboard → Developers → API keys