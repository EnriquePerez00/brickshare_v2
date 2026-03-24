import { faker } from '@faker-js/faker';

/**
 * Integration Test Fixtures - Fase 2
 * Datos dinámicos para tests de integración
 */

export const createMockAuthFlow = () => ({
  email: faker.internet.email(),
  password: 'Password123!',
  fullName: faker.person.fullName(),
  phone: '+34' + faker.string.numeric('9########'),
  address: faker.location.streetAddress(),
  zipCode: faker.location.zipCode('28###'),
  city: 'Madrid',
});

export const createMockSubscriptionFlow = (plan: 'basic' | 'standard' | 'premium') => ({
  plan,
  priceId: `price_${plan}`,
  amount: {
    basic: 999,
    standard: 1999,
    premium: 2999,
  }[plan],
  currency: 'EUR',
});

export const createMockSetAssignmentData = (userId: string, setId: string) => ({
  user_id: userId,
  set_id: setId,
  assignment_date: new Date().toISOString(),
  expected_delivery: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000).toISOString(),
});

export const createMockShipmentTracking = (shipmentId: string) => ({
  shipment_id: shipmentId,
  status: 'en_transito',
  tracking_number: `CORREOS${faker.string.numeric('############')}`,
  current_location: 'Centro de distribución Madrid',
  estimated_delivery: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000).toISOString(),
});

export const createMockPUDOLocation = () => ({
  id: `pudo-${faker.string.numeric('####')}`,
  name: `Punto PUDO ${faker.location.city()}`,
  address: faker.location.streetAddress(),
  zip_code: faker.location.zipCode('28###'),
  city: faker.location.city(),
  latitude: parseFloat(faker.location.latitude()),
  longitude: parseFloat(faker.location.longitude()),
  opening_hours: '09:00-20:00',
  phone: '+34' + faker.string.numeric('9########'),
});

export const createMockWishlistItem = (userId: string, setId: string, priority: number) => ({
  user_id: userId,
  set_id: setId,
  priority,
  added_at: new Date().toISOString(),
});

export const createMockReturnRequest = (userId: string, setId: string) => ({
  user_id: userId,
  set_id: setId,
  reason: 'Completed',
  return_date: new Date().toISOString(),
  status: 'pending',
});

export const createMockProfileUpdate = () => ({
  phone: '+34' + faker.string.numeric('9########'),
  address: faker.location.streetAddress(),
  zip_code: faker.location.zipCode('28###'),
  city: 'Madrid',
  profile_completed: true,
});

export const createMockAdminData = () => ({
  email: `admin-${faker.string.numeric('####')}@brickshare.test`,
  password: 'AdminPassword123!',
  fullName: 'Test Admin',
});

export const createMockOperatorData = () => ({
  email: `operator-${faker.string.numeric('####')}@brickshare.test`,
  password: 'OperatorPassword123!',
  fullName: 'Test Operator',
});

export const createMockSetData = () => ({
  name: `LEGO Set ${faker.string.numeric('####+')}`,
  theme: faker.helpers.arrayElement(['Star Wars', 'City', 'Creator', 'Technic', 'Friends']),
  pieces: parseInt(faker.string.numeric('####+')),
  brickset_id: faker.string.numeric('####'),
  age_range: '14+',
  description: faker.lorem.sentence(),
  market_value: Math.random() * 500 + 50,
});

export const createMockMaintenanceLog = (setId: string) => ({
  set_id: setId,
  status: 'en_mantenimiento',
  issue_description: faker.lorem.sentence(),
  maintenance_date: new Date().toISOString(),
  estimated_completion: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(),
});

export const createMockQRCodeData = (shipmentId: string) => ({
  shipment_id: shipmentId,
  type: faker.helpers.arrayElement(['delivery', 'return']),
  qr_code: `BRICKSHARE-${faker.string.numeric('##############')}`,
  generated_at: new Date().toISOString(),
  expires_at: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
  scans: 0,
});

export const createMockOperationLog = (userId: string, action: string) => ({
  user_id: userId,
  action,
  timestamp: new Date().toISOString(),
  details: `Operation: ${action}`,
  ip_address: faker.internet.ipv4(),
});