import { test, expect } from '@playwright/test';
import { testUsers, generateQRCode, generateTrackingNumber } from '../fixtures/test-data';

/**
 * Operator Journey: Logistics Operations
 * Tests operator QR scanning, maintenance logging, and shipment tracking
 */

test.describe('Operator Logistics Operations', () => {
  test.beforeEach(async ({ page }) => {
    // Login as operator
    await page.goto('/auth/signin');
    await page.fill('[name="email"]', testUsers.operatorUser.email);
    await page.fill('[name="password"]', testUsers.operatorUser.password);
    await page.click('button:has-text("Sign In")');

    // Wait for operator dashboard
    await expect(page).toHaveURL(/.*operator|operations/i);
  });

  test('should access operator dashboard', async ({ page }) => {
    // Navigate to operator dashboard
    await page.goto('/operator/dashboard');

    // Verify operator dashboard loads
    await expect(page.locator('text=Operations Dashboard')).toBeVisible();
    await expect(page.locator('text=Pending Deliveries')).toBeVisible();
    await expect(page.locator('text=QR Scanner')).toBeVisible();
  });

  test('should scan delivery QR code and mark as delivered', async ({ page }) => {
    // Navigate to QR scanner
    await page.goto('/operator/qr-scanner');

    // Verify scanner page
    await expect(page.locator('text=QR Code Scanner')).toBeVisible();
    await expect(page.locator('text=Point your camera')).toBeVisible();

    // Simulate QR code scan by entering QR manually
    const qrInput = page.locator('[data-testid="qr-input"]');
    const qrCode = generateQRCode();

    // Enter QR code
    await qrInput.fill(qrCode);
    await qrInput.press('Enter');

    // Should display shipment details
    await expect(page.locator('text=Shipment Details')).toBeVisible();
    await expect(page.locator('text=User:')).toBeVisible();
    await expect(page.locator('text=Set:')).toBeVisible();

    // Confirm delivery
    await page.click('button:has-text("Confirm Delivery")');

    // Verify confirmation
    await expect(page.locator('text=Delivered successfully')).toBeVisible();
  });

  test('should scan return QR code and mark as returned', async ({ page }) => {
    // Navigate to QR scanner
    await page.goto('/operator/qr-scanner');

    // Enter return QR code
    const returnQR = `RETURN-${generateQRCode()}`;
    await page.locator('[data-testid="qr-input"]').fill(returnQR);
    await page.locator('[data-testid="qr-input"]').press('Enter');

    // Should display return shipment details
    await expect(page.locator('text=Return Shipment')).toBeVisible();

    // Confirm return reception
    await page.click('button:has-text("Confirm Return Reception")');

    // Verify confirmation
    await expect(page.locator('text=Return received successfully')).toBeVisible();
  });

  test('should mark set for maintenance and log issue', async ({ page }) => {
    // Navigate to maintenance section
    await page.goto('/operator/maintenance');

    // Verify maintenance page
    await expect(page.locator('text=Maintenance Queue')).toBeVisible();

    // Click on a set to mark for maintenance
    await page.click('[data-testid="maintenance-action"]');

    // Verify maintenance form
    await expect(page.locator('text=Report Issue')).toBeVisible();

    // Fill issue description
    await page.fill('[name="issue"]', 'Missing 3 red bricks and 1 connector');

    // Select severity
    await page.click('[data-testid="severity"]');
    await page.click('text=Medium');

    // Submit maintenance report
    await page.click('button:has-text("Report Issue")');

    // Verify confirmation
    await expect(page.locator('text=Issue reported successfully')).toBeVisible();
  });

  test('should complete maintenance and return set to inventory', async ({ page }) => {
    // Navigate to maintenance queue
    await page.goto('/operator/maintenance');

    // Find a set in maintenance
    const maintenanceItem = page.locator('[data-testid="maintenance-item"]').first();
    await maintenanceItem.click();

    // Verify maintenance details
    await expect(page.locator('text=Maintenance Details')).toBeVisible();

    // Add maintenance notes
    await page.fill('[name="notes"]', 'Replaced missing bricks from spare inventory');

    // Complete maintenance
    await page.click('button:has-text("Complete Maintenance")');

    // Verify completion
    await expect(page.locator('text=Maintenance completed')).toBeVisible();
    await expect(page.locator('text=Set ready for shipment')).toBeVisible();
  });

  test('should view operation logs and history', async ({ page }) => {
    // Navigate to operation logs
    await page.goto('/operator/logs');

    // Verify logs page
    await expect(page.locator('text=Operation Logs')).toBeVisible();
    await expect(page.locator('text=Date')).toBeVisible();
    await expect(page.locator('text=Action')).toBeVisible();
    await expect(page.locator('text=Details')).toBeVisible();

    // Filter by action type
    await page.click('[data-testid="filter-action"]');
    await page.click('text=QR Scan');

    // Verify filtered logs
    const logs = page.locator('[data-testid="log-row"]');
    await expect(logs).toHaveCount(1);
  });

  test('should export operation logs', async ({ page }) => {
    // Navigate to operation logs
    await page.goto('/operator/logs');

    // Click export button
    const downloadPromise = page.waitForEvent('download');
    await page.click('button:has-text("Export Logs")');

    // Verify download
    const download = await downloadPromise;
    expect(download.suggestedFilename()).toMatch(/logs.*\.csv/);
  });
});