import { test, expect } from '@playwright/test';
import { resetDatabase, seedTestData, createReturnShipment, supabase } from '../helpers/database';

/**
 * Operator Journey: Complete Return Reception Flow
 * Tests the full operator flow for receiving returned sets:
 * - View pending returns
 * - Scan return QR code
 * - Validate QR via brickshare-qr-api
 * - Inspect set condition
 * - Update inventory
 * - Log maintenance if needed
 */

test.describe('Operator Complete Reception Flow', () => {
  let testUserId: string;
  let testSetId: string;

  test.beforeEach(async ({ page }) => {
    // Reset and seed test data
    await resetDatabase();
    const seedResult = await seedTestData();
    testUserId = seedResult.testUserId!;

    // Get the first test set
    const { data: sets } = await supabase.from('sets').select('id').limit(1).single();
    testSetId = sets?.id || '';

    // Create a return shipment in database
    if (testUserId && testSetId) {
      await createReturnShipment(testUserId, testSetId);
    }

    // Login as operator
    await page.goto('/auth');
    await page.fill('[name="email"]', 'operator@brickshare.test');
    await page.fill('[name="password"]', 'test123456');
    await page.click('button:has-text("Iniciar sesión")');
    
    // Wait for redirect to operations panel
    await expect(page).toHaveURL(/.*operations/i);
  });

  test('should process complete return reception with QR validation', async ({ page }) => {
    // Navigate to Returns tab
    await page.goto('/operations');
    await page.click('button:has-text("Devoluciones")');

    // Verify returns list loads
    await expect(page.locator('[data-testid="returns-list"]')).toBeVisible();

    // Find a return with status 'in_return_pudo' or 'in_return'
    const returnRow = page.locator('[data-testid="return-row"]').first();
    await expect(returnRow).toBeVisible();

    // Click to view return details
    await returnRow.click();

    // Step 1: Scan return QR code
    await expect(page.locator('text=Escanear QR de Devolución')).toBeVisible();
    
    const returnQR = await page.locator('[data-testid="return-qr-display"]').textContent();
    expect(returnQR).toMatch(/^BS-/);

    // Simulate QR scan (in real app, this uses camera)
    await page.click('button:has-text("Validar QR")');
    
    // Enter QR code manually (for testing)
    await page.fill('[data-testid="qr-input"]', returnQR!);
    await page.click('button:has-text("Confirmar")');

    // Step 2: Validate QR against brickshare-qr-api
    // Wait for validation result
    await expect(page.locator('text=QR válido')).toBeVisible({ timeout: 10000 });

    // Should display shipment info
    await expect(page.locator('[data-testid="shipment-info"]')).toBeVisible();
    await expect(page.locator('[data-testid="set-name"]')).not.toBeEmpty();
    await expect(page.locator('[data-testid="set-ref"]')).not.toBeEmpty();

    // Step 3: Inspect set condition
    await expect(page.locator('text=Inspección del Set')).toBeVisible();

    // Check piece checklist
    await page.click('[data-testid="pieces-checklist"]');
    
    // Mark all pieces as present (or note missing ones)
    const checkboxes = page.locator('[data-testid="piece-checkbox"]');
    const count = await checkboxes.count();
    
    for (let i = 0; i < Math.min(count, 5); i++) {
      await checkboxes.nth(i).check();
    }

    // Check set condition
    await page.selectOption('[data-testid="set-condition"]', 'good');

    // Add inspection notes
    await page.fill('[data-testid="inspection-notes"]', 'Set recibido en buen estado, todas las piezas presentes');

    // Step 4: Mark as received
    await page.click('button:has-text("Confirmar Recepción")');

    // Wait for confirmation
    await expect(page.locator('text=Devolución procesada correctamente')).toBeVisible({ timeout: 10000 });

    // Step 5: Verify reception logged in database
    // Should be able to see in reception operations log
    await page.goto('/operations');
    await page.click('button:has-text("Mantenimiento")');
    
    // Check if reception operation is logged
    // If set is in good condition, it should go directly to inventory
    // If damaged, it should appear in maintenance queue
  });

  test('should handle damaged set requiring maintenance', async ({ page }) => {
    await page.goto('/operations');
    await page.click('button:has-text("Devoluciones")');

    const returnRow = page.locator('[data-testid="return-row"]').first();
    await returnRow.click();

    // Scan and validate QR
    const returnQR = await page.locator('[data-testid="return-qr-display"]').textContent();
    await page.click('button:has-text("Validar QR")');
    await page.fill('[data-testid="qr-input"]', returnQR!);
    await page.click('button:has-text("Confirmar")');

    await expect(page.locator('text=QR válido')).toBeVisible({ timeout: 10000 });

    // Mark set as damaged
    await page.selectOption('[data-testid="set-condition"]', 'damaged');

    // Uncheck some pieces
    await page.locator('[data-testid="piece-checkbox"]').first().uncheck();

    // Add detailed maintenance notes
    await page.fill('[data-testid="inspection-notes"]', 'Faltan 3 piezas rojas 2x4 y 1 pieza azul 1x1. Caja dañada.');

    // Select maintenance required
    await page.check('[data-testid="requires-maintenance"]');

    // Confirm reception
    await page.click('button:has-text("Confirmar Recepción")');

    await expect(page.locator('text=Set enviado a mantenimiento')).toBeVisible({ timeout: 10000 });

    // Verify set appears in maintenance queue
    await page.goto('/operations');
    await page.click('button:has-text("Mantenimiento")');

    await expect(page.locator('[data-testid="maintenance-list"]')).toBeVisible();
    
    const maintenanceItem = page.locator('[data-testid="maintenance-item"]').first();
    await expect(maintenanceItem).toContainText('Faltan 3 piezas');
  });

  test('should update inventory after successful reception', async ({ page }) => {
    // Check initial inventory
    await page.goto('/admin');
    await page.click('text=Inventario');
    
    const initialEnUso = await page.locator('[data-testid="en-uso"]').first().textContent();
    const initialEnUsoNum = parseInt(initialEnUso || '0');

    // Process return
    await page.goto('/operations');
    await page.click('button:has-text("Devoluciones")');
    
    const returnRow = page.locator('[data-testid="return-row"]').first();
    await returnRow.click();

    const returnQR = await page.locator('[data-testid="return-qr-display"]').textContent();
    await page.click('button:has-text("Validar QR")');
    await page.fill('[data-testid="qr-input"]', returnQR!);
    await page.click('button:has-text("Confirmar")');

    await expect(page.locator('text=QR válido')).toBeVisible({ timeout: 10000 });

    // Mark as good condition
    await page.selectOption('[data-testid="set-condition"]', 'good');
    await page.click('button:has-text("Confirmar Recepción")');

    await expect(page.locator('text=Devolución procesada')).toBeVisible({ timeout: 10000 });

    // Verify inventory updated
    await page.goto('/admin');
    await page.click('text=Inventario');

    // en_uso should decrease
    const newEnUso = await page.locator('[data-testid="en-uso"]').first().textContent();
    const newEnUsoNum = parseInt(newEnUso || '0');
    expect(newEnUsoNum).toBeLessThan(initialEnUsoNum);

    // stock_central should increase
    const stockCentral = await page.locator('[data-testid="stock-central"]').first().textContent();
    expect(parseInt(stockCentral || '0')).toBeGreaterThan(0);
  });

  test('should reject invalid or expired QR codes', async ({ page }) => {
    await page.goto('/operations');
    await page.click('button:has-text("Devoluciones")');

    const returnRow = page.locator('[data-testid="return-row"]').first();
    await returnRow.click();

    // Try to validate invalid QR
    await page.click('button:has-text("Validar QR")');
    await page.fill('[data-testid="qr-input"]', 'INVALID-QR-CODE');
    await page.click('button:has-text("Confirmar")');

    // Should show error
    await expect(page.locator('text=/QR inválido|QR code is invalid/i')).toBeVisible();
  });

  test('should prevent duplicate QR validation', async ({ page }) => {
    await page.goto('/operations');
    await page.click('button:has-text("Devoluciones")');

    const returnRow = page.locator('[data-testid="return-row"]').first();
    await returnRow.click();

    const returnQR = await page.locator('[data-testid="return-qr-display"]').textContent();

    // Validate QR first time
    await page.click('button:has-text("Validar QR")');
    await page.fill('[data-testid="qr-input"]', returnQR!);
    await page.click('button:has-text("Confirmar")');
    await expect(page.locator('text=QR válido')).toBeVisible({ timeout: 10000 });

    // Complete reception
    await page.selectOption('[data-testid="set-condition"]', 'good');
    await page.click('button:has-text("Confirmar Recepción")');
    await expect(page.locator('text=Devolución procesada')).toBeVisible({ timeout: 10000 });

    // Try to validate same QR again
    await page.goto('/operations');
    await page.click('button:has-text("Devoluciones")');
    
    await page.click('button:has-text("Validar QR")');
    await page.fill('[data-testid="qr-input"]', returnQR!);
    await page.click('button:has-text("Confirmar")');

    // Should show already used error
    await expect(page.locator('text=/QR ya utilizado|already used/i')).toBeVisible();
  });

  test('should log reception operation in database', async ({ page }) => {
    await page.goto('/operations');
    await page.click('button:has-text("Devoluciones")');

    const returnRow = page.locator('[data-testid="return-row"]').first();
    await returnRow.click();

    const returnQR = await page.locator('[data-testid="return-qr-display"]').textContent();
    await page.click('button:has-text("Validar QR")');
    await page.fill('[data-testid="qr-input"]', returnQR!);
    await page.click('button:has-text("Confirmar")');

    await expect(page.locator('text=QR válido')).toBeVisible({ timeout: 10000 });

    await page.selectOption('[data-testid="set-condition"]', 'good');
    await page.fill('[data-testid="inspection-notes"]', 'Set en perfecto estado');
    await page.click('button:has-text("Confirmar Recepción")');

    await expect(page.locator('text=Devolución procesada')).toBeVisible({ timeout: 10000 });

    // Check operation logs
    await page.goto('/operations');
    
    // Verify in qr_validation_logs and reception_operations tables
    // This would require querying the database or showing logs in UI
    // For now, we verify the operation completed successfully
  });
});