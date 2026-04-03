#!/bin/bash

# Script para validar el email enviado a user3 via Resend
# Muestra el template HTML y valida la configuración

echo "═══════════════════════════════════════════════════════════"
echo "📧 Validación de Email Resend para User3"
echo "═══════════════════════════════════════════════════════════"
echo ""

# 1. Verificar que la API key esté configurada correctamente
echo "1️⃣ Verificando configuración de RESEND_API_KEY..."
echo ""

RESEND_KEY_FUNCTIONS=$(grep "RESEND_API_KEY" supabase/functions/.env | cut -d'=' -f2)
RESEND_KEY_SUPABASE=$(grep "RESEND_API_KEY" supabase/.env | cut -d'=' -f2)
RESEND_KEY_ENV=$(grep "RESEND_API_KEY" .env | cut -d'=' -f2)

if [[ "$RESEND_KEY_FUNCTIONS" == "a7937760-ab2b-47a1-9a95-746c7fa7ad63" ]]; then
  echo "✅ supabase/functions/.env: CORRECTO"
else
  echo "❌ supabase/functions/.env: INCORRECTO"
  echo "   Actual: $RESEND_KEY_FUNCTIONS"
fi

if [[ "$RESEND_KEY_SUPABASE" == "a7937760-ab2b-47a1-9a95-746c7fa7ad63" ]]; then
  echo "✅ supabase/.env: CORRECTO"
else
  echo "❌ supabase/.env: INCORRECTO"
  echo "   Actual: $RESEND_KEY_SUPABASE"
fi

if [[ "$RESEND_KEY_ENV" == "a7937760-ab2b-47a1-9a95-746c7fa7ad63" ]]; then
  echo "✅ .env: CORRECTO"
else
  echo "❌ .env: INCORRECTO"
  echo "   Actual: $RESEND_KEY_ENV"
fi

echo ""
echo "2️⃣ Obtener información del último shipment de user3..."
echo ""

# Consultar el último shipment de user3
psql postgresql://postgres:postgres@127.0.0.1:5433/postgres -c "
SELECT 
  s.id as shipment_id,
  s.delivery_qr_code,
  s.set_ref,
  u.email,
  u.full_name,
  st.set_name
FROM shipments s
JOIN users u ON s.user_id = u.user_id
LEFT JOIN sets st ON s.set_ref = st.set_ref
WHERE u.email = 'enriqueperezbcn1973@gmail.com'
ORDER BY s.created_at DESC
LIMIT 1;
" 2>&1

echo ""
echo "3️⃣ Verificar en Resend Dashboard:"
echo ""
echo "   🔗 URL: https://resend.com/emails"
echo "   📧 Buscar emails enviados a: enriqueperezbcn1973@gmail.com"
echo "   ✅ Status debe ser: Delivered"
echo "   📝 Subject debe contener: 'Tu código QR para recoger'"
echo ""

echo "═══════════════════════════════════════════════════════════"
echo "✅ Validación completada"
echo "═══════════════════════════════════════════════════════════"