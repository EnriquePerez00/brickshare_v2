#!/bin/bash
# Verify Edge Functions Deployment
# Compares functions in code vs deployed functions in Supabase

set -e

echo "🔍 Verificando Edge Functions..."
echo "================================"

# Get functions from code
echo ""
echo "📁 Funciones en el código (supabase/functions/):"
CODE_FUNCTIONS=$(ls -1 supabase/functions/ 2>/dev/null | grep -v "^_" || true)
if [ -z "$CODE_FUNCTIONS" ]; then
    echo "   ⚠️  No se encontraron funciones en el código"
    exit 1
fi

echo "$CODE_FUNCTIONS" | while read -r func; do
    echo "   • $func"
done

# Get deployed functions
echo ""
echo "☁️  Funciones desplegadas en Supabase:"
DEPLOYED_FUNCTIONS=$(supabase functions list --format name 2>/dev/null || echo "")

if [ -z "$DEPLOYED_FUNCTIONS" ]; then
    echo "   ⚠️  No se pudieron obtener las funciones desplegadas"
    echo "   💡 ¿Está corriendo Supabase local? Ejecuta: supabase start"
    exit 1
fi

echo "$DEPLOYED_FUNCTIONS" | tail -n +2 | while read -r func; do
    # Skip header and empty lines
    if [ ! -z "$func" ]; then
        echo "   • $func"
    fi
done

# Compare and find missing functions
echo ""
echo "🔎 Análisis de diferencias:"
echo "----------------------------"

MISSING_COUNT=0

echo "$CODE_FUNCTIONS" | while read -r code_func; do
    if ! echo "$DEPLOYED_FUNCTIONS" | grep -q "^$code_func$"; then
        echo "   ❌ FALTA: $code_func (existe en código pero NO está desplegada)"
        MISSING_COUNT=$((MISSING_COUNT + 1))
    fi
done

# Check if all functions are deployed
if [ $MISSING_COUNT -eq 0 ]; then
    echo "   ✅ Todas las funciones del código están desplegadas"
    echo ""
    echo "================================"
    echo "✅ Verificación completada con éxito"
    exit 0
else
    echo ""
    echo "================================"
    echo "⚠️  Se encontraron $MISSING_COUNT función(es) sin desplegar"
    echo ""
    echo "Para desplegar las funciones faltantes:"
    echo "  supabase functions deploy <nombre-funcion>"
    echo ""
    echo "Para desplegar todas las funciones:"
    
    echo "$CODE_FUNCTIONS" | while read -r func; do
        if ! echo "$DEPLOYED_FUNCTIONS" | grep -q "^$func$"; then
            echo "  supabase functions deploy $func"
        fi
    done
    
    exit 1
fi