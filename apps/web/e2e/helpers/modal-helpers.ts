/**
 * Helper functions for opening and interacting with modals
 * 
 * IMPORTANT: Brickshare uses MODALS for authentication, not separate routes.
 * These helpers provide a robust way to interact with modal-based UI.
 */

import { Page, Locator } from '@playwright/test';

/**
 * Opens the signup/register modal from any page
 * Tries multiple possible button texts and selectors
 */
export async function openSignupModal(page: Page): Promise<void> {
  // First, let's debug what's available on the page
  const availableButtons = await page.locator('button, a').evaluateAll(els => 
    els.map(el => ({
      text: el.textContent?.trim(),
      className: el.className,
      id: el.id
    })).filter(item => item.text)
  );
  
  console.log('Available buttons on page:', JSON.stringify(availableButtons, null, 2));

  const signupSelectors = [
    'button:has-text("Suscribirse")',  // El botón real según logs
    'button:has-text("Registrarse")',
    'button:has-text("Crear cuenta")',
    'a:has-text("Registrarse")',
    'a:has-text("Crear cuenta")',
    'button:has-text("Empezar")',
    'a:has-text("Empezar")',
    '[data-testid="register-link"]',
    '[data-testid="register-button"]',
    '[data-testid="signup-button"]',
    '[data-testid="cta-button"]',
    'text=/Suscr[ií]bete|Suscribirse|Únete|Regístrate|Empezar/i'
  ];

  for (const selector of signupSelectors) {
    try {
      const element = page.locator(selector).first();
      const count = await element.count();
      console.log(`Trying selector "${selector}": found ${count} elements`);
      
      if (count > 0) {
        const isVisible = await element.isVisible().catch(() => false);
        console.log(`Element visible: ${isVisible}`);
        
        if (isVisible) {
          console.log(`Clicking element with selector: ${selector}`);
          await element.click();
          // Wait a bit for modal animation
          await page.waitForTimeout(1000);
          return;
        }
      }
    } catch (error) {
      console.log(`Error trying selector "${selector}":`, error);
    }
  }

  // If nothing worked, take a screenshot for debugging
  await page.screenshot({ path: 'debug-no-signup-button.png', fullPage: true });
  
  throw new Error(
    'Could not find signup button.\n' +
    'Available buttons: ' + JSON.stringify(availableButtons.slice(0, 15), null, 2) +
    '\nScreenshot saved to: debug-no-signup-button.png'
  );
}

/**
 * Opens the login/signin modal from any page
 * Tries multiple possible button texts and selectors
 */
export async function openLoginModal(page: Page): Promise<void> {
  // Debug available buttons
  const availableButtons = await page.locator('button, a').evaluateAll(els => 
    els.map(el => ({
      text: el.textContent?.trim(),
      className: el.className
    })).filter(item => item.text)
  );
  
  console.log('Available buttons for login:', JSON.stringify(availableButtons.slice(0, 15), null, 2));

  const loginSelectors = [
    'button:has-text("Iniciar sesión")',
    'button:has-text("Login")',
    'button:has-text("Entrar")',
    'button:has-text("Acceder")',
    'a:has-text("Iniciar sesión")',
    'a:has-text("Login")',
    'a:has-text("Acceder")',
    '[data-testid="login-link"]',
    '[data-testid="login-button"]',
    '[data-testid="signin-button"]',
    'text=/Iniciar sesión|Login|Entrar|Acceder/i'
  ];

  for (const selector of loginSelectors) {
    try {
      const element = page.locator(selector).first();
      const count = await element.count();
      console.log(`Trying login selector "${selector}": found ${count} elements`);
      
      if (count > 0) {
        const isVisible = await element.isVisible().catch(() => false);
        console.log(`Login element visible: ${isVisible}`);
        
        if (isVisible) {
          console.log(`Clicking login element with selector: ${selector}`);
          await element.click();
          await page.waitForTimeout(1000);
          return;
        }
      }
    } catch (error) {
      console.log(`Error trying login selector "${selector}":`, error);
    }
  }

  await page.screenshot({ path: 'debug-no-login-button.png', fullPage: true });
  
  throw new Error(
    'Could not find login button.\n' +
    'Available buttons: ' + JSON.stringify(availableButtons.slice(0, 15), null, 2) +
    '\nScreenshot saved to: debug-no-login-button.png'
  );
}

/**
 * Waits for the auth form to be visible in the modal
 */
export async function waitForAuthForm(page: Page, timeout: number = 20000): Promise<void> {
  await page.waitForSelector('input[type="email"]', { 
    state: 'visible',
    timeout 
  });
}

/**
 * Switches between signup and login within the auth modal
 * Most auth modals have a toggle between signup/login
 */
export async function switchToLogin(page: Page): Promise<void> {
  const switchSelectors = [
    'text=/Ya tienes cuenta|Iniciar sesión/i',
    'button:has-text("Iniciar sesión")',
    '[data-testid="switch-to-login"]'
  ];

  for (const selector of switchSelectors) {
    const element = page.locator(selector);
    if (await element.count() > 0) {
      await element.click();
      await page.waitForTimeout(500);
      return;
    }
  }
}

/**
 * Switches to signup within the auth modal
 */
export async function switchToSignup(page: Page): Promise<void> {
  const switchSelectors = [
    'text=/No tienes cuenta|Crear cuenta|Registrarse/i',
    'button:has-text("Crear cuenta")',
    '[data-testid="switch-to-signup"]'
  ];

  for (const selector of switchSelectors) {
    const element = page.locator(selector);
    if (await element.count() > 0) {
      await element.click();
      await page.waitForTimeout(500);
      return;
    }
  }
}

/**
 * Closes any open modal
 */
export async function closeModal(page: Page): Promise<void> {
  const closeSelectors = [
    '[aria-label="Close"]',
    'button[aria-label="Cerrar"]',
    '[data-testid="close-modal"]',
    'button:has-text("×")',
    'button:has-text("✕")'
  ];

  for (const selector of closeSelectors) {
    const element = page.locator(selector);
    if (await element.count() > 0 && await element.isVisible()) {
      await element.click();
      await page.waitForTimeout(500);
      return;
    }
  }

  // Fallback: try pressing Escape
  await page.keyboard.press('Escape');
  await page.waitForTimeout(500);
}

/**
 * Fills the signup form with provided data
 */
export async function fillSignupForm(
  page: Page, 
  email: string, 
  password: string,
  acceptPolicy: boolean = true
): Promise<void> {
  await page.fill('input[type="email"]', email);
  await page.fill('input[type="password"]', password);

  if (acceptPolicy) {
    // shadcn/ui checkboxes have a hidden input and a visible button
    // Try multiple approaches to find and click the policy checkbox
    try {
      // Approach 1: Find by role="checkbox" (shadcn/ui uses button with role="checkbox")
      const roleCheckbox = page.locator('[role="checkbox"]').first();
      if (await roleCheckbox.count() > 0) {
        const isChecked = await roleCheckbox.getAttribute('data-state');
        if (isChecked !== 'checked') {
          await roleCheckbox.click();
          await page.waitForTimeout(300);
        }
        return;
      }

      // Approach 2: Click the visible label text that contains policy/terms
      const policyLabel = page.locator('text=/acepto.*política|términos.*condiciones/i').first();
      if (await policyLabel.count() > 0) {
        await policyLabel.click();
        await page.waitForTimeout(300);
        return;
      }

      // Approach 3: Find any checkbox container/label
      const checkboxContainer = page.locator('[class*="checkbox"]').first();
      if (await checkboxContainer.count() > 0) {
        await checkboxContainer.click();
        await page.waitForTimeout(300);
        return;
      }

      console.log('Warning: Could not find policy checkbox, continuing anyway');
    } catch (error) {
      console.log('Could not check policy checkbox:', error);
      // Continue anyway - some forms might not require it
    }
  }
}

/**
 * Fills the login form with provided data
 */
export async function fillLoginForm(
  page: Page, 
  email: string, 
  password: string
): Promise<void> {
  await page.fill('input[type="email"]', email);
  await page.fill('input[type="password"]', password);
}

/**
 * Submits the auth form
 */
export async function submitAuthForm(page: Page): Promise<void> {
  await page.click('button[type="submit"]');
}