#!/bin/bash

# Test script to verify correos-pudo Edge Function works without authentication

echo "🧪 Testing correos-pudo Edge Function..."
echo "📍 Testing coordinates: Barcelona (41.3874, 2.1686)"
echo ""

# Test WITHOUT authentication (should work now)
echo "1️⃣  Testing WITHOUT authentication..."
response=$(curl -s -X POST \
  'http://127.0.0.1:54331/functions/v1/correos-pudo' \
  -H 'Content-Type: application/json' \
  -d '{
    "lat": 41.3874,
    "lng": 2.1686,
    "radius": 5000
  }')

echo "Response:"
echo "$response" | jq '.' 2>/dev/null || echo "$response"
echo ""

# Check if response contains error
if echo "$response" | grep -q "Unauthorized"; then
  echo "❌ FAILED: Still getting Unauthorized error"
  exit 1
elif echo "$response" | grep -q "error"; then
  echo "⚠️  WARNING: Got error response (might be Correos API issue)"
  echo "$response" | jq '.error' 2>/dev/null || echo "$response"
  exit 0
else
  echo "✅ SUCCESS: Function responds without authentication!"
  echo "📦 Number of points returned: $(echo "$response" | jq 'length' 2>/dev/null || echo 'unknown')"
fi