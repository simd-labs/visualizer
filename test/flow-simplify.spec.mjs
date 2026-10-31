// The S2 wait cells, wait column and unit busy bars: the hatched cells of
// each timeline row equal its issue-minus-dispatch cycles, each unit's busy
// percent matches its issue events, and the 16 accumulators of
// reduction-16acc drive the FP pipes measurably higher than the single
// accumulator of reduction-1acc.
import { test, expect } from '@playwright/test';
import { readFileSync } from 'node:fs';
import { run } from '../wasm/run.mjs';
import { buildModel, unitBusy } from '../src/model.js';
import { EXAMPLES } from '../src/examples.js';

const FIXED = 'znver4';
const runJson = (source, args) => JSON.parse(run(source, args).stdout);

// znver4's example loop at 100 iterations, from the page's own inputs.
async function runExample(page) {
  await page.goto('/');
  await page.locator('#asm').fill(EXAMPLES.x86_64);
  await page.locator('#cpu').selectOption(FIXED);
  await expect(page.locator('#run')).toBeEnabled({ timeout: 120000 });
  await page.locator('#run').click();
  await expect(page.locator('#run')).toHaveText('Run', { timeout: 120000 });
  await expect(page.locator('#timeline svg')).toHaveCount(1);
}

test('each row: hatched cells equal issue minus dispatch, and the wait column equals both', async ({ page }) => {
  await runExample(page);
  const model = buildModel(runJson(EXAMPLES.x86_64, ['-mtriple=x86_64-unknown-linux-gnu', '-mcpu=znver4', '-iterations=100', '-timeline', '-json', '-issue-events']));
  // the drawn cell width, from the axis grid's tick spacing
  const cell = await page.evaluate(() => {
    const g = [...document.querySelectorAll('#timeline svg line.grid')];
    return (+g.at(-1).getAttribute('x1') - +g[0].getAttribute('x1')) / (g.length - 1) / 5;
  });
  // the wait column: values per row, in row order, pinned at the box's right edge
  const waits = await page.locator('#wait-col .wait-val').evaluateAll((els) => els.map((e) => +e.textContent));
  expect(waits.length).toBe(model.rows.length);
  // hatched wait cells per row, from the rects: one hatched rect per row,
  // its width in cells must equal the row's wait
  const rects = await page.locator('#timeline svg > rect[fill]').evaluateAll((els) =>
    els.map((r) => ({ fill: r.getAttribute('fill'), width: +r.getAttribute('width'), y: +r.getAttribute('y') }))
  );
  const hatched = rects.filter((r) => r.fill.startsWith('url(#hatch-wait')).sort((a, b) => a.y - b.y);
  expect(hatched.length).toBe(model.rows.length);
  let sawWait = 0;
  model.rows.forEach((r, i) => {
    const want = r.issued - r.dispatched;
    sawWait += want;
    expect(waits[i], `row ${i} wait column`).toBe(want);
    expect(Math.round(hatched[i].width / cell), `row ${i} hatched cells`).toBe(want);
  });
  expect(sawWait, 'no waiting cycles in the example run').toBeGreaterThan(0);
  // the longest is bold unless it is 0
  const bold = await page.locator('#wait-col .wait-val').evaluateAll((els) => els.map((e) => getComputedStyle(e).fontWeight));
  const longest = Math.max(...waits);
  waits.forEach((w, i) => {
    if (longest > 0 && w === longest) expect(+bold[i], `row ${i} longest bold`).toBeGreaterThanOrEqual(700);
  });
});

test('one busy bar per unit, and each percent matches the unit\'s issue events within 1 point', async ({ page }) => {
  await runExample(page);
  const model = buildModel(runJson(EXAMPLES.x86_64, ['-mtriple=x86_64-unknown-linux-gnu', '-mcpu=znver4', '-iterations=100', '-timeline', '-json', '-issue-events']));
  const want = unitBusy(model);
  expect(want, 'the example run has issue events').not.toBeNull();
  const rows = await page.locator('#busy .busy-row').evaluateAll((els) =>
    els.map((r) => ({ unit: +r.dataset.unit, pct: +r.querySelector('.busy-val').textContent.replace('%', '') }))
  );
  expect(rows.length).toBe(model.resources.length);
  rows.forEach((row, i) => {
    expect(row.unit, `row ${i} unit`).toBe(want[i].unit);
    expect(Math.abs(row.pct - want[i].pct), `unit ${row.unit} busy %`).toBeLessThanOrEqual(1);
  });
});

for (const [file, cpi] of [['examples/reduction-1acc.s', '3.10'], ['examples/reduction-16acc.s', '8.12']]) {
  test(`${file}: the header shows cycles per iteration ${cpi} at 100 iterations`, async ({ page }) => {
    await page.goto('/');
    await expect(page.locator('#run')).toBeEnabled({ timeout: 120000 });
    await page.locator('#cpu').selectOption(FIXED);
    await page.locator('#file').setInputFiles(file);
    await expect(page.locator('#run')).toHaveText('Run', { timeout: 120000 });
    await expect(page.locator('#run-stats')).toContainText(`${cpi} c/iter`);
    await expect(page.locator('#run-stats')).toContainText('IPC');
  });
}

test('16acc drives the FP pipes higher than 1acc on znver4', async ({ page }) => {
  const ARGS = ['-mtriple=x86_64-unknown-linux-gnu', '-mcpu=znver4', '-iterations=100', '-timeline', '-json', '-issue-events'];
  const j1 = runJson(readFileSync('examples/reduction-1acc.s', 'utf8'), ARGS);
  const j16 = runJson(readFileSync('examples/reduction-16acc.s', 'utf8'), ARGS);
  const one = unitBusy(buildModel(j1));
  const many = unitBusy(buildModel(j16));
  // FP units are the run-json's Zn4FP* resources; 16acc keeps them at ~100%
  // while 1acc leaves them idle for most of the run
  const fp = one.map((_, u) => u).filter((u) => /^Zn4FP/.test(j1.TargetInfo.Resources[u]));
  expect(fp.length).toBeGreaterThan(0);
  expect(Math.max(...fp.map((u) => many[u].pct)), '16acc peak FP busy').toBeGreaterThan(90);
  expect(Math.max(...fp.map((u) => one[u].pct)), '1acc peak FP busy').toBeLessThan(50);

  // the same contrast is visible on the page: the 16acc FP bars sit higher
  const vals = async (file) => {
    await page.goto('/');
    await expect(page.locator('#run')).toBeEnabled({ timeout: 120000 });
    await page.locator('#cpu').selectOption(FIXED);
    await page.locator('#file').setInputFiles(file);
    // a file pick queues the run: #run still reads 'Run' until it starts, so
    // text alone passes on the previous state; the result panel is the signal
    await expect(page.locator('#out')).toBeVisible({ timeout: 120000 });
    await expect(page.locator('#run')).toHaveText('Run', { timeout: 120000 });
    return page.locator('#busy .busy-row').evaluateAll((els) =>
      Object.fromEntries(els.map((r) => [+r.dataset.unit, +r.querySelector('.busy-val').textContent.replace('%', '')]))
    );
  };
  const v1 = await vals('examples/reduction-1acc.s');
  const v16 = await vals('examples/reduction-16acc.s');
  for (const u of fp) expect(v16[u] ?? 0, `FP unit ${u} bar`).toBeGreaterThanOrEqual(v1[u] ?? 0);
  expect(Math.max(...fp.map((u) => v16[u] ?? 0)), '16acc FP bar peak on the page').toBeGreaterThan(90);
  expect(Math.max(...fp.map((u) => v1[u] ?? 0)), '1acc FP bar peak on the page').toBeLessThan(50);
});
