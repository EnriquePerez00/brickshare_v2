# 🔗 Integration Tests - Fase 2

Este directorio contiene tests de integración que validan flujos completos del usuario y administrador.

## Estructura

```
integration/
├── user-flows/
│   ├── authentication.integration.test.ts
│   ├── subscription.integration.test.ts
│   ├── set-assignment.integration.test.ts
│   ├── wishlist.integration.test.ts
│   └── account.integration.test.ts
│
├── admin-flows/
│   ├── dashboard.integration.test.ts
│   ├── user-management.integration.test.ts
│   ├── inventory.integration.test.ts
│   ├── shipments.integration.test.ts
│   └── analytics.integration.test.ts
│
└── operator-flows/
    ├── qr-scanning.integration.test.ts
    ├── maintenance.integration.test.ts
    └── operations-log.integration.test.ts
```

## Ejemplo de Test

```typescript
// authentication.integration.test.ts
import { describe, it, expect } from 'vitest';
import { setupTestUser, cleanupTestUser } from '@/test/helpers';

describe('Authentication Flow - Integration', () => {
  describe('Complete signup flow', () => {
    it('should complete signup and profile setup', async () => {
      // 1. Signup
      const user = await signUp({
        email: 'test@example.com',
        password: 'password123',
        fullName: 'Test User',
      });

      // 2. Verify email
      await verifyEmail(user.email);

      // 3. Complete profile
      await completeProfile(user.id, {
        phone: '+34612345678',
        address: 'Calle Principal 123',
        zip_code: '28001',
        city: 'Madrid',
      });

      // 4. Select PUDO
      await selectPUDO(user.id, 'pudo-1');

      // Assertions
      expect(user).toBeDefined();
      expect(user.email_verified).toBe(true);
      expect(user.profile_completed).toBe(true);
      expect(user.pudo_point_id).toBe('pudo-1');
    });
  });
});
```

## Cómo Escribir Integration Tests

1. **Setup**: Crear datos de prueba necesarios
2. **Action**: Ejecutar flujo completo
3. **Assert**: Verificar resultados en todo el sistema
4. **Cleanup**: Limpiar datos de prueba

## Ejecutar Tests

```bash
# Todos los integration tests
npm run test -- integration/

# Tests específicos
npm run test -- user-flows/authentication

# Watch mode
npm run test:watch -- integration/
```

## Coverage Target

- User flows: 80%+
- Admin flows: 75%+
- Operator flows: 85%+

---

**Status**: ⏳ Pendiente de implementación