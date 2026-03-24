# 🚀 Quick Start - Testing en Brickshare

## ⚡ 30 segundos para empezar

```bash
# 1. Ir a la carpeta web
cd apps/web

# 2. Ejecutar todos los tests
npm run test

# 3. Ver resultados en vivo (watch mode)
npm run test:watch

# 4. Ver coverage
npm run test:coverage

# 5. Ver reporte HTML
open coverage/index.html
```

---

## 📋 Comandos Principales

### Ejecutar Tests

```bash
# Todos los tests
npm run test

# Tests en watch mode (rerun on file change)
npm run test:watch

# Tests con coverage report
npm run test:coverage

# Tests de un archivo específico
npm run test -- useAuth.test.tsx

# Tests de una carpeta
npm run test -- hooks/
npm run test -- components/
npm run test -- utils/

# Con interfaz UI
npm run test -- --ui
```

---

## 📊 Current Status

```
✅ 83 Tests Passing
✅ 0 Tests Failing
✅ ~7.64s Execution Time
✅ 70%+ Code Coverage
```

---

## 🗂️ Structure

```
apps/web/src/
├── __tests__/unit/
│   ├── hooks/           # 35 tests
│   ├── components/      # 28 tests
│   └── utils/           # 20 tests
└── test/
    ├── fixtures/        # Test data
    └── mocks/           # API mocks
```

---

## 🧪 What's Tested

### Hooks (35)
- `useAuth` - Authentication & roles
- `useProducts` - Product catalog
- `useShipments` - Order tracking
- `useWishlist` - Wishlist management

### Components (28)
- `ProfileCompletionModal` - User profile
- `DeleteAccountDialog` - Account deletion
- `ShipmentTimeline` - Delivery tracking

### Utils (20)
- `pudoService` - PUDO locations
- Formatting utilities
- Validation utilities

---

## 📖 Documentation

- **README.md** - Overview & strategy
- **PHASE_1_UNIT_TESTS.md** - Test specifications
- **TEST_SETUP_GUIDE.md** - Setup instructions
- **TEST_DATA_FIXTURES.md** - Test data guide
- **IMPLEMENTATION_SUMMARY.md** - Full summary
- **QUICK_START.md** - This file

---

## 🎯 Writing Tests

### Basic Structure

```typescript
import { describe, it, expect } from 'vitest';
import { mockData } from '@/test/fixtures/data';

describe('Feature', () => {
  describe('Functionality', () => {
    it('should do something', () => {
      // Arrange
      const input = mockData;

      // Act
      const result = doSomething(input);

      // Assert
      expect(result).toBe(expected);
    });
  });
});
```

### Using Fixtures

```typescript
import { mockUser } from '@/test/fixtures/users';
import { mockSet } from '@/test/fixtures/sets';

describe('Dashboard', () => {
  it('should display user sets', () => {
    const user = mockUser;
    const sets = [mockSet];
    
    // Test implementation
  });
});
```

### Testing Hooks

```typescript
import { renderHook } from '@testing-library/react';
import { useMyHook } from '@/hooks/useMyHook';

describe('useMyHook', () => {
  it('should update value', () => {
    const { result } = renderHook(() => useMyHook());
    
    expect(result.current.value).toBe(expected);
  });
});
```

---

## 🐛 Debugging

### See Detailed Output

```bash
npm run test -- --reporter=verbose
```

### Run Single Test

```bash
npm run test -- "useAuth.test.tsx"
```

### Debug in VS Code

1. Set breakpoint in test
2. Run: `npm run test:debug`
3. Open `chrome://inspect` in Chrome

---

## 💡 Tips

1. **Use Fixtures**: Don't repeat test data, use fixtures
2. **Mock Correctly**: Mock APIs, not internal logic
3. **Test Behavior**: Test what users see, not implementation
4. **Keep Tests Fast**: Unit tests should be ~<100ms each
5. **One Assertion**: Each test should verify one thing (or related things)

---

## ⚠️ Common Issues

### Tests Not Found
```bash
# Make sure files end with .test.ts or .test.tsx
# Location must match: src/**/*.test.{ts,tsx}
```

### Import Errors
```bash
# Check @/ alias is configured in vite.config.ts
# Restart dev server after changes
```

### Mock Not Working
```bash
# Make sure vi.mock() is at top level (not in describe)
# Clear mocks between tests: vi.clearAllMocks()
```

---

## 📈 Coverage Targets

| Category | Target | Current |
|---|---|---|
| Hooks | 90% | ✅ |
| Components | 75% | ✅ |
| Utils | 80% | ✅ |
| Overall | 60% | ✅ |

---

## 🔗 Links

- [Vitest Docs](https://vitest.dev/)
- [Testing Library](https://testing-library.com/)
- [MSW Docs](https://mswjs.io/)
- [Faker.js](https://fakerjs.dev/)

---

## 📞 Help

- Check `TEST_SETUP_GUIDE.md` for setup issues
- Check `TEST_DATA_FIXTURES.md` for fixture info
- Check `PHASE_1_UNIT_TESTS.md` for test specs

---

**Happy Testing! 🎉**