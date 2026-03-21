# GitHub Actions — Configuración de Secrets

Para que el pipeline CI/CD funcione correctamente, añade los siguientes secrets en:
**GitHub → Settings → Secrets and variables → Actions**

## Secrets Requeridos

| Secret | Descripción | Dónde obtenerlo |
|---|---|---|
| `VITE_SUPABASE_URL` | URL del proyecto Supabase | Supabase Dashboard → Settings → API |
| `VITE_SUPABASE_ANON_KEY` | Anon key pública de Supabase | Supabase Dashboard → Settings → API |
| `VITE_STRIPE_PUBLISHABLE_KEY` | Clave pública de Stripe | Stripe Dashboard → Developers → API keys |
| `VITE_APP_URL` | URL de producción | `https://brickshare.es` |
| `VERCEL_TOKEN` | Token de Vercel | Vercel → Settings → Tokens |
| `VERCEL_ORG_ID` | ID de organización Vercel | `vercel env ls` o Vercel Dashboard |
| `VERCEL_PROJECT_ID` | ID del proyecto en Vercel | `vercel env ls` o Vercel Dashboard |
| `SUPABASE_ACCESS_TOKEN` | Token personal de Supabase CLI | `supabase login` |
| `SUPABASE_PROJECT_ID` | ID del proyecto Supabase | Supabase Dashboard → Settings → General |