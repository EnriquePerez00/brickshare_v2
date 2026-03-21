# Brickshare — Visión General del Proyecto

## ¿Qué es Brickshare?

Brickshare es una plataforma de **alquiler/préstamo circular de sets de LEGO** orientada a familias. Los usuarios pagan una suscripción mensual, seleccionan sets del catálogo, los reciben en casa mediante Correos, los disfrutan y los devuelven para obtener el siguiente. El modelo combina economía circular, ahorro familiar y sostenibilidad.

---

## Stack Tecnológico

| Capa | Tecnología |
|---|---|
| Frontend Web | React 18 + TypeScript + Vite |
| Estilos | Tailwind CSS + shadcn/ui |
| Backend / DB | Supabase (PostgreSQL + Auth + Storage + Edge Functions) |
| Pagos | Stripe (Checkout Sessions, Subscriptions, Webhooks) |
| Logística | Correos API (PUDO points, envíos, tracking) |
| Email | Resend |
| App Móvil | React Native + Expo (apps/ios/) |
| Monorepo | Packages compartidos en packages/shared/ |
| Deploy | Vercel (web) |

---

## Estructura del Repositorio

```
Brickshare/
├── src/                        # Frontend web principal (Vite/React)
│   ├── pages/                  # Rutas principales
│   ├── components/             # Componentes UI reutilizables
│   ├── hooks/                  # Custom hooks (datos, lógica)
│   ├── contexts/               # AuthContext
│   ├── integrations/supabase/  # Cliente Supabase tipado
│   └── lib/                    # Utilidades (pudo, resend, utils)
├── apps/
│   ├── web/                    # App web alternativa (monorepo)
│   └── ios/                    # App React Native / Expo
├── packages/shared/            # Código compartido (tipos, utils)
├── supabase/
│   ├── functions/              # Edge Functions (serverless)
│   └── migrations/             # Migraciones SQL históricas
└── docs/                       # Documentación del proyecto
```

---

## Páginas del Frontend

| Ruta | Componente | Descripción |
|---|---|---|
| `/` | `Index.tsx` | Landing page principal |
| `/catalogo` | `Catalogo.tsx` | Catálogo de sets disponibles |
| `/como-funciona` | `ComoFunciona.tsx` | Explicación del servicio |
| `/sobre-nosotros` | `SobreNosotros.tsx` | Página corporativa |
| `/blog` | `Blog.tsx` | Blog de contenido |
| `/contacto` | `Contacto.tsx` | Formulario de contacto |
| `/donaciones` | `Donaciones.tsx` | Módulo de donaciones |
| `/auth` | `Auth.tsx` | Login / Registro |
| `/dashboard` | `Dashboard.tsx` | Panel del usuario (privado) |
| `/admin` | `Admin.tsx` | Backoffice administrador |
| `/operations` | `Operations.tsx` | Panel operador logístico |
| `/legal-notice` | `LegalNotice.tsx` | Aviso legal |
| `/privacy-policy` | `PrivacyPolicy.tsx` | Política de privacidad |
| `/terminos-condiciones` | `TerminosCondiciones.tsx` | T&C |

---

## Roles de Usuario

| Rol | Descripción |
|---|---|
| `user` | Cliente suscriptor (rol por defecto) |
| `admin` | Administrador con acceso total al backoffice |
| `operador` | Acceso a panel de operaciones logísticas |

---

## Flujos Principales

### 1. Flujo de Suscripción
```
Usuario → Selecciona plan → Stripe Checkout Session → 
Webhook confirma pago → Perfil actualizado en Supabase → 
Usuario accede a Dashboard
```

### 2. Flujo de Pedido / Envío
```
Dashboard → Usuario solicita set → 
Creación de orden en BD → Asignación de set físico → 
Correos genera envío → PUDO point seleccionado → 
QR/etiqueta generada → Entrega → Seguimiento → Devolución
```

### 3. Flujo de Donación
```
Usuario / empresa → submit-donation Edge Function → 
Registro en BD → Email de confirmación (Resend)
```

---

## Edge Functions (Supabase)

| Función | Propósito |
|---|---|
| `create-checkout-session` | Crear sesión de pago Stripe |
| `create-subscription-intent` | Iniciar suscripción Stripe |
| `change-subscription` | Cambiar/cancelar plan |
| `stripe-webhook` | Recibir eventos de Stripe |
| `process-assignment-payment` | Pago de asignación de set |
| `correos-logistics` | Crear envíos con Correos API |
| `correos-pudo` | Consultar puntos PUDO |
| `send-email` | Envío de emails vía Resend |
| `submit-donation` | Registrar donaciones |
| `fetch-lego-data` | Enriquecer datos de sets desde API externa |
| `add-lego-set` | Añadir set al catálogo |
| `delete-user` | Eliminar cuenta de usuario |

---

## Variables de Entorno Requeridas

```env
# Supabase
VITE_SUPABASE_URL=
VITE_SUPABASE_ANON_KEY=

# Stripe
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
VITE_STRIPE_PUBLISHABLE_KEY=

# Resend
RESEND_API_KEY=

# Correos API
CORREOS_API_USER=
CORREOS_API_PASSWORD=
CORREOS_SENDER_CODE=

# App
VITE_APP_URL=
```

---

## Estado Actual del Proyecto

- ✅ Landing page completa con secciones de marketing
- ✅ Sistema de autenticación (Supabase Auth)
- ✅ Catálogo de sets con enriquecimiento desde Rebrickable/BrickSet
- ✅ Suscripciones con Stripe
- ✅ Panel de usuario (Dashboard)
- ✅ Backoffice de administrador
- ✅ Integración logística con Correos (PUDO, envíos, tracking)
- ✅ Sistema de donaciones
- ✅ App iOS en desarrollo (React Native/Expo)
- ✅ Wishlist de usuarios
- ✅ Módulo de blog
- ⚠️ App iOS incompleta (falta paridad con web)
- ⚠️ Tests unitarios mínimos
- ⚠️ Sin CI/CD configurado