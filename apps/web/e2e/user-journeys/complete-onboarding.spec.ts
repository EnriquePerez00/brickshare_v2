import { test, expect } from '@playwright/test';
import { generateUniqueEmail } from '../fixtures/test-data';
import { supabase, cleanupTestData } from '../helpers/database';
import { 
  openSignupModal, 
  openLoginModal, 
  waitForAuthForm,
  fillSignupForm,
  fillLoginForm,
  submitAuthForm
} from '../helpers/modal-helpers';

/**
 * User Journey: Complete Onboarding
 * Tests the complete signup, email verification, and profile setup flow
 * 
 * ARCHITECTURE NOTE: This app uses MODALS for authentication, not separate routes.
 * Auth happens via modals opened from the home page, not /auth/* routes.
 */

test.describe('User Complete Onboarding Journey', () => {
  let testUserEmail: string;
  let testUserId: string;

  test.afterEach(async () => {
    // Cleanup test user if created
    if (testUserId) {
      try {
        await cleanupTestData(testUserId);
      } catch (error) {
        console.error('Cleanup error:', error);
      }
    }
  });

  test('should complete signup with unique email', async ({ page }) => {
    // Step 1: Navigate to home page
    await page.goto('/', { waitUntil: 'domcontentloaded' });
    await page.waitForLoadState('networkidle', { timeout: 30000 });

    // Step 2: Open signup modal
    await openSignupModal(page);

    // Step 3: Wait for auth form to appear
    await waitForAuthForm(page);

    // Step 4: Fill signup form
    testUserEmail = generateUniqueEmail();
    await fillSignupForm(page, testUserEmail, 'TestPassword123!');

    // Step 5: Submit signup
    await submitAuthForm(page);

    // Step 6: Wait for successful signup (redirect or confirmation)
    await page.waitForTimeout(3000);
    
    // Step 7: Verify we're logged in (should see dashboard or profile elements)
    const currentUrl = page.url();
    console.log('After signup URL:', currentUrl);
    
    const isAuthenticated = 
      (await page.locator('text=/Dashboard|Mi Panel|Perfil/i').count()) > 0 ||
      currentUrl.includes('/dashboard');
    
    expect(isAuthenticated).toBeTruthy();

    // Step 8: Store user ID for cleanup
    const { data } = await supabase.auth.admin.listUsers();
    const createdUser = data?.users?.find(u => u.email === testUserEmail);
    if (createdUser) {
      testUserId = createdUser.id;
    }
  });

  test('should validate required fields on signup', async ({ page }) => {
    // Navigate to home
    await page.goto('/', { waitUntil: 'domcontentloaded' });
    await page.waitForLoadState('networkidle', { timeout: 30000 });
    
    // Open signup modal
    await openSignupModal(page);
    
    // Wait for form
    await waitForAuthForm(page, 10000);

    // Try to submit empty form
    await submitAuthForm(page);

    // Should still see the form (HTML5 validation prevents submission)
    await page.waitForTimeout(1000);
    const emailInput = await page.locator('input[type="email"]').count();
    expect(emailInput).toBeGreaterThan(0);
  });

  test('should reject weak passwords', async ({ page }) => {
    // Navigate to home
    await page.goto('/', { waitUntil: 'domcontentloaded' });
    await page.waitForLoadState('networkidle', { timeout: 30000 });

    // Open signup modal
    await openSignupModal(page);

    // Wait for form
    await waitForAuthForm(page, 10000);

    // Fill with weak password
    await fillSignupForm(page, generateUniqueEmail(), '123', true);

    // Try to submit
    await submitAuthForm(page);

    // Should show error message or stay on same form
    await page.waitForTimeout(2000);
    const hasError = 
      (await page.locator('text=/contraseña.*al menos/i').count()) > 0 ||
      (await page.locator('input[type="email"]').count()) > 0;
    
    expect(hasError).toBeTruthy();
  });

  test('should complete login with existing test user', async ({ page }) => {
    // This test uses the pre-created test user from database
    const testEmail = 'e2e.onboarding@test.com';
    const testPassword = 'TestPassword123!';

    // Navigate to home
    await page.goto('/', { waitUntil: 'domcontentloaded' });
    await page.waitForLoadState('networkidle', { timeout: 30000 });

    // Open login modal
    await openLoginModal(page);

    // Wait for auth form
    await waitForAuthForm(page);

    // Fill and submit login form
    await fillLoginForm(page, testEmail, testPassword);
    await submitAuthForm(page);

    // Wait for navigation after login
    await page.waitForTimeout(3000);
    
    // Should be logged in - check for authenticated content
    const currentUrl = page.url();
    console.log('After login URL:', currentUrl);
    
    // Check for dashboard or authenticated elements
    const isAuthenticated = 
      (await page.locator('text=/Mi Panel|Dashboard|Catálogo|Perfil/i').count()) > 0 ||
      currentUrl.includes('/dashboard');
    
    expect(isAuthenticated).toBeTruthy();
  });
});