# Assignment Function set_dim Fix

**Date**: 2026-03-24  
**Migration**: `20260324171000_remove_set_dim_from_assignment.sql`

## Problem

The `confirm_assign_sets_to_users` function was referencing a column `set_dim` that doesn't exist in the `sets` table, causing runtime errors during set assignment operations.

### Error Message
```
ERROR (42703): column s.set_dim does not exist
```

## Root Cause

The function was attempting to fetch `s.set_dim` from the sets table in the SELECT statement:
```sql
SELECT 
    w.set_id,
    s.set_name,
    s.set_ref,
    s.set_weight,
    s.set_dim  -- ❌ This column doesn't exist
INTO ...
```

## Solution

Removed all references to `set_dim` from the `confirm_assign_sets_to_users` function:

1. **Removed from SELECT query**: Eliminated `s.set_dim` from the query that fetches set details
2. **Removed from DECLARE section**: Removed `v_set_dim TEXT` variable declaration
3. **Removed from return assignment**: Removed assignment to `confirm_assign_sets_to_users.set_dim`
4. **Removed from RETURN TABLE**: Removed `set_dim text` from the function's return type

## Verification

After applying the migration:

```sql
-- Test the function
SELECT * FROM preview_assign_sets_to_users();
SELECT * FROM confirm_assign_sets_to_users(ARRAY['user-uuid-here']::uuid[]);
```

## Function Behavior (Confirmed)

The updated `confirm_assign_sets_to_users` function correctly:

✅ Updates `users.user_status` to `'set_shipping'`  
✅ Creates shipment with `shipment_status = 'assigned'`  
✅ Populates `shipping_address`, `shipping_city`, `shipping_zip_code` from selected PUDO point  
✅ Handles both Correos and Brickshare PUDO types  
✅ Updates inventory (`inventory_set_total_qty`, `in_shipping`)  
✅ Marks wishlist item as assigned  

## Related Files

- **Migration**: `supabase/migrations/20260324171000_remove_set_dim_from_assignment.sql`
- **TypeScript Types**: `src/types/supabase.ts` (regenerated)
- **Previous Fix**: `docs/ASSIGNMENT_SHIPMENT_FIX.md`

## Notes

- The `set_dim` column was dropped from the `sets` table in migration `20260203190000_drop_set_dim.sql`
- This fix ensures consistency between the function and the actual database schema
- No frontend changes required as `set_dim` was not being used in the UI