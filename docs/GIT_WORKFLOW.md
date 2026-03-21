# Git & Deployment Workflow

## Estructura de ramas

```
origin/main      ← PRODUCCIÓN (desplegado en Vercel, dominio principal)
origin/develop   ← DESARROLLO (work-in-progress, preview URL en Vercel)
```

## Repositorio

- **GitHub:** https://github.com/EnriquePerez00/brickshare_antigravityonly
- **Producción (Vercel):** rama `main` → dominio principal
- **Preview (Vercel):** rama `develop` → URL preview automática de Vercel

---

## Flujo de trabajo diario

### 1. Trabajo local (siempre en `develop`)

```bash
# Asegurarte de estar en develop
git checkout develop

# Traer los últimos cambios del remoto
git pull origin develop

# ... haces cambios en el código ...

# Guardar cambios
git add .
git commit -m "feat: descripción del cambio"

# Subir a remoto
git push origin develop
```

### 2. Validar cambios antes de pasar a producción

Una vez que los cambios en `develop` están listos y probados:

1. Ve a **GitHub → Pull Requests → New Pull Request**
2. Selecciona: `base: main` ← `compare: develop`
3. Revisa el diff de cambios
4. Haz **Merge** cuando todo esté validado
5. Vercel desplegará automáticamente a producción

### 3. Sincronizar `develop` con los últimos cambios de `main`

Si `main` recibe cambios directos (hotfixes, etc.), sincroniza `develop`:

```bash
git checkout develop
git merge main
git push origin develop
```

---

## Comandos de referencia rápida

| Acción | Comando |
|---|---|
| Ver rama actual | `git branch` |
| Cambiar a develop | `git checkout develop` |
| Ver estado de cambios | `git status` |
| Subir cambios | `git push origin develop` |
| Ver diferencias antes de commit | `git diff` |
| Ver historial | `git log --oneline -10` |

---

## Configuración Vercel

Vercel genera automáticamente una **Preview URL** para cada rama distinta de `main`.

- `main` → producción (dominio configurado en Vercel dashboard)
- `develop` → preview URL automática (ej: `brickshare-git-develop-xxx.vercel.app`)

Para ver/configurar las ramas en Vercel:
1. Entra a [vercel.com/dashboard](https://vercel.com/dashboard)
2. Selecciona tu proyecto Brickshare
3. **Settings → Git → Production Branch** → debe ser `main`
4. Todas las demás ramas generan previews automáticamente

---

## Notas importantes

- **Nunca hagas `push` directamente a `main` en el día a día** — usa siempre Pull Requests desde `develop`
- Los cambios en `develop` no afectan a los usuarios en producción hasta que se mergea a `main`
- Puedes usar `git stash` para guardar cambios temporalmente si necesitas cambiar de contexto