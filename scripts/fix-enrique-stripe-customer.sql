-- Fix stripe_customer_id for enrique peto user
-- This user needs a valid Stripe customer ID to test payment flows

-- First, let's see current state
SELECT user_id, email, full_name, stripe_customer_id, subscription_status 
FROM users 
WHERE email = 'enriquepeto@yahoo.es';

-- OPTION 1: Set to NULL to trigger customer creation on next subscription
-- UPDATE users 
-- SET stripe_customer_id = NULL
-- WHERE email = 'enriquepeto@yahoo.es';

-- OPTION 2: You need to create a customer in Stripe Dashboard first, then update with real ID
-- Go to: https://dashboard.stripe.com/test/customers
-- Create a customer with email: enriquepeto@yahoo.es
-- Add a test payment method (card: 4242 4242 4242 4242)
-- Then run:
-- UPDATE users 
-- SET stripe_customer_id = 'cus_XXXXXXXXXXXXXX'  -- Replace with real customer ID
-- WHERE email = 'enriquepeto@yahoo.es';

-- Verify the change
SELECT user_id, email, full_name, stripe_customer_id, subscription_status 
FROM users 
WHERE email = 'enriquepeto@yahoo.es';