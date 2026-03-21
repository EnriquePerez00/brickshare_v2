# Brickshare – App iOS (Expo)

App móvil iOS del monorepo Brickshare. Comparte backend (Supabase) con la web.

## Requisitos

- Node 18+
- Expo Go (en dispositivo/simulador) o Xcode para builds nativos

## Configuración

1. En la raíz del monorepo: `npm install`
2. Crear `apps/ios/.env` con (mismos valores que la web):

   ```
   EXPO_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
   EXPO_PUBLIC_SUPABASE_ANON_KEY=eyJ...
   ```

3. Opcional: compilar tipos compartidos: `npm run build -w @brickshare/shared`

## Desarrollar

Desde la raíz:

```bash
npm run ios
```

O desde esta carpeta:

```bash
cd apps/ios && npx expo start
```

Luego escanear QR con Expo Go o pulsar `i` para simulador iOS.

## Estructura

- `App.tsx` – raíz, AuthProvider + QueryClient + navegación condicional (invitado / logueado)
- `contexts/AuthContext.tsx` – sesión Supabase, perfil, roles
- `hooks/` – useSets, useWishlist, useOrders, useReturnSet, usePudo, useDonation
- `lib/supabase.ts` – cliente Supabase (mismo proyecto que la web)
- `navigation/` – GuestNavigator (Home, Auth, Catalog, Dashboard), AppNavigator (MainTabs + Donaciones), MainTabs (Catálogo, Mi área, Perfil)
- `screens/` – Home, Auth, Catalog, Dashboard (invitado), CatalogTab, DashboardTab (wishlist, envíos, PUDO, impacto), ProfileTab, Donaciones
- Tipos en `@brickshare/shared`

## Flujo

- **Sin sesión**: pantalla Home → Iniciar sesión / Ver catálogo / Mi área. Auth (login, registro, recuperar contraseña). Catalog con datos reales y wishlist (pide login). Dashboard invitado con CTA a login.
- **Con sesión**: 3 tabs (Catálogo, Mi área, Perfil). Mi área: wishlist, envíos con solicitar devolución, PUDO, puntos de impacto. Perfil: datos, Donar sets, Cerrar sesión, Eliminar cuenta. Donaciones: formulario y Edge Function submit-donation.
