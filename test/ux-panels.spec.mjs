import { test, expect } from '@playwright/test';
import { readFileSync } from 'node:fs';
import { gzipSync } from 'node:zlib';
import { createServer } from 'node:http';
import { EXAMPLES } from '../src/examples.js';

const EXAMPLE_ASM = EXAMPLES.x86_64;

// znver4's example loop at 100 iterations: a full run with the note, heatmap
// and every label on screen.
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

// P6: the timeline note is one line; the cap details sit in a collapsed
// details element, so the chart box stays within 60px of its section heading.
for (const [width, height] of [[1920, 1080], [1600, 900], [1366, 768], [960, 1080], [800, 900]]) {
  test(`${width}x${height}: the timeline note is one short line and the chart sits near its heading`, async ({ page }) => {
    await page.setViewportSize({ width, height });
    await runExample(page);
    const note = await page.locator('#notice').textContent();
    expect(note.trim().split(/\s+/).length).toBeLessThanOrEqual(25);
    const r = await page.evaluate(() => {
      const tl = document.getElementById('timeline').getBoundingClientRect();
      const h = document.getElementById('h-timeline').getBoundingClientRect();
      const details = document.getElementById('notice-more');
      return { gap: tl.top - h.top, collapsed: !details.open, detailsHasCap: details.textContent.includes('cap') };
    });
    expect(r.collapsed).toBe(true);
    expect(r.detailsHasCap).toBe(true);
    // whole px: runner fonts shift the line height by a fraction of a pixel
    expect(Math.round(r.gap)).toBeLessThanOrEqual(60);
  });
}

// P7: the page never scrolls sideways; at 960 the heatmap fits its box (cells
// shrink to 26px), and at 800 its own box scrolls internally.
for (const [width, height] of [[960, 1080], [800, 900]]) {
  test(`${width}x${height}: no page-wide horizontal scroll; the heatmap fits or scrolls in its own box`, async ({ page }) => {
    await page.setViewportSize({ width, height });
    await runExample(page);
    const doc = await page.evaluate(() => ({
      scroll: document.documentElement.scrollWidth,
      client: document.documentElement.clientWidth,
    }));
    expect(doc.scroll).toBeLessThanOrEqual(doc.client);
    const hm = await page.evaluate(() => {
      const box = document.getElementById('heatmap');
      return { scrollW: box.scrollWidth, clientW: box.clientWidth };
    });
    if (width === 960) expect(hm.scrollW).toBeLessThanOrEqual(hm.clientW);
  });
}

// P7b: the heatmap cell never goes below 26px.
test('800x900: heatmap cells stay at least 26px wide when the box scrolls internally', async ({ page }) => {
  await page.setViewportSize({ width: 800, height: 900 });
  await runExample(page);
  const w = await page.evaluate(() => +document.querySelector('#heatmap svg rect[data-cy]').getAttribute('width'));
  expect(w).toBeGreaterThanOrEqual(26);
});

// P8: with a gzip-encoded wasm (compressed Content-Length, decompressed
// body), no progress label shows loaded > total, and the last label reaches
// the total. Chromium only decodes Content-Encoding on a real network
// response (route.fulfill bodies arrive verbatim), so the wasm comes from a
// small gzipping server, and the page's own worker drives the fetch: the
// MutationObserver records every progress label on the Run button.
test('load progress never exceeds the total under gzip and reaches it at the end', async ({ page }) => {
  test.setTimeout(90000); // the module compiles once from the gzip server
  const wasm = readFileSync('wasm/dist/llvm-mca.wasm');
  const zipped = gzipSync(wasm);
  const server = createServer((req, res) => {
    res.writeHead(200, {
      'Content-Type': 'application/wasm',
      'Content-Encoding': 'gzip',
      'Content-Length': zipped.length,
      'Access-Control-Allow-Origin': '*',
    });
    // trickle: a fast local server sends the body in one burst and no
    // intermediate progress label exists to record
    let off = 0;
    const step = Math.ceil(zipped.length / 20);
    const send = () => {
      if (off >= zipped.length) return res.end();
      off += step;
      res.write(zipped.subarray(off - step, Math.min(off, zipped.length)), send);
    };
    send();
  });
  await new Promise((r) => server.listen(0, '127.0.0.1', r));
  const port = server.address().port;
  try {
    // the worker's own fetch goes to the gzipping server (a 307, so
    // route.fulfill's verbatim body never enters the picture)
    await page.route('**/wasm/dist/llvm-mca.wasm', (route) =>
      route.fulfill({ status: 307, headers: { Location: `http://127.0.0.1:${port}/llvm-mca.wasm` } })
    );
    await page.addInitScript(() => {
      // the button text changes several times a second while the body
      // streams; a MutationObserver never fired here, so poll instead
      window.__runLabels = [];
      const start = Date.now();
      const poll = () => {
        const t = document.getElementById('run')?.textContent;
        if (t && window.__runLabels.at(-1) !== t) window.__runLabels.push(t);
        if (Date.now() - start < 120000) setTimeout(poll, 5);
      };
      poll();
    });
    await page.goto('/');
    await expect(page.locator('#run')).toHaveText('Run', { timeout: 80000 });
    const labels = (await page.evaluate(() => window.__runLabels)).filter((t) => /MB/.test(t));
    expect(labels.length).toBeGreaterThan(1);
    const pair = (t) => {
      const m = /([0-9.]+) MB of ([0-9.]+) MB/.exec(t);
      return { got: +m[1], total: +m[2] };
    };
    const parsed = labels.map(pair);
    for (const p of parsed) expect(p.got, `label ${JSON.stringify(p)}`).toBeLessThanOrEqual(p.total + 1e-9);
    // the label's total ends at the decompressed body size, past the
    // compressed Content-Length, and the last label reaches it
    expect(zipped.length).toBeLessThan(wasm.length); // gzip really compressed
    expect(parsed.at(-1).got).toBeCloseTo(parsed.at(-1).total, 1);
    expect(parsed.at(-1).total).toBeCloseTo(wasm.length / (1 << 20), 1);
  } finally {
    server.close();
  }
});

// P8, plain server: uncompressed, the same guarantee holds.
test('load progress never exceeds the total on the plain local server', async ({ page }) => {
  test.setTimeout(150000);
  await page.addInitScript(() => {
    window.__runLabels = [];
    const start = Date.now();
    const poll = () => {
      const t = document.getElementById('run')?.textContent;
      if (t && window.__runLabels.at(-1) !== t) window.__runLabels.push(t);
      if (Date.now() - start < 120000) setTimeout(poll, 5);
    };
    poll();
  });
  await page.goto('/');
  await expect(page.locator('#run')).toHaveText('Run', { timeout: 120000 });
  const labels = (await page.evaluate(() => window.__runLabels)).filter((t) => /MB/.test(t));
  expect(labels.length).toBeGreaterThan(1);
  const pair = (t) => {
    const m = /([0-9.]+) MB of ([0-9.]+) MB/.exec(t);
    return m ? { got: +m[1], total: +m[2] } : null;
  };
  for (const t of labels) {
    const p = pair(t);
    expect(p, t).toBeTruthy();
    expect(p.got, `label ${t}`).toBeLessThanOrEqual(p.total + 1e-9);
  }
});

// P9: the empty-state card names a control state that is true on screen:
// while loading it says Run starts when llvm-mca is ready; when ready it says
// press Run.
test('the empty card agrees with the Run button, on load and after ready', async ({ page }) => {
  test.setTimeout(90000);
  // hold the wasm so the loading state lasts long enough to read
  let release;
  const hold = new Promise((r) => (release = r));
  await page.route('**/wasm/dist/llvm-mca.wasm', async (route) => {
    await hold;
    const res = await route.fetch();
    route.fulfill({ response: res });
  });
  await page.goto('/');
  const card = page.locator('#empty-label');
  await expect(page.locator('#run')).toBeDisabled();
  await expect(card).toContainText('Run starts once llvm-mca is ready');
  await expect(card).not.toContainText('press Run');
  release();
  await expect(page.locator('#run')).toBeEnabled({ timeout: 60000 });
  await expect(card).toContainText('press Run');
});

// P11: legend, axis and heatmap label text renders at least 13px; the
// heatmap's pressure values stay at least 11px.
for (const [width, height] of [[1920, 1080], [1366, 768]]) {
  test(`${width}x${height}: timeline axis, legend and heatmap label text is at least 13px`, async ({ page }) => {
    await page.setViewportSize({ width, height });
    await runExample(page);
    const small = await page.evaluate(() => {
      const out = [];
      const measure = (t, min, where) => {
        const m = t.getScreenCTM();
        const h = parseFloat(getComputedStyle(t).fontSize) * Math.hypot(m.c, m.d);
        if (h < min - 0.01) out.push(`${where}: "${t.textContent}" ${h.toFixed(1)}px`);
      };
      for (const t of document.querySelectorAll('#timeline svg text.axis')) measure(t, 13, 'axis');
      for (const t of document.querySelectorAll('#heatmap svg text.col, #heatmap svg text.rowlabel, #heatmap svg text.heat-scale')) measure(t, 13, 'heatmap');
      for (const t of document.querySelectorAll('#heatmap svg text.heat-val')) measure(t, 11, 'heat-val');
      return out;
    });
    expect(small.slice(0, 10)).toEqual([]);
    const legendPx = await page.locator('#legend span').first().evaluate((s) => parseFloat(getComputedStyle(s).fontSize));
    expect(legendPx).toBeGreaterThanOrEqual(13);
  });
}
