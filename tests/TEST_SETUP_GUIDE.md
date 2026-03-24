# 🔧 Testing Setup Guide

Guía paso a paso para configurar el entorno de testing en Brickshare.

## 📋 Prerequisitos

```bash
# Node.js 18+
node --version

# npm 8+
npm --version
```

## 📦 Dependencias Instaladas

```json
{
  "@testing-library/react": "^14.0.0",
  "@testing-library/jest-dom": "^6.1.0",
  "@testing-library/user-event": "^14.5.0",
  "msw": "^1.3.0",
  "@faker-js/faker": "^8.0.0",
  "vitest": "^0.34.0",
  "vitest-mock-extended": "^1.1.0"
}
```

## 📂 Estructura de Carpetas

```bash
apps/web/
├── src/
│   ├── test/
│   │   ├── setup.ts                 # Setup global de Vitest
│   │   ├── mocks/
│   │   │   ├── supabase.ts         # Mock de Supabase client
│   │   │   ├── handlers.ts         # MSW request handlers
│   │   │   └── browser.ts          # MSW browser setup
│   │   └── fixtures/
│   │       ├── users.ts            # Datos de usuarios
│   │       ├── sets.ts             # Datos de sets
│   │       └── shipments.ts        # Datos de shipments
│   └── __tests__/
│       ├── unit/
│       │   ├── hooks/
│       │   ├── components/
│       │   └── utils/
│       └── integration/             # Fase 2+
└── vitest.config.ts                # Configuración Vitest
```

## 🔧 Configuración de Vitest

El archivo `apps/web/vitest.config.ts` ya está configurado:

```typescript
export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: "jsdom",
    setupFiles: ["./src/test/setup.ts"],
    include: ["src/**/*.test.{ts,tsx}"],
    coverage: {
      provider: "v8",
      reporter: ["text", "json", "html"],
      thresholds: {
        lines: 50,
        functions: 50,
        branches: 40,
      },
    },
  },
});
```

### Parámetros Clave

| Parámetro | Valor | Descripción |
|---|---|---|
| `globals: true` | - | APIs de Vitest (describe, it, expect) disponibles globalmente |
| `environment: "jsdom"` | - | Simula browser para testing de React |
| `setupFiles` | `src/test/setup.ts` | Archivo que se ejecuta antes de cada test |
| `include` | `src/**/*.test.{ts,tsx}` | Pattern para buscar archivos de test |

## 🛠️ Archivos de Setup

### 1. `src/test/setup.ts` (Global Setup)

```typescript
import '@testing-library/jest-dom';
import { server } from './mocks/browser';
import { beforeAll, afterEach, afterAll } from 'vitest';

// Inicia MSW server
beforeAll(() => server.listen());

// Limpia handlers después de cada test
afterEach(() => server.resetHandlers());

// Cierra servidor después de todos los tests
afterAll(() => server.close());
```

### 2. `src/test/mocks/supabase.ts` (Supabase Mock)

```typescript
import { vi } from 'vitest';

export const mockSupabaseClient = {
  auth: {
    signUp: vi.fn(),
    signIn: vi.fn(),
    signOut: vi.fn(),
    resetPasswordForEmail: vi.fn(),
  },
  from: vi.fn(),
  functions: {
    invoke: vi.fn(),
  },
};
```

### 3. `src/test/mocks/handlers.ts` (API Handlers)

```typescript
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.get('*/rest/v1/sets', () => {
    return HttpResponse.json([
      { id: '1', name: 'Set 1', piece_count: 500 },
    ]);
  }),
];
```

### 4. `src/test/mocks/browser.ts` (MSW Browser Setup)

```typescript
import { setupServer } from 'msw/node';
import { handlers } from './handlers';

export const server = setupServer(...handlers);
```

## 🧪 Estructura de un Test

### Anatomía Básica

```typescript
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { render, screen } from '@testing-library/react';

describe('MyComponent', () => {
  beforeEach(() => {
    // Setup: Preparar estado inicial
    mockSupabaseClient.from.mockReturnValue({
      select: vi.fn().mockReturnValue({ data: [], error: null }),
    });
  });

  afterEach(() => {
    // Cleanup: Limpiar mocks
    vi.clearAllMocks();
  });

  it('should render component', () => {
    // Arrange: Preparar datos/componentes
    const { container } = render(<MyComponent />);

    // Act: Realizar acciones
    const button = screen.getByRole('button', { name: /click/i });
    button.click();

    // Assert: Verificar resultados
    expect(button).toHaveClass('active');
  });
});
```

## 🎣 Testing de Hooks

```typescript
import { renderHook, act } from '@testing-library/react';
import { useMyHook } from '@/hooks/useMyHook';

describe('useMyHook', () => {
  it('should update value on change', () => {
    const { result } = renderHook(() => useMyHook());

    act(() => {
      result.current.setValue('new value');
    });

    expect(result.current.value).toBe('new value');
  });
});
```

## 🎨 Testing de Componentes

```typescript
import { render, screen, fireEvent } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

describe('MyComponent', () => {
  it('should handle user interaction', async () => {
    const user = userEvent.setup();
    render(<MyComponent />);

    const button = screen.getByRole('button');
    await user.click(button);

    expect(screen.getByText('Clicked!')).toBeInTheDocument();
  });
});
```

## 📊 Queries Comunes de Testing Library

| Query | Uso |
|---|---|
| `getByRole(role, options)` | Obtener elemento por ARIA role |
| `getByLabelText(text)` | Obtener input por label |
| `getByPlaceholderText(text)` | Obtener input por placeholder |
| `getByText(text)` | Obtener elemento por texto |
| `getByTestId(id)` | Obtener elemento por data-testid |
| `queryBy*` | Retorna null si no encuentra (para verificar que NO existe) |
| `findBy*` | Async - espera a que aparezca el elemento |

## 🎯 Best Practices

### 1. Usa Fixtures para Datos

❌ **Malo - Duplicación**
```typescript
it('test 1', () => {
  const user = { id: '1', email: 'test@example.com', name: 'Test' };
  // ...
});

it('test 2', () => {
  const user = { id: '1', email: 'test@example.com', name: 'Test' };
  // ...
});
```

✅ **Bueno - Fixtures**
```typescript
// fixtures/users.ts
export const mockUser = { id: '1', email: 'test@example.com', name: 'Test' };

// test
it('test 1', () => {
  const user = mockUser;
  // ...
});
```

### 2. Mockea al Nivel Correcto

❌ **Malo - Mockea demasiado**
```typescript
vi.mock('@/hooks/useProducts');
const mockUseProducts = useProducts as vi.Mock;
mockUseProducts.mockReturnValue({ data: [] });
```

✅ **Bueno - Mockea APIs externas**
```typescript
server.use(
  http.get('*/rest/v1/sets', () => {
    return HttpResponse.json([]);
  })
);
```

### 3. Testing de Interacciones de Usuario

❌ **Malo - fireEvent**
```typescript
fireEvent.click(button);
```

✅ **Bueno - userEvent**
```typescript
const user = userEvent.setup();
await user.click(button);
```

### 4. Espera a Elementos Async

❌ **Malo - getBy con datos async**
```typescript
it('should load data', () => {
  render(<Component />);
  const text = screen.getByText('Data loaded'); // Falla si está en loading
});
```

✅ **Bueno - findBy espera**
```typescript
it('should load data', async () => {
  render(<Component />);
  const text = await screen.findByText('Data loaded');
  expect(text).toBeInTheDocument();
});
```

## 🚀 Ejecutar Tests

```bash
# Todos los tests
npm run test -w @brickshare/web

# Watch mode (rerun on change)
npm run test:watch -w @brickshare/web

# Coverage
npm run test:coverage -w @brickshare/web

# Un archivo específico
npm run test -w @brickshare/web -- useAuth.test.tsx

# Una carpeta
npm run test -w @brickshare/web -- hooks/

# Con UI
npm run test -w @brickshare/web -- --ui
```

## 📈 Coverage Reports

```bash
# Generar coverage
npm run test:coverage -w @brickshare/web

# Ver reporte HTML
open apps/web/coverage/index.html
```

## 🐛 Debugging

### Debug en VS Code

```json
{
  "type": "node",
  "request": "launch",
  "name": "Debug Tests",
  "runtimeExecutable": "npm",
  "runtimeArgs": ["run", "test:debug"],
  "cwd": "${workspaceFolder}/apps/web"
}
```

### Debug en Terminal

```bash
node --inspect-brk ./node_modules/vitest/vitest.mjs --no-file-parallelism
```

Luego abre `chrome://inspect` en Chrome.

## ✅ Checklist de Setup

- [x] Instalar dependencias
- [x] Configurar Vitest
- [x] Crear carpeta test/
- [x] Crear mocks de Supabase
- [x] Crear MSW handlers
- [x] Crear fixtures
- [x] Crear setup.ts
- [ ] Escribir primeros tests
- [ ] Verificar coverage
- [ ] Integrar en CI/CD

---

**Próximo Paso**: Leer [TEST_DATA_FIXTURES.md](./TEST_DATA_FIXTURES.md)