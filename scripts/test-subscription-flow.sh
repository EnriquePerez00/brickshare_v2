#!/bin/bash
# ============================================================================
# Test: Subscription Flow with Stripe Test VISA Card
# ============================================================================
# This script tests the complete subscription flow:
# 1. Sign in test user → get JWT
# 2. Call create-subscription-intent Edge Function
# 3. Confirm payment with Stripe test card 4242424242424242
# 4. Verify subscription in Stripe
# 5. Verify database update
# ============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SUPABASE_URL="http://127.0.0.1:54321"
SUPABASE_ANON_KEY="sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH"
STRIPE_SECRET_KEY="${STRIPE_SECRET_KEY}"
DB_URL="postgresql://postgres:postgres@127.0.0.1:54322/postgres"

# Plan: Brick Starter (19.90 EUR/month)
PLAN_NAME="starter"
PRICE_ID="price_1StxtY7Pc5FKirdFJ7ypGgR3"

TEST_EMAIL="test-sub@brickshare.com"
TEST_PASSWORD="TestSub123!"

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE} Brickshare Subscription Test${NC}"
echo -e "${BLUE} Plan: Brick Starter (19.90 EUR/mes)${NC}"
echo -e "${BLUE} Card: 4242 4242 4242 4242 (Stripe Test VISA)${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# ── Step 0: Check pre-conditions ──────────────────────────────────────────
echo -e "${YELLOW}[Step 0] Checking pre-conditions...${NC}"

echo -n "  Supabase running: "
if curl -s -o /dev/null -w "%{http_code}" "$SUPABASE_URL/rest/v1/" -H "apikey: $SUPABASE_ANON_KEY" | grep -q "200"; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗ Supabase not running!${NC}"
    exit 1
fi

echo -n "  Stripe API key valid: "
STRIPE_CHECK=$(curl -s -o /dev/null -w "%{http_code}" https://api.stripe.com/v1/prices/$PRICE_ID \
    -u "$STRIPE_SECRET_KEY:")
if [ "$STRIPE_CHECK" = "200" ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗ Stripe API key invalid or price not found (HTTP $STRIPE_CHECK)${NC}"
    exit 1
fi

echo ""

# ── Step 1: Sign in and get JWT ───────────────────────────────────────────
echo -e "${YELLOW}[Step 1] Signing in as $TEST_EMAIL...${NC}"

AUTH_RESPONSE=$(curl -s -X POST "$SUPABASE_URL/auth/v1/token?grant_type=password" \
    -H "Content-Type: application/json" \
    -H "apikey: $SUPABASE_ANON_KEY" \
    -d "{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PASSWORD\"}")

ACCESS_TOKEN=$(echo "$AUTH_RESPONSE" | jq -r '.access_token')
USER_ID=$(echo "$AUTH_RESPONSE" | jq -r '.user.id')

if [ "$ACCESS_TOKEN" = "null" ] || [ -z "$ACCESS_TOKEN" ]; then
    echo -e "${RED}  ✗ Authentication failed!${NC}"
    echo "  Error: $(echo "$AUTH_RESPONSE" | jq -r '.msg // .error_description // "unknown"')"
    exit 1
fi

echo -e "${GREEN}  ✓ Authenticated as user: $USER_ID${NC}"
echo ""

# ── Step 2: Check initial DB state ────────────────────────────────────────
echo -e "${YELLOW}[Step 2] Checking initial subscription state in DB...${NC}"

INITIAL_STATE=$(PAGER=cat psql "$DB_URL" -t -A -c "SELECT subscription_status, subscription_type, stripe_customer_id FROM users WHERE user_id = '$USER_ID';" 2>/dev/null)
echo -e "  subscription_status: $(echo $INITIAL_STATE | cut -d'|' -f1)"
echo -e "  subscription_type:   $(echo $INITIAL_STATE | cut -d'|' -f2)"
echo -e "  stripe_customer_id:  $(echo $INITIAL_STATE | cut -d'|' -f3)"
echo ""

# ── Step 3: Call create-subscription-intent Edge Function ─────────────────
echo -e "${YELLOW}[Step 3] Calling create-subscription-intent Edge Function...${NC}"
echo -e "  Plan: $PLAN_NAME | Price ID: $PRICE_ID"

INTENT_RESPONSE=$(curl -s -X POST "$SUPABASE_URL/functions/v1/create-subscription-intent" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "apikey: $SUPABASE_ANON_KEY" \
    -d "{\"plan\":\"$PLAN_NAME\",\"userId\":\"$USER_ID\",\"priceId\":\"$PRICE_ID\"}")

echo "  Raw response: $INTENT_RESPONSE"

SUBSCRIPTION_ID=$(echo "$INTENT_RESPONSE" | jq -r '.subscriptionId')
CLIENT_SECRET=$(echo "$INTENT_RESPONSE" | jq -r '.clientSecret')
ERROR_MSG=$(echo "$INTENT_RESPONSE" | jq -r '.error // empty')

if [ -n "$ERROR_MSG" ]; then
    echo -e "${RED}  ✗ Edge Function error: $ERROR_MSG${NC}"
    exit 1
fi

if [ "$SUBSCRIPTION_ID" = "null" ] || [ -z "$SUBSCRIPTION_ID" ]; then
    echo -e "${RED}  ✗ No subscription ID returned!${NC}"
    exit 1
fi

echo -e "${GREEN}  ✓ Subscription created: $SUBSCRIPTION_ID${NC}"
echo -e "  Client Secret: ${CLIENT_SECRET:0:40}..."
echo ""

# ── Step 4: Verify Stripe customer was created ────────────────────────────
echo -e "${YELLOW}[Step 4] Verifying Stripe customer was created in DB...${NC}"

STRIPE_CUSTOMER=$(PAGER=cat psql "$DB_URL" -t -A -c "SELECT stripe_customer_id FROM users WHERE user_id = '$USER_ID';" 2>/dev/null | tr -d '[:space:]')

if [ -n "$STRIPE_CUSTOMER" ] && [ "$STRIPE_CUSTOMER" != "" ]; then
    echo -e "${GREEN}  ✓ Stripe customer created: $STRIPE_CUSTOMER${NC}"
else
    echo -e "${RED}  ✗ Stripe customer ID not saved in DB${NC}"
    exit 1
fi
echo ""

# ── Step 5: Confirm payment with test VISA card via Stripe API ────────────
echo -e "${YELLOW}[Step 5] Confirming payment with Stripe test VISA card...${NC}"
echo -e "  Card: 4242 4242 4242 4242 | Exp: 12/34 | CVC: 123"

# Extract the PaymentIntent ID from the client secret
PAYMENT_INTENT_ID=$(echo "$CLIENT_SECRET" | cut -d'_' -f1-2)
echo -e "  PaymentIntent ID: $PAYMENT_INTENT_ID"

# Confirm the payment intent with Stripe's test VISA token (pm_card_visa)
CONFIRM_RESPONSE=$(curl -s -X POST "https://api.stripe.com/v1/payment_intents/$PAYMENT_INTENT_ID/confirm" \
    -u "$STRIPE_SECRET_KEY:" \
    -d "payment_method=pm_card_visa")

PAYMENT_STATUS=$(echo "$CONFIRM_RESPONSE" | jq -r '.status')
PAYMENT_ERROR=$(echo "$CONFIRM_RESPONSE" | jq -r '.error.message // empty')

if [ -n "$PAYMENT_ERROR" ]; then
    echo -e "${RED}  ✗ Payment confirmation error: $PAYMENT_ERROR${NC}"
    echo "  Full response: $(echo "$CONFIRM_RESPONSE" | jq -c .)"
    exit 1
fi

echo -e "${GREEN}  ✓ Payment status: $PAYMENT_STATUS${NC}"

if [ "$PAYMENT_STATUS" = "succeeded" ]; then
    echo -e "${GREEN}  ✓ Payment succeeded!${NC}"
elif [ "$PAYMENT_STATUS" = "requires_action" ]; then
    echo -e "${YELLOW}  ⚠ Payment requires action (3D Secure) - test card shouldn't need this${NC}"
else
    echo -e "${YELLOW}  ⚠ Payment status: $PAYMENT_STATUS${NC}"
fi
echo ""

# ── Step 6: Verify subscription is active in Stripe ──────────────────────
echo -e "${YELLOW}[Step 6] Verifying subscription status in Stripe...${NC}"

sleep 2  # Wait for Stripe to process

STRIPE_SUB=$(curl -s "https://api.stripe.com/v1/subscriptions/$SUBSCRIPTION_ID" \
    -u "$STRIPE_SECRET_KEY:")

STRIPE_SUB_STATUS=$(echo "$STRIPE_SUB" | jq -r '.status')
STRIPE_SUB_PLAN=$(echo "$STRIPE_SUB" | jq -r '.metadata.plan')
STRIPE_SUB_PRICE=$(echo "$STRIPE_SUB" | jq -r '.items.data[0].price.unit_amount')

echo -e "  Stripe Subscription Status: ${GREEN}$STRIPE_SUB_STATUS${NC}"
echo -e "  Plan metadata: $STRIPE_SUB_PLAN"
echo -e "  Price: $(echo "scale=2; $STRIPE_SUB_PRICE / 100" | bc) EUR/month"
echo ""

# ── Step 7: Check if webhook updated the database ────────────────────────
echo -e "${YELLOW}[Step 7] Checking database after payment (webhook may take a moment)...${NC}"

# Wait a bit for webhook processing
sleep 3

FINAL_STATE=$(PAGER=cat psql "$DB_URL" -t -A -c "SELECT subscription_status, subscription_type, stripe_customer_id FROM users WHERE user_id = '$USER_ID';" 2>/dev/null)
FINAL_SUB_STATUS=$(echo "$FINAL_STATE" | cut -d'|' -f1 | tr -d '[:space:]')
FINAL_SUB_TYPE=$(echo "$FINAL_STATE" | cut -d'|' -f2 | tr -d '[:space:]')
FINAL_STRIPE_CID=$(echo "$FINAL_STATE" | cut -d'|' -f3 | tr -d '[:space:]')

echo -e "  subscription_status: $FINAL_SUB_STATUS"
echo -e "  subscription_type:   $FINAL_SUB_TYPE"
echo -e "  stripe_customer_id:  $FINAL_STRIPE_CID"
echo ""

# ── Summary ──────────────────────────────────────────────────────────────
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE} TEST RESULTS SUMMARY${NC}"
echo -e "${BLUE}============================================${NC}"

PASS=0
FAIL=0

# Test 1: Edge Function worked
if [ "$SUBSCRIPTION_ID" != "null" ] && [ -n "$SUBSCRIPTION_ID" ]; then
    echo -e "${GREEN}  ✓ PASS: Edge Function create-subscription-intent works${NC}"
    ((PASS++))
else
    echo -e "${RED}  ✗ FAIL: Edge Function did not return subscription${NC}"
    ((FAIL++))
fi

# Test 2: Stripe customer created
if [ -n "$STRIPE_CUSTOMER" ]; then
    echo -e "${GREEN}  ✓ PASS: Stripe customer created and saved in DB${NC}"
    ((PASS++))
else
    echo -e "${RED}  ✗ FAIL: Stripe customer not in DB${NC}"
    ((FAIL++))
fi

# Test 3: Payment succeeded
if [ "$PAYMENT_STATUS" = "succeeded" ]; then
    echo -e "${GREEN}  ✓ PASS: Payment with test VISA card succeeded${NC}"
    ((PASS++))
else
    echo -e "${RED}  ✗ FAIL: Payment status is $PAYMENT_STATUS (expected: succeeded)${NC}"
    ((FAIL++))
fi

# Test 4: Stripe subscription active
if [ "$STRIPE_SUB_STATUS" = "active" ]; then
    echo -e "${GREEN}  ✓ PASS: Stripe subscription is active${NC}"
    ((PASS++))
else
    echo -e "${YELLOW}  ⚠ WARN: Stripe subscription status is $STRIPE_SUB_STATUS (expected: active)${NC}"
    ((FAIL++))
fi

# Test 5: DB updated via webhook (may not work without Stripe CLI forwarding)
if [ "$FINAL_SUB_STATUS" = "active" ]; then
    echo -e "${GREEN}  ✓ PASS: Database subscription_status updated to 'active'${NC}"
    ((PASS++))
else
    echo -e "${YELLOW}  ⚠ NOTE: Database subscription_status is '$FINAL_SUB_STATUS' (webhook may not be forwarded locally)${NC}"
    echo -e "${YELLOW}         This is expected without 'stripe listen --forward-to' running${NC}"
fi

echo ""
echo -e "${BLUE}  Results: ${GREEN}$PASS passed${NC}, ${RED}$FAIL failed${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""
echo -e "${YELLOW}NOTE: To test webhook locally, run:${NC}"
echo -e "  stripe listen --forward-to http://127.0.0.1:54321/functions/v1/stripe-webhook"
echo ""

# Cleanup info
echo -e "${YELLOW}Cleanup: To cancel test subscription in Stripe:${NC}"
echo -e "  curl -s -X DELETE https://api.stripe.com/v1/subscriptions/$SUBSCRIPTION_ID -u '$STRIPE_SECRET_KEY:'"
echo ""