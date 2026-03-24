#!/bin/bash

# Script to test both PUDO flows (Correos and Brickshare)
# Tests the complete assignment flow with PUDO validation

set -e

echo "🧪 Testing PUDO Flows (Correos & Brickshare)"
echo "=============================================="

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Database connection
DB_URL="postgresql://postgres:postgres@127.0.0.1:54322/postgres"

echo ""
echo "📊 Step 1: Check current PUDO configuration"
echo "--------------------------------------------"

# Get test users
CORREOS_USER=$(psql "$DB_URL" -tAc "
  SELECT user_id FROM users 
  WHERE pudo_type = 'correos' 
  LIMIT 1;
")

BRICKSHARE_USER=$(psql "$DB_URL" -tAc "
  SELECT user_id FROM users 
  WHERE pudo_type = 'brickshare' 
  LIMIT 1;
")

NO_PUDO_USER=$(psql "$DB_URL" -tAc "
  SELECT user_id FROM users 
  WHERE pudo_type IS NULL 
  AND subscription_type IN ('basic', 'standard', 'premium')
  LIMIT 1;
")

if [ -z "$CORREOS_USER" ]; then
  echo -e "${YELLOW}⚠️  No user with Correos PUDO found${NC}"
else
  echo -e "${GREEN}✓ Correos user: $CORREOS_USER${NC}"
fi

if [ -z "$BRICKSHARE_USER" ]; then
  echo -e "${YELLOW}⚠️  No user with Brickshare PUDO found${NC}"
else
  echo -e "${GREEN}✓ Brickshare user: $BRICKSHARE_USER${NC}"
fi

if [ -z "$NO_PUDO_USER" ]; then
  echo -e "${YELLOW}⚠️  No user without PUDO found${NC}"
else
  echo -e "${GREEN}✓ User without PUDO: $NO_PUDO_USER${NC}"
fi

echo ""
echo "📊 Step 2: Test assignment WITHOUT PUDO (should fail)"
echo "------------------------------------------------------"

if [ -n "$NO_PUDO_USER" ]; then
  # Propose a set to user without PUDO
  RANDOM_SET=$(psql "$DB_URL" -tAc "
    SELECT id FROM sets 
    WHERE set_status = 'active' 
    LIMIT 1;
  ")
  
  psql "$DB_URL" -c "
    UPDATE users 
    SET proposed_set_id = '$RANDOM_SET'
    WHERE user_id = '$NO_PUDO_USER';
  " > /dev/null
  
  # Try to confirm assignment (should fail)
  RESULT=$(psql "$DB_URL" -tAc "
    SELECT success, message 
    FROM confirm_assign_sets_to_users(ARRAY['$NO_PUDO_USER'::UUID]);
  ")
  
  if echo "$RESULT" | grep -q "does not have a PUDO"; then
    echo -e "${GREEN}✓ Assignment correctly blocked: user has no PUDO${NC}"
  else
    echo -e "${RED}✗ ERROR: Assignment should have been blocked!${NC}"
    echo "Result: $RESULT"
  fi
else
  echo -e "${YELLOW}⚠️  Skipping test (no user without PUDO)${NC}"
fi

echo ""
echo "📊 Step 3: Test assignment WITH Correos PUDO"
echo "--------------------------------------------"

if [ -n "$CORREOS_USER" ]; then
  # Propose a set
  RANDOM_SET=$(psql "$DB_URL" -tAc "
    SELECT id FROM sets 
    WHERE set_status = 'active' 
    LIMIT 1;
  ")
  
  psql "$DB_URL" -c "
    UPDATE users 
    SET proposed_set_id = '$RANDOM_SET'
    WHERE user_id = '$CORREOS_USER';
  " > /dev/null
  
  # Confirm assignment
  RESULT=$(psql "$DB_URL" -tAc "
    SELECT success, message 
    FROM confirm_assign_sets_to_users(ARRAY['$CORREOS_USER'::UUID]);
  ")
  
  if echo "$RESULT" | grep -q "t|Assignment confirmed successfully"; then
    echo -e "${GREEN}✓ Correos PUDO assignment successful${NC}"
    
    # Check shipment was created
    SHIPMENT_COUNT=$(psql "$DB_URL" -tAc "
      SELECT COUNT(*) FROM shipments 
      WHERE user_id = '$CORREOS_USER' 
      AND set_id = '$RANDOM_SET';
    ")
    
    if [ "$SHIPMENT_COUNT" -gt "0" ]; then
      echo -e "${GREEN}✓ Shipment created for Correos user${NC}"
    else
      echo -e "${RED}✗ ERROR: Shipment not created${NC}"
    fi
  else
    echo -e "${RED}✗ ERROR: Assignment failed${NC}"
    echo "Result: $RESULT"
  fi
else
  echo -e "${YELLOW}⚠️  Skipping test (no Correos user)${NC}"
fi

echo ""
echo "📊 Step 4: Test assignment WITH Brickshare PUDO"
echo "------------------------------------------------"

if [ -n "$BRICKSHARE_USER" ]; then
  # Propose a set
  RANDOM_SET=$(psql "$DB_URL" -tAc "
    SELECT id FROM sets 
    WHERE set_status = 'active' 
    LIMIT 1;
  ")
  
  psql "$DB_URL" -c "
    UPDATE users 
    SET proposed_set_id = '$RANDOM_SET'
    WHERE user_id = '$BRICKSHARE_USER';
  " > /dev/null
  
  # Confirm assignment
  RESULT=$(psql "$DB_URL" -tAc "
    SELECT success, message 
    FROM confirm_assign_sets_to_users(ARRAY['$BRICKSHARE_USER'::UUID]);
  ")
  
  if echo "$RESULT" | grep -q "t|Assignment confirmed successfully"; then
    echo -e "${GREEN}✓ Brickshare PUDO assignment successful${NC}"
    
    # Check shipment was created
    SHIPMENT_COUNT=$(psql "$DB_URL" -tAc "
      SELECT COUNT(*) FROM shipments 
      WHERE user_id = '$BRICKSHARE_USER' 
      AND set_id = '$RANDOM_SET';
    ")
    
    if [ "$SHIPMENT_COUNT" -gt "0" ]; then
      echo -e "${GREEN}✓ Shipment created for Brickshare user${NC}"
    else
      echo -e "${RED}✗ ERROR: Shipment not created${NC}"
    fi
  else
    echo -e "${RED}✗ ERROR: Assignment failed${NC}"
    echo "Result: $RESULT"
  fi
else
  echo -e "${YELLOW}⚠️  Skipping test (no Brickshare user)${NC}"
fi

echo ""
echo "📊 Step 5: Verify PUDO data retrieval"
echo "--------------------------------------"

if [ -n "$CORREOS_USER" ]; then
  PUDO_INFO=$(psql "$DB_URL" -tAc "
    SELECT pudo_type, pudo_id 
    FROM get_user_active_pudo('$CORREOS_USER');
  ")
  
  if echo "$PUDO_INFO" | grep -q "correos"; then
    echo -e "${GREEN}✓ Correos PUDO data retrieved correctly${NC}"
  else
    echo -e "${RED}✗ ERROR: Could not retrieve Correos PUDO${NC}"
  fi
fi

if [ -n "$BRICKSHARE_USER" ]; then
  PUDO_INFO=$(psql "$DB_URL" -tAc "
    SELECT pudo_type, pudo_id 
    FROM get_user_active_pudo('$BRICKSHARE_USER');
  ")
  
  if echo "$PUDO_INFO" | grep -q "brickshare"; then
    echo -e "${GREEN}✓ Brickshare PUDO data retrieved correctly${NC}"
  else
    echo -e "${RED}✗ ERROR: Could not retrieve Brickshare PUDO${NC}"
  fi
fi

echo ""
echo "=============================================="
echo -e "${GREEN}🎉 Testing complete!${NC}"
echo "=============================================="