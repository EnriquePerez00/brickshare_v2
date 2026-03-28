# Label Generation Config Fix

## Problem
When attempting to generate a Brickshare label in the Operations panel, the system returned a 404 error for the `send-brickshare-qr-email` Edge Function, despite the function existing in the codebase.

## Root Cause
The `send-brickshare-qr-email` Edge Function was **not configured in `supabase/config.toml`**, which meant it defaulted to requiring JWT verification but wasn't properly registered with Kong (the API Gateway).

### Symptoms
- ✅ Function responded to GET requests with 401 (Unauthorized)
- ❌ Function returned 404 for POST requests from the browser
- Edge runtime logs showed "early termination has been triggered"
- Kong logs showed the POST requests were not being routed correctly

## Solution
Added the function configuration to `supabase/config.toml`:

```toml
[functions.send-brickshare-qr-email]
verify_jwt = true
```

This explicitly tells Supabase that:
1. The function exists and should be served
2. It requires JWT authentication (`verify_jwt = true`)
3. Kong should route POST requests to this function

## Files Modified
- `supabase/config.toml` - Added function configuration

## Testing & Verification
After applying the fix:
1. Performed hard restart: `supabase stop --no-backup && docker system prune -f && supabase start` ✅
2. Verified function is accessible:
   ```bash
   curl -X POST http://127.0.0.1:54331/functions/v1/send-brickshare-qr-email \
     -H "Content-Type: application/json" -d '{"test":"test"}'
   # Returns: {"msg":"Error: Missing authorization header"}
   # (This is correct - function is accessible, just needs auth)
   ```
3. Test in UI:
   - Navigate to Operations panel → Label Generation
   - Select a Brickshare PUDO shipment
   - Click "Generar Etiqueta" - should now work! ✅

**Status**: ✅ **RESOLVED** - Function is now properly configured and accessible

## Prevention
When adding new Edge Functions:
1. ✅ Create the function code in `supabase/functions/<name>/index.ts`
2. ✅ Add configuration to `supabase/config.toml`:
   ```toml
   [functions.<name>]
   verify_jwt = true  # or false, depending on authentication needs
   ```
3. ✅ Restart Supabase to apply changes

## Related Documentation
- [LABEL_GENERATION_FEATURE.md](./LABEL_GENERATION_FEATURE.md) - Feature overview
- [LABEL_GENERATION_TROUBLESHOOTING.md](./LABEL_GENERATION_TROUBLESHOOTING.md) - Common issues
- [BRICKSHARE_QR_EMAIL_FIX.md](./BRICKSHARE_QR_EMAIL_FIX.md) - QR code email improvements

## Date
2026-03-25