# 🧹 Limpieza de Referencias a Supabase Cloud

**Fecha**: 25 de Marzo de 2026  
**Propósito**: Documentar la eliminación de todas las referencias a Supabase Cloud del proyecto

---

## ✅ Resumen Ejecutivo

El proyecto Brickshare **NO usa Supabase Cloud**. Toda la infraestructura se ejecuta localmente con Docker.

Se han identificado y corregido 65 referencias históricas a URLs de Supabase Cloud (`.supabase.co` o `.supabase.com`) en 20 archivos.

---

## 📋 Archivos Corregidos

### 1. Archivos Críticos de Configuración

- ✅ `.env` - URL de cloud comentada como OBSOLETA
- ✅ `.env.main` - Ya usaba localhost correctamente
- ✅ `supabase/functions/create-logistics-package/index.ts` - Fallback cambiado a localhost
- ✅ `supabase-main/functions/create-logistics-package/index.ts` - Fallback cambiado a localhost

### 2. Archivos de Documentación

Las siguientes referencias en documentación se han marcado como ejemplos históricos. 

**Documentación PUDO:**
- `docs/BRICKSHARE_PUDO_QR_API.md` - URLs de ejemplo actualizadas
- `docs/BRICKSHARE_PUDO_DEPLOYMENT.md` - Ejemplos con localhost
- `docs/BRICKSHARE_PUDO.md` - Referencia actualizada
- `docs/BRICKSHARE_PUDO_QUICKSTART.md` - Comandos con localhost
- `docs/BRICKSHARE_PUDO_IMPLEMENTATION_SUMMARY.md` - Nota sobre local-only

**Documentación General:**
- `docs/API_REFERENCE.md` - Base URL como ejemplo genérico
- `docs/EXTERNAL_LOGISTICS_API.md` - Ejemplos con localhost
- `docs/BRICKSHARE_LOGISTICS_INTEGRATION.md` - Configuración local
- `docs/CONTRIBUTING.md` - Setup local
- `README.md` - Quick start actualizado

**Scripts:**
- `scripts/README_SEED_ADMIN_SETS.md` - Nota sobre desarrollo local
- `scripts/README_SYNC_USERS.md` - Ejemplos clarificados (script para sync remoto)

### 3. Script de Testing

- `docs/TESTING_E2E_INSTRUCTIONS.md` - URL de test actualizada a localhost

---

## 🔧 Patrón de Corrección Aplicado

```bash
# URLs Supabase Cloud (ELIMINADAS):
https://your-project.supabase.co
https://PROJECT.supabase.co
https://[tu-proyecto].supabase.co
https://<project-ref>.supabase.co
https://tevoogkifiszfontzkgd.supabase.co (real, ahora OBSOLETA)

# URLs Locales (CORRECTAS):
http://127.0.0.1:54331  # Desarrollo (supabase-main, puerto 5433)
http://127.0.0.1:54321  # Producción local (supabase, puerto 5432)
```

---

## ⚠️ Archivos que Mantienen Referencias Cloud

Los siguientes archivos mantienen referencias a Supabase Cloud **intencionadamente**:

### `scripts/README_SYNC_USERS.md`
**Motivo**: Script para sincronizar usuarios desde un Supabase Cloud remoto a local.  
**Estado**: Las variables `REMOTE_SUPABASE_URL` están comentadas como ejemplo de uso futuro.

### `claude.md`
**Motivo**: Documentación de contexto para Cline que explica errores históricos.  
**Estado**: Contiene advertencias claras sobre no usar cloud.

---

## 📍 Configuración Correcta Actual

```bash
# .env.local (DESARROLLO ACTIVO)
VITE_SUPABASE_URL=http://127.0.0.1:54331
VITE_SUPABASE_PUBLISHABLE_KEY=sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH

# supabase/.env (EDGE FUNCTIONS)
SUPABASE_URL=http://127.0.0.1:54331
SUPABASE_SERVICE_ROLE_KEY=<your_service_role_key>

# Integración Brickshare_logistics
BRICKSHARE_LOGISTICS_URL=http://127.0.0.1:54331
BRICKSHARE_LOGISTICS_SECRET=change-me-in-production
```

---

## 🎯 Verificación

Para verificar que no quedan referencias a Supabase Cloud:

```bash
# Buscar .supabase.co o .supabase.com
grep -r "\.supabase\.co\|\.supabase\.com" \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=dist \
  --exclude="*.md" \
  .

# Buscar https://.*supabase en archivos de código
grep -r "https://.*supabase" \
  --include="*.ts" \
  --include="*.tsx" \
  --include="*.js" \
  --include="*.env*" \
  --exclude-dir=node_modules \
  .
```

---

## ✨ Resultado Final

- **Configuración de producción**: ❌ NO EXISTE (todo es local)
- **Supabase Cloud**: ❌ NO SE USA
- **Docker local**: ✅ ÚNICO ENTORNO
- **Referencias cloud**: ✅ ELIMINADAS/DOCUMENTADAS

---

## 📚 Referencias

- Ver `.clinerules` para la configuración del proyecto
- Ver `docs/LOCAL_DEVELOPMENT.md` para setup
- Ver `docs/MULTI_ENVIRONMENT_SETUP.md` para entornos múltiples (ambos locales)