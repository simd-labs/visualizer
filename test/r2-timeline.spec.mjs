import { test, expect } from '@playwright/test';
import { EXAMPLES } from '../src/examples.js';

// UX round 2, timeline and heatmap: every drawn timeline row shows on a 16:9
// screen, a wide box shows a visible scroll cue on its clipped edge, and the
// heatmap stays inside its card at 8:9.

// znver4's example loop at 100 iterations (the prefilled example).
async function runExample(page) {
  await page.goto('/');
  await page.locator('#asm').fill(EXAMPLES.x86_64);
  await page.locator('#cpu').selectOption('znver4');
  await expect(page.locator('#run')).toBeEnabled({ timeout: 60000 });
  await page.locator('#run').click();
  await expect(page.locator('#run')).toHaveText('Run', { timeout: 60000 });
  await expect(page.locator('#timeline svg')).toHaveCount(1);
  await expect(page.locator('#heatmap svg')).toHaveCount(1);
}

const rowsInBox = () => {
  const tl = document.getElementById('timeline');
  const r = tl.getBoundingClientRect();
  const labels = [...tl.querySelectorAll('svg text.row')];
  const iters = new Set(labels.map((t) => t.textContent.split(':')[0]));
  const visByIter = new Set(
    labels
      .filter((t) => t.getBoundingClientRect().bottom <= r.bottom + 0.5)
      .map((t) => t.textContent.split(':')[0])
  );
  return {
    drawn: labels.length,
    drawnIters: iters.size,
    visByIter: visByIter.size,
    clientH: tl.clientHeight,
    note: document.getElementById('notice').textContent,
  };
};

// Rule 1: on a 16:9 screen the box holds every iteration without a vertical
// scroll: each of the 10 drawn iterations has rows visible, and each label
// keeps the 12px floor.
for (const [w, h] of [[1920, 1080], [1600, 900]]) {
  test(`${w}x${h}: every drawn iteration shows rows without a vertical scroll`, async ({ page }) => {
    await page.setViewportSize({ width: w, height: h });
    await runExample(page);
    const m = await page.evaluate(rowsInBox);
    expect(m.drawn, 'rows drawn').toBe(60);
    expect(m.visByIter, `iterations visible ${m.visByIter} of ${m.drawnIters}`).toBe(m.drawnIters);
    expect(m.note, 'the one-line note, no "Box shows" append').not.toContain('Box shows');
    const font = await page.evaluate(() =>
      Math.min(...[...document.querySelectorAll('#timeline svg text.row')].map((t) => +t.getAttribute('font-size')))
    );
    expect(font, 'row label size').toBeGreaterThanOrEqual(12);
  });
}

// Rule 1b: a run with more rows than the box fits scrolls, the bottom cue
// shows, and the note says which rows show. The znver4 run's timeline covers
// 10 iterations (llvm-mca's -timeline cap); this fat dropped JSON repeats
// znver4.json's entries for 100 iterations (400 rows, 12px floor).
test('more rows than fit: the box scrolls and the note names the visible range', async ({ page }) => {
  await page.setViewportSize({ width: 960, height: 1080 });
  await page.goto('/');
  const fat = await page.evaluate(async () => {
    const res = await fetch('/test/fixtures/znver4.json');
    const j = await res.json();
    const region = j.CodeRegions[0];
    const info = region.TimelineView.TimelineInfo;
    const n = region.Instructions.length; // one iteration's rows
    const one = info.slice(0, n);
    region.TimelineView.TimelineInfo = Array.from({ length: 100 }, () => one).flat();
    region.SummaryView.Iterations = 100;
    return JSON.stringify(j);
  });
  const dt = await page.evaluateHandle((json) => {
    const d = new DataTransfer();
    d.items.add(new File([json], 'fat.json', { type: 'application/json' }));
    return d;
  }, fat);
  await page.locator('#drop').dispatchEvent('drop', { dataTransfer: dt });
  await expect(page.locator('#timeline svg')).toHaveCount(1);
  const m = await page.evaluate(() => {
    const tl = document.getElementById('timeline');
    const wrap = tl.closest('.scroll-wrap');
    const hint = wrap.querySelector('.scroll-hint');
    const r = tl.getBoundingClientRect();
    return {
      scrollH: tl.scrollHeight,
      clientH: tl.clientHeight,
      note: document.getElementById('notice').textContent,
      cueDown: wrap.classList.contains('cue-down'),
      hintVisible: getComputedStyle(hint).opacity === '1',
      bottomFade: getComputedStyle(wrap, '::before').backgroundImage.includes('gradient'),
    };
  });
  expect(m.scrollH).toBeGreaterThan(m.clientH + 1);
  expect(m.cueDown, 'bottom cue class').toBe(true);
  expect(m.hintVisible, 'scroll hint visible').toBe(true);
  expect(m.bottomFade, 'bottom fade').toBe(true);
  const font = await page.evaluate(() =>
    Math.min(...[...document.querySelectorAll('#timeline svg text.row')].map((t) => +t.getAttribute('font-size')))
  );
  expect(font, 'row label size').toBeGreaterThanOrEqual(12);
  const shown = /Box shows (\d+)-(\d+)/.exec(m.note);
  expect(shown, `note "${m.note}"`).toBeTruthy();
  // scroll to the bottom: the cue hides
  const after = await page.evaluate(() => {
    const box = document.getElementById('timeline');
    box.scrollTop = box.scrollHeight - box.clientHeight;
    box.dispatchEvent(new Event('scroll'));
    return box.closest('.scroll-wrap').className;
  });
  expect(after, 'cue hides at the bottom').not.toContain('cue-down');
});

// Rule 2: a box wider than its content area shows a scroll cue on its
// clipped edge; the cue hides at the edge and when there is no overflow.
// Timeline rows land one per 12px; wheel the box down first so the rule-1b
// rows-past-the-box state does not confuse the horizontal checks.
test('800x900: the timeline and heatmap show a scroll cue while their right edge is clipped', async ({ page }) => {
  await page.setViewportSize({ width: 800, height: 900 });
  await runExample(page);
  const m = await page.evaluate(() => {
    const read = (id) => {
      const box = document.getElementById(id);
      const wrap = box.closest('.scroll-wrap');
      const hint = wrap.querySelector('.scroll-hint');
      return {
        over: box.scrollWidth > box.clientWidth + 1,
        cue: wrap.classList.contains('cue-right'),
        hintVisible: getComputedStyle(hint).opacity === '1',
        edgeFade: getComputedStyle(wrap, '::before').backgroundImage.includes('gradient'),
      };
    };
    return { tl: read('timeline'), hm: read('heatmap') };
  });
  for (const [name, b] of Object.entries(m)) {
    expect(b.over, `${name} overflows`).toBe(true);
    expect(b.cue, `${name} cue class`).toBe(true);
    expect(b.hintVisible, `${name} hint visible`).toBe(true);
    expect(b.edgeFade, `${name} edge fade`).toBe(true);
  }
  // scroll each box to its right edge: the cue hides there. Linux keeps 15px
  // for the classic horizontal scrollbar, so max scrollLeft stops that far
  // short; the cue's own slack covers it.
  const after = await page.evaluate(() => {
    for (const id of ['timeline', 'heatmap']) {
      const box = document.getElementById(id);
      box.scrollLeft = box.scrollWidth - box.clientWidth;
      box.dispatchEvent(new Event('scroll'));
    }
    const read = (id) => {
      const box = document.getElementById(id);
      return { sl: box.scrollLeft, cls: box.closest('.scroll-wrap').className };
    };
    return { tl: read('timeline'), hm: read('heatmap') };
  });
  expect(after.tl.sl, 'timeline scrolled').toBeGreaterThan(0);
  expect(after.hm.sl, 'heatmap scrolled').toBeGreaterThan(0);
  expect(after.tl.cls, 'timeline cue at right edge').not.toContain('cue-right');
  expect(after.hm.cls, 'heatmap cue at right edge').not.toContain('cue-right');
});

test('1920x1080: no overflow, no cue', async ({ page }) => {
  await page.setViewportSize({ width: 1920, height: 1080 });
  await runExample(page);
  const m = await page.evaluate(() => {
    const read = (id) => {
      const box = document.getElementById(id);
      const wrap = box.closest('.scroll-wrap');
      return {
        over: box.scrollWidth > box.clientWidth + 1,
        cue: wrap.classList.contains('cue-right') || wrap.classList.contains('cue-down'),
        hintVisible: getComputedStyle(wrap.querySelector('.scroll-hint')).opacity === '1',
      };
    };
    return { tl: read('timeline'), hm: read('heatmap') };
  });
  expect(m.tl.over, 'timeline horizontal overflow at 1920').toBe(false);
  expect(m.hm.over, 'heatmap overflow at 1920').toBe(false);
  expect(m.tl.cue, 'timeline cue without overflow').toBe(false);
  expect(m.hm.cue, 'heatmap cue without overflow').toBe(false);
  expect(m.tl.hintVisible, 'timeline hint without overflow').toBe(false);
  expect(m.hm.hintVisible, 'heatmap hint without overflow').toBe(false);
});

// Rule 3: at 800x900 and 960x1080 the heatmap card itself does not overflow;
// any overflow is inside the heatmap box, and the page has no horizontal
// scroll.
for (const [w, h] of [[800, 900], [960, 1080]]) {
  test(`${w}x${h}: the heatmap card holds; overflow stays inside the heatmap box`, async ({ page }) => {
    await page.setViewportSize({ width: w, height: h });
    await runExample(page);
    const m = await page.evaluate(() => {
      const hm = document.getElementById('heatmap');
      const card = hm.closest('.panel');
      return {
        pageOver: document.documentElement.scrollWidth - document.documentElement.clientWidth,
        cardOver: card.scrollWidth - card.clientWidth,
        boxOver: hm.scrollWidth - hm.clientWidth,
      };
    });
    expect(m.pageOver, 'page horizontal scroll').toBeLessThanOrEqual(0);
    expect(m.cardOver, 'heatmap card overflow').toBeLessThanOrEqual(1);
    if (w === 800) expect(m.boxOver, 'the 800px heatmap scrolls inside its box').toBeGreaterThan(1);
    if (w === 960) expect(m.boxOver, 'the 960px heatmap fits its box').toBeLessThanOrEqual(1);
  });
}
