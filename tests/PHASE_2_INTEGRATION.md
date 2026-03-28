# 📋 Fase 2: Integration Tests Specification

## Overview

**Fase 2** implementa ~50 tests de integración que validan flujos completos del usuario y administrador con datos dinámicos y APIs mockeadas.

| Categoría | Tests | Estado |
|---|---|---|
| **Flujos de Usuario** | ~25 tests | ⏳ Pendiente |
| **Flujos de Admin** | ~20 tests | ⏳ Pendiente |
| **Flujos de Operador** | ~5 tests | ⏳ Pendiente |
| **Total Fase 2** | **~50 tests** | **⏳ Pendiente** |

---

## 🎯 User Flow Tests (~25 tests)

### 1. Authentication Flow (5 tests)

| # | Test Case | Descripción | Entrada | Salida Esperada |
|---|---|---|---|---|
| 1 | should complete signup flow | Signup + email verification | email, password | user creado, profile iniciado |
| 2 | should complete signin flow | Login + sesión | credentials | usuario autenticado, session activa |
| 3 | should handle signin error | Error en login | credentials inválidas | error message |
| 4 | should complete profile setup | Llenar perfil incompleto | profile data | profile_completed: true |
| 5 | should remember PUDO selection | Guardar PUDO del usuario | pudo location | user.pudo_point_id guardado |

### 2. Subscription Flow (5 tests)

| # | Test Case | Descripción | Entrada | Salida Esperada |
|---|---|---|---|---|
| 6 | should select basic plan | Seleccionar plan | plan: basic | checkout session creado |
| 7 | should select standard plan | Seleccionar plan | plan: standard | checkout session creado |
| 8 | should select premium plan | Seleccionar plan | plan: premium | checkout session creado |
| 9 | should complete stripe checkout | Pago exitoso | stripe token | subscription activa |
| 10 | should handle payment error | Falla en pago | invalid card | error message |

### 3. Set Assignment & Delivery Flow (5 tests)

| # | Test Case | Descripción | Entrada | Salida Esperada |
|---|---|---|---|---|
| 11 | should receive first set | Set asignado y enviado | user con subscription | shipment creado, QR generado |
| 12 | should receive set at PUDO | Recoger set en punto | QR de entrega | shipment.status = "entregado" |
| 13 | should confirm set receipt | Confirmar recepción | QR escaneado | user.sets = [set] |
| 14 | should request set return | Solicitar devolución | set en uso | return_shipment creado |
| 15 | should return set at PUDO | Devolver set en punto | QR de devolución | shipment.status = "devuelto" |

### 4. Wishlist & Browse Flow (5 tests)

| # | Test Case | Descripción | Entrada | Salida Esperada |
|---|---|---|---|---|
| 16 | should browse catalog | Ver catálogo completo | N/A | products listado |
| 17 | should filter by theme | Filtrar por tema | theme: "Star Wars" | solo sets de tema |
| 18 | should search by name | Buscar sets | query: "Falcon" | resultados encontrados |
| 19 | should add to wishlist | Agregar a favoritos | set_id | wishlist_item creado |
| 20 | should reorder wishlist | Cambiar prioridades | new order | wishlist reordenado |

### 5. Account Management Flow (5 tests)

| # | Test Case | Descripción | Entrada | Salida Esperada |
|---|---|---|---|---|
| 21 | should update profile | Editar perfil | profile data | profile actualizado |
| 22 | should change password | Cambiar contraseña | old pass, new pass | password actualizado |
| 23 | should request password reset | Reset de contraseña | email | reset email enviado |
| 24 | should manage subscriptions | Ver/cambiar suscripción | plan change | subscription actualizada |
| 25 | should delete account | Eliminación de cuenta | password confirmation | usuario eliminado |

---

## 🛠️ Admin Flow Tests (~20 tests)

### 6. Dashboard Overview (3 tests)

| # | Test Case | Descripción | Entrada | Salida Esperada |
|---|---|---|---|---|
| 26 | should load admin dashboard | Acceso a panel admin | admin login | dashboard con datos |
| 27 | should display user metrics | Mostrar estadísticas | N/A | users count, revenue, etc. |
| 28 | should display inventory status | Mostrar inventario | N/A | sets por estado |

### 7. User Management (4 tests)

| # | Test Case | Descripción | Entrada | Salida Esperada |
|---|---|---|---|---|
| 29 | should list all users | Listar usuarios | N/A | users array |
| 30 | should search users | Buscar usuario | email/name | usuarios filtrados |
| 31 | should view user details | Ver perfil usuario | user_id | datos completos |
| 32 | should manage user roles | Cambiar roles | user_id, role | role actualizado |

### 8. Set & Inventory Management (5 tests)

| # | Test Case | Descripción | Entrada | Salida Esperada |
|---|---|---|---|---|
| 33 | should add new set | Agregar set al catálogo | set data | set creado |
| 34 | should edit set details | Modificar set | set_id, data | set actualizado |
| 35 | should manage inventory | Ver/editar stock | set_id | inventory actualizado |
| 36 | should flag damaged sets | Marcar set en reparación | set_id | status: "en_reparacion" |
| 37 | should create purchase order | Agregar piezas faltantes | piece data | compra registrada |

### 9. Shipment Operations (5 tests)

| # | Test Case | Descripción | Entrada | Salida Esperada |
|---|---|---|---|---|
| 38 | should preview assignments | Ver propuesta de asignación | N/A | preview con usuarios |
| 39 | should confirm assignments | Confirmar asignación de sets | user_ids | shipments creados |
| 40 | should track shipments | Ver estado de envíos | N/A | shipments con tracking |
| 41 | should manage returns | Procesar devoluciones | return_shipment_id | devolución procesada |
| 42 | should update PUDO locations | Actualizar puntos PUDO | location data | PUDO actualizado |

### 10. Reporting & Analytics (3 tests)

| # | Test Case | Descripción | Entrada | Salida Esperada |
|---|---|---|---|---|
| 43 | should generate usage report | Reporte de uso | date range | CSV/PDF generado |
| 44 | should export user data | Exportar datos usuario | format | data exportada |
| 45 | should view analytics dashboard | Analytics completo | N/A | gráficos y metrics |

---

## 🎛️ Operator Flow Tests (~5 tests)

### 11. Logistic Operations (5 tests)

| # | Test Case | Descripción | Entrada | Salida Esperada |
|---|---|---|---|---|
| 46 | should scan QR delivery | Escanear QR entrega | qr_code | set marcado entregado |
| 47 | should scan QR return | Escanear QR devolución | qr_code | set marcado devuelto |
| 48 | should mark set maintenance | Marcar mantenimiento | set_id | status: "en_mantenimiento" |
| 49 | should complete maintenance | Finalizar reparación | set_id | status: "active" |
| 50 | should log operations | Registrar operación | operation data | log creado |

---

## 📊 Summary

| Categoría | Tests | Líneas | Tiempo |
|---|---|---|---|
| **User Flows** | 25 | ~1500 | ~3s |
| **Admin Flows** | 20 | ~1200 | ~2.5s |
| **Operator Flows** | 5 | ~300 | ~0.5s |
| **Total Fase 2** | **50** | **~3000** | **~6s** |

---

## 🔧 Technical Requirements

### Setup
- Mantener fixtures de Fase 1
- Agregar nuevas fixtures dinámicas
- Usar MSW para APIs completas
- Tests independientes

### Coverage Target
- User flows: 80%+
- Admin flows: 75%+
- Operator flows: 85%+
- Global: 70%+

---

## ✅ Implementation Steps

1. Crear fixtures adicionales para Fase 2
2. Crear MSW handlers completos
3. Implementar tests de user flows
4. Implementar tests de admin flows
5. Implementar tests de operator flows
6. Validar coverage
7. Documentar nuevos patrones

---

**Próxima Fase**: [PHASE 3 - E2E Tests]