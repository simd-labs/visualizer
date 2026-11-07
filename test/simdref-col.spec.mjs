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

// The column is pointer-events: none so the timeline below keeps its events.
// The cells take pointer events back, so a cut-off value reads on hover: the
// element under the pointer is the cell, and its title is the full value.
test('hovering a cut-off simdref cell exposes its full value', async ({ page }) => {
  await page.setViewportSize({ width: 1280, height: 900 });
  await page.goto('/');
  await page.locator('#asm').fill(EXAMPLES.aarch64);
  await page.locator('#cpu').selectOption('neoverse-v2');
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
      { timeout: 120000 }
    )
    .toBe(true);
  // Whether a value overflows the 300px column depends on the test host's
  // monospace font, so narrow the column to cut a long value off for sure.
  await page.addStyleTag({ content: '#simdref-col { width: 60px !important; }' });
  const idx = await page.evaluate(() => {
    const vals = [...document.querySelectorAll('#simdref-col .simdref-val')];
    return vals.findIndex((c) => c.scrollWidth > c.clientWidth);
  });
  expect(idx, 'a long value is cut off in the narrow column').toBeGreaterThanOrEqual(0);
  const cell = page.locator('#simdref-col .simdref-val').nth(idx);
  await cell.hover();
  const hit = await page.evaluate((i) => {
    const c = document.querySelectorAll('#simdref-col .simdref-val')[i];
    const r = c.getBoundingClientRect();
    const el = document.elementFromPoint(r.left + r.width / 2, r.top + r.height / 2);
    return { isCell: el === c, title: el ? el.getAttribute('title') : null, full: c.getAttribute('title') };
  }, idx);
  expect(hit.isCell, 'the element under the pointer is the cell').toBe(true);
  expect(hit.title, 'the title carries the full value').toBe(hit.full);
  expect(hit.full, 'the value is longer than the column').toBeTruthy();
});

// The cells sit over the timeline's right strip, which has no clickable
// control. The row labels on the left keep their hover, so the column must
// not swallow the timeline's events.
test('the timeline row hover is not blocked by the simdref column', async ({ page }) => {
  await page.setViewportSize({ width: 1280, height: 900 });
  await page.goto('/');
  await page.locator('#asm').fill(EXAMPLES.aarch64);
  await page.locator('#cpu').selectOption('neoverse-v2');
  await expect(page.locator('#run')).toBeEnabled({ timeout: 60000 });
  await page.locator('#run').click();
  await expect(page.locator('#run')).toHaveText('Run', { timeout: 60000 });
  await expect
    .poll(
      () =>
        page.evaluate(() => {
          const vals = [...document.querySelectorAll('#simdref-col .simdref-val')];
          return vals.length > 0 && !vals.every((c) => c.textContent === '…');
        }),
      { timeout: 120000 }
    )
    .toBe(true);
  const row = page.locator('#timeline svg text.row').first();
  await row.hover();
  await expect(page.locator('#asm-gutter .hl')).toHaveCount(1);
});
