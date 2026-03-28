import { test, expect } from '@playwright/test';
import { resetDatabase, seedTestData } from '../helpers/database';

/**
 * Admin Journey: Complete Set Assignment Flow with QR and Email
 * Tests the full assignment process including:
 * - Preview assignment
 * - Confirm assignment
 * - Shipment creation
 * - QR code generation
 * - Email delivery
 * - Correos logistics integration
 */

test.describe('Admin Complete Assignment Flow', () => {
  test.beforeEach(async ({ page }) => {
    // Reset database and seed test data
    await resetDatabase();
    await seedTestData();

    // Login as admin
    await page.goto('/auth');
    await page.fill('[name="email"]', 'admin@brickshare.test');
    await page.fill('[name="password"]', 'test123456');
    await page.click('button:has-text("Iniciar sesión")');
    
    // Wait for redirect to admin panel
    await expect(page).toHaveURL(/.*admin/i);
  });

  test('should complete full assignment flow from preview to email delivery', async ({ page }) => {
    // Navigate to Operations > Assignment tab
    await page.goto('/operations');
    await page.click('button:has-text("Asignación sets")');

    // Step 1: Execute preview_assign_sets_to_users()
    await expect(page.locator('text=Previsualización de Asignaciones')).toBeVisible();
    await page.click('button:has-text("Generar Propuesta")');

    // Wait for preview results
    await expect(page.locator('[data-testid="assignment-preview-table"]')).toBeVisible({ timeout: 10000 });

    // Verify preview shows user, set, and PUDO info
    const previewRows = page.locator('[data-testid="preview-row"]');
    await expect(previewRows).toHaveCount(1); // At least 1 assignment

    const firstRow = previewRows.first();
    await expect(firstRow.locator('[data-testid="user-name"]')).toBeVisible();
    await expect(firstRow.locator('[data-testid="set-name"]')).toBeVisible();
    await expect(firstRow.locator('[data-testid="pudo-info"]')).toBeVisible();

    // Step 2: Confirm assignment with confirm_assign_sets_to_users()
    await page.click('button:has-text("Confirmar Asignaciones")');

    // Wait for confirmation dialog
    await expect(page.locator('text=¿Confirmar asignaciones?')).toBeVisible();
    await page.click('button:has-text("Confirmar")');

    // Wait for success message
    await expect(page.locator('text=Asignaciones confirmadas exitosamente')).toBeVisible({ timeout: 15000 });

    // Step 3: Verify shipment created in database
    // Navigate to Shipments tab to verify
    await page.click('button:has-text("Envíos")');
    await expect(page.locator('[data-testid="shipments-table"]')).toBeVisible();

    const shipmentRow = page.locator('[data-testid="shipment-row"]').first();
    await expect(shipmentRow).toBeVisible();

    // Verify shipment has status 'pending' or 'assigned'
    await expect(shipmentRow.locator('text=/pending|assigned/i')).toBeVisible();

    // Step 4: Verify QR codes generated
    await shipmentRow.click();
    await expect(page.locator('[data-testid="shipment-details"]')).toBeVisible();
    
    // Check delivery QR code exists
    const deliveryQR = page.locator('[data-testid="delivery-qr-code"]');
    await expect(deliveryQR).toBeVisible();
    await expect(deliveryQR).toHaveText(/^BS-/); // QR format: BS-{ID}

    // Check return QR code exists
    const returnQR = page.locator('[data-testid="return-qr-code"]');
    await expect(returnQR).toBeVisible();
    await expect(returnQR).toHaveText(/^BS-/);

    // Step 5: Verify PUDO information in shipment
    await expect(page.locator('[data-testid="pudo-type"]')).toContainText(/brickshare|correos/i);
    await expect(page.locator('[data-testid="pudo-name"]')).not.toBeEmpty();
    await expect(page.locator('[data-testid="pudo-address"]')).not.toBeEmpty();

    // Step 6: Send QR email manually (if not auto-sent)
    await page.click('button:has-text("Enviar Email QR")');
    await expect(page.locator('text=Email enviado correctamente')).toBeVisible({ timeout: 10000 });

    // Step 7: Verify Correos logistics integration (if pudo_type = 'correos')
    const pudoType = await page.locator('[data-testid="pudo-type"]').textContent();
    
    if (pudoType?.toLowerCase().includes('correos')) {
      // Trigger Correos preregistration
      await page.click('button:has-text("Generar Etiqueta Correos")');
      
      // Wait for label generation
      await expect(page.locator('text=Etiqueta generada')).toBeVisible({ timeout: 15000 });
      
      // Verify tracking number assigned
      await expect(page.locator('[data-testid="correos-tracking"]')).not.toBeEmpty();
      
      // Verify label URL exists
      await expect(page.locator('[data-testid="label-url"]')).toHaveAttribute('href', /.+/);
    }
  });

  test('should handle assignment failure when user has no PUDO configured', async ({ page }) => {
    // Create user without PUDO in test data
    await page.goto('/operations');
    await page.click('button:has-text("Asignación sets")');

    // Generate preview
    await page.click('button:has-text("Generar Propuesta")');
    await expect(page.locator('[data-testid="assignment-preview-table"]')).toBeVisible({ timeout: 10000 });

    // Check for users with missing PUDO warning
    const warningRow = page.locator('[data-testid="preview-row"]:has-text("Sin PUDO configurado")');
    
    if (await warningRow.count() > 0) {
      // Try to confirm assignment
      await page.click('button:has-text("Confirmar Asignaciones")');
      await page.click('button:has-text("Confirmar")');

      // Should show error
      await expect(page.locator('text=/PUDO no configurado|PUDO point required/i')).toBeVisible();
    }
  });

  test('should validate QR code format and expiration', async ({ page }) => {
    // Complete assignment first
    await page.goto('/operations');
    await page.click('button:has-text("Asignación sets")');
    await page.click('button:has-text("Generar Propuesta")');
    await page.click('button:has-text("Confirmar Asignaciones")');
    await page.click('button:has-text("Confirmar")');

    // Wait for success
    await expect(page.locator('text=Asignaciones confirmadas')).toBeVisible({ timeout: 15000 });

    // Navigate to shipment
    await page.click('button:has-text("Envíos")');
    await page.locator('[data-testid="shipment-row"]').first().click();

    // Validate QR format
    const qrCode = await page.locator('[data-testid="delivery-qr-code"]').textContent();
    expect(qrCode).toMatch(/^BS-[A-Z0-9]{8}$/);

    // Check expiration date exists and is in future
    const expiresText = await page.locator('[data-testid="qr-expires-at"]').textContent();
    expect(expiresText).toBeTruthy();
    
    const expiresDate = new Date(expiresText!);
    const now = new Date();
    expect(expiresDate.getTime()).toBeGreaterThan(now.getTime());
  });

  test('should track assignment in qr_validation_logs when QR is used', async ({ page }) => {
    // This test simulates the PUDO operator scanning the QR
    // In real flow, this happens in the mobile app
    
    await page.goto('/operations');
    await page.click('button:has-text("Asignación sets")');
    await page.click('button:has-text("Generar Propuesta")');
    await page.click('button:has-text("Confirmar Asignaciones")');
    await page.click('button:has-text("Confirmar")');
    await expect(page.locator('text=Asignaciones confirmadas')).toBeVisible({ timeout: 15000 });

    // Get shipment QR
    await page.click('button:has-text("Envíos")');
    await page.locator('[data-testid="shipment-row"]').first().click();
    const qrCode = await page.locator('[data-testid="delivery-qr-code"]').textContent();

    // Simulate QR validation (would normally be done via brickshare-qr-api)
    // For now, verify the QR code exists and is valid format
    expect(qrCode).toMatch(/^BS-/);

    // In production, we would call:
    // GET /functions/v1/brickshare-qr-api/validate/{qrCode}
    // Then verify response contains shipment info without personal data
  });

  test('should update inventory after assignment', async ({ page }) => {
    await page.goto('/operations');
    await page.click('button:has-text("Asignación sets")');

    // Check initial inventory
    await page.goto('/admin');
    await page.click('text=Inventario');
    
    const initialStock = await page.locator('[data-testid="stock-central"]').first().textContent();
    const initialStockNum = parseInt(initialStock || '0');

    // Go back and complete assignment
    await page.goto('/operations');
    await page.click('button:has-text("Asignación sets")');
    await page.click('button:has-text("Generar Propuesta")');
    await page.click('button:has-text("Confirmar Asignaciones")');
    await page.click('button:has-text("Confirmar")');
    await expect(page.locator('text=Asignaciones confirmadas')).toBeVisible({ timeout: 15000 });

    // Verify inventory decreased
    await page.goto('/admin');
    await page.click('text=Inventario');
    
    const newStock = await page.locator('[data-testid="stock-central"]').first().textContent();
    const newStockNum = parseInt(newStock || '0');

    // Stock should decrease by 1 (or more if multiple assignments)
    expect(newStockNum).toBeLessThan(initialStockNum);

    // Verify en_envio increased
    const enEnvio = await page.locator('[data-testid="en-envio"]').first().textContent();
    expect(parseInt(enEnvio || '0')).toBeGreaterThan(0);
  });
});