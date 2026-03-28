# 📋 Fase 1: Unit Tests Specification

## Overview

**Fase 1** implementa ~50 tests unitarios para validar la lógica core del sistema sin dependencias de red.

| Categoría | Tests | Estado |
|---|---|---|
| **Hooks** | ~25 tests | ✅ Implementado |
| **Componentes** | ~15 tests | ✅ Implementado |
| **Utilidades** | ~10 tests | ✅ Implementado |
| **Total Fase 1** | **~50 tests** | **✅ Implementado** |

---

## 🎣 Hooks Tests (~25 tests)

### 1. useAuth Hook (10 tests)

**Archivo**: `apps/web/src/__tests__/unit/hooks/useAuth.test.tsx`

#### Test Specifications

| # | Test Case | Descripción | Entrada | Salida Esperada |
|---|---|---|---|---|
| 1 | should initialize with null user | Verifica que inicialmente no hay usuario | N/A | user: null, session: null, isLoading: true |
| 2 | should set user after login | Usuario se carga tras login exitoso | credentials válidas | user: User, session: Session |
| 3 | should handle signup errors | Error al registrar | email duplicado | error: "User already registered" |
| 4 | should clear session on logout | Limpia datos tras logout | usuario autenticado | user: null, session: null |
| 5 | should verify admin role | Identifica admin correctamente | user con rol admin | isAdmin: true |
| 6 | should verify operador role | Identifica operador correctamente | user con rol operador | isOperador: true |
| 7 | should refresh profile | Recarga perfil del usuario | user autenticado | profile actualizado |
| 8 | should handle password reset | Inicia reset de contraseña | email válido | email de reset enviado |
| 9 | should update user password | Cambia contraseña | password nueva | success: true |
| 10 | should delete user account | Elimina cuenta de usuario | confirmación | user eliminado |

#### Ejemplo de Test

```typescript
describe('useAuth', () => {
  it('should initialize with null user', () => {
    const { result } = renderHook(() => useAuth(), {
      wrapper: AuthProvider,
    });

    expect(result.current.user).toBeNull();
    expect(result.current.session).toBeNull();
    expect(result.current.isLoading).toBe(true);
  });
});
```

---

### 2. useProducts Hook (5 tests)

**Archivo**: `apps/web/src/__tests__/unit/hooks/useProducts.test.tsx`

| # | Test Case | Descripción | Entrada | Salida Esperada |
|---|---|---|---|---|
| 11 | should fetch products list | Obtiene catálogo de sets | N/A | products array con 10+ items |
| 12 | should filter products by theme | Filtra por tema | theme: "Star Wars" | solo sets de tema especificado |
| 13 | should filter by piece range | Filtra por rango de piezas | min: 500, max: 2000 | sets en rango |
| 14 | should search products by name | Busca por nombre | query: "Death Star" | resultado de búsqueda |
| 15 | should handle loading state | Maneja estado de carga | N/A | isLoading pasa true → false |

---

### 3. useShipments Hook (5 tests)

**Archivo**: `apps/web/src/__tests__/unit/hooks/useShipments.test.tsx`

| # | Test Case | Descripción | Entrada | Salida Esperada |
|---|---|---|---|---|
| 16 | should fetch user shipments | Obtiene envíos del usuario | user_id válido | shipments array |
| 17 | should track shipment status | Sigue estado de envío | shipment_id | status actualizado |
| 18 | should request return shipment | Solicita devolución | shipment_id, set_id | retorno creado |
| 19 | should validate QR code | Valida QR de entrega/devolución | qr_code válido | success: true |
| 20 | should handle shipment errors | Maneja errores | shipment_id inválido | error message |

---

### 4. useWishlist Hook (5 tests)

**Archivo**: `apps/web/src/__tests__/unit/hooks/useWishlist.test.tsx`

| # | Test Case | Descripción | Entrada | Salida Esperada |
|---|---|---|---|---|
| 21 | should fetch user wishlist | Obtiene lista de deseos | user_id válido | wishlist items |
| 22 | should add item to wishlist | Añade set a wishlist | set_id, user_id | item añadido |
| 23 | should remove item from wishlist | Elimina set de wishlist | wishlist_item_id | item eliminado |
| 24 | should reorder wishlist items | Reordena items (drag & drop) | new order array | items reordenados |
| 25 | should respect plan limits | Respeta límite según plan | plan: "basic" (1 set max) | error si supera límite |

---

## 🎨 Components Tests (~15 tests)

### 5. ProfileCompletionModal Component (5 tests)

**Archivo**: `apps/web/src/__tests__/unit/components/ProfileCompletionModal.test.tsx`

| # | Test Case | Descripción | Entrada | Salida Esperada |
|---|---|---|---|---|
| 26 | should show modal for incomplete profile | Modal visible para perfil incompleto | profile.profile_completed: false | modal renderizada |
| 27 | should validate required fields | Valida campos obligatorios | submit sin llenar | error message por campo |
| 28 | should update profile on submit | Actualiza perfil al enviar | form data válida | onSuccess llamado |
| 29 | should disable submit button while saving | Desabilita botón durante guardado | isLoading: true | button disabled |
| 30 | should close modal on success | Cierra modal tras éxito | submit exitoso | modal cerrada |

---

### 6. DeleteAccountDialog Component (3 tests)

**Archivo**: `apps/web/src/__tests__/unit/components/DeleteAccountDialog.test.tsx`

| # | Test Case | Descripción | Entrada | Salida Esperada |
|---|---|---|---|---|
| 31 | should show confirmation dialog | Dialog visible | open: true | confirmation message |
| 32 | should require password confirmation | Valida contraseña | password vacío | error |
| 33 | should delete account on confirm | Elimina cuenta | password correcto | onConfirm llamado |

---

### 7. ShipmentTimeline Component (4 tests)

**Archivo**: `apps/web/src/__tests__/unit/components/ShipmentTimeline.test.tsx`

| # | Test Case | Descripción | Entrada | Salida Esperada |
|---|---|---|---|---|
| 34 | should render timeline steps | Renderiza timeline | shipment object | 4+ pasos visibles |
| 35 | should mark completed steps | Marca pasos completados | status: "entregado" | checkmark en entregado |
| 36 | should show current step highlight | Destaca paso actual | status: "en_transito" | highlight en en_transito |
| 37 | should display estimated dates | Muestra fechas estimadas | dates object | fechas formateadas |

---

## 🛠️ Utils Tests (~10 tests)

### 8. pudoService Utility (5 tests)

**Archivo**: `apps/web/src/__tests__/unit/utils/pudoService.test.ts`

| # | Test Case | Descripción | Entrada | Salida Esperada |
|---|---|---|---|---|
| 38 | should fetch PUDO points | Obtiene puntos PUDO | postal_code | array de PUDOs |
| 39 | should filter PUDO by postal code | Filtra por código postal | postal_code: "28001" | PUDOs en Madrid |
| 40 | should calculate distance to PUDO | Calcula distancia | coords, pudo_coords | distancia en km |
| 41 | should sort PUDO by distance | Ordena por proximidad | array de PUDOs | ordenado ascendente |
| 42 | should handle PUDO API errors | Maneja errores API | API falla | error message |

---

### 9. Date/Format Utilities (3 tests)

**Archivo**: `apps/web/src/__tests__/unit/utils/formatting.test.ts`

| # | Test Case | Descripción | Entrada | Salida Esperada |
|---|---|---|---|---|
| 43 | should format date as DD/MM/YYYY | Formatea fecha | Date object | "23/03/2026" |
| 44 | should format currency as EUR | Formatea moneda | 29.99 | "29,99 €" |
| 45 | should format shipment status | Formatea estado de envío | "en_transito" | "En tránsito" |

---

### 10. Validation Utilities (2 tests)

**Archivo**: `apps/web/src/__tests__/unit/utils/validation.test.ts`

| # | Test Case | Descripción | Entrada | Salida Esperada |
|---|---|---|---|---|
| 46 | should validate email format | Valida email | "test@example.com" | true |
| 47 | should validate phone number | Valida teléfono | "+34 612 345 678" | true |

---

## 📊 Summary

| Categoría | Tests | Líneas | Tiempo Ejecución |
|---|---|---|---|
| **Hooks** | 25 | ~1200 | ~2s |
| **Componentes** | 15 | ~800 | ~1.5s |
| **Utilidades** | 10 | ~500 | ~0.5s |
| **Total Fase 1** | **50** | **~2500** | **~4s** |

## ✅ Ejecución

```bash
# Ejecutar todos los tests de Fase 1
npm run test -w @brickshare/web

# Con coverage
npm run test:coverage -w @brickshare/web
```

## 📈 Cobertura Esperada

- **Hooks**: 85%+ coverage
- **Componentes**: 75%+ coverage
- **Utilidades**: 90%+ coverage
- **Global**: 70%+ coverage

---

**Próxima Fase**: [PHASE 2 - Integration Tests]