#!/bin/bash

# ═══════════════════════════════════════════════════════════════
# Test Script for Logistics External API
# ═══════════════════════════════════════════════════════════════
# This script tests the update-shipment endpoint with various scenarios

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BASE_URL="http://127.0.0.1:54321/functions/v1"
API_KEY="brickshare_logistics_2025_secure_key_change_in_production"

# Get a test shipment ID from database
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  📦 Logistics API Testing${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${YELLOW}📋 Obteniendo shipment de prueba...${NC}"
SHIPMENT_ID=$(psql "postgresql://postgres:postgres@127.0.0.1:54322/postgres" -t -c \
  "SELECT id FROM shipments WHERE shipping_status = 'assigned' LIMIT 1;" | tr -d '[:space:]')

if [ -z "$SHIPMENT_ID" ]; then
  echo -e "${RED}❌ No se encontró ningún shipment con estado 'assigned'${NC}"
  echo -e "${YELLOW}💡 Ejecuta primero una asignación de sets en el panel de admin${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Shipment encontrado: ${SHIPMENT_ID}${NC}"
echo ""

# Test 1: Valid request - Update to in_transit_pudo
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}Test 1: Actualizar a 'in_transit_pudo'${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"

RESPONSE=$(curl -s -X POST "$BASE_URL/update-shipment" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d "{
    \"shipment_id\": \"$SHIPMENT_ID\",
    \"updates\": {
      \"shipping_status\": \"in_transit_pudo\"
    }
  }")

echo "$RESPONSE" | jq .

if echo "$RESPONSE" | jq -e '.success == true' > /dev/null; then
  echo -e "${GREEN}✅ Test 1 PASSED${NC}"
else
  echo -e "${RED}❌ Test 1 FAILED${NC}"
fi
echo ""

# Test 2: Update to delivered with timestamp
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}Test 2: Actualizar a 'delivered' con timestamp${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
RESPONSE=$(curl -s -X POST "$BASE_URL/update-shipment" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d "{
    \"shipment_id\": \"$SHIPMENT_ID\",
    \"updates\": {
      \"shipping_status\": \"delivered\",
      \"delivered_at\": \"$TIMESTAMP\"
    }
  }")

echo "$RESPONSE" | jq .

if echo "$RESPONSE" | jq -e '.success == true' > /dev/null; then
  echo -e "${GREEN}✅ Test 2 PASSED${NC}"
else
  echo -e "${RED}❌ Test 2 FAILED${NC}"
fi
echo ""

# Test 3: Invalid API key
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}Test 3: API Key inválido (debe fallar)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"

RESPONSE=$(curl -s -X POST "$BASE_URL/update-shipment" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: invalid-key" \
  -d "{
    \"shipment_id\": \"$SHIPMENT_ID\",
    \"updates\": {
      \"shipping_status\": \"picked_up\"
    }
  }")

echo "$RESPONSE" | jq .

if echo "$RESPONSE" | jq -e '.success == false' > /dev/null; then
  echo -e "${GREEN}✅ Test 3 PASSED (correctamente rechazado)${NC}"
else
  echo -e "${RED}❌ Test 3 FAILED${NC}"
fi
echo ""

# Test 4: Invalid shipment ID
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}Test 4: Shipment ID inexistente (debe fallar)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"

RESPONSE=$(curl -s -X POST "$BASE_URL/update-shipment" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d '{
    "shipment_id": "00000000-0000-0000-0000-000000000000",
    "updates": {
      "shipping_status": "delivered"
    }
  }')

echo "$RESPONSE" | jq .

if echo "$RESPONSE" | jq -e '.success == false' > /dev/null; then
  echo -e "${GREEN}✅ Test 4 PASSED (correctamente rechazado)${NC}"
else
  echo -e "${RED}❌ Test 4 FAILED${NC}"
fi
echo ""

# Test 5: Invalid field
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}Test 5: Campo no permitido (debe fallar)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"

RESPONSE=$(curl -s -X POST "$BASE_URL/update-shipment" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d "{
    \"shipment_id\": \"$SHIPMENT_ID\",
    \"updates\": {
      \"user_id\": \"12345678-1234-1234-1234-123456789012\"
    }
  }")

echo "$RESPONSE" | jq .

if echo "$RESPONSE" | jq -e '.success == false' > /dev/null; then
  echo -e "${GREEN}✅ Test 5 PASSED (correctamente rechazado)${NC}"
else
  echo -e "${RED}❌ Test 5 FAILED${NC}"
fi
echo ""

# Check audit log
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}📊 Verificando audit log...${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"

psql "postgresql://postgres:postgres@127.0.0.1:54322/postgres" -c \
  "SELECT 
    id,
    shipment_id,
    updated_by,
    updated_fields,
    new_values,
    created_at
  FROM shipment_update_logs 
  WHERE shipment_id = '$SHIPMENT_ID' 
  ORDER BY created_at DESC 
  LIMIT 5;"

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Tests completados${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}📝 Para más pruebas, consulta: docs/EXTERNAL_LOGISTICS_API.md${NC}"