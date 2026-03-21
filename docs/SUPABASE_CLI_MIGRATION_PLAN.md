# Plan de Migración CLI de Supabase - Análisis Completo

## Resumen Ejecutivo

Tras analizar el estado de las migraciones y la base de datos remota, se han identificado **problemas críticos de nomenclatura** en 7 migraciones pendientes que causan errores al intentar aplicarlas.

## Estado Actual del CLI

### ✅ Configuración Exitosa
- **Supabase CLI**: v2.78.1 instalado y funcionando
- **Autenticación**: Configurada con token de acceso válido
- **Variables de entorno configuradas**:
  ```bash
  SUPABASE_ACCESS_TOKEN="sbp_7602620a857f1d4b233e3285d8eb032ee9917633"
  SUPABASE_DB_PASSWORD="Urgell175177"
  ```
- **Archivo de configuración**: `~/.zshrc` actualizado correctamente
- **Conexión a BD remota**: Funcional (proyecto `tevoogkifiszfontzkgd`)

### 📊 Estado de Migraciones

**Migraciones aplicadas en remoto**: 111 migraciones

**Migraciones pendientes locales**: 7 migraciones
1. `20260319200000_chat_logs.sql` ⚠️ Parcialmente aplicada manualmente
2. `20260320000000_add_swikly_fields.sql` ❌ **ERROR: tabla incorrecta**
3. `20260320000001_brickman_rag.sql`
4. `20260321000000_brickshare_pudo_qr_system.sql` ❌ **ERROR: tablas incorrectas**  
5. `20260322000000_add_logistics_integration.sql`
6. `20260323000000_update_assignment_with_history_check.sql` ❌ **ERROR: tabla incorrecta**
7. `20260324000000_fix_users_visibility_all_roles.sql`

## Problema Principal: Nomenclatura de Tablas Incorrecta

### Tablas Reales en la Base de Datos

Según las migraciones aplicadas (análisis de 20260127*.sql):

| Nombre Incorrecto en Migraciones | Nombre Real en BD | Migración Origen |
|----------------------------------|-------------------|------------------|
| `assignments` | `envios` | 20260127090000 |
| `shipments` | `envios` | 20260127090000 |

**Nota Importante**: La BD usa nomenclatura en español. La tabla principal de envíos/asignaciones se llama `envios`.

### Migraciones Afectadas

#### 1. ❌ 20260319200000_chat_logs.sql
**Problema**: Políticas RLS y triggers ya existen en BD remota
**Causa**: Migración aplicada manualmente (parcialmente) desde el dashboard de Supabase
**Solución**: Agregar `IF NOT EXISTS` o `DROP IF EXISTS` antes de recrear

#### 2. ❌ 20260320000000_add_swikly_fields.sql
**Problema**: 
```sql
ALTER TABLE assignments ADD COLUMN...  -- ❌ tabla no existe
```
**Corrección realizada**:
```sql
ALTER TABLE envios ADD COLUMN...  -- ✅ tabla correcta
```

#### 3. ❌ 20260321000000_brickshare_pudo_qr_system.sql
**Problemas múltiples**:
```sql
ALTER TABLE shipments ADD COLUMN...     -- ❌ debería ser envios
SELECT * FROM shipments...              -- ❌ debería ser envios
UPDATE shipments SET...                 -- ❌ debería ser envios
SELECT * FROM assignments...            -- ❌ debería ser envios
```

**Esta migración requiere reemplazo masivo de referencias a tablas**.

#### 4. ⚠️ 20260323000000_update_assignment_with_history_check.sql
**Probable problema**: Referencias a `assignments` en lugar de `envios`
**Requiere revisión**: Sí

## Plan de Acción Detallado

### Fase 1: Corrección de Migraciones (URGENTE)

#### Paso 1.1: Corregir 20260319200000_chat_logs.sql
```sql
-- Cambiar CREATE POLICY por:
CREATE POLICY IF NOT EXISTS "chat_conversations_insert"...

-- Cambiar CREATE TRIGGER por:
DROP TRIGGER IF EXISTS chat_messages_update_conversation_ts ON public.chat_messages;
CREATE TRIGGER chat_messages_update_conversation_ts...
```

#### Paso 1.2: Ya corregida 20260320000000_add_swikly_fields.sql ✅
- Cambios: `assignments` → `envios`
- Archivo actualizado correctamente

#### Paso 1.3: Corregir 20260321000000_brickshare_pudo_qr_system.sql
**Reemplazos necesarios**:
1. `ALTER TABLE shipments` → `ALTER TABLE envios` (todas las ocurrencias)
2. `FROM shipments` → `FROM envios` (en funciones SQL)
3. `UPDATE shipments` → `UPDATE envios` (en funciones SQL)
4. `JOIN assignments` → `JOIN envios` (en funciones SQL)
5. Índices: `idx_shipments_*` → `idx_envios_*`

**Estimación**: ~50+ líneas afectadas

#### Paso 1.4: Revisar 20260320000001_brickman_rag.sql
- Verificar si usa tablas incorrectas
- Aplicar correcciones si necesario

#### Paso 1.5: Revisar 20260322000000_add_logistics_integration.sql
- Verificar referencias a tablas
- Corregir si necesario

#### Paso 1.6: Corregir 20260323000000_update_assignment_with_history_check.sql
- Cambiar `assignments` → `envios`
- Revisar nombres de funciones y procedimientos

#### Paso 1.7: Revisar 20260324000000_fix_users_visibility_all_roles.sql
- Verificar que no tenga problemas de nomenclatura

### Fase 2: Aplicación de Migraciones

#### Opción A: Aplicación Automática (Recomendada)
```bash
# Una vez corregidos todos los archivos:
supabase db push
```

**Ventajas**:
- Registra correctamente en historial de migraciones
- Mantiene consistencia entre local y remoto
- Reversible con `supabase migration down`

**Desventajas**:
- Requiere corrección previa de todos los archivos

#### Opción B: Aplicación Manual (No recomendada)
```bash
# Aplicar cada migración manualmente desde dashboard de Supabase
```

**Ventajas**:
- Control total sobre cada paso

**Desventajas**:
- No se registra en historial local
- Dificulta sincronización futura
- Propenso a errores de sincronización

### Fase 3: Verificación Post-Migración

```bash
# 1. Verificar estado de migraciones
supabase migration list

# 2. Verificar que todas muestren "Remote" poblado
# Esperado: Las 7 migraciones deben aparecer en columna Remote

# 3. Regenerar tipos TypeScript
supabase gen types typescript --linked > src/integrations/supabase/types.ts

# 4. Verificar en aplicación que todo funciona
npm run dev
```

## Comandos Útiles CLI

### Gestión de Migraciones
```bash
# Listar migraciones
supabase migration list

# Crear nueva migración
supabase migration new nombre_migracion

# Aplicar migraciones pendientes
supabase db push

# Revertir última migración
supabase migration down

# Ver diferencias con remoto
supabase db diff -f nombre_archivo

# Regenerar tipos
supabase gen types typescript --linked > src/integrations/supabase/types.ts
```

### Gestión de Funciones
```bash
# Listar funciones
supabase functions list

# Desplegar función
supabase functions deploy nombre-funcion

# Ver logs de función
supabase functions logs nombre-funcion
```

### Diagnóstico
```bash
# Ver estado general
supabase status

# Ver configuración del proyecto
cat supabase/config.toml

# Verificar conexión
supabase db ping
```

## Riesgos y Mitigaciones

### Riesgo Alto: Inconsistencia de Datos
**Escenario**: Aplicar migraciones con nombres de tabla incorrectos
**Impacto**: Fallos en aplicación, pérdida de funcionalidad
**Mitigación**: ✅ **Corregir TODAS las migraciones antes de aplicar**

### Riesgo Medio: Conflictos con Cambios Manuales
**Escenario**: La migración 20260319200000 fue parcialmente aplicada manualmente
**Impacto**: Errores de "ya existe" al aplicar migración
**Mitigación**: Usar `IF NOT EXISTS` y `DROP IF EXISTS`

### Riesgo Bajo: Pérdida de Sincronización
**Escenario**: Aplicar migraciones manualmente sin registrarlas
**Impacto**: Historial local difiere del remoto
**Mitigación**: Usar siempre `supabase db push`

## Checklist de Implementación

### Pre-requisitos
- [x] CLI instalado y configurado
- [x] Variables de entorno configuradas
- [x] Conexión a BD remota verificada
- [x] Backup de migraciones originales

### Correcciones Pendientes
- [ ] Corregir 20260319200000_chat_logs.sql (agregar IF NOT EXISTS)
- [x] Corregir 20260320000000_add_swikly_fields.sql (assignments → envios)
- [ ] Corregir 20260321000000_brickshare_pudo_qr_system.sql (shipments → envios, assignments → envios)
- [ ] Revisar 20260320000001_brickman_rag.sql
- [ ] Revisar 20260322000000_add_logistics_integration.sql
- [ ] Revisar 20260323000000_update_assignment_with_history_check.sql
- [ ] Revisar 20260324000000_fix_users_visibility_all_roles.sql

### Aplicación
- [ ] Ejecutar `supabase db push`
- [ ] Verificar que las 7 migraciones aparezcan como aplicadas
- [ ] Regenerar tipos TypeScript
- [ ] Probar aplicación en desarrollo
- [ ] Verificar funciones Edge en producción

### Post-Aplicación
- [ ] Documentar cambios en CHANGELOG
- [ ] Actualizar documentación de esquema
- [ ] Notificar al equipo de cambios en BD

## Recomendaciones Futuras

### 1. Convención de Nomenclatura
**Establecer estándar claro**:
- Inglés: `assignments`, `shipments`, `users`
- Español: `asignaciones`, `envios`, `usuarios`

**Decisión requerida**: Elegir UNO y mantener consistencia

### 2. Proceso de Migración
- Siempre usar CLI para migr aciones
- No aplicar cambios manualmente en dashboard
- Revisar migraciones antes de push
- Mantener migraciones pequeñas y atómicas

### 3. Testing
- Probar migraciones en entorno local primero
- Usar `supabase db reset` para pruebas limpias
- Documentar cambios de esquema

### 4. Documentación
- Actualizar schema dump tras cada migración exitosa
- Mantener README actualizado con comandos CLI
- Documentar decisiones de arquitectura

## Próximos Pasos Inmediatos

1. **AHORA**: Corregir las 6 migraciones restantes con problemas de nomenclatura
2. **SIGUIENTE**: Aplicar todas las migraciones con `supabase db push`
3. **VERIFICAR**: Confirmar que todo funciona correctamente
4. **REGENERAR**: Actualizar tipos TypeScript
5. **PROBAR**: Ejecutar suite de tests y verificar aplicación

## Contacto y Soporte

- **Documentación Supabase CLI**: https://supabase.com/docs/guides/cli
- **Supabase Discord**: https://discord.supabase.com
- **GitHub Issues**: Reportar problemas específicos del proyecto

---

**Última actualización**: 21/03/2026 18:30 CET
**Autor**: Análisis automatizado del sistema
**Estado**: Plan de acción definido - Pendiente de ejecución