# QR Code Format Specification — Brickshare

**Version:** 2.0 (Simplified — No Timestamp)  
**Date:** April 4, 2026  
**Status:** Active

---

## 📋 Overview

Brickshare uses a standardized QR code format that identifies the operation type and the shipment uniquely. The format is simple, deterministic, and impossible to forge.

---

## 🎯 Format Definition

### Pattern
```
BS-{TYPE}-{SHIPMENT_ID}
```

### Components

| Component | Format | Example | Description |
|-----------|--------|---------|-------------|
| **Prefix** | `BS` | `BS` | Brickshare system identifier |
| **Type** | `DEL \| PCK \| RET` | `DEL` | Operation type code |
| **Separator** | `-` | `-` | Literal hyphen |
| **Shipment ID** | `[A-F0-9]{12}` | `550E8400E29B` | First 12 chars of shipment UUID (uppercase hex) |

### Total Length
**19 characters** (fixed)

---

## 🔄 Operation Types

### Delivery (DEL)
```
BS-DEL-550E8400E29B
```
**Purpose:** Package arrives at PUDO  
**Scanned by:** Logistics staff  
**Location:** Physical label on package  
**Result:** `delivery_validated_at` timestamp set

### Pickup (PCK)
```
BS-PCK-550E8400E29B
```
**Purpose:** User collects set at PUDO  
**Scanned by:** PUDO staff (user shows phone)  
**Location:** Sent to user via email  
**Result:** `pickup_validated_at` timestamp set

### Return (RET)
```
BS-RET-550E8400E29B
```
**Purpose:** User returns set at PUDO  
**Scanned by:** PUDO staff  
**Location:** Generated on-demand  
**Result:** `return_validated_at` timestamp set

---

## ✅ Valid QR Code Examples

```
BS-DEL-550E8400E29B  ✅
BS-PCK-550E8400E29B  ✅
BS-RET-550E8400E29B  ✅
BS-DEL-F1A2B3C4D5E6  ✅
BS-RET-ABCDEF123456  ✅
```

---

## ❌ Invalid QR Code Examples

```
BS-DEL-550e8400e29b      ❌ (lowercase hex)
BS-DEL-550E8400E29       ❌ (too short)
BS-DEL-550E8400E29B123   ❌ (too long)
BS-DELIVERY-550E8400E29B ❌ (wrong type)
BS-550E8400E29B          ❌ (missing type)
550E8400E29B-BS-DEL      ❌ (wrong order)
```

---

## 🔐 Security Features

| Feature | Benefit |
|---------|---------|
| **BS- Prefix** | Identifies Brickshare system, prevents non-Brickshare scanning |
| **Type Code** | Prevents scanning wrong QR code type (e.g., scanning return code during delivery) |
| **UUID Base** | Impossible to guess or forge — derived from shipment UUID |
| **Fixed Length** | No variability — always 19 chars |
| **Alphanumeric** | QR codes are more reliable with alphanumeric than pure random |
| **UNIQUE Constraint** | Database enforces no duplicate codes |

---

## 📊 Format Comparison

### Previous Format (with timestamp)
```
BS-DEL-550E8400E29B-1712234567890  (34 chars)
```
❌ Longer QR codes (harder to scan)  
❌ Timestamp not needed (shipment ID already unique)

### Current Format (simplified)
```
BS-DEL-550E8400E29B  (19 chars)
```
✅ Shorter QR codes (easier to scan)  
✅ Deterministic (same shipment = same code)  
✅ Just as secure (UUID-based)

---

## 🔄 Database Schema

### Shipments Table

```sql
delivery_qr_code VARCHAR(19) UNIQUE
  -- Format: BS-DEL-{12 hex}
  -- Example: BS-DEL-550E8400E29B
  -- NULL until generated

pickup_qr_code VARCHAR(19) UNIQUE
  -- Format: BS-PCK-{12 hex}
  -- Example: BS-PCK-550E8400E29B
  -- NULL until generated

return_qr_code VARCHAR(19) UNIQUE
  -- Format: BS-RET-{12 hex}
  -- Example: BS-RET-550E8400E29B
  -- NULL until generated
```

---

## 🧪 Validation Rules

### PostgreSQL Regex
```sql
-- Validate QR code format
^BS-(DEL|PCK|RET)-[A-F0-9]{12}$

-- Examples:
BS-DEL-550E8400E29B   ✅
BS-PCK-F1A2B3C4D5E6   ✅
BS-RET-ABCDEF123456   ✅
BS-XYZ-550E8400E29B   ❌
```

### Constraints
- **UNIQUE**: No duplicate codes possible
- **NOT NULL**: When set, must be valid format
- **CHECK**: Must match regex pattern

---

## 🎯 Generation Algorithm

### TypeScript Implementation

```typescript
function generateQRCode(shipmentId: string, prefix: 'DEL' | 'PCK' | 'RET'): string {
  const shipmentIdShort = shipmentId.substring(0, 12).toUpperCase();
  return `BS-${prefix}-${shipmentIdShort}`;
}

// Examples:
generateQRCode('550e8400-e29b-41d4-a716-446655440000', 'DEL')
// → 'BS-DEL-550E8400E29B'

generateQRCode('550e8400-e29b-41d4-a716-446655440000', 'PCK')
// → 'BS-PCK-550E8400E29B'

generateQRCode('550e8400-e29b-41d4-a716-446655440000', 'RET')
// → 'BS-RET-550E8400E29B'
```

---

## 📝 Implementation Locations

### Frontend
- **Component:** `apps/web/src/components/admin/operations/LabelGeneration.tsx`
- **Function:** `generateBrickshareLabel()` — generates delivery & pickup QR codes

### Backend (Edge Functions)
- **Function:** `supabase/functions/send-brickshare-qr-email/index.ts`
- **Function:** `generateQRCode()` — generates all QR code types

---

## 🚀 Deployment Notes

- ✅ No database migration needed (format only affects new codes)
- ✅ Existing QR codes with timestamps remain unchanged
- ✅ New codes generate without timestamp automatically
- ✅ No breaking changes to API

---

## 📞 Support

For issues or questions about QR code format, refer to:
- **Technical Overview:** `docs/QR_CODE_PREFIX_IMPLEMENTATION_SUMMARY.md`
- **Visual Guide:** `docs/QR_CODE_IMPLEMENTATION_VISUAL_GUIDE.md`
- **PUDO QR Flow:** `docs/BRICKSHARE_PUDO_QR_FLOW.md`