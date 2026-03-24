# 📦 Test Data Fixtures

Documentación de todas las fixtures (datos de prueba) reutilizables para los tests.

## Overview

Las fixtures se encuentran en `apps/web/src/test/fixtures/` y contienen datos de prueba predefinidos que se utilizan en múltiples tests.

## 🧑 Users Fixtures

**Archivo**: `apps/web/src/test/fixtures/users.ts`

### Mock Users

```typescript
export const mockUser = {
  id: 'user-1',
  email: 'user@example.com',
  user_metadata: {
    full_name: 'John Doe',
  },
  aud: 'authenticated',
  role: 'authenticated',
  email_confirmed_at: '2024-01-01T00:00:00Z',
  phone: '+34612345678',
  created_at: '2024-01-01T00:00:00Z',
};

export const mockAdmin = {
  ...mockUser,
  id: 'admin-1',
  email: 'admin@example.com',
  user_metadata: {
    full_name: 'Admin User',
  },
};

export const mockOperador = {
  ...mockUser,
  id: 'operador-1',
  email: 'operador@example.com',
  user_metadata: {
    full_name: 'Operador User',
  },
};
```

### Mock Profiles

```typescript
export const mockProfile = {
  id: 'profile-1',
  user_id: 'user-1',
  full_name: 'John Doe',
  email: 'user@example.com',
  avatar_url: null,
  user_status: 'active',
  impact_points: 150,
  address: 'Calle Principal 123',
  zip_code: '28001',
  city: 'Madrid',
  phone: '+34612345678',
  subscription_status: 'active',
  subscription_type: 'standard',
  profile_completed: true,
};

export const mockProfileIncomplete = {
  ...mockProfile,
  full_name: null,
  phone: null,
  address: null,
  zip_code: null,
  city: null,
  profile_completed: false,
};

export const mockSession = {
  user: mockUser,
  access_token: 'mock-access-token-123',
  refresh_token: 'mock-refresh-token-456',
  expires_in: 3600,
  expires_at: Math.floor(Date.now() / 1000) + 3600,
  token_type: 'bearer',
};
```

## 🧱 Sets Fixtures

**Archivo**: `apps/web/src/test/fixtures/sets.ts`

### Mock Sets

```typescript
export const mockSet = {
  id: 'set-1',
  set_ref: '75192',
  name: 'UCS Millennium Falcon',
  theme: 'Star Wars',
  piece_count: 7541,
  age_range: '16+',
  description: 'Iconic LEGO Star Wars set',
  img_url: 'https://example.com/set-1.jpg',
  price: 799.99,
  status: 'active',
  brickset_url: 'https://brickset.com/sets/75192-1',
  rebrickable_id: '75192-1',
  year_released: 2017,
  weight: 15.5,
  dimensions: { length: 84, width: 56, height: 17 },
};

export const mockSetBasic = {
  ...mockSet,
  id: 'set-2',
  set_ref: '10298',
  name: 'Titanic',
  theme: 'Architecture',
  piece_count: 9090,
  price: 399.99,
};

export const mockSetSmall = {
  ...mockSet,
  id: 'set-3',
  set_ref: '21303',
  name: 'WALL-E',
  theme: 'Ideas',
  piece_count: 677,
  price: 199.99,
};

export const mockSets = [mockSet, mockSetBasic, mockSetSmall];

export const mockPieceListItem = {
  id: 'piece-1',
  set_id: 'set-1',
  piece_id: '3001',
  quantity: 50,
  color: 'Black',
  piece_name: 'Brick 2x4',
  studdim: { x: 2, y: 4 },
};
```

## 📦 Shipments Fixtures

**Archivo**: `apps/web/src/test/fixtures/shipments.ts`

### Mock Shipments

```typescript
export const mockShipment = {
  id: 'shipment-1',
  assignment_id: 'assign-1',
  user_id: 'user-1',
  set_id: 'set-1',
  set_ref: '75192',
  direction: 'outgoing',
  status: 'en_transito',
  pudo_point_id: 'pudo-1',
  pudo_name: 'Correos Atocha',
  pudo_address: 'Calle Atocha 1',
  pudo_zip: '28012',
  pudo_city: 'Madrid',
  tracking_number: 'CC000123456ES',
  delivery_qr_code: 'QR-DELIVERY-123',
  return_qr_code: 'QR-RETURN-456',
  expected_delivery_date: '2024-03-30',
  actual_delivery_date: null,
  created_at: '2024-03-23T10:00:00Z',
  updated_at: '2024-03-23T12:00:00Z',
};

export const mockShipmentDelivered = {
  ...mockShipment,
  id: 'shipment-2',
  status: 'entregado',
  actual_delivery_date: '2024-03-30',
};

export const mockShipmentReturn = {
  ...mockShipment,
  id: 'shipment-3',
  direction: 'incoming',
  status: 'devuelto',
  expected_delivery_date: '2024-04-15',
  actual_delivery_date: '2024-04-15',
};

export const mockShipments = [
  mockShipment,
  mockShipmentDelivered,
  mockShipmentReturn,
];

export const mockAssignment = {
  id: 'assign-1',
  user_id: 'user-1',
  set_id: 'set-1',
  set_ref: '75192',
  status: 'active',
  assigned_at: '2024-03-20T00:00:00Z',
  due_date: '2024-04-20',
  created_at: '2024-03-20T00:00:00Z',
};
```

## 🛒 Subscription Fixtures

**Archivo**: `apps/web/src/test/fixtures/subscriptions.ts` (nuevo)

```typescript
export const mockSubscriptionBasic = {
  id: 'sub-1',
  user_id: 'user-1',
  stripe_subscription_id: 'sub_123456',
  plan: 'basic',
  status: 'active',
  price_per_month: 29.99,
  max_simultaneous_sets: 1,
  renewal_date: '2024-04-23',
  created_at: '2024-03-23T00:00:00Z',
  next_billing_date: '2024-04-23',
};

export const mockSubscriptionStandard = {
  ...mockSubscriptionBasic,
  id: 'sub-2',
  plan: 'standard',
  price_per_month: 49.99,
  max_simultaneous_sets: 2,
};

export const mockSubscriptionPremium = {
  ...mockSubscriptionBasic,
  id: 'sub-3',
  plan: 'premium',
  price_per_month: 79.99,
  max_simultaneous_sets: 3,
};

export const mockSubscriptionCancelled = {
  ...mockSubscriptionBasic,
  id: 'sub-4',
  status: 'cancelled',
  cancelled_at: '2024-03-23T00:00:00Z',
};
```

## 🗺️ PUDO Fixtures

**Archivo**: `apps/web/src/test/fixtures/pudo.ts` (nuevo)

```typescript
export const mockPudoLocation = {
  id: 'pudo-1',
  name: 'Correos Atocha',
  address: 'Calle Atocha 1',
  zip_code: '28012',
  city: 'Madrid',
  province: 'Madrid',
  latitude: 40.409264,
  longitude: -3.693591,
  phone: '+34912983000',
  opening_hours: '09:00-20:00',
  is_active: true,
};

export const mockPudoLocations = [
  mockPudoLocation,
  {
    ...mockPudoLocation,
    id: 'pudo-2',
    name: 'Correos Plaza Mayor',
    address: 'Plaza Mayor 1',
    latitude: 40.415363,
    longitude: -3.707398,
  },
  {
    ...mockPudoLocation,
    id: 'pudo-3',
    name: 'Correos Retiro',
    address: 'Calle Retiro 1',
    latitude: 40.414639,
    longitude: -3.681759,
  },
];
```

## 💬 Reviews Fixtures

**Archivo**: `apps/web/src/test/fixtures/reviews.ts` (nuevo)

```typescript
export const mockReview = {
  id: 'review-1',
  set_id: 'set-1',
  user_id: 'user-1',
  rating: 5,
  title: 'Excelente set',
  comment: 'Muy bien conservado, llegó en perfecto estado',
  created_at: '2024-03-15T00:00:00Z',
  updated_at: '2024-03-15T00:00:00Z',
};

export const mockReviews = [
  mockReview,
  {
    ...mockReview,
    id: 'review-2',
    user_id: 'user-2',
    rating: 4,
    title: 'Muy bueno',
  },
  {
    ...mockReview,
    id: 'review-3',
    user_id: 'user-3',
    rating: 3,
    title: 'Aceptable',
  },
];
```

## 🎁 Wishlist Fixtures

**Archivo**: `apps/web/src/test/fixtures/wishlist.ts` (nuevo)

```typescript
export const mockWishlistItem = {
  id: 'wish-1',
  user_id: 'user-1',
  set_id: 'set-1',
  priority: 1,
  created_at: '2024-03-20T00:00:00Z',
};

export const mockWishlistItems = [
  mockWishlistItem,
  {
    ...mockWishlistItem,
    id: 'wish-2',
    set_id: 'set-2',
    priority: 2,
  },
  {
    ...mockWishlistItem,
    id: 'wish-3',
    set_id: 'set-3',
    priority: 3,
  },
];
```

## 🧬 Factory Functions

Funciones helper para generar datos dinámicos:

```typescript
// Usar Faker.js para datos realistas
import { faker } from '@faker-js/faker';

export function createMockUser(overrides = {}) {
  return {
    id: faker.string.uuid(),
    email: faker.internet.email(),
    user_metadata: {
      full_name: faker.person.fullName(),
    },
    ...overrides,
  };
}

export function createMockSet(overrides = {}) {
  return {
    id: faker.string.uuid(),
    set_ref: faker.string.numeric(5),
    name: faker.commerce.productName(),
    piece_count: faker.number.int({ min: 100, max: 10000 }),
    price: faker.number.float({ min: 50, max: 800, precision: 0.01 }),
    ...overrides,
  };
}

export function createMockShipment(overrides = {}) {
  return {
    id: faker.string.uuid(),
    tracking_number: faker.string.alphaNumeric(20).toUpperCase(),
    status: faker.helpers.arrayElement(['en_transito', 'entregado', 'devuelto']),
    created_at: faker.date.recent().toISOString(),
    ...overrides,
  };
}
```

## 📖 Uso en Tests

### Ejemplo 1: Test con Fixtures Simples

```typescript
import { mockUser, mockProfile } from '@/test/fixtures/users';
import { mockSet } from '@/test/fixtures/sets';

describe('Dashboard', () => {
  it('should display user sets', () => {
    const { render } = render(<Dashboard />, {
      mockData: {
        user: mockUser,
        profile: mockProfile,
        sets: [mockSet],
      },
    });

    expect(screen.getByText(mockSet.name)).toBeInTheDocument();
  });
});
```

### Ejemplo 2: Test con Factory Functions

```typescript
import { createMockSet } from '@/test/fixtures/sets';

describe('Catalog', () => {
  it('should filter sets by price range', () => {
    const cheapSet = createMockSet({ price: 50 });
    const expensiveSet = createMockSet({ price: 500 });

    const filtered = [cheapSet, expensiveSet].filter(s => s.price < 100);

    expect(filtered).toHaveLength(1);
    expect(filtered[0]).toEqual(cheapSet);
  });
});
```

### Ejemplo 3: Test con MSW Handlers

```typescript
import { http, HttpResponse } from 'msw';
import { mockSets } from '@/test/fixtures/sets';

// En el test
server.use(
  http.get('*/rest/v1/sets', () => {
    return HttpResponse.json(mockSets);
  })
);

render(<Catalog />);
await screen.findByText(mockSets[0].name);
```

## ✅ Checklist de Fixtures

- [x] Users fixtures
- [x] Sets fixtures
- [x] Shipments fixtures
- [ ] Subscriptions fixtures (create if needed)
- [ ] PUDO fixtures (create if needed)
- [ ] Reviews fixtures (create if needed)
- [ ] Wishlist fixtures (create if needed)
- [ ] Factory functions (create if needed)

## 🔄 Mantenimiento de Fixtures

1. **Actualizar cuando cambia el schema** de la BD
2. **Sincronizar con migrations** más recientes
3. **Reutilizar** entre múltiples tests
4. **Documentar** nuevas fixtures
5. **Revisar** valores realistas con Faker.js

---

**Próximo Paso**: Ejecutar los tests con `npm run test -w @brickshare/web`