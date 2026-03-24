# Análisis de seed_full.sql y Conflictos con la Base de Datos Actual

## ⚠️ PROBLEMA PRINCIPAL: Tabla `orders` eliminada

La tabla `orders` fue eliminada en la migración `20260130220000` y su funcionalidad fue absorbida por la tabla `shipments`. El archivo `seed_full.sql` contiene **82 referencias a la tabla orders** que causarán errores al intentar restaurarlo.

---

## 🔍 Elementos del seed_full.sql que NO se pueden recuperar

### 1. **Tabla `orders` (DEPRECADA)**
- ❌ **Estructura completa de la tabla eliminada**
- ❌ **Datos históricos de pedidos**
- ❌ **Foreign keys relacionadas**
- ❌ **Políticas RLS específicas**

**Impacto**: Los datos históricos de pedidos en `orders` no se pueden restaurar directamente. Deben migrarse a `shipments`.

---

### 2. **Tabla `shipping_orders` (DEPRECADA)**
- ❌ Tabla creada en migración `20260131184000`
- ❌ Nunca se utilizó en el código final
- ❌ No contiene datos relevantes

**Impacto**: Ninguno. Esta tabla era experimental y no se usa.

---

### 3. **Columnas deprecadas en `envios/shipments`**
- ❌ `order_id` (eliminada, ahora se usa `set_id` directamente)
- ❌ `costo_envio` (eliminada)

**Impacto**: Cualquier dato en estas columnas se pierde.

---

### 4. **Nombres de columnas obsoletos**
El seed usa nombres antiguos en español que fueron renombrados:

#### En tabla `shipments` (antes `envios`):
- `estado_envio` → `shipment_status`
- `fecha_asignada` → `assigned_date`
- `fecha_entrega` → `estimated_delivery_date`
- `fecha_entrega_real` → `actual_delivery_date`
- `fecha_entrega_usuario` → `user_delivery_date`
- `fecha_recepcion_almacen` → `warehouse_reception_date`
- `fecha_devolucion_estimada` → `estimated_return_date`
- `direccion_envio` → `shipping_address`
- `ciudad_envio` → `shipping_city`
- `codigo_postal_envio` → `shipping_zip_code`
- `pais_envio` → `shipping_country`
- `proveedor_envio` → `shipping_provider`
- `direccion_proveedor_recogida` → `pickup_provider_address`
- `numero_seguimiento` → `tracking_number`
- `transportista` → `carrier`
- `notas_adicionales` → `additional_notes`
- `fecha_recogida_almacen` → `warehouse_pickup_date`
- `fecha_solicitud_devolucion` → `return_request_date`
- `proveedor_recogida` → `pickup_provider`

#### En tabla `reception_operations` (antes `operaciones_recepcion`):
- `peso_obtenido` → `weight_measured`
- `status_recepcion` → `reception_completed`

#### En tabla `inventory_sets` (antes `inventario_sets`):
- `cantidad_total` → `inventory_set_total_qty`
- `stock_central` → (eliminada)

#### En tabla `users`:
- `estado_usuario` → `user_status`
- Múltiples campos de dirección duplicados eliminados

**Impacto**: El seed intentará insertar datos en columnas que no existen.

---

## ✅ Elementos que SÍ se pueden recuperar

### 1. **Datos de usuarios (`auth.users` y `public.users`)**
- ✅ Estructura compatible
- ✅ Roles en `user_roles`
- ⚠️ Requiere mapeo de columnas renombradas

### 2. **Datos de sets (`sets`)**
- ✅ Estructura compatible
- ✅ Relación con `inventory_sets`
- ⚠️ Requiere mapeo de columnas renombradas

### 3. **Datos de inventario (`inventory_sets`)**
- ✅ Estructura compatible
- ⚠️ Requiere mapeo de columnas renombradas
- ⚠️ Columna `stock_central` eliminada

### 4. **Lista de piezas (`set_piece_list`)**
- ✅ Estructura totalmente compatible

### 5. **Wishlist**
- ✅ Estructura compatible

### 6. **Donaciones (`donations`)**
- ✅ Estructura compatible
- ⚠️ Requiere mapeo de columnas

### 7. **Reviews y Referrals**
- ✅ Estructuras compatibles
- ✅ Añadidas en migraciones posteriores

### 8. **PUDO locations**
- ✅ `brickshare_pudo_locations` compatible
- ✅ `users_correos_dropping` compatible
- ✅ `users_brickshare_dropping` compatible

### 9. **Operaciones de recepción (`reception_operations`)**
- ✅ Estructura compatible
- ⚠️ Requiere mapeo de columnas

### 10. **Operaciones de backoffice (`backoffice_operations`)**
- ✅ Estructura compatible

---

## 🛠️ Estrategia de Recuperación

### OPCIÓN 1: Seed Limpio (RECOMENDADO)
Crear un nuevo archivo `seed_clean.sql` que:
1. ❌ **Elimine** todas las referencias a `orders` y `shipping_orders`
2. ✅ **Migre** datos necesarios directamente a `shipments`
3. ✅ **Actualice** nombres de columnas al estándar inglés
4. ✅ **Elimine** columnas deprecadas
5. ✅ **Mantenga** todos los datos de tablas compatibles

### OPCIÓN 2: Script de Migración
Crear `scripts/migrate-seed-to-current.sql` que:
1. Carga `seed_full.sql` en tablas temporales
2. Transforma los datos al esquema actual
3. Inserta en las tablas reales

### OPCIÓN 3: Restauración Parcial
Ejecutar sentencias SELECT específicas de `seed_full.sql`:
- Usuarios y roles
- Sets e inventario
- Wishlists
- PUDO locations
- Datos de negocio (reviews, referrals, donations)

---

## 📋 Pasos Inmediatos Recomendados

### 1. Backup de datos actuales
```bash
./scripts/safe-db-reset.sh backup
```

### 2. Identificar datos críticos en seed_full.sql
```bash
# Extraer solo INSERTs de tablas compatibles
grep "INSERT INTO public.sets" supabase/seed_full.sql > temp_sets.sql
grep "INSERT INTO public.users" supabase/seed_full.sql > temp_users.sql
# etc...
```

### 3. Crear seed_clean.sql
- Eliminar toda referencia a `orders`
- Actualizar nombres de columnas
- Validar con esquema actual

### 4. Probar en entorno local
```bash
supabase db reset
psql $DATABASE_URL -f supabase/seed_clean.sql
```

---

## 🚨 Conflictos Críticos a Resolver

### 1. **Datos de shipments sin order_id**
Los envíos en el seed tienen `order_id` pero la tabla actual usa `set_id` directamente.

**Solución**: 
```sql
-- En vez de:
-- INSERT INTO shipments (order_id, ...) VALUES (uuid, ...);

-- Hacer:
INSERT INTO shipments (set_id, user_id, ...) 
SELECT set_id, user_id, ... FROM orders WHERE id = order_id;
```

### 2. **Estados de envío en español**
Los valores en `estado_envio` usan español pero `shipment_status` usa inglés.

**Mapeo necesario**:
- `'preparacion'` → `'preparation'`
- `'ruta_envio'` → `'in_transit_pudo'`
- `'entregado'` → `'delivered_user'`
- `'devuelto'` → `'returned'`
- `'ruta_devolucion'` → `'in_return_pudo'`
- `'cancelado'` → `'cancelled'`

### 3. **User_status valores inconsistentes**
Valores antiguos vs actuales en `users.user_status`.

**Mapeo necesario**:
- `'sin set'` → `'no_set'`
- `'set en envio'` → `'set_shipping'`
- `'con set'` → `'has_set'`  
- `'set en devolucion'` → `'set_returning'`

---

## 📊 Resumen Estadístico

- **Total referencias a orders**: 82
- **Columnas renombradas**: ~30
- **Columnas eliminadas**: ~5
- **Tablas deprecadas**: 2 (`orders`, `shipping_orders`)
- **Tablas recuperables**: 15+
- **Datos en riesgo**: Histórico de pedidos (si no se migra)

---

## ✅ Checklist de Validación Post-Restauración

- [ ] Todos los usuarios se crearon correctamente
- [ ] Roles asignados (admin, user, operador)
- [ ] Sets importados con inventario
- [ ] Wishlists funcionando
- [ ] PUDO locations disponibles
- [ ] Reviews y referrals activos
- [ ] Funciones RPC operativas:
  - [ ] `preview_assign_sets_to_users()`
  - [ ] `confirm_assign_sets_to_users()`
  - [ ] `delete_assignment_and_rollback()`
- [ ] Triggers activos
- [ ] RLS políticas funcionando

---

## 🎯 Conclusión

**NO se puede** aplicar `seed_full.sql` directamente sin generar errores masivos. Se requiere:

1. ✅ Crear `seed_clean.sql` sin referencias a `orders`
2. ✅ Actualizar todos los nombres de columnas
3. ✅ Migrar datos de `orders` a `shipments` con lógica de mapeo
4. ✅ Validar con schema actual antes de aplicar

**Tiempo estimado**: 2-4 horas para crear y validar seed limpio.