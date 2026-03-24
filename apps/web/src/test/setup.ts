import '@testing-library/jest-dom';
import { server } from './mocks/browser';
import { beforeAll, afterEach, afterAll, vi } from 'vitest';

// Inicia MSW server
beforeAll(() => server.listen());

// Limpia handlers después de cada test
afterEach(() => {
  server.resetHandlers();
  vi.clearAllMocks();
});

// Cierra servidor después de todos los tests
afterAll(() => server.close());

// Configurar window.matchMedia mock
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: vi.fn().mockImplementation((query) => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: vi.fn(),
    removeListener: vi.fn(),
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
    dispatchEvent: vi.fn(),
  })),
});