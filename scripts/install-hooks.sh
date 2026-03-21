#!/bin/bash

# Script to install git hooks for automatic schema updates
# Run this script after cloning the repository

echo "📦 Instalando Git Hooks para Brickshare..."

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Este script debe ejecutarse desde la raíz del repositorio"
    exit 1
fi

# Check if hook already exists
if [ -f ".git/hooks/pre-commit" ]; then
    echo "⚠️  Ya existe un hook pre-commit"
    read -p "¿Deseas sobrescribirlo? (s/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo "❌ Instalación cancelada"
        exit 0
    fi
fi

# Create the pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

# Git hook pre-commit: Automatically update database schema documentation
# This hook runs before each commit if migrations are detected

# Verificar si hay migraciones en el commit
if git diff --cached --name-only | grep -q "supabase/migrations/"; then
    echo "🔍 Detectada migración, actualizando documentación del esquema..."
    
    # Ejecutar script de actualización de documentación
    if bash scripts/update-schema-docs.sh; then
        # Añadir documentación actualizada al commit
        git add docs/DATABASE_SCHEMA.md docs/schema_dump.sql 2>/dev/null
        echo "✅ Documentación del esquema actualizada y añadida al commit"
    else
        echo "⚠️  No se pudo actualizar la documentación del esquema"
        echo "   El commit continuará, pero la documentación puede estar desactualizada"
    fi
else
    echo "ℹ️  No se detectaron cambios en migraciones, saltando actualización de esquema"
fi

echo ""
exit 0
EOF

# Make the hook executable
chmod +x .git/hooks/pre-commit

echo "✅ Hook pre-commit instalado correctamente"
echo ""
echo "📋 Cómo funciona:"
echo "   - El hook detecta automáticamente commits con migraciones"
echo "   - Actualiza docs/DATABASE_SCHEMA.md y docs/schema_dump.sql"
echo "   - Añade la documentación actualizada al commit"
echo ""
echo "💡 Para actualizar la documentación manualmente:"
echo "   bash scripts/update-schema-docs.sh"
echo ""
echo "⚠️  Nota: El hook requiere que Supabase esté corriendo localmente (supabase start)"
