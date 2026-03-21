# Brickshare — Arquitectura Técnica

## Diagrama de Alto Nivel

```
┌─────────────────────────────────────────────────────────────┐
│                        CLIENTES                             │
│  ┌──────────────────┐          ┌──────────────────────┐     │
│  │   Web (Vite/     │          │   iOS App            │     │
│  │   React/TS)      │          │   (React Native      │     │
│  │   → Vercel       │          │    Expo)             │     │
│  └────────┬─────────┘          └──────────┬───────────┘     │
└───────────┼──────────────────────────────┼─────────────────┘
            │                              │
            ▼                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    SUPABASE PLATFORM                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │  PostgreSQL  │  │  Supabase    │  │  Edge Functions  │  │
│  │  Database    │  │  Auth        │  │  (Deno runtime)  │  │
│  │              │  │  (JWT/RLS)   │  │                  │  │
│  └──────────────┘  └──────────────┘  └────────┬─────────┘  │
│  ┌──────────────┐  ┌──────────────┐           │            │
│  │  Storage     │  │  Realtime    │           │            │
│  │  (imágenes)  │  │  (futuro)    │           │            │
│  └──────────────┘  └──────────────┘           │            │
└──────────────────────────────────────────────┼─────────────┘
                                               │
                    ┌──────────────────────────┼──────────────┐
                    │       SERVICIOS EXTERNOS │              │
                    │  ┌──────────┐  ┌─────────┴──┐  ┌─────┐ │
                    │  │  Stripe  │  │  Correos   │  │Resend│ │
                    │  │  Payments│  │  API       │  │Email│ │
                    │  └──────────┘  └────────────┘  └─────┘ │
                    └─────────────────────────────────────────┘
```

---

## Frontend Web

### Tecnologías
- **Vite 5** — Bundler y dev server
- **React 18** — UI library con hooks
- **TypeScript** — Tipado estático
- **Tailwind CSS** — Estilos utilitarios
- **shadcn/ui** — Componentes UI accesibles (Radix UI)
- **React Router DOM** — Navegación SPA
- **TanStack Query** (React Query) — Cache y sincronización de datos
- **Stripe.js** — Pagos en el frontend

### Gestión de Estado
```
┌────────────────────────────────────────┐
│  Estado Global                         │
│  AuthContext → usuario, sesión, rol    │
├────────────────────────────────────────┤
│  Estado del Servidor (React Query)     │
│  useProducts → catálogo de sets        │
│  useOrders → pedidos del usuario       │
│  useSubscription → plan activo         │
│  useWishlist → lista de deseos         │
│  useShipments → envíos y tracking      │
│  useDonation → donaciones              │
│  usePudo → puntos de recogida          │
│  useLegoEnrichment → datos externos    │
├────────────────────────────────────────┤
│  Estado Local (useState/useReducer)    │
│  Formularios, modales, UI temporal     │
└────────────────────────────────────────┘
```

### Estructura de Componentes
```
App.tsx (Router + Providers)
├── Navbar
├── Pages
│   ├── Index (Landing)
│   │   ├── HeroSection
│   │   ├── FeaturedProducts
│   │   ├── HygieneSection
│   │   ├── EducationalSection
│   │   ├── SocialImpactSection
│   │   └── CTASection
│   ├── Catalogo
│   │   ├── ProductCard
│   │   └── ProductRow
│   ├── Dashboard
│   │   ├── StripePaymentModal
│   │   ├── PudoSelector
│   │   └── ProfileCompletionModal
│   ├── Admin
│   │   └── [componentes admin/]
│   └── Operations
└── Footer
```

---

## Supabase — Base de Datos

### Row Level Security (RLS)
Todas las tablas tienen RLS habilitado. Los patrones principales son:

| Política | Tabla | Descripción |
|---|---|---|
| `select_own` | orders, profiles, wishlist | Usuarios solo ven sus datos |
| `admin_all` | sets, orders, shipments | Admins tienen acceso total |
| `operador_read` | orders, shipments | Operadores pueden leer |
| `public_read` | sets | Catálogo público sin auth |

### Esquema Simplificado
```sql
-- Identidad
profiles (id, email, full_name, role, address, subscription_plan, ...)

-- Catálogo
sets (id, name, lego_ref, theme, piece_count, age_range, img_url, ...)
set_piece_list (id, set_id, piece_id, quantity, ...)

-- Inventario
inventario_sets (id, set_id, estado, ubicacion, ...)

-- Comercial
orders (id, user_id, set_id, status, created_at, ...)
subscriptions (id, user_id, stripe_subscription_id, plan, status, ...)

-- Logística
envios (id, order_id, correos_shipment_id, tracking_code, pudo_point_id, status, ...)

-- Contenido
donations (id, user_id, amount, message, ...)
wishlist (id, user_id, set_id, ...)
```

---

## Edge Functions

### Runtime
- Deno (TypeScript nativo)
- Desplegadas en Supabase Functions
- Variables de entorno via `Deno.env.get()`
- Comunicación con Stripe SDK y fetch nativo

### Flujo de Autenticación en Edge Functions
```
Cliente → Header Authorization: Bearer <JWT>
         ↓
Edge Function → supabaseAdmin.auth.getUser(jwt)
              → Verifica rol si necesario
              → Ejecuta lógica
              → Responde JSON
```

---

## Autenticación

```
Usuario → Supabase Auth (email/password)
        → JWT emitido (1h por defecto)
        → AuthContext almacena session
        → RLS usa auth.uid() para filtrar datos
        → rol en profiles.role para RBAC adicional
```

### Roles y Permisos
| Acción | user | operador | admin |
|---|:---:|:---:|:---:|
| Ver catálogo | ✅ | ✅ | ✅ |
| Realizar pedido | ✅ | ❌ | ✅ |
| Ver sus pedidos | ✅ | ❌ | ✅ |
| Panel operaciones | ❌ | ✅ | ✅ |
| Gestión backoffice | ❌ | ❌ | ✅ |
| CRUD sets | ❌ | ❌ | ✅ |
| Ver todos pedidos | ❌ | ✅ | ✅ |

---

## Pagos con Stripe

### Flujo Suscripción
```
1. Frontend → POST /create-subscription-intent
   { priceId, customerId }

2. Edge Function → stripe.paymentIntents.create()
   → Devuelve clientSecret

3. Frontend → stripe.confirmPayment(clientSecret)
   → Stripe procesa pago

4. Stripe → POST /stripe-webhook (evento payment_intent.succeeded)
   Edge Function → Actualiza profiles.subscription_plan en Supabase
```

### Planes Disponibles (inferidos del código)
| Plan | Descripción |
|---|---|
| `basic` | Plan básico — 1 set activo |
| `standard` | Plan estándar — 2 sets activos |
| `premium` | Plan premium — 3+ sets activos |

---

## Logística con Correos

### PUDO (Pick Up / Drop Off)
- Usuario selecciona punto de recogida cercano
- `correos-pudo` Edge Function → Correos API consulta puntos
- `PudoSelector` componente muestra mapa/lista

### Envío
```
Admin/Operador crea envío →
correos-logistics Edge Function →
Correos API genera código de envío →
QR/etiqueta descargable →
Tracking actualizado en envios tabla
```

---

## App iOS (React Native / Expo)

### Estado Actual
La app comparte la misma instancia de Supabase que el web.

### Estructura
```
apps/ios/
├── App.tsx           # Entry point
├── navigation/       # React Navigation
├── screens/          # Pantallas equivalentes a páginas web
├── contexts/         # Shared contexts
├── hooks/            # Hooks adaptados
└── lib/              # Cliente Supabase, utilidades
```

---

## Monorepo (packages/shared)

Código compartido entre web e iOS:
- Tipos TypeScript
- Esquemas de validación (Zod)
- Utilidades puras

---

## Consideraciones de Seguridad

1. **RLS en todas las tablas** — primera línea de defensa
2. **Service Role Key** solo en Edge Functions (servidor)
3. **Anon Key** solo para operaciones públicas permitidas
4. **Webhook secret** para validar eventos de Stripe
5. **CORS** configurado en Edge Functions
6. Variables sensibles en `.env` (no en repositorio)