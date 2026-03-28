import { test, expect } from '@playwright/test';
import { testUsers } from '../fixtures/test-data';
import { loginAsAdmin } from '../helpers/auth';

/**
 * Admin Journey: Set Assignment Operations
 * Tests admin operations for assigning sets to users
 */

test.describe('Admin Set Assignment Operations', () => {
  test.beforeEach(async ({ page }) => {
    // Login as admin using helper
    await loginAsAdmin(page);
    
    // Wait for auth to be loaded
    await page.waitForTimeout(1000);
  });

  test('should access admin dashboard', async ({ page }) => {
    // Navigate to admin dashboard
    await page.goto('/admin/dashboard');

    // Verify admin dashboard loads
    await expect(page.locator('text=Admin Dashboard')).toBeVisible();
    await expect(page.locator('text=Users')).toBeVisible();
    await expect(page.locator('text=Inventory')).toBeVisible();
    await expect(page.locator('text=Shipments')).toBeVisible();
  });

  test('should generate assignment preview', async ({ page }) => {
    // Navigate to assignments
    await page.goto('/admin/assignments');

    // Click generate preview
    await page.click('button:has-text("Generate Preview")');

    // Verify preview modal opens
    await expect(page.locator('text=Assignment Preview')).toBeVisible();
    await expect(page.locator('text=Total Users')).toBeVisible();
    await expect(page.locator('text=Sets to Assign')).toBeVisible();
    await expect(page.locator('text=Estimated Cost')).toBeVisible();
  });

  test('should review and modify assignment preview', async ({ page }) => {
    // Generate preview
    await page.goto('/admin/assignments');
    await page.click('button:has-text("Generate Preview")');

    // Verify preview content
    await expect(page.locator('text=Assignment Preview')).toBeVisible();

    // Modify selection (example: uncheck a user)
    const userCheckbox = page.locator('[data-testid="user-checkbox"]').first();
    await userCheckbox.uncheck();

    // Verify cost updates
    await expect(page.locator('text=Estimated Cost')).toBeVisible();

    // Close preview without confirming
    await page.click('button:has-text("Cancel")');
  });

  test('should confirm assignment and create shipments', async ({ page }) => {
    // Generate preview
    await page.goto('/admin/assignments');
    await page.click('button:has-text("Generate Preview")');

    // Confirm assignment
    await page.click('button:has-text("Confirm Assignment")');

    // Verify confirmation message
    await expect(page.locator('text=Assignment confirmed successfully')).toBeVisible();
    await expect(page.locator('text=Shipments created')).toBeVisible();

    // Should redirect to shipments page
    await expect(page).toHaveURL(/.*shipments/i);
  });

  test('should view all active shipments', async ({ page }) => {
    // Navigate to shipments
    await page.goto('/admin/shipments');

    // Verify shipments list
    await expect(page.locator('text=Active Shipments')).toBeVisible();
    await expect(page.locator('[data-testid="shipment-row"]')).toHaveCount(1);

    // Verify shipment details columns
    await expect(page.locator('text=User')).toBeVisible();
    await expect(page.locator('text=Set')).toBeVisible();
    await expect(page.locator('text=Status')).toBeVisible();
    await expect(page.locator('text=Tracking Number')).toBeVisible();
  });

  test('should manage return shipments', async ({ page }) => {
    // Navigate to returns
    await page.goto('/admin/returns');

    // Verify returns list
    await expect(page.locator('text=Return Requests')).toBeVisible();

    // View return details
    await page.click('[data-testid="return-row"]');

    // Verify return details
    await expect(page.locator('text=Set')).toBeVisible();
    await expect(page.locator('text=User')).toBeVisible();
    await expect(page.locator('text=Return Status')).toBeVisible();

    // Verify action buttons
    await expect(page.locator('button:has-text("View QR Code")')).toBeVisible();
  });
});