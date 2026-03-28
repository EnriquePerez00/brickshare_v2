#!/bin/bash

# Script para ejecutar el test de onboarding con debugging
# Uso: ./run-onboarding-test.sh

set -e

echo "🎭 Brickshare E2E - Test de Onboarding"
echo "========================================"
echo ""

# Verificar que estamos en el directorio correcto
if [ ! -f "package.json" ]; then
    echo "❌ Error: Este script debe ejecutarse desde apps/web/"
    exit 1
fi

# Verificar que el dev server está corriendo
echo "🔍 Verificando dev server en localhost:5173..."
if curl -s http://localhost:5173 > /dev/null 2>&1; then
    echo "✅ Dev server detectado"
else
    echo "❌ Dev server NO está corriendo"
    echo ""
    echo "Por favor, inicia el dev server en otra terminal:"
    echo "  npm run dev"
    echo ""
    echo "Espera hasta ver el mensaje:"
    echo "  ➜  Local:   http://localhost:5173/"
    echo ""
    exit 1
fi

echo ""
echo "🧪 Ejecutando test de onboarding..."
echo ""

# Ejecutar el test con reporter verbose
npx playwright test e2e/user-journeys/complete-onboarding.spec.ts \
    --project=chromium \
    --reporter=list \
    --max-failures=1

TEST_EXIT_CODE=$?

echo ""
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo "✅ Tests completados exitosamente!"
else
    echo "❌ Tests fallaron"
    echo ""
    echo "Para debug interactivo, ejecuta:"
    echo "  npx playwright test --ui"
    echo ""
    echo "Para ver screenshots:"
    echo "  open debug-no-signup-button.png  # Si existe"
    echo ""
    echo "Para ver traces:"
    echo "  npx playwright show-trace test-results/*/trace.zip"
fi

exit $TEST_EXIT_CODE