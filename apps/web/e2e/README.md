# Brickshare E2E Tests (Phase 3)

End-to-End tests using Playwright for critical user, admin, and operator journeys.

## Overview

This directory contains E2E tests that validate complete business flows from the user's perspective, simulating real browser interactions.

```
Testing Pyramid:
        /\
       /E2E\        5-10% - Critical Journeys ← You are here
      /______\
     /         \
    /Integration\ 30% - Business Flows (Phase 2)
   /___________\
  /             \
 /    Unit       \ 65% - Components & Hooks (Phase 1)
/______________\
```

## Directory Structure

```
e2e/
├── fixtures/
│   └── test-data.ts               # Reusable test data and helpers
│
├── user-journeys/
│   ├── complete-onboarding.spec.ts  # Signup, verification, profile setup
│   ├── subscription-flow.spec.ts    # Plan selection and payment
│   └── set-rental-cycle.spec.ts     # Browse, request, receive, return
│
├── admin-journeys/
│   ├── assignment-operations.spec.ts # Assignment preview and confirmation
│   └── user-management.spec.ts       # User listing, search, role management
│
├── operator-journeys/
│   └── logistics-operations.spec.ts  # QR scanning, maintenance, logging
│
├── playwright.config.ts            # Playwright configuration
└── README.md                        # This file
```

## Test Coverage

### User Journeys (3 tests)

#### 1. Complete Onboarding
```
Signup → Email Verification → Profile Setup → PUDO Selection
```
- ✅ Complete signup flow
- ✅ Email verification validation
- ✅ Profile completion
- ✅ PUDO location selection
- ✅ Login after signup

#### 2. Subscription Flow
```
Plan Selection → Stripe Payment → Confirmation → Renewal Details
```
- ✅ Display subscription plans
- ✅ Plan selection
- ✅ Stripe payment integration
- ✅ Subscription confirmation
- ✅ Plan upgrade/downgrade
- ✅ Renewal date display

#### 3. Set Rental Cycle
```
Catalog Browse → Wishlist → Request → Receive → Use → Return → New Assignment
```
- ✅ Browse and search catalog
- ✅ Filter by theme and piece count
- ✅ Add to wishlist
- ✅ Request set assignment
- ✅ Track shipment
- ✅ Confirm receipt (QR)
- ✅ View active collection
- ✅ Request return
- ✅ Generate return QR
- ✅ Automatic new assignment

### Admin Journeys (2 tests)

#### 1. Assignment Operations
```
Dashboard → Generate Preview → Confirm → Shipments → Returns
```
- ✅ Admin dashboard
- ✅ Generate assignment preview
- ✅ Review and modify preview
- ✅ Confirm assignment and create shipments
- ✅ View active shipments
- ✅ Manage returns

#### 2. User Management
```
Users List → Search → Details → Roles → Activity → Deactivate
```
- ✅ List and search users
- ✅ View user details
- ✅ Filter by subscription status
- ✅ Assign admin roles
- ✅ Deactivate accounts
- ✅ View activity history

### Operator Journeys (1 test)

#### Logistics Operations
```
QR Scanner → Delivery → Return → Maintenance → Logs → Export
```
- ✅ Access operator dashboard
- ✅ Scan delivery QR
- ✅ Mark as delivered
- ✅ Scan return QR
- ✅ Mark as returned
- ✅ Report maintenance issues
- ✅ Complete maintenance
- ✅ View operation logs
- ✅ Export logs as CSV

## Installation

### Prerequisites
- Node.js 16+
- npm or yarn
- Running Brickshare dev server

### Setup

1. **Install Playwright** (already done in package.json)
```bash
npm install --save-dev @playwright/test
```

2. **Install Chromium, Firefox, and WebKit**
```bash
npx playwright install
```

3. **Verify setup**
```bash
npx playwright --version
```

## Running Tests

### Run all E2E tests
```bash
npm run test:e2e
```

### Run specific test file
```bash
npx playwright test user-journeys/complete-onboarding.spec.ts
```

### Run with UI (recommended for debugging)
```bash
npx playwright test --ui
```

### Run in headed mode (see browser)
```bash
npx playwright test --headed
```

### Run specific browser
```bash
npx playwright test --project=chromium
npx playwright test --project=firefox
npx playwright test --project=webkit
```

### Watch mode (for development)
```bash
npx playwright test --watch
```

### Debug mode
```bash
npx playwright test --debug
```

## Configuration

The configuration is in `playwright.config.ts`:

```typescript
- baseURL: http://localhost:5173
- timeout: 30 seconds per test
- retries: 2 on CI, 0 locally
- workers: 1 (sequential to avoid DB conflicts)
- screenshots: on failure only
- videos: retain on failure
- projects: Chromium, Firefox, WebKit
```

## Test Data

Test data is managed in `fixtures/test-data.ts`:

```typescript
// Users
testUsers.regularUser
testUsers.adminUser
testUsers.operatorUser

// Sets
testSets.starWars
testSets.cityPoliceStation
testSets.harryPotterHogwarts

// Subscription Plans
subscriptionPlans.basic
subscriptionPlans.standard
subscriptionPlans.premium

// PUDO Locations
pudoLocations.madrid
pudoLocations.barcelona

// Stripe Test Cards
stripeTestCards.successCard
stripeTestCards.declineCard

// Helpers
generateUniqueEmail()
generateTrackingNumber()
generateQRCode()
```

## Best Practices

### 1. Use Page Object Model (Optional)
```typescript
// Create a page object for common actions
class LoginPage {
  async login(page, email, password) {
    await page.fill('[name="email"]', email);
    await page.fill('[name="password"]', password);
    await page.click('button:has-text("Sign In")');
  }
}
```

### 2. Wait for Elements Explicitly
```typescript
// ✅ Good
await expect(page.locator('text=Success')).toBeVisible();

// ❌ Bad
await page.waitForTimeout(2000);
```

### 3. Use Data Attributes
```typescript
// ✅ Use consistent selectors
await page.click('[data-testid="submit-button"]');

// ❌ Avoid fragile selectors
await page.click('button.btn.btn-primary:nth-child(3)');
```

### 4. Handle Authentication
```typescript
// Store auth state between tests
await page.context().addCookies([
  { name: 'auth', value: token, url: 'http://localhost:5173' }
]);
```

### 5. Clean Up Test Data
```typescript
// Reset database before/after tests if needed
test.beforeAll(async () => {
  // Reset test database
  await resetTestDB();
});
```

## Debugging

### View Test Report
```bash
npx playwright show-report
```

### Take Screenshots
```typescript
await page.screenshot({ path: 'screenshot.png' });
```

### Record Video
Already enabled in config for failures

### View Browser Console
```typescript
page.on('console', msg => console.log(msg.text()));
```

### Pause Test Execution
```typescript
await page.pause();
```

## CI/CD Integration

For GitHub Actions, add to `.github/workflows/test.yml`:

```yaml
- name: Run E2E tests
  run: npm run test:e2e

- name: Upload test results
  uses: actions/upload-artifact@v3
  if: always()
  with:
    name: playwright-report
    path: playwright-report/
    retention-days: 30
```

## Troubleshooting

### Tests timeout
- Check if dev server is running: `npm run dev`
- Increase timeout in config: `timeout: 60000`
- Verify network connectivity

### QR code tests not working
- QR scanning is simulated by manual input in tests
- Update selectors if QR element changes

### Payment tests failing
- Use Stripe test cards (already in fixtures)
- Mock Stripe API if needed
- Verify test mode is enabled

### Database conflicts
- Keep `workers: 1` to run tests sequentially
- Clear test data between runs
- Use unique test data (generateUniqueEmail())

## Performance Tips

1. **Run tests in parallel** (when database allows):
```bash
npx playwright test --workers=4
```

2. **Run only changed tests**:
```bash
npx playwright test --last-failed
```

3. **Use test filters**:
```bash
npx playwright test -g "User Journey"
```

## Metrics & Reports

After running tests:
```bash
# View HTML report
npx playwright show-report

# Run with trace for debugging
npx playwright test --trace on
```

## Next Steps

- [ ] Add more test scenarios
- [ ] Implement Page Object Model
- [ ] Setup visual regression testing
- [ ] Add API mocking for external services
- [ ] Configure CI/CD pipeline
- [ ] Setup test data management
- [ ] Add performance testing

## Resources

- [Playwright Documentation](https://playwright.dev)
- [Best Practices](https://playwright.dev/docs/best-practices)
- [Debugging Guide](https://playwright.dev/docs/debug)
- [Reporters](https://playwright.dev/docs/test-reporters)

---

**Status**: Phase 3 ✅  
**Total Tests**: 10 E2E Tests  
**Last Updated**: 23/03/2026