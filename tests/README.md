# 🧪 Testing Strategy for Brickshare

Brickshare cuenta con una estrategia de testing integral que cubre los principales flujos de usuario y administrador. Este documento sirve como índice general de la estrategia de testing.

## 📊 Pirámide de Testing

```
                    /\
                   /  \  E2E Tests (5-10%)
                  /____\
                 /      \  Integration Tests (20-30%)
                /________\
               /          \  Unit Tests (60-70%)
              /____________\
```

**Distribución:**
- **Unit Tests (60-70%)**: Hooks, utilidades, componentes aislados
- **Integration Tests (20-30%)**: Flujos completos con API mockeda (Fase 2)
- **E2E Tests (5-10%)**: Flujos críticos de negocio (Fase 3)

## 🗂️ Estructura de Carpetas

```
tests/
├── README.md                           # Este archivo
├── PHASE_1_UNIT_TESTS.md              # Specs de tests unitarios
├── TEST_SETUP_GUIDE.md                # Guía de configuración
├── TEST_DATA_FIXTURES.md              # Documentación de fixtures

apps/web/src/
├── test/
│   ├── setup.ts                       # Setup de Vitest (Ya existe)
│   ├── mocks/
│   │   ├── supabase.ts               # Mock del cliente Supabase
│   │   ├── handlers.ts               # MSW handlers
│   │   └── browser.ts                # MSW browser setup
│   └── fixtures/
│       ├── users.ts                  # Datos de usuarios
│       ├── sets.ts                   # Datos de sets
│       └── shipments.ts              # Datos de envíos
└── __tests__/
    ├── unit/
    │   ├── hooks/
    │   │   ├── useAuth.test.tsx
    │   │   ├── useProducts.test.tsx
    │   │   ├── useShipments.test.tsx
    │   │   └── useWishlist.test.tsx
    │   ├── components/
    │   │   ├── ProfileCompletionModal.test.tsx
    │   │   ├── DeleteAccountDialog.test.tsx
    │   │   └── ShipmentTimeline.test.tsx
    │   └── utils/
    │       └── pudoService.test.ts
    └── integration/
        └── (Fase 2 - Pendiente)
```

## 🚀 Comandos de Testing

```bash
# Ejecutar todos los tests
npm run test -w @brickshare/web

# Ejecutar tests en modo watch (desarrollo)
npm run test:watch -w @brickshare/web

# Ejecutar tests con coverage
npm run test:coverage -w @brickshare/web

# Ejecutar tests de un archivo específico
npm run test -w @brickshare/web -- useAuth

# Ejecutar tests de una carpeta
npm run test -w @brickshare/web -- hooks/
npm run test -w @brickshare/web -- components/

# Ver reporte de coverage en HTML
open apps/web/coverage/index.html
```

## 📝 Stack de Testing

| Herramienta | Uso |
|---|---|
| **Vitest** | Test runner (configurado en vitest.config.ts) |
| **Testing Library** | Renderizado y queries de componentes |
| **MSW** (Mock Service Worker) | Mocking de APIs (Supabase) |
| **@faker-js/faker** | Generación de datos de prueba |
| **vitest-mock-extended** | Extensiones de mocks |

## 📚 Documentación Detallada

- **[PHASE_1_UNIT_TESTS.md](./PHASE_1_UNIT_TESTS.md)** - Especificación de todos los tests unitarios (Fase 1)
- **[TEST_SETUP_GUIDE.md](./TEST_SETUP_GUIDE.md)** - Guía paso a paso de configuración
- **[TEST_DATA_FIXTURES.md](./TEST_DATA_FIXTURES.md)** - Documentación de fixtures y datos de prueba

## 🎯 Cobertura de Tests

### Fase 1: Unit Tests (Implementado ✅)
- **~50 tests unitarios** de hooks críticos, componentes y utilidades
- Coverage objetivo: **70%+** en funciones críticas
- Status: ✅ Implementado

### Fase 2: Integration Tests (Pendiente)
- **~30 tests de integración** de flujos de usuario
- **~20 tests de integración** de flujos de admin
- Coverage objetivo: **60%+**
- Status: ⏳ Pendiente

### Fase 3: E2E Tests (Pendiente)
- **5-10 tests E2E** con Playwright
- Flujos críticos de negocio
- Status: ⏳ Pendiente

## 🔄 Convenciones

### Naming de Tests
```typescript
describe('useAuth', () => {
  describe('signUp', () => {
    it('should create a new user with email and password', () => {
      // Test implementation
    });
  });
});
```

### Estructura de Tests
```typescript
describe('Component/Hook Name', () => {
  beforeEach(() => {
    // Setup
  });

  afterEach(() => {
    // Cleanup
  });

  it('should do something', () => {
    // Arrange
    const data = {...};

    // Act
    const result = action(data);

    // Assert
    expect(result).toBe(expectedValue);
  });
});
```

## 🔧 Cómo Ejecutar Tests Localmente

### Prerequisitos
```bash
# Asegúrate de estar en la carpeta apps/web
cd apps/web

# Instala dependencias (ya hecho)
npm install
```

### Ejecutar
```bash
# Todos los tests
npm run test

# Watch mode (rerun on file change)
npm run test:watch

# Con coverage
npm run test:coverage
```

## 📊 Métricas de Cobertura

Los tests están configurados para generar reportes de coverage:

```bash
# Ver reporte en la terminal
npm run test:coverage

# Ver reporte HTML interactivo
open apps/web/coverage/index.html
```

**Objetivos de Coverage:**

| Capa | Target |
|---|---|
| **Hooks críticos** | 90%+ |
| **Componentes UI** | 70%+ |
| **Utilidades** | 80%+ |
| **Global** | 60%+ |

## 🐛 Debugging Tests

```bash
# Run tests with verbose output
npm run test -- --reporter=verbose

# Debug mode
node --inspect-brk ./node_modules/vitest/vitest.mjs --no-file-parallelism

# Run a single test file
npm run test -- useAuth.test.tsx
```

## 📖 Recursos Adicionales

- [Vitest Documentation](https://vitest.dev/)
- [React Testing Library](https://testing-library.com/react)
- [MSW (Mock Service Worker)](https://mswjs.io/)
- [Faker.js](https://fakerjs.dev/)

## ✅ Checklist de Implementación

- [x] Instalar dependencias
- [x] Configurar Vitest
- [x] Crear mocks de Supabase
- [x] Crear fixtures de datos
- [x] Implementar tests de hooks
- [x] Implementar tests de componentes
- [x] Implementar tests de utilidades
- [ ] Fase 2: Integration tests
- [ ] Fase 3: E2E tests
- [ ] CI/CD: GitHub Actions

## 🤝 Contribuir Nuevos Tests

Cuando añadas nuevos tests:

1. Crea el archivo `.test.tsx` o `.test.ts` en la ubicación correspondiente
2. Sigue la estructura de naming: `ComponentName.test.tsx`
3. Agrupa tests con `describe()` blocks
4. Usa fixtures para datos comunes
5. Mockea Supabase automáticamente
6. Ejecuta `npm run test` para verificar
7. Asegúrate de que coverage no baja

---

**Última actualización**: 23/03/2026
**Responsable**: Development Team