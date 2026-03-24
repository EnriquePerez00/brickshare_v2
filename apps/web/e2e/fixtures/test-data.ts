/**
 * E2E Test Data Fixtures
 * Reusable test data for E2E tests
 */

export const testUsers = {
  regularUser: {
    email: 'user@test.local',
    password: 'TestPassword123!',
    fullName: 'Test User',
    phone: '+34612345678',
    address: 'Calle Test 123',
    zipCode: '28001',
    city: 'Madrid',
  },
  adminUser: {
    email: 'admin@test.local',
    password: 'AdminPassword123!',
    fullName: 'Admin User',
    phone: '+34612345679',
    address: 'Calle Admin 456',
    zipCode: '28002',
    city: 'Madrid',
  },
  operatorUser: {
    email: 'operator@test.local',
    password: 'OperatorPassword123!',
    fullName: 'Operator User',
    phone: '+34612345680',
    address: 'Calle Operator 789',
    zipCode: '28003',
    city: 'Madrid',
  },
};

export const testSets = {
  starWars: {
    name: 'Star Wars Millennium Falcon',
    brickset_id: '75192',
    pieces: 1351,
    theme: 'Star Wars',
  },
  cityPoliceStation: {
    name: 'City Police Station',
    brickset_id: '60141',
    pieces: 973,
    theme: 'City',
  },
  harryPotterHogwarts: {
    name: 'Harry Potter Hogwarts Castle',
    brickset_id: '71043',
    pieces: 6020,
    theme: 'Harry Potter',
  },
};

export const subscriptionPlans = {
  basic: {
    name: 'Basic',
    monthlyPrice: 9.99,
    setsPerMonth: 1,
  },
  standard: {
    name: 'Standard',
    monthlyPrice: 19.99,
    setsPerMonth: 2,
  },
  premium: {
    name: 'Premium',
    monthlyPrice: 29.99,
    setsPerMonth: 3,
  },
};

export const pudoLocations = {
  madrid: {
    name: 'PUDO Madrid Centro',
    address: 'Calle Mayor 100',
    zipCode: '28001',
    city: 'Madrid',
  },
  barcelona: {
    name: 'PUDO Barcelona Eixample',
    address: 'Passeig de Gràcia 50',
    zipCode: '08007',
    city: 'Barcelona',
  },
};

export const stripeTestCards = {
  successCard: {
    number: '4242 4242 4242 4242',
    expiry: '12/25',
    cvc: '123',
  },
  declineCard: {
    number: '4000 0000 0000 0002',
    expiry: '12/25',
    cvc: '123',
  },
};

/**
 * Helper functions for test data
 */

export const generateUniqueEmail = (): string => {
  return `test-${Date.now()}@local.test`;
};

export const generateTrackingNumber = (): string => {
  return `CORREOS${Date.now()}${Math.floor(Math.random() * 10000)}`;
};

export const generateQRCode = (): string => {
  return `BRICKSHARE-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
};