#!/bin/bash
# Intelligent data restoration script
# Restores data from backup while handling schema changes gracefully

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Script configuration
DRY_RUN=false
INTERACTIVE=true
BACKUP_DIR=""
SPECIFIC_TABLES=()
VERBOSE=false

# ==============================================================================
# FUNCTIONS
# ==============================================================================

show_help() {
    cat << EOF
${CYAN}╔════════════════════════════════════════════════════════════╗${NC}
${CYAN}║  📦 Brickshare Intelligent Data Restore                   ║${NC}
${CYAN}╚════════════════════════════════════════════════════════════╝${NC}

${BLUE}Usage:${NC}
  ./scripts/restore-data.sh [OPTIONS]

${BLUE}Options:${NC}
  -d, --dir DIR          Backup directory to restore from (default: latest)
  -t, --table TABLE      Restore only specific table(s) (can specify multiple)
  -y, --yes              Non-interactive mode (auto-confirm)
  -n, --dry-run          Show what would be restored without executing
  -v, --verbose          Show detailed SQL operations
  -h, --help             Show this help message

${BLUE}Examples:${NC}
  # Restore latest backup interactively
  ./scripts/restore-data.sh

  # Restore specific backup
  ./scripts/restore-data.sh --dir supabase/backups/pre_reset_20260324_151300

  # Restore only users and sets tables
  ./scripts/restore-data.sh -t users -t sets

  # Dry run to see what would be restored
  ./scripts/restore-data.sh --dry-run

  # Non-interactive restore
  ./scripts/restore-data.sh --yes

EOF
    exit 0
}

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# ==============================================================================
# PARSE ARGUMENTS
# ==============================================================================

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dir)
            BACKUP_DIR="$2"
            shift 2
            ;;
        -t|--table)
            SPECIFIC_TABLES+=("$2")
            shift 2
            ;;
        -y|--yes)
            INTERACTIVE=false
            shift
            ;;
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            show_help
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# ==============================================================================
# INITIALIZATION
# ==============================================================================

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  📦 Intelligent Data Restore                              ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if Supabase is running
if ! supabase status > /dev/null 2>&1; then
    log_error "Supabase is not running. Start it with: supabase start"
    exit 1
fi

# Get database connection
DB_URL=$(supabase status -o json 2>/dev/null | grep -o '"DB URL": "[^"]*"' | cut -d'"' -f4)
if [ -z "$DB_URL" ]; then
    log_error "Could not get database URL"
    exit 1
fi

# Determine backup directory
if [ -z "$BACKUP_DIR" ]; then
    if [ -L "supabase/backups/latest_backup" ]; then
        BACKUP_DIR="supabase/backups/$(readlink supabase/backups/latest_backup)"
        log_info "Using latest backup: $BACKUP_DIR"
    else
        log_error "No backup directory specified and no latest backup found"
        exit 1
    fi
fi

# Validate backup directory
if [ ! -d "$BACKUP_DIR" ]; then
    log_error "Backup directory not found: $BACKUP_DIR"
    exit 1
fi

if [ ! -f "$BACKUP_DIR/data.sql" ]; then
    log_error "Data file not found: $BACKUP_DIR/data.sql"
    exit 1
fi

if [ ! -f "$BACKUP_DIR/metadata.json" ]; then
    log_warning "Metadata file not found (proceeding anyway)"
fi

# ==============================================================================
# DISPLAY BACKUP INFO
# ==============================================================================

echo -e "${BLUE}📁 Backup Information:${NC}"
echo -e "   Location: $BACKUP_DIR"

if [ -f "$BACKUP_DIR/metadata.json" ]; then
    BACKUP_DATE=$(jq -r '.backup_date // "unknown"' "$BACKUP_DIR/metadata.json" 2>/dev/null || echo "unknown")
    TABLE_COUNT=$(jq -r '.statistics.tables // "unknown"' "$BACKUP_DIR/metadata.json" 2>/dev/null || echo "unknown")
    INSERT_COUNT=$(jq -r '.statistics.insert_statements // "unknown"' "$BACKUP_DIR/metadata.json" 2>/dev/null || echo "unknown")
    
    echo -e "   Date: $BACKUP_DATE"
    echo -e "   Tables: $TABLE_COUNT"
    echo -e "   Insert Statements: $INSERT_COUNT"
fi

DATA_SIZE=$(du -h "$BACKUP_DIR/data.sql" | cut -f1)
echo -e "   Data Size: $DATA_SIZE"
echo ""

# ==============================================================================
# ANALYZE CURRENT SCHEMA
# ==============================================================================

log_info "Analyzing current database schema..."

TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Get current tables
psql "$DB_URL" -t -c "\dt public.*" 2>/dev/null | awk '{print $3}' | grep -v "^$" > "$TEMP_DIR/current_tables.txt" || true

CURRENT_TABLE_COUNT=$(wc -l < "$TEMP_DIR/current_tables.txt" | xargs)
log_success "Found $CURRENT_TABLE_COUNT tables in current schema"

# ==============================================================================
# EXTRACT TABLES FROM BACKUP
# ==============================================================================

log_info "Analyzing backup data..."

grep "^INSERT INTO public\." "$BACKUP_DIR/data.sql" | \
    sed 's/INSERT INTO public\.\([^ ]*\).*/\1/' | \
    sort -u > "$TEMP_DIR/backup_tables.txt"

BACKUP_TABLE_COUNT=$(wc -l < "$TEMP_DIR/backup_tables.txt" | xargs)
log_success "Found $BACKUP_TABLE_COUNT tables in backup"

# ==============================================================================
# DETERMINE WHAT TO RESTORE
# ==============================================================================

echo ""
log_info "Comparing schemas..."

# Tables that exist in both
comm -12 "$TEMP_DIR/current_tables.txt" "$TEMP_DIR/backup_tables.txt" > "$TEMP_DIR/restorable_tables.txt"
RESTORABLE_COUNT=$(wc -l < "$TEMP_DIR/restorable_tables.txt" | xargs)

# Tables only in backup (missing in current schema)
comm -13 "$TEMP_DIR/current_tables.txt" "$TEMP_DIR/backup_tables.txt" > "$TEMP_DIR/missing_tables.txt"
MISSING_COUNT=$(wc -l < "$TEMP_DIR/missing_tables.txt" | xargs)

# Tables only in current schema (new tables)
comm -23 "$TEMP_DIR/current_tables.txt" "$TEMP_DIR/backup_tables.txt" > "$TEMP_DIR/new_tables.txt"
NEW_COUNT=$(wc -l < "$TEMP_DIR/new_tables.txt" | xargs)

echo ""
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Schema Comparison Results:${NC}"
echo -e "${GREEN}  ✅ Restorable tables:${NC} $RESTORABLE_COUNT (exist in both schemas)"
if [ "$MISSING_COUNT" -gt 0 ]; then
    echo -e "${RED}  ❌ Missing tables:${NC} $MISSING_COUNT (in backup but not in current schema)"
fi
if [ "$NEW_COUNT" -gt 0 ]; then
    echo -e "${BLUE}  ℹ️  New tables:${NC} $NEW_COUNT (in current schema but not in backup)"
fi
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Show missing tables if any
if [ "$MISSING_COUNT" -gt 0 ]; then
    log_warning "The following tables cannot be restored (missing in current schema):"
    while IFS= read -r table; do
        echo -e "     • ${RED}$table${NC}"
    done < "$TEMP_DIR/missing_tables.txt"
    echo ""
fi

# Filter tables if specific ones requested
if [ ${#SPECIFIC_TABLES[@]} -gt 0 ]; then
    log_info "Filtering for specific tables: ${SPECIFIC_TABLES[*]}"
    > "$TEMP_DIR/filtered_tables.txt"
    for table in "${SPECIFIC_TABLES[@]}"; do
        if grep -q "^$table$" "$TEMP_DIR/restorable_tables.txt"; then
            echo "$table" >> "$TEMP_DIR/filtered_tables.txt"
        else
            log_warning "Table '$table' not found or not restorable"
        fi
    done
    mv "$TEMP_DIR/filtered_tables.txt" "$TEMP_DIR/restorable_tables.txt"
    RESTORABLE_COUNT=$(wc -l < "$TEMP_DIR/restorable_tables.txt" | xargs)
fi

if [ "$RESTORABLE_COUNT" -eq 0 ]; then
    log_error "No tables to restore"
    exit 1
fi

# ==============================================================================
# CONFIRM RESTORATION
# ==============================================================================

if [ "$INTERACTIVE" = true ]; then
    echo -e "${YELLOW}Tables to restore:${NC}"
    cat "$TEMP_DIR/restorable_tables.txt" | while read table; do
        echo -e "  • $table"
    done
    echo ""
    
    if [ "$DRY_RUN" = false ]; then
        read -p "$(echo -e ${YELLOW}"Proceed with restoration? (yes/no): "${NC})" -r
        echo
        if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
            log_info "Restoration cancelled"
            exit 0
        fi
    fi
fi

# ==============================================================================
# PERFORM RESTORATION
# ==============================================================================

if [ "$DRY_RUN" = true ]; then
    log_info "DRY RUN MODE - No changes will be made"
    echo ""
fi

log_info "Starting intelligent data restoration..."
echo ""

# Create restore script
RESTORE_SCRIPT="$TEMP_DIR/restore.sql"
echo "-- Intelligent Data Restore Script" > "$RESTORE_SCRIPT"
echo "-- Generated: $(date)" >> "$RESTORE_SCRIPT"
echo "SET session_replication_role = replica;" >> "$RESTORE_SCRIPT"
echo "" >> "$RESTORE_SCRIPT"

TOTAL_INSERTS=0
SUCCESSFUL_TABLES=0
FAILED_TABLES=0

# Process each table
while IFS= read -r table; do
    echo -e "${BLUE}Processing table: ${CYAN}$table${NC}"
    
    # Extract inserts for this table
    grep "^INSERT INTO public\.$table" "$BACKUP_DIR/data.sql" > "$TEMP_DIR/${table}_inserts.sql" 2>/dev/null || true
    
    TABLE_INSERTS=$(wc -l < "$TEMP_DIR/${table}_inserts.sql" | xargs)
    
    if [ "$TABLE_INSERTS" -eq 0 ]; then
        log_warning "  No data found for $table"
        continue
    fi
    
    # Add to restore script with ON CONFLICT DO NOTHING
    {
        echo "-- Table: $table ($TABLE_INSERTS inserts)"
        cat "$TEMP_DIR/${table}_inserts.sql" | sed 's/;$/ ON CONFLICT DO NOTHING;/'
        echo ""
    } >> "$RESTORE_SCRIPT"
    
    TOTAL_INSERTS=$((TOTAL_INSERTS + TABLE_INSERTS))
    
    if [ "$DRY_RUN" = false ]; then
        # Execute restoration
        if cat "$TEMP_DIR/${table}_inserts.sql" | sed 's/;$/ ON CONFLICT DO NOTHING;/' | psql "$DB_URL" > /dev/null 2>&1; then
            log_success "  ✅ Restored $TABLE_INSERTS rows"
            SUCCESSFUL_TABLES=$((SUCCESSFUL_TABLES + 1))
        else
            log_error "  ❌ Failed to restore (check column compatibility)"
            FAILED_TABLES=$((FAILED_TABLES + 1))
        fi
    else
        echo -e "  ${BLUE}Would restore: $TABLE_INSERTS rows${NC}"
        SUCCESSFUL_TABLES=$((SUCCESSFUL_TABLES + 1))
    fi
    
done < "$TEMP_DIR/restorable_tables.txt"

# Reset triggers
echo "SET session_replication_role = DEFAULT;" >> "$RESTORE_SCRIPT"

# Save restore script for reference
RESTORE_LOG="$BACKUP_DIR/restore_report_$(date +%Y%m%d_%H%M%S).log"
cp "$RESTORE_SCRIPT" "$RESTORE_LOG"

# ==============================================================================
# SUMMARY
# ==============================================================================

echo ""
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ "$DRY_RUN" = true ]; then
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  DRY RUN COMPLETE - No Changes Made                       ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
else
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✅ Data Restoration Complete!                            ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
fi

echo ""
echo -e "${BLUE}📊 Restoration Summary:${NC}"
echo -e "   • Total tables processed: $RESTORABLE_COUNT"
echo -e "   • Successful: ${GREEN}$SUCCESSFUL_TABLES${NC}"
if [ "$FAILED_TABLES" -gt 0 ]; then
    echo -e "   • Failed: ${RED}$FAILED_TABLES${NC}"
fi
echo -e "   • Total inserts attempted: $TOTAL_INSERTS"
echo ""
echo -e "${BLUE}📄 Restore log saved to:${NC}"
echo -e "   $RESTORE_LOG"
echo ""

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}💡 To perform actual restoration, run without --dry-run flag${NC}"
else
    echo -e "${GREEN}✨ Data restoration completed successfully!${NC}"
fi

echo ""
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

exit 0