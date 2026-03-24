import { describe, it, expect, beforeEach, vi } from 'vitest';
import { renderHook, act, waitFor } from '@testing-library/react';
import { mockUser, mockProfile, mockSession } from '@/test/fixtures/users';

// Usar vi.hoisted para declarar el mock antes del hoisting
// Variable compartida para configurar dinámicamente los roles
let mockRolesData: { role: string }[] = [];

const { mockSupabaseClient } = vi.hoisted(() => ({
  mockSupabaseClient: {
    auth: {
      signUp: vi.fn(),
      signInWithPassword: vi.fn(),
      signInWithOAuth: vi.fn(),
      signOut: vi.fn(),
      resetPasswordForEmail: vi.fn(),
      updateUser: vi.fn(),
      getSession: vi.fn(),
      onAuthStateChange: vi.fn(() => ({
        data: { subscription: { unsubscribe: vi.fn() } },
      })),
    },
    from: vi.fn((table: string) => {
      // Mock específico para la tabla user_roles
      if (table === 'user_roles') {
        return {
          select: vi.fn().mockReturnThis(),
          eq: vi.fn().mockResolvedValue({
            data: mockRolesData,
            error: null,
          }),
        };
      }
      // Mock genérico para otras tablas (users, etc.)
      return {
        select: vi.fn().mockReturnThis(),
        insert: vi.fn().mockReturnThis(),
        update: vi.fn().mockReturnThis(),
        delete: vi.fn().mockReturnThis(),
        eq: vi.fn().mockReturnThis(),
        maybeSingle: vi.fn().mockResolvedValue({ data: null, error: null }),
      };
    }),
    functions: {
      invoke: vi.fn(),
    },
  },
}));

vi.mock('@/integrations/supabase/client', () => ({
  supabase: mockSupabaseClient,
}));

import { useAuth } from '@/contexts/AuthContext';
import { AuthProvider } from '@/contexts/AuthContext';

describe('useAuth', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    // Resetear los datos de roles antes de cada test
    mockRolesData = [];
  });

  describe('initialization', () => {
    it('should initialize with null values', async () => {
      mockSupabaseClient.auth.getSession.mockResolvedValue({
        data: { session: null },
      });

      const wrapper = ({ children }: { children: React.ReactNode }) => (
        <AuthProvider>{children}</AuthProvider>
      );

      const { result } = renderHook(() => useAuth(), { wrapper });

      await waitFor(() => {
        expect(result.current.isLoading).toBe(false);
      });

      expect(result.current.user).toBeNull();
      expect(result.current.session).toBeNull();
    });

    it('should initialize with existing session', async () => {
      mockSupabaseClient.auth.getSession.mockResolvedValue({
        data: { session: mockSession },
      });

      mockSupabaseClient.auth.onAuthStateChange.mockReturnValue({
        data: { subscription: { unsubscribe: vi.fn() } },
      });

      const wrapper = ({ children }: { children: React.ReactNode }) => (
        <AuthProvider>{children}</AuthProvider>
      );

      const { result } = renderHook(() => useAuth(), { wrapper });

      await waitFor(() => {
        expect(result.current.isLoading).toBe(false);
      });

      expect(result.current.user).not.toBeNull();
    });
  });

  describe('signUp', () => {
    it('should handle successful signup', async () => {
      mockSupabaseClient.auth.signUp.mockResolvedValue({
        data: { user: mockUser },
        error: null,
      });

      const wrapper = ({ children }: { children: React.ReactNode }) => (
        <AuthProvider>{children}</AuthProvider>
      );

      const { result } = renderHook(() => useAuth(), { wrapper });

      let signupResult;
      await act(async () => {
        signupResult = await result.current.signUp('test@example.com', 'password123', 'Test User');
      });

      expect(signupResult?.error).toBeNull();
      expect(mockSupabaseClient.auth.signUp).toHaveBeenCalledWith({
        email: 'test@example.com',
        password: 'password123',
        options: expect.objectContaining({
          data: { full_name: 'Test User' },
        }),
      });
    });

    it('should handle signup error', async () => {
      const error = new Error('User already registered');
      mockSupabaseClient.auth.signUp.mockResolvedValue({
        data: null,
        error,
      });

      const wrapper = ({ children }: { children: React.ReactNode }) => (
        <AuthProvider>{children}</AuthProvider>
      );

      const { result } = renderHook(() => useAuth(), { wrapper });

      let signupResult;
      await act(async () => {
        signupResult = await result.current.signUp('test@example.com', 'password123');
      });

      expect(signupResult?.error).toEqual(error);
    });
  });

  describe('signIn', () => {
    it('should handle successful signin', async () => {
      mockSupabaseClient.auth.signInWithPassword.mockResolvedValue({
        data: { user: mockUser, session: mockSession },
        error: null,
      });

      const wrapper = ({ children }: { children: React.ReactNode }) => (
        <AuthProvider>{children}</AuthProvider>
      );

      const { result } = renderHook(() => useAuth(), { wrapper });

      let signinResult;
      await act(async () => {
        signinResult = await result.current.signIn('test@example.com', 'password123');
      });

      expect(signinResult?.error).toBeNull();
      expect(mockSupabaseClient.auth.signInWithPassword).toHaveBeenCalledWith({
        email: 'test@example.com',
        password: 'password123',
      });
    });
  });

  describe('signOut', () => {
    it('should handle logout', async () => {
      mockSupabaseClient.auth.signOut.mockResolvedValue({ error: null });

      const wrapper = ({ children }: { children: React.ReactNode }) => (
        <AuthProvider>{children}</AuthProvider>
      );

      const { result } = renderHook(() => useAuth(), { wrapper });

      await act(async () => {
        await result.current.signOut();
      });

      expect(mockSupabaseClient.auth.signOut).toHaveBeenCalled();
    });
  });

  describe('resetPassword', () => {
    it('should handle password reset request', async () => {
      mockSupabaseClient.auth.resetPasswordForEmail.mockResolvedValue({
        data: {},
        error: null,
      });

      const wrapper = ({ children }: { children: React.ReactNode }) => (
        <AuthProvider>{children}</AuthProvider>
      );

      const { result } = renderHook(() => useAuth(), { wrapper });

      let resetResult;
      await act(async () => {
        resetResult = await result.current.resetPassword('test@example.com');
      });

      expect(resetResult?.error).toBeNull();
    });
  });

  describe('updateUserPassword', () => {
    it('should handle password update', async () => {
      mockSupabaseClient.auth.updateUser.mockResolvedValue({
        data: { user: mockUser },
        error: null,
      });

      const wrapper = ({ children }: { children: React.ReactNode }) => (
        <AuthProvider>{children}</AuthProvider>
      );

      const { result } = renderHook(() => useAuth(), { wrapper });

      let updateResult;
      await act(async () => {
        updateResult = await result.current.updateUserPassword('newpassword123');
      });

      expect(updateResult?.error).toBeNull();
    });
  });

  describe('role checks', () => {
    it('should identify admin role', async () => {
      // Configurar los datos de roles ANTES de renderizar
      mockRolesData = [{ role: 'admin' }];

      mockSupabaseClient.auth.getSession.mockResolvedValue({
        data: { session: mockSession },
      });

      mockSupabaseClient.auth.onAuthStateChange.mockReturnValue({
        data: { subscription: { unsubscribe: vi.fn() } },
      });

      const wrapper = ({ children }: { children: React.ReactNode }) => (
        <AuthProvider>{children}</AuthProvider>
      );

      const { result } = renderHook(() => useAuth(), { wrapper });

      // Esperar primero a que termine de cargar
      await waitFor(
        () => {
          expect(result.current.isLoading).toBe(false);
        },
        { timeout: 3000 }
      );

      // Luego verificar el rol admin
      await waitFor(
        () => {
          expect(result.current.isAdmin).toBe(true);
        },
        { timeout: 3000 }
      );

      // Verificar que operador es false
      expect(result.current.isOperador).toBe(false);
    });

    it('should identify operador role', async () => {
      // Configurar los datos de roles ANTES de renderizar
      mockRolesData = [{ role: 'operador' }];

      mockSupabaseClient.auth.getSession.mockResolvedValue({
        data: { session: mockSession },
      });

      mockSupabaseClient.auth.onAuthStateChange.mockReturnValue({
        data: { subscription: { unsubscribe: vi.fn() } },
      });

      const wrapper = ({ children }: { children: React.ReactNode }) => (
        <AuthProvider>{children}</AuthProvider>
      );

      const { result } = renderHook(() => useAuth(), { wrapper });

      // Esperar primero a que termine de cargar
      await waitFor(
        () => {
          expect(result.current.isLoading).toBe(false);
        },
        { timeout: 3000 }
      );

      // Luego verificar el rol operador
      await waitFor(
        () => {
          expect(result.current.isOperador).toBe(true);
        },
        { timeout: 3000 }
      );

      // Verificar que admin es false
      expect(result.current.isAdmin).toBe(false);
    });
  });
});