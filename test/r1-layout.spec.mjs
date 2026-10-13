import { test, expect } from '@playwright/test';
import { readFileSync } from 'node:fs';
import { EXAMPLES } from '../src/examples.js';

const EXAMPLE_ASM = EXAMPLES.x86_64;

// znver4's example loop at 100 iterations: a run with issue events, the heatmap
// cells below and the timeline tall enough to need its own box.
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

// Every text glyph in the timeline and the heatmap keeps at least `min` px of
// screen height: font size times the SVG's own scale. The Haiku audit measured
// 8-9px labels at 800px.
for (const [width, min] of [[800, 10], [1400, 12]]) {
  test(`${width}px: timeline and heatmap SVG text renders at least ${min}px tall`, async ({ page }) => {
    await page.setViewportSize({ width, height: 900 });
    await runExample(page);
    const small = await page.evaluate((min) => {
      const out = [];
      let n = 0;
      for (const t of document.querySelectorAll('#timeline svg text, #heatmap svg text')) {
        if (!t.textContent) continue;
        n++;
        const m = t.getScreenCTM();
        const h = parseFloat(getComputedStyle(t).fontSize) * Math.hypot(m.c, m.d);
        if (h < min - 0.01) out.push(`"${t.textContent}" ${h.toFixed(1)}px`);
      }
      return n === 0 ? ['no labels'] : out;
    }, min);
    expect(small.slice(0, 10)).toEqual([]);
  });
}

// The heatmap's columns use the flow diagram's display names (src/unit-names.js),
// not llvm-mca's raw resource names, and each column's tooltip carries the raw name.
test('heatmap columns use display names with the raw llvm-mca name in the tooltip', async ({ page }) => {
  await page.goto('/');
  await runExample(page);
  const r = await page.evaluate(() => {
    const cols = [...document.querySelectorAll('#heatmap svg text.col')];
    return {
      texts: cols.map((c) => c.firstChild.textContent),
      titles: cols.map((c) => c.querySelector('title')?.textContent ?? ''),
      n: cols.length,
    };
  });
  expect(r.n).toBeGreaterThan(10);
  // znver4's raw names start with Zn4; the display names must not
  expect(r.texts.filter((t) => /Zn4/.test(t))).toEqual([]);
  expect(r.texts).toContain('FP0');
  // every kept column names its raw llvm-mca resource in the tooltip
  for (const t of r.titles) expect(t).toMatch(/\(.+\)$/);
});

// The heatmap column for a unit shows the same display name the flow diagram
// shows for it; both come from src/unit-names.js, so a name is one per unit.
test('heatmap and flow show the same display name for each unit', async ({ page }) => {
  await page.goto('/');
  await runExample(page);
  // each heatmap column tooltip is "<display> (<raw>)"; the flow box for the
  // same raw resource must show the same <display> text and its own tooltip
  // must name the raw resource too
  const r = await page.evaluate(() => {
    const cols = [...document.querySelectorAll('#heatmap svg text.col')].map((c) => ({
      text: c.firstChild.textContent,
      tip: c.querySelector('title')?.textContent ?? '',
    }));
    const flow = [...document.querySelectorAll('#flow .flow-unit')].map((u) => ({
      text: u.querySelector('text').textContent,
      tip: u.querySelector('title')?.textContent ?? '',
    }));
    return { cols, flow, n: cols.length };
  });
  expect(r.n).toBeGreaterThan(10);
  expect(r.flow.length).toBeGreaterThan(10);
  for (const col of r.cols) {
    const raw = /\(([^()]+)\)$/.exec(col.tip)?.[1];
    expect(raw, col.tip).toBeTruthy();
    const box = r.flow.find((f) => f.tip.split('\n').at(-1)?.trim() === raw);
    expect(box, `flow box for ${raw}`).toBeTruthy();
    expect(box.text).toBe(col.text);
  }
});

// The heatmap has an outside-the-grid scale: text naming the pressure range,
// so a filled cell can be read against the maximum.
test('heatmap shows the pressure range outside the column grid', async ({ page }) => {
  await page.goto('/');
  await runExample(page);
  const texts = await page.evaluate(() => [...document.querySelectorAll('#heatmap svg text')].map((t) => t.textContent));
  const scale = texts.find((t) => /^pressure per iteration: 0 to /.test(t));
  expect(scale).toBeTruthy();
  expect(+scale.split('to').at(-1)).toBeGreaterThan(0);
});

// Filled heatmap cells carry their value when the glyph fits the cell: at
// least one number is printed inside the grid.
test('heatmap cells print values', async ({ page }) => {
  await page.goto('/');
  await runExample(page);
  const values = await page.evaluate(() => {
    const cells = [...document.querySelectorAll('#heatmap svg rect[data-cy]')].map((r) => r.getBoundingClientRect());
    return [...document.querySelectorAll('#heatmap svg text.heat-val')].filter((t) => {
      const b = t.getBoundingClientRect();
      return cells.some((c) => b.left >= c.left - 1 && b.right <= c.right + 1 && b.top >= c.top - 1 && b.bottom <= c.bottom + 1);
    }).length;
  });
  expect(values).toBeGreaterThan(0);
});

// The timeline scrolls in its own box: at 100 iterations the SVG is about
// 850px tall, but the box caps at 520px instead of stretching the page.
test('timeline box is capped and scrolls at 100 iterations', async ({ page }) => {
  await page.goto('/');
  await runExample(page);
  const r = await page.evaluate(() => {
    const box = document.getElementById('timeline');
    return { client: box.clientHeight, scroll: box.scrollHeight, svg: box.querySelector('svg').getBBox().height };
  });
  expect(r.svg).toBeGreaterThan(520);
  expect(r.client).toBeLessThanOrEqual(520);
  expect(r.scroll).toBeGreaterThan(r.client);
});

// The timeline notice does not tell a browser user to rerun llvm-mca with
// command-line flags they cannot set.
test('timeline cap notice does not name command-line flags', async ({ page }) => {
  await page.goto('/');
  await runExample(page);
  const notice = await page.locator('#notice').textContent();
  expect(notice).toContain('of 100');
  expect(notice).toContain('scroll');
  expect(notice).not.toMatch(/-timeline-max|Rerun|flag/);
});

// At 1400px the flow and timeline sit side by side; each panel keeps its own
// height instead of stretching to the other's (that left ~600px blank).
test('1400px: flow panel does not stretch to the timeline height', async ({ page }) => {
  await page.setViewportSize({ width: 1400, height: 900 });
  await page.goto('/');
  await runExample(page);
  const r = await page.evaluate(() => ({
    flow: document.querySelector('#out > .panel:has(> #flow)').getBoundingClientRect().height,
    timeline: document.querySelector('#out > .panel:has(> #timeline)').getBoundingClientRect().height,
  }));
  // content-sized panels: fixed ~665/810, ~750 off (a 600px gap by grid stretch)
  expect(Math.abs(r.timeline - r.flow)).toBeLessThan(300);
  expect(Math.abs(r.timeline - r.flow)).toBeGreaterThan(5);
});
