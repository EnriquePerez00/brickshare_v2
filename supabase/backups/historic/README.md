# 📦 Archivos Históricos de Seeds

Este directorio contiene archivos de seed históricos que **NO deben ser utilizados** en la base de datos actual debido a incompatibilidades estructurales.

---

## ⚠️ ADVERTENCIA IMPORTANTE

**NO aplicar estos archivos directamente a la base de datos**

Estos archivos contienen referencias a estructuras obsoletas que fueron eliminadas o refactorizadas en migraciones posteriores. Intentar aplicarlos puede causar:
- ❌ Errores de referencia a tablas inexistentes
- ❌ Corrupción de datos correctamente migrados
- ❌ Inconsistencias en relaciones entre tablas

---

## 📋 Archivos en este Directorio

### `seed_full.sql.historic`
**Origen:** Dump de datos de producción (pre-enero 2026)  
**Estado:** OBSOLETO - Incompatible con esquema actual  
**Tamaño:** ~3000 líneas

**Problemas identificados:**
- 82 referencias a tabla `orders` (eliminada en migración `20260130220000_refactor_envios_remove_orders.sql`)
- Referencias a funciones RPC que no existen en migraciones actuales
- Referencias a tablas de chat eliminadas en refactor global

**Datos migrados correctamente:**
- ✅ Datos de `orders` → migrados a `shipments.set_id` y `shipments.set_ref`
- ✅ Datos de `profiles` → migrados a `users`

### `seed_clean.sql.historic`
**Origen:** Versión procesada de `seed_full.sql` con limpieza Python  
**Estado:** PARCIALMENTE LIMPIO - Aún contiene conflictos  

**Procesamiento realizado:**
- ✅ Eliminadas 82 referencias a tabla `orders`
- ✅ Eliminadas funciones RPC obsoletas
- ⚠️ Persisten conflictos con funciones sin implementación actual

---

## 📚 Documentación Relacionada

Para entender el proceso completo de análisis y las decisiones tomadas, consultar:

1. **`scripts/SEED_FULL_ANALYSIS.md`**
   - Análisis detallado de todas las referencias obsoletas
   - Comparación con esquema actual
   - Identificación de conflictos específicos

2. **`scripts/SEED_RECOVERY_GUIDE.md`**
   - Guía paso a paso del intento de recuperación
   - Proceso de limpieza ejecutado
   - Resultados de verificación

3. **`scripts/SEED_RECOVERY_FINAL_SUMMARY.md`**
   - Resumen ejecutivo del proceso completo
   - Conclusiones y decisiones estratégicas
   - Recomendaciones para el camino adelante

---

## 🚀 ¿Qué Usar en su Lugar?

### Para Desarrollo Local

```bash
# Opción 1: Seed minimalista actual (RECOMENDADO)
supabase db reset
# Aplica todas las migraciones + supabase/seed.sql
```

### Para Datos de Prueba Específicos

```bash
# Usuario admin de prueba
psql postgresql://postgres:postgres@127.0.0.1:5433/postgres < scripts/create-enrique-test-user.sql

# Sets LEGO desde API BrickSet (datos reales actualizados)
npm run seed:sets-brickset
```

### Para Staging/Pre-producción

```bash
# Exportar datos actuales de producción
pg_dump --data-only \
  --table=sets \
  --table=users \
  --table=inventory_sets \
  --table=shipments \
  --table=wishlist \
  postgresql://[PRODUCTION_URL] > supabase/seed_new.sql

# Aplicar en staging
psql postgresql://[STAGING_URL] < supabase/seed_new.sql
```

---

## 🔍 Por Qué Estos Archivos Son Históricos

### Evolución del Esquema

El proyecto Brickshare ha experimentado refactors significativos desde enero 2026:

1. **Eliminación de tabla `orders`** (20260130220000)
   - Consolidación en tabla `shipments`
   - Nuevo diseño de tracking de envíos

2. **Migración `profiles` → `users`** (20260321000001)
   - Unificación de datos de usuario
   - Nueva estructura de campos

3. **Refactor del sistema PUDO** (20260324095000)
   - Nueva tabla `users_correos_dropping`
   - Integración mejorada con API Correos

4. **Funciones RPC rediseñadas**
   - `assign_sets_to_users()` → `preview_assign_sets_to_users()` + `confirm_assign_sets_to_users()`
   - Nuevo flujo de asignación en dos pasos

### Decisión Estratégica

**Se decidió NO intentar recuperar estos seeds históricos** porque:

1. Los datos relevantes ya fueron migrados correctamente a través de migraciones SQL
2. Las funciones RPC referenciadas no existen en el diseño actual
3. El riesgo de corrupción de datos supera los beneficios potenciales
4. Existen alternativas mejores y más seguras para poblar datos de prueba

---

## 📊 Verificación de Estado Actual

Para verificar que la base de datos actual está correctamente estructurada:

```bash
# Verificar tablas principales
psql postgresql://postgres:postgres@127.0.0.1:5433/postgres -c "
SELECT 
  table_name,
  (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as columnas
FROM information_schema.tables t
WHERE table_schema = 'public' 
  AND table_type = 'BASE TABLE'
ORDER BY table_name;
"

# Verificar funciones RPC
psql postgresql://postgres:postgres@127.0.0.1:5433/postgres -c "
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
ORDER BY routine_name;
"
```

---

## 🎓 Lecciones Aprendidas

1. **Mantener seeds actualizados con el esquema**
   - Los seeds históricos se vuelven obsoletos rápidamente
   - Importante sincronizar seeds con cambios de migraciones

2. **Seeds minimalistas > Seeds masivos**
   - Más fáciles de mantener
   - Menos propensos a conflictos
   - Más rápidos de aplicar

3. **Documentar decisiones de refactor**
   - Facilita entender por qué ciertos seeds son obsoletos
   - Ayuda en futuras migraciones

4. **Usar APIs para datos frescos**
   - Datos de BrickSet/Rebrickable siempre actualizados
   - Reproducibles y versionables
   - No requieren mantenimiento manual

---

## 📅 Historial

| Fecha | Acción | Motivo |
|---|---|---|
| 24/03/2026 | Archivado como histórico | Incompatibilidad con esquema actual post-refactor |
| Enero 2026 | Refactor global | Eliminación tabla orders, nuevas funciones RPC |
| Pre-2026 | Generado seed_full.sql | Dump de datos de producción |

---

**Última actualización:** 24 de marzo de 2026  
**Mantenedor:** Equipo Brickshare