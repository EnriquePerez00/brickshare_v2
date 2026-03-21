#!/bin/bash

# Script to install git hooks for automatic schema documentation updates
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

# Git hook pre-commit: Automatically update database schema documentation
# This hook runs before each commit if migrations are detected

if git diff --cached --name-only | grep -q "supabase/migrations/"; then
    echo "🔍 Migration detected, updating schema documentation..."

    if bash scripts/update-schema-docs.sh; then
        git add docs/DATABASE_SCHEMA.md docs/schema_dump.sql 2>/dev/null
        echo "✅ Schema documentation updated and added to commit"
    else
        echo "⚠️  Could not update schema documentation"
        echo "   The commit will continue, but documentation may be outdated"
    fi
else
    echo "ℹ️  No migration changes detected, skipping schema update"
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
    echo "✅ Legacy pre-push hook removed (Supabase remote is no longer used)"
fi

# ─────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────

echo ""
echo "════════════════════════════════════════════"
echo "📋 Hooks installed:"
echo ""
echo "  🔹 pre-commit:"
echo "     - Detects commits with migrations"
echo "     - Updates docs/DATABASE_SCHEMA.md and docs/schema_dump.sql"
echo "     - Adds updated documentation to the commit"
echo ""
echo "💡 To update documentation manually:"
echo "   bash scripts/update-schema-docs.sh"
echo ""
echo "ℹ️  Note: This project uses local Supabase only."
echo "   Migrations are applied via 'supabase db reset' locally."
echo "════════════════════════════════════════════"