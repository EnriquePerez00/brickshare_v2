# Apartado "Devoluciones" — Consola de Operations

## 📋 Descripción General

El apartado **"Devoluciones"** en la consola de Operations permite a operadores y administradores gestionar el flujo completo de devolución y reparación de sets LEGO que han sido utilizados por los clientes. Es el corazón del proceso de recepción logística.

---

## 🔍 Información Mostrada

### 1. **Shipments en Devolución (ReturnsList)**

La sección principal muestra una tabla con todos los envíos que están en proceso de devolución:

| Campo | Descripción |
|-------|-------------|
| **Set Ref** | Código LEGO del set (ej: "75192") |
| **Usuario** | Nombre del cliente que devuelve el set |
| **Estado del Set** | Estado actual (pending_reception, received, in_repair, active) |
| **Fecha de Recepción** | Cuándo se recibió el set en el almacén |
| **Peso (kg)** | Campo de entrada para registrar el peso del set devuelto |
| **Peso Esperado** | Peso estándar del set según catálogo |
| **Estado de Procesamiento** | Si ya fue procesado o está pendiente |
| **Acciones** | Botones para procesar, ver detalles, registrar piezas faltantes |

#### **Flujo de Procesamiento:**

1. **Escanear QR** o buscar el shipment
2. **Registrar Peso** del set devuelto en kg
3. **Sistema valida automáticamente:**
   - ✅ Si el peso está dentro del rango esperado (±10% de tolerancia) → Set se marca como `active` (disponible)
   - ❌ Si hay varianza de peso → Set se marca como `in_repair` (requiere inspección)
4. **Botón "Procesar Devolución"** → Guarda el registro y actualiza el estado

---

### 2. **Reparaciones (RepairsList)**

Una sección separada que muestra todos los sets actualmente en reparación:

| Campo | Descripción |
|-------|-------------|
| **Set Ref** | Código LEGO del set que está en reparación |
| **Tema/Nombre** | Nombre del set |
| **Piezas Faltantes** | Número total de piezas registradas como faltantes |
| **Peso Registrado** | Último peso medido del set |
| **Varianza de Peso** | Porcentaje de diferencia vs. peso esperado |
| **Fecha de Entrada** | Cuándo entró en reparación |
| **Acciones** | Botones para ver detalles, agregar piezas, marcar como reparado |

---

### 3. **Diálogo: Piezas Faltantes (MissingPiecesDialog)**

Cuando se detectan discrepancias de peso o se necesita registrar piezas faltantes manualmente:

**Campos mostrados:**
- Lista detallada de piezas faltantes:
  - Referencia LEGO de la pieza (ej: "3001")
  - Nombre descriptivo (ej: "Brick 2x4")
  - Color
  - Cantidad faltante
  - Notas adicionales (opcionales)
  - Estado del pedido de reemplazo: `pending` | `ordered` | `received`

**Acciones disponibles:**
- ➕ **Agregar pieza**: Abre un formulario para registrar nuevas piezas faltantes
- ✏️ **Editar**: Modifica cantidad o estado de una pieza
- 🗑️ **Eliminar**: Quita una pieza del registro
- 📊 **Generar Informe**: Exporta el listado de piezas a PDF/CSV
- ✅ **Marcar Reparación Completa**: Una vez reemplazadas todas las piezas

---

### 4. **Datos Clave Mostrados en Tiempo Real**

#### **Tabla de Pesos y Varianza:**
```
Set Ref     | Peso Medido | Peso Esperado | Varianza | Tolerancia OK? | Acción
75192       | 1.850 kg    | 1.800 kg      | +2.8%    | ✅ SÍ          | Active
70840       | 0.450 kg    | 0.500 kg      | -10.5%   | ❌ NO          | In Repair
75261       | 2.100 kg    | 2.100 kg      | 0%       | ✅ SÍ          | Active
```

#### **Registro de Piezas Faltantes:**
```
Set: 70840 (Star Wars - The Child)
─────────────────────────────────
Pieza ID | Descripción              | Color   | Cantidad | Estado
3001     | Brick 2x4               | Tan     | 2        | pending
3005     | Brick 1x1               | Brown   | 5        | pending
61252    | Dish 2x2 (Minifig Head) | Yellow  | 1        | ordered
```

---

## 🎯 Procesos Principales

### **Proceso 1: Devolución Normal (Sin Piezas Faltantes)**

```
1. Set llega al almacén (pending_reception)
   ↓
2. Escanear QR del shipment
   ↓
3. Registrar peso del set
   ↓
4. Sistema valida peso (±10%)
   ↓
5. SI CORRECTO → Estado: active (disponible para renta)
   ↓
6. Actualizar inventario automáticamente
```

### **Proceso 2: Reparación (Piezas Faltantes Detectadas)**

```
1. Set llega (pending_reception)
   ↓
2. Peso fuera de tolerancia → in_repair
   ↓
3. Operador inspecciona y registra piezas faltantes
   ↓
4. Sistema crea órdenes de reemplazo (pending → ordered → received)
   ↓
5. Una vez recibidas todas las piezas → marcar como reparado
   ↓
6. Set vuelve a: active (disponible)
```

---

## 📊 Estadísticas Visibles

En el panel de Operations se pueden ver:

- **Total de sets en devolución hoy**: Contador
- **Sets procesados correctamente**: Número y porcentaje
- **Sets en reparación**: Número y tiempo promedio de reparación
- **Piezas faltantes más comunes**: Ranking
- **Tasa de devolución sin problemas**: Porcentaje

---

## 🔐 Permisos Requeridos

| Acción | Rol Requerido |
|--------|---------------|
| Ver devoluciones | `operador` \| `admin` |
| Registrar peso | `operador` \| `admin` |
| Procesar devolución | `operador` \| `admin` |
| Registrar piezas faltantes | `operador` \| `admin` |
| Marcar reparación completa | `operador` \| `admin` |
| Generar reportes | `admin` |

---

## 💾 Datos Almacenados

### **Tabla: `reception_operations`**
- `event_id` (shipment_id)
- `user_id` (operador que procesa)
- `set_id` (set devuelto)
- `weight_measured` (peso registrado)
- `reception_completed` (booleano)
- `missing_parts` (descripción si aplica)

### **Tabla: `reception_missing_pieces`**
- `id` (UUID)
- `set_id` (set que le faltan piezas)
- `piece_ref` (referencia LEGO, ej: "3001")
- `quantity` (cantidad faltante)
- `status` (pending | ordered | received)
- `created_at`, `updated_at`

### **Tabla: `reception_set_weight`**
- `id` (UUID)
- `set_id` (set pesado)
- `weight_kg` (peso medido)
- `expected_weight_kg` (peso estándar)
- `weight_variance_percentage` (% de varianza)
- `recorded_by` (user_id del operador)

---

## 🔧 Funciones RPC Utilizadas

### **`process_set_return_with_weight()`**
Procesa la devolución de un set con validación automática de peso.

```typescript
// Input
{
  set_id: UUID,
  weight_kg: number,
  notes?: string
}

// Output
{
  success: boolean,
  new_status: 'active' | 'in_repair',
  weight_ok: boolean,
  variance_percentage: number
}
```

### **`add_missing_pieces_batch()`**
Registra múltiples piezas faltantes de una vez.

```typescript
// Input
{
  set_id: UUID,
  pieces: [
    {
      piece_ref: string,
      quantity: number
    }
  ]
}

// Output
{
  success: boolean,
  inserted_count: number,
  error_count: number
}
```

### **`mark_repairs_complete()`**
Marca un set como reparado y lo devuelve al inventario.

```typescript
// Input
{
  set_id: UUID
}

// Output
{
  success: boolean,
  status: 'active',
  missing_pieces_recorded: number
}
```

---

## 📱 Interfaz de Usuario

### **Secciones Visibles en el Panel:**

```
┌─────────────────────────────────────────────────────────┐
│ Operations Panel > Devoluciones                          │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  📦 SHIPMENTS EN DEVOLUCIÓN                             │
│  ├─ Tabla con shipments pendientes de procesar          │
│  ├─ Columnas: Set Ref, Usuario, Peso, Estado           │
│  └─ Acciones: Procesar, Ver Detalles, Registrar        │
│                                                         │
│  🔧 SETS EN REPARACIÓN                                 │
│  ├─ Tabla con sets que requieren reparación            │
│  ├─ Columnas: Set Ref, Piezas Faltantes, Varianza      │
│  └─ Acciones: Agregar Piezas, Marcar Reparado         │
│                                                         │
│  ⚙️ PIEZAS FALTANTES (Modal)                           │
│  ├─ Lista detallada de piezas por set                  │
│  ├─ Estado de cada pieza (pending/ordered/received)    │
│  └─ Opciones: Agregar, Editar, Eliminar, Completar    │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## ✅ Resumen Final

El apartado **"Devoluciones"** muestra:

1. ✅ **Lista de shipments en devolución** con info de peso y usuario
2. ✅ **Validación automática de peso** (±10% de tolerancia)
3. ✅ **Detección automática de piezas faltantes** por varianza de peso
4. ✅ **Registro manual de piezas faltantes** con detalles LEGO
5. ✅ **Seguimiento de reparaciones** (pending → ordered → received)
6. ✅ **Estadísticas en tiempo real** de devoluciones y reparaciones
7. ✅ **Integración con inventario** (actualización automática)
8. ✅ **Permisos granulares** (operador/admin)

---

**Última actualización:** 28 de marzo de 2026
**Componentes relacionados:** `ReturnsList.tsx`, `RepairsList.tsx`, `MissingPiecesDialog.tsx`, `Operations.tsx`