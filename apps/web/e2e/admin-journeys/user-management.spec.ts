import { test, expect } from '@playwright/test';
import { testUsers, generateUniqueEmail } from '../fixtures/test-data';

/**
 * Admin Journey: User Management
 * Tests admin user listing, searching, and role management
 */

test.describe('Admin User Management', () => {
  test.beforeEach(async ({ page }) => {
    // Login as admin
    await page.goto('/auth/signin');
    await page.fill('[name="email"]', testUsers.adminUser.email);
    await page.fill('[name="password"]', testUsers.adminUser.password);
    await page.click('button:has-text("Sign In")');

    // Wait for dashboard
    await expect(page).toHaveURL(/.*admin|backoffice/i);
  });

  test('should list and search users', async ({ page }) => {
    // Navigate to user management
    await page.goto('/admin/users');

    // Verify users list loads
    await expect(page.locator('text=Users Management')).toBeVisible();
    await expect(page.locator('[data-testid="user-row"]')).toHaveCount(1);

    // Search by email
    await page.fill('[data-testid="search-users"]', testUsers.regularUser.email);
    await page.press('[data-testid="search-users"]', 'Enter');

    // Verify search results
    await expect(page.locator(`text=${testUsers.regularUser.email}`)).toBeVisible();
  });

  test('should view user details and subscription', async ({ page }) => {
    // Navigate to users
    await page.goto('/admin/users');

    // Click on a user
    await page.click(`[data-testid="user-${testUsers.regularUser.email}"]`);

    // Verify user details page
    await expect(page.locator('text=User Details')).toBeVisible();
    await expect(page.locator(`text=${testUsers.regularUser.fullName}`)).toBeVisible();
    await expect(page.locator(`text=${testUsers.regularUser.email}`)).toBeVisible();

    // Verify subscription section
    await expect(page.locator('text=Subscription')).toBeVisible();
    await expect(page.locator('text=Plan:')).toBeVisible();
    await expect(page.locator('text=Status:')).toBeVisible();
  });

  test('should filter users by subscription status', async ({ page }) => {
    // Navigate to users
    await page.goto('/admin/users');

    // Apply status filter
    await page.click('[data-testid="filter-status"]');
    await page.click('text=Active');

    // Verify filtered results
    const userRows = page.locator('[data-testid="user-row"]');
    const count = await userRows.count();
    expect(count).toBeGreaterThan(0);

    // All visible users should have "Active" status
    for (let i = 0; i < count; i++) {
      const row = userRows.nth(i);
      await expect(row.locator('text=Active')).toBeVisible();
    }
  });

  test('should assign admin role to user', async ({ page }) => {
    // Navigate to users
    await page.goto('/admin/users');

    // Find and click a user
    await page.click('[data-testid="user-row"]');

    // Open role management
    await page.click('button:has-text("Manage Roles")');

    // Verify role dialog
    await expect(page.locator('text=User Roles')).toBeVisible();

    // Assign admin role
    await page.click('[data-testid="role-admin"]');

    // Save changes
    await page.click('button:has-text("Save")');

    // Verify confirmation
    await expect(page.locator('text=Role updated successfully')).toBeVisible();
  });

  test('should deactivate user account', async ({ page }) => {
    // Navigate to users
    await page.goto('/admin/users');

    // Find and click a user
    await page.click('[data-testid="user-row"]');

    // Open account actions
    await page.click('button:has-text("More Actions")');

    // Click deactivate
    await page.click('text=Deactivate Account');

    // Confirm deactivation
    await page.click('button:has-text("Confirm")');

    // Verify success message
    await expect(page.locator('text=User deactivated')).toBeVisible();
  });

  test('should view user activity history', async ({ page }) => {
    // Navigate to users
    await page.goto('/admin/users');

    // Click on a user
    await page.click('[data-testid="user-row"]');

    // Navigate to activity tab
    await page.click('[data-testid="tab-activity"]');

    // Verify activity log
    await expect(page.locator('text=Activity Log')).toBeVisible();
    await expect(page.locator('text=Login')).toBeVisible();
    await expect(page.locator('text=View Set')).toBeVisible();
  });
});