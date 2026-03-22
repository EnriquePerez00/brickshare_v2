# Schema Auto-Update System

## 📋 Description

This system automatically keeps the local database and schema documentation up-to-date whenever migrations are committed. It uses a Git pre-commit hook that detects changes in `supabase/migrations/` and:

1. **Applies pending migrations** to the local database (`supabase migration up --local`)
2. **Regenerates schema documentation** (`docs/DATABASE_SCHEMA.md` and `docs/schema_dump.sql`)

## 🎯 Components

### 1. Git Hook Pre-commit
**Location**: `.git/hooks/pre-commit`

Runs automatically before each commit and:
- Checks if migration files are staged
- Applies pending migrations to the local database via `supabase migration up --local`
- **Blocks the commit if migration fails** (so you can fix the SQL before committing)
- Runs `scripts/update-schema-docs.sh` to regenerate documentation
- Saves the result to `docs/DATABASE_SCHEMA.md` and `docs/schema_dump.sql`
- Adds the updated files to the commit

### 2. NPM Script
**Command**: `npm run dump-schema`

To manually regenerate the schema documentation when needed.

### 3. Installation Script
**Location**: `scripts/install-hooks.sh`

Script to install the git hook on developer machines.

## 🚀 Setup

### First-time setup:

```bash
# 1. Make sure Supabase local is running
supabase start

# 2. Install git hooks
bash scripts/install-hooks.sh

# 3. Verify it works
supabase migration up --local
npm run dump-schema
```

### For other developers:

```bash
# Run the installation script
bash scripts/install-hooks.sh
```

## 📝 Usage

### Automatic (recommended)
The hook runs automatically on every commit that includes migration files. You'll see:

```
🔍 Detectada migración en el commit...
  → Aplicando migraciones pendientes a la BBDD local...
  ✅ Migraciones aplicadas correctamente a la BBDD local
  → Actualizando documentación del esquema...
  ✅ Documentación del esquema actualizada y añadida al commit
🎉 BBDD local actualizada y documentación regenerada
```

If a migration has errors, the commit is **blocked**:
```
  ❌ Error al aplicar migraciones a la BBDD local
     Revisa el error y corrige la migración antes de hacer commit
```

### Manual
If you need to apply migrations or regenerate docs without committing:

```bash
# Apply pending migrations to local DB
supabase migration up --local

# Regenerate schema documentation
npm run dump-schema
```

## ⚠️ Troubleshooting

### Error: "Supabase is not running"

```bash
supabase start
```

### The hook doesn't run

Verify it's executable:
```bash
chmod +x .git/hooks/pre-commit
```

### Migration fails on commit

Fix the SQL file in `supabase/migrations/`, then retry the commit. The hook blocks commits with broken migrations to keep the local DB consistent.

### Temporarily disable the hook

Rename the file:
```bash
mv .git/hooks/pre-commit .git/hooks/pre-commit.disabled
```

To re-enable:
```bash
mv .git/hooks/pre-commit.disabled .git/hooks/pre-commit
```

## 📂 System Files

```
.git/hooks/pre-commit           # Hook that runs on each commit
docs/DATABASE_SCHEMA.md          # Auto-generated schema documentation
docs/schema_dump.sql             # Auto-generated SQL dump
scripts/update-schema-docs.sh    # Schema documentation generator
scripts/install-hooks.sh         # Hook installer for devs
package.json                     # Contains "dump-schema" script
```

## 🔄 Workflow

```
1. Developer creates/edits SQL migration in supabase/migrations/
   ↓
2. Runs: git add . && git commit -m "..."
   ↓
3. Pre-commit hook activates automatically
   ↓
4. supabase migration up --local applies pending migrations
   ↓
5. If migration fails → commit is BLOCKED (fix the SQL and retry)
   ↓
6. docs/DATABASE_SCHEMA.md and docs/schema_dump.sql are regenerated
   ↓
7. Updated docs are added to the commit automatically
   ↓
8. Commit completes with code + migrated DB + updated docs
```

## 💡 Benefits

✅ **Local DB always in sync**: Migrations are applied before the commit completes
✅ **Early error detection**: Broken migrations block the commit, preventing inconsistencies
✅ **Always up-to-date documentation**: Schema docs reflect the actual DB state
✅ **Change review**: Schema changes are visible in pull requests
✅ **Full history**: Git maintains the complete schema evolution history
✅ **Automation**: Zero manual effort to keep DB and documentation in sync

## ℹ️ Note

This project uses **local Supabase only** (via Docker). There is no remote database. All migrations are applied locally via `supabase migration up --local` (incremental) or `supabase db reset` (full reset).

## 📚 References

- [Supabase CLI Documentation](https://supabase.com/docs/guides/cli)
- [Supabase Migration Up](https://supabase.com/docs/reference/cli/supabase-migration-up)
- [Git Hooks Documentation](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks)