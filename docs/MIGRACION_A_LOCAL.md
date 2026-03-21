# 🚀 Migración de Supabase Remoto a Local - Brickshare

**Fecha de creación**: 2026-03-21  
**Estado**: ✅ Listo para implementar  
**Repositorio**: https://github.com/EnriquePerez00/brickshare_v2.git

---

## 📋 Resumen Ejecutivo

Este documento detalla el plan completo para migrar el proyecto Brickshare desde el entorno remoto de Supabase (`tevoogkifiszfontzkgd.supabase.co`) a un entorno local con Docker. El nuevo repositorio oficial es `brickshare_v2`.

### Decisiones Clave

- ✅ Mantener todos los datos de producción
- ✅ Entorno local como nuevo entorno principal
- ✅ Usar mismas credenciales de servicios externos
- ✅ Documentación automática del esquema de BD

---

## 🎯 Objetivos

1. Configurar Supabase local con Docker
2. Migrar esquema y datos de producción
3. Configurar Edge Functions localmente
4. Establecer workflow de desarrollo local
5. Implementar documentación automática

---

## 📊 Estado Actual del Proyecto

### Configuración Remota
- **Project ID**: `tevoogkifiszfontzkgd`
- **URL**: `https://tevoogkifiszfontzkgd.supabase.co`
- **Región**: No especificada (Supabase Cloud)
- **Plan**: Free Tier

### Inventario de Recursos

#### Base de Datos
- **104 migraciones SQL** aplicadas
- **Tablas principales**:
  - `users` - Usuarios registrados
  - `sets` - Catálogo de sets LEGO
  - `inventario_sets` - Inventario disponible
  - `envios` - Gestión de envíos
  - `operaciones_recepcion` - Operaciones de recepción
  - `wishlist` - Lista de deseos de usuarios
  - `reviews` - Reseñas de usuarios
  - `referrals` - Sistema de referidos
  - Más tablas auxiliares...

#### Edge Functions (17)
1. `brickshare-qr-api` - API de códigos QR
2. `change-subscription` - Cambio de suscripción
3. `correos-logistics` - Integración logística Correos
4. `correos-pudo` - Puntos de recogida Correos
5. `create-checkout-session` - Sesión checkout Stripe
6. `create-logistics-package` - Crear paquete logístico
7. `create-subscription-intent` - Intent de suscripción
8. `create-swikly-wish` - Integración Swikly
9. `delete-user` - Eliminar usuario
10. `fetch-lego-data` - Obtener datos LEGO
11. `process-assignment-payment` - Procesar pago asignación
12. `send-brickshare-qr-email` - Enviar email con QR
13. `send-email` - Servicio genérico de email
14. `stripe-webhook` - Webhook de Stripe
15. `submit-donation` - Enviar donación
16. `swikly-manage-wish` - Gestionar Swikly
17. `swikly-webhook` - Webhook de Swikly

#### Servicios Externos Integrados
- **Stripe**: Pagos y suscripciones
- **Resend**: Servicio de email
- **Correos**: Logística y PUDO
- **Swikly**: Gestión de garantías
- **Google Maps**: Geocodificación
- **APIs LEGO**: Rebrickable, Brickset, BrickLink

---

## 📦 Sistema de Documentación Automática

### ✨ Nueva Característica Implementada

Se ha implementado un sistema de **documentación automática del esquema de base de datos**:

#### Scripts Creados

1. **`scripts/update-schema-docs.sh`**
   - Genera `docs/DATABASE_SCHEMA.md` (formato Markdown legible)
   - Genera `docs/schema_dump.sql` (dump SQL completo)
   - Extrae comentarios de tablas y columnas
   - Documenta funciones RPC, triggers y políticas RLS

2. **`scripts/install-hooks.sh`**
   - Instala hook Git pre-commit
   - Detecta automáticamente commits con migraciones
   - Ejecuta generación de documentación
   - Añade documentación al commit automáticamente

3. **`scripts/README.md`**
   - Documentación completa de todos los scripts
   - Ejemplos de uso
   - Mejores prácticas
   - Troubleshooting

#### Flujo Automático

```
1. Desarrollador crea migración
   ↓
2. Desarrollador hace commit
   ↓
3. Hook pre-commit detecta migración
   ↓
4. Script genera documentación automáticamente
   ↓
5. Documentación se añade al commit
   ↓
6. Commit se completa con migración + docs
```

#### Uso

```bash
# Instalación única
bash scripts/install-hooks.sh

# Uso normal (automático)
git add supabase/migrations/XXXXXX_nueva_tabla.sql
git commit -m "feat: add new table"
# → docs/DATABASE_SCHEMA.md se actualiza automáticamente

# Uso manual (si es necesario)
bash scripts/update-schema-docs.sh
```

---

## 🛠️ Plan de Implementación

### FASE 1: Preparación del Entorno Local ⏱️ 30 min

#### 1.1 Verificar Requisitos

```bash
# Verificar Docker
docker --version
# Si no está instalado: https://www.docker.com/products/docker-desktop

# Verificar Supabase CLI
supabase --version
# Si no está instalado: npm install -g supabase

# Verificar PostgreSQL client
psql --version
# Si no está instalado (macOS): brew install postgresql
```

#### 1.2 Clonar Repositorio (si es necesario)

```bash
git clone https://github.com/EnriquePerez00/brickshare_v2.git
cd brickshare_v2
```

#### 1.3 Instalar Dependencias

```bash
npm install
```

---

### FASE 2: Configuración de Supabase Local ⏱️ 20 min

#### 2.1 Inicializar Supabase

```bash
# Ya existe supabase/ con config.toml, migrations/, functions/
# Solo verificar que esté todo en orden
ls -la supabase/
```

#### 2.2 Actualizar `supabase/config.toml`

El archivo ya está configurado. Verificar que contenga:

```toml
project_id = "tevoogkifiszfontzkgd"  # Mantener por ahora

[api]
enabled = true
port = 54321

[db]
port = 54322
major_version = 15

[studio]
enabled = true
port = 54323

[auth]
site_url = "http://localhost:5173"

# ... resto de configuración
```

#### 2.3 Iniciar Supabase Local

```bash
supabase start

# Esto mostrará:
# - API URL: http://localhost:54321
# - DB URL: postgresql://postgres:postgres@localhost:54322/postgres
# - Studio URL: http://localhost:54323
# - anon key: eyJ...
# - service_role key: eyJ...
```

**⚠️ IMPORTANTE**: Guarda las keys que se muestran, las necesitarás.

---

### FASE 3: Exportación de Datos del Remoto ⏱️ 45 min

#### 3.1 Exportar Esquema y Datos

```bash
# Conectar al remoto
supabase link --project-ref tevoogkifiszfontzkgd

# Exportar estructura completa
supabase db dump --linked --file backups/schema_remoto.sql

# Exportar solo datos
supabase db dump --linked --data-only --file backups/data_remoto.sql
```

#### 3.2 Exportar Storage (si hay archivos)

Si tienes archivos en Supabase Storage:

```bash
# Listar buckets
supabase storage list --linked

# Descargar archivos
# (Requiere script personalizado o hacerlo manualmente desde Studio)
```

**Nota**: Los archivos de Storage deberán migrarse manualmente o mediante script personalizado según volumen.

---

### FASE 4: Importación a Local ⏱️ 30 min

#### 4.1 Aplicar Migraciones

```bash
# Reset BD local y aplicar todas las migraciones
supabase db reset

# Esto aplicará todas las migraciones en orden
# desde supabase/migrations/
```

#### 4.2 Verificar Esquema

```bash
# Acceder a Studio local
open http://localhost:54323

# O verificar desde CLI
supabase db diff
# (No debería haber diferencias)
```

#### 4.3 Importar Datos de Producción

```bash
# Importar datos
psql "postgresql://postgres:postgres@localhost:54322/postgres" < backups/data_remoto.sql

# Verificar importación
psql "postgresql://postgres:postgres@localhost:54322/postgres" -c "SELECT COUNT(*) FROM users;"
```

---

### FASE 5: Configurar Variables de Entorno ⏱️ 15 min

#### 5.1 Crear `.env.local` en Raíz

```bash
cat > .env.local << 'EOF'
# Supabase Local
SUPABASE_URL=http://localhost:54321
SUPABASE_ANON_KEY=<copia_el_anon_key_de_supabase_start>
SUPABASE_SERVICE_ROLE_KEY=<copia_el_service_role_key_de_supabase_start>

# Frontend
VITE_SUPABASE_URL=http://localhost:54321
VITE_SUPABASE_PUBLISHABLE_KEY=<mismo_que_anon_key>

# Servicios externos (mismas credenciales)
VITE_STRIPE_PUBLISHABLE_KEY=pk_test_51StqNY7Pc5FKirdFPCyXY3IsNrrcvNSAq1iZMxSkkkPWZZbVQ4CVnzqI00Sfdc5rw5xAL0xiPmqclPWkNdw32E2A00Lt264wrW
VITE_GOOGLE_MAPS_API_KEY=AIzaSyBmwgX2hobyh7IPl0qMgYqlaJ59BJSX_-w
EOF
```

#### 5.2 Actualizar `apps/web/.env`

```bash
cat > apps/web/.env << 'EOF'
VITE_SUPABASE_URL=http://localhost:54321
VITE_SUPABASE_PUBLISHABLE_KEY=<anon_key_de_supabase_start>
VITE_STRIPE_PUBLISHABLE_KEY=pk_test_51StqNY7Pc5FKirdFPCyXY3IsNrrcvNSAq1iZMxSkkkPWZZbVQ4CVnzqI00Sfdc5rw5xAL0xiPmqclPWkNdw32E2A00Lt264wrW
VITE_GOOGLE_MAPS_API_KEY=AIzaSyBmwgX2hobyh7IPl0qMgYqlaJ59BJSX_-w
EOF
```

#### 5.3 Edge Functions `.env`

El archivo `supabase/functions/.env` ya existe con las credenciales correctas:

```env
RESEND_API_KEY=re_EceHVN28_C8XXwSTyuQBwrzPGAPqusizg
RESEND_FROM_EMAIL=info@brickclinic.eu
CORREOS_CLIENT_ID=8f21043b027346faa6eb9582f2312fdd
CORREOS_CLIENT_SECRET=9d973F90ab294211B8B14723A6aC6128
# ... resto de credenciales
```

Añadir keys de Stripe y Swikly si faltan.

---

### FASE 6: Configurar Edge Functions Locales ⏱️ 20 min

#### 6.1 Servir Functions Localmente

```bash
# Todas las funciones
supabase functions serve

# O función específica
supabase functions serve stripe-webhook --env-file supabase/functions/.env
```

#### 6.2 Configurar Webhooks de Stripe

Para que los webhooks de Stripe funcionen localmente:

```bash
# Instalar Stripe CLI
brew install stripe/stripe-cli/stripe

# Autenticar
stripe login

# Forward webhooks
stripe listen --forward-to localhost:54321/functions/v1/stripe-webhook

# Esto mostrará un webhook secret, añádelo a supabase/functions/.env:
# STRIPE_WEBHOOK_SECRET=<your_webhook_secret>...
```

---

### FASE 7: Generar Tipos TypeScript ⏱️ 5 min

```bash
# Generar tipos desde esquema local
supabase gen types typescript --local > apps/web/src/integrations/supabase/types.ts

# Verificar que se generaron correctamente
wc -l apps/web/src/integrations/supabase/types.ts
```

---

### FASE 8: Instalar Sistema de Documentación Automática ⏱️ 5 min

```bash
# Instalar hooks de Git
bash scripts/install-hooks.sh

# Generar documentación inicial
bash scripts/update-schema-docs.sh

# Verificar que se generó
ls -lh docs/DATABASE_SCHEMA.md docs/schema_dump.sql
```

---

### FASE 9: Verificación y Testing ⏱️ 30 min

#### 9.1 Verificar Servicios Docker

```bash
# Ver contenedores corriendo
docker ps

# Ver logs
supabase logs
supabase logs db
```

#### 9.2 Acceder a Studio

```bash
open http://localhost:54323
```

Verificar:
- ✅ Tablas presentes
- ✅ Datos importados
- ✅ Funciones RPC disponibles
- ✅ Políticas RLS configuradas

#### 9.3 Iniciar Aplicación

```bash
# Terminal 1: Frontend
npm run dev

# Terminal 2: Edge Functions (si no están corriendo)
supabase functions serve
```

Abrir: http://localhost:5173

#### 9.4 Testing Funcional

Probar:
- [ ] Login/Registro de usuario
- [ ] Navegación por catálogo
- [ ] Añadir a wishlist
- [ ] Proceso de checkout (modo test Stripe)
- [ ] Envío de emails (capturados en Inbucket: http://localhost:54324)
- [ ] Funciones de operador/admin

---

### FASE 10: Migración de Storage (Opcional) ⏱️ Variable

Si tienes archivos en Storage:

1. Descargar archivos del remoto
2. Crear buckets en local
3. Subir archivos usando API o Studio

```bash
# Crear bucket
supabase storage create <bucket-name>

# Subir archivos programáticamente o vía Studio
```

---

## 🔄 Workflow de Desarrollo Local

### Comandos Cotidianos

```bash
# Iniciar entorno
supabase start

# Detener entorno
supabase stop

# Ver logs
supabase logs -f

# Reiniciar (útil después de cambios en config)
supabase restart

# Crear migración
supabase migration new nombre_descriptivo

# Aplicar migraciones
supabase db reset

# Generar tipos
supabase gen types typescript --local > apps/web/src/integrations/supabase/types.ts
```

### Crear Nueva Feature con Migración

```bash
# 1. Crear rama
git checkout -b feature/nueva-tabla

# 2. Crear migración
supabase migration new add_nueva_tabla

# 3. Editar migración con comentarios
vim supabase/migrations/XXXXXX_add_nueva_tabla.sql

# Añadir comentarios SQL:
# COMMENT ON TABLE nueva_tabla IS 'Descripción de la tabla';
# COMMENT ON COLUMN nueva_tabla.campo IS 'Descripción del campo';

# 4. Aplicar localmente
supabase db reset

# 5. Verificar en Studio
open http://localhost:54323

# 6. Commit (documentación se genera automáticamente)
git add supabase/migrations/
git commit -m "feat: add nueva tabla"
# → Hook genera docs/DATABASE_SCHEMA.md automáticamente

# 7. Push
git push origin feature/nueva-tabla
```

---

## ⚠️ Consideraciones Importantes

### 1. Servicios Externos

- **Stripe**: Usar Stripe CLI para webhooks locales
- **Correos, Resend, Swikly**: Funcionan igual (APIs externas)
- **Google Maps**: Funciona igual

### 2. Email

Los emails NO se envían realmente en local:
- Se capturan en **Inbucket**: http://localhost:54324
- Ver emails enviados ahí durante desarrollo

### 3. Rendimiento

Docker consume recursos:
- Mínimo 8GB RAM recomendado
- SSD mejora significativamente
- Cerrar otros contenedores Docker innecesarios

### 4. Datos Sensibles

⚠️ **CRÍTICO**: Los datos de producción contienen información real:
- NO commitear archivos de datos a Git
- Añadir a `.gitignore`:
  ```
  backups/
  *_remoto.sql
  data_export.sql
  ```
- Considerar anonimizar datos para desarrollo

### 5. Backup Local

Hacer dumps periódicos:

```bash
# Crear directorio de backups
mkdir -p backups

# Dump periódico
supabase db dump --local --file backups/local_$(date +%Y%m%d).sql
```

---

## 📚 Recursos y Documentación

### Documentos Creados

- ✅ `scripts/README.md` - Documentación de scripts
- ✅ `scripts/update-schema-docs.sh` - Generador de docs
- ✅ `scripts/install-hooks.sh` - Instalador de hooks
- ✅ `docs/MIGRACION_A_LOCAL.md` - Este documento
- ✅ Hook pre-commit configurado
- ✅ `.gitignore` actualizado

### Documentos Existentes

- `docs/SUPABASE_CLI_SETUP.md` - Setup del CLI
- `docs/DATABASE_SCHEMA.md` - Esquema de BD (auto-generado)
- `docs/ARCHITECTURE.md` - Arquitectura general
- `docs/API_REFERENCE.md` - Referencia de API

### Enlaces Útiles

- [Supabase CLI Docs](https://supabase.com/docs/guides/cli)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Stripe CLI](https://stripe.com/docs/stripe-cli)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)

---

## ✅ Checklist de Migración

### Pre-requisitos
- [ ] Docker Desktop instalado y corriendo
- [ ] Supabase CLI instalado
- [ ] PostgreSQL client instalado
- [ ] Repositorio clonado
- [ ] Dependencias npm instaladas

### Migración
- [ ] Supabase local iniciado
- [ ] Datos exportados del remoto
- [ ] Migraciones aplicadas localmente
- [ ] Datos importados correctamente
- [ ] Variables de entorno configuradas
- [ ] Tipos TypeScript generados
- [ ] Edge Functions funcionando
- [ ] Webhooks de Stripe configurados

### Documentación
- [ ] Hooks de Git instalados
- [ ] Documentación inicial generada
- [ ] README de scripts revisado

### Verificación
- [ ] Studio accesible (http://localhost:54323)
- [ ] Aplicación corre en local (http://localhost:5173)
- [ ] Login funciona
- [ ] Base de datos responde
- [ ] Edge Functions responden
- [ ] Emails se capturan en Inbucket

---

## 🆘 Troubleshooting

Ver `scripts/README.md` sección Troubleshooting para problemas comunes.

### Problemas Frecuentes

**Supabase no inicia**
```bash
# Ver logs
docker logs <container_id>

# Reiniciar Docker Desktop
# Liberar puerto 54321-54326 si están ocupados
```

**Migraciones fallan**
```bash
# Ver error específico
supabase db reset --debug

# Verificar sintaxis SQL
# Revisar dependencias entre migraciones
```

**Edge Functions no responden**
```bash
# Verificar que están corriendo
supabase functions serve --debug

# Ver logs
supabase functions logs <function-name>
```

---

## 📞 Soporte

Para problemas o dudas:
1. Revisar `scripts/README.md`
2. Consultar documentación de Supabase
3. Verificar logs de Docker
4. Revisar issues en GitHub del proyecto

---

**Última actualización**: 2026-03-21  
**Autor**: Equipo Brickshare  
**Versión**: 1.0