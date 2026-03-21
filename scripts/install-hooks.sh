#!/bin/bash

# Script to install git hooks for automatic schema updates and migration push
# Run this script after cloning the repository

echo "📦 Instalando Git Hooks para Brickshare..."

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Este script debe ejecutarse desde la raíz del repositorio"
    exit 1
fi

# ─────────────────────────────────────────────
# 1. Install pre-commit hook
# ─────────────────────────────────────────────

echo ""
echo "── Hook pre-commit ──────────────────────"

# Check if hook already exists
if [ -f ".git/hooks/pre-commit" ]; then
    echo "⚠️  Ya existe un hook pre-commit"
    read -p "¿Deseas sobrescribirlo? (s/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo "⏭️  Saltando instalación de pre-commit"
    else
        INSTALL_PRECOMMIT=true
    fi
else
    INSTALL_PRECOMMIT=true
fi

if [ "$INSTALL_PRECOMMIT" = true ]; then
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

    chmod +x .git/hooks/pre-commit
    echo "✅ Hook pre-commit instalado correctamente"
fi

# ─────────────────────────────────────────────
# 2. Install pre-push hook
# ─────────────────────────────────────────────

echo ""
echo "── Hook pre-push ────────────────────────"

# Check if hook already exists
if [ -f ".git/hooks/pre-push" ]; then
    echo "⚠️  Ya existe un hook pre-push"
    read -p "¿Deseas sobrescribirlo? (s/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo "⏭️  Saltando instalación de pre-push"
    else
        INSTALL_PREPUSH=true
    fi
else
    INSTALL_PREPUSH=true
fi

if [ "$INSTALL_PREPUSH" = true ]; then
    # Create the pre-push hook
    cat > .git/hooks/pre-push << 'PREPUSH_EOF'
#!/bin/bash

# Git hook pre-push: Automatically push Supabase migrations to remote DB
# This hook detects new migration files and runs `supabase db push` before pushing

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Checking for pending Supabase migrations...${NC}"

# Check if supabase CLI is available
if ! command -v npx &> /dev/null; then
    echo -e "${YELLOW}⚠️  npx not found. Skipping migration push.${NC}"
    exit 0
fi

# Check if there are migration files in the commits being pushed
# Get the range of commits being pushed
while read local_ref local_sha remote_ref remote_sha; do
    # If this is a new branch, compare against the remote tracking branch or all commits
    if [ "$remote_sha" = "0000000000000000000000000000000000000000" ]; then
        # New branch - check all files in the branch
        MIGRATION_FILES=$(git diff --name-only HEAD~10..HEAD 2>/dev/null | grep "^supabase/migrations/" || true)
    else
        # Existing branch - check only new commits
        MIGRATION_FILES=$(git diff --name-only "$remote_sha".."$local_sha" 2>/dev/null | grep "^supabase/migrations/" || true)
    fi
done

if [ -z "$MIGRATION_FILES" ]; then
    echo -e "${GREEN}ℹ️  No new migrations detected. Skipping db push.${NC}"
    exit 0
fi

echo -e "${YELLOW}📦 New migrations detected:${NC}"
echo "$MIGRATION_FILES" | while read -r file; do
    echo -e "   ${BLUE}→${NC} $(basename "$file")"
done
echo ""

# Run supabase db push
echo -e "${YELLOW}🚀 Pushing migrations to remote Supabase database...${NC}"
if npx supabase db push 2>&1; then
    echo -e "${GREEN}✅ Migrations pushed to remote database successfully!${NC}"
    echo ""
else
    echo ""
    echo -e "${RED}❌ Error pushing migrations to remote database.${NC}"
    echo -e "${YELLOW}⚠️  The git push will continue, but the remote DB may be out of sync.${NC}"
    echo -e "${YELLOW}   Run 'npx supabase db push' manually to fix.${NC}"
    echo ""
    # Don't block the push - just warn
    # To block the push on failure, change 'exit 0' to 'exit 1' below:
    exit 0
fi

exit 0
PREPUSH_EOF

    chmod +x .git/hooks/pre-push
    echo "✅ Hook pre-push instalado correctamente"
fi

# ─────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────

echo ""
echo "════════════════════════════════════════════"
echo "📋 Hooks instalados:"
echo ""
echo "  🔹 pre-commit:"
echo "     - Detecta commits con migraciones"
echo "     - Actualiza docs/DATABASE_SCHEMA.md y docs/schema_dump.sql"
echo "     - Añade la documentación actualizada al commit"
echo ""
echo "  🔹 pre-push:"
echo "     - Detecta migraciones nuevas en los commits a pushear"
echo "     - Ejecuta 'supabase db push' para sincronizar la DB remota"
echo "     - Avisa si falla pero no bloquea el push"
echo ""
echo "💡 Para actualizar la documentación manualmente:"
echo "   bash scripts/update-schema-docs.sh"
echo ""
echo "⚠️  Nota: Los hooks requieren que Supabase esté correctamente configurado"
echo "════════════════════════════════════════════"