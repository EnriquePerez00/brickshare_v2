#!/bin/bash

# Script to install git hooks for automatic local DB migration and schema documentation
# Run this script after cloning the repository

echo "📦 Installing Git Hooks for Brickshare..."

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: This script must be run from the repository root"
    exit 1
fi

# ─────────────────────────────────────────────
# 1. Install pre-commit hook
# ─────────────────────────────────────────────

echo ""
echo "── Hook pre-commit ──────────────────────"

# Check if hook already exists
if [ -f ".git/hooks/pre-commit" ]; then
    echo "⚠️  A pre-commit hook already exists"
    read -p "Do you want to overwrite it? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "⏭️  Skipping pre-commit installation"
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

# Git hook pre-commit: Automatically apply pending migrations and update schema docs
# This hook runs before each commit if migrations are detected

# Verificar si hay migraciones en el commit
if git diff --cached --name-only | grep -q "supabase/migrations/"; then
    echo "🔍 Detectada migración en el commit..."

    # ── 1. Aplicar migraciones pendientes a la BBDD local ──
    echo "  → Aplicando migraciones pendientes a la BBDD local..."
    if supabase migration up --local 2>&1; then
        echo "  ✅ Migraciones aplicadas correctamente a la BBDD local"
    else
        echo "  ❌ Error al aplicar migraciones a la BBDD local"
        echo "     Revisa el error y corrige la migración antes de hacer commit"
        exit 1
    fi

    # ── 2. Actualizar documentación del esquema ──
    echo "  → Actualizando documentación del esquema..."
    if bash scripts/update-schema-docs.sh; then
        # Añadir documentación actualizada al commit
        git add docs/DATABASE_SCHEMA.md docs/schema_dump.sql 2>/dev/null
        echo "  ✅ Documentación del esquema actualizada y añadida al commit"
    else
        echo "  ⚠️  No se pudo actualizar la documentación del esquema"
        echo "     El commit continuará, pero la documentación puede estar desactualizada"
    fi

    echo ""
    echo "🎉 BBDD local actualizada y documentación regenerada"
else
    echo "ℹ️  No se detectaron cambios en migraciones, saltando actualización"
fi

echo ""
exit 0
EOF

    chmod +x .git/hooks/pre-commit
    echo "✅ Pre-commit hook installed successfully"
fi

# ─────────────────────────────────────────────
# 2. Remove legacy pre-push hook (if exists)
# ─────────────────────────────────────────────

if [ -f ".git/hooks/pre-push" ]; then
    echo ""
    echo "── Removing legacy pre-push hook ────────"
    rm -f .git/hooks/pre-push
    echo "✅ Legacy pre-push hook removed"
fi

# ─────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────

echo ""
echo "════════════════════════════════════════════"
echo "📋 Hooks installed:"
echo ""
echo "  🔹 pre-commit:"
echo "     - Detects commits with new migrations"
echo "     - Applies pending migrations to local DB (supabase migration up --local)"
echo "     - Updates docs/DATABASE_SCHEMA.md and docs/schema_dump.sql"
echo "     - Adds updated documentation to the commit"
echo "     - Blocks commit if migration fails"
echo ""
echo "💡 To update documentation manually:"
echo "   npm run dump-schema"
echo ""
echo "💡 To apply migrations manually:"
echo "   supabase migration up --local"
echo ""
echo "ℹ️  Note: This project uses local Supabase only (Docker)."
echo "   No remote database exists."
echo "════════════════════════════════════════════"