import { test, expect } from '@playwright/test';
import { readFileSync } from 'node:fs';

// Layout constants from src/render.js; the position checks below depend on them.
const CELL = 10;
const LEFT = 200;
const TOP = 16;
const HEAD = 60;
const STAGES = ['wait', 'ready', 'exec', 'done'];

const fixture = (name) => JSON.parse(readFileSync(`test/fixtures/${name}.json`, 'utf8'));
const label = (s) => s.replace(/[\u0000-\u001f]/g, (c) => c.charCodeAt(0));
const rowName = (asm, i) => (i === asm.length ? 'total/iter' : asm[i]);
const nd = (x) => x.toFixed(2);

// Expected values come from the JSON, not from the page's own code.
function expectedRows(j) {
  const r = j.CodeRegions[0];
  const n = r.Instructions.length;
  return r.TimelineView.TimelineInfo.map((e, i) => ({ iter: Math.floor(i / n), instr: i % n, e }));
}

// Rects in render order: row by row, then wait, ready, exec, done when non-empty.
function expectedRects(j) {
  const rects = [];
  const asm = j.CodeRegions[0].Instructions;
  for (const { iter, instr, e } of expectedRows(j)) {
    const y = TOP + (iter * asm.length + instr) * CELL;
    const spans = [
      [e.CycleDispatched, e.CycleReady],
      [e.CycleReady, e.CycleIssued],
      [e.CycleIssued, e.CycleExecuted],
      [e.CycleExecuted, e.CycleRetired],
    ];
    spans.forEach(([a, b], k) => {
      if (b <= a) return;
      rects.push({
        x: String(LEFT + a * CELL),
        y: String(y),
        width: String((b - a) * CELL),
        stage: STAGES[k],
        title: `${asm[instr]}\niter ${iter}, ${STAGES[k]}: cycles ${a}-${b}`,
      });
    });
  }
  return rects;
}

// Full resource matrix (zeros included) and the non-zero cells the heatmap draws.
function expectedMatrix(j) {
  const r = j.CodeRegions[0];
  const n = r.Instructions.length;
  const m = Array.from({ length: n + 1 }, () => new Array(j.TargetInfo.Resources.length).fill(0));
  for (const { InstructionIndex: i, ResourceIndex: k, ResourceUsage: v } of r.ResourcePressureView.ResourcePressureInfo) {
    if (i <= n) m[i][k] = v;
  }
  return m;
}

// Each pick or drop is a real user action; the page must render the same either way.
async function open(page, via, file) {
  const errors = [];
  page.on('pageerror', (e) => errors.push(e.message));
  await page.goto('/');
  if (via === 'picker') {
    await page.locator('#file').setInputFiles(`test/fixtures/${file}`);
  } else {
    const dt = await page.evaluateHandle(
      (f) => {
        const d = new DataTransfer();
        d.items.add(new File([Uint8Array.from(f.bytes)], f.name, { type: 'application/json' }));
        return d;
      },
      { name: file, bytes: [...readFileSync(`test/fixtures/${file}`)] }
    );
    await page.locator('#drop').dispatchEvent('drop', { dataTransfer: dt });
  }
  return errors;
}

const complete = ['znver4', 'skylake', 'neoverse-v2'];
for (const via of ['drop', 'picker']) {
  for (const name of complete) {
    test(`${name} (${via}): timeline rows, cycles, and tooltips match the JSON`, async ({ page }) => {
      const errors = await open(page, via, `${name}.json`);
      await expect(page.locator('#out')).toBeVisible();
      await expect(page.locator('#error')).toBeHidden();
      await expect(page.locator('#notice')).toBeHidden();
      const j = fixture(name);
      const asm = j.CodeRegions[0].Instructions;
      const n = asm.length;

      const rows = expectedRows(j);
      expect(rows.length).toBeGreaterThan(0);
      // [iter,instr] labels, one per row, in order
      const labels = await page.locator('#timeline svg text.row').allTextContents();
      expect(labels).toEqual(rows.map((r) => `[${r.iter},${r.instr}]`));

      // every rect's x, width, fill stage, and tooltip
      const rects = expectedRects(j);
      const got = await page.locator('#timeline svg rect').evaluateAll((els) =>
        els.map((r) => ({
          x: r.getAttribute('x'),
          y: r.getAttribute('y'),
          width: r.getAttribute('width'),
          title: r.querySelector('title').textContent,
        }))
      );
      expect(got.length).toBeGreaterThan(0);
      expect(got.length).toBe(rects.length);
      got.forEach((g, i) => {
        expect(g.x, `rect ${i} x`).toBe(rects[i].x);
        expect(g.y, `rect ${i} y`).toBe(rects[i].y);
        expect(g.width, `rect ${i} width`).toBe(rects[i].width);
        expect(g.title, `rect ${i} title`).toBe(rects[i].title);
      });

      // cycle labels and grid lines every 5 cycles up to the last retire
      const maxCycle = Math.max(...rows.map((r) => r.e.CycleRetired));
      const axis = [];
      for (let c = 0; c <= maxCycle; c += 5) axis.push(String(c));
      expect(await page.locator('#timeline svg text.axis').allTextContents()).toEqual(axis);
      expect(await page.locator('#timeline svg line.grid').count()).toBe(axis.length);

      // the text table carries all five cycles per row, the same as the SVG
      const table = await page.locator('#timeline-table tr').evaluateAll((trs) =>
        trs.map((tr) => [...tr.children].map((c) => c.textContent))
      );
      expect(table[0]).toEqual(['Iteration', 'Instr', 'Asm', 'Dispatched', 'Ready', 'Issued', 'Executed', 'Retired']);
      expect(table.slice(1)).toEqual(
        rows.map((r) => [
          String(r.iter),
          String(r.instr),
          asm[r.instr],
          String(r.e.CycleDispatched),
          String(r.e.CycleReady),
          String(r.e.CycleIssued),
          String(r.e.CycleExecuted),
          String(r.e.CycleRetired),
        ])
      );
      expect(errors).toEqual([]);
      expect(n).toBeGreaterThan(0);
    });

    test(`${name} (${via}): heatmap headers, cells, and table match the JSON`, async ({ page }) => {
      const errors = await open(page, via, `${name}.json`);
      await expect(page.locator('#out')).toBeVisible();
      const j = fixture(name);
      const asm = j.CodeRegions[0].Instructions;
      const resources = j.TargetInfo.Resources;
      const matrix = expectedMatrix(j);

      // headers: exact names, no control characters
      const heads = await page.locator('#heatmap svg text.col').allTextContents();
      expect(heads.length).toBeGreaterThan(0);
      expect(heads).toEqual(resources.map(label));
      expect(heads.filter((t) => /[\u0000-\u001f]/.test(t))).toEqual([]);

      // each header centred on its column (column centre = 100 + 10j + 4.5)
      const centres = await page.locator('#heatmap svg text.col').evaluateAll((els) => {
        const left = els[0].ownerSVGElement.getBoundingClientRect().left;
        return els.map((e) => {
          const b = e.getBoundingClientRect();
          return (b.left + b.right) / 2 - left;
        });
      });
      centres.forEach((c, j2) => expect(Math.abs(c - (104.5 + CELL * j2)), `header ${j2}`).toBeLessThan(1));

      // every non-zero cell is drawn with its value, and no others
      const cells = await page.locator('#heatmap svg rect[data-cy]').evaluateAll((els) =>
        els.map((r) => ({ cy: r.getAttribute('data-cy'), x: r.getAttribute('x'), y: r.getAttribute('y'), title: r.querySelector('title').textContent }))
      );
      const want = [];
      matrix.forEach((row, i) => row.forEach((v, k) => {
        if (v !== 0) want.push({ cy: `${i},${k}`, x: String(100 + k * CELL), y: String(HEAD + i * CELL), title: `${rowName(asm, i)}, ${label(resources[k])}: ${nd(v)}` });
      }));
      expect(want.length).toBeGreaterThan(0);
      expect(cells).toEqual(want);

      // the table view lists every cell, zeros included
      const table = await page.locator('#heatmap-table tr').evaluateAll((trs) =>
        trs.map((tr) => [...tr.children].map((c) => c.textContent))
      );
      expect(table[0]).toEqual(['Instruction', ...resources.map(label)]);
      expect(table.slice(1)).toEqual(matrix.map((row, i) => [rowName(asm, i), ...row.map(nd)]));
      expect(errors).toEqual([]);
    });

    test(`${name} (${via}): stage colors are distinct and meet 3:1 on the rendered cells`, async ({ page }) => {
      await open(page, via, `${name}.json`);
      await expect(page.locator('#out')).toBeVisible();

      // the legend names all four stages in order, each with the color its cells use
      const legend = await page.locator('#legend span').evaluateAll((els) =>
        els.map((s) => [s.textContent, getComputedStyle(s.querySelector('i')).backgroundColor])
      );
      expect(legend.map((l) => l[0])).toEqual(STAGES);
      const colorOf = Object.fromEntries(legend.map(([s, c]) => [s, c]));

      const fills = await page.locator('#timeline svg rect').evaluateAll((els) =>
        els.map((r) => [r.querySelector('title').textContent.match(/, (\w+): /)[1], getComputedStyle(r).fill])
      );
      expect(fills.length).toBeGreaterThan(0);
      for (const [stage, fill] of fills) expect(fill, `${stage} cell color`).toBe(colorOf[stage]);
      for (const stage of STAGES) expect(fills.some(([s]) => s === stage), `${stage} cells rendered`).toBe(true);

      const lum = (rgb) => {
        const c = rgb.match(/\d+/g).slice(0, 3).map((v) => {
          const x = Number(v) / 255;
          return x <= 0.03928 ? x / 12.92 : ((x + 0.055) / 1.055) ** 2.4;
        });
        return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2];
      };
      const ratio = (a, b) => {
        const [hi, lo] = [lum(a), lum(b)].sort((x, y) => y - x);
        return (hi + 0.05) / (lo + 0.05);
      };
      const white = 'rgb(255, 255, 255)';
      for (let k = 0; k < STAGES.length; k++) {
        expect(ratio(colorOf[STAGES[k]], white), `${STAGES[k]} against white`).toBeGreaterThanOrEqual(3);
        if (k > 0) {
          expect(ratio(colorOf[STAGES[k - 1]], colorOf[STAGES[k]]), `${STAGES[k - 1]} next to ${STAGES[k]}`).toBeGreaterThanOrEqual(3);
        }
      }
    });
  }
}

test('znver4-i100: the notice is visible and names the iteration cap', async ({ page }) => {
  const errors = await open(page, 'picker', 'znver4-i100.json');
  await expect(page.locator('#out')).toBeVisible();
  await expect(page.locator('#notice')).toBeVisible();
  await expect(page.locator('#notice')).toHaveText(
    "Showing 10 of 100 iterations. llvm-mca's iteration cap (-timeline-max-iterations, default 10) or cycle cap (-timeline-max-cycles, default 80) cut the timeline. The file does not say which. Rerun with higher values, or 0 for no cycle limit."
  );
  await expect(page.locator('#timeline svg text.row')).toHaveCount(40);
  expect(errors).toEqual([]);
});

test('znver4-cap18: the notice is visible and names the cycle cap', async ({ page }) => {
  const errors = await open(page, 'drop', 'znver4-cap18.json');
  await expect(page.locator('#out')).toBeVisible();
  await expect(page.locator('#notice')).toBeVisible();
  await expect(page.locator('#notice')).toHaveText(
    "Showing 4 of 10 iterations. llvm-mca's cycle cap (-timeline-max-cycles, default 80) cut the timeline. Rerun with a higher value, or 0 for no cycle limit."
  );
  await expect(page.locator('#timeline svg text.row')).toHaveCount(17);
  expect(errors).toEqual([]);
});

test('a slower File.text() from an older drop cannot overwrite a newer one', async ({ page }) => {
  const seen = [];
  page.on('console', (m) => seen.push(m.text()));
  await page.goto('/');
  await page.evaluate(() => {
    const orig = File.prototype.text;
    File.prototype.text = function () {
      // the first drop is slow to read; File.text() normally resolves before
      // the next drop lands, so push it to a task queue to force the overlap
      console.log('TEXT-CALLED', this.name);
      return new Promise((r) => setTimeout(() => r(orig.call(this)), this.name === 'znver4-i100.json' ? 400 : 0));
    };
  });
  const dropFile = async (name) => {
    const dt = await page.evaluateHandle(
      ({ name, bytes }) => {
        const d = new DataTransfer();
        d.items.add(new File([Uint8Array.from(bytes)], name, { type: 'application/json' }));
        return d;
      },
      { name: `${name}.json`, bytes: [...readFileSync(`test/fixtures/${name}.json`)] }
    );
    // drop without awaiting its load: dispatchEvent resolves with the event,
    // not with the async load()
    await page.locator('#drop').dispatchEvent('drop', { dataTransfer: dt });
  };
  await dropFile('znver4-i100');
  await dropFile('znver4');
  // settle: enough for the stale load to overwrite the DOM if the bug were present
  await page.waitForTimeout(700);
  expect(await page.locator('#timeline svg text.row').count()).toBe(12);
  expect(await page.locator('#notice').isHidden()).toBe(true);
  expect(seen.filter((s) => s.startsWith('TEXT-CALLED'))).toEqual(['TEXT-CALLED znver4-i100.json', 'TEXT-CALLED znver4.json']);
});

test('both text tables get col and row header scopes', async ({ page }) => {
  await open(page, 'drop', 'znver4.json');
  for (const id of ['#timeline-table', '#heatmap-table']) {
    const bodyRows = page.locator(`${id} table tr:not(:first-child)`);
    expect(await bodyRows.count()).toBeGreaterThan(0);
    await expect(page.locator(`${id} table tr:first-child th[scope=col]`)).toHaveCount(
      await page.locator(`${id} table tr:first-child th`).count()
    );
    for (const tr of await bodyRows.all()) {
      const first = tr.locator(':scope > :first-child');
      await expect(first).toHaveJSProperty('tagName', 'TH');
      await expect(first).toHaveAttribute('scope', 'row');
    }
  }
});

test('800px viewport scrolls wide tables inside their container, not the page', async ({ page }) => {
  await page.setViewportSize({ width: 800, height: 900 });
  await open(page, 'drop', 'znver4-i100.json');
  await expect(page.locator('#out')).toBeVisible();
  const doc = await page.evaluate(() => ({
    scroll: document.documentElement.scrollWidth,
    client: document.documentElement.clientWidth,
  }));
  expect(doc.scroll).toBeLessThanOrEqual(doc.client);
});

test('skylake-idivq: a cap that cuts the first row shows a message, not a broken SVG', async ({ page }) => {
  const errors = await open(page, 'drop', 'skylake-idivq.json');
  await expect(page.locator('#out')).toBeVisible();
  await expect(page.locator('#timeline')).toHaveText(
    'No instruction retired within the cycle cap, so there is no timeline to draw. Raise -timeline-max-cycles.'
  );
  await expect(page.locator('#notice')).toHaveText(
    "Showing 0 of 3 iterations. llvm-mca's cycle cap (-timeline-max-cycles, default 80) cut the timeline. Rerun with a higher value, or 0 for no cycle limit."
  );
  expect(await page.locator('svg[width*="Infinity"], svg[height*="Infinity"]').count()).toBe(0);
  expect(errors).toEqual([]);
});

for (const via of ['drop', 'picker']) {
  test(`malformed JSON (${via}) shows a SyntaxError message`, async ({ page }) => {
    await open(page, via, 'malformed.json');
    await expect(page.locator('#error')).toBeVisible();
    await expect(page.locator('#error')).toHaveText(/^SyntaxError: /);
    await expect(page.locator('#out')).toBeHidden();
  });

  test(`wrong-schema JSON (${via}) shows a TimelineMappingError message`, async ({ page }) => {
    await open(page, via, 'wrong-schema.json');
    await expect(page.locator('#error')).toBeVisible();
    await expect(page.locator('#error')).toHaveText(/^TimelineMappingError: /);
    await expect(page.locator('#out')).toBeHidden();
  });
}

test('800px viewport keeps the drop zone inside the viewport', async ({ page }) => {
  await page.setViewportSize({ width: 800, height: 900 });
  await page.goto('/');
  const box = await page.locator('#drop').boundingBox();
  expect(box.x).toBeGreaterThan(0);
  expect(box.x + box.width).toBeLessThan(800);
});

test('first Tab lands on the file input', async ({ page }) => {
  await page.goto('/');
  await page.keyboard.press('Tab');
  await expect(page.locator('#file')).toBeFocused();
});

// ---------------------------------------------------------------------------
// Item 7: paste box, .s drop/pick, CPU dropdown, lazy WASM llvm-mca.
// The fixture loop is the 4-instruction loop.s; iterations=3 matches the
// committed fixtures. The inputs are the ones shared with wasm/fixture-cases.json.
const ASM_CASES = [
  { file: 'loop.s', json: 'znver4.json', cpu: 'znver4' },
  { file: 'loop.s', json: 'skylake.json', cpu: 'skylake' },
  { file: 'loop_a64.s', json: 'neoverse-v2.json', cpu: 'neoverse-v2' },
];
const readFixture = (name) => readFileSync(`test/fixtures/${name}`, 'utf8');

async function dropFile(page, name, text) {
  const dt = await page.evaluateHandle(
    ({ name, bytes }) => {
      const d = new DataTransfer();
      d.items.add(new File([Uint8Array.from(bytes)], name));
      return d;
    },
    { name, bytes: [...Buffer.from(text)] }
  );
  await page.locator('#drop').dispatchEvent('drop', { dataTransfer: dt });
}

// Compare the whole rendered model: every timeline rect and every heatmap cell.
async function expectModelMatchesFixture(page, jsonName) {
  const j = fixture(jsonName.replace(/\.json$/, ''));
  const rows = expectedRows(j);
  expect(await page.locator('#timeline svg text.row').allTextContents())
    .toEqual(rows.map((r) => `[${r.iter},${r.instr}]`));
  const rects = await page.locator('#timeline svg rect').evaluateAll((els) =>
    els.map((r) => ({ x: r.getAttribute('x'), y: r.getAttribute('y'), width: r.getAttribute('width') }))
  );
  expect(rects).toEqual(expectedRects(j).map(({ x, y, width }) => ({ x, y, width })));
  const cells = await page.locator('#heatmap svg rect[data-cy]').evaluateAll((els) =>
    els.map((r) => ({ cy: r.getAttribute('data-cy'), title: r.querySelector('title').textContent }))
  );
  const want = [];
  const asmList = j.CodeRegions[0].Instructions;
  expectedMatrix(j).forEach((row, i) => row.forEach((v, k) => {
    if (v !== 0) want.push({ cy: `${i},${k}`, title: `${rowName(asmList, i)}, ${label(j.TargetInfo.Resources[k])}: ${nd(v)}` });
  }));
  expect(cells).toEqual(want);
}

test('before the WASM resolves, typing and CPU picking work and Run shows progress', async ({ page }) => {
  let release;
  const hold = new Promise((r) => (release = r));
  await page.route('**/wasm/dist/llvm-mca.wasm', async (route) => {
    await hold;
    const res = await route.fetch();
    route.fulfill({ response: res });
  });
  const errors = [];
  page.on('pageerror', (e) => errors.push(e.message));
  await page.goto('/');
  await expect(page.locator('#run')).toBeDisabled();
  await expect(page.locator('#run')).toHaveText(/Loading llvm-mca/);
  await page.locator('#asm').fill('loop:\n  nop\n  jne loop');
  await expect(page.locator('#asm')).toHaveValue('loop:\n  nop\n  jne loop');
  const cpus = page.locator('#cpu option');
  await expect(cpus).toHaveCount(221);
  await expect(page.locator('#cpu optgroup')).toHaveCount(3);
  await page.locator('#cpu').selectOption('skylake');
  await expect(page.locator('#cpu')).toHaveValue('skylake');
  release();
  await expect(page.locator('#run')).toHaveText('Run');
  await expect(page.locator('#run')).toBeEnabled();
  expect(errors).toEqual([]);
});

for (const c of ASM_CASES) {
  test(`run pasted ${c.cpu} loop renders the same model as dropping ${c.json}`, async ({ page }) => {
    const errors = [];
    page.on('pageerror', (e) => errors.push(e.message));
    await page.goto('/');
    await page.locator('#asm').fill(readFixture(c.file));
    await page.locator('#cpu').selectOption(c.cpu);
    await page.locator('#iterations').fill('3');
    await page.locator('#run').click();
    await expect(page.locator('#out')).toBeVisible({ timeout: 60000 });
    await expect(page.locator('#error')).toBeHidden();
    await expectModelMatchesFixture(page, c.json);
    expect(errors).toEqual([]);
  });

  test(`dropping ${c.file} fills the paste box, runs, and matches ${c.json}`, async ({ page }) => {
    await page.goto('/');
    await expect(page.locator('#run')).toBeEnabled({ timeout: 60000 });
    await page.locator('#cpu').selectOption(c.cpu);
    await page.locator('#iterations').fill('3');
    await dropFile(page, c.file, readFixture(c.file));
    await expect(page.locator('#asm')).toHaveValue(readFixture(c.file));
    await expect(page.locator('#out')).toBeVisible({ timeout: 60000 });
    await expectModelMatchesFixture(page, c.json);
  });
}

test('picking a .s file fills the paste box and runs', async ({ page }) => {
  await page.goto('/');
  await expect(page.locator('#run')).toBeEnabled({ timeout: 60000 });
  await page.locator('#cpu').selectOption('skylake');
  await page.locator('#iterations').fill('3');
  await page.locator('#file').setInputFiles('test/fixtures/loop.s');
  await expect(page.locator('#asm')).toHaveValue(readFixture('loop.s'));
  await expect(page.locator('#out')).toBeVisible({ timeout: 60000 });
  await expectModelMatchesFixture(page, 'skylake.json');
});

test('invalid asm shows llvm-mca\u2019s error, and a later valid run clears it', async ({ page }) => {
  await page.goto('/');
  await expect(page.locator('#run')).toBeEnabled({ timeout: 60000 });
  await page.locator('#iterations').fill('3');
  await page.locator('#asm').fill('notaninstruction %eax\n');
  await page.locator('#run').click();
  await expect(page.locator('#error')).toBeVisible({ timeout: 60000 });
  await expect(page.locator('#error')).toContainText("error: invalid instruction mnemonic 'notaninstruction'");
  await expect(page.locator('#out')).toBeHidden();
  await page.locator('#asm').fill(readFixture('loop.s'));
  await page.locator('#run').click();
  await expect(page.locator('#out')).toBeVisible({ timeout: 60000 });
  await expect(page.locator('#error')).toBeHidden();
  await expectModelMatchesFixture(page, 'znver4.json');
});
