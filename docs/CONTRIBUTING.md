# Guía de Contribución — Brickshare

## Requisitos Previos

```bash
node >= 18
npm >= 9
# o bien
bun >= 1.0

# Para Supabase local
supabase CLI >= 1.x
docker (para Supabase local)
```

---

## Setup del Entorno de Desarrollo

### 1. Clonar el repositorio
```bash
git clone https://github.com/EnriquePerez00/brickshare_antigravityonly.git
cd brickshare_antigravityonly
```

### 2. Instalar dependencias
```bash
npm install
# o
bun install
```

### 3. Variables de entorno
```bash
cp .env.example .env.local
```

Editar `.env.local` con tus credenciales:
```env
VITE_SUPABASE_URL=https://tu-proyecto.supabase.co
VITE_SUPABASE_ANON_KEY=tu-anon-key
VITE_STRIPE_PUBLISHABLE_KEY=pk_test_...
VITE_APP_URL=http://localhost:5173
```

### 4. Configurar Supabase CLI

Para trabajar con migraciones y funciones de Supabase, necesitas configurar el CLI. Sigue la guía completa en:

**[📖 Guía de Configuración Supabase CLI](./SUPABASE_CLI_SETUP.md)**

### 5. Iniciar dev server
```bash
npm run dev
```

La app estará disponible en `http://localhost:5173`

---

## Scripts Disponibles

| Script | Descripción |
|---|---|
| `npm run dev` | Servidor de desarrollo (Vite) |
| `npm run build` | Build de producción |
| `npm run preview` | Preview del build de producción |
| `npm run lint` | Linting con ESLint |
| `npm run test` | Tests unitarios con Vitest |
| `npm run test:coverage` | Tests con informe de cobertura |

---

## Estructura de Ramas

```
main          → Producción (desplegado automáticamente en Vercel)
develop       → Rama de integración (base para PRs)
feature/*     → Nuevas funcionalidades
fix/*         → Corrección de bugs
hotfix/*      → Correcciones urgentes en producción
chore/*       → Mantenimiento, dependencias, documentación
```

### Flujo de trabajo
```
feature/nueva-funcionalidad → develop → main
```

---

## Convenciones de Commits

Se usa [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: añadir sistema de reviews
fix: corregir cálculo de precio en checkout
docs: actualizar API_REFERENCE.md
chore: actualizar dependencias
refactor: extraer lógica de pagos a hook usePayment
test: añadir tests para useOrders
```

---

## Añadir una Nueva Página

1. Crear el componente en `src/pages/NuevaPagina.tsx`
2. Añadir la ruta en `src/App.tsx`:
```tsx
<Route path="/nueva-pagina" element={<NuevaPagina />} />
```
3. Si requiere autenticación, envolver con el guard apropiado

---

## Añadir una Edge Function

1. Crear el directorio en `supabase/functions/nombre-funcion/`
2. Crear `supabase/functions/nombre-funcion/index.ts`
3. Seguir la estructura base:
```typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Tu lógica aquí
    return new Response(
      JSON.stringify({ success: true }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});
```
4. Documentar en `docs/API_REFERENCE.md`

---

## Añadir una Migración de BD

```bash
# Generar migración vacía
supabase migration new nombre_de_la_migracion

# El archivo se crea en supabase/migrations/
# Editar el archivo .sql con los cambios
# Aplicar en local
supabase db reset

# Para producción, el deploy aplica las migraciones automáticamente
```

---

## Generación de Tipos TypeScript desde Supabase

```bash
# Requiere Supabase CLI instalado y autenticado
supabase gen types typescript \
  --project-id <project-id> \
  --schema public \
  > src/integrations/supabase/types.ts
```

Hacer esto **siempre** después de cambiar el esquema de BD.

---

## Linting y Formateo

El proyecto usa **ESLint** para linting. Antes de hacer commit:

```bash
npm run lint
# Corregir automáticamente
npm run lint -- --fix
```

Se recomienda instalar la extensión ESLint en VS Code y activar "Format on Save".

---

## Debugging

### Edge Functions (Remoto)
```bash
# Ver logs en tiempo real
supabase functions logs nombre-funcion --follow

# Ver logs históricos
supabase functions logs nombre-funcion
```

### Base de Datos
```bash
# Ver estado del proyecto
supabase status

# Ejecutar queries
supabase db query "SELECT * FROM table_name LIMIT 5"
```

**Nota**: Este proyecto trabaja solo con Supabase remoto, no usa Docker local. Ver [SUPABASE_CLI_SETUP.md](./SUPABASE_CLI_SETUP.md) para más detalles.

---

## FAQ para Desarrolladores

**¿Cómo accedo al panel de Supabase?**
Dashboard remoto: https://supabase.com/dashboard/project/tevoogkifiszfontzkgd

**¿Cómo probar webhooks de Stripe en local?**
```bash
stripe listen --forward-to localhost:54321/functions/v1/stripe-webhook
```

**¿Por qué mi query a Supabase devuelve empty array?**
Verificar que las políticas RLS permiten la operación con el usuario autenticado.

**¿Cómo cambio el rol de un usuario?**
En Supabase Studio → Table Editor → `profiles` → editar `role` del usuario.