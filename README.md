# Brickshare

Aplicación web de alquiler de sets de LEGO construida con **Vite + React** y **backend Supabase**.

## Estructura

```
├── apps/
│   └── web/          # Frontend web (Vite, React, shadcn, Tailwind)
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
```

El frontend web está en `apps/web`. Se sirve en `http://localhost:8080` (o el puerto que use Vite).

**Build:**

```bash
npm run build
```

## Backend (Supabase)

El backend utiliza Supabase con Auth, base de datos PostgreSQL y Edge Functions.

- Migraciones: `supabase/migrations/`
- Edge Functions: `supabase/functions/`

---

## Lovable

**URL**: https://lovable.dev/projects/REPLACE_WITH_PROJECT_ID

Puedes seguir editando con Lovable; los cambios se reflejan en este repo. El código web está en `apps/web/`.

Deploy: Lovable → Share → Publish.

Tecnologías: Vite, TypeScript, React, shadcn-ui, Tailwind CSS, Supabase.
