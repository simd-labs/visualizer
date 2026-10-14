// Round-1 flow-area fixes: unit roles spelled out, token notation in the
// legend, queue boxes no taller than their pile, flow text at least 11px at 800px.
import { test, expect } from '@playwright/test';
import { readFileSync } from 'node:fs';
import { lookup } from '../src/unit-names.js';
import { buildModel, tokenPositionsAt } from '../src/model.js';

const dropJson = async (page, file) => {
  const dt = await page.evaluateHandle(
    (f) => {
      const d = new DataTransfer();
      d.items.add(new File([Uint8Array.from(f.bytes)], f.name, { type: 'application/json' }));
      return d;
    },
    { name: file, bytes: [...readFileSync(`test/fixtures/${file}`)] }
  );
  await page.dispatchEvent('body', 'drop', { dataTransfer: dt });
  await expect(page.locator('#flow svg')).toHaveCount(1);
};

test('unit names: display roles are spelled out, no bare st or AGU anywhere', () => {
  // hand-picked roles the rules generate
  expect(lookup('znver4', 'Zn4FP45.').role).toBe('store/fma');
  expect(lookup('znver4', 'Zn4LSU.').role).toBe('LSU: load/store unit');
  expect(lookup('skylake', 'SKLPort0').display).toBe('Port 0 (arithmetic logic unit / vector arithmetic logic unit+FMA)');
  expect(lookup('neoverse-v2', 'V2UnitS01.').role).toBe('integer arithmetic logic unit');
  // every fixture resource: no abbreviation the page never defines
  for (const file of ['znver4.issue.json', 'neoverse-v2.issue.json', 'skylake.issue.json', 'cortex-a55.issue.json']) {
    const j = JSON.parse(readFileSync(`test/fixtures/${file}`, 'utf8'));
    for (const r of j.TargetInfo.Resources) {
      const d = lookup(j.TargetInfo.CPUName, r).display;
      expect(d, r).not.toMatch(/\bst\b/i);
      expect(d, r).not.toMatch(/\bAGU\b/);
    }
  }
});

test('flow legend explains the iteration:mnemonic:line token labels', async ({ page }) => {
  await page.goto('/');
  await expect(page.locator('#flow-legend')).toContainText('iteration:mnemonic:line');
});

test('flow diagram: queue boxes fit their piles and retire stays in view', async ({ page }) => {
  await page.goto('/');
  await dropJson(page, 'znver4.issue.json');
  const j = JSON.parse(readFileSync('test/fixtures/znver4.issue.json', 'utf8'));
  const model = buildModel(j);
  const pile = { dispatch: 1, waiting: 1, ready: 1, retire: 1 };
  let cycled1 = null;
  for (let c = 0; c <= model.cycleIndex.maxCycle; c++) {
    const cur = { dispatch: 0, waiting: 0, ready: 0, retire: 0 };
    for (const t of tokenPositionsAt(model, c)) if (t.stage in cur) cur[t.stage]++;
    if (cycled1 === null) cycled1 = cur; // the page sits at cycle 1 after drop
    for (const k in cur) pile[k] = Math.max(pile[k], cur[k]);
  }
  // layout constants and queue-height formula from render.js
  const FLOW = { pad: 6, head: 20, tokH: 18, tg: 3, font: 12, gap: 24, W: 700 };
  // labels are iteration:mnemonic after a JSON drop (no source lines)
  const mnemonic = (s) => s.trim().split(/\s+/)[0].toLowerCase();
  const len = Math.max(...model.rows.map((r) => `${r.iter}:${mnemonic(model.instructions[r.instr])}`.length));
  const tokW = Math.ceil(len * 0.62 * FLOW.font) + 8;
  const step = tokW + FLOW.tg;
  const colsIn = (w) => Math.max(1, Math.floor((w - 2 * FLOW.pad + FLOW.tg) / step));
  const rows = (n, w) => Math.ceil(Math.max(n, 1) / colsIn(w));
  const qH = (n, w) => FLOW.head + rows(n, w) * FLOW.tokH + (rows(n, w) - 1) * FLOW.tg + FLOW.pad;
  const qW3 = (FLOW.W - 2 * FLOW.gap) / 3;
  const qW4 = (FLOW.W - 3 * FLOW.gap) / 4;
  const qW = colsIn(qW4) >= colsIn(qW3) && pile.retire <= colsIn(qW4) ? qW4 : qW3;
  const blocks = await page.locator('#flow svg .flow-block').evaluateAll((gs) =>
    gs.map((g) => ({ b: g.dataset.block, y: +g.querySelector('rect').getAttribute('y'), h: +g.querySelector('rect').getAttribute('height') }))
  );
  const byName = Object.fromEntries(blocks.map((x) => [x.b, x]));
  for (const cls of ['dispatch', 'waiting', 'ready']) {
    expect(byName[cls].h, cls).toBeCloseTo(qH(cycled1[cls], qW), 0);
  }
  // every block stays inside the SVG (retire used to stretch it with dead space)
  const svgH = +(await page.locator('#flow svg').getAttribute('height'));
  for (const x of blocks) expect(x.y + x.h, x.b).toBeLessThanOrEqual(svgH);
});

test('flow text renders at least 12px at 1400px and 11px at 800px', async ({ page }) => {
  for (const [width, min] of [[1400, 12], [800, 11]]) {
    await page.setViewportSize({ width, height: 900 });
    await page.goto('/');
    await dropJson(page, 'znver4.issue.json');
    const sizes = await page.locator('#flow svg text').evaluateAll((ts) => {
      return ts.map((el) => {
        const svg = el.ownerSVGElement;
        const rect = svg.getBoundingClientRect();
        const vb = svg.viewBox.baseVal;
        return (+el.getAttribute('font-size')) * (rect.width / vb.width);
      });
    });
    expect(sizes.length).toBeGreaterThan(10);
    for (const s of sizes) expect(s).toBeGreaterThanOrEqual(min - 0.01);
  }
});
