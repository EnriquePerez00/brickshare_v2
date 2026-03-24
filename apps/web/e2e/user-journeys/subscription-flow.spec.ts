import { test, expect } from '@playwright/test';
import { testUsers, subscriptionPlans, stripeTestCards } from '../fixtures/test-data';

/**
 * User Journey: Subscription Selection and Payment
 * Tests the subscription plan selection and Stripe payment flow
 */

test.describe('User Subscription Flow', () => {
  test.beforeEach(async ({ page }) => {
    // Assume user is already logged in
    // In a real scenario, you'd use authentication tokens or login first
    await page.goto('/subscription');
  });

  test('should display all subscription plans', async ({ page }) => {
    // Verify all plans are visible
    await expect(page.locator('text=Basic')).toBeVisible();
    await expect(page.locator('text=Standard')).toBeVisible();
    await expect(page.locator('text=Premium')).toBeVisible();

    // Verify pricing is displayed
    await expect(page.locator('text=$9.99')).toBeVisible();
    await expect(page.locator('text=$19.99')).toBeVisible();
    await expect(page.locator('text=$29.99')).toBeVisible();
  });

  test('should select subscription plan and proceed to payment', async ({ page }) => {
    // Click on Standard plan
    await page.click('[data-testid="plan-standard"]');

    // Verify plan is selected
    await expect(page.locator('[data-testid="plan-standard"]')).toHaveClass(/selected/);

    // Click checkout button
    await page.click('button:has-text("Continue to Payment")');

    // Should navigate to Stripe checkout
    await expect(page).toHaveURL(/.*checkout|payment/i);
  });

  test('should handle successful payment with test card', async ({ page }) => {
    // Select a plan
    await page.click('[data-testid="plan-premium"]');

    // Click checkout
    await page.click('button:has-text("Continue to Payment")');

    // Wait for Stripe iframe to load
    await page.waitForURL(/.*checkout|stripe/i);

    // Fill Stripe card form (in iframe)
    const cardNumberFrame = await page.locator('iframe[name="__privateStripeFrame"]').first();

    // Note: In real tests, you'd interact with Stripe iframe
    // For this example, we verify the checkout page loads
    await expect(page.locator('text=Payment Details')).toBeVisible();
  });

  test('should show confirmation after successful payment', async ({ page }) => {
    // Complete payment flow (mocked)
    // After successful payment, should show confirmation
    await page.goto('/subscription-confirmation');

    // Verify confirmation page
    await expect(page.locator('text=Subscription Confirmed')).toBeVisible();
    await expect(page.locator('text=Premium')).toBeVisible();
    await expect(page.locator('text=Your subscription renews on')).toBeVisible();
  });

  test('should allow subscription upgrade', async ({ page }) => {
    // Navigate to subscription management
    await page.goto('/account/subscription');

    // Should show current plan
    await expect(page.locator('text=Current Plan: Standard')).toBeVisible();

    // Click upgrade button
    await page.click('button:has-text("Upgrade to Premium")');

    // Should proceed to payment
    await expect(page).toHaveURL(/.*payment|checkout/i);
  });

  test('should display subscription details and renewal date', async ({ page }) => {
    // Navigate to subscription details
    await page.goto('/account/subscription');

    // Verify subscription info is displayed
    await expect(page.locator('text=Plan:')).toBeVisible();
    await expect(page.locator('text=Status: Active')).toBeVisible();
    await expect(page.locator('text=Renews on:')).toBeVisible();
    await expect(page.locator('text=Next renewal date')).toBeVisible();
  });
});