# Brickshare — Documentación Técnica Completa

> Plataforma de alquiler de sets LEGO  
> Repositorio: https://github.com/EnriquePerez00/brickshare_v2  
> Última actualización: 22/03/2026

---

# Reglas de Consumo de Tokens
1. **Respostas Concisas:** No me des explicaciones largas a menos que te lo pida. Ve directo al código.
2. **Lectura Selectiva:** Antes de leer archivos grandes, pregúntame o lee solo las líneas relevantes.
3. **No repitas código:** Si solo cambias una línea, no me devuelvas el archivo entero; usa bloques de diff o solo la parte afectada.
4. **Pensamiento Interno:** Minimiza el razonamiento paso a paso si la solución es trivial.

## 1. Esquema del Repositorio

```
brickshare_v2/
├── apps/
│   └── web/                          # Frontend web principal
│       ├── src/
│       │   ├── components/           # Componentes React
│       │   │   ├── admin/            # Panel de administración
│       │   │   │   ├── inventory/    #   Gestión de inventario
│       │   │   │   ├── operations/   #   Operaciones (envíos, devoluciones, asignaciones)
│       │   │   │   └── users/        #   Gestión de usuarios
│       │   │   └── ui/               # Componentes UI reutilizables (shadcn/ui)
│       │   ├── contexts/             # Contextos React (AuthContext, etc.)
│       │   ├── hooks/                # Custom hooks (useOrders, useShipments, etc.)
│       │   ├── lib/                  # Servicios y utilidades (supabaseClient, pudoService)
│       │   ├── pages/                # Páginas (Dashboard, Auth, Catalogo, Admin)
│       │   └── types/                # Tipos TypeScript del frontend
│       ├── public/                   # Assets estáticos
│       ├── package.json              # Dependencias del frontend
│       ├── vite.config.ts            # Configuración de Vite
│       ├── tailwind.config.ts        # Configuración de Tailwind CSS
│       └── tsconfig.json             # Configuración de TypeScript
│
├── packages/
│   └── shared/                       # Código compartido entre apps
│       └── src/
│           └── types/                # Tipos compartidos (pudo.ts, etc.)
│
├── supabase/
│   ├── config.toml                   # Configuración de Supabase local
│   ├── functions/                    # Edge Functions (Deno runtime)
│   │   ├── brickshare-qr-api/       # API de validación de códigos QR
│   │   ├── change-subscription/      # Cambio de plan de suscripción
│   │   ├── correos-logistics/        # Integración logística con Correos
│   │   ├── correos-pudo/             # Puntos PUDO de Correos
│   │   ├── create-checkout-session/  # Sesión de pago Stripe
│   │   ├── create-logistics-package/ # Creación de paquetes logísticos
│   │   ├── create-subscription-intent/ # Intent de suscripción Stripe
│   │   ├── create-swikly-wish/       # Garantías Swikly
│   │   ├── delete-user/              # Eliminación de cuenta
│   │   ├── fetch-lego-data/          # Importación datos LEGO (Brickset/Rebrickable)
│   │   ├── process-assignment-payment/ # Procesamiento de pago de asignación
│   │   ├── send-brickshare-qr-email/ # Envío de QR por email
│   │   ├── send-email/               # Servicio genérico de email (Resend)
│   │   ├── stripe-webhook/           # Webhook de Stripe
│   │   ├── submit-donation/          # Procesamiento de donaciones
│   │   ├── swikly-manage-wish/       # Gestión de deseos Swikly
│   │   └── swikly-webhook/           # Webhook de Swikly
│   ├── migrations/                   # ~90+ migraciones SQL ordenadas cronológicamente
│   └── snippets/                     # Snippets SQL de utilidad
│
├── scripts/                          # Scripts de utilidad
│   ├── check-set-ref.ts              # Verificación de referencias de sets
│   ├── install-hooks.sh              # Instalación de git hooks
│   ├── reset-test-data.sql           # Reset de datos de prueba
│   ├── seed-admin-and-sets.sql       # Seed de admin y sets iniciales
│   ├── seed-sets-from-brickset.ts    # Importación de sets desde Brickset
│   ├── update-schema-docs.sh         # Actualización automática de docs de esquema
│   ├── verify-seed.ts                # Verificación de seed
│   └── verify-supabase-cli.sh        # Verificación de CLI de Supabase
│
├── src/
│   └── types/
│       └── supabase.ts               # Tipos TypeScript generados de Supabase
│
├── docs/                             # Documentación técnica
│   ├── ARCHITECTURE.md               # Arquitectura del sistema
│   ├── DATABASE_SCHEMA.md            # Esquema de base de datos (auto-generado)
│   ├── schema_dump.sql               # Dump SQL completo del esquema
│   ├── API_REFERENCE.md              # Referencia de API
│   ├── LOCAL_DEVELOPMENT.md          # Guía de desarrollo local
│   ├── CONTRIBUTING.md               # Guía de contribución
│   ├── DEVELOPMENT_ROADMAP.md        # Roadmap de desarrollo
│   ├── BRICKSHARE_PUDO*.md           # Documentación del sistema PUDO
│   └── ...                           # Otras guías y documentación
│
├── package.json                      # Monorepo root (npm workspaces)
├── vercel.json                       # Configuración de despliegue en Vercel
├── .env.example                      # Variables de entorno de ejemplo
└── .gitignore
```

---

## 2. Stack Tecnológico

### 2.1 Frontend Web

| Tecnología | Versión | Propósito |
|---|---|---|
| **Vite** | ^7.3.1 | Build tool y dev server |
| **React** | ^18.3.1 | Librería UI |
| **TypeScript** | ^5.8.3 | Tipado estático |
| **Tailwind CSS** | ^3.4.17 | Framework de estilos utilitarios |
| **shadcn/ui (Radix UI)** | Varios | Componentes UI accesibles (Dialog, Select, Tabs, etc.) |
| **React Router DOM** | ^6.30.1 | Enrutamiento SPA |
| **TanStack React Query** | ^5.83.0 | Cache y sincronización de datos del servidor |
| **React Hook Form** | ^7.61.1 | Gestión de formularios |
| **Zod** | ^3.25.76 | Validación de esquemas |
| **Stripe.js** | ^8.7.0 | Pagos en el frontend |
| **Recharts** | ^2.15.4 | Gráficos y visualización de datos |
| **Framer Motion** | ^12.26.2 | Animaciones |
| **date-fns** | ^3.6.0 | Utilidades de fechas |
| **Lucide React** | ^0.462.0 | Iconos |
| **Sonner** | ^1.7.4 | Notificaciones toast |
| **PapaParse** | ^5.5.3 | Parsing de CSV |

### 2.2 Backend (Supabase)

| Tecnología | Propósito |
|---|---|
| **Supabase** | Backend as a Service (BaaS) |
| **PostgreSQL** | Base de datos relacional |
| **Supabase Auth** | Autenticación (email/password, JWT, RLS) |
| **Supabase Edge Functions** | Funciones serverless (runtime Deno/TypeScript) |
| **Supabase Storage** | Almacenamiento de archivos (etiquetas de envío, imágenes) |
| **Supabase Realtime** | Suscripciones WebSocket (preparado para uso futuro) |
| **Row Level Security (RLS)** | Control de acceso a nivel de fila en todas las tablas |

### 2.3 Integraciones Externas

| Servicio | Propósito |
|---|---|
| **Stripe** | Pagos, suscripciones y webhooks |
| **Correos API** | Logística de envíos y puntos PUDO (Pick Up / Drop Off) |
| **Swikly** | Garantías y depósitos de seguridad |
| **Resend** | Envío de emails transaccionales |
| **Brickset / Rebrickable** | Importación de datos de sets LEGO (piezas, imágenes, detalles) |

### 2.4 Herramientas de Desarrollo

| Herramienta | Propósito |
|---|---|
| **npm workspaces** | Gestión de monorepo |
| **ESLint** | Linting de código |
| **Vitest** | Framework de testing |
| **Testing Library** | Testing de componentes React |
| **Docker** | Supabase local (PostgreSQL, Auth, etc.) |
| **Supabase CLI** | Gestión de migraciones, funciones y tipos |
| **Vercel** | Despliegue del frontend en producción |

### 2.5 Sistema de Roles (RBAC)

| Rol | Descripción |
|---|---|
| `admin` | Acceso total: gestión de sets, usuarios, inventario, operaciones |
| `operador` | Operaciones: gestión de envíos, recepciones, inventario |
| `user` | Usuario final: catálogo, wishlist, suscripción, seguimiento de envíos |

---

## 3. Esquema de Base de Datos

### 3.1 Tipos Enumerados

#### `app_role`
```sql
ENUM ('admin', 'user', 'operador')
```
Roles de la aplicación para el sistema RBAC.

#### `operation_type`
```sql
ENUM ('recepcion paquete', 'analisis_peso', 'deposito_fulfillment', 'higienizado', 'retorno_stock')
```
Tipos de operaciones de backoffice registrables.

---

### 3.2 Tablas

---

#### `users`

**Descripción**: Perfil de usuario vinculado a `auth.users`. Se crea automáticamente al registrar un nuevo usuario mediante el trigger `handle_new_user`.

| Campo | Tipo | Nulo | Default | Restricciones | Significado |
|---|---|:---:|---|---|---|
| `id` | uuid | ✗ | `gen_random_uuid()` | PK | Identificador interno del perfil |
| `user_id` | uuid | ✗ | — | UNIQUE, FK → `auth.users(id)` ON DELETE CASCADE | ID del usuario en `auth.users` |
| `full_name` | text | ✓ | — | — | Nombre completo del usuario |
| `email` | text | ✓ | — | — | Email del usuario (copiado de auth) |
| `avatar_url` | text | ✓ | — | — | URL del avatar del usuario |
| `phone` | text | ✓ | — | — | Teléfono de contacto |
| `address` | text | ✓ | — | — | Dirección postal |
| `address_extra` | text | ✓ | — | — | Información adicional de dirección (piso, puerta, etc.) |
| `zip_code` | text | ✓ | — | — | Código postal |
| `city` | text | ✓ | — | — | Ciudad |
| `province` | text | ✓ | — | — | Provincia |
| `impact_points` | integer | ✓ | `0` | — | Puntos de impacto social acumulados |
| `subscription_type` | text | ✓ | — | — | Plan de suscripción (Brick Starter, Pro, Master) |
| `subscription_status` | text | ✓ | `'active'` | CHECK: `active`, `inactive` | Estado de la suscripción |
| `profile_completed` | boolean | ✓ | `false` | — | Si el usuario completó su perfil (dirección, teléfono, etc.) |
| `user_status` | text | ✓ | `'no_set'` | CHECK: `no_set`, `set_shipping`, `received`, `has_set`, `set_returning`, `suspended`, `cancelled` | Estado del usuario en el ciclo de alquiler |
| `stripe_customer_id` | text | ✓ | — | UNIQUE | ID de cliente en Stripe |
| `referral_code` | text | ✓ | — | UNIQUE (case-insensitive) | Código de referido (6 chars, auto-generado al INSERT) |
| `referred_by` | uuid | ✓ | — | FK → `auth.users(id)` ON DELETE SET NULL | ID del usuario que lo refirió |
| `referral_credits` | integer | ✗ | `0` | — | Créditos acumulados por referidos exitosos |
| `created_at` | timestamptz | ✗ | `now()` | — | Fecha de creación |
| `updated_at` | timestamptz | ✗ | `now()` | Auto-update via trigger | Fecha de última actualización |

---

#### `user_roles`

**Descripción**: Asignación de roles a usuarios. Un usuario puede tener múltiples roles.

| Campo | Tipo | Nulo | Default | Restricciones | Significado |
|---|---|:---:|---|---|---|
| `id` | uuid | ✗ | `gen_random_uuid()` | PK | Identificador del registro |
| `user_id` | uuid | ✗ | — | FK → `auth.users(id)` ON DELETE CASCADE, UNIQUE(user_id, role) | ID del usuario en auth |
| `role` | app_role | ✗ | — | ENUM: `admin`, `user`, `operador` | Rol asignado |
| `created_at` | timestamptz | ✗ | `now()` | — | Fecha de asignación |

---

#### `sets`

**Descripción**: Catálogo de sets LEGO disponibles para alquiler.

| Campo | Tipo | Nulo | Default | Restricciones | Significado |
|---|---|:---:|---|---|---|
| `id` | uuid | ✗ | `gen_random_uuid()` | PK | Identificador del set |
| `set_name` | text | ✗ | — | — | Nombre del set LEGO |
| `set_description` | text | ✓ | — | — | Descripción del set |
| `set_image_url` | text | ✓ | — | — | URL de la imagen principal |
| `set_theme` | text | ✗ | — | — | Tema LEGO (City, Technic, Star Wars, etc.) |
| `set_subtheme` | text | ✓ | — | — | Subtema dentro del tema principal |
| `set_age_range` | text | ✗ | — | — | Rango de edad recomendado (ej: "6-12") |
| `set_piece_count` | integer | ✗ | — | — | Número total de piezas |
| `set_ref` | text | ✓ | — | — | Número de referencia oficial LEGO (ej: "75192") |
| `set_weight` | numeric | ✓ | — | — | Peso del set (en gramos) |
| `set_minifigs` | numeric | ✓ | — | — | Número de minifiguras incluidas |
| `set_price` | numeric | ✓ | `100.00` | — | Precio de referencia del set (para depósito/valor) |
| `set_pvp_release` | numeric | ✓ | — | — | PVP de lanzamiento original |
| `current_value_new` | numeric | ✓ | — | — | Valor de mercado actual (nuevo) |
| `current_value_used` | numeric | ✓ | — | — | Valor de mercado actual (usado) |
| `set_status` | text | ✓ | `'inactive'` | CHECK: `active`, `inactive`, `in_repair` | Estado del set en el sistema |
| `catalogue_visibility` | boolean | ✗ | `true` | — | Si es visible en el catálogo público |
| `skill_boost` | text[] | ✓ | — | — | Habilidades que potencia (creatividad, motricidad, etc.) |
| `year_released` | integer | ✓ | — | — | Año de lanzamiento |
| `barcode_upc` | text | ✓ | — | — | Código de barras UPC |
| `barcode_ean` | text | ✓ | — | — | Código de barras EAN |
| `created_at` | timestamptz | ✗ | `now()` | — | Fecha de creación |
| `updated_at` | timestamptz | ✗ | `now()` | Auto-update via trigger | Fecha de última actualización |

---

#### `set_piece_list`

**Descripción**: Lista detallada de piezas que componen cada set LEGO. Se importa desde APIs externas (Rebrickable/Brickset).

| Campo | Tipo | Nulo | Default | Restricciones | Significado |
|---|---|:---:|---|---|---|
| `id` | uuid | ✗ | `gen_random_uuid()` | PK | Identificador del registro |
| `set_id` | uuid | ✗ | — | FK → `sets(id)` ON DELETE CASCADE | Set al que pertenece la pieza |
| `set_ref` | text | ✗ | — | — | Referencia del set (para búsqueda rápida) |
| `piece_ref` | text | ✗ | — | — | Referencia/ID de la pieza en LEGO |
| `color_ref` | text | ✓ | — | — | Referencia del color |
| `color_id` | integer | ✓ | — | — | ID numérico del color (Rebrickable) |
| `piece_description` | text | ✓ | — | — | Descripción de la pieza |
| `piece_qty` | integer | ✗ | `1` | — | Cantidad de esta pieza en el set |
| `piece_weight` | numeric | ✓ | — | — | Peso individual de la pieza (gramos) |
| `piece_image_url` | text | ✓ | — | — | URL de la imagen de la pieza |
| `piece_studdim` | text | ✓ | — | — | Dimensiones en studs (ej: "2x4") |
| `element_id` | text | ✓ | — | — | ID de elemento LEGO |
| `is_spare` | boolean | ✓ | `false` | — | Si es una pieza de repuesto |
| `part_cat_id` | integer | ✓ | — | — | ID de categoría de pieza (Rebrickable) |
| `year_from` | integer | ✓ | — | — | Primer año en que se fabricó esta pieza |
| `year_to` | integer | ✓ | — | — | Último año en que se fabricó esta pieza |
| `is_trans` | boolean | ✓ | `false` | — | Si la pieza es translúcida |
| `external_ids` | jsonb | ✓ | — | — | IDs externos (BrickLink, BrickOwl, etc.) |
| `created_at` | timestamptz | ✗ | `now()` | — | Fecha de creación |
| `updated_at` | timestamptz | ✗ | `now()` | Auto-update via trigger | Fecha de última actualización |

---

#### `inventory_sets`

**Descripción**: Control de inventario de cada set. Rastrea unidades en diferentes estados (almacén, envío, uso, reparación). Se crea automáticamente al insertar un set (trigger `handle_new_set_inventory`).

| Campo | Tipo | Nulo | Default | Restricciones | Significado |
|---|---|:---:|---|---|---|
| `id` | uuid | ✗ | `gen_random_uuid()` | PK | Identificador del registro |
| `set_id` | uuid | ✗ | — | UNIQUE, FK → `sets(id)` ON DELETE CASCADE | Set al que pertenece |
| `set_ref` | text | ✓ | — | — | Referencia LEGO del set |
| `inventory_set_total_qty` | integer | ✗ | `0` | — | Cantidad total de unidades disponibles en almacén |
| `in_shipping` | integer | ✗ | `0` | — | Unidades actualmente en proceso de envío |
| `in_use` | integer | ✗ | `0` | — | Unidades actualmente en uso por usuarios |
| `in_return` | integer | ✗ | `0` | — | Unidades en proceso de devolución |
| `in_repair` | integer | ✗ | `0` | — | Unidades en reparación (piezas faltantes) |
| `spare_parts_order` | text | ✓ | — | — | Notas sobre pedidos de piezas de repuesto |
| `created_at` | timestamptz | ✗ | `now()` | — | Fecha de creación |
| `updated_at` | timestamptz | ✗ | `now()` | Auto-update via trigger | Fecha de última actualización |

---

#### `shipments`

**Descripción**: Tabla central de envíos. Gestiona todo el ciclo de vida de un envío: asignación → preparación → envío → entrega → devolución.

| Campo | Tipo | Nulo | Default | Restricciones | Significado |
|---|---|:---:|---|---|---|
| `id` | uuid | ✗ | `gen_random_uuid()` | PK | Identificador del envío |
| `user_id` | uuid | ✗ | — | FK → `auth.users(id)` CASCADE, FK → `users(user_id)` CASCADE | Usuario destinatario |
| `set_id` | uuid | ✓ | — | FK → `sets(id)` ON DELETE SET NULL | Set enviado |
| `set_ref` | text | ✓ | — | — | Referencia LEGO del set (para consulta rápida) |
| `shipment_status` | text | ✗ | `'pending'` | CHECK: `pending`, `preparation`, `assigned`, `in_transit`, `delivered`, `returned`, `return_in_transit`, `cancelled` | Estado actual del envío |
| `shipping_address` | text | ✗ | — | — | Dirección de envío |
| `shipping_city` | text | ✗ | — | — | Ciudad de envío |
| `shipping_zip_code` | text | ✗ | — | — | Código postal de envío |
| `shipping_country` | text | ✗ | `'España'` | — | País de envío |
| `shipping_provider` | text | ✓ | — | — | Proveedor de envío |
| `pickup_provider_address` | text | ✓ | — | — | Dirección del punto de recogida |
| `tracking_number` | text | ✓ | UNIQUE | — | Número de seguimiento |
| `carrier` | text | ✓ | — | — | Transportista |
| `additional_notes` | text | ✓ | — | — | Notas adicionales del envío |
| `assigned_date` | timestamptz | ✓ | — | — | Fecha de asignación del set |
| `estimated_delivery_date` | timestamptz | ✓ | — | — | Fecha estimada de entrega |
| `actual_delivery_date` | timestamptz | ✓ | — | — | Fecha real de entrega |
| `user_delivery_date` | timestamptz | ✓ | — | — | Fecha en la que el usuario recogió el paquete |
| `warehouse_pickup_date` | timestamptz | ✓ | — | — | Fecha de recogida desde almacén |
| `warehouse_reception_date` | timestamptz | ✓ | — | — | Fecha de recepción en almacén (devolución) |
| `estimated_return_date` | date | ✓ | — | — | Fecha estimada de devolución |
| `return_request_date` | timestamptz | ✓ | — | — | Fecha en la que el usuario solicitó la devolución |
| `pickup_provider` | text | ✓ | — | — | Transportista encargado de la recogida de devolución |
| `handling_processed` | boolean | ✓ | `false` | — | Si la operación de recepción en almacén ya fue procesada |
| `pickup_type` | text | ✓ | `'correos'` | CHECK: `correos`, `brickshare` | Tipo de punto de recogida |
| **Integración Correos** | | | | | |
| `correos_shipment_id` | text | ✓ | — | — | ID de envío en Correos (API Preregister) |
| `label_url` | text | ✓ | — | — | Ruta a la etiqueta de envío generada |
| `pickup_id` | text | ✓ | — | — | ID externo de recogida programada |
| `last_tracking_update` | timestamptz | ✓ | — | — | Última sincronización con Correos Tracking API |
| **Integración Swikly (Depósitos)** | | | | | |
| `swikly_wish_id` | text | ✓ | — | — | ID del wish en Swikly |
| `swikly_wish_url` | text | ✓ | — | — | URL del wish de Swikly para el usuario |
| `swikly_status` | text | ✓ | `'pending'` | CHECK: `pending`, `wish_created`, `accepted`, `released`, `captured`, `expired`, `cancelled` | Estado del depósito Swikly |
| `swikly_deposit_amount` | integer | ✓ | — | — | Monto del depósito en céntimos |
| **Sistema PUDO Brickshare** | | | | | |
| `brickshare_pudo_id` | text | ✓ | — | — | ID del punto PUDO de Brickshare |
| `brickshare_package_id` | text | ✓ | — | — | ID del package en Brickshare Logistics |
| `brickshare_metadata` | jsonb | ✓ | `'{}'` | — | Metadatos adicionales del sistema PUDO |
| **Códigos QR** | | | | | |
| `delivery_qr_code` | text | ✓ | — | UNIQUE | Código QR para validar entrega |
| `delivery_qr_expires_at` | timestamptz | ✓ | — | — | Fecha de expiración del QR de entrega |
| `delivery_validated_at` | timestamptz | ✓ | — | — | Fecha en la que se validó la entrega por QR |
| `return_qr_code` | text | ✓ | — | UNIQUE | Código QR para validar devolución |
| `return_qr_expires_at` | timestamptz | ✓ | — | — | Fecha de expiración del QR de devolución |
| `return_validated_at` | timestamptz | ✓ | — | — | Fecha en la que se validó la devolución por QR |
| `created_at` | timestamptz | ✗ | `now()` | — | Fecha de creación |
| `updated_at` | timestamptz | ✗ | `now()` | Auto-update via trigger | Fecha de última actualización |

---

#### `shipping_orders`

**Descripción**: Registro de órdenes de envío con transportistas externos.

| Campo | Tipo | Nulo | Default | Restricciones | Significado |
|---|---|:---:|---|---|---|
| `id` | uuid | ✗ | `gen_random_uuid()` | PK | Identificador de la orden |
| `user_id` | uuid | ✗ | — | FK → `users(user_id)` ON DELETE CASCADE | Usuario asociado |
| `set_id` | uuid | ✗ | — | FK → `sets(id)` ON DELETE CASCADE | Set a enviar |
| `shipping_order_date` | timestamptz | ✓ | `now()` | — | Fecha de la orden de envío |
| `tracking_ref` | text | ✓ | — | — | Referencia de seguimiento |
| `created_at` | timestamptz | ✓ | `now()` | — | Fecha de creación |
| `updated_at` | timestamptz | ✓ | `now()` | Auto-update via trigger | Fecha de última actualización |

---

#### `reception_operations`

**Descripción**: Registro de operaciones de recepción y mantenimiento de sets devueltos por los usuarios. Se crea automáticamente cuando un envío pasa al estado `returned` (trigger `handle_shipment_warehouse_received`).

| Campo | Tipo | Nulo | Default | Restricciones | Significado |
|---|---|:---:|---|---|---|
| `id` | uuid | ✗ | `gen_random_uuid()` | PK | Identificador de la operación |
| `event_id` | uuid | ✓ | — | FK → `shipments(id)` ON DELETE SET NULL | Envío asociado |
| `user_id` | uuid | ✗ | — | FK → `auth.users(id)` ON DELETE CASCADE | Usuario que devolvió el set |
| `set_id` | uuid | ✗ | — | FK → `sets(id)` ON DELETE CASCADE | Set devuelto |
| `weight_measured` | numeric(10,2) | ✓ | — | — | Peso real medido en la recepción (gramos) |
| `reception_completed` | boolean | ✗ | `false` | — | Si la recepción y verificación está completada |
| `missing_parts` | text | ✓ | — | — | Notas sobre piezas faltantes |
| `created_at` | timestamptz | ✗ | `now()` | — | Fecha de creación |
| `updated_at` | timestamptz | ✗ | `now()` | Auto-update via trigger | Fecha de última actualización |

---

#### `backoffice_operations`

**Descripción**: Log de operaciones de backoffice realizadas por admins y operadores.

| Campo | Tipo | Nulo | Default | Restricciones | Significado |
|---|---|:---:|---|---|---|
| `event_id` | uuid | ✗ | `gen_random_uuid()` | PK | Identificador del evento |
| `user_id` | uuid | ✓ | — | FK → `auth.users(id)` ON DELETE SET NULL | Usuario que realizó la operación |
| `operation_type` | operation_type | ✗ | — | ENUM: `recepcion paquete`, `analisis_peso`, `deposito_fulfillment`, `higienizado`, `retorno_stock` | Tipo de operación realizada |
| `operation_time` | timestamptz | ✗ | `now()` | — | Momento de la operación |
| `metadata` | jsonb | ✓ | — | — | Datos adicionales de la operación |

---

#### `wishlist`

**Descripción**: Lista de deseos de los usuarios. Se usa para asignar sets automáticamente a los usuarios según sus preferencias.

| Campo | Tipo | Nulo | Default | Restricciones | Significado |
|---|---|:---:|---|---|---|
| `id` | uuid | ✗ | `gen_random_uuid()` | PK | Identificador del registro |
| `user_id` | uuid | ✗ | — | FK → `auth.users(id)` ON DELETE CASCADE, UNIQUE(user_id, set_id) | Usuario |
| `set_id` | uuid | ✗ | — | — | Set deseado |
| `status` | boolean | ✗ | `true` | — | `true` = activo en wishlist, `false` = ya fue asignado/removido |
| `status_changed_at` | timestamptz | ✓ | `now()` | — | Fecha del último cambio de estado |
| `created_at` | timestamptz | ✗ | `now()` | — | Fecha en que se añadió a la wishlist |

---

#### `donations`

**Descripción**: Gestión de donaciones de piezas LEGO al proyecto.

| Campo | Tipo | Nulo | Default | Restricciones | Significado |
|---|---|:---:|---|---|---|
| `id` | uuid | ✗ | `gen_random_uuid()` | PK | Identificador de la donación |
| `user_id` | uuid | ✓ | — | FK → `auth.users(id)` ON DELETE SET NULL | Usuario donante (opcional, puede ser anónimo) |
| `name` | text | ✗ | — | — | Nombre del donante |
| `email` | text | ✗ | — | — | Email del donante |
| `phone` | text | ✓ | — | — | Teléfono del donante |
| `address` | text | ✓ | — | — | Dirección para recogida |
| `estimated_weight` | numeric | ✗ | — | — | Peso estimado de la donación (kg) |
| `delivery_method` | text | ✗ | — | CHECK: `pickup-point`, `home-pickup` | Método de entrega de la donación |
| `reward` | text | ✗ | — | CHECK: `economic`, `social` | Tipo de recompensa elegida |
| `children_benefited` | integer | ✗ | — | — | Estimación de niños beneficiados |
| `co2_avoided` | numeric | ✗ | — | — | Estimación de CO₂ evitado (kg) |
| `status` | text | ✗ | `'pending'` | CHECK: `pending`, `confirmed`, `shipped`, `received`, `processed`, `completed` | Estado de la donación |
| `tracking_code` | text | ✓ | — | — | Código de seguimiento del envío de la donación |
| `created_at` | timestamptz | ✗ | `now()` | — | Fecha de creación |
| `updated_at` | timestamptz | ✗ | `now()` | Auto-update via trigger | Fecha de última actualización |

---

#### `reviews`

**Descripción**: Reseñas y valoraciones de los usuarios sobre sets LEGO alquilados.

| Campo | Tipo | Nulo | Default | Restricciones | Significado |
|---|---|:---:|---|---|---|
| `id` | uuid | ✗ | `gen_random_uuid()` | PK | Identificador de la reseña |
| `user_id` | uuid | ✗ | — | FK → `auth.users(id)` ON DELETE CASCADE | Usuario autor de la reseña |
| `set_id` | uuid | ✗ | — | FK → `sets(id)` ON DELETE CASCADE | Set reseñado |
| `envio_id` | uuid | ✓ | — | FK → `shipments(id)` ON DELETE SET NULL, UNIQUE (si no nulo) | Envío asociado (una reseña por envío) |
| `rating` | smallint | ✗ | — | CHECK: 1–5 | Puntuación de 1 a 5 estrellas |
| `comment` | text | ✓ | — | — | Comentario de texto libre |
| `age_fit` | boolean | ✓ | — | — | ¿El set era apropiado para el rango de edad indicado? |
| `difficulty` | smallint | ✓ | — | CHECK: 1–5 | Dificultad de construcción (1=muy fácil, 5=muy difícil) |
| `would_reorder` | boolean | ✓ | — | — | ¿El usuario alquilaría este set otra vez? |
| `is_published` | boolean | ✗ | `true` | — | Si la reseña es visible públicamente |
| `created_at` | timestamptz | ✗ | `now()` | — | Fecha de creación |
| `updated_at` | timestamptz | ✗ | `now()` | Auto-update via trigger | Fecha de última actualización |

---

#### `referrals`

**Descripción**: Programa de referidos. Rastrea quién refirió a quién y el estado de las recompensas.

| Campo | Tipo | Nulo | Default | Restricciones | Significado |
|---|---|:---:|---|---|---|
| `id` | uuid | ✗ | `gen_random_uuid()` | PK | Identificador del referido |
| `referrer_id` | uuid | ✗ | — | FK → `auth.users(id)` ON DELETE CASCADE | Usuario que refirió |
| `referee_id` | uuid | ✗ | — | FK → `auth.users(id)` ON DELETE CASCADE, UNIQUE | Usuario referido |
| `status` | text | ✗ | `'pending'` | CHECK: `pending`, `credited`, `rejected` | `pending`=registro completado, `credited`=recompensa aplicada, `rejected`=no calificó |
| `reward_credits` | integer | ✗ | `1` | — | Créditos otorgados (1 = 1 mes gratis equivalente) |
| `stripe_coupon_id` | text | ✓ | — | — | ID del cupón en Stripe (si aplica) |
| `credited_at` | timestamptz | ✓ | — | — | Fecha en la que se acreditó la recompensa |
| `created_at` | timestamptz | ✗ | `now()` | — | Fecha de creación |
| `updated_at` | timestamptz | ✗ | `now()` | Auto-update via trigger | Fecha de última actualización |

---

#### `brickshare_pudo_locations`

**Descripción**: Puntos de recogida y entrega (PUDO) propios de Brickshare.

| Campo | Tipo | Nulo | Default | Restricciones | Significado |
|---|---|:---:|---|---|---|
| `id` | text | ✗ | — | PK | Identificador del punto PUDO |
| `name` | text | ✗ | — | — | Nombre del punto |
| `address` | text | ✗ | — | — | Dirección |
| `city` | text | ✗ | — | — | Ciudad |
| `postal_code` | text | ✗ | — | — | Código postal |
| `province` | text | ✗ | — | — | Provincia |
| `latitude` | numeric(10,8) | ✓ | — | — | Latitud geográfica |
| `longitude` | numeric(11,8) | ✓ | — | — | Longitud geográfica |
| `contact_phone` | text | ✓ | — | — | Teléfono de contacto del punto |
| `contact_email` | text | ✓ | — | — | Email de contacto del punto |
| `opening_hours` | jsonb | ✓ | — | — | Horarios de apertura (estructura JSON) |
| `is_active` | boolean | ✓ | `true` | — | Si el punto está activo |
| `notes` | text | ✓ | — | — | Notas internas |
| `created_at` | timestamptz | ✓ | `now()` | — | Fecha de creación |
| `updated_at` | timestamptz | ✓ | `now()` | — | Fecha de última actualización |

---

#### `users_correos_dropping`

**Descripción**: Punto PUDO de Correos seleccionado por cada usuario para recibir y devolver sus envíos.

| Campo | Tipo | Nulo | Default | Restricciones | Significado |
|---|---|:---:|---|---|---|
| `user_id` | uuid | ✗ | — | PK, FK → `users(user_id)` ON DELETE CASCADE | Usuario (1 punto por usuario) |
| `correos_id_pudo` | text | ✗ | — | — | ID del punto PUDO en Correos |
| `correos_name` | text | ✗ | — | — | Nombre del punto |
| `correos_point_type` | text | ✗ | — | CHECK: `Oficina`, `Citypaq`, `Locker` | Tipo de punto PUDO |
| `correos_street` | text | ✗ | — | — | Calle |
| `correos_street_number` | text | ✓ | — | — | Número de calle |
| `correos_zip_code` | text | ✗ | — | — | Código postal |
| `correos_city` | text | ✗ | — | — | Ciudad |
| `correos_province` | text | ✗ | — | — | Provincia |
| `correos_country` | text | ✗ | `'España'` | — | País |
| `correos_full_address` | text | ✗ | — | — | Dirección completa formateada |
| `correos_latitude` | numeric(10,8) | ✗ | — | — | Latitud |
| `correos_longitude` | numeric(11,8) | ✗ | — | — | Longitud |
| `correos_opening_hours` | text | ✓ | — | — | Horario de apertura (texto libre) |
| `correos_structured_hours` | jsonb | ✓ | — | — | Horario estructurado (JSON) |
| `correos_available` | boolean | ✗ | `true` | — | Si el punto está disponible |
| `correos_phone` | text | ✓ | — | — | Teléfono del punto |
| `correos_email` | text | ✓ | — | — | Email del punto |
| `correos_internal_code` | text | ✓ | — | — | Código interno de Correos |
| `correos_locker_capacity` | integer | ✓ | — | — | Capacidad del locker (si aplica) |
| `correos_additional_services` | text[] | ✓ | — | — | Servicios adicionales disponibles |
| `correos_accessibility` | boolean | ✓ | `false` | — | Si tiene acceso para personas con movilidad reducida |
| `correos_parking` | boolean | ✓ | `false` | — | Si tiene parking disponible |
| `correos_selection_date` | timestamptz | ✗ | `now()` | — | Fecha de selección del punto |
| `created_at` | timestamptz | ✗ | `now()` | — | Fecha de creación |
| `updated_at` | timestamptz | ✗ | `now()` | Auto-update via trigger | Fecha de última actualización |

---

#### `qr_validation_logs`

**Descripción**: Registro de validaciones de códigos QR para entregas y devoluciones en puntos PUDO Brickshare.

| Campo | Tipo | Nulo | Default | Restricciones | Significado |
|---|---|:---:|---|---|---|
| `id` | uuid | ✗ | `gen_random_uuid()` | PK | Identificador del log |
| `shipment_id` | uuid | ✗ | — | FK → `shipments(id)` ON DELETE CASCADE | Envío asociado |
| `qr_code` | text | ✗ | — | — | Código QR validado |
| `validation_type` | text | ✗ | — | CHECK: `delivery`, `return` | Tipo de validación |
| `validated_by` | text | ✓ | — | — | Identificador de quien validó |
| `validated_at` | timestamptz | ✓ | `now()` | — | Momento de la validación |
| `validation_status` | text | ✗ | — | CHECK: `success`, `expired`, `invalid`, `already_used` | Resultado de la validación |
| `metadata` | jsonb | ✓ | `'{}'` | — | Datos adicionales |
| `created_at` | timestamptz | ✓ | `now()` | — | Fecha de creación |

---

### 3.3 Vistas

#### `brickshare_pudo_shipments`
Vista filtrada de `shipments` que muestra solo envíos gestionados a través de puntos PUDO de Brickshare (`pickup_type = 'brickshare'`).

#### `set_avg_ratings`
Vista que calcula la valoración media y el número de reseñas por set (solo reseñas publicadas).

#### `set_review_stats`
Vista con estadísticas detalladas de reseñas por set: distribución de estrellas, dificultad media y conteo de "volvería a pedir".

---

### 3.4 Funciones RPC Principales

| Función | Parámetros | Descripción |
|---|---|---|
| `preview_assign_sets_to_users()` | — | Muestra las asignaciones propuestas de sets a usuarios elegibles, priorizando la wishlist y evitando duplicados |
| `confirm_assign_sets_to_users(p_user_ids)` | `uuid[]` | Confirma la asignación: crea envíos, actualiza inventario, cambia estado del usuario y desactiva la wishlist correspondiente |
| `delete_assignment_and_rollback(p_envio_id)` | `uuid` | Elimina una asignación y revierte los cambios en inventario, wishlist y estado del usuario |
| `update_set_status_from_return(p_set_id, p_new_status, p_envio_id)` | `uuid, text, uuid` | Actualiza el estado de un set tras la devolución (active, inactive, in_repair) |
| `generate_delivery_qr(p_shipment_id)` | `uuid` | Genera un código QR único para validar la entrega (expira en 30 días) |
| `generate_return_qr(p_shipment_id)` | `uuid` | Genera un código QR único para validar la devolución (expira en 30 días) |
| `validate_qr_code(p_qr_code)` | `text` | Valida un código QR y devuelve información del envío asociado |
| `confirm_qr_validation(p_qr_code, p_validated_by)` | `text, text` | Confirma la validación de un QR, actualizando el estado del envío |
| `has_role(_user_id, _role)` | `uuid, app_role` | Verifica si un usuario tiene un rol específico (usado en políticas RLS) |
| `process_referral_credit(p_referee_user_id)` | `uuid` | Procesa un crédito de referido: acredita puntos al referidor |
| `increment_referral_credits(p_user_id, p_amount)` | `uuid, int` | Incrementa los créditos de referido de un usuario |

---

### 3.5 Triggers Principales

| Tabla | Trigger | Evento | Descripción |
|---|---|---|---|
| `users` | `users_generate_referral_code` | BEFORE INSERT | Genera automáticamente un código de referido único de 6 caracteres |
| `users` | `update_users_updated_at` | BEFORE UPDATE | Actualiza `updated_at` automáticamente |
| `sets` | `on_set_created` | AFTER INSERT | Crea automáticamente un registro en `inventory_sets` con qty=2 |
| `shipments` | `on_shipment_delivered` | AFTER UPDATE | Cuando el estado cambia a `delivered`, actualiza `user_status` a `has_set` |
| `shipments` | `on_shipment_return_user_status` | AFTER UPDATE | Cuando el estado cambia a `return_in_transit`, actualiza `user_status` a `no_set` |
| `shipments` | `on_shipment_return_transit_inv` | AFTER UPDATE | Cuando el estado cambia a `return_in_transit`, incrementa `in_return` en inventario |
| `shipments` | `on_shipment_warehouse_received` | BEFORE UPDATE | Cuando el estado cambia a `returned`, crea una `reception_operation` y registra la fecha |
| `reception_operations` | `on_reception_completed` | AFTER UPDATE | Cuando `reception_completed` = true, actualiza inventario y estado del set (activo o en reparación) |
| Todas las tablas | `update_*_updated_at` | BEFORE UPDATE | Actualiza `updated_at` automáticamente |

---

### 3.6 Diagrama de Relaciones (Simplificado)

```
auth.users (Supabase Auth)
    │
    ├──→ users (1:1 via user_id)
    │       ├──→ users_correos_dropping (1:1 via user_id)
    │       └──→ shipping_orders (1:N via user_id)
    │
    ├──→ user_roles (1:N via user_id)
    ├──→ wishlist (1:N via user_id)
    ├──→ donations (1:N via user_id)
    ├──→ reviews (1:N via user_id)
    ├──→ referrals (1:N como referrer_id o referee_id)
    ├──→ shipments (1:N via user_id)
    ├──→ reception_operations (1:N via user_id)
    └──→ backoffice_operations (1:N via user_id)

sets
    ├──→ set_piece_list (1:N via set_id)
    ├──→ inventory_sets (1:1 via set_id)
    ├──→ shipments (1:N via set_id)
    ├──→ reviews (1:N via set_id)
    ├──→ reception_operations (1:N via set_id)
    └──→ shipping_orders (1:N via set_id)

shipments
    ├──→ reception_operations (1:N via event_id)
    ├──→ qr_validation_logs (1:N via shipment_id)
    └──→ reviews (1:1 via envio_id)
```

---

### 3.7 Row Level Security (RLS)

Todas las tablas tienen RLS habilitado. Los patrones principales son:

| Patrón | Descripción | Tablas |
|---|---|---|
| **Lectura pública** | Cualquiera puede leer (sin autenticación) | `sets`, `set_piece_list`, `inventory_sets`, `brickshare_pudo_locations` (solo activos) |
| **Solo datos propios** | Usuarios solo ven/modifican sus propios datos | `users`, `wishlist`, `shipments`, `donations`, `reviews`, `users_correos_dropping`, `shipping_orders`, `qr_validation_logs` |
| **Admin total** | Admin tiene acceso completo | `sets`, `users`, `user_roles`, `wishlist`, `set_piece_list`, `donations` |
| **Admin + Operador** | Admin y Operador tienen acceso completo | `shipments`, `inventory_sets`, `reception_operations`, `backoffice_operations`, `referrals`, `reviews` |
| **Reseñas publicadas** | Cualquiera puede leer reseñas publicadas | `reviews` (donde `is_published = true`) |