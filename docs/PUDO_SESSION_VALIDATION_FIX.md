# PUDO Brickshare Deposit Selection - Session Validation Fix

**Date:** 26/3/2026  
**Issue:** Error 409 (Conflict) when confirming Brickshare deposit for user3  
**Root Cause:** Corrupted/desynchronized authentication session

---

## Problem Summary

When user3 tried to confirm a Brickshare deposit selection, the following error occurred:

```
[saveUserBricksharePudo] Error saving to users_brickshare_dropping:
{
  code: '23503',
  message: 'insert or update on table "users_brickshare_dropping" violates foreign key constraint "users_brickshare_dropping_user_id_fkey"',
  hint: 'Key is not present in table "users"'
}
```

### Root Cause Analysis

1. **Actual user ID in DB:** `b8b3ebbb-9d34-41d0-8afa-6464e1996115`
2. **User ID in browser session:** `67bb6ea4-7d17-4c1f-993e-aa3bb6737f9c` (invalid/corrupted)
3. **Foreign key violation:** The corrupted ID doesn't exist in `auth.users`, so the INSERT fails

This happens when:
- Database is reset but browser caches old auth tokens
- Multiple login/logout cycles without clearing session storage
- Supabase local environment issues (mismatched auth state)

---

## Solution Implemented

### 1. Defensive Validation in `pudoService.ts`

Added `validateUserExists()` function that checks if the user_id is valid before attempting to save PUDO data:

```typescript
async function validateUserExists(userId: string): Promise<void> {
    const { data, error } = await supabase
        .from('users')
        .select('user_id')
        .eq('user_id', userId)
        .single();

    if (error || !data) {
        throw new Error(
            'Invalid user session. Your user ID is not found in the database. ' +
            'Please log out completely (localStorage.clear()) and log in again.'
        );
    }
}
```

Both `saveUserCorreosPudo()` and `saveUserBricksharePudo()` now validate the session before attempting to save.

### 2. Periodic Session Validation in `AuthContext.tsx`

Added a 5-minute interval check that validates session integrity:

```typescript
// Runs every 5 minutes
const validationInterval = setInterval(async () => {
    const { data: { session } } = await supabase.auth.getSession();
    
    if (session?.user) {
        const { data: userExists } = await supabase
            .from('users')
            .select('user_id')
            .eq('user_id', session.user.id)
            .maybeSingle();

        if (!userExists) {
            // Corrupted session detected - force logout
            await supabase.auth.signOut();
            // ... clear state
        }
    }
}, 5 * 60 * 1000);
```

---

## How to Fix user3's Session

### Option A: Manual Fix (Client-side)

1. Open browser DevTools (F12)
2. Go to Console tab
3. Run:
   ```javascript
   localStorage.clear();
   sessionStorage.clear();
   ```
4. Refresh the page
5. Log out completely and log in again as `user3@brickshare.com`
6. Try the deposit selection again

### Option B: Database Fix (Server-side)

If the user still can't log in, check if user3 exists in both tables:

```sql
-- Check auth.users
SELECT id, email FROM auth.users WHERE email = 'user3@brickshare.com';

-- Should return: b8b3ebbb-9d34-41d0-8afa-6464e1996115 | user3@brickshare.com

-- Check public.users
SELECT user_id, email FROM public.users WHERE email = 'user3@brickshare.com';

-- Should return: b8b3ebbb-9d34-41d0-8afa-6464e1996115 | user3@brickshare.com
```

If `public.users` is missing the user, sync it:

```sql
INSERT INTO public.users (user_id, email)
SELECT id, email FROM auth.users 
WHERE email = 'user3@brickshare.com'
ON CONFLICT (user_id) DO NOTHING;
```

---

## Technical Details

### Foreign Key Constraint

The `users_brickshare_dropping` table has:

```sql
FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
```

This means the user_id MUST exist in `auth.users.id`. If it doesn't:
- Error 23503 (Foreign Key Violation)
- Error message: "Key is not present in table 'users'"

### Why Validation Matters

1. **Prevents unclear errors:** Instead of "Key is not present in table", users see "Invalid session - please log in again"
2. **Auto-recovery:** Periodic validation detects corruption and forces logout (allows fresh login)
3. **Defensive coding:** Catches edge cases from auth infrastructure issues

---

## Affected Functions

Modified functions:
- `saveUserBricksharePudo()` - Added validation before saving
- `saveUserCorreosPudo()` - Added validation before saving
- `AuthContext` - Added periodic session validation hook

These changes are backwards compatible and only add extra safety checks.

---

## Testing Recommendations

1. **Normal flow:** User logs in → selects Brickshare deposit → saves successfully ✅
2. **Corrupted session:** 
   - Manually create invalid token in localStorage
   - Try to select deposit
   - Should get clear error message: "Invalid user session..."
3. **Periodic validation:**
   - Manually delete user from `public.users` while logged in
   - Wait 5 minutes
   - Should auto-logout with console error

---

## Prevention

This fix is now deployed. Future session corruption will be:
1. **Caught immediately** when trying to save PUDO data
2. **Detected automatically** every 5 minutes by AuthContext validation
3. **Reported clearly** to the user with actionable next steps