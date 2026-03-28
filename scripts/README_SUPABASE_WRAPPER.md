# Supabase Wrapper - Backup Automático en DB Reset

## Problema Resuelto

Cuando ejecutabas `supabase db reset`, NO se hacía backup automático de la base de datos, lo que podía resultar en pérdida de datos si algo salía mal.

**Causa**: Los hooks de Git (como `.git/hooks/pre-db-reset`) solo funcionan con comandos Git (`git commit`, `git push`, etc.), NO con comandos externos como `supabase db reset`.

## Solución Implementada

Hemos creado un **wrapper de Supabase CLI** que intercepta el comando `supabase db reset` y ejecuta automáticamente el script de backup antes del reset.

## Archivos Creados

1. **`scripts/supabase-wrapper.sh`** - Wrapper que intercepta comandos supabase
2. **`scripts/setup-supabase-alias.sh`** - Script de configuración automática

## Instalación (Una Sola Vez)

### Opción 1: Configuración Automática (Recomendado)

```bash
./scripts/setup-supabase-alias.sh
source ~/.zshrc  # o source ~/.bashrc si usas bash
```

Este script:
- ✅ Detecta automáticamente tu shell (zsh o bash)
- ✅ Añade el alias a tu archivo de configuración
- ✅ Maneja conflictos si ya existe un alias 'supabase'
- ✅ Usa rutas absolutas para funcionar desde cualquier directorio

### Opción 2: Configuración Manual

Añade esto al final de tu `~/.zshrc` (o `~/.bashrc`):

```bash
# ════════════════════════════════════════════════════════
# Brickshare - Supabase wrapper para backup automático
# ════════════════════════════════════════════════════════
alias supabase='/Users/I764690/Code_personal/Brickshare/scripts/supabase-wrapper.sh'
```

Luego recarga:
```bash
source ~/.zshrc
```

## Verificación

Verifica que el alias está configurado correctamente:

```bash
# Debería mostrar la ruta al wrapper
which supabase

# Debería mostrar: /Users/I764690/Code_personal/Brickshare/scripts/supabase-wrapper.sh
```

## Uso

### Comandos Interceptados

```bash
# ✅ INTERCEPTADO - Hace backup automático antes del reset
supabase db reset
supabase db reset --local
supabase db reset --local --debug

# El wrapper automáticamente:
# 1. Detecta que es un comando 'db reset'
# 2. Ejecuta ./scripts/db-reset.sh (que incluye backup)
# 3. Pasa cualquier flag adicional que hayas usado
```

### Otros Comandos (Pasan Directamente)

```bash
# ❌ NO INTERCEPTADOS - Pasan directamente a supabase CLI
supabase start
supabase status
supabase migration new
supabase functions deploy
# ... cualquier otro comando supabase
```

## Cómo Funciona

### Flujo del Wrapper

```
Usuario ejecuta: supabase db reset
         ↓
wrapper detecta "db reset"
         ↓
ejecuta: ./scripts/db-reset.sh
         ↓
db-reset.sh hace backup
         ↓
db-reset.sh ejecuta: supabase db reset
         ↓
Reset completado con backup guardado
```

### Código del Wrapper (Simplificado)

```bash
if [[ "$1" == "db" && "$2" == "reset" ]]; then
    # Interceptar y ejecutar con backup
    ./scripts/db-reset.sh "${@:3}"
else
    # Pasar directamente a supabase CLI
    command supabase "$@"
fi
```

## Ventajas

✅ **Transparente**: No necesitas cambiar tu workflow  
✅ **Automático**: El backup se hace automáticamente  
✅ **Compatible**: Todos los comandos supabase funcionan igual  
✅ **Seguro**: Siempre hay un backup antes del reset  
✅ **Flexible**: Acepta todos los flags de `db reset`

## Backups Generados

Los backups se guardan en:

```
supabase/backups/
├── dump_reset_YYYYMMDD_HHMMSS.sql  # Backups individuales
└── latest/                          # Symlink al último backup
```

## Restaurar un Backup

Si necesitas restaurar después de un reset:

```bash
# Ver backups disponibles
ls -lh supabase/backups/

# Restaurar el último backup
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres \
  < supabase/backups/dump_reset_20260325_102000.sql
```

## Desinstalación

Si quieres volver al comando supabase original:

```bash
# Editar tu ~/.zshrc o ~/.bashrc
nano ~/.zshrc

# Eliminar o comentar la línea del alias:
# alias supabase='/path/to/supabase-wrapper.sh'

# Recargar
source ~/.zshrc

# Verificar
which supabase
# Debería mostrar: /usr/local/bin/supabase (o donde esté instalado)
```

## Troubleshooting

### El alias no funciona

```bash
# Verificar que está en tu archivo de configuración
grep "supabase" ~/.zshrc

# Recargar configuración
source ~/.zshrc

# Verificar
which supabase
```

### Error: "No se encontró ./scripts/db-reset.sh"

Asegúrate de estar en el directorio raíz del proyecto Brickshare:

```bash
cd /Users/I764690/Code_personal/Brickshare
supabase db reset
```

### Quiero usar el comando original sin backup

```bash
# Opción 1: Usar el comando completo
command supabase db reset

# Opción 2: Desactivar temporalmente el alias
unalias supabase
supabase db reset
# Recargar para recuperar el alias
source ~/.zshrc
```

## Alternativas si No Quieres Alias

Si prefieres NO usar alias, puedes:

### Opción A: Usar siempre el script directamente

```bash
./scripts/db-reset.sh
```

### Opción B: Función en lugar de alias

Añade esto a tu `~/.zshrc`:

```bash
supabase() {
    if [[ "$1" == "db" && "$2" == "reset" ]]; then
        /Users/I764690/Code_personal/Brickshare/scripts/db-reset.sh "${@:3}"
    else
        command supabase "$@"
    fi
}
```

Ventaja: La función tiene mayor prioridad que los aliases.

## Documentos Relacionados

- `docs/GIT_HOOKS_LIMITATION.md` - Explicación de por qué los Git hooks no funcionan
- `scripts/README_SAFE_DB_RESET.md` - Documentación del script db-reset.sh
- `scripts/README_BACKUP_RESTORE.md` - Guía de backup y restauración

## Resumen

| Antes | Después |
|-------|---------|
| `supabase db reset` → ❌ Sin backup | `supabase db reset` → ✅ Backup automático |
| Manual: `./scripts/db-reset.sh` | Automático con alias |
| Riesgo de pérdida de datos | Siempre hay backup |

**Recomendación Final**: Ejecuta una vez `./scripts/setup-supabase-alias.sh` y olvídate del problema. Tus resets siempre tendrán backup automático.