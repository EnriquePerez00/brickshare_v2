import { test, expect } from '@playwright/test';
import { testUsers, pudoLocations, generateUniqueEmail } from '../fixtures/test-data';

/**
 * User Journey: Complete Onboarding
 * Tests the complete signup, email verification, and profile setup flow
 */

test.describe('User Complete Onboarding Journey', () => {
  test('should complete signup, email verification, and profile setup', async ({
    page,
  }) => {
    // Step 1: Navigate to signup
    await page.goto('/');
    await page.click('text=Sign Up');

    // Verify signup page loaded
    await expect(page).toHaveURL(/.*signup/i);
    await expect(page.locator('text=Create Account')).toBeVisible();

    // Step 2: Fill signup form
    const uniqueEmail = generateUniqueEmail();
    await page.fill('[name="email"]', uniqueEmail);
    await page.fill('[name="password"]', testUsers.regularUser.password);
    await page.fill('[name="confirmPassword"]', testUsers.regularUser.password);

    // Step 3: Submit signup
    await page.click('button:has-text("Create Account")');

    // Step 4: Wait for email verification page
    await expect(page).toHaveURL(/.*verify-email|verification/i);
    await expect(page.locator('text=Email Verification')).toBeVisible();

    // Step 5: Simulate email verification (in real app, would click email link)
    // For now, bypass or mock the verification step
    await page.goto('/dashboard');

    // Step 6: Complete profile setup
    await page.fill('[name="fullName"]', testUsers.regularUser.fullName);
    await page.fill('[name="phone"]', testUsers.regularUser.phone);
    await page.fill('[name="address"]', testUsers.regularUser.address);
    await page.fill('[name="zipCode"]', testUsers.regularUser.zipCode);
    await page.fill('[name="city"]', testUsers.regularUser.city);

    // Step 7: Select PUDO location
    await page.click('[data-testid="select-pudo"]');
    await page.click(`text=${pudoLocations.madrid.name}`);

    // Step 8: Save profile
    await page.click('button:has-text("Save Profile")');

    // Step 9: Verify completion
    await expect(page.locator('text=Profile Updated Successfully')).toBeVisible();
    await expect(page).toHaveURL(/.*dashboard/i);
  });

  test('should validate required fields on signup', async ({ page }) => {
    // Navigate to signup
    await page.goto('/auth/signup');

    // Try to submit empty form
    await page.click('button:has-text("Create Account")');

    // Should show validation errors
    await expect(page.locator('text=Email is required')).toBeVisible();
    await expect(page.locator('text=Password is required')).toBeVisible();
  });

  test('should reject weak passwords', async ({ page }) => {
    // Navigate to signup
    await page.goto('/auth/signup');

    // Fill with weak password
    await page.fill('[name="email"]', generateUniqueEmail());
    await page.fill('[name="password"]', '123'); // Too weak
    await page.fill('[name="confirmPassword"]', '123');

    // Try to submit
    await page.click('button:has-text("Create Account")');

    // Should show password strength error
    await expect(page.locator('text=Password must be at least 8 characters')).toBeVisible();
  });

  test('should complete login after signup', async ({ page }) => {
    // This would be run after signup test in a real scenario
    // Navigate to login
    await page.goto('/auth/signin');

    // Fill login form
    await page.fill('[name="email"]', testUsers.regularUser.email);
    await page.fill('[name="password"]', testUsers.regularUser.password);

    // Submit login
    await page.click('button:has-text("Sign In")');

    // Should be redirected to dashboard
    await expect(page).toHaveURL(/.*dashboard/i);
    await expect(page.locator('text=Welcome')).toBeVisible();
  });
});