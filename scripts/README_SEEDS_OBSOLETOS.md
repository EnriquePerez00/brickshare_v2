# 🗑️ Seeds Obsoletos Eliminados

## Archivos Eliminados en la Limpieza de Seeds

Como parte de la reorganización del sistema de seeds, se han eliminado los siguientes archivos obsoletos:

### 📁 Scripts SQL Eliminados

1. **`scripts/seed-admin-and-sets.sql`**
   - ❌ **Razón**: Seed parcial con solo 15 sets de ejemplo
   - ✅ **Reemplazo**: `supabase/seed_full.sql` + scripts de API para poblar catálogo
   - 📝 **Contenía**: 5 sets City + 5 sets Star Wars + 5 sets Architecture

2. **`scripts/seed-users-wishlist.sql`**
   - ❌ **Razón**: Seed muy específico para un caso de prueba
   - ✅ **Reemplazo**: `supabase/seed_full.sql` incluye usuarios base
   - 📝 **Contenía**: 2 usuarios + 5 sets + wishlist asociada

3. **`scripts/reset-test-data.sql`**
   - ❌ **Razón**: Script de limpieza, no seed real
   - ✅ **Reemplazo**: `supabase db reset` hace esto mejor
   - 📝 **Función**: Limpiaba envíos, wishlist y reseteaba estados

### 📁 Archivos de Backup Temporales Eliminados

- `supabase/seed-temp.sql` - Backup temporal
- `supabase/seed.sql.backup` - Backup antiguo
- `supabase/seed.sql.bak` - Backup 1
- `supabase/seed.sql.bak2` - Backup 2

Estos archivos eran duplicados o versiones obsoletas del seed principal.

---

## 🆕 Nuevo Sistema de Seeds

### Archivo Principal

**`supabase/seed_full.sql`** - Seed completo unificado
- ✅ Incluye datos de `auth` (usuarios de prueba)
- ✅ Incluye datos de `public` (usuarios, roles, PUDO locations)
- ✅ Documentación inline de usuarios y contraseñas
- ✅ Se aplica automáticamente con `supabase db reset`

### Archivos Mantenidos

**`supabase/seed.sql`** - Seed oficial de Supabase
- Archivo reconocido automáticamente por CLI de Supabase
- Puede ser el seed completo o un symlink a `seed_full.sql`

---

## 📋 README Eliminados

Junto con los seeds obsoletos, se eliminaron sus READMEs correspondientes:

- `scripts/README_SEED_ADMIN_SETS.md` → Ya no necesario
- `scripts/README_RESET_TEST_DATA.md` → Ya no necesario

---

## 🔄 Migración de Flujos Antiguos

Si tenías scripts que usaban los seeds eliminados, aquí está la migración:

### Antiguo: seed-admin-and-sets.sql

```bash
# ❌ Antiguo
psql "$DB_URL" < scripts/seed-admin-and-sets.sql
```

```bash
# ✅ Nuevo - Opción 1: Seed completo
./scripts/db-reset.sh

# ✅ Nuevo - Opción 2: Poblar catálogo desde API
npm run seed-sets-from-brickset
```

### Antiguo: seed-users-wishlist.sql

```bash
# ❌ Antiguo
psql "$DB_URL" < scripts/seed-users-wishlist.sql
```

```bash
# ✅ Nuevo
./scripts/db-reset.sh  # Ya incluye usuarios de prueba

# Agregar wishlist manualmente si es necesario:
# Ver supabase/seed_full.sql sección wishlist
```

### Antiguo: reset-test-data.sql

```bash
# ❌ Antiguo
psql "$DB_URL" < scripts/reset-test-data.sql
```

```bash
# ✅ Nuevo
supabase db reset  # Reset completo mejor que limpieza parcial
```

---

## 🎯 Beneficios de la Nueva Estructura

1. **Un solo archivo de seed** → Menos confusión
2. **Seed completo funcional** → Incluye todo lo necesario para desarrollo
3. **Documentación integrada** → Contraseñas y usuarios en el mismo archivo
4. **Compatible con CLI** → Se aplica automáticamente con `db reset`
5. **Mejor organización** → `.gitignore` actualizado para backups
6. **Fácil mantenimiento** → Un solo punto de actualización

---

## 📚 Documentación Actualizada

Ver la nueva documentación completa:
- [`scripts/README_SEED_FULL.md`](README_SEED_FULL.md) - Guía de uso del seed
- [`scripts/README_DB_RESET_BACKUP.md`](README_DB_RESET_BACKUP.md) - Sistema de backups
- [`README.md`](../README.md) - Sección actualizada de base de datos

---

**Fecha de limpieza**: 24 de marzo de 2026  
**Commit**: [Cleanup: Unify database seeds into single seed_full.sql]