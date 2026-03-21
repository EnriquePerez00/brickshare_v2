# 📜 Scripts de Brickshare

Este directorio contiene scripts de utilidad para el mantenimiento y gestión del proyecto Brickshare.

## 📋 Índice

- [Documentación de Esquema](#documentación-de-esquema)
- [Gestión de Migraciones](#gestión-de-migraciones)
- [Datos de Prueba](#datos-de-prueba)
- [Git Hooks](#git-hooks)

---

## 📊 Documentación de Esquema

### `update-schema-docs.sh`

**Propósito**: Genera automáticamente documentación del esquema de base de datos en formato Markdown.

**Uso**:
```bash
bash scripts/update-schema-docs.sh
```

**Requisitos**:
- Supabase debe estar corriendo localmente (`supabase start`)
- PostgreSQL client (`psql`) instalado

**Genera**:
- `docs/DATABASE_SCHEMA.md` - Documentación legible con tablas, funciones, triggers y políticas RLS
- `docs/schema_dump.sql` - Dump SQL completo del esquema

**Características**:
- Detecta automáticamente si Supabase está corriendo
- Extrae comentarios de tablas y columnas
- Documenta funciones RPC con parámetros y tipos de retorno
- Lista todos los triggers con sus eventos
- Detalla políticas RLS (Row Level Security)

**Ejecución automática**:
Este script se ejecuta automáticamente cuando:
1. Haces commit de una migración (vía hook pre-commit)
2. Se detectan cambios en `supabase/migrations/`

---

## 🔧 Git Hooks

### `install-hooks.sh`

**Propósito**: Instala hooks de Git para automatizar la actualización de documentación.

**Uso**:
```bash
bash scripts/install-hooks.sh
```

**Qué hace**:
1. Verifica que estás en un repositorio Git
2. Pregunta si quieres sobrescribir hooks existentes
3. Crea el hook `pre-commit` que:
   - Detecta commits con migraciones
   - Ejecuta `update-schema-docs.sh`
   - Añade la documentación actualizada al commit

**Flujo de trabajo**:
```bash
# 1. Instalar hooks (una sola vez)
bash scripts/install-hooks.sh

# 2. Crear migración
supabase migration new add_new_table

# 3. Editar la migración
vim supabase/migrations/XXXXXX_add_new_table.sql

# 4. Hacer commit (el hook se ejecuta automáticamente)
git add supabase/migrations/XXXXXX_add_new_table.sql
git commit -m "feat: add new table"
# → El hook actualiza docs/DATABASE_SCHEMA.md automáticamente
# → El archivo actualizado se añade al commit
```

**Desinstalar**:
```bash
rm .git/hooks/pre-commit
```

---

## 🗄️ Gestión de Migraciones

### `repair-migration-history.sh`

**Propósito**: Repara el historial de migraciones cuando hay discrepancias entre local y remoto.

**Uso**:
```bash
bash scripts/repair-migration-history.sh
```

**Cuándo usar**:
- Después de clonar el repositorio
- Cuando `supabase migration list` muestra migraciones locales no aplicadas remotamente
- Para sincronizar el historial de migraciones

**Qué hace**:
- Marca todas las migraciones locales como aplicadas en el remoto
- No ejecuta las migraciones (solo actualiza el registro)
- Útil cuando las migraciones ya están aplicadas pero no registradas

### `verify-supabase-cli.sh`

**Propósito**: Verifica la instalación y configuración del CLI de Supabase.

**Uso**:
```bash
bash scripts/verify-supabase-cli.sh
```

**Verifica**:
- Instalación de Supabase CLI
- Autenticación
- Vinculación del proyecto
- Permisos de acceso

---

## 🧪 Datos de Prueba

### `reset-test-data.sql`

**Propósito**: Resetea la base de datos a un estado conocido con datos de prueba.

**Uso**:
```sql
-- Desde psql
\i scripts/reset-test-data.sql

-- O con supabase CLI
psql "postgresql://postgres:postgres@localhost:54322/postgres" < scripts/reset-test-data.sql
```

**⚠️ ADVERTENCIA**: Este script elimina TODOS los datos existentes.

**Qué incluye**:
- Usuarios de prueba
- Sets LEGO de ejemplo
- Inventario de muestra
- Envíos de prueba
- Datos para testing

**Ver también**: `README_RESET_TEST_DATA.md` para más detalles.

---

## 🚀 Flujo de Trabajo Recomendado

### Desarrollo de una nueva feature con migración

```bash
# 1. Crear rama de feature
git checkout -b feature/new-table

# 2. Crear migración
supabase migration new add_new_table

# 3. Editar migración con comentarios descriptivos
cat > supabase/migrations/XXXXXX_add_new_table.sql << 'EOF'
-- Crear tabla de ejemplo
CREATE TABLE public.example (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL,
    created_at timestamptz DEFAULT now()
);

-- Añadir comentarios para documentación automática
COMMENT ON TABLE public.example IS 'Tabla de ejemplo para demostración';
COMMENT ON COLUMN public.example.id IS 'ID único auto-generado';
COMMENT ON COLUMN public.example.name IS 'Nombre del ejemplo';
COMMENT ON COLUMN public.example.created_at IS 'Fecha de creación';

-- Habilitar RLS
ALTER TABLE public.example ENABLE ROW LEVEL SECURITY;

-- Política de lectura pública
CREATE POLICY "Example: Anyone can read"
    ON public.example FOR SELECT
    USING (true);
EOF

# 4. Aplicar migración localmente
supabase db reset

# 5. Verificar en Studio
open http://localhost:54323

# 6. Commit (el hook genera la documentación automáticamente)
git add supabase/migrations/XXXXXX_add_new_table.sql
git commit -m "feat: add example table"
# → docs/DATABASE_SCHEMA.md se actualiza automáticamente

# 7. Revisar documentación generada
cat docs/DATABASE_SCHEMA.md

# 8. Push
git push origin feature/new-table
```

### Actualización manual de documentación

Si necesitas actualizar la documentación sin hacer commit:

```bash
# 1. Asegurar que Supabase está corriendo
supabase start

# 2. Ejecutar script manualmente
bash scripts/update-schema-docs.sh

# 3. Revisar cambios
git diff docs/DATABASE_SCHEMA.md
```

---

## 📝 Mejores Prácticas

### Comentarios en Migraciones

Siempre añade comentarios SQL para mejorar la documentación automática:

```sql
-- ✅ BUENO: Comentarios detallados
COMMENT ON TABLE public.users IS 'Tabla principal de usuarios registrados en Brickshare';
COMMENT ON COLUMN public.users.email IS 'Email único del usuario (usado para login)';

-- ❌ MALO: Sin comentarios
CREATE TABLE public.users (email text);
```

### Nombres Descriptivos

Usa nombres claros y auto-explicativos:

```sql
-- ✅ BUENO
CREATE TABLE envios (
    id bigint,
    user_id bigint,
    estado_envio text
);

-- ❌ MALO
CREATE TABLE e (
    i bigint,
    u bigint,
    s text
);
```

### Políticas RLS Documentadas

Nombra las políticas de forma descriptiva:

```sql
-- ✅ BUENO
CREATE POLICY "Users: Can read own profile"
    ON public.users FOR SELECT
    USING (auth.uid() = id);

-- ❌ MALO
CREATE POLICY "policy_1"
    ON public.users FOR SELECT
    USING (auth.uid() = id);
```

---

## 🔍 Troubleshooting

### "Supabase no está corriendo"

```bash
# Iniciar Supabase
supabase start

# Verificar status
docker ps | grep supabase
```

### "psql: command not found"

```bash
# macOS
brew install postgresql

# Linux (Ubuntu/Debian)
sudo apt-get install postgresql-client
```

### "Permission denied"

```bash
# Dar permisos de ejecución
chmod +x scripts/*.sh
```

### El hook no se ejecuta

```bash
# Reinstalar hooks
bash scripts/install-hooks.sh

# Verificar permisos
ls -la .git/hooks/pre-commit
# Debe mostrar: -rwxr-xr-x
```

### Documentación desactualizada

```bash
# Forzar regeneración
bash scripts/update-schema-docs.sh

# Añadir al último commit
git add docs/DATABASE_SCHEMA.md docs/schema_dump.sql
git commit --amend --no-edit
```

---

## 📚 Recursos Adicionales

- [Supabase CLI Documentation](https://supabase.com/docs/guides/cli)
- [PostgreSQL COMMENT](https://www.postgresql.org/docs/current/sql-comment.html)
- [Git Hooks](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks)
- [Row Level Security (RLS)](https://supabase.com/docs/guides/auth/row-level-security)

---

**Última actualización**: 2026-03-21  
**Mantenido por**: Equipo Brickshare