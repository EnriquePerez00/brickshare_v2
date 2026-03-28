# 🔧 Seed de Datos para Testing de Devoluciones y Reparaciones

## 📋 Descripción

Este script SQL crea datos de prueba completos para testear la sección **"Devoluciones"** y **"Reparaciones"** de la consola de Operations en Brickshare.

Se ejecuta con el usuario `user2@brickshare.com` que ya existe en la base de datos local.

---

## 🎯 Datos que se crean

### **1. Shipment en Devolución (Status: `received`)**
- **Usuario**: user2@brickshare.com
- **Set**: Empire State Building (21002)
- **Tipo**: Devolución (`return`)
- **Estado**: `received` (ya devuelto al almacén)
- **Peso medido**: 185g
- **Peso esperado**: 190g
- **Varianza**: -2.63% ✅ (dentro de tolerancia ±10%, sin piezas faltantes)
- **Acción en UI**: El operador puede registrar este peso y marcarlo como `active` (disponible nuevamente)

### **2. Shipment en Reparación (Status: `in_repair`)**
- **Usuario**: user2@brickshare.com
- **Set**: LEGO City Advent Calendar (2824)
- **Tipo**: Devolución (`return`)
- **Estado**: `in_repair` (requiere reparación)
- **Peso medido**: 405g
- **Peso esperado**: 430g
- **Varianza**: -5.81% ⚠️ (fuera de tolerancia, indica piezas faltantes)
- **Piezas faltantes**: 4 piezas en diferentes estados

### **3. Piezas Faltantes Registradas**

| Ref LEGO | Nombre | Color | Cantidad | Status | Descripción |
|----------|--------|-------|----------|--------|-------------|
| 3001 | Brick 2x4 | Red | 3 | pending | Pendiente de solicitar al proveedor |
| 3005 | Brick 1x1 | Tan | 5 | ordered | Ya solicitada, en camino |
| 4740 | Slope Brick 45° 2x1 | Light Gray | 2 | received | Ya recibida, lista para instalar |
| 3622 | Minifig Head Yellow | Yellow | 1 | pending | Pendiente de solicitar |

---

## 🚀 Cómo ejecutar

### **Opción 1: Directamente desde psql (recomendado)**

```bash
# Conectar a la base de datos local de Supabase
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres -f scripts/seed-returns-testing.sql

# O si usas el alias de supabase:
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres \
  -f scripts/seed-returns-testing.sql
```

### **Opción 2: Dentro de Supabase Studio (UI)**

1. Abre **Supabase Studio** en http://localhost:54323
2. Ve a **SQL Editor**
3. Copia el contenido de `scripts/seed-returns-testing.sql`
4. Pégalo en el editor
5. Ejecuta con **Cmd+Enter** (o **Ctrl+Enter** en Linux/Windows)

### **Opción 3: Con supabase CLI**

```bash
supabase migration up  # Asegúrate de que todas las migraciones estén aplicadas primero

# Luego ejecuta el seed
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres < scripts/seed-returns-testing.sql
```

---

## ✅ Verificación

Una vez ejecutado el seed, deberías poder:

### **En la sección "Devoluciones":**
- ✅ Ver un shipment de `user2@brickshare.com` con el **Empire State Building (21002)**
- ✅ Registrar manualmente el peso: **0.185 kg** (o similar)
- ✅ El sistema validará automáticamente que está dentro de tolerancia
- ✅ Marcar como "Procesar Devolución" → Status cambia a `active`

### **En la sección "Reparaciones":**
- ✅ Ver un shipment de `user2@brickshare.com` con el **LEGO City Advent Calendar (2824)**
- ✅ Mostrar piezas faltantes con tabla de estados (pending/ordered/received)
- ✅ Posibilidad de agregar/editar/eliminar piezas
- ✅ Una vez todas las piezas estén en `received`, marcar como "Reparación Completa"

### **Verificar datos en SQL:**

Descomenta las líneas de verificación al final de `seed-returns-testing.sql` para ver:

```sql
-- Descomentar líneas de verificación
SELECT '=== SHIPMENT EN DEVOLUCIÓN ===' as section;
SELECT * FROM public.shipments WHERE shipment_type = 'return' AND status = 'received';

SELECT '=== SHIPMENT EN REPARACIÓN ===' as section;
SELECT * FROM public.shipments WHERE shipment_type = 'return' AND status = 'in_repair';

SELECT '=== PIEZAS FALTANTES ===' as section;
SELECT * FROM public.reception_missing_pieces;

SELECT '=== PESOS REGISTRADOS ===' as section;
SELECT * FROM public.reception_set_weight;
```

---

## 🧹 Limpiar datos (si necesitas reiniciar)

Para eliminar todos los datos de prueba creados por este seed:

```sql
-- Eliminar en orden inverso de dependencias:
DELETE FROM public.reception_missing_pieces
WHERE set_id IN (
  '0beb3582-b8c6-4963-a4f0-5d4c7d36873b',  -- LEGO City Advent Calendar
  '535f8eec-123a-4577-9dac-d9d54be7cccf'   -- Empire State Building
);

DELETE FROM public.reception_operations
WHERE set_id IN (
  '0beb3582-b8c6-4963-a4f0-5d4c7d36873b',
  '535f8eec-123a-4577-9dac-d9d54be7cccf'
);

DELETE FROM public.reception_set_weight
WHERE set_id IN (
  '0beb3582-b8c6-4963-a4f0-5d4c7d36873b',
  '535f8eec-123a-4577-9dac-d9d54be7cccf'
);

DELETE FROM public.shipments
WHERE user_id = '8251dd64-3747-40d0-8d20-c32b3a87d215'
  AND shipment_type = 'return'
  AND status IN ('received', 'in_repair');
```

---

## 📊 Resumen de Datos

| Concepto | Valor |
|----------|-------|
| **Usuario** | user2@brickshare.com |
| **Shipments creados** | 2 (1 devolución + 1 reparación) |
| **Sets involucrados** | 2 |
| **Piezas faltantes** | 4 |
| **Estados de piezas** | 3 (pending, ordered, received) |
| **Peso esperado total** | 620g |
| **Peso medido total** | 589.5g |

---

## 🔗 Documentación Relacionada

- `docs/OPERATIONS_RETURNS_SECTION.md` - Descripción completa de la sección Devoluciones
- `docs/DATABASE_SCHEMA.md` - Esquema completo de la base de datos
- `supabase/migrations/20260328000001_reception_operations_complete.sql` - Migraciones de tablas

---

## ⚠️ Notas Importantes

- Este seed **NO modifica** el seed.sql principal
- Solo crea datos de prueba en tablas ya existentes
- Es **seguro ejecutar múltiples veces** (usa `ON CONFLICT DO NOTHING` y `WHERE NOT EXISTS`)
- Los datos se crean con timestamps relativos (NOW() - INTERVAL) para simular devoluciones recientes
- El usuario `user2@brickshare.com` ya debe existir en la base de datos

---

**Última actualización:** 28 de marzo de 2026
**Compatible con:** Brickshare v2 (rama develop)