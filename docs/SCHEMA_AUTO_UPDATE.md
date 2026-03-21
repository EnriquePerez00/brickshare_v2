# Schema Auto-Update System

## 📋 Description

This system automatically keeps the database schema documentation up-to-date whenever migrations are committed. It uses a Git pre-commit hook that detects changes in `supabase/migrations/` and regenerates the schema docs.

## 🎯 Components

### 1. Git Hook Pre-commit
**Location**: `.git/hooks/pre-commit`

Runs automatically before each commit and:
- Checks if migration files are staged
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
npm run dump-schema
```

### For other developers:

```bash
# Run the installation script
bash scripts/install-hooks.sh
```

## 📝 Usage

### Automatic
The hook runs automatically on every commit. You'll see a message like:

```
🔍 Migration detected, updating schema documentation...
✅ Schema documentation updated and added to commit
```

### Manual
If you need to regenerate the schema without committing:

```bash
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
1. Developer makes changes to SQL migrations
   ↓
2. Runs: git add . && git commit -m "..."
   ↓
3. Pre-commit hook activates automatically
   ↓
4. docs/DATABASE_SCHEMA.md and docs/schema_dump.sql are regenerated
   ↓
5. If there are changes, they are added to the commit
   ↓
6. Commit completes with code + updated schema documentation
```

## 💡 Benefits

✅ **Always up-to-date documentation**: Schema docs reflect the actual DB state
✅ **Change review**: Schema changes are visible in pull requests
✅ **Full history**: Git maintains the complete schema evolution history
✅ **Automation**: Zero manual effort to keep documentation in sync

## ℹ️ Note

This project uses **local Supabase only** (via Docker). There is no remote Supabase database. All migrations are applied locally via `supabase db reset`.

## 📚 References

- [Supabase CLI Documentation](https://supabase.com/docs/guides/cli)
- [Git Hooks Documentation](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks)