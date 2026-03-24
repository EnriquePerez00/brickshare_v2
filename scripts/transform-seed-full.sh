#!/bin/bash
# ============================================================================
# Script: transform-seed-full.sh
# Description: Transforms seed_full.sql to be compatible with current schema
# ============================================================================

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INPUT_FILE="$PROJECT_ROOT/supabase/seed_full.sql"
OUTPUT_FILE="$PROJECT_ROOT/supabase/seed_clean.sql"
TEMP_FILE="/tmp/seed_transform_$$.sql"

echo "🔄 Starting seed_full.sql transformation..."
echo "📂 Input:  $INPUT_FILE"
echo "📂 Output: $OUTPUT_FILE"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "❌ Error: Input file not found: $INPUT_FILE"
    exit 1
fi

# Create temporary file with header
cat > "$TEMP_FILE" << 'EOF'
-- ============================================================================
-- TRANSFORMED SEED FILE - Compatible with current schema
-- Generated from: seed_full.sql
-- Date: $(date)
-- ============================================================================
-- This file contains cleaned data from seed_full.sql with column mappings
-- applied to match the current database schema.
-- ============================================================================

BEGIN;

-- Disable triggers temporarily for faster insertion
SET session_replication_role = 'replica';

EOF

echo "🔧 Applying transformations..."

# Extract and transform data sections from seed_full.sql
# We'll use sed and awk to process the SQL

# 1. Extract INSERT statements for specific tables
grep -A 10000 "^COPY public\." "$INPUT_FILE" | while IFS= read -r line; do
    # Transform column names in COPY statements
    echo "$line" | sed \
        -e 's/users\.direccion/users.address/g' \
        -e 's/users\.codigo_postal/users.zip_code/g' \
        -e 's/users\.ciudad/users.city/g' \
        -e 's/users\.telefono/users.phone/g' \
        -e 's/inventory_sets\.inventory_set_total_qty/inventory_sets.available_stock/g' \
        >> "$TEMP_FILE"
done

# 2. Process INSERT INTO statements
awk '
/^INSERT INTO public\.users/ {
    # Replace deprecated column names in INSERT statements
    gsub(/direccion/, "address")
    gsub(/codigo_postal/, "zip_code")
    gsub(/ciudad/, "city")
    gsub(/telefono/, "phone")
    print
    next
}

/^INSERT INTO public\.inventory_sets/ {
    # Replace inventory column names
    gsub(/inventory_set_total_qty/, "available_stock")
    print
    next
}

/^INSERT INTO/ {
    # Pass through other INSERT statements unchanged
    print
    next
}
' "$INPUT_FILE" >> "$TEMP_FILE"

# Add footer
cat >> "$TEMP_FILE" << 'EOF'

-- Re-enable triggers
SET session_replication_role = 'origin';

-- Update sequences to match inserted data
SELECT setval('auth.refresh_tokens_id_seq', (SELECT MAX(id) FROM auth.refresh_tokens), true);

COMMIT;

-- ============================================================================
-- Transformation complete
-- ============================================================================
EOF

# Move temp file to output
mv "$TEMP_FILE" "$OUTPUT_FILE"

echo "✅ Transformation complete!"
echo "📄 Generated: $OUTPUT_FILE"
echo ""
echo "📋 Next steps:"
echo "   1. Review the generated file: less $OUTPUT_FILE"
echo "   2. Apply to database:"
echo "      psql \$DATABASE_URL < $OUTPUT_FILE"
echo ""
echo "   Or use the restore-data.sh script:"
echo "      ./scripts/restore-data.sh"