# Limitación de Git Hooks para `supabase db reset`

**Fecha**: 2026-03-25  
**Problema**: El hook `pre-db-reset` no se ejecutó automáticamente  
**Causa**: Los hooks de Git NO se activan para comandos que no son de Git

## Problema Detectado

Al ejecutar `supabase db reset --local`, se esperaba que el hook `.git/hooks/pre-db-reset` se activara automáticamente para crear un backup de la base de datos. Sin embargo, esto **NO ocurrió**.

## Causa Raíz

**Los hooks de Git solo se activan para comandos Git:**

| Comando | Hook que se activa |
|---------|-------------------|
| `git commit` | `pre-commit`, `commit-msg`, `post-commit` |
| `git push` | `pre-push` |
| `git merge` | `pre-merge-commit` |
| `git rebase` | `pre-rebase` |
| `git checkout` | `post-checkout` |

**Los comandos externos NO activan hooks de Git:**
- ❌ `supabase db reset` 
- ❌ `npm run script`
- ❌ `make build`
- ❌ Cualquier comando que no sea `git`

Git no tiene forma de interceptar comandos externos como `supabase`, porque Git hooks son un mecanismo interno del sistema de control de versiones.

## Estado Actual

### Hook Creado (pero no funcional para este caso)
```bash
.git/hooks/pre-db-reset  # Existe pero nunca se ejecuta
```

Este hook fue creado con la esperanza de que se activara antes de `supabase db reset`, pero **Git no puede interceptar este comando** porque no es un comando Git.

### Backups Disponibles
```bash
supabase/backups/dump_reset_20260324_234744.sql  # Último backup (24 Mar)
```

El último backup automático es del 24 de marzo. El reset de hoy (25 de marzo) **NO generó backup**.

## Soluciones

### Solución 1: Usar el Script Wrapper (RECOMENDADO)

**Siempre usa el script `db-reset.sh` en lugar de `supabase db reset` directamente:**

```bash
# ✅ CORRECTO - Hace backup automático
./scripts/db-reset.sh

# ❌ INCORRECTO - NO hace backup
supabase db reset --local
```

El script `db-reset.sh` ya incluye el backup automático antes de hacer el reset.

### Solución 2: Alias de Shell

Añade un alias a tu shell (`~/.zshrc` o `~/.bashrc`):

```bash
# Añadir al final del archivo
alias supabase-reset='./scripts/db-reset.sh'
alias sdb-reset='./scripts/db-reset.sh'

# Recargar configuración
source ~/.zshrc  # o source ~/.bashrc
```

Entonces usa:
```bash
supabase-reset  # En lugar de supabase db reset
```

### Solución 3: Función de Shell (Más avanzado)

Añade esto a tu `~/.zshrc` o `~/.bashrc`:

```bash
# Override supabase command para interceptar db reset
supabase() {
    if [[ "$1" == "db" && "$2" == "reset" ]]; then
        echo "⚠️  Interceptando 'supabase db reset' para hacer backup..."
        if [[ -f "./scripts/db-reset.sh" ]]; then
            ./scripts/db-reset.sh "${@:3}"
        else
            echo "❌ Script db-reset.sh no encontrado. Ejecutando comando original..."
            command supabase "$@"
        fi
    else
        command supabase "$@"
    fi
}
```

Con esto, cualquier `supabase db reset` se redirigirá automáticamente a `db-reset.sh`.

## Alternativa: Hook en Supabase CLI

**Nota**: Supabase CLI no tiene un sistema de hooks nativo. La única forma de interceptar comandos Supabase es mediante:

1. **Shell wrappers** (scripts)
2. **Shell aliases** (atajos)
3. **Shell functions** (funciones que sobrescriben comandos)

## Recomendación Final

### Para Uso Inmediato
```bash
# Siempre usa:
./scripts/db-reset.sh

# NUNCA uses directamente:
supabase db reset --local
```

### Para Evitar Olvidos (Setup una vez)
```bash
# 1. Abrir archivo de configuración shell
nano ~/.zshrc  # o ~/.bashrc para bash

# 2. Añadir al final:
alias sdb-reset='./scripts/db-reset.sh'

# 3. Recargar
source ~/.zshrc

# 4. Usar en el futuro:
sdb-reset  # En lugar de supabase db reset
```

## ¿Por Qué Existe el Hook `pre-db-reset` Entonces?

El archivo `.git/hooks/pre-db-reset` fue creado por error, basándose en la suposición incorrecta de que Git hooks pueden interceptar comandos externos. 

### Opciones:
1. **Eliminarlo** - Ya que nunca se ejecutará
2. **Dejarlo como documentación** - Como referencia del código de backup
3. **Moverlo a `scripts/`** - Como parte de `db-reset.sh`

**Recomendación**: Dejarlo como está, pero actualizar la documentación para aclarar que no se ejecuta automáticamente y que debe usarse `scripts/db-reset.sh`.

## Archivos Relacionados

- `.git/hooks/pre-db-reset` - Hook que NO se ejecuta (Git limitation)
- `scripts/db-reset.sh` - Script correcto que SÍ hace backup
- `scripts/safe-db-reset.sh` - Alternativa más segura con confirmación
- `docs/DATABASE_SCHEMA.md` - Documentación del esquema
- `supabase/backups/` - Directorio de backups

## Lección Aprendida

**Git hooks solo funcionan para comandos Git.** Para interceptar comandos de herramientas externas como Supabase CLI, debes usar wrappers de shell, aliases o funciones.