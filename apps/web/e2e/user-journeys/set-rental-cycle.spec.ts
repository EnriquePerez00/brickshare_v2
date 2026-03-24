import { test, expect } from '@playwright/test';
import { testSets, generateQRCode } from '../fixtures/test-data';

/**
 * User Journey: Complete Set Rental Cycle
 * Tests browsing, requesting, receiving, and returning sets
 */

test.describe('User Set Rental Cycle', () => {
  test('should browse catalog and add set to wishlist', async ({ page }) => {
    // Navigate to catalog
    await page.goto('/catalog');

    // Verify catalog loads
    await expect(page.locator('text=LEGO Set Catalog')).toBeVisible();
    await expect(page.locator('text=Star Wars')).toBeVisible();
    await expect(page.locator('text=City')).toBeVisible();

    // Search for a set
    await page.fill('[data-testid="search-sets"]', 'Star Wars');
    await page.press('[data-testid="search-sets"]', 'Enter');

    // Verify search results
    await expect(page.locator(`text=${testSets.starWars.name}`)).toBeVisible();

    // Click on set to view details
    await page.click(`text=${testSets.starWars.name}`);

    // Verify set details page
    await expect(page.locator('text=Add to Wishlist')).toBeVisible();

    // Add to wishlist
    await page.click('button:has-text("Add to Wishlist")');

    // Verify added confirmation
    await expect(page.locator('text=Added to Wishlist')).toBeVisible();
  });

  test('should filter sets by theme and piece count', async ({ page }) => {
    // Navigate to catalog
    await page.goto('/catalog');

    // Apply theme filter
    await page.click('[data-testid="filter-theme"]');
    await page.click('text=Star Wars');

    // Verify filtered results
    await expect(page.locator('text=Star Wars')).toBeVisible();

    // Apply piece count filter
    await page.click('[data-testid="filter-pieces"]');
    await page.click('text=1000-2000');

    // Verify combined filters applied
    const setCards = page.locator('[data-testid="set-card"]');
    await expect(setCards).toHaveCount(1);
  });

  test('should view wishlist and request set assignment', async ({ page }) => {
    // Navigate to wishlist
    await page.goto('/wishlist');

    // Verify wishlist page
    await expect(page.locator('text=My Wishlist')).toBeVisible();
    await expect(page.locator(`text=${testSets.starWars.name}`)).toBeVisible();

    // Click request assignment
    await page.click('button:has-text("Request Assignment")');

    // Verify confirmation
    await expect(page.locator('text=Assignment requested successfully')).toBeVisible();
  });

  test('should track shipment and confirm receipt', async ({ page }) => {
    // Navigate to active shipments
    await page.goto('/dashboard/shipments');

    // Verify shipment is listed
    await expect(page.locator('text=In Transit')).toBeVisible();
    await expect(page.locator('text=Tracking:')).toBeVisible();

    // View shipment details
    await page.click('[data-testid="shipment-details"]');

    // Verify tracking information
    await expect(page.locator('text=Tracking Number:')).toBeVisible();
    await expect(page.locator('text=PUDO Location:')).toBeVisible();

    // Show QR code for confirmation
    await page.click('button:has-text("Show Delivery QR")');

    // Verify QR code is displayed
    const qrCode = page.locator('[data-testid="delivery-qr"]');
    await expect(qrCode).toBeVisible();

    // Simulate QR scan (button click)
    await page.click('button:has-text("Confirm Receipt")');

    // Verify confirmation
    await expect(page.locator('text=Set received successfully')).toBeVisible();
  });

  test('should display set in active collection after receipt', async ({ page }) => {
    // Navigate to active collection
    await page.goto('/collection/active');

    // Verify received set is displayed
    await expect(page.locator('text=Active Sets')).toBeVisible();
    await expect(page.locator(`text=${testSets.starWars.name}`)).toBeVisible();

    // Verify received date
    await expect(page.locator('text=Received:')).toBeVisible();

    // Verify can return button
    await expect(page.locator('button:has-text("Return Set")')).toBeVisible();
  });

  test('should request return and generate return QR', async ({ page }) => {
    // Navigate to active collection
    await page.goto('/collection/active');

    // Find and click return button
    await page.click(`[data-testid="${testSets.starWars.name}"] button:has-text("Return Set")`);

    // Verify return confirmation dialog
    await expect(page.locator('text=Return Confirmation')).toBeVisible();

    // Confirm return
    await page.click('button:has-text("Confirm Return")');

    // Should show return QR code page
    await expect(page.locator('text=Return QR Code')).toBeVisible();
    const returnQR = page.locator('[data-testid="return-qr"]');
    await expect(returnQR).toBeVisible();

    // Verify instructions
    await expect(page.locator('text=Take this set to any PUDO location')).toBeVisible();
  });

  test('should trigger automatic new set assignment after return', async ({ page }) => {
    // After completing return, user should see new assignment
    await page.goto('/dashboard/assignments');

    // Verify new assignment is pending
    await expect(page.locator('text=New Assignment Available')).toBeVisible();
    await expect(page.locator('text=Pending Shipment')).toBeVisible();
  });
});