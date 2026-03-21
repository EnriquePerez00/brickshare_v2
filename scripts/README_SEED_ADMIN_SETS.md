# 🚀 Seed Admin User and Sample Sets

Este script crea un usuario administrador y 15 sets de LEGO de muestra en la base de datos de Brickshare.

## 📦 Contenido

- **1 Usuario Admin**: admin@brickshare.com (password: Admin2test)
- **5 Sets City**: Mini sets de la serie LEGO City
- **5 Sets Star Wars**: Mini sets de la serie LEGO Star Wars  
- **5 Sets Architecture**: Sets de la serie LEGO Architecture

Todos los datos fueron obtenidos de la API de Rebrickable.

## 🔑 API Key Utilizada

```
REBRICKABLE_API_KEY=a52f6e7e9cb8c225d1339dcfda8b6ae7
```

## 📋 Requisitos Previos

1. Tener Supabase CLI instalado
2. Estar conectado a tu proyecto de Supabase
3. Tener acceso a la base de datos

## 🛠️ Instrucciones de Ejecución

### Método 1: Usando Supabase Dashboard (Recomendado) ⭐

**Paso 1**: Ejecuta el script SQL para crear los 15 sets:

```bash
supabase db execute --file scripts/seed-admin-and-sets.sql
```

O si usas psql:

```bash
psql postgres://postgres:[YOUR-PASSWORD]@db.[YOUR-PROJECT-REF].supabase.co:5432/postgres \
  -f scripts/seed-admin-and-sets.sql
```

**Paso 2**: Ve al dashboard de Supabase Authentication y crea el usuario admin:
1. Abre tu proyecto en https://supabase.com/dashboard
2. Ve a "Authentication" → "Users"
3. Click en "Add user" → "Create new user"
4. Ingresa:
   - Email: `admin@brickshare.com`
   - Password: `Admin2test`
   - Confirma el email automáticamente (marca la casilla si está disponible)

**Paso 3**: Una vez creado el usuario, asígnale el rol de admin manualmente:

```sql
-- Obtén el UUID del usuario recién creado
SELECT id FROM auth.users WHERE email = 'admin@brickshare.com';

-- Asigna el rol de admin (reemplaza YOUR_UUID_HERE con el UUID obtenido)
INSERT INTO public.user_roles (user_id, role) 
VALUES ('YOUR_UUID_HERE', 'admin');
```

### Método 2: Usando la API de Supabase

Si prefieres usar curl, puedes crear el usuario con la API de Supabase:

```bash
# Obtén tu SUPABASE_URL y ANON_KEY del dashboard
export SUPABASE_URL="https://your-project.supabase.co"
export SUPABASE_ANON_KEY="your-anon-key"

# Crear usuario
curl -X POST "${SUPABASE_URL}/auth/v1/signup" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@brickshare.com",
    "password": "Admin2test"
  }'
```

Luego asigna el rol de admin como en el Método 1, Paso 3.

### Método 3: Registrarse desde la Aplicación

La forma más simple:
1. Ejecuta el script SQL (Método 1, Paso 1)
2. Ve a tu aplicación Brickshare
3. Regístrate normalmente con:
   - Email: `admin@brickshare.com`
   - Password: `Admin2test`
4. Asigna el rol de admin con SQL (Método 1, Paso 3)

### Verificar la Instalación

Puedes verificar que todo se creó correctamente ejecutando estas consultas:

```sql
-- Verificar usuario admin
SELECT * FROM public.users WHERE email = 'admin@brickshare.com';

-- Verificar roles
SELECT * FROM public.user_roles WHERE user_id = 'TU_UUID_AQUI';

-- Verificar sets insertados
SELECT set_ref, set_name, set_theme, set_piece_count 
FROM public.sets 
ORDER BY set_theme, set_ref;

-- Verificar inventario (debe crearse automáticamente por trigger)
SELECT s.set_ref, s.set_name, i.inventory_set_total_qty 
FROM public.sets s
LEFT JOIN public.inventory_sets i ON s.id = i.set_id;
```

## 📊 Sets Incluidos

### City (5 sets)
- 30016: Small Satellite
- 30224: Lawn Mower
- 30314: Go-Kart Racer
- 30315: Space Utility Vehicle
- 30350: Volcano Jackhammer

### Star Wars (5 sets)
- 20006: Clone Turbo Tank
- 20007: Republic Attack Cruiser
- 20009: AT-TE Walker
- 20010: Republic Gunship
- 20016: Imperial Shuttle

### Architecture (5 sets)
- 19710: Sears Tower (Brickstructures Version)
- 19720: John Hancock Center (Brickstructures Version)
- 21000: Sears Tower
- 21000-2: Willis Tower
- 21001: John Hancock Center

## 🔍 Detalles Técnicos

### Triggers Automáticos

El script se beneficia del trigger `on_set_created` que automáticamente:
- Crea una entrada en `inventory_sets` por cada set insertado
- Inicializa los contadores de inventario a 0

### Estructura de Datos

Cada set incluye:
- `set_name`: Nombre del set
- `set_description`: Descripción generada
- `set_image_url`: URL de imagen de Rebrickable
- `set_theme`: Tema del set (City, Star Wars, Architecture)
- `set_age_range`: Rango de edad recomendado
- `set_piece_count`: Número de piezas
- `year_released`: Año de lanzamiento
- `set_ref`: Referencia oficial de LEGO
- `set_status`: Estado inicial 'disponible'
- `set_price`: Precio estimado en euros
- `set_weight`: Peso estimado en gramos
- `set_minifigs`: Número de minifiguras

### Usuario Admin

El usuario admin se crea en tres tablas:
1. **auth.users**: Sistema de autenticación de Supabase (mediante CLI)
2. **public.users**: Datos de usuario de la aplicación
3. **public.profiles**: Perfil público del usuario
4. **public.user_roles**: Rol de administrador

## ⚠️ Notas Importantes

1. **Contraseña segura**: En producción, cambia la contraseña `Admin2test` por una más segura
2. **Verificación de email**: Si tu proyecto requiere verificación de email, actívala manualmente desde el dashboard
3. **Idempotencia**: El script SQL usa `ON CONFLICT DO NOTHING` para evitar duplicados al insertar sets
4. **Inventario automático**: El trigger `on_set_created` creará automáticamente las entradas en `inventory_sets`
5. **Rol de admin**: Debe asignarse manualmente después de crear el usuario

## 🐛 Solución de Problemas

### Error: "duplicate key value violates unique constraint"
- Ya existe un usuario con ese email. Usa un email diferente o elimina el usuario existente.

### Error: "insert or update on table violates foreign key constraint"
- El UUID del usuario no existe en auth.users. Verifica que creaste el usuario correctamente usando uno de los métodos indicados.

### Error: "User already registered"
- Ya existe un usuario con ese email. Puedes:
  - Usar el usuario existente y solo asignarle el rol de admin
  - Eliminar el usuario existente desde el dashboard de Supabase
  - Usar un email diferente

### Los sets no aparecen en inventory_sets
- Verifica que el trigger `on_set_created` está activo:
  ```sql
  SELECT * FROM information_schema.triggers 
  WHERE trigger_name = 'on_set_created';
  ```

## 📚 Referencias

- [Rebrickable API](https://rebrickable.com/api/)
- [Supabase Auth CLI](https://supabase.com/docs/reference/cli/auth)
- [Base de Datos Schema](../docs/DATABASE_SCHEMA.md)