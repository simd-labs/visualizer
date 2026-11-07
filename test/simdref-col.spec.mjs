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
  // Wait for the column to render its cells. The live values may still be
  // resolving, and their length and the host font vary, so the test sets its
  // own long value and a narrow column to make one cell cut off for sure.
  await expect
    .poll(
      () => page.evaluate(() => document.querySelectorAll('#simdref-col .simdref-val').length),
      { timeout: 60000 }
    )
    .toBeGreaterThan(0);
  const full = 'a'.repeat(200);
  await page.addStyleTag({ content: '#simdref-col { width: 60px !important; }' });
  await page.evaluate((v) => {
    const c = document.querySelector('#simdref-col .simdref-val');
    c.textContent = v;
    c.setAttribute('title', v);
  }, full);
  const cell = page.locator('#simdref-col .simdref-val').first();
  await cell.hover();
  const hit = await page.evaluate((v) => {
    const c = document.querySelector('#simdref-col .simdref-val');
    const r = c.getBoundingClientRect();
    const el = document.elementFromPoint(r.left + r.width / 2, r.top + r.height / 2);
    return { isCell: el === c, title: el ? el.getAttribute('title') : null, cut: c.scrollWidth > c.clientWidth };
  }, full);
  expect(hit.cut, 'the long value is cut off in the narrow column').toBe(true);
  expect(hit.isCell, 'the element under the pointer is the cell').toBe(true);
  expect(hit.title, 'the title carries the full value').toBe(full);
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
