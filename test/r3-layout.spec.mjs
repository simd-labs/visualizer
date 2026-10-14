import { test, expect } from '@playwright/test';
import { EXAMPLES } from '../src/examples.js';

const EXAMPLE_ASM = EXAMPLES.x86_64;

// znver4's example loop at 100 iterations: a run with issue events.
async function runExample(page) {
  await page.goto('/');
  await page.locator('#asm').fill(EXAMPLE_ASM);
  await page.locator('#cpu').selectOption('znver4');
  await page.locator('#iterations').fill('100');
  await expect(page.locator('#run')).toBeEnabled({ timeout: 60000 });
  await page.locator('#run').click();
  await expect(page.locator('#run')).toHaveText('Run', { timeout: 60000 });
  await expect(page.locator('#out')).toBeVisible();
  await expect(page.locator('#flow svg')).toHaveCount(1);
}

// Defect b1: the cycle slider reads its value and max beside it, synced while
// stepping.
test('cycle slider shows "cycle N of M" next to it and stays in sync', async ({ page }) => {
  await runExample(page);
  const out = page.locator('#flow-cycle-value');
  const max = await page.locator('#flow-cycle').getAttribute('max');
  await expect(out).toHaveText(`cycle 0 of ${max}`);
  await page.locator('#flow-cycle').fill('17');
  await page.locator('#flow-cycle').dispatchEvent('input');
  await expect(out).toHaveText(`cycle 17 of ${max}`);
  await page.locator('#flow-step').click();
  await expect(out).toHaveText(`cycle 18 of ${max}`);
});

// Defect b16: the last axis tick is at or past the last retired cycle, and no
// bar runs to the panel's right edge past it.
test('timeline axis covers the last cycle and bars stay behind the last tick', async ({ page }) => {
  await runExample(page);
  const r = await page.evaluate(() => {
    const svg = document.querySelector('#timeline svg');
    const rects = [...svg.querySelectorAll(':scope > rect')];
    const lastBarX = Math.max(...rects.map((x) => +x.getAttribute('x') + +x.getAttribute('width')));
    const lastRetired = Math.max(...rects.map((x) => (+x.getAttribute('x') - 200) / 14 + +x.getAttribute('width') / 14)); // LEFT=200, CELL=14
    const ticks = [...svg.querySelectorAll('text.axis')].map((t) => +t.textContent);
    const lastTick = Math.max(...ticks);
    const ctm = svg.getScreenCTM();
    const barEnd = ctm.a * lastBarX + ctm.e;
    const panelRight = document.getElementById('timeline').closest('.panel').getBoundingClientRect().right;
    return { lastRetired, lastTick, minTick: Math.min(...ticks), gap: panelRight - barEnd };
  });
  expect(r.lastTick).toBeGreaterThanOrEqual(Math.floor(r.lastRetired));
  expect(r.lastTick % 5 === 0 || r.lastTick === Math.floor(r.lastRetired)).toBe(true);
  expect(r.minTick).toBe(0);
  expect(r.gap).toBeGreaterThan(0); // nothing touches the panel edge
});

// Defect b2: the caption names every shown iteration, and rows for all of
// them exist, and the box scrolls to reach them.
test('timeline caption and chart agree: visible range named, rest reachable by scroll', async ({ page }) => {
  await runExample(page);
  const notice = await page.locator('#notice').textContent();
  expect(notice).toContain('scroll');
  const r = await page.evaluate(() => {
    const iters = new Set([...document.querySelectorAll('#timeline svg text.row')].map((t) => +/^(\d+):/.exec(t.textContent)[1]));
    const box = document.getElementById('timeline');
    return { maxIter: Math.max(...iters), minIter: Math.min(...iters), scrolls: box.scrollHeight > box.clientHeight };
  });
  const m = /Showing iterations (\d+)-(\d+) of (\d+)/.exec(notice);
  expect(m).toBeTruthy();
  expect(r.minIter).toBe(+m[1]);
  expect(r.maxIter).toBe(+m[2]);
  expect(+m[3]).toBe(100);
  expect(r.maxIter).toBeLessThan(+m[3] - 1);
  expect(r.scrolls).toBe(true);
});

// Defect b4: the pressure scale is a labelled line outside the column grid,
// not a bare-number column header with a swatch.
test('heatmap scale is labelled and outside the column grid', async ({ page }) => {
  await runExample(page);
  const r = await page.evaluate(() => {
    const texts = [...document.querySelectorAll('#heatmap svg text')];
    const scale = texts.find((t) => /^pressure per iteration: 0 to /.test(t.textContent));
    const cols = texts.filter((t) => t.classList.contains('col'));
    // no column header is a bare number
    const bareNumber = cols.filter((t) => /^\d/.test(t.textContent.trim())).length;
    return { scale: scale?.textContent ?? null, bareNumber, hasSwatchCol: !!document.querySelector('#heatmap svg rect:not([data-cy])') };
  });
  expect(r.scale).toBeTruthy();
  expect(r.bareNumber).toBe(0);
  expect(r.hasSwatchCol).toBe(false);
});

// Round-4 defect (znver4, skylake): every non-zero heatmap cell shows its
// value, equal to the JSON/model value rounded the same way the cell renders
// it. The 32px omission at HCELL made ALU0-ALU3 and memory cells blank.
test('every non-zero heatmap cell prints its value', async ({ page }) => {
  for (const cpu of ['znver4', 'skylake']) {
    await page.goto('/');
    await page.locator('#asm').fill(EXAMPLE_ASM);
    await page.locator('#cpu').selectOption(cpu);
    await page.locator('#iterations').fill('100');
    await expect(page.locator('#run')).toBeEnabled({ timeout: 60000 });
    await page.locator('#run').click();
    await expect(page.locator('#run')).toHaveText('Run', { timeout: 60000 });
    await expect(page.locator('#heatmap svg')).toHaveCount(1);

    const report = await page.evaluate(() => {
      // model values from the text table: same numbers, full precision.
      const tbl = document.querySelector('#heatmap-table table');
      const rows = [...tbl.querySelectorAll('tr')].slice(1).map((tr) => [...tr.children].map((td) => td.textContent));
      const svg = document.querySelector('#heatmap svg');
      const fmt = (v) => +v.toFixed(2); // same rounding renderHeatmap applies
      const missing = [];
      const wrong = [];
      for (const rect of svg.querySelectorAll('rect[data-cy]')) {
        const [i, j] = rect.dataset.cy.split(',').map(Number);
        const v = parseFloat(rows[i][j + 1]);
        if (v === 0) continue;
        const x = +rect.getAttribute('x') + +rect.getAttribute('width') / 2;
        const y = +rect.getAttribute('y') + +rect.getAttribute('height') / 2;
        // find a text element covering the cell centre
        const t = [...svg.querySelectorAll('text.heat-val')].find(
          (ln) => +ln.getAttribute('x') === x && Math.abs(+ln.getAttribute('y') - y) <= 2
        );
        if (!t) {
          missing.push({ i, j, v });
          continue;
        }
        // renderHeatmap prints fmt(v) if it fits, then drops a decimal; the
        // displayed text equals the model value rounded to at most 2 decimals.
        const ok = [0, 1, 2].map((d) => String(+v.toFixed(d))).includes(t.textContent);
        if (!ok) wrong.push({ i, j, v, shown: t.textContent });
      }
      return { missing, wrong };
    });
    expect(report.missing, `${cpu}: cells with no visible value`).toEqual([]);
    expect(report.wrong, `${cpu}: cells whose visible value is wrong`).toEqual([]);
  }
});
