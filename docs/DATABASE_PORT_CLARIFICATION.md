# Clarificación de Puertos de Base de Datos Supabase Local

## 📌 Resumen Ejecutivo

El proyecto Brickshare usa **puerto 5433** para conectarse a PostgreSQL desde el host (tu máquina local), pero internamente Supabase usa el puerto 54322.

## 🔍 Contexto: Dos Puertos Válidos

Supabase Local en Docker expone PostgreSQL de dos formas:

### Puerto 54322 (Puerto Interno de Supabase)
- **Uso**: Conexiones desde **dentro del contenedor Docker** de Supabase
- **Documentación**: Aparece en muchas guías y docs oficiales de Supabase
- **Ejemplo**: `postgresql://postgres:postgres@127.0.0.1:54322/postgres`
- **Cuándo usar**: NO usar desde tu máquina local

### Puerto 5433 (Puerto Expuesto al Host) ✅
- **Uso**: Conexiones desde **tu máquina local** (fuera de Docker)
- **Configuración**: Definido en `supabase/config.toml`
- **Ejemplo**: `postgresql://postgres:postgres@127.0.0.1:5433/postgres`
- **Cuándo usar**: SIEMPRE que conectes con `psql` desde terminal

## ⚙️ Configuración en `supabase/config.toml`

```toml
[db]
port = 5433          # ✅ Puerto PostgreSQL expuesto al host
shadow_port = 54320

[api]
port = 54331         # Puerto API REST

[studio]
port = 54333         # Puerto Supabase Studio UI
```

## 📊 Tabla de Puertos del Proyecto

| Servicio | Puerto Host | Puerto Interno | URL de Conexión |
|---|---|---|---|
| **PostgreSQL** | **5433** | 54322 | `postgresql://postgres:postgres@127.0.0.1:5433/postgres` |
| **API REST** | 54331 | - | `http://127.0.0.1:54331` |
| **Studio UI** | 54333 | - | `http://127.0.0.1:54333` |
| **Mailpit** | 54334 | - | `http://127.0.0.1:54334` |

## ✅ Comando Correcto para Conectar

```bash
# ✅ CORRECTO - Usa puerto 5433
psql postgresql://postgres:postgres@127.0.0.1:5433/postgres

# ❌ INCORRECTO - Puerto 54322 no está expuesto al host
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres
# Error: connection to server at "127.0.0.1", port 54322 failed: Connection refused
```

## 🔄 Verificación Rápida

```bash
# Ver puertos activos de Supabase
supabase status

# Salida esperada incluye:
# Database: postgresql://postgres:postgres@127.0.0.1:5433/postgres
```

## 📝 Estado de la Documentación

### ✅ Ya Actualizado (Usa puerto 5433)
- `docs/ENVIRONMENT_VARIABLES_SUMMARY.md`
- `docs/LABEL_GENERATION_TROUBLESHOOTING.md`
- `docs/PUDO_IDS_FIX.md`
- Scripts recientes

### ⚠️ Pendiente de Actualización (Referencias obsoletas a 54322)
La mayoría de la documentación antigua sigue haciendo referencia al puerto **54322**, pero estas son referencias **obsoletas** que deben actualizarse a **5433**.

Archivos afectados:
- `claude.md`
- `README.md`
- `docs/LOCAL_DEVELOPMENT.md`
- `docs/MULTI_ENVIRONMENT_SETUP.md`
- Múltiples READMEs en `scripts/`
- Scripts de testing antiguos

## 🛠️ Acción Recomendada

**Para usuarios del proyecto**: Usar siempre `5433` al conectar desde terminal.

**Para mantenedores**: Se recomienda una actualización masiva con:

```bash
# Buscar y reemplazar en documentación
find docs -name "*.md" -type f -exec sed -i '' 's/54322/5433/g' {} +
find scripts -name "README*.md" -type f -exec sed -i '' 's/54322/5433/g' {} +

# Actualizar scripts SQL y shell
find scripts -name "*.sh" -type f -exec sed -i '' 's/54322/5433/g' {} +
find scripts -name "*.sql" -type f -exec sed -i '' 's/54322/5433/g' {} +
```

## 📚 Referencias

- **Supabase Config Reference**: https://supabase.com/docs/guides/cli/config
- **Docker Port Mapping**: El puerto interno del contenedor (54322) se mapea al puerto del host (5433) en `supabase/config.toml`

## 🎯 Conclusión

**Regla de oro**: Si estás ejecutando `psql` o cualquier cliente de PostgreSQL desde tu máquina local, usa siempre el **puerto 5433**.

El puerto 54322 es una referencia histórica de la documentación de Supabase que no aplica a este proyecto.

---

*Última actualización: 2026-03-04*
*Autor: Sistema de documentación Brickshare*