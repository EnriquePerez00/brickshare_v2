# Brickshare Deposit Selection Fix

## Problem Description

When selecting a PUDO point of type "depósito brickshare" (Brickshare deposit), users encountered an error:
**"Error al actualizar el punto de entrega"**

The selection appeared to work (green marker was clickable), but confirmation failed.

## Root Cause

The issue was in the data flow when saving a Brickshare deposit:

1. **PudoSelector Component** (`apps/web/src/components/PudoSelector.tsx`):
   - Fetches Brickshare deposits from `/api/locations-local` 
   - Creates `PUDOPoint` objects with `id_correos_pudo = dep.id`
   - Sets `tipo_punto = "Deposito"`

2. **Dashboard handlePudoSelect** (`apps/web/src/pages/Dashboard.tsx`):
   - Normalizes the `tipo_punto` to match database constraints
   - Routes to `saveBricksharePudoMutation` for Deposito types

3. **Transform Function** (`apps/web/src/lib/pudoService.ts`):
   - `transformPUDOPointToBricksharePudo()` maps fields
   - **KEY FIX**: Correctly maps `id_correos_pudo` → `brickshare_pudo_id`

4. **Database** (`users_brickshare_dropping` table):
   - Requires NOT NULL `brickshare_pudo_id` field
   - No FK constraint (removed in migration 20260324101000) to allow dynamic IDs

## Solution Applied

### 1. Migration: `20260324165000_fix_brickshare_pudo_id_handling.sql`

- Added documentation to clarify field usage
- Ensured `brickshare_pudo_id` is NOT NULL
- No schema changes needed - issue was in frontend logic

### 2. Code Fix: `apps/web/src/lib/pudoService.ts`

Enhanced `transformPUDOPointToBricksharePudo()`:
```typescript
export function transformPUDOPointToBricksharePudo(pudoPoint: PUDOPoint): Partial<BricksharePudoPoint> {
    // Validation: ensure ID exists
    if (!pudoPoint.id_correos_pudo) {
        throw new Error('Cannot transform PUDO point: missing ID');
    }
    
    return {
        brickshare_pudo_id: pudoPoint.id_correos_pudo, // KEY: Map universal ID to Brickshare ID
        location_name: pudoPoint.nombre,
        address: pudoPoint.direccion,
        city: pudoPoint.ciudad,
        postal_code: pudoPoint.cp,
        province: pudoPoint.ciudad,
        latitude: pudoPoint.lat,
        longitude: pudoPoint.lng,
        opening_hours: { description: pudoPoint.horario },
    };
}
```

## Data Flow (Fixed)

```
User clicks Brickshare deposit marker
  ↓
PudoSelector creates PUDOPoint with:
  - id_correos_pudo = "deposit-id-123"
  - tipo_punto = "Deposito"
  ↓
Dashboard.handlePudoSelect()
  - Normalizes tipo_punto → "Deposito"
  - Calls transformPUDOPointToBricksharePudo()
  ↓
Transform function maps:
  - id_correos_pudo → brickshare_pudo_id ✅
  - Other fields correctly
  ↓
saveBricksharePudoMutation saves to:
  - users_brickshare_dropping (brickshare_pudo_id = "deposit-id-123")
  - users table (pudo_id = "deposit-id-123", pudo_type = "brickshare")
  ↓
Success! ✅
```

## Testing

### Automated Test
Run: `./scripts/test-deposit-selection-complete.sql`

This script:
1. Creates a test user
2. Creates a test Brickshare deposit location
3. Simulates the PUDO selection flow
4. Verifies data is correctly saved

### Manual Test
1. Start dev server: `npm run dev`
2. Login as a test user
3. Go to Dashboard
4. Click "Seleccionar punto" for PUDO
5. Select a Brickshare deposit (green marker)
6. Click "Confirmar Selección"
7. Should see: "Punto de entrega actualizado correctamente" ✅

## Key Tables

### `users_brickshare_dropping`
- `user_id` (PK, FK to auth.users)
- `brickshare_pudo_id` (TEXT, NOT NULL, no FK constraint)
- Location details (denormalized)

### `users_correos_dropping`
- `user_id` (PK, FK to auth.users)
- `correos_id_pudo` (TEXT, NOT NULL)
- Correos location details

### `users`
- `pudo_id` (TEXT, nullable) - Universal reference
- `pudo_type` ('correos' | 'brickshare', nullable)

## Related Files

- `apps/web/src/components/PudoSelector.tsx` - PUDO selection UI
- `apps/web/src/pages/Dashboard.tsx` - Handles PUDO selection
- `apps/web/src/lib/pudoService.ts` - Transformation logic (FIXED)
- `apps/web/src/hooks/usePudo.ts` - React Query hooks
- `supabase/migrations/20260324095000_refactor_pudo_system.sql` - PUDO system
- `supabase/migrations/20260324101000_remove_brickshare_pudo_fk_constraint.sql` - Remove FK
- `supabase/migrations/20260324165000_fix_brickshare_pudo_id_handling.sql` - Documentation

## Notes

- The `id_correos_pudo` field in `PUDOPoint` is a **universal ID field** used by PudoSelector for all point types
- When `tipo_punto = "Deposito"`, this ID represents a Brickshare location
- When `tipo_punto = "Oficina"` or `"Citypaq"`, this ID represents a Correos location
- No FK constraint on `brickshare_pudo_id` allows dynamic locations from `/api/locations-local`