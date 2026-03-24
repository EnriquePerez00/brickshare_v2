# 🔄 Brickshare Database Backup & Restore System

Sistema inteligente de backup y restauración de base de datos que maneja cambios de schema de forma automática.

---

## 📋 Tabla de Contenidos

- [Visión General](#-visión-general)
- [Flujo Automático de Backup](#-flujo-automático-de-backup)
- [Estructura de Backups](#-estructura-de-backups)
- [Restauración Inteligente](#-restauración-inteligente)
- [Ejemplos de Uso](#-ejemplos-de-uso)
- [Casos de Uso](#-casos-de-uso)
- [Troubleshooting](#-troubleshooting)

---

## 🎯 Visión General

Este sistema proporciona:

1. **Backup automático** antes de cada `supabase db reset`
2. **Separación de schema y datos** para máxima flexibilidad
3. **Restauración inteligente** que maneja cambios de schema
4. **Recuperación selectiva** de tablas específicas
5. **Historial de backups** (últimos 10 mantenidos automáticamente)

### ¿Por qué este sistema?

Cuando desarrollas y modificas el schema de la base de datos:
- **Problema**: Los backups tradicionales fallan al restaurar si el schema cambió
- **Solución**: Este sistema restaura solo los datos compatibles, ignorando conflictos

---

## 🔄 Flujo Automático de Backup

### 1. Git Hook: `.git/hooks/pre-db-reset`

Se ejecuta automáticamente **antes** de cada `supabase db reset`.

#### ¿Qué hace?

```bash
# 1. Extrae schema completo (estructura)
pg_dump --schema-only → supabase/backups/pre_reset_TIMESTAMP/schema.sql

# 2. Extrae datos con nombres de columna
pg_dump --data-only --column-inserts → supabase/backups/pre_reset_TIMESTAMP/data.sql

# 3. Genera metadata
→ supabase/backups/pre_reset_TIMESTAMP/metadata.json

# 4. Crea symlink a último backup
→ supabase/backups/latest_backup
```

#### Características del Backup

| Archivo | Contenido | Uso |
|---------|-----------|-----|
| `schema.sql` | DDL completo (CREATE, ALTER, CONSTRAINT, TRIGGER, FUNCTION, ENUM, etc.) | Referencia de estructura |
| `data.sql` | INSERT con nombres de columna explícitos | Restauración flexible |
| `metadata.json` | Estadísticas y información del backup | Información del backup |

#### ¿Por qué `--column-inserts`?

```sql
# ❌ SIN --column-inserts (falla si cambió el schema)
INSERT INTO users VALUES (1, 'john@example.com', 'John');

# ✅ CON --column-inserts (funciona aunque cambió el schema)
INSERT INTO users (user_id, email, full_name) VALUES (1, 'john@example.com', 'John')
  ON CONFLICT DO NOTHING;
```

Si después del backup:
- Se añadió columna `phone` → El INSERT funciona (usa DEFAULT o NULL)
- Se eliminó columna `middle_name` → El INSERT funciona (ignora la columna)
- Se renombró columna `full_name` → El INSERT falla solo para ese campo

---

## 📁 Estructura de Backups

```
supabase/backups/
├── pre_reset_20260324_151300/      # Backup timestamped
│   ├── schema.sql                   # 256KB - Estructura completa
│   ├── data.sql                     # 1.2MB - Datos con column-inserts
│   ├── metadata.json                # Info del backup
│   └── restore_report_*.log         # Logs de restauración (si se ejecutó)
│
├── pre_reset_20260324_143200/      # Backup anterior
│   └── ...
│
├── latest_backup → pre_reset_20260324_151300/  # Symlink al más reciente
│
└── [máximo 10 backups, los más antiguos se eliminan automáticamente]
```

### Metadata JSON

```json
{
  "backup_timestamp": "20260324_151300",
  "backup_date": "2026-03-24 15:13:00 UTC",
  "database_url": "postgresql://postgres:***@127.0.0.1:54322/postgres",
  "supabase_version": "1.x.x",
  "postgresql_version": "PostgreSQL 17.6",
  "statistics": {
    "tables": 45,
    "functions": 23,
    "triggers": 18,
    "insert_statements": 535
  },
  "files": {
    "schema": "schema.sql",
    "data": "data.sql",
    "metadata": "metadata.json"
  },
  "schemas_backed_up": ["public", "auth", "storage"],
  "backup_options": {
    "schema_backup": "full structure with CREATE statements",
    "data_backup": "column-inserts format for flexible restore",
    "compression": "none"
  }
}
```

---

## 🔧 Restauración Inteligente

### Script: `scripts/restore-data.sh`

Este script compara el backup con el schema actual y restaura solo lo que es compatible.

### Características

✅ **Análisis automático de compatibilidad**
- Detecta tablas que existen en ambos schemas
- Identifica tablas eliminadas (no restaurables)
- Identifica tablas nuevas (sin datos antiguos)

✅ **Restauración flexible**
- Usa `ON CONFLICT DO NOTHING` para evitar duplicados
- Intenta restaurar fila por fila
- Continúa aunque fallen algunas filas

✅ **Modos de operación**
- **Interactivo**: Pide confirmación
- **Dry-run**: Muestra qué se restauraría sin ejecutar
- **Selectivo**: Restaura solo tablas específicas

✅ **Reporting detallado**
- Muestra qué se restauró exitosamente
- Indica qué falló y por qué
- Genera log completo

---

## 💻 Ejemplos de Uso

### 1. Uso Básico (Restaurar Último Backup)

```bash
./scripts/restore-data.sh
```

**Output:**
```
╔════════════════════════════════════════════════════════════╗
║  📦 Intelligent Data Restore                              ║
╚════════════════════════════════════════════════════════════╝

ℹ️  Using latest backup: supabase/backups/pre_reset_20260324_151300

📁 Backup Information:
   Location: supabase/backups/pre_reset_20260324_151300
   Date: 2026-03-24 15:13:00 UTC
   Tables: 45
   Insert Statements: 535
   Data Size: 1.2M

ℹ️  Analyzing current database schema...
✅ Found 47 tables in current schema

ℹ️  Analyzing backup data...
✅ Found 45 tables in backup

ℹ️  Comparing schemas...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Schema Comparison Results:
  ✅ Restorable tables: 43 (exist in both schemas)
  ❌ Missing tables: 2 (in backup but not in current schema)
  ℹ️  New tables: 2 (in current schema but not in backup)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Tables to restore:
  • users
  • sets
  • inventory_sets
  • shipments
  ...

Proceed with restoration? (yes/no): yes

Processing table: users
  ✅ Restored 15 rows

Processing table: sets
  ✅ Restored 450 rows

...

╔════════════════════════════════════════════════════════════╗
║  ✅ Data Restoration Complete!                            ║
╚════════════════════════════════════════════════════════════╝

📊 Restoration Summary:
   • Total tables processed: 43
   • Successful: 42
   • Failed: 1
   • Total inserts attempted: 535

📄 Restore log saved to:
   supabase/backups/pre_reset_20260324_151300/restore_report_20260324_152030.log

✨ Data restoration completed successfully!
```

### 2. Dry Run (Ver qué se Restauraría)

```bash
./scripts/restore-data.sh --dry-run
```

Muestra el plan de restauración **sin ejecutar** ningún cambio.

### 3. Restaurar Backup Específico

```bash
./scripts/restore-data.sh --dir supabase/backups/pre_reset_20260324_143200
```

### 4. Restaurar Solo Tablas Específicas

```bash
# Restaurar solo usuarios y sets
./scripts/restore-data.sh -t users -t sets
```

```bash
# Con confirmación automática
./scripts/restore-data.sh -t users -t sets --yes
```

### 5. Modo No Interactivo (para Scripts)

```bash
./scripts/restore-data.sh --yes
```

---

## 🎬 Casos de Uso

### Caso 1: Desarrollo Normal

**Escenario**: Estás desarrollando y haces múltiples resets.

```bash
# 1. Trabajas en tu código, haces cambios
# ...

# 2. Reseteas la BD (backup automático se crea)
./scripts/db-reset.sh

# 3. Si necesitas recuperar datos de usuarios de prueba:
./scripts/restore-data.sh -t users --yes
```

### Caso 2: Cambio de Schema con Datos Importantes

**Escenario**: Vas a renombrar una columna pero quieres mantener datos de prueba.

```bash
# 1. Tienes datos importantes en la BD actual
# 2. Creas migración que cambia schema
# 3. Ejecutas reset (backup automático incluye los datos)
./scripts/db-reset.sh

# 4. Restauras lo que puedas (el script detecta incompatibilidades)
./scripts/restore-data.sh

# Output mostrará:
#  ✅ users: 10/10 registros restaurados
#  ⚠️  old_table: tabla no existe en schema actual
#  ⚠️  sets: 48/50 registros (columna 'old_column' no existe)
```

### Caso 3: Recuperación de Desastre

**Escenario**: Hiciste un reset accidental y necesitas recuperar datos urgentemente.

```bash
# 1. ¡Pánico! Reseteo accidental
# 2. Verifica qué backups tienes
ls -ltr supabase/backups/

# 3. Dry-run para ver qué puedes recuperar
./scripts/restore-data.sh --dry-run

# 4. Restaura todo
./scripts/restore-data.sh --yes
```

### Caso 4: Migración Parcial

**Escenario**: Quieres probar una migración pero mantener datos de ciertas tablas.

```bash
# 1. Identifica tablas críticas
# 2. Reset con backup automático
./scripts/db-reset.sh

# 3. Restaura solo lo crítico
./scripts/restore-data.sh \
  -t users \
  -t sets \
  -t inventory_sets \
  -t shipments \
  --yes
```

---

## 🔍 Troubleshooting

### Problema: "No backup directory found"

```bash
# Error
❌ No backup directory specified and no latest backup found

# Solución: Verifica que existen backups
ls supabase/backups/

# Si no hay backups, ejecuta un reset para crear uno
./scripts/db-reset.sh
```

### Problema: "Table not restorable"

```bash
# Warning durante restore
⚠️  The following tables cannot be restored (missing in current schema):
     • old_profiles
     • deprecated_orders

# Explicación: Estas tablas existían en el backup pero fueron eliminadas
# No es un error - es información de que esas tablas ya no existen
```

### Problema: Fallos Parciales en Restauración

```bash
# Output
❌ Failed to restore shipments (check column compatibility)

# Solución: Revisar el log de restauración
cat supabase/backups/latest_backup/restore_report_*.log

# El log mostrará exactamente qué columnas causaron el fallo
# Puedes:
# 1. Ignorar si son columnas deprecadas
# 2. Crear migración para renombrar/recrear columnas
# 3. Restaurar manualmente editando el data.sql
```

### Problema: Backup Hook No Se Ejecuta

```bash
# Verifica que el hook tiene permisos de ejecución
ls -l .git/hooks/pre-db-reset

# Debe mostrar: -rwxr-xr-x (la 'x' indica ejecutable)

# Si no es ejecutable:
chmod +x .git/hooks/pre-db-reset

# Reinstala hooks
./scripts/install-hooks.sh
```

### Problema: Restauración Muy Lenta

```bash
# Para tablas grandes, usa restauración selectiva
./scripts/restore-data.sh \
  -t users \
  -t inventory_sets \
  --yes

# Las tablas pequeñas se restauran rápido
# Las grandes pueden tardar según el tamaño
```

---

## 📚 Comandos de Referencia

### Backup Manual (sin reset)

```bash
# El hook solo se ejecuta en reset, pero puedes hacer backup manual:
.git/hooks/pre-db-reset
```

### Ver Contenido de un Backup

```bash
# Ver schema
less supabase/backups/latest_backup/schema.sql

# Ver datos
less supabase/backups/latest_backup/data.sql

# Ver metadata
cat supabase/backups/latest_backup/metadata.json | jq
```

### Limpiar Backups Antiguos

```bash
# El sistema mantiene automáticamente los últimos 10
# Para limpiar manualmente:
cd supabase/backups
ls -dt pre_reset_* | tail -n +6 | xargs rm -rf  # Mantiene últimos 5
```

### Comparar Schemas

```bash
# Antes de restaurar, compara schemas:
diff <(psql $DB_URL -c "\d+ public.users") \
     <(grep "CREATE TABLE public.users" supabase/backups/latest_backup/schema.sql -A 50)
```

---

## 🎓 Mejores Prácticas

1. **Antes de Cambios Grandes de Schema**
   ```bash
   # Fuerza un backup antes de cambios críticos
   .git/hooks/pre-db-reset
   ```

2. **Testing de Migraciones**
   ```bash
   # 1. Backup manual
   .git/hooks/pre-db-reset
   
   # 2. Reset y aplica migración
   ./scripts/db-reset.sh
   
   # 3. Prueba migración
   # 4. Si falla, restaura
   ./scripts/restore-data.sh --yes
   ```

3. **Documentar Cambios Incompatibles**
   - Si renombras columnas, documenta en migración
   - Facilita debugging futuro

4. **Validar Restauraciones**
   ```bash
   # Después de restaurar, verifica conteos
   psql $DB_URL -c "SELECT COUNT(*) FROM users;"
   psql $DB_URL -c "SELECT COUNT(*) FROM sets;"
   ```

---

## 🔗 Enlaces Relacionados

- [LOCAL_DEVELOPMENT.md](../docs/LOCAL_DEVELOPMENT.md) - Setup de desarrollo
- [DATABASE_SCHEMA.md](../docs/DATABASE_SCHEMA.md) - Schema de BD
- [MIGRATION_HISTORY.md](../docs/MIGRATION_HISTORY.md) - Historial de migraciones

---

**Última actualización**: 24 Marzo 2026
**Mantenedor**: Equipo Brickshare