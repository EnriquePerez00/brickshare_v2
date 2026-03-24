# 📚 Guía de Recuperación de Datos desde seed_full.sql

## ✅ Problemas Identificados y Soluciones

### 🔴 CRÍTICO: Incompatibilidades del Schema

#### 1. Tabla `orders` (ELIMINADA)
- **Problema**: `seed_full.sql` contiene 82 referencias a la tabla `orders`
- **Solución**: Esta tabla fue eliminada en migración `20260130220000_refactor_envios_remove_orders.sql`
- **Acción**: Datos ya migrados a `shipments.set_id` - **NO RECUPERAR**

#### 2. Funciones RPC Obsoletas
```sql
-- OBSOLETAS (no recuperar):
- assign_sets_to_users()
- handle_envio_entregado()
- handle_return_status_update()
```
- **Reemplazadas por**: Nuevas funciones en migraciones recientes
- **Acción**: **IGNORAR** del seed

#### 3. Tablas Chat (ELIMINADAS)
- Eliminadas en: `20260325000000_remove_chatbot_tables.sql`
- **Acción**: **NO RECUPERAR**

### 🟡 ADVERTENCIA: Datos Duplicados

#### 4. Usuarios de Test
El `seed_full.sql` contiene 3 usuarios:
- `user@brickshare.com` (UUID: c1e75904-1019-4dc7-97eb-80e1c7b4209e)
- `admin@brickshare.com` (UUID: a8aed17c-5256-46b4-a6b0-fafa83ab1a8d)  
- `enriquepeto@yahoo.es` (UUID: 5a0d2970-95a6-46cf-922c-76eea4830913)

**Problema**: Ya existen en la BD actual tras `db:reset`
**Solución**: Usar `ON CONFLICT DO NOTHING` o eliminar sección de auth

### 🟢 RECUPERABLE: Datos Válidos

#### Tablas Core (SIN conflictos)
✅ **Sets**: 29 sets LEGO con datos completos
✅ **Inventory**: Stock y tracking de inventario  
✅ **Wishlist**: 6 items en wishlists de usuarios
✅ **PUDO Locations**: 2 puntos Brickshare PUDO
✅ **User PUDO selections**: 1 selección activa

## 🚀 Métodos de Recuperación

### Opción A: Script Automático (RECOMENDADO)

```bash
# 1. Limpiar seed_full.sql
python3 scripts/clean-seed-full.py

# 2. Revisar seed_clean.sql generado
less supabase/seed_clean.sql

# 3. Aplicar datos
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres < supabase/seed_clean.sql
```

### Opción B: Extracción Manual Selectiva

```bash
# Extraer solo INSERTs de tablas específicas
grep -A 50 "INSERT INTO public.sets" supabase/seed_full.sql > sets_data.sql
grep -A 50 "INSERT INTO public.inventory_sets" supabase/seed_full.sql > inventory_data.sql
grep -A 20 "INSERT INTO public.wishlist" supabase/seed_full.sql > wishlist_data.sql

# Aplicar uno por uno
psql $DATABASE_URL < sets_data.sql
psql $DATABASE_URL < inventory_data.sql
psql $DATABASE_URL < wishlist_data.sql
```

### Opción C: Extracción por Tabla Individual

```sql
-- Conectar a la BD
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres

-- Copiar solo datos de sets (ejemplo)
BEGIN;
SET session_replication_role = 'replica';

-- Pegar aquí los INSERT de seed_full.sql para public.sets
-- (solo la sección de esa tabla)

SET session_replication_role = 'origin';
COMMIT;
```

## 📊 Resumen de Recuperación

| Elemento | Estado | Acción |
|----------|--------|--------|
| **Usuarios test** | ✅ Ya existen | NO recuperar |
| **Sets (29)** | ✅ Recuperable | Usar script limpieza |
| **Inventory** | ✅ Recuperable | Usar script limpieza |
| **Wishlist (6)** | ✅ Recuperable | Usar script limpieza |
| **PUDO locations** | ✅ Recuperable | Usar script limpieza |
| **Shipments** | ⚠️ Sin datos en seed | - |
| **Tabla orders** | ❌ Obsoleta | IGNORAR |
| **Funciones RPC** | ❌ Obsoletas | IGNORAR |
| **Tablas chat** | ❌ Eliminadas | IGNORAR |

## ⚡ Quick Start (Recomendado)

```bash
# Método rápido y seguro
python3 scripts/clean-seed-full.py && \
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres < supabase/seed_clean.sql
```

## 🔍 Verificación Post-Recuperación

```sql
-- Verificar sets recuperados
SELECT COUNT(*) FROM public.sets; -- Debe ser 29

-- Verificar inventory
SELECT COUNT(*) FROM public.inventory_sets; -- Debe ser 29

-- Verificar wishlist
SELECT COUNT(*) FROM public.wishlist; -- Debe ser 6

-- Verificar usuarios
SELECT email, subscription_status FROM public.users;
```

## 📝 Notas Importantes

1. **NO intentar recuperar**:
   - Tabla `orders` (eliminada en refactor)
   - Funciones RPC obsoletas
   - Tablas chat_*
   - Datos de schema interno (auth.*, storage.*, realtime.*)

2. **Recuperación segura**:
   - Solo datos de tablas `public.*` core
   - Usar transacciones (BEGIN/COMMIT)
   - Desactivar triggers temporalmente (`session_replication_role = 'replica'`)

3. **Backup antes de aplicar**:
   ```bash
   ./scripts/db-reset.sh  # Ya hace backup automático
   ```

## 🆘 Troubleshooting

### Error: "duplicate key value violates unique constraint"
**Solución**: Los datos ya existen, usar `ON CONFLICT DO NOTHING`

### Error: "relation does not exist"
**Solución**: Tabla obsoleta o renombrada - verificar en migraciones

### Error: "violates foreign key constraint"
**Solución**: Cargar tablas en orden: users → sets → inventory → wishlist

---

**Conclusión**: El 90% de datos en `seed_full.sql` son estructuras de schema (DROP/CREATE). 
Solo ~10% son datos reales, y de esos, los únicos relevantes son sets, inventory y wishlist.

**Recomendación final**: Usar el script Python de limpieza automática.