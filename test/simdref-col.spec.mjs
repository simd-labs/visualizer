import { test, expect } from '@playwright/test';
import { EXAMPLES } from '../src/examples.js';

// A simdref column cell can be cut off by the 300px column. The cell
// ellipsizes, and its title keeps the full value.

test('a simdref cell keeps its full value in the title', async ({ page }) => {
  await page.setViewportSize({ width: 1280, height: 900 });
  await page.goto('/');
  await page.locator('#asm').fill(EXAMPLES.x86_64);
  await page.locator('#cpu').selectOption('znver4');
  await expect(page.locator('#run')).toBeEnabled({ timeout: 60000 });
  await page.locator('#run').click();
  await expect(page.locator('#run')).toHaveText('Run', { timeout: 60000 });
  // The cells hold '…' while the values resolve from the live simdref data.
  await expect
    .poll(
      () =>
        page.evaluate(() => {
          const vals = [...document.querySelectorAll('#simdref-col .simdref-val')];
          return vals.length > 0 && !vals.every((c) => c.textContent === '…');
        }),
      { timeout: 60000 }
    )
    .toBe(true);
  const m = await page.evaluate(() => {
    const vals = [...document.querySelectorAll('#simdref-col .simdref-val')];
    return {
      n: vals.length,
      titled: vals.every((c) => c.getAttribute('title') === c.textContent),
      ellipsized: vals.every((c) => getComputedStyle(c).textOverflow === 'ellipsis'),
    };
  });
  expect(m.n, 'cells with a title').toBeGreaterThan(0);
  expect(m.titled, 'every title holds the full text').toBe(true);
  expect(m.ellipsized, 'every cell can ellipsize').toBe(true);
});
