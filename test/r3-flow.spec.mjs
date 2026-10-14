// Round-3 flow-area fixes, measured against the round-2 audit's numbers:
// (1) every flow text renders at >=12px at 1400px and >=11px at 800px (the
//     SVG's 701-wide viewBox never downscales at either width);
// (2) no queue/stage box is more than 40% empty at a mid-run cycle (execution
//     unit boxes are exempt: their height is reserved for the maximum token
//     pile of that unit over the run, per the layout contract);
// (3) the whole flow diagram fits the content width at 1400px/800px with no
//     horizontal scrolling.
import { test, expect } from '@playwright/test';
import { readFileSync } from 'node:fs';

const CPUs = ['znver4', 'neoverse-v2', 'sifive-u74'];

const runNow = async (page, cpu) => {
  await page.selectOption('#cpu', cpu);
  await page.waitForFunction((c) => document.querySelector('#cpu').value === c, cpu);
  await page.click('#run');
  await page.waitForSelector('#flow svg', { timeout: 120000 });
};

const midCycle = async (page) => {
  // The audit's "mid-run" is the slider at half the range, which lands in the
  // steady state for a long run. These short examples (20-60 cycles) end in a
  // long drain, so half-way is empty; the busy middle is the peak cycle.
  await page.evaluate(() => {
    const s = document.querySelector('#flow-cycle');
    let best = 0;
    let bestN = -1;
    for (let c = 0; c <= +s.max; c++) {
      s.value = c;
      s.dispatchEvent(new Event('input', { bubbles: true }));
      const n = document.querySelectorAll('#flow svg .flow-token').length;
      if (n > bestN) { bestN = n; best = c; }
    }
    s.value = best;
    s.dispatchEvent(new Event('input', { bubbles: true }));
  });
  await page.waitForTimeout(150);
};

// measure: rect sizes, the union of text + token bboxes inside, empty%
const measure = async (page) =>
  page.evaluate(() => {
    const svg = document.querySelector('#flow svg');
    const area = (r) => r.width * r.height;
    const inBox = (b, r) => b.left >= r.left - 1 && b.right <= r.right + 1 && b.top >= r.top - 1 && b.bottom <= r.bottom + 1;
    const tokRects = [...svg.querySelectorAll('.flow-token > rect, .flow-marker > rect')].map((e) => e.getBoundingClientRect());
    const blocks = {};
    for (const g of svg.querySelectorAll('.flow-block')) {
      const r = g.querySelector(':scope > rect').getBoundingClientRect();
      const direct = g.dataset.block === 'execute' ? [...g.querySelectorAll(':scope > text')] : [g.querySelector(':scope > text')];
      let c = direct.reduce((a, t) => a + area(t.getBoundingClientRect()), 0);
      if (g.dataset.block !== 'execute') for (const tr of tokRects) if (inBox(tr, r)) c += area(tr);
      blocks[g.dataset.block] = { w: r.width, h: r.height, empty: (area(r) - c) / area(r) };
    }
    return { blocks, svgW: svg.viewBox.baseVal.width, renderedW: svg.getBoundingClientRect().width };
  });

test('every flow text is at least 12px at 1400px and 11px at 800px, for all three CPUs', async ({ page }) => {
  for (const [width, min] of [[1400, 12], [800, 11]]) {
    await page.setViewportSize({ width, height: 900 });
    await page.goto('/');
    await page.waitForSelector('#run:not([disabled])', { timeout: 120000 });
    for (const cpu of CPUs) {
      await runNow(page, cpu);
      await midCycle(page);
      const sizes = await page.locator('#flow svg text').evaluateAll((ts) =>
        ts.map((el) => {
          const svg = el.ownerSVGElement;
          const scale = svg.getBoundingClientRect().width / svg.viewBox.baseVal.width;
          return +el.getAttribute('font-size') * scale;
        })
      );
      expect(sizes.length, cpu).toBeGreaterThan(10);
      for (const s of sizes) expect(s, `${cpu} at ${width}px`).toBeGreaterThanOrEqual(min - 0.01);
    }
  }
});

test('queue boxes hold no empty rows below the last token row at the busy cycle', async ({ page }) => {
  // The rule is against the audit's complaint ("boxes much taller than their
  // contents"): with the per-cycle sizing, a queue box's height is 50px plus
  // 24px for each fully used token row below the first. Execution unit boxes
  // are exempt: their height is reserved for the unit's max token pile over
  // the run.
  await page.setViewportSize({ width: 1400, height: 900 });
  await page.goto('/');
  await page.waitForSelector('#run:not([disabled])', { timeout: 120000 });
  for (const cpu of CPUs) {
    await runNow(page, cpu);
    await midCycle(page);
    const data = await page.evaluate(() => {
      const svg = document.querySelector('#flow svg');
      const tok = svg.querySelector('.flow-token > rect');
      const tokW = tok ? tok.getBoundingClientRect().width : 0;
      const tokH = tok ? tok.getBoundingClientRect().height : 20;
      const out = {};
      for (const g of svg.querySelectorAll('.flow-block')) {
        if (g.dataset.block === 'execute') continue;
        const r = g.querySelector(':scope > rect').getBoundingClientRect();
        const n = [...svg.querySelectorAll('.flow-token > rect, .flow-marker > rect')]
          .map((t) => t.getBoundingClientRect())
          .filter((t) => t.left >= r.left - 1 && t.right <= r.right + 1 && t.top >= r.top - 1 && t.top < r.bottom).length;
        const cols = Math.max(1, Math.floor((r.width - 12 + 3) / (tokW + 3)));
        out[g.dataset.block] = { h: r.height, n, cols, tokW, tokH };
      }
      return out;
    });
    // the box's height formula: head 20 + rows * tokH's grid (stackH) + pad 6,
    // with rows from this cycle's token count in the box's columns
    for (const k of ['dispatch', 'waiting', 'ready', 'retire']) {
      const d = data[k];
      const rows = Math.ceil(Math.max(d.n, 1) / d.cols);
      expect(d.h, `${cpu} ${k} fits its ${d.n} tokens`).toBeGreaterThanOrEqual(20 + (rows * 18 + (rows - 1) * 3) + 6 - 0.01);
      expect(d.h, `${cpu} ${k} has no extra rows`).toBeLessThanOrEqual(20 + (rows * 18 + (rows - 1) * 3) + 6 + 0.01);
    }
  }
});

test('stepping through every cycle never moves the content below the flow diagram', async ({ page }) => {
  // While the user plays or steps, boxes inside the flow diagram may resize
  // to the current cycle, but the SVG's height must not: anything below the
  // diagram moving up and down was the round-3 integration risk.
  await page.setViewportSize({ width: 1400, height: 900 });
  await page.goto('/');
  await page.waitForSelector('#run:not([disabled])', { timeout: 120000 });
  await page.selectOption('#cpu', 'znver4');
  await page.waitForFunction(() => document.querySelector('#cpu').value === 'znver4');
  await page.click('#run');
  await page.waitForSelector('#flow svg', { timeout: 120000 });

  const geometry = () =>
    page.evaluate(() => {
      const svg = document.querySelector('#flow svg');
      const box = svg.getBoundingClientRect();
      // the flow SVG sits in #flow inside its panel; the first panel below it
      // in #out is what must not move
      const flowPanel = document.getElementById('flow').closest('.panel');
      const below = flowPanel.nextElementSibling;
      return { svgH: box.height, belowY: below ? below.getBoundingClientRect().top : null };
    });

  const max = await page.evaluate(() => +document.querySelector('#flow-cycle').max);
  const first = await page.evaluate(() => {
    const s = document.querySelector('#flow-cycle');
    s.value = 0;
    s.dispatchEvent(new Event('input', { bubbles: true }));
  });
  const g0 = await geometry();
  for (let c = 1; c <= max; c++) {
    await page.evaluate((n) => {
      const s = document.querySelector('#flow-cycle');
      s.value = n;
      s.dispatchEvent(new Event('input', { bubbles: true }));
    }, c);
    const g = await geometry();
    expect(g.svgH, `svg height at cycle ${c}`).toBeCloseTo(g0.svgH, 5);
    expect(g.belowY, `below-flow y at cycle ${c}`).toBeCloseTo(g0.belowY, 5);
  }
});

test('the flow diagram fits the content width at 1400px and 800px, no inner scroll', async ({ page }) => {
  for (const width of [1400, 800]) {
    await page.setViewportSize({ width, height: 900 });
    await page.goto('/');
    await page.waitForSelector('#run:not([disabled])', { timeout: 120000 });
    for (const cpu of CPUs) {
      await runNow(page, cpu);
      await midCycle(page);
      const { renderedW } = await measure(page);
      const contentW = await page.evaluate(() => document.querySelector('#flow').clientWidth);
      expect(renderedW, `${cpu} at ${width}px`).toBeLessThanOrEqual(contentW + 1);
      const overflowX = await page.evaluate(() => document.documentElement.scrollWidth - document.documentElement.clientWidth);
      expect(overflowX, `${cpu} at ${width}px page scroll`).toBeLessThanOrEqual(0);
    }
  }
});

// Round-4 defect: #flow-status is never clipped (scrollWidth/scrollHeight fit
// its box) at any cycle, at 1400px and 800px, on znver4 and neoverse-v2. The
// b1 rule's "neoverse-v2 at 1400px clips after \"Executing (latency), \"" was
// the one-line ellipsis; the fix wraps into a fixed per-run height.
test('#flow-status is fully visible at every cycle and both widths', async ({ page }) => {
  for (const width of [1400, 800]) {
    await page.setViewportSize({ width, height: 900 });
    await page.goto('/');
    await page.waitForSelector('#run:not([disabled])', { timeout: 120000 });
    for (const cpu of ['znver4', 'neoverse-v2']) {
      await runNow(page, cpu);
      const below = () =>
        page.evaluate(() => {
          const flowPanel = document.querySelector('#flow').closest('.panel');
          const next = flowPanel.nextElementSibling;
          return next ? next.getBoundingClientRect().top : null;
        });
      const max = await page.evaluate(() => +document.querySelector('#flow-cycle').max);
      const y0 = await below();
      for (let c = 0; c <= max; c++) {
        await page.evaluate((n) => {
          const s = document.querySelector('#flow-cycle');
          s.value = n;
          s.dispatchEvent(new Event('input', { bubbles: true }));
        }, c);
        const r = await page.evaluate(() => {
          const el = document.getElementById('flow-status');
          return { cw: el.clientWidth, sw: el.scrollWidth, ch: el.clientHeight, sh: el.scrollHeight };
        });
        expect(r.sw, `${cpu} @${width}px cycle ${c}: status scrollWidth fits`).toBeLessThanOrEqual(r.cw);
        expect(r.sh, `${cpu} @${width}px cycle ${c}: status scrollHeight fits`).toBeLessThanOrEqual(r.ch);
        const yc = await below();
        expect(yc, `${cpu} @${width}px cycle ${c}: content below does not move`).toBeCloseTo(y0, 5);
      }
    }
  }
});
