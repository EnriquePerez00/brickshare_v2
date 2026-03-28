# 🔐 Brickshare Security & Quality Agent Guidelines

> **Propósito**: Guía comprensiva de seguridad, calidad de código y cyberseguridad para Brickshare.
> Documento generado por análisis de experto en seguridad del stack completo (Frontend + Backend + DB + Third-parties).

---

## 📋 Tabla de Contenidos

1. [Resumen Ejecutivo](#resumen-ejecutivo)
2. [Arquitectura de Seguridad](#arquitectura-de-seguridad)
3. [OWASP Top 10 - Aplicado a Brickshare](#owasp-top-10---aplicado-a-brickshare)
4. [Vulnerabilidades Encontradas](#vulnerabilidades-encontradas)
5. [Checklist de Seguridad por Componente](#checklist-de-seguridad-por-componente)
6. [Reglas Estrictas de Calidad de Código](#reglas-estrictas-de-calidad-de-código)
7. [Testing de Seguridad](#testing-de-seguridad)
8. [Compliance & Regulaciones](#compliance--regulaciones)
9. [Operaciones & Monitoreo](#operaciones--monitoreo)
10. [Incident Response Plan](#incident-response-plan)

---

## Resumen Ejecutivo

**Estado Actual**: Brickshare tiene una base de seguridad sólida gracias a Supabase (RLS, Auth nativa) y patrones RBAC bien definidos. Sin embargo, **EXISTEN BRECHAS CRÍTICAS** que deben cerrarse antes de producción.

### 🚨 Problemas Críticos Identificados

| Severidad | Problema | Impacto | Estado |
|-----------|----------|--------|--------|
| 🔴 CRÍTICA | Falta de rate limiting en Edge Functions | DDoS, abuso API | ❌ NO IMPLEMENTADO |
| 🔴 CRÍTICA | Secrets y credenciales en logs | Exposure de API keys | ⚠️ RIESGO ALTO |
| 🟡 ALTA | CORS demasiado permisivo (`Access-Control-Allow-Origin: *`) | XSS cross-domain | ⚠️ PARCIAL |
| 🟡 ALTA | Sin validación de tamaño en uploads | Resource exhaustion | ❌ NO IMPLEMENTADO |
| 🟡 ALTA | Falta de SQL injection prevention en RPC calls | SQL injection | ✅ MITIGADO (Supabase) |
| 🟠 MEDIA | Sin HTTPS enforcement en algunos endpoints | MITM attacks | ⚠️ PARCIAL |
| 🟠 MEDIA | Validación incompleta de Stripe webhooks | Payment spoofing | ⚠️ IMPLEMENTADO |
| 🟠 MEDIA | Sin monitoreo de anomalías | Fraude sin detectar | ❌ NO IMPLEMENTADO |

---

## Arquitectura de Seguridad

### 🛡️ Capas de Defensa

```
┌─────────────────────────────────────────────────────┐
│ 1. WAF / DDoS Protection (Cloudflare / AWS Shield)  │ ← FALTA
├─────────────────────────────────────────────────────┤
│ 2. HTTPS + HSTS Headers (Vercel + Edge)             │ ✅ PRESENTE
├─────────────────────────────────────────────────────┤
│ 3. CORS + CSP Headers (Origin validation)           │ ⚠️ INCOMPLETO
├─────────────────────────────────────────────────────┤
│ 4. Rate Limiting + Throttling (Edge Functions)      │ ❌ FALTA
├─────────────────────────────────────────────────────┤
│ 5. JWT + Session Management (Supabase Auth)         │ ✅ PRESENTE
├─────────────────────────────────────────────────────┤
│ 6. RLS + RBAC (Database Layer)                      │ ✅ PRESENTE
├─────────────────────────────────────────────────────┤
│ 7. Data Encryption (TLS + DB encryption)            │ ✅ PRESENTE
├─────────────────────────────────────────────────────┤
│ 8. Audit Logging + Monitoring (CloudWatch / Sentry) │ ⚠️ PARCIAL
└─────────────────────────────────────────────────────┘
```

### 🔐 Modelo de Confianza

```
Usuario → HTTPS (TLS 1.3+)
        → Supabase Auth (JWT, 1h expiry)
        → RLS Policies (auth.uid() verification)
        → Service Role (solo Edge Functions)
        → External APIs (Stripe, Correos, Resend)
```

---

## OWASP Top 10 - Aplicado a Brickshare

### 1. 🔴 Broken Access Control

**Riesgo**: Usuarios acceden a datos ajenos.

**Mitigaciones Actuales**:
- ✅ RLS en todas las tablas
- ✅ RBAC con `user_roles` y `has_role()` function
- ✅ JWT verification en Edge Functions

**Verificaciones Obligatorias**:
```sql
-- SIEMPRE verificar RLS en nuevas tablas
ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users_own_data" ON table_name
  FOR SELECT USING (auth.uid() = user_id);

-- SIEMPRE verificar permisos en funciones
IF NOT public.has_role(auth.uid(), 'admin') THEN
  RAISE EXCEPTION 'Access denied';
END IF;
```

**Tests Requeridos**:
- [ ] User A intenta acceder a datos de User B → 401 Unauthorized
- [ ] Admin accede a todos datos → ✅ 200 OK
- [ ] Operador accede a shipments pero no a billing → ✅ 200 / 401

---

### 2. 🔴 Cryptographic Failures

**Riesgo**: Passwords, tokens, o datos sensibles comprometidos.

**Mitigaciones Actuales**:
- ✅ Passwords hasheados por Supabase (Bcrypt)
- ✅ HTTPS en todos los endpoints
- ✅ Secrets en `.env` (no en `.git`)

**Vulnerabilidades Encontradas**:
- ⚠️ Secrets en logs (`console.log()` muestra API keys)
- ⚠️ Sin encryption de datos sensibles en DB (SSN, tarjetas)

**Acciones Inmediatas**:
```typescript
// ❌ PROHIBIDO
console.log("API Key:", process.env.STRIPE_SECRET_KEY);
console.error("User data:", userData); // Puede contener tarjetas

// ✅ CORRECTO
console.log("[PaymentProcessor] Payment intent created"); // Sin datos
if (process.env.NODE_ENV === 'production') {
  // NO loguear secrets
  console.log("[REDACTED] Secret operation");
}
```

**Encryption Requerida**:
- [ ] Stripe Payment Method IDs → cifrados en DB
- [ ] SSN / Documento de identidad → hash o no guardar
- [ ] Direcciones de envío → acceso restringido a admins/operators

---

### 3. 🟡 Injection

**Riesgo**: SQL injection, NoSQL injection, command injection.

**Estado**: ✅ BIEN PROTEGIDO (Supabase + Parameterized Queries)

**Verificación de Código Actual**:
```typescript
// ✅ CORRECTO - Supabase maneja escaping
const { data } = await supabase
  .from('users')
  .select('*')
  .eq('email', userInput); // Parametrizado

// ❌ RIESGO - String interpolation
const query = `SELECT * FROM users WHERE email = '${userInput}'`;
// NO PERMITIR ESTO NUNCA
```

**Tests Requeridos**:
- [ ] SQL injection attempts en búsquedas → error, no dump
- [ ] XSS payloads en nombres/emails → escaped
- [ ] Command injection en APIs externas → validación strict

---

### 4. 🔴 Insecure Design

**Riesgo**: Lógica de negocio flaws, ataque de lógica.

**Vulnerabilidades Encontradas**:
- ⚠️ Sin rate limiting → fuerza bruta en login/passwords
- ⚠️ Sin verificación de duplicados en donaciones → spam
- ⚠️ Sin límite de intentos en QR validation

**Implementar Rate Limiting**:
```typescript
// En cada Edge Function crítica
const rateLimitKey = `${req.headers.get('x-forwarded-for')}:${functionName}`;
const attempts = await redis.incr(rateLimitKey);
if (attempts > LIMIT) {
  return new Response('Too many requests', { status: 429 });
}
await redis.expire(rateLimitKey, 60); // Reset cada minuto
```

---

### 5. 🟡 Broken Authentication

**Riesgo**: Sessions hijacking, credential stuffing.

**Mitigaciones Actuales**:
- ✅ Supabase Auth (OAuth, email magic links)
- ✅ JWT con expiry (1 hora)
- ✅ Session validation cada 5 minutos (AuthContext)

**Verificaciones Obligatorias**:
```typescript
// En AuthContext - CORRECTO
const { data: userExists } = await supabase
  .from('users')
  .select('user_id')
  .eq('user_id', session.user.id)
  .maybeSingle();

if (!userExists) {
  // Sesión corrupta, forzar logout
  await supabase.auth.signOut();
}
```

**Mejoras Requeridas**:
- [ ] Implementar 2FA (TOTP o SMS)
- [ ] Detectar login anomalous (geolocation, device fingerprint)
- [ ] Logout remoto de sesiones antiguas

---

### 6. 🟠 Sensitive Data Exposure

**Riesgo**: PII, datos de tarjeta, información personal visible.

**Vulnerabilidades Encontradas**:
- 🔴 CRÍTICA: Direcciones de envío sin encripción
- 🔴 CRÍTICA: Email en responses sin restricción
- 🟡 MEDIA: Datos de shipment exponibles via QR API

**Acción Inmediata**:
```typescript
// ❌ PROHIBIDO - Expone email
const users = await supabase
  .from('users')
  .select('*, email'); // Email es sensible

// ✅ CORRECTO - Solo admins ven email
const users = await supabase
  .from('users')
  .select('id, full_name, subscription_type')
  .eq('role', 'user');
```

**Data Masking en Responses**:
- [ ] Direcciones: solo última 5 dígitos CP
- [ ] Teléfono: solo últimos 4 dígitos
- [ ] Email: solo visible para own user + admins
- [ ] SSN/Documento: NUNCA en responses

---

### 7. 🟠 Identification & Authentication Failures

**Riesgo**: Phishing, account takeover.

**Estado**: ⚠️ MEDIO (Supabase + validaciones)

**Tests Requeridos**:
- [ ] Cambio de email requiere verificación old + new
- [ ] Cambio de contraseña requiere old password
- [ ] Intentos fallidos de login bloquean temporalmente

---

### 8. 🟡 Software & Data Integrity Failures

**Riesgo**: Dependencias comprometidas, código malicioso.

**Acciones Obligatorias**:
```bash
# Revisar dependencias regularmente
npm audit --audit-level=moderate
npm outdated
npm update --depth 3

# NUNCA usar `npm install -g` packages
# SIEMPRE usar lockfile (package-lock.json)
```

**Críticas para Vigilar**:
- `@supabase/supabase-js` → usado en frontend, anón key
- `stripe` (Deno) → maneja secrets
- `zod` → validación (bajo riesgo)
- `react-hook-form` → form handling

---

### 9. 🟠 Logging & Monitoring Failures

**Riesgo**: Ataques no detectados, no hay forensics.

**Estado**: ❌ NO IMPLEMENTADO

**Implementar Logging**:
```typescript
// Eventos críticos a loguear
- Login attempt (exitoso/fallido) + IP + timestamp
- Cambio de suscripción (plan, monto)
- Acceso a datos sensibles (admins solo)
- Fallos de pago (monto, reason)
- Admin actions (CRUD, deletions)
- QR validations (éxito/fallo, timestamp)
```

**Stack Recomendado**:
- Supabase: `audit_logs` table con RLS
- Sentry: Error tracking + performance
- CloudWatch (AWS) o Vercel Analytics: request logs

---

### 10. 🟠 Using Components with Known Vulnerabilities

**Riesgo**: Dependencias con CVEs publicados.

**Acción Diaria**:
```bash
# En CI/CD
npm audit --production
# Fallar si vulnerabilidades HIGH o CRITICAL

# Monitorear Dependabot alerts en GitHub
# Actualizar al menos monthly
```

---

## Vulnerabilidades Encontradas

### 🔴 Críticas

#### V1: CORS Demasiado Permisivo
**Archivo**: `supabase/functions/*/index.ts` (todos)
**Código**:
```typescript
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',  // ❌ TOO PERMISSIVE
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};
```
**Impacto**: XSS cross-domain, CSRF attacks
**Remediación**:
```typescript
const ALLOWED_ORIGINS = [
  'https://brickshare.es',
  'https://app.brickshare.es',
  'http://localhost:5173', // Dev only
];

const origin = req.headers.get('origin') || '';
const corsHeaders = {
  'Access-Control-Allow-Origin': ALLOWED_ORIGINS.includes(origin) ? origin : '',
  'Access-Control-Allow-Credentials': 'true',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Max-Age': '86400', // 24h
};
```

#### V2: Sin Rate Limiting
**Impacto**: DDoS, brute force, API abuse
**Remediación**: Implementar Redis-backed rate limiting (ver sección Operaciones)

#### V3: Secrets en Logs
**Archivo**: `supabase/functions/*/index.ts`
**Código**:
```typescript
console.log(`STRIPE_SECRET_KEY exists: !!${stripeKey}`); // ❌ Prints "true/false" ok
// Pero podría loguear el valor real si no se cuida
```
**Remediación**:
```typescript
// ✅ CORRECTO
const hasStripeKey = !!Deno.env.get("STRIPE_SECRET_KEY");
console.log(`[create-subscription-intent] Stripe configured: ${hasStripeKey}`);
// NUNCA: console.log(`Key: ${key}`);
```

#### V4: Sin Validación de Tamaño en Uploads
**Impacto**: Resource exhaustion, storage costs
**Remediación**: Implementar max file size checks:
```typescript
const MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
if (file.size > MAX_FILE_SIZE) {
  throw new Error('File too large');
}
```

### 🟡 Altas

#### V5: CORS Credentials Inseguros
**Archivo**: `supabase/functions/create-checkout-session/index.ts`
```typescript
"Access-Control-Allow-Credentials": "true", // ⚠️ Con origin *
```
**Remediación**: Solo con ALLOWED_ORIGINS específicos

#### V6: Sin Helmet Headers
**Impacto**: Clickjacking, MIME sniffing, XSS
**Remediación**: En `supabase/config.toml` o middleware Vercel:
```typescript
// Add security headers
headers: [
  { key: 'X-Content-Type-Options', value: 'nosniff' },
  { key: 'X-Frame-Options', value: 'DENY' },
  { key: 'X-XSS-Protection', value: '1; mode=block' },
  { key: 'Strict-Transport-Security', value: 'max-age=31536000; includeSubDomains' },
  { key: 'Content-Security-Policy', value: "default-src 'self'; script-src 'self' 'unsafe-inline' stripe.com" },
]
```

#### V7: Sin Input Validation en Edge Functions
**Archivo**: `supabase/functions/submit-donation/index.ts`
**Riesgo**: Inyección de datos maliciosos
**Remediación**:
```typescript
import { z } from 'https://deno.land/x/zod@v3.20.0/mod.ts';

const DonationSchema = z.object({
  name: z.string().min(1).max(100),
  email: z.string().email(),
  weight: z.number().min(1).max(100),
  delivery_method: z.enum(['pickup', 'shipping']),
});

const validated = DonationSchema.parse(req.json());
```

#### V8: Stripe Webhook Secret Validation Incompleta
**Archivo**: `supabase/functions/stripe-webhook/index.ts`
**Código**:
```typescript
if (!endpointSecret) {
  console.error("STRIPE_WEBHOOK_SECRET is not configured");
  return new Response("Webhook secret not configured", { status: 500 });
}
// ✅ CORRECTO - Valida presencia
```
**Mejora**: Añadir timeout para signature verification:
```typescript
const constructEventOptions = {
  tolerance: 300, // 5 minutos, por defecto 5 mins
};
const event = await stripe.webhooks.constructEventAsync(
  body,
  signature,
  endpointSecret,
  undefined,
  cryptoProvider,
  constructEventOptions
);
```

#### V9: Sin Validación de QR Code Expiry
**Archivo**: `supabase/functions/brickshare-qr-api/index.ts`
**Riesgo**: QR codes válidos indefinidamente
**Remediación**: Verificar `delivery_qr_expires_at < now()`:
```typescript
if (validationResult.delivery_qr_expires_at) {
  const expiryDate = new Date(validationResult.delivery_qr_expires_at);
  if (expiryDate < new Date()) {
    return { success: false, error: 'QR code expired' };
  }
}
```

### 🟠 Medias

#### V10: Sin Validación de Session Tokens
**Impacto**: Menor, pero posible race condition
**Remediación**: Ya implementado en AuthContext ✅

#### V11: Sin Audit Logging Completo
**Impacto**: No detectar cambios no autorizados
**Remediación**: Implementar tabla `audit_logs`:
```sql
CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  action VARCHAR(100),
  resource_type VARCHAR(50),
  resource_id UUID,
  old_values JSONB,
  new_values JSONB,
  ip_address INET,
  created_at TIMESTAMP DEFAULT now()
);
```

---

## Checklist de Seguridad por Componente

### ✅ Frontend (React + TypeScript)

- [ ] **Input Validation**
  - [ ] Zod schemas en todos los formularios
  - [ ] Max length enforcement en inputs
  - [ ] Email/URL validation con Zod patterns
  - [ ] Nunca `eval()` o `dangerouslySetInnerHTML` (encontrado solo 1, en chart.tsx)

- [ ] **Authentication**
  - [ ] JWT stored en localStorage (SEGURO en Supabase)
  - [ ] Refresh token rotation cada sesión
  - [ ] Session validation cada 5 mins ✅
  - [ ] Logout en tab close ✅
  - [ ] 2FA before sensitive operations (TODO)

- [ ] **API Communication**
  - [ ] HTTPS only ✅
  - [ ] Bearer token en Authorization header ✅
  - [ ] Error messages no revelan internals
  - [ ] Sensitive data no en URL params

- [ ] **Error Handling**
  - [ ] No mostrar stack traces al usuario
  - [ ] Loguear errors con Sentry
  - [ ] Sanitizar error messages

- [ ] **Dependencies**
  - [ ] npm audit monthly
  - [ ] No usar `npm install -g` inseguro
  - [ ] Revisar transitive dependencies

### ✅ Backend (Supabase + Edge Functions)

- [ ] **Database**
  - [ ] RLS enabled en todas las tablas ✅
  - [ ] Row policies testadas para cada rol
  - [ ] No `SECURITY INVOKER` functions (use `SECURITY DEFINER`)
  - [ ] Migraciones siempre versionadas ✅

- [ ] **Auth**
  - [ ] JWT verification obligatoria ✅
  - [ ] Service Role Key NUNCA expuesto
  - [ ] Anon key usado solo para public data
  - [ ] Custom claims validation (TODO)

- [ ] **Edge Functions**
  - [ ] Rate limiting implementado (TODO)
  - [ ] Input validation con Zod (PARCIAL)
  - [ ] Secrets never logged (VIGILAR)
  - [ ] CORS restrictivo (MEJORAR)
  - [ ] Timeouts configurados (TODO)
  - [ ] Error handling sin exposición de internals

- [ ] **Webhooks (Stripe, Swikly)**
  - [ ] Signature verification ✅
  - [ ] Idempotency keys (TODO)
  - [ ] Retry logic with exponential backoff (TODO)
  - [ ] Dead letter queue para fallos (TODO)

### ✅ Third-party Integrations

| Servicio | Verificación | Status |
|----------|---|---|
| **Stripe** | API key secret, webhook secret, payment verification | ✅ |
| **Correos** | Client ID/secret, contract ID, base URL | ⚠️ VIGILAR |
| **Resend** | API key, email templates sanitized | ✅ |
| **Swikly** | Account ID, secret, HMAC signature | ✅ |
| **Google Maps** | API key restricted to domain | ✅ |
| **Rebrickable** | API key, rate limiting | ✅ |

### ✅ Deployment (Vercel)

- [ ] HTTPS enforced ✅
- [ ] Environment variables encrypted ✅
- [ ] Build previews isolated
- [ ] No secrets in build logs ✅
- [ ] Branch protection on main
- [ ] CI/CD security scanning (TODO)

---

## Reglas Estrictas de Calidad de Código

### 1. TypeScript Strict Mode

**Obligatorio**:
```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "noImplicitThis": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictBindCallApply": true,
    "strictPropertyInitialization": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true
  }
}
```

### 2. Linting Rules

**ESLint obligatorio** con:
```javascript
{
  rules: {
    'no-console': ['warn', { allow: ['warn', 'error'] }], // ⚠️ Sin log() en prod
    'no-eval': 'error',
    'no-implied-eval': 'error',
    'no-with': 'error',
    'no-var': 'error', // Solo const/let
    'prefer-const': 'error',
  }
}
```

### 3. Naming Conventions

```typescript
// ✅ CORRECTO
const MAX_RETRY_ATTEMPTS = 3;
const userId = user.id;
function validateEmailFormat(email: string): boolean {}
async function fetchUserProfile(userId: string): Promise<UserProfile> {}

// ❌ INCORRECTO
const max = 3; // Qué es max?
let uid = user.id; // uid vs userId inconsistencia
function validate(e: string) {} // Qué se valida?
const fetchProfile = (u: string) => {}; // Parámetro poco claro
```

### 4. Error Handling

```typescript
// ❌ PROHIBIDO
try {
  await somethingAsync();
} catch (e) {
  console.log(e); // No capturado
}

// ✅ CORRECTO
try {
  await somethingAsync();
} catch (error) {
  if (error instanceof SupabaseError) {
    // Handle specifically
    throw new AppError('Database error', 500, error);
  }
  throw error;
}
```

### 5. Async/Await & Promise Handling

```typescript
// ❌ PROHIBIDO - Fire and forget
someAsyncFunction(); // Error no capturado

// ✅ CORRECTO
try {
  await someAsyncFunction();
} catch (error) {
  // Handle
}

// ✅ CORRECTO - Si realmente fire and forget
someAsyncFunction().catch(error => {
  logger.error('Async task failed', error);
});
```

### 6. Comments & Documentation

```typescript
// ✅ BUENO - Explica WHY no WHAT
// We retry on network errors because Correos API is unreliable
async function fetchWithRetry(url: string, maxRetries = 3) {}

// ❌ MALO - Redunda con el código
// Increment counter
counter++;

// TODO: Implementar 2FA - Issue #123
```

### 7. Secure Defaults

```typescript
// ❌ Inseguro por defecto
export function createUser(data: any) {} // Any type!

// ✅ Seguro por defecto
export function createUser(data: Partial<User>): Promise<User> {
  const validated = UserSchema.parse(data);
  return saveUser(validated);
}
```

### 8. Dependency Injection

```typescript
// ❌ PROHIBIDO - Tightly coupled
async function sendEmail(to: string, message: string) {
  const resend = new Resend(Deno.env.get("RESEND_API_KEY"));
  return resend.emails.send(...);
}

// ✅ CORRECTO - Testeable
async function sendEmail(
  to: string,
  message: string,
  emailService: EmailService = new ResendService()
) {
  return emailService.send(to, message);
}
```

### 9. Testing Requirements

**Por cada componente crítico**:
- [ ] Unit tests (mínimo 80% coverage)
- [ ] Integration tests para Edge Functions
- [ ] E2E tests para flujos de negocio
- [ ] Security tests (XSS, injection, auth)

```typescript
// Ejemplo: AuthContext.test.tsx
describe('AuthContext', () => {
  it('should validate corrupted sessions', async () => {
    // Session exists in auth.users but NOT in public.users
    const { rerender } = render(<AuthProvider>{children}</AuthProvider>);
    await waitFor(() => {
      expect(supabase.auth.signOut).toHaveBeenCalled();
    });
  });

  it('should enforce RLS policies', async () => {
    // User A cannot read User B's data
    const userAData = await supabase
      .from('users')
      .select('*')
      .eq('id', userBId);
    expect(userAData).toHaveLength(0);
  });
});
```

### 10. Code Review Checklist

**Antes de merge**:
- [ ] ✅ TypeScript compilation sin errors
- [ ] ✅ ESLint sin warnings críticos
- [ ] ✅ Tests pasan (unit + integration)
- [ ] ✅ No secrets committeados
- [ ] ✅ Datos sensibles no en logs
- [ ] ✅ RLS policies si toca BD
- [ ] ✅ Rate limiting si API expuesta
- [ ] ✅ Error handling completo
- [ ] ✅ CORS policy revisada

---

## Testing de Seguridad

### 🧪 Unit Tests

```bash
npm run test
```

**Cobertura mínima**: 80%

### 🔍 Integration Tests

```bash
npm run test:e2e
```

**Flujos a testear**:
1. Auth: login/signup/logout/2FA
2. Payments: create intent, webhook, cancel subscription
3. RBAC: admin access, operador restrictions, user own data
4. Logistics: QR generation, validation, expiry

### 🔐 Security-Specific Tests

```typescript
// test/security.integration.test.ts

describe('Security: Access Control', () => {
  it('should deny user access to other users data', async () => {
    const userAAuth = await signInAs('user-a@test.com');
    const userBId = 'user-b-uuid';
    
    const result = await supabase
      .from('users')
      .select('*')
      .eq('id', userBId)
      .maybeSingle();
    
    expect(result.data).toBeNull(); // RLS policy enforced
  });

  it('should prevent XSS via comment field', async () => {
    const malicious = '<img src=x onerror="alert(1)">';
    const result = await submitForm({ comment: malicious });
    
    const stored = await supabase
      .from('comments')
      .select('text')
      .eq('id', result.id)
      .single();
    
    expect(stored.text).not.toContain('onerror');
    expect(stored.text).toContain('&lt;img'); // HTML escaped
  });

  it('should prevent SQL injection in search', async () => {
    const injection = "'; DROP TABLE users; --";
    const result = await supabase
      .from('products')
      .select('*')
      .ilike('name', `%${injection}%`);
    
    expect(result.error).toBeNull(); // Parametrized query safe
    expect(result.data).toBeDefined(); // Table still exists
  });
});

describe('Security: Rate Limiting', () => {
  it('should block excessive login attempts', async () => {
    for (let i = 0; i < 10; i++) {
      await signIn('user@test.com', 'wrong-password');
    }
    
    const result = await signIn('user@test.com', 'correct-password');
    expect(result.error).toMatch(/too many attempts/i);
  });
});
```

### 🛡️ OWASP ZAP Scanning

```bash
# Automated security scanning
docker run -t owasp/zap2docker-stable zap-baseline.py \
  -t https://brickshare.es \
  -r report.html
```

---

## Compliance & Regulaciones

### 🇪🇸 GDPR (RGPD en España)

| Requerimiento | Status | Acción |
|---|---|---|
| User consent para datos | ✅ | Privacy policy + checkbox |
| Right to access | ⚠️ | Implementar endpoint export |
| Right to deletion | ✅ | `delete-user` edge function |
| Right to portability | ❌ | TODO: Export as JSON |
| Privacy by design | ⚠️ | Auditar data minimization |
| Data Protection Impact Assessment | ❌ | TODO: DPIA document |

**Acciones Inmediatas**:
```sql
-- GDPR audit table
CREATE TABLE gdpr_audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  action VARCHAR(50), -- 'accessed', 'exported', 'deleted'
  data_categories TEXT[], -- ['personal', 'payment', 'shipment']
  timestamp TIMESTAMP DEFAULT now(),
  -- Show compliance with GDPR principles
  lawful_basis VARCHAR(50), -- 'consent', 'contract', 'legal_obligation'
  retention_period INTERVAL,
  
  UNIQUE(user_id, action, timestamp)
);
```

### 💳 PCI-DSS (Payment Card Industry)

**Nivel 1** (30M+ transactions/year):
- [ ] Annual penetration testing
- [ ] WAF implementation
- [ ] Encrypted transmission
- [ ] Regular vulnerability scanning

**Stripe Compliance**:
- ✅ Nunca manejar PAN (números de tarjeta)
- ✅ Stripe.js maneja todo
- ✅ Usar Payment Intents API (no Charges)

---

## Operaciones & Monitoreo

### 📊 Logging

**Stack Recomendado**:
```
Supabase Audit Logs → CloudWatch / ELK → Alerting
Sentry → Error tracking + stack traces
Vercel Analytics → Performance
```

**Eventos a Loguear**:
```
[CRITICAL]
- Failed payment attempts (> 2 times / user)
- Unauthorized access attempts
- RLS policy violations
- Admin/Operador actions

[HIGH]
- Login/logout events
- Subscription changes
- QR validations
- Data exports (GDPR)

[MEDIUM]
- API rate limit hits
- Webhook retries
- Email sends
- Missing environment variables
```

### 🚨 Alerting Rules

```yaml
# Alertmanager rules
groups:
  - name: security
    rules:
      - alert: FailedLoginAttempts
        expr: increase(failed_login_attempts[5m]) > 10
        annotations:
          severity: HIGH
          description: "Possible brute force attack"

      - alert: RLSPolicyViolation
        expr: increase(rls_violations[1h]) > 0
        annotations:
          severity: CRITICAL
          description: "Unauthorized DB access detected"

      - alert: HighErrorRate
        expr: (rate(errors_total[5m]) / rate(requests_total[5m])) > 0.05
        annotations:
          severity: HIGH
          description: "Error rate above 5%"
```

### 🔄 Deployment Checklist

Antes de producción:
- [ ] Security headers configurados (Helmet)
- [ ] Rate limiting activo
- [ ] Audit logging habilitado
- [ ] HTTPS enforcement
- [ ] Environment variables secrets (no hardcoded)
- [ ] WAF rules activas
- [ ] Backup strategy documented
- [ ] Incident response runbook ready
- [ ] Sentry/monitoring alerting funcionando
- [ ] Database encryption habilitado
- [ ] Backups daily tested

---

## Incident Response Plan

### 🚨 Clasificación de Severidad

| Nivel | Tiempo Respuesta | Escalación |
|---|---|---|
| 🔴 CRÍTICA | < 15 min | CTO + DevOps + Legal |
| 🟡 ALTA | < 1 hora | Tech Lead + DevOps |
| 🟠 MEDIA | < 4 horas | Tech Lead |
| 🟢 BAJA | < 24 horas | Team |

### 📋 Playbooks

#### Incident: Payment System Down
1. **Detect**: Alerting triggers (error_rate > 50% on Stripe endpoints)
2. **Isolate**: Kill affected Edge Function (pause new transactions)
3. **Notify**: Send alert to on-call engineer
4. **Assess**: Check Stripe status page + logs
5. **Mitigate**: Rollback code if recent deployment
6. **Communicate**: Notify users (status page)
7. **Resolution**: Contact Stripe support if needed
8. **Post-mortem**: Document root cause + prevention

#### Incident: Unauthorized Access Detected
1. **Detect**: Multiple RLS policy violations logged
2. **Isolate**: Revoke suspected user's JWT immediately
3. **Contain**: Disable user account if confirmed breach
4. **Notify**: Legal + affected users
5. **Investigate**: Review audit logs + IP geolocation
6. **Report**: GDPR breach notification if PII exposed
7. **Remediate**: Password reset + 2FA requirement

#### Incident: Database Compromise
1. **Backup Verification**: Check latest backup integrity
2. **Snapshot**: Create DB snapshot for forensics
3. **Isolate**: Restrict database access to admins only
4. **Restore**: From backup if necessary
5. **Audit**: Review all recent DDL changes
6. **Communication**: Notify affected users of data compromise

### 📞 Contact List

```
On-Call Engineer: PAGERDUTY_ALERT
CTO: email@company.com
DevOps Lead: devops@company.com
Legal: legal@company.com
Customers Support: support@brickshare.es
```

---

## Recomendaciones Finales

### 🎯 Prioridades para Sprint Actual

**Semana 1** (Críticas):
- [ ] Implementar rate limiting en todas Edge Functions
- [ ] Revisar y sanitizar todos logs (no secrets)
- [ ] Actualizar CORS policies con whitelist

**Semana 2** (Altas):
- [ ] Añadir Helmet security headers
- [ ] Implementar input validation con Zod (Edge Functions)
- [ ] Configurar Sentry para error tracking

**Semana 3** (Medias):
- [ ] Audit logging table + alertas
- [ ] 2FA setup (TOTP)
- [ ] Database encryption at rest

### 📚 Documentos de Referencia

- [OWASP Top 10 2021](https://owasp.org/Top10/)
- [Supabase Security](https://supabase.com/docs/guides/auth)
- [Stripe API Security](https://stripe.com/docs/security)
- [PCI-DSS Requirements](https://www.pcisecuritystandards.org/)
- [GDPR Compliance Checklist](https://gdpr-info.eu/)

### 👥 Responsabilidades

| Rol | Responsabilidad |
|---|---|
| **CTO** | Revisar design decisions, GDPR compliance |
| **Tech Lead** | Code review, security testing, incident response |
| **DevOps** | Infrastructure security, backups, monitoring |
| **QA** | Security test cases, OWASP scanning |
| **Frontend** | Input validation, error handling, no secrets |
| **Backend** | Auth, RLS, rate limiting, logging |

---

## Checklist de Uso para Claude (Sesiones Futuras)

**Ante CUALQUIER cambio de código o DB**:
- [ ] ¿Hay RLS policy nueva? → Verificar ENABLE ROW LEVEL SECURITY
- [ ] ¿Hay Edge Function nueva? → Rate limiting + CORS restrictivo + input validation
- [ ] ¿Toca autenticación? → JWT verification obligatoria
- [ ] ¿Datos sensibles? → Nunca en logs, nunca sin encryption
- [ ] ¿Tercera API? → Webhook secret validation, signature verification
- [ ] ¿Changes en RBAC? → Test todas las combinaciones de roles
- [ ] ¿Código que loguea? → Revisar sin secrets/PII
- [ ] ¿Error handling? → No revelar internals al usuario

---

**Última actualización**: 28/03/2026
**Próxima revisión**: 28/04/2026 (monthly)
**Status**: 🟡 ACTIVO - En implementación