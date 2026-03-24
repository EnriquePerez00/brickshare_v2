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