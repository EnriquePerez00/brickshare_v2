import { Page } from '@playwright/test';
import { supabase } from './database';

/**
 * Login helper for E2E tests
 * Uses direct database authentication for faster, more reliable tests
 */

export interface TestUser {
  email: string;
  password: string;
  fullName?: string;
  phone?: string;
  address?: string;
  zipCode?: string;
  city?: string;
}

/**
 * Login as a user using email/password via UI
 * @param page Playwright page object
 * @param email User email
 * @param password User password
 */
export async function loginViaUI(page: Page, email: string, password: string) {
  await page.goto('/auth/signin');
  
  // Wait for login form to be visible
  await page.waitForSelector('[name="email"]', { timeout: 10000 });
  
  // Fill credentials
  await page.fill('[name="email"]', email);
  await page.fill('[name="password"]', password);
  
  // Submit form
  await page.click('button[type="submit"]');
  
  // Wait for navigation to complete (dashboard or catalog)
  await page.waitForURL(/.*dashboard|catalog|catalogo/i, { timeout: 15000 });
}

/**
 * Setup authenticated session by directly injecting auth token
 * This is faster and more reliable than UI login
 * @param page Playwright page object
 * @param email User email
 * @param password User password
 */
export async function setupAuthenticatedSession(page: Page, email: string, password: string) {
  // 1. Get session from Supabase
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });
  
  if (error) {
    throw new Error(`Authentication failed: ${error.message}`);
  }
  
  if (!data.session) {
    throw new Error('No session returned from authentication');
  }
  
  // 2. Navigate to app
  await page.goto('/');
  
  // 3. Inject auth token into localStorage
  await page.evaluate((session) => {
    localStorage.setItem(
      `sb-${window.location.hostname.split('.')[0]}-auth-token`,
      JSON.stringify({
        access_token: session.access_token,
        refresh_token: session.refresh_token,
        expires_at: session.expires_at,
        expires_in: session.expires_in,
        token_type: session.token_type,
        user: session.user,
      })
    );
  }, data.session);
  
  // 4. Reload to apply session
  await page.reload();
  
  // 5. Wait for auth to be loaded
  await page.waitForTimeout(1000);
}

/**
 * Quick login helper - uses test@brickshare.test user
 * @param page Playwright page object
 */
export async function loginAsTestUser(page: Page) {
  await setupAuthenticatedSession(
    page,
    'test@brickshare.test',
    'test123456'
  );
}

/**
 * Login as admin user
 * @param page Playwright page object
 */
export async function loginAsAdmin(page: Page) {
  await setupAuthenticatedSession(
    page,
    'admin@brickshare.test',
    'test123456'
  );
}

/**
 * Login as operator user
 * @param page Playwright page object
 */
export async function loginAsOperator(page: Page) {
  await setupAuthenticatedSession(
    page,
    'operator@brickshare.test',
    'test123456'
  );
}

/**
 * Logout the current user
 * @param page Playwright page object
 */
export async function logout(page: Page) {
  await page.evaluate(() => {
    // Clear all auth-related localStorage items
    for (let i = localStorage.length - 1; i >= 0; i--) {
      const key = localStorage.key(i);
      if (key && key.includes('auth-token')) {
        localStorage.removeItem(key);
      }
    }
  });
  
  await page.goto('/auth/signin');
}

/**
 * Check if user is authenticated
 * @param page Playwright page object
 * @returns true if authenticated, false otherwise
 */
export async function isAuthenticated(page: Page): Promise<boolean> {
  return await page.evaluate(() => {
    for (let i = 0; i < localStorage.length; i++) {
      const key = localStorage.key(i);
      if (key && key.includes('auth-token')) {
        const value = localStorage.getItem(key);
        if (value) {
          try {
            const session = JSON.parse(value);
            return !!session.access_token;
          } catch {
            return false;
          }
        }
      }
    }
    return false;
  });
}