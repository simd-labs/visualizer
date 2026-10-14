import { test, expect } from '@playwright/test';
import { EXAMPLES } from '../src/examples.js';

// UX round 1, flow and timeline layout: the flow column is bounded, the
// timeline gets the rest, its pixels per cycle follow the box, the slider
// keeps the chart cursor and itself on screen, and side-by-side starts only
// when the timeline box keeps at least 700px.

const HEADER = 48; // .header height
const SIZES = [
  [1920, 1080],
  [1600, 900],
  [1366, 768],
  [960, 1080],
  [800, 900],
];
const SIDE_BY_SIDE = (w) => w >= 1400;

// znver4's example loop at 100 iterations, slider mid-run.
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

const geom = () => {
  const flow = document.getElementById('flow');
  const tl = document.getElementById('timeline');
  const bar = document.querySelector('.cycle-bar');
  const fr = flow.getBoundingClientRect();
  const tr = tl.getBoundingClientRect();
  const g = [...document.querySelectorAll('#timeline svg line.grid')];
  return {
    flowW: Math.round(fr.width),
    flowPanelW: flow.closest('.panel').clientWidth,
    flowH: Math.round(fr.height),
    flowBottom: Math.round(fr.bottom + scrollY),
    tlClientW: tl.clientWidth,
    tlScrollW: tl.scrollWidth,
    tlH: Math.round(tr.height),
    barTop: Math.round(bar.getBoundingClientRect().top),
    barH: Math.round(bar.getBoundingClientRect().height),
    cell: g.length > 1 ? (+g.at(-1).getAttribute('x1') - +g[0].getAttribute('x1')) / (g.length - 1) / 5 : 14,
    sideBySide:
      Math.abs(flow.closest('.panel').getBoundingClientRect().top - tl.closest('.panel').getBoundingClientRect().top) < 5,
    minFlowText: Math.min(...[...flow.querySelectorAll('text')].map((t) => +t.getAttribute('font-size') || 99)),
  };
};

for (const [w, h] of SIZES) {
  test.describe(`${w}x${h}`, () => {
    test.beforeEach(async ({ page }) => {
      await page.setViewportSize({ width: w, height: h });
      await runExample(page);
    });

    // Breakpoint: side by side only from 1400px; the flow text stays >= 12px
    // there (the bounded column is >= the 734px the diagram uses at 95%).
    test('breakpoint and P2: the flow column is bounded, the timeline takes the rest', async ({ page }) => {
      const m = await page.evaluate(geom);
      expect(m.sideBySide, `sideBySide at ${w}`).toBe(SIDE_BY_SIDE(w));
      if (m.sideBySide) {
        expect(m.flowPanelW, 'flow column').toBeLessThanOrEqual(736);
        expect(m.tlClientW, 'timeline width').toBeGreaterThanOrEqual(700);
        expect(m.minFlowText, 'flow text at 95% scale').toBeGreaterThanOrEqual(12);
      } else {
        // stacked: the timeline is full width below the flow
        expect(m.tlClientW, 'stacked timeline width').toBeGreaterThanOrEqual(w - 90);
      }
      if (w === 1920) expect(m.tlClientW, 'timeline >= 1000px at 1920').toBeGreaterThanOrEqual(1000);
    });

    // P3: px per cycle follows the box; a run that fits shrinks toward the
    // 12px floor, one that cannot keeps the full 14px column and scrolls.
    test('P3: the timeline fits the box or scrolls at a readable cell', async ({ page }) => {
      const m = await page.evaluate(geom);
      expect(m.cell, 'px per cycle').toBeGreaterThanOrEqual(12);
      if (m.cell <= 14) {
        expect(m.tlScrollW, `scrollWidth ${m.tlScrollW} vs clientWidth ${m.tlClientW} at cell ${m.cell}`).toBeLessThanOrEqual(m.tlClientW + 1);
      } else {
        // below the floor the run gets a wider slab and scrolls
        expect(m.tlScrollW).toBeGreaterThan(m.tlClientW);
      }
    });
  });

  // P5: stacked, the cycle bar is sticky and the slider stays on screen while
  // the timeline is in view; the bar never covers the cursor row.
  if (!SIDE_BY_SIDE(w)) {
    test(`P5: ${w}x${h}`, async ({ page }) => {
      await runExample(page);
      const m = await page.evaluate(() => {
        const tl = document.getElementById('timeline');
        tl.scrollIntoView({ block: 'center' });
        const bar = document.querySelector('.cycle-bar');
        const barR = bar.getBoundingClientRect();
        const tlR = tl.getBoundingClientRect();
        const sliderR = document.querySelector('#flow-cycle').getBoundingClientRect();
        const svgTop = tl.querySelector('svg').getBoundingClientRect().top;
        return {
          pos: getComputedStyle(bar).position,
          barTop: Math.round(barR.top),
          tlTop: Math.round(tlR.top), tlBottom: Math.round(tlR.bottom),
          sliderTop: Math.round(sliderR.top), sliderBottom: Math.round(sliderR.bottom),
          svgTop: Math.round(svgTop), vh: innerHeight,
        };
      });
      expect(m.pos).toBe('sticky');
      expect(m.barTop, 'bar parked at the sticky top').toBeGreaterThanOrEqual(HEADER);
      // the slider (its row) stays on screen while the timeline is in view
      expect(m.sliderBottom, 'slider on screen').toBeLessThanOrEqual(m.vh);
      expect(m.sliderTop, 'slider on screen').toBeGreaterThanOrEqual(HEADER - 1);
      // the bar parks under the header; with the timeline scrolled to center
      // the bar's slot sits above it, so the bar keeps the timeline top, not
      // the chart under the box, hidden
      expect(m.barTop, 'bar above the timeline box').toBeLessThanOrEqual(m.tlTop);
    });
  }
}

// P4: playing or stepping keeps the chart cursor inside the box's visible span.
// 500px: znver4's run needs 45x12=686px for the chart; the 416px box cannot
// show it, so a working scroll-to-cursor is the only way the last cycle lands
// in view.
test('P4: the chart cursor stays in view at the last cycle', async ({ page }) => {
  await page.setViewportSize({ width: 500, height: 900 });
  await runExample(page);
  await expect
    .poll(
      async () =>
        page.evaluate(() => {
          const s = document.querySelector('#flow-cycle');
          s.value = s.max;
          s.dispatchEvent(new Event('input', { bubbles: true }));
          const cur = document.querySelector('#timeline line.flow-cur');
          const box = document.getElementById('timeline');
          const x = +cur.getAttribute('x1');
          return x - box.scrollLeft >= 0 && x - box.scrollLeft <= box.clientWidth;
        }),
      { timeout: 5000, message: 'cursor stays inside the visible span' }
    )
    .toBe(true);
});

// P3 on sifive-u74 at 1920: the longest run still fits the wide box.
test('P3: sifive-u74 at 1920 fits its box without sideways scroll', async ({ page }) => {
  await page.setViewportSize({ width: 1920, height: 1080 });
  await runExample(page, 'sifive-u74');
  const m = await page.evaluate(geom);
  expect(m.tlScrollW, `scrollWidth ${m.tlScrollW} vs clientWidth ${m.tlClientW}`).toBeLessThanOrEqual(m.tlClientW + 1);
});
