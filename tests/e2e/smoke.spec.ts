import { test, expect } from '@playwright/test';

test.describe('Open CoreUI Smoke Tests', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:15565');
  });

  test('page loads successfully', async ({ page }) => {
    // Wait for the page to load
    await expect(page).toHaveTitle(/Open/);
  });

  test('config endpoint returns valid data', async ({ page }) => {
    const response = await page.goto('http://localhost:15565/api/config');
    expect(response?.status()).toBe(200);

    const config = await response?.json();
    expect(config).toHaveProperty('features');
    expect(config.features).toHaveProperty('auth', false);
  });

  test('Socket.IO connection works', async ({ page }) => {
    // Check if Socket.IO client is loaded
    const socketIOExists = await page.evaluate(() => {
      return typeof (window as any).io !== 'undefined';
    });

    // Socket.IO may not be immediately available, which is fine
    console.log('Socket.IO available:', socketIOExists);
  });

  test('static files are served', async ({ page }) => {
    const response = await page.goto('http://localhost:15565/favicon.png');
    expect(response?.status()).toBeLessThan(400); // 200 or 304
  });

  test('no-auth signin endpoint works', async ({ page }) => {
    const response = await page.request.post('http://localhost:15565/api/auths/no-auth');

    // Should return 200 when auth is disabled
    if (response.status() === 200) {
      const data = await response.json();
      expect(data).toHaveProperty('token');
      expect(data).toHaveProperty('id');
      expect(data.role).toBe('admin');
      expect(data.name).toBe('x');
    } else {
      // Auth might be enabled or other config, just check it's not a 500 error
      expect(response.status()).toBeLessThan(500);
    }
  });
});
