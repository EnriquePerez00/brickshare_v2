# Brickshare

Monorepo: **frontend web** (Vite + React) y **app iOS** (Expo), con un mismo **backend** (Supabase).

## Estructura

```
├── apps/
│   ├── web/          # Frontend web (Vite, React, shadcn, Tailwind)
│   └── ios/          # App móvil iOS (Expo, React Native)
├── packages/
│   └── shared/       # Tipos y contratos API compartidos
├── supabase/         # Backend (Auth, DB, Edge Functions)
└── docs/
```

## Requisitos

- Node.js 18+
- npm (o pnpm si prefieres)

## Instalación

```bash
npm install
```

## Desarrollo

**Web** (desde la raíz):

```bash
npm run dev
# o
npm run dev:web
```

El frontend web está en `apps/web`. Se sirve en `http://localhost:8080` (o el puerto que use Vite).

**App iOS** (Expo):

```bash
# Opcional: compilar tipos compartidos
npm run build -w @brickshare/shared

# Arrancar Expo
npm run ios
```

Configura `apps/ios/.env` con `EXPO_PUBLIC_SUPABASE_URL` y `EXPO_PUBLIC_SUPABASE_ANON_KEY` (mismos valores que la web). Ver `apps/ios/README.md`.

**Build web:**

```bash
npm run build:web
```

## Backend (Supabase)

El backend es común para web e iOS: mismo proyecto Supabase, mismas tablas y Edge Functions.

- Migraciones y funciones: `supabase/`
- Plan detallado web + iOS: `docs/PLAN_MONOREPO_WEB_IOS.md`

---

## Lovable

**URL**: https://lovable.dev/projects/REPLACE_WITH_PROJECT_ID

Puedes seguir editando con Lovable; los cambios se reflejan en este repo. El código web está en `apps/web/`.

Deploy: Lovable → Share → Publish.

Technologías: Vite, TypeScript, React, shadcn-ui, Tailwind CSS, Supabase, Expo (app iOS).
