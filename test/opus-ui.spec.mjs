// M2: the flow diagram has a fixed geometry per run. Stepping through the
// cycles moves tokens between blocks; no box or panel moves. Waiting tokens
// (dispatched, not yet issued) share one area, sized from the run's peak;
// past the peak a single +N carries the rest.
import { test, expect } from '@playwright/test';
import { readFileSync } from 'node:fs';
import { run } from '../wasm/run.mjs';
import { buildModel, notIssuedAt } from '../src/model.js';
import { exampleFor } from '../src/examples.js';

const CPUs = ['znver4', 'neoverse-v2', 'sifive-u74'];
const cpus = JSON.parse(readFileSync('cpus.json', 'utf8'));
const tripleOf = (cpu) => Object.keys(cpus).find((t) => cpus[t].includes(cpu));

const runNow = async (page, cpu) => {
  await page.selectOption('#cpu', cpu);
  await page.waitForFunction((c) => document.querySelector('#cpu').value === c, cpu);
  await page.click('#run');
  await page.waitForSelector('#flow svg', { timeout: 120000 });
};

// Every cycle in one page call: set the slider, then run `probe` (a function
// body as text) and collect what it returns.
const eachCycle = (page, probe) =>
  page.evaluate((probe) => {
    const f = new Function(probe);
    const s = document.querySelector('#flow-cycle');
    const out = [];
    for (let c = 0; c <= +s.max; c++) {
      s.value = c;
      s.dispatchEvent(new Event('input', { bubbles: true }));
      out.push(f());
    }
    return out;
  }, probe);

test.beforeEach(async ({ page }) => {
  await page.setViewportSize({ width: 1400, height: 900 });
  await page.goto('/');
  await page.waitForSelector('#run:not([disabled])', { timeout: 120000 });
});

for (const cpu of CPUs) {
  test(`${cpu}: no flow box or panel below it moves or resizes between cycles`, async ({ page }) => {
    await runNow(page, cpu);
    const records = await eachCycle(
      page,
      `const box = (el) => { const r = el.getBoundingClientRect(); return [r.x + scrollX, r.y + scrollY, r.width, r.height].map((v) => v.toFixed(2)).join(','); };
       const svg = document.querySelector('#flow svg');
       const parts = [svg, ...svg.querySelectorAll('*')].filter((el) => !el.closest('.flow-tokens') && !(el instanceof SVGDefsElement || el.closest('defs')));
       let panel = document.getElementById('flow').closest('.panel');
       for (let p = panel; p; p = p.nextElementSibling) parts.push(p);
       return parts.map((el) => (el.getAttribute('class') || el.tagName) + '@' + box(el));`
    );
    expect(records.length).toBeGreaterThan(10);
    expect(records[0].length).toBeGreaterThan(20);
    records.forEach((r, c) => expect(r, `cycle ${c}`).toEqual(records[0]));
  });

  test(`${cpu}: waiting tokens plus the +N badge equal the model's dispatched-not-issued count`, async ({ page }) => {
    await runNow(page, cpu);
    const triple = tripleOf(cpu);
    const iters = await page.inputValue('#iterations');
    const { stdout } = run(exampleFor(triple), [`-mtriple=${triple}`, `-mcpu=${cpu}`, `-iterations=${iters}`, '-timeline', '-json', '-issue-events']);
    const model = buildModel(JSON.parse(stdout));
    const want = [];
    for (let c = 0; c <= model.cycleIndex.maxCycle; c++) want.push(notIssuedAt(model, c));
    const got = await eachCycle(
      page,
      `const tokens = document.querySelectorAll('#flow svg .flow-token[data-block="waiting"]').length;
       const over = document.querySelector('#flow svg .flow-overflow');
       return tokens + (over ? +over.dataset.n : 0);`
    );
    expect(got.length).toBe(want.length);
    got.forEach((n, c) => expect(n, `cycle ${c}: waiting tokens + badge`).toBe(want[c]));
    if (cpu !== 'sifive-u74') expect(got.reduce((a, b) => a + b, 0), 'no instance waits in this run').toBeGreaterThan(0);
  });
}

// M3: the editor stays open after Run, and the results fit the screen. From
// 1400px the editor and run controls take a left column; below, they sit
// above the results and the sticky cycle bar stays on screen while scrolling.
test.describe('M3 editor and screen fit', () => {
  const runAt = async (page, w, h) => {
    await page.setViewportSize({ width: w, height: h });
    await page.goto('/');
    await page.waitForSelector('#run:not([disabled])', { timeout: 120000 });
    await runNow(page, 'znver4');
    await page.evaluate(() => scrollTo(0, 0));
  };
  const rect = (page, sel) =>
    page.evaluate((sel) => {
      const r = document.querySelector(sel).getBoundingClientRect();
      return { top: r.top, bottom: r.bottom, left: r.left, right: r.right };
    }, sel);

  test('the editor stays open after Run', async ({ page }) => {
    await runAt(page, 1920, 1080);
    await expect(page.locator('#asm')).toBeVisible();
    expect((await rect(page, '#asm')).bottom - (await rect(page, '#asm')).top, 'textarea height').toBeGreaterThan(50);
    await expect(page.locator('#asm-summary, #asm-edit')).toHaveCount(0);
  });

  for (const [w, h] of [[1920, 1080], [1600, 900]]) {
    test(`${w}x${h}: the cycle bar and the whole flow diagram fit the first screen`, async ({ page }) => {
      await runAt(page, w, h);
      expect(await page.evaluate(() => scrollY)).toBe(0);
      for (const sel of ['.cycle-bar', '#flow svg']) {
        const r = await rect(page, sel);
        expect(r.top, `${sel} top`).toBeGreaterThanOrEqual(0);
        expect(r.left, `${sel} left`).toBeGreaterThanOrEqual(0);
        expect(r.bottom, `${sel} bottom`).toBeLessThanOrEqual(h);
        expect(r.right, `${sel} right`).toBeLessThanOrEqual(w);
      }
    });
  }

  for (const [w, h] of [[960, 1080], [800, 900]]) {
    test(`${w}x${h}: the sticky cycle bar stays on screen with the flow and the timeline in view`, async ({ page }) => {
      await runAt(page, w, h);
      for (const sel of ['#flow svg', '#timeline']) {
        await page.evaluate((sel) => document.querySelector(sel).scrollIntoView({ block: 'center' }), sel);
        const bar = await rect(page, '.cycle-bar');
        const r = await rect(page, sel);
        expect(r.bottom > 0 && r.top < h, `${sel} in view`).toBe(true);
        expect(bar.top, `bar top with ${sel} in view`).toBeGreaterThanOrEqual(0);
        expect(bar.top, `bar top with ${sel} in view`).toBeLessThan(h);
        expect(bar.bottom, `bar bottom with ${sel} in view`).toBeLessThanOrEqual(h);
      }
    });
  }

  for (const [w, h] of [[1920, 1080], [800, 900]]) {
    test(`${w}x${h}: no cycle bar control moves between cycles`, async ({ page }) => {
      await runAt(page, w, h);
      const records = await eachCycle(
        page,
        `return [...document.querySelectorAll('.cycle-bar > *:not(#flow-status)')].map((el) => { const r = el.getBoundingClientRect(); return [r.x, r.y, r.width, r.height].map((v) => v.toFixed(2)).join(','); });`
      );
      records.forEach((r, c) => expect(r, `cycle ${c}`).toEqual(records[0]));
    });
  }

  for (const [w, h] of [[1920, 1080], [1600, 900], [1366, 768], [960, 1080], [800, 900]]) {
    test(`${w}x${h}: no sideways page scroll`, async ({ page }) => {
      await runAt(page, w, h);
      const d = await page.evaluate(() => ({ sw: document.documentElement.scrollWidth, cw: document.documentElement.clientWidth }));
      expect(d.sw, `scrollWidth vs clientWidth ${d.cw}`).toBeLessThanOrEqual(d.cw);
    });
  }

  for (const [w, min] of [[1920, 12], [1600, 12], [1400, 12], [800, 11]]) {
    test(`${w}px: every visible text in the editor, cycle bar, flow and panels is at least ${min}px`, async ({ page }) => {
      await runAt(page, w, 900);
      const small = await page.evaluate((min) => {
        const out = [];
        for (const el of document.querySelectorAll('#run-form *, .cycle-bar *, .panel, .panel *')) {
          const own = [...el.childNodes].some((n) => n.nodeType === 3 && n.textContent.trim());
          const editable = el.matches('textarea, input, select, button');
          if (!own && !editable) continue;
          if (!el.getClientRects().length || el.closest('[hidden], details:not([open]) > :not(summary)')) continue;
          const cs = getComputedStyle(el);
          if (cs.visibility === 'hidden' || cs.opacity === '0') continue;
          // SVG text renders at its font-size times the SVG's scale on screen (hypot: rotated labels)
          const px = parseFloat(cs.fontSize) * (el instanceof SVGElement ? Math.hypot(el.getScreenCTM().a, el.getScreenCTM().b) : 1);
          if (px < min - 0.01) out.push(`${el.tagName.toLowerCase()}${el.id ? '#' + el.id : ''}.${el.getAttribute('class') ?? ''} ${px.toFixed(1)}px`);
        }
        return [...new Set(out)];
      }, min);
      expect(small).toEqual([]);
    });
  }
});
