# Sistema de Actualización Automática del Esquema de Base de Datos

## 📋 Descripción

Este sistema mantiene automáticamente actualizado el archivo `docs/schema.sql` con el esquema completo de la base de datos de Supabase (`public` schema) cada vez que se realiza un commit.

## 🎯 Componentes

### 1. Git Hook Pre-commit
**Ubicación**: `.git/hooks/pre-commit`

Se ejecuta automáticamente antes de cada commit y:
- Verifica que Supabase CLI esté instalado
- Genera un dump del esquema `public`
- Guarda el resultado en `docs/schema.sql`
- Añade el archivo al commit si hubo cambios

### 2. Script NPM Manual
**Comando**: `npm run dump-schema`

Para regenerar el esquema manualmente cuando sea necesario.

### 3. Script de Instalación
**Ubicación**: `scripts/install-hooks.sh`

Script para instalar el git hook en máquinas de otros desarrolladores.

## 🚀 Configuración Inicial

### Para el primer uso:

**Sigue la guía completa de configuración en [SUPABASE_CLI_SETUP.md](./SUPABASE_CLI_SETUP.md)**

Resumen de pasos:
```bash
# 1. Genera access token desde dashboard de Supabase
# https://supabase.com/dashboard/account/tokens

# 2. Guarda el token localmente
mkdir -p ~/.supabase
echo "TU_TOKEN_AQUI" > ~/.supabase/access-token

# 3. Vincula el proyecto
supabase link --project-ref tevoogkifiszfontzkgd --password "Urgell175177"

# 4. Verifica que funciona
npm run dump-schema
```

### Para otros desarrolladores:

```bash
# Ejecuta el script de instalación
./scripts/install-hooks.sh

# Sigue las instrucciones de configuración que aparecen
```

## 📝 Uso

### Automático
El hook se ejecutará automáticamente en cada commit. Verás un mensaje como:

```
🔄 Actualizando esquema de base de datos...
✅ Esquema actualizado en docs/schema.sql
   Agregando docs/schema.sql al commit...
```

### Manual
Si necesitas regenerar el esquema sin hacer commit:

```bash
npm run dump-schema
```

## ⚠️ Solución de Problemas

### Error: "Supabase CLI no autenticado"

```bash
supabase login
supabase link --project-ref tevoogkifiszfontzkgd
```

### Error: "password authentication failed"

**Causa**: Contraseña de base de datos incorrecta.

**Solución**: Verificar que usas la contraseña correcta: `Urgell175177`

```bash
supabase link --project-ref tevoogkifiszfontzkgd --password "Urgell175177"
```

### Error: "Unauthorized"

**Causa**: Access token inválido o expirado.

**Solución**: Genera un nuevo token desde el dashboard y guárdalo:
```bash
# 1. Ve a https://supabase.com/dashboard/account/tokens
# 2. Genera nuevo token
# 3. Guárdalo localmente
echo "NUEVO_TOKEN" > ~/.supabase/access-token
```

Ver guía completa en [SUPABASE_CLI_SETUP.md](./SUPABASE_CLI_SETUP.md)

### El hook no se ejecuta

Verifica que sea ejecutable:
```bash
chmod +x .git/hooks/pre-commit
```

### Quiero deshabilitar temporalmente el hook

Renombra el archivo:
```bash
mv .git/hooks/pre-commit .git/hooks/pre-commit.disabled
```

Para reactivarlo:
```bash
mv .git/hooks/pre-commit.disabled .git/hooks/pre-commit
```

## 📂 Archivos del Sistema

```
.git/hooks/pre-commit           # Hook que se ejecuta en cada commit
docs/schema.sql                  # Esquema generado automáticamente
scripts/install-hooks.sh         # Instalador para otros devs
package.json                     # Contiene script "dump-schema"
```

## 🔄 Flujo de Trabajo

```
1. Desarrollador hace cambios en migraciones SQL
   ↓
2. Ejecuta: git add . && git commit -m "..."
   ↓
3. El pre-commit hook se activa automáticamente
   ↓
4. Se genera docs/schema.sql con el esquema actual
   ↓
5. Si hay cambios, se añade al commit automáticamente
   ↓
6. El commit se completa con código + esquema actualizado
```

## 💡 Beneficios

✅ **Documentación siempre actualizada**: El esquema en docs/ refleja el estado real de la BD
✅ **Revisión de cambios**: En pull requests se pueden ver los cambios de esquema
✅ **Historial completo**: Git mantiene historial de evolución del esquema
✅ **Automatización**: Cero esfuerzo manual para mantener sincronizado

## 📚 Referencias

- [Supabase CLI Documentation](https://supabase.com/docs/guides/cli)
- [Git Hooks Documentation](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks)

---

**Última actualización**: 21/03/2026  
**Mantenedor**: Equipo Brickshare