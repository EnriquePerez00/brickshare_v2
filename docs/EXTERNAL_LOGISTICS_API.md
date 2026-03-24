# External Logistics API Documentation

## Overview

This API allows external logistics operators to update shipment status and timestamps by scanning QR codes on shipping labels.

**Base URL**: `https://your-project.supabase.co/functions/v1`

**Authentication**: API Key via `X-API-Key` header

---

## Authentication

All requests must include the API key in the header:

```
X-API-Key: your-logistics-api-key-here
```

**Security**: The API key is configured as an environment variable `LOGISTICS_API_KEY` in Supabase Edge Functions.

---

## Endpoints

### POST /update-shipment

Update shipment status and/or timestamp fields.

#### Request

```http
POST /functions/v1/update-shipment
Content-Type: application/json
X-API-Key: your-api-key-here

{
  "shipment_id": "550e8400-e29b-41d4-a716-446655440000",
  "updates": {
    "shipping_status": "in_transit_pudo",
    "delivered_at": "2025-03-24T14:30:00Z"
  }
}
```

#### Request Body

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `shipment_id` | string (UUID) | Yes | The unique identifier of the shipment (obtained from QR code) |
| `updates` | object | Yes | Object containing fields to update (at least one field required) |

#### Allowed Update Fields

| Field | Type | Description | Valid Values |
|-------|------|-------------|--------------|
| `shipping_status` | string | Current status of the shipment | `assigned`, `in_transit_pudo`, `delivered`, `picked_up`, `in_transit_return`, `returned` |
| `delivered_at` | string (ISO 8601) | Timestamp when shipment was delivered to PUDO | e.g., `2025-03-24T14:30:00Z` |
| `picked_up_at` | string (ISO 8601) | Timestamp when customer picked up the shipment | e.g., `2025-03-24T15:45:00Z` |
| `returned_at` | string (ISO 8601) | Timestamp when shipment was returned | e.g., `2025-03-24T16:00:00Z` |
| `tracking_update` | string | Free-form text for tracking notes | Any string up to 500 chars |

#### Response (Success)

```json
{
  "success": true,
  "shipment_id": "550e8400-e29b-41d4-a716-446655440000",
  "updated_fields": ["shipping_status", "delivered_at"],
  "message": "Shipment updated successfully"
}
```

#### Response (Error)

```json
{
  "success": false,
  "error": "Error description here"
}
```

#### HTTP Status Codes

| Code | Meaning |
|------|---------|
| 200 | Success - Shipment updated |
| 400 | Bad Request - Invalid parameters |
| 401 | Unauthorized - Invalid or missing API key |
| 404 | Not Found - Shipment ID does not exist |
| 405 | Method Not Allowed - Only POST is supported |
| 500 | Internal Server Error |

---

## QR Code Integration

### Reading QR Codes

Each shipping label contains a QR code that encodes **only the shipment UUID**:

```
Example QR content: 550e8400-e29b-41d4-a716-446655440000
```

The QR code is a standard UUID (36 characters with hyphens). Your app should:

1. Scan the QR code
2. Extract the UUID string
3. Use this UUID as the `shipment_id` in API calls

### Human-Readable Reference

Labels also include a short reference for operators (last 8 characters of UUID):

```
REF: #446655440000
```

This is for visual confirmation only and should not be used in API calls.

---

## Common Workflows

### Workflow 1: Delivery to PUDO

When the shipment arrives at the PUDO location:

```bash
curl -X POST https://your-project.supabase.co/functions/v1/update-shipment \
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

### Workflow 2: Customer Pick-up

When customer picks up the package:

```bash
curl -X POST https://your-project.supabase.co/functions/v1/update-shipment \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-api-key-here" \
  -d '{
    "shipment_id": "550e8400-e29b-41d4-a716-446655440000",
    "updates": {
      "shipping_status": "picked_up",
      "picked_up_at": "2025-03-24T15:45:00Z"
    }
  }'
```

### Workflow 3: Return to Warehouse

When customer returns the package:

```bash
curl -X POST https://your-project.supabase.co/functions/v1/update-shipment \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-api-key-here" \
  -d '{
    "shipment_id": "550e8400-e29b-41d4-a716-446655440000",
    "updates": {
      "shipping_status": "returned",
      "returned_at": "2025-03-25T10:00:00Z",
      "tracking_update": "Package returned in good condition"
    }
  }'
```

---

## Error Handling

### Example Error Responses

**Invalid UUID Format**:
```json
{
  "success": false,
  "error": "Invalid shipment_id format. Must be a valid UUID."
}
```

**Shipment Not Found**:
```json
{
  "success": false,
  "error": "Shipment not found with ID: 550e8400-e29b-41d4-a716-446655440000"
}
```

**Invalid Status Value**:
```json
{
  "success": false,
  "error": "Invalid shipping_status value. Must be one of: assigned, in_transit_pudo, delivered, picked_up, in_transit_return, returned"
}
```

**Invalid Timestamp Format**:
```json
{
  "success": false,
  "error": "Invalid delivered_at format. Must be ISO 8601 format (e.g., 2025-03-24T14:30:00Z)"
}
```

**Unauthorized**:
```json
{
  "success": false,
  "error": "Unauthorized. Invalid or missing API key."
}
```

---

## Audit Logging

All updates via this API are automatically logged in the `shipment_update_logs` table with:

- Timestamp of the update
- Fields that were changed
- Old values before update
- New values after update
- Source IP address
- User agent string

This provides complete audit trail for compliance and troubleshooting.

---

## Rate Limiting

Currently, there is **no rate limiting** implemented. However, best practices:

- Avoid excessive requests (batch updates if possible)
- Implement retry logic with exponential backoff for failed requests
- Cache shipment IDs locally to minimize redundant scans

---

## Testing

### Test with curl

```bash
# Set your API key
API_KEY="your-api-key-here"
BASE_URL="http://127.0.0.1:54321/functions/v1"

# Test update
curl -X POST $BASE_URL/update-shipment \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d '{
    "shipment_id": "test-uuid-here",
    "updates": {
      "shipping_status": "delivered",
      "delivered_at": "2025-03-24T14:30:00Z"
    }
  }' \
  | jq
```

### Test with Postman

1. Create new POST request to `/functions/v1/update-shipment`
2. Add header: `X-API-Key: your-api-key-here`
3. Set body type to JSON
4. Use example request body from above
5. Send request

---

## Support

For technical issues or questions:

- Email: tech@brickshare.com
- Check audit logs in Supabase dashboard: `shipment_update_logs` table
- Review Edge Function logs in Supabase dashboard

---

## Changelog

### Version 1.0.0 (2025-03-25)
- Initial release
- POST /update-shipment endpoint
- API key authentication
- Audit logging
- Support for status and timestamp updates

---

**Last Updated**: March 25, 2025