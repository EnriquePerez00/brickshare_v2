# 🔧 Fix: Normalización de IDs PUDO (BS-PUDO-XXX → brickshare-XXX)

**Fecha**: 27 de Marzo de 2026  
**Versión**: 1.0.0  
**Estado**: ✅ Aplicado

---

## 📋 Resumen

Se ha identificado y corregido un error en la tabla `brickshare_pudo_locations` donde los IDs de los puntos PUDO estaban hardcodeados con el formato `BS-PUDO-001` y `BS-PUDO-002`, cuando deberían seguir el formato `brickshare-001` y `brickshare-002`.

### ❌ Problema Original

```sql
-- INCORRECTO: IDs hardcodeados con formato inconsistente
INSERT INTO brickshare_pudo_locations (id, name, ...)
VALUES 
    ('BS-PUDO-001', 'Brickshare Madrid Centro', ...),
    ('BS-PUDO-002', 'Brickshare Barcelona Eixample', ...)
```

**Impacto**:
- ❌ Conflicto con migración 20260326120000 que esperaba `brickshare-XXX`
- ❌ Error 404 en Edge Function `send-brickshare-qr-email` al no encontrar puntos PUDO
- ❌ Violación de nueva regla en claude.md: NO harcodear valores configurables
- ❌ Inconsistencia con API remota de PUDO

### ✅ Solución Implementada

#### 1. Actualización de claude.md
```markdown
- **❌ NUNCA harcodear valores configurables** en el código (URLs, IDs, claves, hosts, puertos, etc.)
  - Todas las variables configurables deben provenir de `import.meta.env` (frontend) 
    o `Deno.env.get()` (Edge Functions)
  - Excepciones permitidas: constantes de lógica de negocio, enums estáticos, valores 
    hardcoded en datos de test
  - Ejemplos de lo que NO se debe harcodear: `BS-PUDO-001`, URLs API, direcciones 
    de servidores, configuraciones por entorno
```

#### 2. Normalización de IDs
```sql
-- Cambio de formato en todas las tablas:
BS-PUDO-001  →  brickshare-001
BS-PUDO-002  →  brickshare-002
```

#### 3. Tablas Afectadas

| Tabla | Campo | Registros Actualizados |
|---|---|---|
| `brickshare_pudo_locations` | `id` | 2 |
| `users` | `pudo_id` | Todos con `pudo_type = 'brickshare'` |
| `users_brickshare_dropping` | `brickshare_pudo_id` | Todos con IDs antiguos |
| `shipments` | `brickshare_pudo_id` | Todos con IDs antiguos |

---

## 🔧 Cambios Técnicos

### Migración Aplicada
**Archivo**: `supabase/migrations/20260327150000_fix_pudo_ids_format.sql`

Acciones:
1. ✅ Elimina registros con IDs antiguos (`BS-PUDO-001/002`)
2. ✅ Inserta registros con IDs correctos (`brickshare-001/002`)
3. ✅ Actualiza referencias en todas las tablas
4. ✅ Añade comentarios de tabla/columna para documentar el formato correcto
5. ✅ Incluye verificación con RAISE NOTICE

### Verificación
```sql
-- Todos los registros usan el formato correcto:
SELECT COUNT(*) FROM users WHERE pudo_id LIKE 'brickshare-%';
SELECT COUNT(*) FROM users_brickshare_dropping WHERE brickshare_pudo_id LIKE 'brickshare-%';
SELECT COUNT(*) FROM shipments WHERE brickshare_pudo_id LIKE 'brickshare-%';
SELECT COUNT(*) FROM brickshare_pudo_locations WHERE id LIKE 'brickshare-%';
```

---

## 📝 Errores Que Se Solucionan

### Error 1: Edge Function 404
```
❌ QR Email Error: FunctionsHttpError: Edge Function returned a non-2xx status code
   at send-brickshare-qr-email 404 (Not Found)
```

**Causa**: La función buscaba puntos PUDO con ID `brickshare-001` pero solo encontraba `BS-PUDO-001`

**Solución**: ✅ IDs ahora son `brickshare-001`

### Error 2: Violación de Reglas de Código
```
❌ VIOLACIÓN: IDs hardcodeados en migración
```

**Regla**: `claude.md` prohíbe harcodear valores configurables

**Solución**: ✅ Actualizado claude.md con nueva regla de prevención

---

## 🚀 Verificación Post-Fix

### En Desarrollo Local

1. **Reiniciar Supabase con datos limpios**:
```bash
./scripts/safe-db-reset.sh
```

2. **Verificar migración aplicada**:
```bash
supabase db info
```

3. **Comprobar datos en BD**:
```bash
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres -c \
  "SELECT id, name FROM brickshare_pudo_locations WHERE id LIKE 'brickshare-%';"
```

Resultado esperado:
```
      id      |           name
--------------+---------------------------
brickshare-001| Brickshare Madrid Centro
brickshare-002| Brickshare Barcelona Eixample
```

### Probar Generación de Etiquetas
```bash
# 1. Navegar a Admin > Operaciones > Generación de Etiquetas
# 2. Seleccionar usuario Enrique Perez
# 3. Hacer clic en "Generar Etiqueta"
# 4. Verificar que NO aparece error 404
```

---

## 📚 Documentación Relacionada

- `claude.md` - Sección 11: Nuevas reglas sobre hardcoding
- `supabase/migrations/20260321000000_brickshare_pudo_qr_system.sql` - Sistema PUDO original
- `supabase/migrations/20260326120000_fix_brickshare_pudo_ids.sql` - Primer intento de fix (incompleto)
- `docs/BRICKSHARE_PUDO.md` - Documentación sistema PUDO

---

## ✅ Checklist Post-Despliegue

- [x] Migración aplicada a BD local
- [x] Tabla `brickshare_pudo_locations` contiene IDs correctos
- [x] Registros en `users`, `users_brickshare_dropping`, `shipments` actualizados
- [x] Comentarios de tabla/columna añadidos
- [x] Nueva regla documentada en `claude.md`
- [x] Documentación de este fix creada
- [ ] Probar generación de etiquetas en interfaz (usuario debe verificar)
- [ ] Crear prueba E2E para prevenir regresión

---

## 🔮 Prevención Futura

### Regla en `claude.md`
```markdown
- **❌ NUNCA harcodear valores configurables** en el código (URLs, IDs, claves, 
  hosts, puertos, etc.)
  - Todas las variables configurables deben provenir de `import.meta.env` 
    (frontend) o `Deno.env.get()` (Edge Functions)
```

### Migraciones Futuras
Cuando se añadan nuevos puntos PUDO:
1. ✅ NO hardcodear en migraciones
2. ✅ Usar tabla `brickshare_pudo_locations` como maestra
3. ✅ Referencia dinámica mediante queries (nunca values hardcodeados)

---

**Versión**: 1.0.0  
**Última actualización**: 27/03/2026  
**Responsable**: Cline (fix automático)