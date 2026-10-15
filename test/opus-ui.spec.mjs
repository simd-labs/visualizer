// M2: the flow diagram has a fixed geometry per run. Stepping through the
// cycles moves tokens between scheduler slots; no box, slot or panel moves.
import { test, expect } from '@playwright/test';
import { readFileSync } from 'node:fs';
import { run } from '../wasm/run.mjs';
import { buildModel, tokenPositionsAt, unitGroup } from '../src/model.js';
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

  test(`${cpu}: each scheduler group's tokens, +N and badge match the model's waiting count`, async ({ page }) => {
    await runNow(page, cpu);
    const triple = tripleOf(cpu);
    const iters = await page.inputValue('#iterations');
    const { stdout } = run(exampleFor(triple), [`-mtriple=${triple}`, `-mcpu=${cpu}`, `-iterations=${iters}`, '-timeline', '-json', '-issue-events']);
    const model = buildModel(JSON.parse(stdout));
    const want = [];
    for (let c = 0; c <= model.cycleIndex.maxCycle; c++) {
      const at = {};
      for (const t of tokenPositionsAt(model, c)) {
        if (t.stage !== 'waiting') continue;
        const g = t.queue == null ? 'unassigned' : unitGroup(model.resources[t.queue]);
        at[g] = (at[g] ?? 0) + 1;
      }
      want.push(at);
    }
    const got = await eachCycle(
      page,
      `const out = {};
       for (const g of document.querySelectorAll('#flow svg .flow-group')) {
         const id = g.dataset.group;
         const tokens = document.querySelectorAll('#flow svg .flow-token[data-group="' + id + '"]').length;
         const over = document.querySelector('#flow svg .flow-overflow[data-group="' + id + '"]');
         const badge = document.querySelector('#flow svg .flow-badge[data-group="' + id + '"]');
         out[id] = { inSlots: tokens + (over ? +over.dataset.n : 0), badge: badge ? +badge.textContent : null };
       }
       out.stray = document.querySelectorAll('#flow svg .flow-token[data-block="waiting"]:not([data-group])').length;
       return out;`
    );
    expect(got.length).toBe(want.length);
    let seen = 0;
    got.forEach((at, c) => {
      expect(at.stray, `cycle ${c}: waiting tokens outside a group`).toBe(0);
      for (const g of Object.keys(at).filter((k) => k !== 'stray')) {
        const n = want[c][g] ?? 0;
        seen += n;
        expect(at[g].inSlots, `cycle ${c} ${g}: tokens in slots`).toBe(n);
        expect(at[g].badge, `cycle ${c} ${g}: badge`).toBe(n);
      }
      for (const g of Object.keys(want[c])) expect(at[g], `cycle ${c}: group ${g} is drawn`).toBeTruthy();
    });
    if (cpu !== 'sifive-u74') expect(seen, 'no instance waits in this run').toBeGreaterThan(0);
  });
}
