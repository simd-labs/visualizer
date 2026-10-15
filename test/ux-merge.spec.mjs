// UX merge: after Run the sticky cycle bar parks under the header and the
// flow starts on the first screen; stacked, the bar stays on screen with the
// timeline in view.
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

// After Run, the cycle bar sits under the header and the flow panel starts
// on the first screen.
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
