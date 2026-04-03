# Resend Email Configuration Guide

## 📧 Overview

Resend is used for sending transactional emails in Brickshare (QR codes, delivery notifications, etc.).

---

## 🔧 Development Environment Configuration

### Email Sending Domain

| Environment | Domain | Status | Notes |
|---|---|---|---|
| **Development** | `www.brickclinic.eu` | ✅ Verified | Use this domain for all dev emails |
| **Production** | `brickshare.eu` | ⏳ Pending | To be configured |

### Verified Email Address

| Environment | Email | Status | Notes |
|---|---|---|---|
| **Development (Sandbox)** | `enriqueperezbcn1973@gmail.com` | ✅ Verified | Only valid recipient in sandbox mode |
| **Production** | `noreply@brickshare.eu` | ⏳ Pending | To be configured |

---

## ⚠️ Critical Resend Limitations in Sandbox

### From Address Format
```
from: 'Brickshare <noreply@www.brickclinic.eu>'
```
- Must use a **verified domain** as the sender
- Cannot use unverified domains like `brickshare` (not a TLD)
- Format: `from: 'Display Name <email@verified-domain.com>'`

### To Address
- In **sandbox/development**: Only `enriqueperezbcn1973@gmail.com` is allowed
- In **production**: Can send to any email address once domain is verified

---

## 🔐 Environment Variables

### `.env` / `supabase/.env` / `supabase/functions/.env`
```bash
RESEND_API_KEY=a7937760-ab2b-47a1-9a95-746c7fa7ad63
RESEND_FROM_DOMAIN=www.brickclinic.eu
RESEND_FROM_EMAIL=noreply@www.brickclinic.eu
RESEND_SANDBOX_RECIPIENT=enriqueperezbcn1973@gmail.com
```

---

## 📝 Usage in Edge Functions

### Example: send-brickshare-qr-email

```typescript
const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY');
const FROM_DOMAIN = Deno.env.get('RESEND_FROM_DOMAIN') || 'www.brickclinic.eu';
const FROM_EMAIL = Deno.env.get('RESEND_FROM_EMAIL') || `noreply@${FROM_DOMAIN}`;
const SANDBOX_RECIPIENT = Deno.env.get('RESEND_SANDBOX_RECIPIENT') || 'enriqueperezbcn1973@gmail.com';

// In development, override recipient
const isDevelopment = !Deno.env.get('PROD');
const toEmail = isDevelopment ? SANDBOX_RECIPIENT : userEmail;

const emailResponse = await fetch('https://api.resend.com/emails', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${RESEND_API_KEY}`,
  },
  body: JSON.stringify({
    from: `Brickshare <${FROM_EMAIL}>`,
    to: [toEmail],
    subject: subject,
    html: htmlContent,
  }),
});
```

---

## ✅ Testing Email Sending

### Test Script
```bash
npx ts-node scripts/test-resend-direct.ts
```

### Verify in Resend Dashboard
1. Go to https://resend.com/emails
2. Look for emails with subject containing "Tu código QR"
3. Status should be ✅ "Delivered" or "Sent"
4. If ❌ "Failed", check the error message (usually domain/recipient issues)

---

## 🚨 Common Errors & Solutions

| Error | Cause | Solution |
|---|---|---|
| `from_address_not_verified` | Using unverified domain | Use `www.brickclinic.eu` in dev |
| `invalid_from_address` | Malformed from field | Use format: `Name <email@domain.com>` |
| `recipient_rejected` | Recipient not in sandbox | In dev, only use `enriqueperezbcn1973@gmail.com` |
| `api_key_invalid` | Wrong/missing API key | Check `RESEND_API_KEY` in env vars |
| `rate_limit_exceeded` | Too many requests | Resend free tier: 100/day limit |

---

## 🔄 Production Migration

When deploying to production:

1. **Update from domain**: Change to `brickshare.eu` (once verified)
2. **Remove sandbox restrictions**: Allow sending to user emails
3. **Update env vars**:
   ```bash
   RESEND_FROM_DOMAIN=brickshare.eu
   RESEND_FROM_EMAIL=noreply@brickshare.eu
   # Remove or disable RESEND_SANDBOX_RECIPIENT override
   ```
4. **Test with Resend production API key**

---

## 📚 References

- **Resend Docs**: https://resend.com/docs
- **Domain Verification**: https://resend.com/docs/dashboard/domains
- **Email Template Examples**: https://resend.com/examples

---

**Last Updated**: 2026-01-04  
**Status**: ✅ Development Ready  
**Author**: Cline Integration