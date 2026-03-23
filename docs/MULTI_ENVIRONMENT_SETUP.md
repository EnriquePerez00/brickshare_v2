# 🏗️ Multi-Environment Docker Setup

Documentación para trabajar con 2 entornos Supabase locales simultáneos.

## 📋 Descripción General

Este proyecto está configurado para ejecutar **2 instancias independientes de Supabase en Docker**:

| Entorno | Propósito | Puerto DB | Puerto API | Puerto Studio | Directorio |
|---------|-----------|-----------|-----------|---------------|-----------|
| **MAIN** | Producción (Estable) | 5432 | 54321 | 54323 | `supabase-main/` |
| **DEVELOP** | Desarrollo (Activo) | 5433 | 54331 | 54333 | `supabase/` |

---

## 🚀 Quick Start

### Iniciar un entorno específico

```bash
# Iniciar DEVELOP (desarrollo - recomendado por defecto)
npm run supabase:start develop

# Iniciar MAIN (producción estable)
npm run supabase:start main

# Iniciar ambos (ejecutar en terminales separadas)
npm run supabase:start develop &
npm run supabase:start main
```

### Ver estado de ambos entornos

```bash
npm run supabase:status
```

### Detener entornos

```bash
# Detener ambos
npm run supabase:stop

# Detener solo uno
npm run supabase:stop develop
npm run supabase:stop main
```

---

## 🔧 Scripts de Gestión

Todos los scripts están en `scripts/supabase-environments.sh`. Se invocan con npm:

### Comandos disponibles

```bash
# Iniciar
npm run supabase:start [develop|main]

# Detener (sin argumentos = todos)
npm run supabase:stop [develop|main]

# Ver estado
npm run supabase:status

# Resetear base de datos
npm run supabase:reset [develop|main]

# Exportar dump SQL
npm run supabase:dump [develop|main]

# Mostrar ayuda
npm run supabase:help
```

---

## 🎯 Flujo de Trabajo Recomendado

### Escenario 1: Desarrollo Local (Default)

```bash
# 1. Inicia solo DEVELOP
npm run supabase:start develop

# 2. Frontend automáticamente usa .env.develop
npm run dev          # Usa puerto 54331 (develop)

# 3. Abre Studio de desarrollo
open http://127.0.0.1:54333
```

**Variables de entorno activas**: `.env.develop`  
**BD**: `localhost:5433`  
**API**: `http://127.0.0.1:54331`

---

### Escenario 2: Pruebas en Producción + Desarrollo

```bash
# 1. Terminal 1: Iniciar MAIN (estable)
npm run supabase:start main

# 2. Terminal 2: Iniciar DEVELOP (desarrollo)
npm run supabase:start develop

# 3. Terminal 3: Frontend apunta a DEVELOP por defecto
npm run dev          # Usa .env.develop

# 4. Para testear contra MAIN, cambia variables:
cp .env.main .env.local && npm run dev
```

**MAIN Studio**: `http://127.0.0.1:54323`  
**DEVELOP Studio**: `http://127.0.0.1:54333`

---

### Escenario 3: Sincronizar MAIN con DEVELOP

```bash
# 1. Exportar dump de DEVELOP
npm run supabase:dump develop

# 2. Copiar y restaurar en MAIN
# (actualmente manual, requeriría script adicional)
```

---

## 📁 Estructura de Directorios

```
Brickshare/
├── supabase/              # 🔵 DEVELOP (Puerto 5433)
│   ├── config.toml        # Puertos: 54331, 54333, 54332
│   ├── migrations/        # Migraciones compartidas
│   └── functions/         # Edge Functions
│
├── supabase-main/         # 🟢 MAIN (Puerto 5432)
│   ├── config.toml        # Puertos: 54321, 54323, 54322
│   ├── migrations/        # Mismo contenido que develop
│   └── functions/         # Mismo contenido que develop
│
├── .env.local             # Frontend (usa develop por defecto)
├── .env.develop           # Variables DEVELOP
├── .env.main              # Variables MAIN
│
└── scripts/
    └── supabase-environments.sh  # Script de gestión
```

---

## 🔌 Variables de Entorno

### `.env.develop` (Default)
```env
VITE_SUPABASE_URL=http://127.0.0.1:54331
VITE_SUPABASE_ANON_KEY=...
VITE_ENVIRONMENT=develop
```

### `.env.main`
```env
VITE_SUPABASE_URL=http://127.0.0.1:54321
VITE_SUPABASE_ANON_KEY=...
VITE_ENVIRONMENT=main
```

### Cambiar entorno del frontend
```bash
# Usar DEVELOP (default)
cp .env.develop .env.local

# Usar MAIN
cp .env.main .env.local

# Reiniciar frontend
npm run dev
```

---

## 🔍 Monitoreo y Debugging

### Ver logs de una instancia específica
```bash
cd supabase-develop
supabase logs --follow
```

### Conectar a la BD directamente
```bash
# DEVELOP (puerto 5433)
psql postgresql://postgres:postgres@127.0.0.1:5433/postgres

# MAIN (puerto 5432)
psql postgresql://postgres:postgres@127.0.0.1:5432/postgres
```

### Ver Studio en navegador
```bash
# DEVELOP Studio
open http://127.0.0.1:54333

# MAIN Studio
open http://127.0.0.1:54323
```

---

## 💾 Datos Persistentes

Ambos entornos usan **Docker volumes** separados:

```bash
# Ver volumes disponibles
docker volume ls --filter label=com.supabase.cli.project=tevoogkifiszfontzkgd

# Los datos persisten incluso si detienes los contenedores
# Se pierden solo si ejecutas supabase db reset
```

---

## ⚙️ Configuración por Entorno

### `supabase/config.toml` (DEVELOP)
```toml
[db]
port = 5433          # PostgreSQL puerto
shadow_port = 54330

[api]
port = 54331         # API REST

[studio]
port = 54333         # Studio UI

[vector]
port = 54332
```

### `supabase-main/config.toml` (MAIN)
```toml
[db]
port = 5432          # PostgreSQL puerto
shadow_port = 54320

[api]
port = 54321         # API REST

[studio]
port = 54323         # Studio UI

[vector]
port = 54322
```

---

## 🐛 Troubleshooting

### Puerto ya en uso
```bash
# Encontrar qué proceso usa el puerto
lsof -i :5432
lsof -i :54331

# Matar proceso
kill -9 <PID>
```

### No se inicia un contenedor
```bash
# Detener todo y limpiar
supabase stop

# Verificar estado Docker
docker ps -a

# Reintentar
npm run supabase:start develop
```

### BD corrupta
```bash
# Resetear completamente (PELIGRO: pierde datos)
npm run supabase:reset develop
```

### Variables de entorno no aplican
```bash
# Asegúrate de que .env.local existe
ls -la .env.*

# Verifica que frontend lee correctamente
console.log(import.meta.env.VITE_SUPABASE_URL)
```

---

## 📝 Migraciones en Multi-Ambiente

### Aplicar nueva migración
```bash
# Crear migración (automáticamente en ambos)
supabase migration new <nombre>

# Aplicar a DEVELOP
cd supabase && supabase db push

# Aplicar a MAIN
cd supabase-main && supabase db push
```

### Sincronizar después de cambios
```bash
# Copiar migraciones nuevas a ambos directorios
cp supabase/migrations/* supabase-main/migrations/

# Resetear ambos
npm run supabase:reset develop
npm run supabase:reset main
```

---

## 🎓 Casos de Uso Típicos

### ✅ Testing de cambios sin afectar main
```bash
npm run supabase:start develop
# ... desarrolla y prueba ...
npm run supabase:reset develop  # Reset solo develop
```

### ✅ Comparar comportamiento entre entornos
```bash
# Terminal 1: MAIN
npm run supabase:start main

# Terminal 2: DEVELOP
npm run supabase:start develop

# Terminal 3: Frontend contra DEVELOP
npm run dev
```

### ✅ Backup antes de reset peligroso
```bash
npm run supabase:dump develop > backup_$(date +%s).sql
npm run supabase:reset develop
```

---

## 🔐 Notas de Seguridad

⚠️ **ADVERTENCIA**: Esto es **solo para desarrollo local**. No usar en producción.

- Las credenciales de BD están hardcodeadas (solo local)
- Los datos están en Docker volumes locales
- No exponer estos puertos a internet
- Usar variab les de entorno seguras en producción

---

## 📚 Referencias

- [Documentación LOCAL_DEVELOPMENT.md](./LOCAL_DEVELOPMENT.md)
- [Supabase CLI Docs](https://supabase.com/docs/guides/cli)
- [Docker Documentation](https://docs.docker.com/)