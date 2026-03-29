# Safe Database Reset con Backup Automático

## 🎯 Propósito

El script `safe-db-reset.sh` ofrece una forma conveniente de resetear la base de datos local de Supabase con backup automático. Es una alternativa opcional a `supabase db reset` que añade protección de datos.

## 📋 Características

- ✅ Backup automático antes de cada reset
- ✅ Mantiene historial de backups con timestamp
- ✅ Guarda siempre el último backup en `supabase/dump_reset.sql`
- ✅ Verificación de que Supabase está corriendo
- ✅ Mensajes claros con colores
- ✅ Instrucciones de restauración incluidas
- ✅ Confirmación en caso de error en el backup

## 🚀 Uso

### Ejecutar el script

```bash
./scripts/safe-db-reset.sh
```

El script:
1. Verifica que Supabase esté corriendo
2. Crea un backup en `supabase/backups/dump_reset_YYYYMMDD_HHMMSS.sql`
3. Copia el backup a `supabase/dump_reset.sql` (último backup)
4. Ejecuta `supabase db reset`
5. Muestra instrucciones de restauración

### Salida esperada

```
═══════════════════════════════════════════════════════════════
  🛡️  Safe Database Reset con Backup Automático
═══════════════════════════════════════════════════════════════

📦 Creando backup de la base de datos...
   Archivo: supabase/backups/dump_reset_20260324_081900.sql
✅ Backup completado (2.3M)

   📁 Guardado en:
      • supabase/dump_reset.sql (último backup)
      • supabase/backups/dump_reset_20260324_081900.sql (con timestamp)

🔄 Ejecutando database reset...
═══════════════════════════════════════════════════════════════

[Output de supabase db reset...]

═══════════════════════════════════════════════════════════════
✅ Reset completado exitosamente

📝 Información del backup:
   • Último backup: supabase/dump_reset.sql
   • Backup con fecha: supabase/backups/dump_reset_20260324_081900.sql

💡 Para restaurar el backup:
   psql postgresql://postgres:postgres@127.0.0.1:5433/postgres < supabase/dump_reset.sql
═══════════════════════════════════════════════════════════════
```

## 🔄 Restaurar un Backup

### Restaurar el último backup

```bash
psql postgresql://postgres:postgres@127.0.0.1:5433/postgres < supabase/dump_reset.sql
```

### Restaurar un backup específico

```bash
psql postgresql://postgres:postgres@127.0.0.1:5433/postgres < supabase/backups/dump_reset_20260324_081900.sql
```

### Ver backups disponibles

```bash
ls -lh supabase/backups/
```

## 📁 Estructura de Archivos

```
supabase/
├── seed.sql                                 # Datos de seeding estáticos (versionado en Git)
├── dump_reset.sql                           # Último backup (NO versionado)
└── backups/                                 # Historial de backups (NO versionados)
    ├── dump_reset_20260324_081900.sql
    ├── dump_reset_20260324_101500.sql
    └── dump_reset_20260324_143000.sql
```

**Nota Importante**: 
- `seed.sql` es un archivo **estático e independiente** que contiene datos de seeding controlados manualmente
- Los backups (`dump_reset.sql` y `backups/`) son archivos **temporales** que NO se versionan en Git
- El script `safe-db-reset.sh` **NO modifica** el archivo `seed.sql`

## ⚠️ Notas Importantes

1. **seed.sql es independiente**: Es un archivo estático con datos de seeding controlados manualmente. NO se modifica automáticamente
2. **Los backups NO se versionan en Git**: Están en `.gitignore` para no llenar el repositorio
3. **Solo datos**: El backup incluye solo datos (`--data-only`), no el esquema (las migraciones ya lo tienen)
4. **Supabase debe estar corriendo**: El script verifica esto automáticamente
5. **Puerto correcto**: Usa el puerto 5433 (puerto local de Supabase)
6. **Historial local**: Los backups solo existen localmente, no en remoto

## 🆚 Comparación: `supabase db reset` vs `safe-db-reset.sh`

Ambas opciones son válidas. Elige según tu necesidad:

| Aspecto | `supabase db reset` | `safe-db-reset.sh` |
|---------|-------------------|-------------------|
| Velocidad | ⚡ Más rápido | ⚡⚡ Un poco más lento (hace backup) |
| Backup automático | ❌ No | ✅ Sí |
| Historial | ❌ No | ✅ Sí (con timestamp) |
| Restauración | Manual si necesita | ✅ Comando incluido |
| Casos de uso | Reset rápido durante desarrollo | Development general (recomendado) |

## 🔧 Troubleshooting

### Error: "Supabase no está corriendo"

```bash
# Iniciar Supabase
supabase start
```

### Error al crear backup

El script preguntará si deseas continuar sin backup. Es seguro continuar si:
- Acabas de hacer un reset reciente
- No tienes datos importantes
- Estás en desarrollo inicial

### Backups muy grandes

Si los backups ocupan mucho espacio, puedes limpiar manualmente:

```bash
# Ver tamaño de backups
du -sh supabase/backups/

# Eliminar backups antiguos (mantener últimos 5)
cd supabase/backups/
ls -t dump_reset_*.sql | tail -n +6 | xargs rm
```

## 🔗 Scripts Relacionados

- `reset-test-data.sql` - SQL directo para reset rápido
- `seed-admin-and-sets.sql` - Seed de datos iniciales
- `seed-users-wishlist.sql` - Seed de usuarios y wishlist

## 📝 Logging

El script no crea logs adicionales, pero puedes capturar la salida:

```bash
./scripts/safe-db-reset.sh 2>&1 | tee reset-log.txt
```

## 🎓 Ejemplo de Workflow Completo

```bash
# 1. Hacer cambios en la aplicación
npm run dev

# 2. Probar cambios en BD local
# ... hacer pruebas ...

# 3. Reset seguro con backup automático
./scripts/safe-db-reset.sh

# 4. Si algo sale mal, restaurar
psql postgresql://postgres:postgres@127.0.0.1:5433/postgres < supabase/dump_reset.sql