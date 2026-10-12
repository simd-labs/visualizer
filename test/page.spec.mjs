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
  // pre-wrap keeps llvm-mca's source line and caret on their own lines
  await expect(page.locator('#error')).toHaveCSS('white-space', 'pre-wrap');
  await page.locator('#asm').fill(readFixture('loop.s'));
  await page.locator('#run').click();
  await expect(page.locator('#out')).toBeVisible({ timeout: 60000 });
  await expect(page.locator('#error')).toBeHidden();
  await expectModelMatchesFixture(page, 'znver4.json');
});

// ---------------------------------------------------------------------------
// Item 9: CPU flow diagram driven by -issue-events.
// Hand-computed token positions for znver4 at cycle 2, from
// znver4.issue.json's timeline rows and issue events (every unit is held for
// exactly one cycle on this fixture). Expected shape: [instr, iter, stage,
// busy units].
const Z4_CYCLE2 = [
  [0, 0, 'execute', []], [1, 0, 'waiting', []], [2, 0, 'retire', []], [3, 0, 'execute', [7]],
  [0, 1, 'execute', [12, 16, 19]], [1, 1, 'waiting', []], [2, 1, 'execute', [5]], [3, 1, 'waiting', []],
  [0, 2, 'waiting', []], [1, 2, 'waiting', []], [2, 2, 'waiting', []], [3, 2, 'waiting', []],
];

test('flow diagram: tokens land on their events units at cycle 2, slider moves the timeline highlight', async ({ page }) => {
  const errors = [];
  page.on('pageerror', (e) => errors.push(e.message));
  await page.goto('/');
  await page.locator('#asm').fill(readFixture('loop.s'));
  await page.locator('#cpu').selectOption('znver4');
  await page.locator('#iterations').fill('3');
  await page.locator('#run').click();
  await expect(page.locator('#out')).toBeVisible({ timeout: 60000 });

  // blocks: dispatch, two scheduler queues, one box per execution unit, retire
  const blocks = await page.locator('#flow svg .flow-block').evaluateAll((els) => els.map((g) => g.dataset.block));
  expect(blocks).toEqual(['dispatch', 'waiting', 'ready', 'execute', 'retire']);
  const nUnits = fixture('znver4').TargetInfo.Resources.length;
  await expect(page.locator('#flow svg .flow-unit')).toHaveCount(nUnits);
  // unit names must be legible (7px was not) and fit inside their box
  const unitText = await page.locator('#flow svg .flow-unit').evaluateAll((gs) =>
    gs.map((g) => {
      const t = g.querySelector('text');
      return { size: +t.getAttribute('font-size'), w: t.getComputedTextLength(), box: g.querySelector('rect').getBBox().width };
    })
  );
  for (const u of unitText) {
    expect(u.size).toBeGreaterThanOrEqual(9);
    expect(u.w).toBeLessThan(u.box - 3);
  }

  await page.locator('#flow-cycle').fill('2');
  await page.locator('#flow-cycle').dispatchEvent('input');
  const tokens = await page.locator('#flow svg .flow-token').evaluateAll((els) =>
    els.map((g) => ({
      instr: +g.dataset.instr,
      iter: +g.dataset.iter,
      block: g.dataset.block,
      units: g.dataset.units === '' ? [] : g.dataset.units.split(' ').map(Number),
    }))
  );
  const want = Z4_CYCLE2.map(([instr, iter, stage, units]) => ({
    instr,
    iter,
    block: stage,
    units,
  }));
  const key = (t) => `${t.instr},${t.iter}`;
  expect(tokens.map(key).sort()).toEqual(want.map(key).sort());
  for (const w of want) {
    const g = tokens.find((t) => t.instr === w.instr && t.iter === w.iter);
    expect(g.block, `${key(w)} block`).toBe(w.block);
    expect(g.units, `${key(w)} units`).toEqual(w.units);
  }
  // executing token sits on its first busy unit's box
  const t31 = tokens.find((t) => t.instr === 3 && t.iter === 0);
  expect(t31.units).toEqual([7]);
  const tokRect = await page.locator('#flow svg .flow-token', { hasText: '0:3' }).locator('rect');
  const unitRect = await page.locator('#flow svg .flow-unit[data-unit="7"] rect').boundingBox();
  const tokBox = await tokRect.boundingBox();
  expect(Math.abs(tokBox.x + tokBox.width / 2 - (unitRect.x + unitRect.width / 2))).toBeLessThan(2);

  // timeline highlight follows the slider, drawn over a white halo so it stays visible on the bars
  const hl = page.locator('#timeline line.flow-cur');
  await expect(hl).toHaveCount(1);
  await expect(page.locator('#timeline line.flow-halo')).toHaveCount(1);
  const x2 = await hl.getAttribute('x1');
  expect(+x2).toBeCloseTo(LEFT + 2 * CELL - CELL / 2);
  await page.locator('#flow-cycle').fill('9');
  await page.locator('#flow-cycle').dispatchEvent('input');
  const x9 = await page.locator('#timeline line.flow-cur').getAttribute('x1');
  expect(+x9).toBeCloseTo(LEFT + 9 * CELL - CELL / 2);
  expect(+x9).not.toBe(+x2);

  // aria-live line states the cycle and units
  await expect(page.locator('#flow-status')).toContainText('Cycle 9.');
  await expect(page.locator('#flow-status')).toContainText('executing on Zn4FP1');
  expect(errors).toEqual([]);
});

// After its unit hold ends and before its executed cycle, the load token is
// still executing: instr 0 issued cycle 1, held 1 cycle, executed cycle 9.
test('flow diagram: a token past its hold draws in execution with the latency style', async ({ page }) => {
  const errors = [];
  page.on('pageerror', (e) => errors.push(e.message));
  await page.goto('/');
  await page.locator('#asm').fill(readFixture('loop.s'));
  await page.locator('#cpu').selectOption('znver4');
  await page.locator('#iterations').fill('3');
  await page.locator('#run').click();
  await expect(page.locator('#out')).toBeVisible({ timeout: 60000 });

  await page.locator('#flow-cycle').fill('2');
  await page.locator('#flow-cycle').dispatchEvent('input');
  const tok = page.locator('#flow svg .flow-token[data-instr="0"][data-iter="0"]');
  await expect(tok).toHaveAttribute('data-block', 'execute');
  await expect(tok).toHaveAttribute('data-units', '');
  await expect(tok).toHaveAttribute('data-latency', '1');
  const rect = tok.locator('rect');
  await expect(rect).toHaveAttribute('stroke-dasharray', '2 2');
  await expect(rect).toHaveAttribute('opacity', '0.6');
  // hollow, so the shape differs from a solid active token, not just its brightness
  await expect(rect).toHaveAttribute('fill', '#fff');
  // stacked on the event's last unit
  const unitBox = await page.locator('#flow svg .flow-unit[data-unit="20"]').boundingBox();
  const tokBox = await tok.boundingBox();
  expect(Math.abs(tokBox.x + tokBox.width / 2 - (unitBox.x + unitBox.width / 2))).toBeLessThan(2);
  expect(Math.abs(tokBox.y + tokBox.height / 2 - (unitBox.y + unitBox.height / 2))).toBeLessThan(2);
  await expect(tok.locator('title')).toContainText('executing (latency), last on Zn4Load.2');
  await expect(page.locator('#flow-status')).toContainText('Executing (latency), last on Zn4Load.2.');
  expect(errors).toEqual([]);
});

test('flow diagram from a dropped JSON without issue events shows the notice', async ({ page }) => {
  const errors = await open(page, 'picker', 'znver4.json'); // native fixture: no IssueEventView
  await expect(page.locator('#out')).toBeVisible();
  await expect(page.locator('#flow-notice')).toBeVisible();
  await expect(page.locator('#flow-notice')).toContainText('no issue events');
  await expect(page.locator('#flow svg')).toHaveCount(0);
  await expect(page.locator('#flow-cycle')).toBeDisabled();
  // the timeline and heatmap still rendered
  await expect(page.locator('#timeline svg text.row')).toHaveCount(12);
  expect(errors).toEqual([]);
});

// Each run used to add another slider listener that drew the previous model;
// a second run then threw getAttribute on null unit boxes.
test('flow slider keeps working across runs with different CPUs', async ({ page }) => {
  const errors = [];
  page.on('pageerror', (e) => errors.push(e.message));
  await page.goto('/');
  for (const [asm, cpu] of [['loop.s', 'znver4'], ['loop.s', 'skylake'], ['loop_a64.s', 'neoverse-v2']]) {
    await page.locator('#asm').fill(readFixture(asm));
    await page.locator('#cpu').selectOption(cpu);
    await page.locator('#iterations').fill('3');
    await page.locator('#run').click();
    await expect(page.locator('#out')).toBeVisible({ timeout: 60000 });
    await page.locator('#flow-cycle').fill('5');
    await page.locator('#flow-cycle').dispatchEvent('input');
    await expect(page.locator('#flow-status')).toContainText('Cycle 5.');
  }
  expect(errors).toEqual([]);
});

// Two tokens on one unit at the same cycle must not share a spot. skylake at
// cycle 3 puts 0:0 (latency) and 2:0 on SKLPort0 together.
test('flow diagram: tokens sharing a unit at one cycle are drawn at separate spots', async ({ page }) => {
  await page.goto('/');
  await page.locator('#asm').fill(readFixture('loop.s'));
  await page.locator('#cpu').selectOption('skylake');
  await page.locator('#iterations').fill('3');
  await page.locator('#run').click();
  await expect(page.locator('#out')).toBeVisible({ timeout: 60000 });
  await page.locator('#flow-cycle').fill('3');
  await page.locator('#flow-cycle').dispatchEvent('input');
  const spots = await page.locator('#flow svg .flow-token rect').evaluateAll((rs) =>
    rs.map((r) => `${r.getAttribute('x')},${r.getAttribute('y')}`)
  );
  expect(spots.length).toBeGreaterThan(0);
  expect(new Set(spots).size).toBe(spots.length);
});

// ---------------------------------------------------------------------------
// Fix4: readiness, failure, supersede, containment and text-equivalent coverage.

async function holdWasm(page) {
  let release;
  const hold = new Promise((r) => (release = r));
  await page.route('**/wasm/dist/llvm-mca.wasm', async (route) => {
    await hold;
    route.fulfill({ response: await route.fetch() });
  });
  await page.goto('/');
  return release;
}

test('a .s file dropped while the WASM loads runs automatically once ready', async ({ page }) => {
  const errors = [];
  page.on('pageerror', (e) => errors.push(e.message));
  const release = await holdWasm(page);
  await expect(page.locator('#run')).toBeDisabled();
  await dropFile(page, 'loop.s', readFixture('loop.s'));
  await expect(page.locator('#asm')).toHaveValue(readFixture('loop.s'));
  release();
  await expect(page.locator('#out')).toBeVisible({ timeout: 60000 });
  // default CPU znver4, 100 iterations: the timeline shows the iteration cap's 40 rows
  await expect(page.locator('#timeline svg text.row')).toHaveCount(40);
  expect(errors).toEqual([]);
});

test('a newer drop supersedes a .s dropped while the WASM loads', async ({ page }) => {
  const release = await holdWasm(page);
  await dropFile(page, 'loop.s', readFixture('loop.s'));
  await dropFile(page, 'znver4.json', readFixture('znver4.json'));
  release();
  // the JSON drop wins: out shows the fixture's 12 timeline rows, no run happens
  await expect(page.locator('#out')).toBeVisible({ timeout: 60000 });
  await expect(page.locator('#timeline svg text.row')).toHaveCount(12);
  await expect(page.locator('#run')).toBeEnabled({ timeout: 60000 });
});

test('a worker that fails to load shows the error and keeps the page usable', async ({ page }) => {
  const errors = [];
  page.on('pageerror', (e) => errors.push(e.message));
  await page.route('**/wasm/dist/llvm-mca.wasm', (route) => route.fulfill({ status: 404, body: 'gone' }));
  await page.goto('/');
  await expect(page.locator('#error')).toBeVisible();
  await expect(page.locator('#error')).toContainText(/404|failed/i);
  await expect(page.locator('#run')).toBeDisabled();
  await expect(page.locator('#run')).toHaveText('llvm-mca failed to load');
  // the page still works for JSON loads
  await dropFile(page, 'znver4.json', readFixture('znver4.json'));
  await expect(page.locator('#out')).toBeVisible();
  await expect(page.locator('#timeline svg text.row')).toHaveCount(12);
  expect(errors).toEqual([]);
});

test('pasting assembly while the WASM loads leaves Run disabled and does not throw', async ({ page }) => {
  const errors = [];
  page.on('pageerror', (e) => errors.push(e.message));
  await holdWasm(page); // never released: the module stays 'loading'
  await expect(page.locator('#run')).toBeDisabled();
  await page.locator('#asm').fill('loop:\n  nop\n  jne loop');
  await expect(page.locator('#cpu')).toHaveValue('znver4');
  await expect(page.locator('#out')).toBeHidden();
  await expect(page.locator('#error')).toBeHidden();
  expect(errors).toEqual([]);
});

test('Step after loading a no-events JSON neither throws nor draws', async ({ page }) => {
  const errors = [];
  page.on('pageerror', (e) => errors.push(e.message));
  await page.goto('/');
  await page.locator('#asm').fill(readFixture('loop.s'));
  await page.locator('#cpu').selectOption('znver4');
  await page.locator('#iterations').fill('3');
  await page.locator('#run').click();
  await expect(page.locator('#out')).toBeVisible({ timeout: 60000 });
  await expect(page.locator('#flow svg')).toHaveCount(1);
  // now load the no-events JSON: the diagram and its handlers must go away
  await dropFile(page, 'znver4.json', readFixture('znver4.json'));
  await expect(page.locator('#flow svg')).toHaveCount(0);
  await expect(page.locator('#flow-step')).toBeDisabled();
  await expect(page.locator('#flow-play')).toBeDisabled();
  await expect(page.locator('#flow-cycle')).toBeDisabled();
  // a programmatic .click() bypasses the disabled attribute; the handler must be gone or a no-op
  await page.evaluate(() => document.getElementById('flow-step').click());
  await page.evaluate(() => document.getElementById('flow-cycle').dispatchEvent(new Event('input')));
  await page.waitForTimeout(50);
  await expect(page.locator('#flow-status')).toHaveText('No issue events.');
  expect(errors).toEqual([]);
});

test('iterations outside min/max is rejected with a local validation error', async ({ page }) => {
  await page.goto('/');
  await expect(page.locator('#run')).toBeEnabled({ timeout: 60000 });
  await page.locator('#asm').fill(readFixture('loop.s'));
  for (const bad of ['0', '10001']) {
    await page.locator('#iterations').fill(bad);
    await page.locator('#run').click();
    await expect(page.locator('#error')).toBeVisible();
    await expect(page.locator('#error')).toContainText('Iterations must be an integer between 1 and 10000');
    await expect(page.locator('#out')).toBeHidden();
  }
});

test('JSON with leading whitespace and a BOM renders as JSON', async ({ page }) => {
  await page.goto('/');
  const padded = '\ufeff   \n  ' + readFixture('znver4.json');
  await dropFile(page, 'znver4-padded.json', padded);
  await expect(page.locator('#out')).toBeVisible();
  await expect(page.locator('#timeline svg text.row')).toHaveCount(12);
  await expect(page.locator('#asm')).toHaveValue('');
});

test('flow tokens stay inside their blocks for a 100-iteration run', async ({ page }) => {
  const errors = [];
  page.on('pageerror', (e) => errors.push(e.message));
  await page.goto('/');
  await page.locator('#asm').fill(readFixture('loop.s'));
  await page.locator('#cpu').selectOption('znver4');
  await page.locator('#iterations').fill('100');
  await page.locator('#run').click();
  await expect(page.locator('#out')).toBeVisible({ timeout: 60000 });
  await expect(page.locator('#flow svg')).toHaveCount(1);
  // sample cycles across the drawn run (the timeline cap keeps 40 rows, so
  // the flow spans cycles 0..23): every token rect must sit inside its block
  for (const cycle of ['0', '1', '5', '11', '17', '23']) {
    await page.locator('#flow-cycle').fill(cycle);
    await page.locator('#flow-cycle').dispatchEvent('input');
    const bad = await page.evaluate(() => {
      const blocks = {};
      for (const g of document.querySelectorAll('#flow svg .flow-block')) {
        const r = g.querySelector('rect').getBoundingClientRect();
        blocks[g.dataset.block] = r;
      }
      const out = [];
      for (const g of document.querySelectorAll('#flow svg .flow-token')) {
        const t = g.querySelector('rect').getBoundingClientRect();
        const b = blocks[g.dataset.block];
        if (t.left < b.left - 1 || t.right > b.right + 1 || t.top < b.top - 1 || t.bottom > b.bottom + 1) {
          out.push(g.dataset.instr + ':' + g.dataset.iter);
        }
      }
      return out;
    });
    expect(bad, `cycle ${cycle} tokens outside their block`).toEqual([]);
  }
  expect(errors).toEqual([]);

  // a crowded unit grows its own rows: skylake cycle 3 puts two tokens on
  // SKLPort0; tokens with a busy unit must sit inside that unit's rect
  await page.locator('#cpu').selectOption('skylake');
  await page.locator('#run').click();
  await expect(page.locator('#flow')).not.toHaveText('', { timeout: 60000 });
  await page.locator('#flow-cycle').fill('3');
  await page.locator('#flow-cycle').dispatchEvent('input');
  const offUnit = await page.evaluate(() => {
    const bad = [];
    for (const g of document.querySelectorAll('#flow svg .flow-token')) {
      if (g.dataset.units === '') continue;
      const parked = +g.dataset.units.split(' ')[0];
      const unit = document.querySelector(`#flow svg .flow-unit[data-unit="${parked}"] rect`).getBoundingClientRect();
      const r = g.querySelector('rect').getBoundingClientRect();
      if (r.top < unit.top - 1 || r.bottom > unit.bottom + 1) bad.push(g.dataset.instr + ':' + g.dataset.iter);
    }
    return bad;
  });
  expect(offUnit).toEqual([]);
  // the two tokens sharing a unit at this cycle must have distinct rows in it:
  // the unit row hides its overflow only when the extra rows exist
  const shared = await page.evaluate(() => {
    const spots = {};
    for (const g of document.querySelectorAll('#flow svg .flow-token')) {
      if (g.dataset.units === '') continue;
      const u = g.dataset.units.split(' ')[0];
      const r = g.querySelector('rect');
      (spots[u] = spots[u] || []).push(r.getAttribute('y'));
    }
    return Object.entries(spots).filter(([, ys]) => new Set(ys).size !== ys.length).map(([u]) => u);
  });
  expect(shared, 'a unit drew two tokens on the same row').toEqual([]);
});

test('the flow text list matches the tokens of the current cycle', async ({ page }) => {
  await page.goto('/');
  await page.locator('#asm').fill(readFixture('loop.s'));
  await page.locator('#cpu').selectOption('znver4');
  await page.locator('#iterations').fill('3');
  await page.locator('#run').click();
  await expect(page.locator('#out')).toBeVisible({ timeout: 60000 });
  await page.locator('#flow-cycle').fill('2');
  await page.locator('#flow-cycle').dispatchEvent('input');
  const tokens = await page.locator('#flow svg .flow-token').evaluateAll((els) =>
    els.map((g) => `${g.dataset.block}:${g.dataset.instr}:${g.dataset.iter}`)
  );
  const lines = await page.locator('#flow-list li').allTextContents();
  expect(lines.length).toBe(tokens.length);
  expect(lines.length).toBe(12); // every in-flight instruction at cycle 2
  for (const t of tokens) {
    const [block, instr, iter] = t.split(':');
    const li = lines.find((l) => l.startsWith(`${block}: `) && l.includes(` ${iter}:${instr} `));
    expect(li, `list line for ${t}`).toBeTruthy();
  }
  // the multi-resource instruction at cycle 1 lists all three of its units
  await page.locator('#flow-cycle').fill('1');
  await page.locator('#flow-cycle').dispatchEvent('input');
  const line00 = (await page.locator('#flow-list li').allTextContents()).find((l) => l.includes(' 0:0 '));
  expect(line00).toContain('Zn4FP45');
  expect(line00).toContain('Zn4LSU');
  expect(line00).toContain('Zn4Load');
});

// The znver4 load holds three units at cycle 1; its solid token parks on the
// first (Zn4FP45 = 13), so the other two (17, 20) must carry its marker
// instead of looking empty.
// M5: a fault inside the worker must not hang the pending run. Both tests
// wait on the module load first (#run stays disabled until it is ready), so
// the timeout is the only browser work they ever do. Per-test timeout: on the
// unfixed code the run promise never settles and the 5s assertion window
// passes, so the test must die on its own timer, not the suite's.
const runAndFail = async (page) => {
  await page.goto('/');
  // an empty source rejects before the worker runs; give it real input
  await page.locator('#asm').fill(readFixture('loop.s'));
  await expect(page.locator('#run')).toBeEnabled({ timeout: 60000 });
  await page.locator('#run').click();
  await expect(page.locator('#error')).toBeVisible({ timeout: 5000 });
  await expect(page.locator('#error')).toContainText(/\S/, { timeout: 5000 });
  await expect(page.locator('#run')).toBeEnabled({ timeout: 5000 });
  await expect(page.locator('#run')).toHaveText('Run');
};

test('a wasm instantiation failure rejects the run and shows the error', { timeout: 15000 }, async ({ page }) => {
  // V8 validates the whole module at compile so corrupt bytes can never get
  // as far as instantiate in 2026; force the failure where it matters, in the
  // worker's instantiateWasm callback, by replacing WebAssembly.instantiate
  // for Module instances once (the worker's own compile needs the original).
  await page.route('**/wasm/dist/llvm-mca.js', async (route) => {
    const res = await route.fetch();
    const js = await res.text();
    const sabotage =
      'const __inst = WebAssembly.instantiate.bind(WebAssembly);' +
      'WebAssembly.instantiate = (m, i) => (m instanceof WebAssembly.Module ' +
      '  ? Promise.reject(new WebAssembly.LinkError("injected link failure")) ' +
      '  : __inst(m, i));';
    route.fulfill({ response: res, body: sabotage + js });
  });
  await runAndFail(page);
});

test('a runtime abort inside the worker rejects the run and shows the error', { timeout: 15000 }, async ({ page }) => {
  // Force an uncaught runtime throw in the worker while a run is pending:
  // wrap the worker script so its result post is replaced by a thrown
  // WebAssembly.RuntimeError on a macrotask, the way an async wasm trap or a
  // late llvm-mca abort reaches the page. A corrupt code section crashes the
  // whole tab instead, so it cannot serve here.
  await page.route('**/src/mca-worker.js', async (route) => {
    const res = await route.fetch();
    const body = (await res.text())
      + '\nconst __post = postMessage.bind(globalThis);'
      + 'globalThis.postMessage = (m) => {'
      + '  if (m.type === "result") { setTimeout(() => { throw new WebAssembly.RuntimeError("injected runtime trap"); }); return; }'
      + '  __post(m);'
      + '};';
    route.fulfill({ response: res, body });
  });
  await runAndFail(page);
});

test('flow diagram: every unit a multi-resource instruction holds carries its marker', async ({ page }) => {
  const errors = [];
  page.on('pageerror', (e) => errors.push(e.message));
  await page.goto('/');
  await page.locator('#asm').fill(readFixture('loop.s'));
  await page.locator('#cpu').selectOption('znver4');
  await page.locator('#iterations').fill('3');
  await page.locator('#run').click();
  await expect(page.locator('#out')).toBeVisible({ timeout: 60000 });
  await page.locator('#flow-cycle').fill('1');
  await page.locator('#flow-cycle').dispatchEvent('input');

  // the solid token for instance 0:0 lists every unit it holds
  const tok = page.locator('#flow svg .flow-token[data-instr="0"][data-iter="0"]');
  await expect(tok).toHaveAttribute('data-units', '13 17 20');
  const markers = page.locator('#flow svg .flow-marker[data-instr="0"][data-iter="0"]');
  await expect(markers).toHaveCount(2);
  // each marked group sits inside a unit box, and between token and markers
  // every held unit box carries one
  const groups = await page.evaluate(() => {
    const byUnit = (u) => {
      const r = document.querySelector(`#flow svg .flow-unit[data-unit="${u}"] rect`).getBoundingClientRect();
      const hit = [];
      for (const g of document.querySelectorAll('#flow svg .flow-tokens > g')) {
        const b = g.getBoundingClientRect();
        if (b.x >= r.x - 1 && b.x + b.width <= r.right + 1 && b.y >= r.y - 1 && b.y + b.height <= r.bottom + 1) hit.push(g.getAttribute('class'));
      }
      return hit;
    };
    return { 13: byUnit('13'), 17: byUnit('17'), 20: byUnit('20') };
  });
  expect(groups['13']).toEqual(['flow-token']);
  expect(groups['17']).toEqual(['flow-marker']);
  expect(groups['20']).toEqual(['flow-marker']);
  expect(errors).toEqual([]);
});
