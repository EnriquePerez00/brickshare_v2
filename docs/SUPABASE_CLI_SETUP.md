# Configuración de Supabase CLI - Guía Completa

## 🚨 Problema Identificado

El comando `supabase login` no está generando correctamente el access token necesario para autenticar el CLI contra la API de Supabase, resultando en errores "Unauthorized" al intentar vincular el proyecto.

## ✅ Solución: Generar Access Token Manualmente

### Paso 1: Generar Access Token en Dashboard

1. Ve al dashboard de Supabase: https://supabase.com/dashboard/account/tokens
2. Inicia sesión con tu cuenta
3. En la sección "Access Tokens", haz clic en "Generate new token"
4. Dale un nombre descriptivo, por ejemplo: "CLI Local Dev"
5. Copia el token generado (empieza con `sbp_...`)

### Paso 2: Guardar el Token Localmente

```bash
# Crear el directorio de configuración si no existe
mkdir -p ~/.supabase

# Guardar el token (reemplaza YOUR_TOKEN con el token que copiaste)
echo "YOUR_TOKEN_HERE" > ~/.supabase/access-token

# Verificar que se guardó correctamente
cat ~/.supabase/access-token
```

### Paso 3: Vincular el Proyecto

```bash
# Vincular el proyecto remoto
supabase link --project-ref tevoogkifiszfontzkgd --password "Urgell175177"

# Verificar la vinculación
supabase status
```

### Paso 4: Verificar que Funciona

```bash
# Listar proyectos disponibles
supabase projects list

# Ver funciones desplegadas
supabase functions list

# Listar migraciones
supabase migration list
```

## 📋 Comandos Útiles (Sin Docker)

Una vez vinculado el proyecto, estos son los comandos principales para trabajar con Supabase remoto:

### Migraciones

```bash
# Aplicar migraciones pendientes al proyecto remoto
supabase db push

# Traer migraciones del remoto al local
supabase db pull

# Crear nueva migración
supabase migration new nombre_migracion

# Ver lista de migraciones
supabase migration list

# Exportar esquema actual
supabase db dump --schema public --file docs/schema.sql
```

### Edge Functions

```bash
# Desplegar una función
supabase functions deploy nombre-funcion

# Desplegar todas las funciones
supabase functions deploy

# Ver logs de una función
supabase functions logs nombre-funcion

# Eliminar una función
supabase functions delete nombre-funcion

# Listar funciones desplegadas
supabase functions list
```

### Generación de Tipos TypeScript

```bash
# Generar tipos desde el esquema actual
supabase gen types typescript --project-id tevoogkifiszfontzkgd > src/integrations/supabase/types.ts

# O usando el linked project
supabase gen types typescript --linked > src/integrations/supabase/types.ts
```

### Base de Datos

```bash
# Ejecutar consultas SQL
supabase db query "SELECT * FROM users LIMIT 5"

# Ver diferencias entre local y remoto
supabase db diff

# Reset de la base de datos (¡CUIDADO! Solo en desarrollo)
supabase db reset
```

## 🔧 Configuración del Proyecto

### Archivo `.env.local` (Ya configurado)

```env
SUPABASE_URL=https://tevoogkifiszfontzkgd.supabase.co
SUPABASE_SERVICE_ROLE_KEY=<obtener del dashboard de Supabase>
SUPABASE_ACCESS_TOKEN=<generar desde dashboard>
SUPABASE_DB_PASSWORD=<configurar en Supabase>
```

**Nota**: El `SUPABASE_ACCESS_TOKEN` en `.env.local` está desactualizado o inválido. Usa el nuevo token que generes desde el dashboard.

### Archivo `supabase/config.toml` (Ya configurado)

```toml
project_id = "tevoogkifiszfontzkgd"

[functions.delete-user]
verify_jwt = true

[functions.submit-donation]
verify_jwt = false

[functions.change-subscription]
verify_jwt = true

[functions.add-lego-set]
verify_jwt = false

[functions.correos-pudo]
verify_jwt = false

[functions.brickman-chat]
verify_jwt = false
```

## 🚫 Comandos NO Disponibles (Requieren Docker Local)

Estos comandos NO funcionarán ya que no usas entorno local:

```bash
supabase start     # Iniciar Supabase localmente
supabase stop      # Detener Supabase local
supabase restart   # Reiniciar servicios locales
supabase db reset  # Reset BD local
```

## 📝 Scripts NPM Personalizados

```bash
# Exportar esquema de base de datos
npm run dump-schema

# Desarrollar aplicación web
npm run dev

# Build de producción
npm run build
```

## ⚠️ Troubleshooting

### Error: "Unauthorized" al vincular proyecto

**Causa**: Token de acceso inválido o expirado.

**Solución**:
1. Generar nuevo token desde https://supabase.com/dashboard/account/tokens
2. Guardar en `~/.supabase/access-token`
3. Intentar vincular nuevamente

### Error: "Cannot connect to Docker daemon"

**Causa**: Intentando usar comandos que requieren Docker local.

**Solución**: Solo usa comandos remotos (`db push`, `functions deploy`, etc.)

### Error: "Project not linked"

**Causa**: No se ha vinculado el proyecto correctamente.

**Solución**:
```bash
supabase link --project-ref tevoogkifiszfontzkgd --password "Urgell175177"
```

### Error: "Database password authentication failed"

**Causa**: Contraseña incorrecta.

**Solución**: Verificar que la contraseña en `.env.local` es correcta: `Urgell175177`

## 🎯 Workflow Recomendado

1. **Hacer cambios en código localmente**
   - Editar archivos TypeScript/React
   - Crear migraciones SQL en `supabase/migrations/`
   - Desarrollar Edge Functions en `supabase/functions/`

2. **Aplicar cambios al proyecto remoto**
   ```bash
   # Aplicar migraciones
   supabase db push
   
   # Desplegar funciones
   supabase functions deploy nombre-funcion
   
   # Generar tipos actualizados
   supabase gen types typescript --linked > src/integrations/supabase/types.ts
   ```

3. **Verificar cambios**
   - Probar en el dashboard: https://supabase.com/dashboard/project/tevoogkifiszfontzkgd
   - Verificar logs de funciones
   - Comprobar datos en tablas

4. **Commit y push**
   ```bash
   git add .
   git commit -m "feat: descripción de cambios"
   git push origin develop
   ```

## 📚 Referencias

- [Supabase CLI Documentation](https://supabase.com/docs/guides/cli)
- [Supabase Management API](https://supabase.com/docs/reference/api/introduction)
- [Edge Functions Guide](https://supabase.com/docs/guides/functions)
- [Database Migrations](https://supabase.com/docs/guides/cli/local-development#database-migrations)

---

**Última actualización**: 21/03/2026  
**Project ID**: tevoogkifiszfontzkgd  
**Modo de trabajo**: Solo remoto (sin Docker)