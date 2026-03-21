# 📋 Migración: profiles → users

## 🎯 Objetivo

Consolidar toda la funcionalidad de perfiles de usuario en la tabla `users`, eliminando la tabla `profiles` para resolver conflictos que impedían guardar datos desde el frontend.

---

## ❌ Problema Original

### Síntoma
Al intentar guardar datos del perfil de usuario desde el UX, los datos no se guardaban y no aparecían errores claros.

### Causa Raíz
Existían **dos tablas conflictivas** para almacenar datos de usuario:

1. **`profiles`** - Creada por migración reciente
   - Trigger `handle_new_user()` insertaba aquí al crear usuario
   - Contenía: `referral_code`, `referred_by`, `referral_credits`
   
2. **`users`** - Sistema heredado
   - El frontend intentaba guardar datos aquí
   - NO recibía inserciones automáticas del trigger
   - **Resultado**: Datos no se guardaban

---

## ✅ Solución Implementada

### Estrategia
Migrar toda la funcionalidad de `profiles` → `users` y eliminar `profiles`.

### Archivos de Migración

#### 1. `20260321000000_migrate_profiles_to_users.sql`
Migración principal que:
- ✅ Añade campos de referrals a `users` (`referral_code`, `referred_by`, `referral_credits`)
- ✅ Migra datos existentes de `profiles` → `users`
- ✅ Actualiza trigger `handle_new_user()` para insertar en `users`
- ✅ Crea trigger `users_generate_referral_code` para auto-generar códigos
- ✅ Actualiza funciones `process_referral_credit()` e `increment_referral_credits()`
- ✅ Backfill códigos de referral para usuarios existentes
- ✅ Elimina tabla `profiles` y sus dependencias

#### 2. `20260321000001_fix_missing_triggers.sql`
Fix complementario que:
- ✅ Recrea función `set_updated_at()`
- ✅ Recrea triggers `reviews_updated_at` y `referrals_updated_at`
- ✅ Sincroniza usuarios de `auth.users` → `users` si faltaban

---

## 📊 Cambios en el Schema

### Tabla `users` - Campos Añadidos

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `referral_code` | TEXT | Código único de 6 caracteres para compartir |
| `referred_by` | UUID | ID del usuario que hizo la referencia |
| `referral_credits` | INTEGER | Créditos acumulados por referidos exitosos |

### Funciones Actualizadas

- `handle_new_user()` - Ahora inserta en `users` en lugar de `profiles`
- `generate_referral_code_users()` - Nueva función para auto-generar códigos
- `process_referral_credit()` - Actualiza `users` en lugar de `profiles`
- `increment_referral_credits()` - Actualiza `users` en lugar de `profiles`

### Tabla Eliminada

- ❌ `profiles` - Completamente eliminada

---

## 🔄 Flujo de Creación de Usuario

### Antes (INCORRECTO)
```
1. Usuario se registra
2. auth.users → INSERT
3. Trigger on_auth_user_created → handle_new_user()
4. profiles → INSERT ✅
5. users → NO INSERT ❌
6. Frontend intenta guardar en users → FALLA ❌
```

### Ahora (CORRECTO)
```
1. Usuario se registra
2. auth.users → INSERT
3. Trigger on_auth_user_created → handle_new_user()
4. users → INSERT ✅
5. Trigger users_generate_referral_code → referral_code auto-generado ✅
6. Frontend guarda en users → ÉXITO ✅
```

---

## 🧪 Verificación

### Comandos de Verificación

```sql
-- 1. Verificar que profiles NO existe
SELECT COUNT(*) FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name = 'profiles';
-- Debe retornar: 0

-- 2. Verificar campos en users
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'users' AND table_schema = 'public'
  AND column_name IN ('referral_code', 'referred_by', 'referral_credits');

-- 3. Verificar trigger en auth.users
SELECT trigger_name, event_manipulation, action_statement
FROM information_schema.triggers
WHERE event_object_schema = 'auth' AND event_object_table = 'users';
-- Debe mostrar: on_auth_user_created → handle_new_user()

-- 4. Verificar usuarios con referral_code
SELECT user_id, email, referral_code, referral_credits 
FROM public.users;
-- Todos los usuarios deben tener un referral_code
```

---

## 🚀 Ejecución de la Migración

### En Local (Supabase CLI)
```bash
# Las migraciones se ejecutan automáticamente con:
supabase db reset

# O manualmente:
psql $DATABASE_URL -f supabase/migrations/20260321000000_migrate_profiles_to_users.sql
psql $DATABASE_URL -f supabase/migrations/20260321000001_fix_missing_triggers.sql
```

### En Producción
```bash
# Push a producción
supabase db reset
```

---

## ⚠️ Consideraciones

### Impacto en Frontend
- ✅ **NO requiere cambios** - El frontend ya usaba la tabla `users`
- ✅ Los campos de dirección, teléfono, etc. siguen en `users`
- ✅ Ahora funciona correctamente al guardar datos

### Impacto en Sistema de Referrals
- ✅ Sistema de referrals **migrado completamente** a `users`
- ✅ Códigos existentes preservados
- ✅ Nuevos usuarios reciben código automáticamente

### Compatibilidad
- ✅ Totalmente compatible con código existente
- ✅ Sin breaking changes en APIs
- ✅ Políticas RLS actualizadas

---

## 📝 Notas Adicionales

### Por qué se eliminó `profiles`
La tabla `profiles` seguía el patrón estándar de Supabase (`id = auth.uid()`), pero en este proyecto ya existía `users` con una estructura diferente (`user_id → auth.uid()`). Mantener ambas causaba:
- Confusión sobre dónde guardar datos
- Duplicación de información
- Errores silenciosos al guardar desde frontend

### Por qué se eligió `users` sobre `profiles`
1. **Código legacy** - Toda la lógica existente ya usaba `users`
2. **Menos cambios** - Solo añadir campos vs reescribir todo
3. **Compatibilidad** - Frontend y backend ya apuntaban a `users`

---

## 🔗 Referencias

- Migración principal: `supabase/migrations/20260321000000_migrate_profiles_to_users.sql`
- Fix de triggers: `supabase/migrations/20260321000001_fix_missing_triggers.sql`
- Schema actualizado: `docs/DATABASE_SCHEMA.md`

---

**Fecha de creación**: 2026-03-21  
**Autor**: Sistema Cline  
**Estado**: ✅ Completada y verificada