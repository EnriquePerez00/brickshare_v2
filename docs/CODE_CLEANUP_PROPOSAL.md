# 📋 Propuesta de Limpieza y Organización de Código

## 🎯 Objetivo
Mantener el repositorio limpio, bien estructurado y fácil de mantener, eliminando código obsoleto, archivos de testing antiguos y organizando mejor los recursos.

---

## 🗑️ Archivos a Eliminar

### 1. **Archivos de Testing/Debug Obsoletos en Root** ❌
Estos archivos fueron usados para pruebas de integración con Correos y ya no son necesarios:

```
probe_correos_auth_v2.js
probe_correos_auth_v5.js
probe_oauth_paths.js
test_403.js
test_all_apis_direct.js
test_app_name_scope.js
test_auth_headers.js
test_auth_json.js
test_basic_auth_api1.js
test_basic_auth.js
test_both_auth.js
test_brute_scopes.js
test_correos_flow.js
test_edge_ui.js
test_generic_spanish_scopes.js
test_homepaqs_headers.js
test_mulesoft_headers.js
test_no_scope.js
test_pudo_direct.js
test_pudo_edge_function.js
test_pudo_query.js
test_scope_variations.js
test_sla_scopes.js
test_spanish_scopes.js
test_terminals_variations.js
test_trackpub_direct.js
thorough_probe.js
verify_correos_integrations.js
```

**Razón**: Estos scripts fueron útiles durante el desarrollo de la integración con Correos API, pero ahora la integración está completa y estable. Deben moverse a un directorio de archivo o eliminarse.

### 2. **Archivos de Respuestas JSON de Testing** ❌
```
response_basic.json
response_scope.json
response.json
token_response.json
```

**Razón**: Respuestas de API guardadas para testing, ya no necesarias en producción.

### 3. **Logs de Debug** ❌
```
push_debug.log
push_error.log
push_force.log
```

**Razón**: Logs temporales que no deben estar en el repositorio.

### 4. **Archivos Duplicados/Placeholders** ❌
```
placeholder.svg (root)
favicon.ico (root)
robots.txt (root)
```

**Razón**: Estos archivos ya existen en `/public/`. La versión del root es innecesaria.

### 5. **Archivos Temporales** ❌
```
label_QR_CODE_GENERATED.pdf
```

**Razón**: Archivo generado, no debe estar en el repositorio.

### 6. **Tests Duplicados** ⚠️
Hay tests duplicados entre `src/test/` y `apps/web/src/test/`:
- `src/test/unit/hooks/useOrders.test.ts` ↔ `apps/web/src/test/unit/hooks/useOrders.test.ts`
- `src/test/unit/hooks/useProducts.test.ts` ↔ `apps/web/src/test/unit/hooks/useProducts.test.ts`
- `src/test/unit/hooks/useWishlist.test.ts` ↔ `apps/web/src/test/unit/hooks/useWishlist.test.ts`

**Razón**: En la estructura de monorepo, los tests deben estar solo en `apps/web/src/test/`. Los de `src/test/` son redundantes.

---

## 📁 Reorganización Propuesta

### 1. **Crear directorio de archivo** 📦
```
/archive/
  /correos-integration-tests/  ← Mover todos los test_*.js y probe_*.js
  /legacy-responses/           ← Mover todos los *.json de respuestas
```

### 2. **Actualizar .gitignore** 🚫
Agregar patrones para prevenir commits de archivos temporales:
```gitignore
# Logs temporales
*.log
push_*.log

# Archivos generados
label_QR_CODE_GENERATED.pdf
*.pdf

# Respuestas de testing
response*.json
token_response.json

# Archivos temporales
.DS_Store
```

### 3. **Consolidar estructura de Testing** 🧪
```
ANTES:
├── src/test/               ← Eliminar (redundante)
└── apps/web/src/test/      ← Mantener (correcto para monorepo)

DESPUÉS:
└── apps/web/src/test/
    ├── setup.ts
    ├── example.test.ts
    └── unit/
        └── hooks/
            ├── useOrders.test.ts
            ├── useProducts.test.ts
            └── useWishlist.test.ts
```

### 4. **Organizar Scripts de Testing** 📝
Los scripts en `/scripts/` están bien, pero podríamos organizarlos mejor:
```
/scripts/
  /testing/
    ├── test-brickshare-qr-flow.ts
    ├── test-deposit-locations.ts
    ├── test-geocoding-precision.ts
    └── test-logistics-integration-e2e.ts
  /maintenance/
    ├── reset-test-data.sql
    └── README_RESET_TEST_DATA.md
  /utils/
    └── ingest-knowledge-base.ts
```

### 5. **Consolidar Documentación README** 📚
```
ANTES:
├── README.md
├── README_BRICKSHARE_PUDO.md
└── README_BRICKSHARE_LOGISTICS_INTEGRATION.md

PROPUESTA:
Mover los READMEs específicos a /docs/:
├── README.md                          (principal)
└── docs/
    ├── BRICKSHARE_PUDO.md
    └── BRICKSHARE_LOGISTICS_INTEGRATION.md
```

---

## 🗄️ Auditoría de Base de Datos - Hallazgos Detallados

### ✅ Tablas Activas y en Uso
Estas tablas están siendo utilizadas correctamente en el código:

| Tabla | Uso | Componentes/Hooks |
|-------|-----|-------------------|
| `profiles` | Extensivo | Dashboard, Auth, Referrals, Operations |
| `sets` | Catálogo principal | Catalogo, useProducts, useCatalogueFilters |
| `envios` | Sistema logístico | useOrders, useShipments, Operations |
| `wishlist` | Lista de deseos | useWishlist, Dashboard |
| `reviews` | Sistema de reseñas | ReviewModal, useReviews |
| `referrals` | Sistema de referidos | ReferralPanel, useReferral |
| `donations` | Donaciones | Donaciones.tsx, useDonation, submit-donation |
| `chat_conversations` | Chat Brickman | ChatWidget (feedback) |
| `chat_messages` | Mensajes chat | ChatWidget, brickman-chat function |
| `brickman_knowledge` | RAG KB | brickman-chat function |
| `operaciones_recepcion` | Panel operaciones | PiecePurchaseManager |
| `set_piece_list` | Inventario piezas | InventoryManager |

### ⚠️ Tablas Sin Uso Aparente

#### 1. **subscriptions** (Alta prioridad para eliminación)
- **Estado**: Tabla creada pero **nunca usada** en queries
- **Problema**: Redundante con `profiles.subscription_plan` y `profiles.subscription_status`
- **Evidencia**: 
  - Búsqueda en código: 0 queries a esta tabla
  - Webhooks de Stripe actualizan `profiles` directamente
  - Las suscripciones se gestionan 100% vía Stripe API
- **Recomendación**: ❌ **ELIMINAR** - No aporta valor y causa confusión

#### 2. **shipping_orders** (Media prioridad)
- **Estado**: Creada en migración `20260131184000` pero no se usa
- **Problema**: No hay queries ni referencias en frontend/backend
- **Evidencia**: 
  - 0 imports o queries encontrados
  - Posible tabla experimental o para desarrollo futuro
- **Recomendación**: ⚠️ **VERIFICAR** con el equipo si tiene propósito futuro, sino **ELIMINAR**

#### 3. **inventario_sets** (Baja prioridad)
- **Estado**: Existe pero uso muy limitado
- **Problema**: Solo se referencia indirectamente en admin
- **Evidencia**: Queries mínimos, podría estar en uso backend
- **Recomendación**: 📝 **DOCUMENTAR** su propósito o consolidar con otras tablas de inventario

### 🔍 Campos Sin Uso

#### En tabla `profiles`:
- **`avatar_url`**: No se usa en ningún componente para mostrar avatares
  - **Impacto**: Bajo (TEXT nullable)
  - **Recomendación**: Remover o implementar funcionalidad de avatar

#### En tabla `sets`:
- **`difficulty`**: Definido en schema pero no usado en filtros de catálogo
  - **Impacto**: Bajo (TEXT nullable)
  - **Recomendación**: Remover o añadir filtro por dificultad
  
- **`tags`**: Array de tags definido pero no usado en búsquedas
  - **Impacto**: Medio (TEXT[] nullable)
  - **Recomendación**: Implementar búsqueda por tags o remover campo

### 🔄 Campos de Swikly (Verificación Requerida)

En tabla `assignments`:
```sql
- swikly_wish_id
- swikly_wish_url
- swikly_status
- swikly_deposit_amount
```

**Estado**: Edge functions existen (`swikly-webhook`, `create-swikly-wish`, `swikly-manage-wish`)

**Pregunta crítica**: ¿Está Swikly activo en producción o es experimental?
- ✅ **Si está activo**: Documentar flujo completo en docs
- ❌ **Si es experimental**: Marcar claramente como "feature flag" o beta

### 📊 Optimización de Migraciones

**Problema actual**: 
- **100+ archivos** de migración en `/supabase/migrations/`
- Muchas son refactorings (`drop`, `rename`, `fix`) que podrían consolidarse
- Dificulta navegación y comprensión del schema

**Recomendación**: 
1. Crear una migración "baseline" consolidada con el estado actual de todas las tablas
2. Mantener solo migraciones desde la última consolidación
3. Archivar migraciones antiguas en `/supabase/migrations/archive/pre-consolidation/`

**Ejemplo**:
```
/supabase/migrations/
  ├── 00000000000000_baseline.sql          ← Schema completo actual
  ├── 20260319000000_create_reviews.sql    ← Migraciones recientes
  ├── 20260319000100_create_referrals.sql
  └── /archive/
      └── /pre-consolidation/              ← Migraciones antiguas
```

---

## 🔄 Estructura Final Recomendada

```
/Brickshare/
├── README.md                          ✅ Principal
├── package.json                       ✅
├── tsconfig.json                      ✅
├── .gitignore                         ✅ (actualizado)
│
├── /apps/                             ✅ Monorepo
│   ├── /web/                          ✅ App web
│   │   └── /src/
│   │       ├── /components/
│   │       ├── /hooks/
│   │       ├── /pages/
│   │       └── /test/                 ✅ Tests aquí
│   └── /ios/                          ✅ App iOS
│
├── /packages/                         ✅ Código compartido
│   └── /shared/
│
├── /docs/                             ✅ Documentación
│   ├── API_REFERENCE.md
│   ├── ARCHITECTURE.md
│   ├── BRICKSHARE_PUDO.md            ← Movido desde root
│   ├── BRICKSHARE_LOGISTICS_INTEGRATION.md ← Movido
│   └── CODE_CLEANUP_PROPOSAL.md       ← Este documento
│
├── /scripts/                          ✅ Scripts organizados
│   ├── /testing/
│   ├── /maintenance/
│   └── /utils/
│
├── /public/                           ✅ Assets públicos
│   ├── favicon.ico
│   ├── robots.txt
│   └── sitemap.xml
│
├── /supabase/                         ✅ Backend
│   ├── /functions/
│   └── /migrations/
│
└── /archive/                          📦 Código antiguo (opcional)
    ├── /correos-integration-tests/
    └── /legacy-responses/
```

---

## 🎬 Plan de Acción Recomendado

### Fase 1: Limpieza Segura (Sin Riesgo) 🟢
1. Eliminar archivos de log (`push_*.log`)
2. Eliminar PDFs generados (`label_QR_CODE_GENERATED.pdf`)
3. Actualizar `.gitignore`
4. Eliminar archivos duplicados en root (`placeholder.svg`, `favicon.ico`, `robots.txt`)

### Fase 2: Archivar Testing Obsoleto (Bajo Riesgo) 🟡
1. Crear carpeta `/archive/`
2. Mover todos los `test_*.js` y `probe_*.js` a `/archive/correos-integration-tests/`
3. Mover archivos JSON de respuestas a `/archive/legacy-responses/`
4. Crear README en `/archive/` explicando el contenido

### Fase 3: Consolidar Tests (Medio Riesgo) 🟠
1. Verificar que tests en `apps/web/src/test/` funcionan correctamente
2. Ejecutar suite de tests
3. Eliminar carpeta `src/test/` (redundante)

### Fase 4: Reorganizar Estructura (Planificado) 🔵
1. Reorganizar `/scripts/` en subcarpetas
2. Mover READMEs específicos a `/docs/`
3. Actualizar referencias en documentación

### Fase 5: Auditoría de Base de Datos (Planificado) 🟣
1. **Eliminar tabla `subscriptions`** - No se usa, todo se maneja en `profiles.subscription_plan`
2. **Verificar/eliminar tabla `shipping_orders`** - Creada pero sin uso aparente
3. **Documentar tabla `inventario_sets`** - Uso limitado, aclarar propósito
4. **Remover campos sin uso**:
   - `profiles.avatar_url` - No se utiliza en ningún componente
   - `sets.difficulty` - Definido pero no usado en filtros
   - `sets.tags` - Array definido pero no usado en búsquedas
5. **Consolidar migraciones** - 100+ archivos de migración pueden optimizarse
6. **Documentar estado de Swikly** - Verificar si está activo o experimental

---

## 📊 Impacto Estimado

### Reducción de Archivos
- **Archivos a eliminar/archivar**: ~40 archivos
- **Reducción de tamaño del repo**: ~500KB - 2MB
- **Archivos duplicados eliminados**: 6 archivos

### Beneficios
- ✅ **Claridad**: Estructura más limpia y comprensible
- ✅ **Mantenibilidad**: Más fácil encontrar código relevante
- ✅ **Velocidad**: Menos archivos = búsquedas más rápidas
- ✅ **Profesionalismo**: Repo más organizado y presentable
- ✅ **Onboarding**: Nuevos desarrolladores entienden la estructura más rápido

### Riesgos
- ⚠️ **Bajo**: La mayoría son archivos de testing/debug obsoletos
- ⚠️ **Mitigación**: Mover a `/archive/` en lugar de eliminar permanentemente
- ⚠️ **Reversible**: Todo está en Git, se puede recuperar si es necesario

---

## 🚀 Comandos Sugeridos

```bash
# Fase 1: Limpieza inmediata
git rm push_*.log
git rm label_QR_CODE_GENERATED.pdf
git rm placeholder.svg favicon.ico robots.txt  # en root, no en public/
git commit -m "chore: remove temporary and duplicate files"

# Fase 2: Archivar tests obsoletos
mkdir -p archive/correos-integration-tests
mkdir -p archive/legacy-responses
git mv test_*.js probe_*.js thorough_probe.js verify_correos_integrations.js archive/correos-integration-tests/
git mv response*.json token_response.json archive/legacy-responses/
git commit -m "chore: archive obsolete correos integration tests"

# Fase 3: Consolidar tests
# Primero verificar que apps/web/src/test/ tiene todos los tests
git rm -r src/test/
git commit -m "chore: remove duplicate test directory (consolidated in apps/web)"

# Fase 4: Reorganizar estructura
git mv README_BRICKSHARE_PUDO.md docs/BRICKSHARE_PUDO.md
git mv README_BRICKSHARE_LOGISTICS_INTEGRATION.md docs/BRICKSHARE_LOGISTICS_INTEGRATION.md
git commit -m "chore: move specific READMEs to docs directory"
```

---

## ✅ Checklist de Validación

Antes de cada commit, verificar:

- [ ] Los tests pasan (`npm test`)
- [ ] La aplicación compila (`npm run build`)
- [ ] No se rompieron imports/referencias
- [ ] La documentación sigue siendo accesible
- [ ] Los scripts en `/scripts/` siguen funcionando

---

## 📝 Notas Adicionales

### Archivos que SÍ deben mantenerse:
- `schema_dump.sql` - Útil para referencia de la DB
- `requirements.txt` - Para Python utilities
- `resend_service.py` - Servicio de email activo
- Todos los archivos en `/supabase/`
- Todos los archivos en `/apps/`
- Todos los archivos en `/packages/`
- Documentación en `/docs/`

### Consideraciones Futuras:
1. Implementar pre-commit hooks para prevenir commits de archivos temporales
2. Configurar CI/CD para ejecutar tests automáticamente
3. Documentar la estructura del monorepo en CONTRIBUTING.md
4. Considerar usar lerna/nx para mejor gestión del monorepo

---

**Última actualización**: 21/03/2026
**Autor**: Propuesta generada durante auditoría de código
**Estado**: Pendiente de revisión y aprobación