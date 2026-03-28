# Sync Auth Users to Local Database

## 📋 Overview

This script synchronizes users from a remote Supabase instance (production/staging) to your local development database. It's useful when you need to work with real user data locally for testing or development purposes.

## 🎯 What It Does

1. **Reads** all users from remote Supabase `auth.users` table
2. **Fetches** user profiles from remote `public.users` table
3. **Creates** users in local database with:
   - Auth entry in `auth.users` (with generic password `Test1234`)
   - Profile in `public.users`
   - Identity in `auth.identities`
   - Role assignment in `user_roles`

## ⚙️ Prerequisites

1. **Local Supabase running**:
   ```bash
   supabase start
   ```

2. **Remote Supabase credentials**:
   - Remote Supabase URL
   - Remote Supabase Service Role Key (with admin access)

## 🔧 Configuration

⚠️ **DEPRECATED**: This script is no longer maintained as the project now uses 100% local development.

Remote Supabase synchronization is no longer supported. All development is performed locally using Docker.

For testing purposes, create local test users directly using the provided scripts.

## 🚀 Usage

### Basic Usage

```bash
# From project root
npx ts-node scripts/sync-auth-users-to-local.ts
```

### Alternative with npm script

You can add this to `package.json`:

```json
{
  "scripts": {
    "sync-users": "ts-node scripts/sync-auth-users-to-local.ts"
  }
}
```

Then run:

```bash
npm run sync-users
```

## 📊 Script Output

The script provides detailed output during execution:


📥 Fetching users from remote Supabase...
   URL: https://your-project.supabase.co
```
🚀 Starting Auth Users Sync to Local Database [DEPRECATED]

📥 Fetching users from remote Supabase... [This script is no longer maintained]
   URL: [local only]
============================================================

📥 Fetching users from remote Supabase...
   URL: https://your-project.supabase.co
✅ Found 15 users in remote auth.users

📥 Fetching user profiles from remote database...
✅ Found 15 user profiles

✅ Connected to local PostgreSQL database

🔄 Syncing user: user1@example.com
   ✅ Successfully synced: user1@example.com
      - ID: abc-123-def-456
      - Name: John Doe
      - Password: Test1234

🔄 Syncing user: user2@example.com
   ✅ Successfully synced: user2@example.com
      - ID: xyz-789-uvw-012
      - Name: Jane Smith
      - Password: Test1234

⏭️  Skipping admin@brickshare.com - already exists locally

============================================================
📊 Sync Summary:
   ✅ Successfully synced: 13
   ⏭️  Skipped (already exist): 2
   ❌ Errors: 0
   📝 Total processed: 15
============================================================

🔐 Generic Password for all synced users: Test1234
💡 Users can now log in to local instance with their email and this password

✅ Sync completed successfully!
```

## 🔐 Important Notes

### Generic Password

- **All synced users** will have the password: `Test1234`
- Original passwords are **not** copied (they're hashed and cannot be retrieved)
- Users can log in locally with: `their-email@example.com` / `Test1234`

### Duplicate Prevention

- Script checks if user already exists locally
- Existing users are **skipped** (not overwritten)
- Only new users are created

### Data Synced

| Table | Fields Synced |
|-------|---------------|
| `auth.users` | id, email, email_confirmed_at, metadata |
| `public.users` | Profile info, subscription data, addresses |
| `auth.identities` | Email provider identity |
| `user_roles` | Assigns 'user' role |

## 🛠️ Troubleshooting

### Error: Missing environment variables

```
❌ Missing required environment variables:
   - REMOTE_SUPABASE_URL
   - REMOTE_SUPABASE_SERVICE_ROLE_KEY
```

**Solution**: Add the variables to `.env.main` file.

---

### Error: Cannot connect to local database

```
❌ Fatal error: connect ECONNREFUSED 127.0.0.1:54322
```

**Solution**: Start local Supabase:
```bash
supabase start
```

---

### Error: Invalid Service Role Key

```
❌ Error fetching remote users: Invalid JWT
```

**Solution**: 
1. Verify your `REMOTE_SUPABASE_SERVICE_ROLE_KEY` is correct
2. Ensure it's the **Service Role Key**, not the Anon Key
3. Get it from: Supabase Dashboard → Settings → API

---

### Warning: Some users failed to sync

Check the detailed error output for each failed user. Common issues:
- Email already exists in local `auth.users` (should be skipped)
- Missing required fields in remote profile
- Database constraint violations

## 🔄 Workflow Example

```bash
# 1. Start local Supabase
supabase start

# 2. Sync users from production
npx ts-node scripts/sync-auth-users-to-local.ts

# 3. Verify users were created
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres -c \
  "SELECT email, full_name FROM users ORDER BY created_at DESC LIMIT 10;"

# 4. Test login with any synced user
# Email: user@example.com
# Password: Test1234
```

## 🔒 Security Considerations

1. **Never commit** `.env.main` with real credentials
2. **Service Role Key** has admin access - protect it carefully
3. **Generic password** (`Test1234`) should only be used in local development
4. Consider adding `.env.main` to `.gitignore` if not already present

## 📝 Additional Options

### Use Local Test Scripts Instead

Use these scripts to create local test users:
- `scripts/create-user-brickshare.sql` - Create individual test user
- `scripts/setup-test-user.sql` - Create complete test user with wishlist
- `scripts/db-reset.sh` - Reset local database with seed data

## 🎯 Related Scripts

- `scripts/create-user-brickshare.sql` - Create individual test user
- `scripts/setup-test-user.sql` - Create complete test user with wishlist
- `scripts/db-reset.sh` - Reset local database

## 📚 Technical Details

### Database Operations

The script uses PostgreSQL transactions to ensure data consistency:

```sql
BEGIN;
  -- 1. Insert into auth.users
  -- 2. Insert into public.users
  -- 3. Insert into auth.identities
  -- 4. Insert into user_roles
COMMIT;
```

If any step fails, the entire transaction is rolled back.

### Password Hashing

Uses PostgreSQL's built-in `crypt()` function with bcrypt:

```sql
encrypted_password = crypt('Test1234', gen_salt('bf'))
```

This creates a secure bcrypt hash compatible with Supabase Auth.

## 🆘 Need Help?

If you encounter issues:

1. Check Supabase is running: `supabase status`
2. Verify remote credentials are correct
3. Check script output for specific error messages
4. Review this documentation for troubleshooting steps

---

**Created**: 2026-03-24  
**Script**: `scripts/sync-auth-users-to-local.ts`  
**Author**: Brickshare Dev Team