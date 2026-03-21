#!/bin/bash

echo "📊 Actualizando documentación del esquema..."

# Verificar que Supabase está corriendo
if ! docker ps 2>/dev/null | grep -q "supabase"; then
    echo "⚠️  Supabase no está corriendo localmente. Saltando actualización de documentación."
    echo "   Para generar la documentación, ejecuta: supabase start"
    exit 0
fi

# Generar dump SQL del esquema
echo "  → Generando dump SQL..."
supabase db dump --local --schema public --file docs/schema_dump.sql 2>/dev/null

# Generar documentación Markdown
echo "  → Generando documentación Markdown..."
psql "postgresql://postgres:postgres@localhost:54322/postgres" > docs/DATABASE_SCHEMA.md 2>/dev/null << 'EOSQL'
\pset tuples_only on
\pset format unaligned

\echo '# 📊 Esquema de Base de Datos - Brickshare'
\echo ''
\o /dev/null
SELECT 'Generado automáticamente el: ' || to_char(now(), 'YYYY-MM-DD HH24:MI:SS');
\o
\echo ''
\echo '---'
\echo ''
\echo '## 📋 Índice'
\echo ''
\echo '- [Tablas](#tablas)'
\echo '- [Funciones RPC](#funciones-rpc)'
\echo '- [Triggers](#triggers)'
\echo '- [Políticas RLS](#políticas-rls)'
\echo ''
\echo '---'
\echo ''
\echo '## 📋 Tablas'
\echo ''

-- Generar documentación de tablas
SELECT 
    '### ' || t.table_name || E'\n' ||
    E'\n' ||
    COALESCE('**Descripción**: ' || pgd.description || E'\n\n', '') ||
    '| Campo | Tipo | Nulo | Default | Descripción |' || E'\n' ||
    '|-------|------|------|---------|-------------|' || E'\n' ||
    string_agg(
        '| `' || c.column_name || 
        '` | ' || c.data_type || 
        CASE 
            WHEN c.character_maximum_length IS NOT NULL 
            THEN '(' || c.character_maximum_length || ')' 
            WHEN c.data_type = 'numeric' AND c.numeric_precision IS NOT NULL
            THEN '(' || c.numeric_precision || ',' || COALESCE(c.numeric_scale::text, '0') || ')'
            ELSE '' 
        END ||
        ' | ' || CASE WHEN c.is_nullable = 'YES' THEN '✓' ELSE '✗' END || 
        ' | ' || COALESCE('`' || substring(c.column_default from 1 for 50) || 
                         CASE WHEN length(c.column_default) > 50 THEN '...' ELSE '' END || '`', '-') || 
        ' | ' || COALESCE(pgcd.description, '-') || ' |'
    , E'\n' ORDER BY c.ordinal_position) || E'\n\n'
FROM information_schema.tables t
JOIN information_schema.columns c 
    ON t.table_name = c.table_name 
    AND t.table_schema = c.table_schema
LEFT JOIN pg_catalog.pg_class pc 
    ON pc.relname = t.table_name
LEFT JOIN pg_catalog.pg_namespace pn
    ON pn.oid = pc.relnamespace
    AND pn.nspname = t.table_schema
LEFT JOIN pg_catalog.pg_description pgd 
    ON pgd.objoid = pc.oid 
    AND pgd.objsubid = 0
LEFT JOIN pg_catalog.pg_description pgcd 
    ON pgcd.objoid = pc.oid 
    AND pgcd.objsubid = c.ordinal_position
WHERE t.table_schema = 'public'
    AND t.table_type = 'BASE TABLE'
GROUP BY t.table_name, pgd.description
ORDER BY t.table_name;

\echo ''
\echo '---'
\echo ''
\echo '## ⚙️ Funciones RPC'
\echo ''

-- Generar documentación de funciones
SELECT 
    '### `' || p.proname || '`' || E'\n' ||
    E'\n' ||
    COALESCE('**Descripción**: ' || d.description || E'\n\n', '') ||
    '**Parámetros**: ' || 
    CASE 
        WHEN pg_get_function_arguments(p.oid) = '' 
        THEN 'Ninguno' 
        ELSE '`' || pg_get_function_arguments(p.oid) || '`' 
    END || E'\n' ||
    '**Retorna**: `' || pg_get_function_result(p.oid) || '`' || E'\n' ||
    E'\n'
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
LEFT JOIN pg_description d ON d.objoid = p.oid
WHERE n.nspname = 'public'
    AND p.prokind = 'f'
ORDER BY p.proname;

\echo ''
\echo '---'
\echo ''
\echo '## 🔔 Triggers'
\echo ''

-- Generar documentación de triggers
SELECT 
    '### ' || event_object_table || E'\n' ||
    E'\n' ||
    string_agg(
        '- **' || trigger_name || '**' || E'\n' ||
        '  - Evento: ' || event_manipulation || E'\n' ||
        '  - Timing: ' || action_timing || E'\n' ||
        '  - Función: `' || action_statement || '`'
    , E'\n\n') || E'\n\n'
FROM information_schema.triggers
WHERE trigger_schema = 'public'
GROUP BY event_object_table
ORDER BY event_object_table;

\echo ''
\echo '---'
\echo ''
\echo '## 🔒 Políticas RLS (Row Level Security)'
\echo ''

-- Generar documentación de políticas RLS
SELECT 
    '### Tabla: `' || tablename || '`' || E'\n' ||
    E'\n' ||
    string_agg(
        '- **' || policyname || '**' || E'\n' ||
        '  - Comando: `' || cmd || '`' || E'\n' ||
        '  - Roles: ' || COALESCE(array_to_string(roles, ', '), 'public') || E'\n' ||
        '  - Usando: `' || COALESCE(qual, 'true') || '`' || E'\n' ||
        CASE WHEN with_check IS NOT NULL 
             THEN '  - With check: `' || with_check || '`' 
             ELSE '' 
        END
    , E'\n\n') || E'\n\n'
FROM pg_policies
WHERE schemaname = 'public'
GROUP BY tablename
ORDER BY tablename;

\echo ''
\echo '---'
\echo ''
\o /dev/null
SELECT '*Última actualización: ' || to_char(now(), 'YYYY-MM-DD HH24:MI:SS') || '*';
\o

EOSQL

if [ $? -eq 0 ]; then
    echo "✅ Documentación actualizada en docs/DATABASE_SCHEMA.md"
    echo "✅ Dump SQL generado en docs/schema_dump.sql"
else
    echo "❌ Error al generar la documentación"
    exit 1
fi