# 🗺️ Brickshare Route Reference for E2E Tests

## ⚠️ CRITICAL ARCHITECTURE NOTE

**Brickshare uses MODALS for authentication, NOT separate routes.**

```typescript
// ❌ WRONG - These routes DO NOT EXIST
await page.goto('/auth/signup');
await page.goto('/auth/signin');
await page.goto('/auth/login');

// ✅ CORRECT - Open modals from existing pages
await page.goto('/');
await openSignupModal(page);  // Helper function
```

## 📋 Actual Routes (from App.tsx)

### Public Routes
| Route | Component | Description | Auth Modal Available |
|-------|-----------|-------------|---------------------|
| `/` | Index | Home page (landing) | ✅ Yes |
| `/catalogo` | Catalogo | LEGO sets catalog | ✅ Yes |
| `/como-funciona` | ComoFunciona | How it works | ✅ Yes |
| `/sobre-nosotros` | SobreNosotros | About us | ✅ Yes |
| `/blog` | Blog | Blog posts | ✅ Yes |
| `/contacto` | Contacto | Contact form | ✅ Yes |
| `/donaciones` | Donaciones | Donations page | ✅ Yes |

### Legal Pages
| Route | Component | Description |
|-------|-----------|-------------|
| `/privacidad` | PrivacyPolicy | Privacy policy |
| `/terminos` | Terms | Terms of service |
| `/terminos-y-condiciones` | TerminosCondiciones | Terms & conditions |
| `/cookies` | PrivacyPolicy | Cookie policy |
| `/aviso-legal` | LegalNotice | Legal notice |

### Authenticated Routes
| Route | Component | Description | Auth Required |
|-------|-----------|-------------|---------------|
| `/dashboard` | Dashboard | User dashboard | Yes (user) |
| `/admin` | Admin | Admin backoffice | Yes (admin) |
| `/operaciones` | Operations | Operations panel | Yes (operator) |

### Special Routes
| Route | Component | Description |
|-------|-----------|-------------|
| `*` | NotFound | 404 page |

## 🎭 Modal-Based Features

### Authentication Modal
- **Trigger**: Buttons labeled "Registrarse", "Iniciar sesión", "Login", etc.
- **Location**: Available from any page via `AuthModal` component
- **Modes**: 
  - Signup/Register
  - Login/Signin
- **Component**: `<AuthModal />` (controlled by AuthContext)
- **State**: Global (managed by `isAuthModalOpen` in AuthContext)

### How to Test Modals in E2E

```typescript
import { 
  openSignupModal, 
  openLoginModal, 
  waitForAuthForm,
  fillSignupForm,
  fillLoginForm,
  submitAuthForm
} from '../helpers/modal-helpers';

test('signup flow', async ({ page }) => {
  // Always start from a real route
  await page.goto('/');
  
  // Use helpers to open modals
  await openSignupModal(page);
  await waitForAuthForm(page);
  
  // Fill and submit
  await fillSignupForm(page, 'test@example.com', 'Password123!');
  await submitAuthForm(page);
});
```

## 🎯 Testing Strategy

### 1. Always Verify Routes Exist
Before writing a test, check `apps/web/src/App.tsx` to confirm the route exists.

### 2. Use Modals for Auth
Never try to navigate to `/auth/*` routes - they don't exist. Always:
1. Navigate to a valid route (usually `/`)
2. Open the auth modal with helpers
3. Interact with the modal

### 3. Flexible Selectors
Use the helper functions which try multiple selectors, as button text may vary.

### 4. Generous Timeouts
Development servers can be slow. Use:
- `waitForLoadState('networkidle', { timeout: 30000 })`
- `waitForSelector(..., { timeout: 20000 })`

### 5. Check Real State
After auth operations, verify actual state:
```typescript
// Check URL changed
const url = page.url();
expect(url).toContain('/dashboard');

// Or check for authenticated content
const hasAuth = await page.locator('text=/Dashboard|Perfil/i').count() > 0;
expect(hasAuth).toBeTruthy();
```

## 📚 Helper Functions Reference

### Navigation Helpers
```typescript
// Opens signup modal from current page
await openSignupModal(page);

// Opens login modal from current page
await openLoginModal(page);

// Waits for auth form to be visible
await waitForAuthForm(page, timeout?);
```

### Form Helpers
```typescript
// Fills signup form
await fillSignupForm(page, email, password, acceptPolicy?);

// Fills login form
await fillLoginForm(page, email, password);

// Submits the auth form
await submitAuthForm(page);
```

### Modal Switching
```typescript
// Switch from signup to login
await switchToLogin(page);

// Switch from login to signup
await switchToSignup(page);

// Close any modal
await closeModal(page);
```

## ⚠️ Common Pitfalls

### ❌ DON'T: Navigate to non-existent auth routes
```typescript
await page.goto('/auth/signup'); // 404 or loads wrong page
await page.goto('/login');        // 404 or loads wrong page
```

### ✅ DO: Use existing routes + modals
```typescript
await page.goto('/');
await openSignupModal(page);
```

### ❌ DON'T: Assume auth happens on separate pages
```typescript
expect(page.url()).toContain('/auth'); // Will fail
```

### ✅ DO: Check for auth state, not URL
```typescript
const isAuth = await page.locator('[data-authenticated]').count() > 0;
expect(isAuth).toBeTruthy();
```

### ❌ DON'T: Use hardcoded selectors
```typescript
await page.click('button.signup-btn'); // May change
```

### ✅ DO: Use helper functions with fallbacks
```typescript
await openSignupModal(page); // Tries multiple selectors
```

## 🔍 Debugging Tips

### View Available Buttons
```typescript
const buttons = await page.locator('button, a').evaluateAll(els => 
  els.map(el => el.textContent?.trim())
);
console.log('Available buttons:', buttons);
```

### Check Current State
```typescript
console.log('URL:', page.url());
console.log('Title:', await page.title());

const modalVisible = await page.locator('[role="dialog"]').isVisible();
console.log('Modal open:', modalVisible);
```

### Screenshot on Failure
```typescript
await page.screenshot({ path: 'debug.png', fullPage: true });
```

## 📝 Example Test Templates

### User Signup
```typescript
test('user signup', async ({ page }) => {
  await page.goto('/');
  await openSignupModal(page);
  await waitForAuthForm(page);
  await fillSignupForm(page, email, password);
  await submitAuthForm(page);
  // Verify auth state
});
```

### User Login
```typescript
test('user login', async ({ page }) => {
  await page.goto('/');
  await openLoginModal(page);
  await waitForAuthForm(page);
  await fillLoginForm(page, email, password);
  await submitAuthForm(page);
  // Verify auth state
});
```

### Protected Route Access
```typescript
test('access dashboard', async ({ page }) => {
  // First login
  await page.goto('/');
  await openLoginModal(page);
  // ... auth flow ...
  
  // Then access protected route
  await page.goto('/dashboard');
  await expect(page).toHaveURL(/dashboard/);
});
```

## 🎓 Key Lessons

1. **Architecture First**: Always understand the app architecture before writing tests
2. **Router is Truth**: Check `App.tsx` routes - they are the source of truth
3. **Modals Need Strategy**: Modal-based UI requires different testing approach
4. **Flexible Selectors**: Use helpers with multiple fallback selectors
5. **Generous Timeouts**: Development environments need patience

---

**Last Updated**: Based on `apps/web/src/App.tsx` analysis  
**Maintained By**: E2E Test Suite  
**Related Files**:
- `apps/web/e2e/helpers/modal-helpers.ts`
- `apps/web/src/App.tsx`
- `apps/web/src/contexts/AuthContext.tsx`