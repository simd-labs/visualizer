// UX merge, editor collapse (assessment proposal 1): after a successful Run
// the editor parks on a one-line summary so the cycle bar and results fill
// the first screen. The summary names the run's CPU, line count and first
// line; the Edit button (or any new input) brings the box back. With the
// editor collapsed, the lift workaround (stickyCycleBarTop) is gone: the
// sticky bar just parks under the header at every width.
import { test, expect } from '@playwright/test';
import { EXAMPLES } from '../src/examples.js';

async function runExample(page, cpu = 'znver4') {
  await page.goto('/');
  await page.locator('#asm').fill(EXAMPLES.x86_64);
  await page.locator('#cpu').selectOption(cpu);
  await expect(page.locator('#run')).toBeEnabled({ timeout: 60000 });
  await page.locator('#run').click();
  await expect(page.locator('#run')).toHaveText('Run', { timeout: 60000 });
  await expect(page.locator('#flow svg')).toHaveCount(1);
  await page.evaluate(() => {
    const s = document.querySelector('#flow-cycle');
    s.value = String(Math.floor(Number(s.max) / 2));
    s.dispatchEvent(new Event('input', { bubbles: true }));
  });
}

const collapsedH = (page) =>
  page.evaluate(() => Math.round(document.getElementById('asm-wrap').getBoundingClientRect().height));

test('Run collapses the editor to a one-line summary with the run details', async ({ page }) => {
  await page.setViewportSize({ width: 1920, height: 1080 });
  await runExample(page);
  // the wrap parks on a 1px invisible box (kept fillable for scripted input)
  expect(await collapsedH(page)).toBeLessThanOrEqual(2);
  expect(await page.evaluate(() => document.getElementById('asm-wrap').hidden)).toBe(true);
  await expect(page.locator('#asm-summary')).toBeVisible();
  await expect(page.locator('#asm-summary-text')).toContainText('znver4');
  await expect(page.locator('#asm-summary-text')).toContainText(`${EXAMPLES.x86_64.split('\n').length} lines`);
  await expect(page.locator('#asm-summary-text')).toContainText(EXAMPLES.x86_64.split('\n').find((l) => l.trim() !== '').trim());
  const edit = page.locator('#asm-edit');
  await expect(edit).toBeVisible();
  await expect(edit).toHaveAttribute('aria-expanded', 'false');
  await expect(edit).toHaveAttribute('aria-controls', 'asm-wrap');
});

test('the Edit button expands the editor, keyboard-operable', async ({ page }) => {
  await page.setViewportSize({ width: 1920, height: 1080 });
  await runExample(page);
  await page.locator('#asm-edit').focus();
  await page.keyboard.press('Enter');
  expect(await collapsedH(page)).toBeGreaterThan(50);
  await expect(page.locator('#asm-summary')).toBeHidden();
  await expect(page.locator('#asm-edit')).toHaveAttribute('aria-expanded', 'true');
  await expect(page.locator('#asm')).toBeFocused();
});

test('typing, a CPU example swap, or a scripted fill expands the collapsed editor', async ({ page }) => {
  await page.setViewportSize({ width: 1920, height: 1080 });
  await runExample(page);
  // a CPU change while collapsed keeps the summary and refreshes the CPU
  await page.locator('#cpu').selectOption('neoverse-v2');
  expect(await collapsedH(page)).toBeLessThanOrEqual(2);
  await expect(page.locator('#asm-summary-text')).toContainText('neoverse-v2');
  // Edit expands
  await page.locator('#asm-edit').click();
  expect(await collapsedH(page)).toBeGreaterThan(50);
  // collapse again with a fresh Run, then a scripted fill expands
  await page.locator('#run').click();
  await expect.poll(() => collapsedH(page)).toBeLessThanOrEqual(2);
  await page.locator('#asm').fill('ret');
  expect(await collapsedH(page)).toBeGreaterThan(50);
  await expect(page.locator('#asm-summary')).toBeHidden();
  // collapse once more on that fill's Run: 'ret' is valid asm
  await page.locator('#run').click();
  await expect(page.locator('#flow svg')).toHaveCount(1);
  await expect.poll(() => collapsedH(page)).toBeLessThanOrEqual(2);
  await expect(page.locator('#asm-summary-text')).toContainText('neoverse-v2');
  await expect(page.locator('#asm-summary-text')).toContainText('1 lines');
});

// Proposal 1's pass check: after Run, the cycle bar sits under the header
// and the flow panel starts on the first screen. (The whole 43-cycle flow
// diagram is taller than any 16:9 viewport, so the panel's top edge is what
// the collapse controls; the side-by-side panel heights are audit material.)
for (const [w, h] of [[1920, 1080], [1600, 900]]) {
  test(`after Run at ${w}x${h} the bar parks under the header, the flow starts on screen`, async ({ page }) => {
    await page.setViewportSize({ width: w, height: h });
    await runExample(page);
    const m = await page.evaluate(() => {
      const bar = document.querySelector('.cycle-bar').getBoundingClientRect();
      const flow = document.getElementById('flow').closest('.panel').getBoundingClientRect();
      const svg = document.querySelector('#flow svg').getBoundingClientRect();
      return { barTop: Math.round(bar.top), flowPanelTop: Math.round(flow.top), svgTop: Math.round(svg.top) };
    });
    expect(m.barTop, `bar top at ${w}x${h}`).toBeLessThanOrEqual(150);
    expect(m.barTop, `bar under the header at ${w}x${h}`).toBeGreaterThanOrEqual(47);
    expect(m.flowPanelTop, `flow panel top at ${w}x${h}`).toBeLessThanOrEqual(260);
    expect(m.svgTop, `flow diagram visible on the first screen ${w}x${h}`).toBeLessThanOrEqual(h - 100);
  });
}

// Stacked check: no lifted gap below the bar (the bar's sticky slot sits
// right in #out's flow), the slider row stays on screen with the timeline
// scrolled into view, and the bar never covers the chart top.
for (const [w, h] of [[960, 1080], [800, 900]]) {
  test(`stacked at ${w}x${h}: bar on screen, no gap, cursor row uncovered`, async ({ page }) => {
    await page.setViewportSize({ width: w, height: h });
    await runExample(page);
    const m = await page.evaluate(() => {
      const tl = document.getElementById('timeline');
      tl.scrollIntoView({ block: 'center' });
      const bar = document.querySelector('.cycle-bar');
      const barR = bar.getBoundingClientRect();
      const tlR = tl.getBoundingClientRect();
      const svgTop = tl.querySelector('svg').getBoundingClientRect().top;
      return {
        inlineTop: getComputedStyle(bar).top,
        barTop: Math.round(barR.top),
        barBottom: Math.round(barR.bottom),
        tlBottom: Math.round(tlR.bottom),
        svgTop: Math.round(svgTop),
        vh: innerHeight,
      };
    });
    expect(m.inlineTop, 'no inline lift: the CSS top stands').toBe('48px');
    expect(m.barTop, 'bar visible under the header').toBeGreaterThanOrEqual(47);
    expect(m.barTop, 'bar on screen').toBeLessThanOrEqual(150);
    // the bar ends in view and the chart top is not under it (no cover)
    expect(m.barBottom, 'bar bottom on screen').toBeLessThanOrEqual(m.vh);
    const covered = m.svgTop < m.barBottom && m.barBottom <= m.tlBottom;
    expect(covered, `bar bottom ${m.barBottom} over chart top ${m.svgTop}`).toBe(false);
  });
}
