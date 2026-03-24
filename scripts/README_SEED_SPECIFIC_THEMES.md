# Seed Specific Themes Script

## Descripción

Script para poblar la base de datos con sets LEGO específicos de temas concretos y años recientes. Diseñado para obtener datos de la API de BrickSet y almacenarlos en Supabase.

## Configuración

El script busca **5 sets de cada tema** desde el año **2020 en adelante**:

- ⭐ **Star Wars**: 5 sets
- 🏙️ **City**: 5 sets  
- 🏛️ **Architecture**: 5 sets

**Total: 15 sets**

## Requisitos

1. Supabase local corriendo:
   ```bash
   supabase start
   ```

2. Variables de entorno en `.env.local`:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_SERVICE_ROLE_KEY`
   - `BRICKSET_API_KEY`

## Uso

```bash
# Desde la raíz del proyecto
npx tsx scripts/seed-specific-themes.ts
```

## Qué hace el script

1. **Consulta BrickSet API** para cada tema con filtros:
   - Tema específico (Star Wars, City, Architecture)
   - Año >= 2020
   - Solo sets con imágenes
   - Ordenados por año (más recientes primero)

2. **Inserta/Actualiza en la tabla `sets`**:
   - Datos completos del set (nombre, descripción, imagen, piezas, etc.)
   - Calcula precio de alquiler según número de piezas
   - Marca como `active` y visible en catálogo

3. **Gestiona inventario en `inventory_sets`**:
   - Crea entrada con 5 unidades por set
   - Inicializa contadores (in_shipping, in_use, etc.) en 0

## Salida esperada

```
🚀 Starting Brickshare Themed Seed...
📍 Targeting Supabase: http://localhost:54331
📅 Year filter: 2020+

============================================================
📦 Processing theme: Star Wars (5 sets)
============================================================

🔍 Fetching Star Wars sets from 2020+...
✅ Found 5 valid Star Wars sets (2020+)
✅ Seeded: 75331 - The Mandalorian™ - The Razor Crest™ (2022, 1969 pcs, €150)
✅ Seeded: 75341 - Luke Skywalker's Landspeeder™ (2022, 1890 pcs, €150)
...

============================================================
🎉 Seed Completed!
============================================================

📊 Summary:
  ✅ Star Wars: 5 sets
  ✅ City: 5 sets
  ✅ Architecture: 5 sets

🎯 Total sets processed: 15
```

## Manejo de duplicados

- Si el `set_ref` ya existe, **actualiza** los datos
- Si no existe, **inserta** el set
- El inventario se actualiza a 5 unidades en ambos casos

## Cálculo de precio de alquiler

```typescript
< 250 piezas  → €25
< 500 piezas  → €50
< 750 piezas  → €75
< 1000 piezas → €100
>= 1000 piezas → €150
```

## Troubleshooting

### Error: Missing VITE_SUPABASE_SERVICE_ROLE_KEY
```bash
# Verificar que existe en .env.local
cat .env.local | grep VITE_SUPABASE_SERVICE_ROLE_KEY

# Obtener la clave si no existe
supabase status
```

### Error: Network error fetching theme
- Verificar conexión a internet
- Verificar que BRICKSET_API_KEY es válida
- La API de BrickSet puede estar temporalmente inaccesible

### Sets no aparecen en catálogo
- Verificar que `catalogue_visibility = true`
- Verificar que `set_status = 'active'`
- Revisar que el inventario tiene unidades disponibles

## Modificar configuración

Para cambiar temas o cantidad de sets, editar en el script:

```typescript
const THEMES_CONFIG = [
  { theme: 'Star Wars', count: 5 },
  { theme: 'City', count: 5 },
  { theme: 'Architecture', count: 5 }
];
const MIN_YEAR = 2020;
```

## Ver sets insertados

```bash
# Conectar a la BD local
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres

# Consultar sets insertados
SELECT set_ref, set_name, set_theme, year_released, set_piece_count, set_price
FROM sets
WHERE set_theme IN ('Star Wars', 'City', 'Architecture')
  AND year_released >= 2020
ORDER BY set_theme, year_released DESC;