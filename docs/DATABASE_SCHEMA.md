# Brickshare — Esquema de Base de Datos

## Diagrama Entidad-Relación

```
profiles ──────────────────────────────────────────────────────────────────────┐
│ id (uuid, PK, FK → auth.users)                                               │
│ email (text)                                                                  │
│ full_name (text)                                                              │
│ role (text: 'user'|'admin'|'operador')                                        │
│ address (text)                                                                │
│ city (text)                                                                   │
│ postal_code (text)                                                            │
│ phone (text)                                                                  │
│ subscription_plan (text)                                                      │
│ stripe_customer_id (text)                                                     │
│ created_at (timestamptz)                                                      │
│ updated_at (timestamptz)                                                      │
└───────────────────────────────────────────────────────────────────────────────┘
        │                   │                    │
        │ 1:N               │ 1:N                │ 1:N
        ▼                   ▼                    ▼
   orders            subscriptions           wishlist
        │                                        │
        │ 1:1                                    │ N:1
        ▼                                        ▼
      envios                                    sets
                                                 │
                                                 │ 1:N
                                                 ▼
                                          inventario_sets
                                                 │
                                                 │ 1:N (set_id)
                                                 ▼
                                          set_piece_list
```

---

## Tablas Detalladas

### `profiles`
Extiende `auth.users` de Supabase. Se crea automáticamente via trigger al registrarse.

| Columna | Tipo | Descripción |
|---|---|---|
| `id` | uuid PK | FK a auth.users.id |
| `email` | text | Email del usuario |
| `full_name` | text | Nombre completo |
| `role` | text | 'user', 'admin', 'operador' |
| `address` | text | Dirección de envío |
| `city` | text | Ciudad |
| `postal_code` | text | Código postal |
| `phone` | text | Teléfono de contacto |
| `subscription_plan` | text | Plan activo ('basic','standard','premium') |
| `stripe_customer_id` | text | ID cliente en Stripe |
| `avatar_url` | text | URL imagen perfil |
| `created_at` | timestamptz | Fecha de registro |
| `updated_at` | timestamptz | Última actualización |

---

### `sets`
Catálogo de sets de LEGO disponibles en la plataforma.

| Columna | Tipo | Descripción |
|---|---|---|
| `id` | uuid PK | Identificador único |
| `name` | text NOT NULL | Nombre del set |
| `lego_ref` | text | Número oficial del set LEGO (ej: "75192") |
| `theme` | text | Temática (Star Wars, City, Technic...) |
| `piece_count` | integer | Número de piezas |
| `age_range` | text | Rango de edad recomendado |
| `img_url` | text | URL imagen principal |
| `description` | text | Descripción del set |
| `difficulty` | text | Nivel de dificultad |
| `year_released` | integer | Año de lanzamiento |
| `retail_price` | numeric | Precio de venta original LEGO |
| `rental_price` | numeric | Precio de alquiler mensual |
| `available` | boolean | Disponible para alquiler |
| `tags` | text[] | Etiquetas para búsqueda |
| `created_at` | timestamptz | Fecha de alta |
| `updated_at` | timestamptz | Última actualización |

---

### `inventario_sets`
Control de inventario físico. Cada fila representa una unidad física de un set.

| Columna | Tipo | Descripción |
|---|---|---|
| `id` | uuid PK | Identificador único |
| `set_id` | uuid FK→sets | Set de referencia |
| `estado` | text | 'disponible','alquilado','en_limpieza','dañado','retirado' |
| `ubicacion` | text | Ubicación física en almacén |
| `codigo_interno` | text | Código de barras/QR interno |
| `notas` | text | Observaciones del operador |
| `created_at` | timestamptz | Fecha de alta |
| `updated_at` | timestamptz | Última actualización |

---

### `set_piece_list`
Lista de piezas de cada set (para control de inventario de piezas).

| Columna | Tipo | Descripción |
|---|---|---|
| `id` | uuid PK | Identificador único |
| `set_id` | uuid FK→sets | Set al que pertenece |
| `piece_id` | text | ID de la pieza (Rebrickable ID) |
| `quantity` | integer | Cantidad de esta pieza en el set |
| `color` | text | Color de la pieza |
| `studdim` | text | Dimensiones en studs |
| `weight_g` | numeric | Peso en gramos |
| `created_at` | timestamptz | Fecha de alta |

---

### `orders`
Pedidos de alquiler realizados por los usuarios.

| Columna | Tipo | Descripción |
|---|---|---|
| `id` | uuid PK | Identificador único |
| `user_id` | uuid FK→profiles | Usuario que realiza el pedido |
| `set_id` | uuid FK→sets | Set solicitado |
| `inventario_set_id` | uuid FK→inventario_sets | Unidad física asignada |
| `status` | text | 'pendiente','confirmado','enviado','entregado','devolucion','completado','cancelado' |
| `created_at` | timestamptz | Fecha del pedido |
| `updated_at` | timestamptz | Última actualización |
| `notes` | text | Notas adicionales |

---

### `envios`
Información logística de cada envío asociado a un pedido.

| Columna | Tipo | Descripción |
|---|---|---|
| `id` | uuid PK | Identificador único |
| `order_id` | uuid FK→orders | Pedido asociado |
| `correos_shipment_id` | text | ID envío en sistema Correos |
| `tracking_code` | text | Código de seguimiento |
| `pudo_point_id` | text | ID punto PUDO de entrega |
| `pudo_point_name` | text | Nombre del punto PUDO |
| `status` | text | Estado del envío |
| `label_url` | text | URL etiqueta de envío |
| `qr_code_url` | text | URL QR del envío |
| `estimated_delivery` | date | Fecha estimada entrega |
| `delivered_at` | timestamptz | Fecha real de entrega |
| `created_at` | timestamptz | Fecha de creación |
| `updated_at` | timestamptz | Última actualización |

---

### `subscriptions`
Historial de suscripciones de Stripe.

| Columna | Tipo | Descripción |
|---|---|---|
| `id` | uuid PK | Identificador único |
| `user_id` | uuid FK→profiles | Usuario |
| `stripe_subscription_id` | text UNIQUE | ID suscripción en Stripe |
| `stripe_customer_id` | text | ID cliente en Stripe |
| `plan` | text | 'basic','standard','premium' |
| `status` | text | 'active','canceled','past_due','trialing' |
| `current_period_start` | timestamptz | Inicio del período actual |
| `current_period_end` | timestamptz | Fin del período actual |
| `canceled_at` | timestamptz | Fecha de cancelación |
| `created_at` | timestamptz | Fecha de alta |

---

### `wishlist`
Lista de deseos de los usuarios.

| Columna | Tipo | Descripción |
|---|---|---|
| `id` | uuid PK | Identificador único |
| `user_id` | uuid FK→profiles | Usuario |
| `set_id` | uuid FK→sets | Set deseado |
| `created_at` | timestamptz | Fecha de añadir |

**Constraint:** UNIQUE(user_id, set_id)

---

### `donations`
Registro de donaciones de sets o económicas.

| Columna | Tipo | Descripción |
|---|---|---|
| `id` | uuid PK | Identificador único |
| `user_id` | uuid FK→profiles | Donante (puede ser null si anónimo) |
| `donor_name` | text | Nombre del donante |
| `donor_email` | text | Email para confirmación |
| `type` | text | 'set','monetary' |
| `amount` | numeric | Importe (si es monetaria) |
| `set_description` | text | Descripción del set donado |
| `message` | text | Mensaje del donante |
| `status` | text | 'pending','accepted','rejected' |
| `created_at` | timestamptz | Fecha de donación |

---

## Políticas RLS Principales

```sql
-- profiles: cada usuario ve y edita solo su perfil
CREATE POLICY "Users read own profile"
  ON profiles FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users update own profile"
  ON profiles FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Admin full access profiles"
  ON profiles FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- sets: lectura pública, escritura solo admin
CREATE POLICY "Public read sets"
  ON sets FOR SELECT USING (true);

CREATE POLICY "Admin manage sets"
  ON sets FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- orders: usuarios ven sus pedidos; admin/operador ven todos
CREATE POLICY "Users read own orders"
  ON orders FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Admin full access orders"
  ON orders FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'operador'))
  );
```

---

## Índices Recomendados

```sql
-- Búsquedas frecuentes en catálogo
CREATE INDEX idx_sets_theme ON sets(theme);
CREATE INDEX idx_sets_available ON sets(available);
CREATE INDEX idx_sets_lego_ref ON sets(lego_ref);

-- Consultas de usuario
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_wishlist_user_id ON wishlist(user_id);

-- Inventario
CREATE INDEX idx_inventario_set_id ON inventario_sets(set_id);
CREATE INDEX idx_inventario_estado ON inventario_sets(estado);

-- Envíos
CREATE INDEX idx_envios_order_id ON envios(order_id);
CREATE INDEX idx_envios_tracking ON envios(tracking_code);
```

---

## Triggers y Funciones SQL

### Trigger: Crear perfil al registrarse
```sql
CREATE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (new.id, new.email, new.raw_user_meta_data->>'full_name');
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
```

### Trigger: Actualizar updated_at automáticamente
```sql
CREATE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar a tablas relevantes
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();