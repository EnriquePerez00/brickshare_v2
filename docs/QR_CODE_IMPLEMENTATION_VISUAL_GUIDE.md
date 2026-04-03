# QR Code Implementation — Visual Guide

**Version:** 2.0 (Simplified Format)  
**Date:** April 4, 2026

---

## 📊 Format Overview

### Complete Format
```
┌─────────────────────────────────┐
│  BS-DEL-550E8400E29B            │
├─────────────────────────────────┤
│ BS        = Brickshare System   │
│ DEL       = Operation Type      │
│ 550E8400E29B = Shipment ID (12 hex) │
│ Total = 19 characters (fixed)   │
└─────────────────────────────────┘
```

---

## 🔄 The Three QR Code Types

### 1. DELIVERY QR (BS-DEL-)
```
┌──────────────────────────────┐
│   WAREHOUSE / LOGISTICS      │
│   Scans this code            │
│                              │
│   BS-DEL-550E8400E29B        │
│                              │
│   Result: Package received   │
│   at PUDO                    │
└──────────────────────────────┘
       ↓
   [QR Image: 3cm x 3cm on label]
```

**Purpose:** When package arrives at PUDO  
**Scanned by:** Logistics company staff  
**Location:** Physical label on package  
**Outcome:** `delivery_validated_at` timestamp set

---

### 2. PICKUP QR (BS-PCK-)
```
┌──────────────────────────────┐
│   USER / CUSTOMER            │
│   Shows this code on phone   │
│                              │
│   BS-PCK-550E8400E29B        │
│                              │
│   Result: User collects set  │
│   from PUDO                  │
└──────────────────────────────┘
       ↓
   [QR Image: in email from Brickshare]
```

**Purpose:** User collects set at PUDO  
**Scanned by:** PUDO staff (using phone camera)  
**Location:** Email sent to user  
**Outcome:** `pickup_validated_at` timestamp set

---

### 3. RETURN QR (BS-RET-)
```
┌──────────────────────────────┐
│   USER / CUSTOMER            │
│   Shows this code on phone   │
│                              │
│   BS-RET-550E8400E29B        │
│                              │
│   Result: User returns set   │
│   to PUDO                    │
└──────────────────────────────┘
       ↓
   [QR Image: in return email]
```

**Purpose:** User returns set to PUDO  
**Scanned by:** PUDO staff  
**Location:** Return email / on-demand  
**Outcome:** `return_validated_at` timestamp set

---

## 🎯 Format Breakdown

### Character-by-Character

```
Position  1-2   = "BS"          (Brickshare prefix)
Position  3     = "-"           (Separator)
Position  4-6   = "DEL|PCK|RET" (Operation type - 3 chars)
Position  7     = "-"           (Separator)
Position  8-19  = 12 HEX CHARS  (Shipment ID from UUID)

Example:
B  S  -  D  E  L  -  5  5  0  E  8  4  0  0  E  2  9  B
1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 16 17 18 19
```

---

## 📋 Shipment Lifecycle with QR Codes

```
┌─────────────────────────────────────────────────────────────┐
│                    SHIPMENT LIFECYCLE                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  [STAGE 1: PREPARATION]                                     │
│  └─ Admin generates label                                   │
│     ├─ delivery_qr_code = BS-DEL-550E8400E29B              │
│     ├─ pickup_qr_code = BS-PCK-550E8400E29B                │
│     └─ Email sent with BS-PCK-... to user                   │
│                                                              │
│         ▼                                                    │
│                                                              │
│  [STAGE 2: DELIVERY]                                        │
│  └─ Package in transit                                      │
│     └─ Arrives at PUDO                                      │
│        └─ Logistics scans: BS-DEL-550E8400E29B              │
│           └─ ✅ delivery_validated_at = NOW()              │
│                                                              │
│         ▼                                                    │
│                                                              │
│  [STAGE 3: PICKUP]                                          │
│  └─ User comes to PUDO                                      │
│     └─ Shows phone with email QR: BS-PCK-550E8400E29B       │
│        └─ ✅ pickup_validated_at = NOW()                   │
│           └─ User receives set 🎉                           │
│                                                              │
│         ▼                                                    │
│                                                              │
│  [STAGE 4-5: USAGE]                                         │
│  └─ User enjoys set for 30 days                             │
│                                                              │
│         ▼                                                    │
│                                                              │
│  [STAGE 6: RETURN REQUEST]                                  │
│  └─ User requests return in app                             │
│     └─ return_qr_code generated: BS-RET-550E8400E29B        │
│        └─ Email sent with return QR                         │
│                                                              │
│         ▼                                                    │
│                                                              │
│  [STAGE 7: RETURN]                                          │
│  └─ User returns to PUDO with set                           │
│     └─ Shows phone with return email: BS-RET-550E8400E29B   │
│        └─ ✅ return_validated_at = NOW()                   │
│           └─ Return process starts 📦                       │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🏗️ Database Schema

```
┌─────────────────────────────────────┐
│        SHIPMENTS TABLE              │
├─────────────────────────────────────┤
│ id (UUID)                           │
│ user_id                             │
│ set_ref                             │
│ pudo_type                           │
│                                     │
│ ┌─────────────────────────────────┐│
│ │ DELIVERY QR FIELDS              ││
│ ├─────────────────────────────────┤│
│ │ delivery_qr_code: VARCHAR(19)   ││
│ │ └─ BS-DEL-550E8400E29B          ││
│ │ delivery_validated_at: TIMESTAMP││
│ │ └─ When logistics scanned QR    ││
│ └─────────────────────────────────┘│
│                                     │
│ ┌─────────────────────────────────┐│
│ │ PICKUP QR FIELDS                ││
│ ├─────────────────────────────────┤│
│ │ pickup_qr_code: VARCHAR(19)     ││
│ │ └─ BS-PCK-550E8400E29B          ││
│ │ pickup_validated_at: TIMESTAMP  ││
│ │ └─ When user collected set      ││
│ └─────────────────────────────────┘│
│                                     │
│ ┌─────────────────────────────────┐│
│ │ RETURN QR FIELDS                ││
│ ├─────────────────────────────────┤│
│ │ return_qr_code: VARCHAR(19)     ││
│ │ └─ BS-RET-550E8400E29B          ││
│ │ return_validated_at: TIMESTAMP  ││
│ │ └─ When user returned set       ││
│ └─────────────────────────────────┘│
│                                     │
└─────────────────────────────────────┘
```

---

## ✅ Valid QR Code Format Examples

```
┌─────────────────────────────────┐
│    VALID QR CODE FORMATS        │
├─────────────────────────────────┤
│ BS-DEL-550E8400E29B   ✅        │
│ BS-PCK-F1A2B3C4D5E6   ✅        │
│ BS-RET-ABCDEF123456   ✅        │
│ BS-DEL-000000000000   ✅        │
│ BS-PCK-FFFFFFFFFFFF   ✅        │
│                                 │
│ Length: Always 19 chars         │
│ Format: BS-{TYPE}-{12HEX}       │
└─────────────────────────────────┘
```

---

## ❌ Invalid QR Code Format Examples

```
┌──────────────────────────────────┐
│    INVALID QR CODE FORMATS       │
├──────────────────────────────────┤
│ BS-DEL-550e8400e29b      ❌     │
│ (lowercase hex chars)            │
│                                  │
│ BS-DEL-550E8400E29       ❌     │
│ (too short - only 11 hex)        │
│                                  │
│ BS-DELIVERY-550E8400E29B ❌     │
│ (full word instead of DEL)       │
│                                  │
│ BS-550E8400E29B          ❌     │
│ (missing type code)              │
│                                  │
│ 550E8400E29B-BS-DEL      ❌     │
│ (wrong order)                    │
│                                  │
│ BS-XYZ-550E8400E29B      ❌     │
│ (invalid type code)              │
└──────────────────────────────────┘
```

---

## 🔒 Security Features

```
┌─────────────────────────────────────────┐
│         SECURITY FEATURES               │
├─────────────────────────────────────────┤
│                                         │
│ 🔐 BS- Prefix                          │
│    └─ System identification             │
│       └─ Only Brickshare codes          │
│                                         │
│ 🔐 Type Code (DEL/PCK/RET)              │
│    └─ Operation validation              │
│       └─ Can't use wrong code type      │
│                                         │
│ 🔐 UUID-Based ID                       │
│    └─ Cryptographically unique          │
│       └─ Impossible to guess/forge      │
│                                         │
│ 🔐 UNIQUE Database Constraint           │
│    └─ No duplicates possible            │
│       └─ Enforced at storage level      │
│                                         │
│ 🔐 Fixed Format (19 chars)              │
│    └─ No variability                    │
│       └─ Regex validation               │
│                                         │
└─────────────────────────────────────────┘
```

---

## 🎯 Generation Flow

```
┌────────────────────────────────────────────────┐
│         QR CODE GENERATION FLOW                │
├────────────────────────────────────────────────┤
│                                                │
│ [1] Shipment Created                          │
│     └─ shipment.id = "550e8400-e29b-41d4..."  │
│                                                │
│ [2] Admin Generates Label                      │
│     └─ Calls LabelGeneration Component         │
│                                                │
│ [3] Extract First 12 Hex                      │
│     └─ "550e8400-e29b" → "550E8400E29B"       │
│                                                │
│ [4] Generate Three QR Codes                    │
│     ├─ BS-DEL-550E8400E29B (delivery)         │
│     ├─ BS-PCK-550E8400E29B (pickup)           │
│     └─ (RET generated on-demand later)         │
│                                                │
│ [5] Save to Database                          │
│     └─ delivery_qr_code & pickup_qr_code      │
│                                                │
│ [6] Send to User                              │
│     └─ Email with BS-PCK-550E8400E29B         │
│                                                │
│ [7] Generate QR Images                        │
│     └─ Using qrserver.com API                 │
│        └─ 300x300px PNG images                │
│                                                │
└────────────────────────────────────────────────┘
```

---

## 📏 QR Code Dimensions

```
For Printing:

┌─────────────────────────────────┐
│      PHYSICAL LABEL             │
│      (10cm x 5cm @ 300dpi)      │
│                                 │
│  ┌───────────────┐              │
│  │  [QR CODE]    │              │
│  │  3cm x 3cm    │              │
│  │               │              │
│  │ BS-DEL-550    │ User info    │
│  └───────────────┘              │
│   Enrique López                 │
│   PUDO: La Tienda              │
│                                 │
└─────────────────────────────────┘
```

---

## 🔍 Scanning Timeline

```
┌─────────────────────────────────────────┐
│         SCANNING TIMELINE               │
├─────────────────────────────────────────┤
│                                         │
│ HOUR 0:00                              │
│ ✓ Admin generates label                │
│   └─ QR codes created                  │
│                                         │
│ HOUR 24:00                             │
│ ✓ Logistics receives package           │
│   └─ Scans: BS-DEL-550E8400E29B        │
│      └─ Validated as DELIVERY          │
│                                         │
│ HOUR 48:00                             │
│ ✓ User picks up set                    │
│   └─ PUDO staff scans: BS-PCK-...      │
│      └─ Validated as PICKUP            │
│                                         │
│ HOURS 48-168 (7 days)                  │
│ ✓ User enjoys set                      │
│   └─ No scanning needed                │
│                                         │
│ HOUR 168:00                            │
│ ✓ User requests return                 │
│   └─ BS-RET-... generated              │
│                                         │
│ HOUR 192:00                            │
│ ✓ User returns set                     │
│   └─ Scans: BS-RET-550E8400E29B        │
│      └─ Validated as RETURN            │
│                                         │
└─────────────────────────────────────────┘
```

---

## 📞 Implementation Reference

- **Code:** `supabase/functions/send-brickshare-qr-email/index.ts`
- **Component:** `apps/web/src/components/admin/operations/LabelGeneration.tsx`
- **Format Spec:** `docs/QR_CODE_FORMAT_SPECIFICATION.md`