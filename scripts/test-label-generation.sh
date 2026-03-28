#!/bin/bash

# Test Label Generation for Brickshare PUDO
# Este script verifica que la generación de etiquetas funcione correctamente

set -e

echo "🧪 Test: Generación de Etiquetas Brickshare"
echo "============================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Supabase is running
echo "1️⃣  Verificando que Supabase esté corriendo..."
if ! curl -s http://127.0.0.1:54331/rest/v1/ > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: Supabase no está corriendo${NC}"
    echo "   Ejecuta: supabase start"
    exit 1
fi
echo -e "${GREEN}✅ Supabase está corriendo${NC}"
echo ""

# Check if Edge Functions are running
echo "2️⃣  Verificando Edge Functions..."
if curl -s http://127.0.0.1:54331/functions/v1/ | grep -q "404"; then
    echo -e "${YELLOW}⚠️  Edge Functions pueden no estar cargadas correctamente${NC}"
else
    echo -e "${GREEN}✅ Edge Functions están disponibles${NC}"
fi
echo ""

# Get a test shipment
echo "3️⃣  Buscando envío de prueba en estado 'assigned'..."
SHIPMENT_ID=$(psql postgresql://postgres:postgres@127.0.0.1:5433/postgres -t -c \
    "SELECT id FROM shipments WHERE shipment_status = 'assigned' AND pudo_type = 'brickshare' LIMIT 1;" 2>/dev/null | xargs)

if [ -z "$SHIPMENT_ID" ]; then
    echo -e "${RED}❌ No se encontró ningún envío en estado 'assigned' con pudo_type 'brickshare'${NC}"
    echo ""
    echo "Para crear uno de prueba, ejecuta:"
    echo "  psql postgresql://postgres:postgres@127.0.0.1:5433/postgres"
    echo ""
    echo "Y luego:"
    echo "  UPDATE shipments SET shipment_status = 'assigned', pudo_type = 'brickshare' WHERE id = '<shipment_id>';"
    exit 1
fi

echo -e "${GREEN}✅ Encontrado shipment ID: $SHIPMENT_ID${NC}"
echo ""

# Get user email for this shipment
echo "4️⃣  Obteniendo datos del usuario..."
USER_EMAIL=$(psql postgresql://postgres:postgres@127.0.0.1:5433/postgres -t -c \
    "SELECT u.email FROM shipments s JOIN users u ON s.user_id = u.id WHERE s.id = '$SHIPMENT_ID';" 2>/dev/null | xargs)

if [ -z "$USER_EMAIL" ]; then
    echo -e "${RED}❌ No se pudo obtener el email del usuario${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Email destino: $USER_EMAIL${NC}"
echo ""

# Test the Edge Function
echo "5️⃣  Probando Edge Function 'send-brickshare-qr-email'..."
echo ""

# Get service role key
SERVICE_ROLE_KEY=$(grep "VITE_SUPABASE_SERVICE_ROLE_KEY" .env.local | cut -d '=' -f2)

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
    "http://127.0.0.1:54331/functions/v1/send-brickshare-qr-email" \
    -H "Authorization: Bearer $SERVICE_ROLE_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"shipment_id\": \"$SHIPMENT_ID\", \"type\": \"delivery\"}")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

echo "Response Status: $HTTP_CODE"
echo "Response Body: $BODY"
echo ""

if [ "$HTTP_CODE" -eq 200 ]; then
    echo -e "${GREEN}✅ ¡Éxito! Email enviado correctamente${NC}"
    echo ""
    echo "📧 Verifica tu bandeja de entrada en: $USER_EMAIL"
    echo "   (Si usas Resend test key, verifica en https://resend.com/emails)"
    echo ""
    echo -e "${GREEN}🎉 Test completado exitosamente${NC}"
    exit 0
else
    echo -e "${RED}❌ Error: La función devolvió código $HTTP_CODE${NC}"
    echo ""
    echo "Posibles causas:"
    echo "  - API key de Resend inválida en supabase/.env"
    echo "  - Edge Functions no cargadas con las variables correctas"
    echo "  - Datos del shipment incompletos"
    echo ""
    echo "Revisa los logs de las Edge Functions para más detalles"
    exit 1
fi