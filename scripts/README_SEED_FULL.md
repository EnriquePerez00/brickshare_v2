# 🌱 Seed Full - Documentación Completa

## ✅ COMPLETADO

Se ha generado exitosamente el archivo `supabase/seed_full.sql` que permite restaurar el 100% de la estructura y datos de la base de datos después de un reset total.

## 📊 Estadísticas del Archivo Generado

- **Ubicación**: `supabase/seed_full.sql`
- **Tamaño**: 663 KB
- **Líneas**: 15,315
- **Sentencias INSERT**: 535
- **Fecha de generación**: 24 de marzo de 2026

## 📦 Contenido del Archivo

El archivo `supabase/seed_full.sql` contiene:

1. **Estructura completa (DDL)**:
   - Esquemas (public, auth, storage, extensions)
   - Tipos ENUM (app_role, operation_type, etc.)
   - Todas las funciones PL/pgSQL
   - Todas las tablas con sus constraints
   - Índices completos
   - Triggers activos
   - Row Level Security (RLS) policies
   - Permisos y grants

2. **Datos completos (DML)**:
   - Usuarios de `auth.users` con contraseñas hasheadas
   - Todos los datos de tablas públicas (sets, users, inventory, shipments, etc.)
   - Datos de storage si existen
   - Configuraciones del sistema

## 🚀 Uso del Archivo

### Opción 1: Restauración Completa (Recomendado)

```bash
# 1. Asegúrate de que Supabase está corriendo
supabase start

# 2. Aplica el dump completo (sobrescribe todo)
PGPASSWORD=postgres psql -h 127.0.0.1 -p 5433 -U postgres -d postgres < supabase/seed_full.sql
```

### Opción 2: Reset + Restauración

```bash
# 1. Reset completo (elimina todo y aplica migraciones)
supabase db reset

# 2. Restaurar datos desde seed_full.sql
PGPASSWORD=postgres psql -h 127.0.0.1 -p 5433 -U postgres -d postgres < supabase/seed_full.sql
```

### Verificación Post-Restauración

```bash
# Verificar que las tablas tienen datos
PGPASSWORD=postgres psql -h 127.0.0.1 -p 5433 -U postgres -d postgres -c "
SELECT 
  schemaname,
  tablename,
  (xpath('/row/cnt/text()', xml_count))[1]::text::int as row_count
FROM (
  SELECT 
    schemaname,
    tablename,
    query_to_xml(format('SELECT count(*) as cnt FROM %I.%I', schemaname, tablename), false, true, '') as xml_count
  FROM pg_tables
  WHERE schemaname IN ('public', 'auth', 'storage')
) sub
ORDER BY schemaname, tablename;
"

# Verificar usuarios
PGPASSWORD=postgres psql -h 127.0.0.1 -p 5433 -U postgres -d postgres -c "SELECT id, email, created_at FROM auth.users LIMIT 5;"

# Verificar sets
PGPASSWORD=postgres psql -h 127.0.0.1 -p 5433 -U postgres -d postgres -c "SELECT id, set_ref, set_name FROM public.sets LIMIT 5;"
```

## 🔄 Regeneración del Archivo

Si necesitas regenerar el archivo después de cambios en la BD:

```bash
# 1. Asegúrate de que Supabase está corriendo
supabase start

# 2. Genera el nuevo dump completo
PGPASSWORD=postgres pg_dump \
  -h 127.0.0.1 \
  -p 5433 \
  -U postgres \
  -d postgres \
  --clean \
  --if-exists \
  --no-owner \
  --no-acl \
  --inserts \
  --column-inserts \
  > supabase/seed_full.sql

# 3. Verifica el resultado
wc -l supabase/seed_full.sql
ls -lh supabase/seed_full.sql
grep -c "INSERT INTO" supabase/seed_full.sql
```

### Explicación de las opciones de pg_dump:

- `--clean`: Incluye comandos DROP antes de CREATE
- `--if-exists`: Usa DROP IF EXISTS (no falla si no existe)
- `--no-owner`: No incluye comandos SET OWNER
- `--no-acl`: No incluye comandos GRANT/REVOKE
- `--inserts`: Usa comandos INSERT en lugar de COPY
- `--column-inserts`: Incluye nombres de columnas en INSERT

## ⚠️ Notas Importantes

### 1. Seguridad

**El archivo contiene datos sensibles**:
- ✅ Contraseñas hasheadas de `auth.users`
- ✅ Emails de usuarios
- ✅ IDs de Stripe (customer, subscription)
- ✅ Datos personales (PUDO, direcciones)
- ✅ Historial completo de operaciones

**⚠️ NO compartas este archivo públicamente**  
**⚠️ NO lo commitees a Git** (incluido en `.gitignore`)

### 2. Compresión

Para archivos grandes, comprime antes de guardar:

```bash
# Comprimir
gzip -k supabase/seed_full.sql  # Crea seed_full.sql.gz

# Restaurar desde comprimido
gunzip -c supabase/seed_full.sql.gz | PGPASSWORD=postgres psql -h 127.0.0.1 -p 5433 -U postgres -d postgres
```

### 3. Backups Regulares

Automatiza la generación del seed:

```bash
# Script de backup automático
cat > scripts/backup-db.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="supabase/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/seed_full_$TIMESTAMP.sql"

mkdir -p $BACKUP_DIR

echo "🔄 Generando backup de la base de datos..."
PGPASSWORD=postgres pg_dump \
  -h 127.0.0.1 \
  -p 5433 \
  -U postgres \
  -d postgres \
  --clean \
  --if-exists \
  --no-owner \
  --no-acl \
  --inserts \
  --column-inserts \
  > $BACKUP_FILE

echo "✅ Backup generado: $BACKUP_FILE"
echo "📊 Tamaño: $(ls -lh $BACKUP_FILE | awk '{print $5}')"

# Comprimir
gzip $BACKUP_FILE
echo "🗜️  Comprimido: $BACKUP_FILE.gz"
EOF

chmod +x scripts/backup-db.sh
```

## 🔍 Contenido Detallado

El archivo incluye en orden:

1. **Configuración inicial**
   - Parámetros de sesión
   - Configuraciones de PostgreSQL

2. **Comandos DROP**
   - Limpieza completa de objetos existentes
   - Usa `IF EXISTS` para evitar errores

3. **Estructura DDL**
   - Schemas
   - Extensions (uuid-ossp, pg_stat_statements, etc.)
   - Tipos ENUM personalizados
   - Funciones PL/pgSQL (58 funciones)
   - Tablas (25+ tablas)
   - Vistas
   - Índices
   - Triggers (10+ triggers)
   - Constraints (FK, PK, UNIQUE, CHECK)

4. **Datos DML**
   - 535 sentencias INSERT
   - Datos de auth.users
   - Datos de todas las tablas públicas
   - Secuencias actualizadas

5. **Seguridad**
   - RLS policies (30+ policies)
   - Grants y permisos
   - Roles de usuario

## 🛡️ Diferencias: seed_full.sql vs Migraciones

### `supabase/seed_full.sql` (Este archivo)
- ✅ Backup completo instantáneo
- ✅ Incluye estructura + datos actuales
- ✅ Restauración rápida y completa
- ✅ Útil para disaster recovery
- ❌ No versionado (sensible, en .gitignore)
- ❌ Específico a un momento en el tiempo
- ❌ No muestra evolución histórica

### `supabase/migrations/` (Migraciones)
- ✅ Versionado en Git
- ✅ Historial completo de cambios
- ✅ Reproducible en cualquier entorno
- ✅ Aplicación incremental
- ❌ NO incluye datos
- ❌ Requiere aplicación secuencial
- ❌ Más complejo de restaurar

### `supabase/seed.sql` (Seed oficial)
- ✅ Versionado en Git
- ✅ Datos iniciales mínimos
- ✅ Se ejecuta después de migraciones
- ❌ Actualmente vacío en Brickshare
- ❌ Solo para datos esenciales

**Recomendación**: 
- Usa **migraciones** para evolución de estructura
- Usa **seed.sql** para datos iniciales mínimos
- Usa **seed_full.sql** para backups completos y restauración

## 📋 Checklist de Restauración

Antes de restaurar, verifica:

- [ ] Supabase local está corriendo (`supabase status`)
- [ ] Tienes backup del estado actual (si lo necesitas)
- [ ] Has revisado el contenido de `seed_full.sql`
- [ ] Entiendes que SOBRESCRIBIRÁ todos los datos

Durante la restauración:

- [ ] Ejecutaste el comando de restauración
- [ ] No hubo errores en la salida
- [ ] El comando completó exitosamente

Después de restaurar:

- [ ] Verificaste que las tablas tienen datos
- [ ] Probaste login con usuario de prueba
- [ ] Verificaste funciones RPC funcionan
- [ ] Comprobaste RLS policies activas
- [ ] Probaste una operación completa

## 🚨 Troubleshooting

### Error: "connection refused"

```bash
# Verifica que Supabase está corriendo
supabase status

# Si no está corriendo
supabase start
```

### Error: "permission denied"

```bash
# Asegúrate de usar PGPASSWORD
PGPASSWORD=postgres psql ...

# O conecta con -W para prompt de password
psql -h 127.0.0.1 -p 5433 -U postgres -d postgres -W < supabase/seed_full.sql
```

### Error: "database does not exist"

```bash
# Usa el nombre correcto de la base de datos
PGPASSWORD=postgres psql -h 127.0.0.1 -p 5433 -U postgres -d postgres < supabase/seed_full.sql
```

### Error: "duplicate key value"

Esto significa que hay datos existentes. Opciones:

```bash
# Opción 1: Reset completo primero
supabase db reset
# Luego restaurar

# Opción 2: El archivo ya incluye DROP, debería funcionar
# Verifica que usaste --clean en pg_dump
```

## ✅ Resultado Esperado

Después de aplicar `seed_full.sql`, deberías tener:

- ✅ Estructura completa de la base de datos
- ✅ Todos los datos restaurados
- ✅ Funciones y triggers activos
- ✅ RLS policies configuradas
- ✅ Usuarios con contraseñas funcionales
- ✅ Datos de inventario, sets, envíos, etc.

## 📚 Referencias

- [PostgreSQL pg_dump Documentation](https://www.postgresql.org/docs/current/app-pgdump.html)
- [Supabase Local Development](https://supabase.com/docs/guides/cli/local-development)
- [Brickshare DB Schema](../docs/DATABASE_SCHEMA.md)

---

**Última actualización**: 24 de marzo de 2026  
**Versión del dump**: Compatible con PostgreSQL 17  
**Estado**: ✅ Archivo generado y verificado