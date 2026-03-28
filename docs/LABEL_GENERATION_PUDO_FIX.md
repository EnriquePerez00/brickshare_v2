# Fix: Label Generation Error for Brickshare PUDO (user3)

**Date**: 25/03/2026  
**Issue**: QR code generation failing for Brickshare PUDO deliveries  
**Affected User**: user3 and other users with Brickshare PUDO type  
**Status**: ✅ Fixed

---

## Problem Description

When attempting to generate a QR code label for user3 with a Brickshare PUDO type, the Edge Function `send-brickshare-qr-email` returned a **non-2xx status code error** (404 Not Found).

**Error Message**:
```
Error enviando email QR: Edge Function returned a non-2xx status code
at send-brickshare-qr-email (LabelGeneration.tsx:236:21)
```

---

## Root Cause Analysis

The Edge Function was querying the **incorrect field** to retrieve the Brickshare PUDO location:

### ❌ Incorrect Code (Before)
```typescript
// Tried to get brickshare_pudo_id directly from users table
const { data: user, error: userError } = await supabaseClient
  .from('users')
  .select('email, full_name, brickshare_pudo_id')  // ← Field doesn't exist here!
  .eq('id', shipment.user_id)
  .single();

// Then tried to query brickshare_pudo_locations with non-existent ID
if (user.brickshare_pudo_id) {
  const { data: pudo } = await supabaseClient
    .from('brickshare_pudo_locations')
    .select('name, address, ...')
    .eq('id', user.brickshare_pudo_id)  // ← This query returns no results
    .single();
}
```

### Database Schema Reality

The Brickshare PUDO system uses **two separate tables**:

1. **`users` table** (unified PUDO reference):
   - `pudo_id` - The active PUDO point ID
   - `pudo_type` - Type indicator: `'correos'` or `'brickshare'`

2. **`users_brickshare_dropping` table** (detailed Brickshare info):
   - `user_id` - Foreign key to users
   - `brickshare_pudo_id` - Reference to `brickshare_pudo_locations`
   - `location_name`, `address`, `city`, `postal_code`, etc.

The field `brickshare_pudo_id` **does not exist** in the `users` table; it only exists in `users_brickshare_dropping`.

---

## Solution Implemented

### ✅ Corrected Code (After)

**File**: `supabase/functions/send-brickshare-qr-email/index.ts`

#### 1. Query Correct User Fields
```typescript
// Get unified PUDO references from users table
const { data: user, error: userError } = await supabaseClient
  .from('users')
  .select('email, full_name, pudo_id, pudo_type')  // ✓ Correct fields
  .eq('id', shipment.user_id)
  .single();
```

#### 2. JOIN with Brickshare Details
```typescript
// If user has Brickshare PUDO type, fetch detailed info
if (user.pudo_type === 'brickshare' && user.pudo_id) {
  const { data: brickshareDropping, error: bsDropError } = await supabaseClient
    .from('users_brickshare_dropping')  // ✓ Query correct table
    .select('location_name, address, city, postal_code, contact_phone, opening_hours')
    .eq('user_id', shipment.user_id)  // ✓ Use user_id as FK
    .single();
  
  if (brickshareDropping) {
    pudo = brickshareDropping;
  }
}
```

#### 3. Proper Validation
```typescript
// Validate configuration before proceeding
if (shipment.pudo_type === 'brickshare') {
  if (!user.pudo_id || user.pudo_type !== 'brickshare') {
    return new Response(
      JSON.stringify({ 
        error: 'User PUDO not properly configured for Brickshare delivery' 
      }),
      { status: 400, headers: corsHeaders }
    );
  }
  
  if (!pudo) {
    return new Response(
      JSON.stringify({ 
        error: 'Brickshare PUDO location not found for user' 
      }),
      { status: 400, headers: corsHeaders }
    );
  }
}
```

#### 4. Use Correct Field Names
```typescript
// Use location_name (not name) from users_brickshare_dropping
const pudoName = pudo?.location_name || 'Punto Brickshare';  // ✓ Correct field
const pudoAddress = pudo?.address || '';
const pudoCity = pudo?.city || '';
const pudoPostalCode = pudo?.postal_code || '';
```

---

## Files Modified

### 1. `supabase/functions/send-brickshare-qr-email/index.ts`
- ✅ Changed user query to fetch `pudo_id` and `pudo_type`
- ✅ Added JOIN with `users_brickshare_dropping` table
- ✅ Added explicit validation for Brickshare PUDO configuration
- ✅ Updated field references (`location_name` instead of `name`)
- ✅ Improved error messages and logging

### 2. `apps/web/src/components/admin/operations/LabelGeneration.tsx`
- ✅ Updated shipment query to fetch `pudo_id` and `pudo_type` from users
- ✅ Added error logging for debugging

---

## Testing & Verification

### Before Fix
```
POST http://localhost:54321/functions/v1/send-brickshare-qr-email
body: { shipment_id: "...", type: "delivery" }
response: 404 Not Found
error: "Brickshare PUDO location not found"
```

### After Fix
```
POST http://localhost:54321/functions/v1/send-brickshare-qr-email
body: { shipment_id: "...", type: "delivery" }
response: 200 OK
email_sent: true
qr_code: "BS-DEL-XXXXX..."
```

---

## Key Learnings

1. **PUDO System Architecture**:
   - Users store a unified `pudo_id` and `pudo_type` for quick filtering
   - Details are stored in separate tables (`users_brickshare_dropping`, `users_correos_dropping`)
   - Always use the correct table for details

2. **Field Naming Conventions**:
   - `users.pudo_id` - Active PUDO ID (generic)
   - `users_brickshare_dropping.brickshare_pudo_id` - Specific reference
   - `users_brickshare_dropping.location_name` (NOT `name`)

3. **Validation Strategy**:
   - Check `pudo_type` to determine which detail table to query
   - Validate relationships before processing
   - Return clear error messages for debugging

---

## Related Documentation

- `docs/BRICKSHARE_PUDO.md` - PUDO integration overview
- `docs/BRICKSHARE_LOGISTICS_INTEGRATION.md` - Logistics integration details
- `supabase/migrations/20260324095000_refactor_pudo_system.sql` - Schema definition

---

## Impact

✅ **Fixed**: Brickshare PUDO users can now generate QR code labels  
✅ **Improved**: Error messages are now more descriptive  
✅ **Enhanced**: Better logging for debugging future issues  

**Note**: This fix applies to all Brickshare PUDO type shipments, not just user3. Any users with `pudo_type = 'brickshare'` will now work correctly.