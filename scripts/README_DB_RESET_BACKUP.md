# 🔄 Automatic Database Backup Before Reset

## Overview

Este sistema automáticamente crea un backup de tu base de datos local **antes** de ejecutar `supabase db reset`, evitando pérdida de datos accidental.

## 📁 Estructura de Backups

```
supabase/
├── last_dump.sql               # ⭐ Último backup (siempre sobrescrito)
└── backups/
    ├── .gitkeep
    ├── pre_reset_20260324_101530.sql
    ├── pre_reset_20260324_103245.sql
    └── ...                     # Se mantienen los últimos 10 backups
```

## 🚀 Uso Recomendado

### Opción 1: Script Wrapper (Recomendado)

```bash
# Usa el script wrapper que automáticamente hace backup
./scripts/db-reset.sh

# También puedes pasar argumentos de supabase db reset
./scripts/db-reset.sh --debug
```

### Opción 2: Comando Directo con Hook

Si instalaste los hooks con `./scripts/install-hooks.sh`:

```bash
# El hook pre-db-reset se ejecuta automáticamente
./.git/hooks/pre-db-reset && supabase db reset
```

### Opción 3: Supabase CLI Directo (Sin Backup)

```bash
# ⚠️ No crea backup automático
supabase db reset
```

## 🔧 Instalación

### Instalación Automática

```bash
# Instala todos los hooks (pre-commit y pre-db-reset)
./scripts/install-hooks.sh
```

### Verificación

```bash
# Verifica que el hook está instalado
ls -la .git/hooks/pre-db-reset

# Prueba el backup manual
./.git/hooks/pre-db-reset
```

## 📦 Qué Incluye el Backup

El backup incluye:
- ✅ Schema `public` (tablas, funciones, triggers)
- ✅ Schema `auth` (usuarios, roles)
- ✅ Schema `storage` (archivos metadata)
- ✅ Datos de todas las tablas
- ✅ RLS policies
- ✅ Indexes y constraints

El backup **NO** incluye:
- ❌ Archivos almacenados en Storage (solo metadata)
- ❌ Schemas de sistema interno de Supabase

## 🔄 Restaurar un Backup

### Restaurar el último backup

```bash
psql postgresql://postgres:postgres@127.0.0.1:5433/postgres < supabase/last_dump.sql
```

### Restaurar un backup específico

```bash
psql postgresql://postgres:postgres@127.0.0.1:5433/postgres < supabase/backups/pre_reset_20260324_101530.sql
```

### Restaurar con reset completo

```bash
# 1. Resetea la BD
supabase db reset

# 2. Restaura el backup
psql postgresql://postgres:postgres@127.0.0.1:5433/postgres < supabase/last_dump.sql
```

## 🗄️ Gestión de Backups

### Rotación Automática

- Se mantienen automáticamente los **últimos 10 backups** timestamped
- Los backups más antiguos se eliminan automáticamente
- `last_dump.sql` siempre contiene el backup más reciente

### Limpieza Manual

```bash
# Eliminar backups antiguos (mantener últimos 5)
cd supabase/backups
ls -t pre_reset_*.sql | tail -n +6 | xargs rm
```

### Ver Tamaño de Backups

```bash
du -h supabase/backups/*.sql
du -h supabase/last_dump.sql
```

## ⚙️ Configuración

### Cambiar Número de Backups a Mantener

Edita `.git/hooks/pre-db-reset` y cambia esta línea:

```bash
# De (mantener 10):
ls -t pre_reset_*.sql | tail -n +11 | xargs -r rm

# A (mantener 5):
ls -t pre_reset_*.sql | tail -n +6 | xargs -r rm
```

### Cambiar Schemas en Backup

Edita `.git/hooks/pre-db-reset` y modifica:

```bash
pg_dump "$DB_URL" \
    --no-owner \
    --no-acl \
    --clean \
    --if-exists \
    --schema=public \
    --schema=auth \
    --schema=storage \
    --schema=tu_nuevo_schema \  # Añade más schemas aquí
    > "$BACKUP_FILE"
```

## 🐛 Troubleshooting

### El backup no se crea

**Problema**: El hook no se ejecuta o falla

**Solución**:
```bash
# 1. Verifica que el hook es ejecutable
chmod +x .git/hooks/pre-db-reset

# 2. Verifica que Supabase está corriendo
supabase status

# 3. Prueba el hook manualmente
./.git/hooks/pre-db-reset
```

### Permiso denegado en el hook

```bash
chmod +x .git/hooks/pre-db-reset
```

### pg_dump no encontrado

```bash
# macOS
brew install postgresql

# El cliente de postgres debe estar instalado
which pg_dump
```

### Backup incompleto o corrupto

```bash
# Verifica el contenido del backup
head -n 50 supabase/last_dump.sql

# Intenta restaurar en una BD de prueba
createdb test_restore
psql test_restore < supabase/last_dump.sql
dropdb test_restore
```

## 💡 Tips y Mejores Prácticas

### Antes de Cambios Importantes

```bash
# 1. Crea un backup manual adicional
./scripts/db-reset.sh  # Esto crea backup automático
cp supabase/last_dump.sql supabase/backups/manual_before_big_change.sql

# 2. Realiza tus cambios...

# 3. Si algo sale mal, restaura
psql postgresql://postgres:postgres@127.0.0.1:5433/postgres < supabase/backups/manual_before_big_change.sql
```

### Backup Completo para Producción

```bash
# Este sistema es SOLO para desarrollo local
# Para producción, usa los backups nativos de Supabase Dashboard
# o configura backups automáticos en tu proyecto cloud
```

### Integración con CI/CD

```bash
# En workflows de CI/CD, puedes deshabilitar el backup:
SKIP_DB_BACKUP=1 supabase db reset
```

## 📚 Referencias

- [Supabase CLI Docs](https://supabase.com/docs/guides/cli)
- [pg_dump Manual](https://www.postgresql.org/docs/current/app-pgdump.html)
- [Git Hooks](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks)

## 🔗 Archivos Relacionados

- `.git/hooks/pre-db-reset` - Hook principal
- `scripts/db-reset.sh` - Script wrapper
- `scripts/install-hooks.sh` - Instalador de hooks
- `.gitignore` - Ignora archivos `.sql` de backup
- `supabase/backups/.gitkeep` - Mantiene directorio en git

---

**Nota**: Los backups son **locales** y solo para desarrollo. Para producción, usa las herramientas nativas de backup de Supabase Cloud.