#!/bin/bash

# Script de verificación de Supabase CLI
# Verifica que el CLI esté configurado correctamente

echo "🔍 Verificando configuración de Supabase CLI..."
echo ""

# Verificar que Supabase CLI esté instalado
if ! command -v supabase &> /dev/null; then
    echo "❌ Supabase CLI no está instalado"
    echo "   Instálalo con: brew install supabase/tap/supabase"
    exit 1
fi

echo "✅ Supabase CLI instalado: $(supabase --version)"
echo ""

# Verificar que existe el token de acceso
if [ ! -f ~/.supabase/access-token ]; then
    echo "❌ No se encontró access token en ~/.supabase/access-token"
    echo ""
    echo "📖 Sigue estos pasos para configurarlo:"
    echo "   1. Ve a https://supabase.com/dashboard/account/tokens"
    echo "   2. Genera un nuevo token"
    echo "   3. Ejecuta: mkdir -p ~/.supabase && echo 'TU_TOKEN' > ~/.supabase/access-token"
    echo ""
    echo "   Ver guía completa: docs/SUPABASE_CLI_SETUP.md"
    exit 1
fi

echo "✅ Access token encontrado"
echo ""

# Verificar que el proyecto está vinculado
if [ ! -d .supabase ]; then
    echo "⚠️  Proyecto no vinculado localmente"
    echo ""
    echo "📖 Para vincular el proyecto ejecuta:"
    echo "   supabase link --project-ref tevoogkifiszfontzkgd --password 'Urgell175177'"
    echo ""
    exit 1
fi

echo "✅ Proyecto vinculado localmente"
echo ""

# Verificar que podemos listar proyectos
echo "🔄 Verificando conexión con Supabase API..."
if supabase projects list &> /dev/null; then
    echo "✅ Conexión exitosa con Supabase API"
    echo ""
    echo "📋 Proyectos disponibles:"
    supabase projects list
    echo ""
else
    echo "❌ Error al conectar con Supabase API"
    echo ""
    echo "📖 Posibles causas:"
    echo "   - Token de acceso inválido o expirado"
    echo "   - Problemas de red"
    echo ""
    echo "   Genera un nuevo token en: https://supabase.com/dashboard/account/tokens"
    exit 1
fi

# Verificar que podemos listar funciones
echo "🔄 Verificando funciones desplegadas..."
if supabase functions list &> /dev/null; then
    echo "✅ Acceso a funciones verificado"
    echo ""
    echo "📋 Funciones desplegadas:"
    supabase functions list
    echo ""
else
    echo "⚠️  No se pudieron listar funciones (puede ser normal si no hay ninguna)"
    echo ""
fi

# Verificar que podemos ver migraciones
echo "🔄 Verificando migraciones..."
if supabase migration list &> /dev/null; then
    echo "✅ Acceso a migraciones verificado"
    echo ""
    MIGRATION_COUNT=$(supabase migration list 2>/dev/null | grep -c "│")
    if [ $MIGRATION_COUNT -gt 0 ]; then
        echo "📋 Tienes $MIGRATION_COUNT migraciones aplicadas"
    fi
    echo ""
else
    echo "⚠️  No se pudieron listar migraciones"
    echo ""
fi

# Resumen final
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ ¡Supabase CLI configurado correctamente!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🚀 Comandos disponibles:"
echo "   - supabase db push             # Aplicar migraciones"
echo "   - supabase functions deploy    # Desplegar funciones"
echo "   - supabase db dump             # Exportar esquema"
echo "   - npm run dump-schema          # Script personalizado"
echo ""
echo "📖 Ver más comandos en: docs/SUPABASE_CLI_SETUP.md"