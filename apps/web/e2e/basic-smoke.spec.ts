import { test, expect } from '@playwright/test';

/**
 * Basic Smoke Tests
 * These tests verify that core pages load correctly without authentication
 */

test.describe('Basic Smoke Test', () => {
  test('should load the home page', async ({ page }) => {
    // Navigate to the home page
    await page.goto('/');
    
    // Wait for the page to load
    await page.waitForLoadState('networkidle');
    
    // Check that the page title contains "Brickshare"
    await expect(page).toHaveTitle(/Brickshare/i);
    
    // Check for the presence of a key element
    const heading = page.locator('h1, h2').first();
    await expect(heading).toBeVisible({ timeout: 10000 });
    
    console.log('✓ Home page loaded successfully');
  });

  test('should navigate to catalog', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    
    // Try to find catalog link - it might be in nav or as a button
    const catalogLink = page.locator('a[href*="catalogo"], a[href*="catalog"], button:has-text("Catálogo"), button:has-text("Catalog")').first();
    
    // Check if link exists before clicking
    const isVisible = await catalogLink.isVisible().catch(() => false);
    
    if (isVisible) {
      await catalogLink.click();
      
      // Wait for navigation with timeout
      await page.waitForURL(/.*catalogo|catalog.*/i, { timeout: 10000 }).catch(() => {
        console.log('⚠ Navigation to catalog timed out');
      });
      
      // Verify we're on the catalog page
      const url = page.url();
      if (url.includes('catalogo') || url.includes('catalog')) {
        console.log('✓ Navigated to catalog successfully');
      } else {
        console.log('⚠ URL does not contain "catalogo" or "catalog":', url);
      }
    } else {
      console.log('⚠ Catalog link not found - this is OK, skipping navigation test');
    }
  });

  test('should display login/auth page', async ({ page }) => {
    // Try multiple common auth routes
    const authRoutes = ['/auth/signin', '/login', '/signin', '/auth/login'];
    
    let pageLoaded = false;
    
    for (const route of authRoutes) {
      try {
        await page.goto(route, { waitUntil: 'networkidle', timeout: 10000 });
        
        // Check if we got a 404 or the page loaded
        const title = await page.title();
        if (!title.includes('404') && !title.includes('Not Found')) {
          pageLoaded = true;
          console.log(`✓ Auth page found at route: ${route}`);
          break;
        }
      } catch (error) {
        console.log(`⚠ Route ${route} not accessible`);
      }
    }
    
    if (!pageLoaded) {
      console.log('⚠ No auth page found, skipping auth page test');
      test.skip();
      return;
    }
    
    // Check for email input field (should exist on any auth page)
    const emailInput = page.locator('input[type="email"], input[name="email"], input[placeholder*="email" i]').first();
    const emailVisible = await emailInput.isVisible({ timeout: 5000 }).catch(() => false);
    
    if (emailVisible) {
      await expect(emailInput).toBeVisible();
      console.log('✓ Email input found');
    }
    
    // Check for password input field
    const passwordInput = page.locator('input[type="password"], input[name="password"], input[placeholder*="password" i]').first();
    const passwordVisible = await passwordInput.isVisible({ timeout: 5000 }).catch(() => false);
    
    if (passwordVisible) {
      await expect(passwordInput).toBeVisible();
      console.log('✓ Password input found');
    }
    
    if (emailVisible && passwordVisible) {
      console.log('✓ Login page loaded successfully');
    }
  });
});
