#!/bin/bash
# Test Complete Flow: Assignment + Email with QR
# This script tests the complete set assignment flow with automatic email sending

set -e

echo "🚀 Starting Complete Flow Test with Email..."
echo "=============================================="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get Supabase credentials
SUPABASE_URL="http://127.0.0.1:54321"
SERVICE_ROLE_KEY=$(supabase status | grep "service_role_key:" | awk '{print $NF}')
ANON_KEY=$(supabase status | grep "anon_key:" | awk '{print $NF}')

if [ -z "$SERVICE_ROLE_KEY" ] || [ -z "$ANON_KEY" ]; then
  echo -e "${YELLOW}Warning: Could not extract Supabase keys. Make sure Supabase is running.${NC}"
  echo "Run: supabase start"
  exit 1
fi

echo -e "${BLUE}Supabase URL: $SUPABASE_URL${NC}"
echo -e "${BLUE}Service Role Key: ${SERVICE_ROLE_KEY:0:20}...${NC}"

# ============================================================
# STEP 1: Get user enriquepeto@yahoo.es
# ============================================================
echo -e "\n${YELLOW}Step 1: Fetching user enriquepeto@yahoo.es...${NC}"

USER_RESPONSE=$(curl -s -X GET \
  "$SUPABASE_URL/rest/v1/users?email=eq.enriquepeto@yahoo.es" \
  -H "Authorization: Bearer $SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json")

USER_ID=$(echo $USER_RESPONSE | jq -r '.[0].user_id // empty')

if [ -z "$USER_ID" ]; then
  echo -e "${YELLOW}User not found. Creating test user...${NC}"
  exit 1
else
  echo -e "${GREEN}✓ User found: $USER_ID${NC}"
fi

# ============================================================
# STEP 2: Check user's PUDO
# ============================================================
echo -e "\n${YELLOW}Step 2: Checking user's PUDO configuration...${NC}"

PUDO_RESPONSE=$(curl -s -X GET \
  "$SUPABASE_URL/rest/v1/users_correos_dropping?user_id=eq.$USER_ID" \
  -H "Authorization: Bearer $SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json")

PUDO_ID=$(echo $PUDO_RESPONSE | jq -r '.[0].correos_id_pudo // empty')

if [ -z "$PUDO_ID" ]; then
  echo -e "${YELLOW}⚠ No PUDO configured for user${NC}"
else
  echo -e "${GREEN}✓ PUDO ID: $PUDO_ID${NC}"
fi

# ============================================================
# STEP 3: Check wishlist
# ============================================================
echo -e "\n${YELLOW}Step 3: Checking user's wishlist...${NC}"

WISHLIST_RESPONSE=$(curl -s -X GET \
  "$SUPABASE_URL/rest/v1/wishlist?user_id=eq.$USER_ID&status=eq.true" \
  -H "Authorization: Bearer $SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json")

SET_ID=$(echo $WISHLIST_RESPONSE | jq -r '.[0].set_id // empty')

if [ -z "$SET_ID" ]; then
  echo -e "${YELLOW}⚠ No sets in wishlist${NC}"
else
  echo -e "${GREEN}✓ Set in wishlist: $SET_ID${NC}"
fi

# ============================================================
# STEP 4: Execute assignment
# ============================================================
echo -e "\n${YELLOW}Step 4: Executing assignment for user...${NC}"

ASSIGNMENT_RESPONSE=$(curl -s -X POST \
  "$SUPABASE_URL/rest/v1/rpc/confirm_assign_sets_to_users" \
  -H "Authorization: Bearer $SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -d "[\"$USER_ID\"]")

SHIPMENT_ID=$(echo $ASSIGNMENT_RESPONSE | jq -r '.[0].envio_id // empty')
USER_EMAIL=$(echo $ASSIGNMENT_RESPONSE | jq -r '.[0].user_email // empty')

if [ -z "$SHIPMENT_ID" ]; then
  echo -e "${YELLOW}⚠ No shipment created. Response:${NC}"
  echo $ASSIGNMENT_RESPONSE
else
  echo -e "${GREEN}✓ Shipment created: $SHIPMENT_ID${NC}"
  echo -e "${GREEN}✓ User email: $USER_EMAIL${NC}"
fi

# ============================================================
# STEP 5: Send QR email manually
# ============================================================
if [ ! -z "$SHIPMENT_ID" ]; then
  echo -e "\n${YELLOW}Step 5: Sending QR email to user...${NC}"

  EMAIL_RESPONSE=$(curl -s -X POST \
    "$SUPABASE_URL/functions/v1/send-brickshare-qr-email" \
    -H "Authorization: Bearer $SERVICE_ROLE_KEY" \
    -H "Content-Type: application/json" \
    -d "{
      \"shipment_id\": \"$SHIPMENT_ID\",
      \"type\": \"delivery\"
    }")

  EMAIL_ID=$(echo $EMAIL_RESPONSE | jq -r '.email_id // empty')
  QR_CODE=$(echo $EMAIL_RESPONSE | jq -r '.qr_code // empty')

  if [ -z "$EMAIL_ID" ]; then
    echo -e "${YELLOW}⚠ Email send response:${NC}"
    echo $EMAIL_RESPONSE
  else
    echo -e "${GREEN}✓ Email sent successfully: $EMAIL_ID${NC}"
    echo -e "${GREEN}✓ QR Code: $QR_CODE${NC}"
  fi
fi

# ============================================================
# STEP 6: Verify shipment QR validation
# ============================================================
if [ ! -z "$QR_CODE" ]; then
  echo -e "\n${YELLOW}Step 6: Validating QR code...${NC}"

  QR_VALIDATION=$(curl -s -X GET \
    "$SUPABASE_URL/functions/v1/brickshare-qr-api/validate/$QR_CODE" \
    -H "Authorization: Bearer $SERVICE_ROLE_KEY")

  QR_VALID=$(echo $QR_VALIDATION | jq -r '.valid // empty')

  if [ "$QR_VALID" = "true" ]; then
    echo -e "${GREEN}✓ QR code is valid and not yet used${NC}"
  else
    echo -e "${YELLOW}⚠ QR validation response:${NC}"
    echo $QR_VALIDATION
  fi
fi

# ============================================================
# Summary
# ============================================================
echo -e "\n${BLUE}=============================================="
echo "Test Summary:"
echo "=============================================${NC}"
echo -e "User ID: ${GREEN}$USER_ID${NC}"
echo -e "PUDO ID: ${GREEN}$PUDO_ID${NC}"
echo -e "Set ID: ${GREEN}$SET_ID${NC}"
echo -e "Shipment ID: ${GREEN}$SHIPMENT_ID${NC}"
echo -e "Email Sent: ${GREEN}${EMAIL_ID:0:20}...${NC}"
echo -e "QR Code: ${GREEN}$QR_CODE${NC}"
echo -e "\n${GREEN}✓ Complete flow test finished!${NC}"