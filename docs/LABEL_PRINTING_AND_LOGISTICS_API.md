# Label Printing and Logistics API - Complete System

## Overview

This document describes the complete system for printing shipping labels with QR codes and the external API that allows logistics operators to update shipment status by scanning these QR codes.

---

## System Components

### 1. Label Printing (Frontend Admin Panel)

**Location**: `apps/web/src/components/admin/operations/LabelPrinting.tsx`

**Features**:
- Lists all shipments with status `assigned`
- Allows printing individual or bulk shipping labels
- Each label includes:
  - User name
  - PUDO address (Brickshare or Correos)
  - Set reference
  - Short reference (last 8 chars of shipment UUID)
  - Tracking code (last 6 digits)
  - **QR Code with shipment UUID**
- Automatically updates shipment status to `in_transit_pudo` after printing

**Label Format**:
- Size: 10cm x 5cm
- QR Code: Contains full shipment UUID
- Print-friendly CSS with page breaks

---

### 2. QR Code Content

**Simple Format**: Just the shipment UUID

```
Example QR content: 550e8400-e29b-41d4-a716-446655440000
```

**Why UUID only?**
- Simple and secure
- Direct database lookup
- No sensitive information exposed
- Easy to implement in any QR scanner app

---

### 3. External Logistics API

**Endpoint**: `POST /functions/v1/update-shipment`

**Authentication**: API Key via `X-API-Key` header

**Purpose**: Allow external logistics operators to update shipment status and timestamps by scanning QR codes.

#### Allowed Updates

| Field | Type | Description |
|-------|------|-------------|
| `shipping_status` | string | Status: `assigned`, `in_transit_pudo`, `delivered`, `picked_up`, `in_transit_return`, `returned` |
| `delivered_at` | ISO 8601 | Timestamp when delivered to PUDO |
| `picked_up_at` | ISO 8601 | Timestamp when customer picked up |
| `returned_at` | ISO 8601 | Timestamp when returned to warehouse |
| `tracking_update` | string | Free-form tracking notes |

#### Example Request

```bash
curl -X POST http://localhost:54321/functions/v1/update-shipment \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-api-key-here" \
  -d '{
    "shipment_id": "550e8400-e29b-41d4-a716-446655440000",
    "updates": {
      "shipping_status": "delivered",
      "delivered_at": "2025-03-24T14:30:00Z"
    }
  }'
```

#### Response

```json
{
  "success": true,
  "shipment_id": "550e8400-e29b-41d4-a716-446655440000",
  "updated_fields": ["shipping_status", "delivered_at"],
  "message": "Shipment updated successfully"
}
```

---

### 4. Audit Logging

**Table**: `shipment_update_logs`

All updates via the API are automatically logged with:
- Timestamp
- Updated fields
- Old and new values
- Source IP address
- User agent

**RLS Policies**:
- Users can view logs for their own shipments
- Admins and operators can view all logs
- Only service role can insert logs

---

## Workflow

### Standard Delivery Flow

```
1. Admin prints label
   ↓
2. Label includes QR with shipment UUID
   ↓
3. Operator scans QR at warehouse
   ↓
4. App calls API: status → "in_transit_pudo"
   ↓
5. Package arrives at PUDO
   ↓
6. Operator scans QR
   ↓
7. App calls API: status → "delivered", delivered_at → timestamp
   ↓
8. Customer picks up package
   ↓
9. Operator scans QR
   ↓
10. App calls API: status → "picked_up", picked_up_at → timestamp
```

### Return Flow

```
1. Customer returns to PUDO
   ↓
2. Operator scans QR
   ↓
3. App calls API: status → "in_transit_return"
   ↓
4. Package arrives at warehouse
   ↓
5. Operator scans QR
   ↓
6. App calls API: status → "returned", returned_at → timestamp
```

---

## Configuration

### Environment Variables

**Local Development** (`.env.local`):
```bash
LOGISTICS_API_KEY=brickshare_logistics_2025_secure_key_change_in_production
```

**Production** (Supabase Dashboard → Edge Functions → Secrets):
```bash
LOGISTICS_API_KEY=<strong-random-key-here>
```

### Edge Function Configuration

**File**: `supabase/config.toml`

```toml
[functions.update-shipment]
verify_jwt = false  # Uses API key instead
```

---

## Security Considerations

### ✅ Implemented Security

1. **API Key Authentication**
   - Required in all requests
   - Stored as environment variable
   - Should be rotated regularly in production

2. **Field Validation**
   - Only allowed fields can be updated
   - Status values validated against enum
   - Timestamp format validation (ISO 8601)
   - UUID format validation

3. **Audit Trail**
   - All updates logged with source IP and timestamp
   - Immutable log records
   - RLS policies restrict access

4. **Database RLS**
   - shipments table protected with Row Level Security
   - Service role required for updates
   - Users can only view their own shipments

### ⚠️ Recommendations for Production

1. **Rate Limiting**
   - Implement rate limiting at API gateway level
   - Suggested: 100 requests per minute per IP

2. **IP Whitelisting**
   - Restrict API access to known operator IPs
   - Configure at Supabase Edge Function level

3. **API Key Rotation**
   - Rotate key every 90 days minimum
   - Use different keys for different environments

4. **Monitoring**
   - Set up alerts for suspicious activity
   - Monitor failed authentication attempts
   - Track unusual update patterns

---

## Testing

### Local Testing

```bash
# Start Supabase
supabase start

# Run test script
./scripts/test-logistics-api.sh
```

### Manual Testing

```bash
# Get a shipment ID
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres \
  -c "SELECT id FROM shipments WHERE shipping_status = 'assigned' LIMIT 1;"

# Test update
curl -X POST http://localhost:54321/functions/v1/update-shipment \
  -H "Content-Type: application/json" \
  -H "X-API-Key: brickshare_logistics_2025_secure_key_change_in_production" \
  -d '{
    "shipment_id": "<shipment-id-here>",
    "updates": {
      "shipping_status": "in_transit_pudo"
    }
  }' | jq
```

---

## Troubleshooting

### Issue: "Unauthorized" error

**Solution**: Check that API key matches environment variable

```bash
# Verify local env var
cat .env.local | grep LOGISTICS_API_KEY

# Verify Supabase has the secret
supabase secrets list
```

### Issue: "Shipment not found"

**Solution**: Verify shipment exists and UUID format is correct

```bash
# Check if shipment exists
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres \
  -c "SELECT id, shipping_status FROM shipments WHERE id = '<uuid>';"
```

### Issue: "Invalid field" error

**Solution**: Check that field names are correct and allowed

Allowed fields: `shipping_status`, `delivered_at`, `picked_up_at`, `returned_at`, `tracking_update`

---

## Related Documentation

- [External Logistics API Reference](./EXTERNAL_LOGISTICS_API.md)
- [QR Reading Process](./BRICKSHARE_QR_READING_PROCESS.md)
- [Logistics Integration](./BRICKSHARE_LOGISTICS_INTEGRATION.md)

---

**Last Updated**: March 24, 2026