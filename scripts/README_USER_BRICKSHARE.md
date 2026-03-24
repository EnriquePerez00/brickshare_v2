# User Brickshare Configuration

## Summary

This document describes the configuration of the test user `user@brickshare.com` in the Brickshare local database.

## User Details

- **Email**: `user@brickshare.com`
- **Password**: `User1test`
- **User ID**: `83c0c80a-aef3-47cc-a6a9-dd9c5172dae4`
- **Full Name**: Jan Perez
- **Role**: `user` (standard customer)

## Database Status

### ✅ auth.users Table
- User exists with email confirmed
- Password hash configured correctly
- Authentication ready

### ✅ public.users Table
- User profile exists
- Subscription: `Frederick Master` (active)
- User status: `no_set`
- Profile completion: Not completed (can be updated if needed)

### ✅ user_roles Table
- Role `user` assigned

### ✅ auth.identities Table
- Email provider identity created
- Provider ID: `user@brickshare.com`

## How to Use

### Login to the Application

1. Start the development server:
   ```bash
   npm run dev
   ```

2. Navigate to `http://localhost:5173`

3. Login with:
   - Email: `user@brickshare.com`
   - Password: `User1test`

### Reset Password (if needed)

To update the password again, run:

```bash
psql postgresql://postgres:postgres@127.0.0.1:5433/postgres -f scripts/set-password-user-brickshare.sql
```

## Script Files

| File | Purpose |
|------|---------|
| `set-password-user-brickshare.sql` | ✅ **USE THIS** - Sets password for existing user |
| `create-user-brickshare.sql` | ⚠️ Old script (has errors, do not use) |
| `update-user-brickshare-password.sql` | ⚠️ Old script (had constraint issues, do not use) |
| `create-verify-user-brickshare.sql` | ⚠️ Old script (had identity issues, do not use) |

## Verification

To verify the user status at any time:

```bash
psql postgresql://postgres:postgres@127.0.0.1:5433/postgres -c "
SELECT 
  'auth.users' as source, 
  id, 
  email, 
  email_confirmed_at IS NOT NULL as confirmed 
FROM auth.users 
WHERE email = 'user@brickshare.com' 
UNION ALL 
SELECT 
  'public.users' as source, 
  user_id as id, 
  email, 
  profile_completed as confirmed 
FROM users 
WHERE email = 'user@brickshare.com';
"
```

Expected output:
```
    source    |                  id                  |        email        | confirmed
--------------+--------------------------------------+---------------------+-----------
 auth.users   | 83c0c80a-aef3-47cc-a6a9-dd9c5172dae4 | user@brickshare.com | t
 public.users | 83c0c80a-aef3-47cc-a6a9-dd9c5172dae4 | user@brickshare.com | f
```

## Notes

- The user existed previously in the database with email `user@brickshare.com`
- The password was updated to `User1test` using the script
- Both `auth.users` and `public.users` tables use the same UUID: `83c0c80a-aef3-47cc-a6a9-dd9c5172dae4`
- The user is ready to authenticate and use the application

## Troubleshooting

### Cannot login
1. Verify Supabase is running: `supabase status`
2. Check user exists: Run verification query above
3. Re-run password script: `psql ... -f scripts/set-password-user-brickshare.sql`

### User not found
If the user doesn't exist, check the current users:
```bash
psql postgresql://postgres:postgres@127.0.0.1:5433/postgres -c "SELECT email, user_id FROM users;"
```

---

**Last Updated**: 2026-03-24  
**Created By**: Automated setup script