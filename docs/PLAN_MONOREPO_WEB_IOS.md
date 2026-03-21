# Análisis del repositorio Brickshare y plan: monorepo Web + iOS

## 1. Estado actual del repositorio

### 1.1 Estructura actual

```
Brickshare/
├── src/                    # Frontend web (todo en raíz)
│   ├── components/         # UI (shadcn + custom)
│   ├── contexts/           # AuthContext
│   ├── hooks/              # useProducts, useOrders, useWishlist, useSubscription, useDonation, usePudo, useShipments, useLegoEnrichment
│   ├── integrations/supabase/  # client.ts, types.ts (vacío)
│   ├── lib/                # pudoService, resend, utils
│   └── pages/              # Index, Catalogo, Dashboard, Auth, Admin, Operations, etc.
├── supabase/               # Backend (compartido)
│   ├── config.toml
│   ├── migrations/         # ~100+ migraciones SQL
│   └── functions/          # Edge Functions (Deno)
│       ├── add-lego-set
│       ├── change-subscription
│       ├── correos-logistics
│       ├── correos-pudo
│       ├── create-checkout-session
│       ├── create-subscription-intent
│       ├── delete-user
│       ├── fetch-lego-data
│       ├── process-assignment-payment
│       ├── send-email
│       ├── stripe-webhook
│       └── submit-donation
├── public/
├── package.json            # Vite + React + TypeScript
├── vite.config.ts
└── docs/
```

### 1.2 Stack técnico

| Capa | Tecnología |
|------|------------|
| **Frontend web** | Vite 7, React 18, TypeScript, React Router, TanStack Query, shadcn/ui (Radix), Tailwind, Framer Motion, Stripe JS, Supabase JS |
| **Backend** | Supabase: Auth, PostgreSQL, Storage, Edge Functions (Deno), RLS |
| **Integraciones** | Stripe (pagos/suscripciones), Correos (PUDO, logística), Resend/Mailtrap (emails), Google Maps (PUDO), Rebrickable/Brickset (datos LEGO) |

### 1.3 Flujos principales del frontend

- **Auth**: registro/login (email, Google), perfil (users), roles (user_roles: admin, operador).
- **Catálogo**: listado de sets (tabla `sets`), wishlist, filtros.
- **Dashboard usuario**: wishlist, pedidos/envíos (`envios`), punto PUDO (`users_correos_dropping`), devoluciones (Edge Function `correos-logistics`).
- **Suscripción**: Stripe (create-subscription-intent, change-subscription, checkout).
- **Donaciones**: submit-donation (Edge Function).
- **Admin**: usuarios, productos/sets, inventario, operaciones (asignaciones, envíos, devoluciones).

### 1.4 Comunicación con el backend

- **Supabase Client**: `createClient(SUPABASE_URL, SUPABASE_ANON_KEY)` con `localStorage` para sesión.
- **Tablas usadas desde el cliente**: `users`, `user_roles`, `sets`, `wishlist`, `envios`, `users_correos_dropping`, etc.
- **Edge Functions**: todas vía `supabase.functions.invoke('nombre-funcion', { body: {...} })`.
- **Variables de entorno (frontend)**: `VITE_SUPABASE_URL`, `VITE_SUPABASE_PUBLISHABLE_KEY`, `VITE_STRIPE_PUBLISHABLE_KEY`, `VITE_GOOGLE_MAPS_API_KEY`.

---

## 2. Objetivo

- Unificar en **un solo repositorio** el desarrollo de **frontend web** y **app móvil iOS**.
- Mantener **un mismo backend** (Supabase).
- **Separar los frontends** para poder desarrollarlos por separado (equipos o fases distintas).

---

## 3. Estructura recomendada: monorepo

Se recomienda un **monorepo** con aplicaciones separadas y backend compartido.

### 3.1 Estructura objetivo

```
Brickshare/
├── apps/
│   ├── web/                 # Frontend web actual (movido desde raíz)
│   │   ├── src/
│   │   ├── public/
│   │   ├── package.json
│   │   └── vite.config.ts
│   │
│   └── ios/                  # App iOS (nueva)
│       ├── Brickshare/       # Proyecto Xcode (Swift/SwiftUI) O proyecto React Native/Expo
│       ├── package.json      # Solo si es React Native/Expo
│       └── ...
│
├── packages/                 # Opcional pero recomendado
│   └── shared/               # Tipos, API client, constantes
│       ├── src/
│       │   ├── types/        # Database types, DTOs, Profile, SetData, OrderData, etc.
│       │   ├── api/          # Contratos de Edge Functions (nombres, payloads)
│       │   └── constants/    # URLs, keys de config
│       ├── package.json
│       └── tsconfig.json
│
├── supabase/                 # Sin cambios (backend único)
│   ├── config.toml
│   ├── migrations/
│   └── functions/
│
├── package.json              # Workspace root (npm/pnpm workspaces)
├── pnpm-workspace.yaml       # o npm workspaces
└── docs/
```

Ventajas de esta estructura:

- Un solo repo, un solo backend (Supabase).
- `apps/web` y `apps/ios` se desarrollan y despliegan por separado.
- `packages/shared` evita duplicar tipos y contratos entre web e iOS.
- CI/CD puede construir solo `web` o solo `ios` según rama o path.

---

## 4. Opciones para la app iOS

Dos enfoques según cuánto quieras reutilizar del frontend web.

### 4.1 Opción A: React Native / Expo (recomendada para reutilizar lógica)

- **Idea**: Misma base TypeScript/React: lógica de negocio, hooks y contratos de API reutilizables; solo la capa de UI es específica de móvil.
- **Ventajas**:
  - Reutilizar tipos, hooks (adaptados a RN), servicios (Supabase, Edge Functions), flujos (auth, catálogo, wishlist, pedidos, PUDO).
  - Supabase tiene SDK oficial para React Native (auth con almacenamiento seguro, mismo `supabase.functions.invoke`).
  - Un solo lenguaje y ecosistema para web y móvil.
- **Desventajas**:
  - No es app “100% nativa” en Swift; es JavaScript/TypeScript en runtime nativo.
- **Dónde iría**: `apps/ios` como proyecto Expo (o React Native CLI) dentro del monorepo; opcionalmente compartir `packages/shared` con `apps/web`.

### 4.2 Opción B: Swift / SwiftUI (app nativa iOS)

- **Idea**: App nativa en Swift; solo se reutilizan **contratos de API** y **tipos** (traducidos a Swift o generados).
- **Ventajas**:
  - Máximo rendimiento e integración con iOS; distribución vía App Store sin dependencia de JS.
- **Desventajas**:
  - Hay que reimplementar toda la UI y la lógica de negocio en Swift; no se reutiliza código React.
- **Dónde iría**: `apps/ios` como proyecto Xcode (Swift/SwiftUI). Los contratos y tipos pueden vivir en `packages/shared` (TypeScript) y documentarse o generarse a Swift con herramientas (por ejemplo OpenAPI + generadores).

---

## 5. Plan de ejecución

### Fase 1: Reestructurar el repositorio (monorepo)

1. **Crear estructura de workspaces**
   - Añadir en la raíz `package.json` workspaces: `["apps/*", "packages/*"]`.
   - Crear `apps/web` y mover todo el código actual del frontend (src, public, index.html, vite.config.ts, package.json, etc.) dentro de `apps/web`.
   - Ajustar rutas y scripts para que `npm run dev` / `build` se ejecuten desde `apps/web`.

2. **Opcional: paquete `packages/shared`**
   - Crear `packages/shared` con TypeScript.
   - Extraer tipos e interfaces usados por web (y luego por móvil): `Profile`, `SetData`, `OrderData`, `CorreosPudoPoint`, etc.
   - Documentar contratos de Edge Functions (nombre, body de entrada, respuesta).
   - Generar (o rellenar) tipos de Supabase desde el schema (por ejemplo `supabase gen types typescript`) y colocarlos en `shared` o en `web` si solo web los usa por ahora.
   - Hacer que `apps/web` dependa de `packages/shared` y use esos tipos.

3. **Verificar**
   - Desde raíz: instalación con `npm install` (o `pnpm install`).
   - Desde `apps/web`: `npm run dev` y `npm run build` sin errores.
   - Dejar `supabase/` en la raíz; ambos frontends lo usarán como backend único.

### Fase 2: Documentar API backend (para móvil y futuro)

1. **Edge Functions**
   - Listar cada función: nombre, método, body esperado, headers (Authorization), respuesta exitosa y errores.
   - Crear en `docs/api-specs/` (o en `packages/shared`) un documento o tipos TypeScript que describan estos contratos (ya tienes algo en `docs/api-specs/correos/`; extender para el resto).

2. **Auth y tablas**
   - Documentar flujo de auth (email, OAuth) y que la app móvil usará el mismo Supabase Project (mismo URL y anon key).
   - Resumir tablas y RLS relevantes para la app (users, sets, wishlist, envios, users_correos_dropping, etc.) para que el equipo iOS sepa qué puede leer/escribir.

### Fase 3: Desarrollo de la app iOS

Según la opción elegida (A o B):

#### Si eliges Opción A (React Native / Expo)

1. Crear proyecto en `apps/ios` con Expo (TypeScript).
2. Configurar Supabase en la app: mismo `SUPABASE_URL` y `SUPABASE_ANON_KEY`; usar `@supabase/supabase-js` y almacenamiento seguro para sesión (Expo SecureStore o equivalente).
3. Reutilizar lógica:
   - Copiar o importar desde `packages/shared` los tipos y contratos de API.
   - Adaptar hooks (useProducts, useOrders, useWishlist, useSubscription, useDonation, usePudo) para React Native (mismo cliente Supabase e `invoke`; sustituir `useNavigate` por navegación RN, etc.).
   - Implementar pantallas equivalentes: Login/Registro, Catálogo, Dashboard (wishlist, pedidos, PUDO), flujo de suscripción (Stripe puede usarse vía WebView o SDK nativo según necesidad).
4. UI con componentes nativos (React Native) o librería (NativeBase, Tamagui, etc.); no reutilizar shadcn directamente (es web).
5. Probar en simulador y dispositivo; configurar builds y firma para TestFlight/App Store.

#### Si eliges Opción B (Swift / SwiftUI)

1. Crear proyecto Xcode en `apps/ios/Brickshare` (Swift, SwiftUI).
2. Integrar Supabase: usar cliente REST o SDK oficial de Supabase para Swift si existe; en cualquier caso, mismo URL y anon key, y mismo flujo de Auth (email, OAuth con Safari/ASWebAuthenticationSession).
3. Implementar en Swift:
   - Modelos equivalentes a los tipos de `packages/shared` (Profile, Set, Order, PudoPoint, etc.).
   - Servicios/clases que llamen a PostgREST (tablas) y a Edge Functions (HTTPS con JWT en Authorization).
   - Pantallas: Login, Catálogo, Dashboard, Wishlist, Pedidos, PUDO, Suscripción (Stripe vía SDK o WebView).
4. Reutilizar solo documentación y contratos de `packages/shared`; no hay código TS compartido con la app.

### Fase 4: Unificación y mantenimiento

1. **Variables de entorno**
   - Web: seguir con `VITE_*` en `apps/web`.
   - iOS: usar mismo Supabase URL/Key; Stripe y Google Maps si aplica (Config.xcconfig o .xcodeproj).

2. **CI/CD**
   - Build web: solo en `apps/web` (y opcionalmente `packages/shared`).
   - Build iOS: solo en `apps/ios` (Xcode o Expo build).
   - Backend: despliegue de Supabase (migrations + functions) desde `supabase/` como hasta ahora.

3. **Documentación**
   - Actualizar README raíz con estructura monorepo y cómo ejecutar web, iOS y Supabase.
   - Mantener `docs/PLAN_MONOREPO_WEB_IOS.md` (este documento) como referencia del plan.

---

## 6. Resumen de recomendaciones

| Tema | Recomendación |
|------|----------------|
| **Estructura** | Monorepo con `apps/web`, `apps/ios` y opcional `packages/shared`. |
| **Backend** | Mantener Supabase en la raíz; un solo proyecto Supabase para web e iOS. |
| **App iOS** | **React Native/Expo** si quieres desarrollar “en base al frontend web” y reutilizar lógica; **Swift/SwiftUI** si priorizas app 100% nativa y solo compartir API/tipos. |
| **Tipos y API** | Centralizar en `packages/shared` (TypeScript) para web y, en Opción A, para la app móvil; en Opción B, usar `shared` solo como documentación/contratos para Swift. |
| **Primer paso** | Fase 1: reestructurar a monorepo y mover el frontend a `apps/web` sin romper builds. |

---

## 7. Estado de ejecución (React Native / Expo)

**Hecho:**

- **Fase 1**: Monorepo con `apps/web`, `apps/ios` y `packages/shared`. Frontend web copiado a `apps/web`; workspaces en la raíz (`npm run dev`, `npm run dev:web`, `npm run build:web`, `npm run build:shared`, `npm run start:ios`).
- **packages/shared**: Tipos `Profile`, `SetData`, `OrderData`, `CorreosPudoPoint` y contratos de Edge Functions exportados en `@brickshare/shared`.
- **apps/ios**: Proyecto Expo (TypeScript) con cliente Supabase en `lib/supabase.ts` (AsyncStorage), `.env.example`, y README. Dependencia de `@brickshare/shared` y `@supabase/supabase-js`.
- **README raíz** y **apps/ios/README.md** actualizados con la nueva estructura y comandos.

**Próximos pasos (desarrollo de la app iOS):**

1. Añadir pantallas (Auth, Catálogo, Dashboard) y navegación (React Navigation).
2. Adaptar/copiar lógica de hooks del web (o consumir `@brickshare/shared` y reimplementar hooks en la app).
3. Añadir iconos/splash en `apps/ios/assets` si se desea.
4. Probar en simulador/dispositivo con `npm run start:ios` desde la raíz.
