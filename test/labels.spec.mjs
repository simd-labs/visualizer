import { test, expect } from '@playwright/test';
import { readFileSync } from 'node:fs';
import { EXAMPLES } from '../src/examples.js';
import { sourceLines } from '../src/source-lines.js';
import { run } from '../wasm/run.mjs';

// Line numbers in the editor and labels as iteration:mnemonic:line. Expected
// values come from the source text and a real llvm-mca run, never from the
// page's own label code.

const readFixture = (name) => readFileSync(`test/fixtures/${name}`, 'utf8');
const mne = (s) => s.trim().split(/\s+/)[0].toLowerCase();
// The exact run the page makes for the prefilled example on znver4.
async function exampleJson(iters) {
  const r = await run(EXAMPLES.x86_64, [
    '-mtriple=x86_64-unknown-linux-gnu',
    '-mcpu=znver4',
    `-iterations=${iters}`,
    '-timeline',
    '-json',
    '-issue-events',
  ]);
  expect(r.exit).toBe(0);
  return JSON.parse(r.stdout);
}

test('the gutter shows one number per line and scrolls with the text', async ({ page }) => {
  await page.goto('/');
  const exampleLines = EXAMPLES.x86_64.split('\n').length;
  await expect(page.locator('#asm-gutter > div')).toHaveCount(exampleLines);

  // a 200-line paste: numbers 1..200, aligned after scrolling
  const text = Array.from({ length: 200 }, (_, i) => `nop # line ${i + 1}`).join('\n');
  await page.locator('#asm').fill(text);
  await expect(page.locator('#asm-gutter > div')).toHaveCount(200);
  await expect(page.locator('#asm-gutter > div').nth(199)).toHaveText('200');

  await page.locator('#asm').evaluate((el) => (el.scrollTop = 500));
  const { gTop, tTop } = await page.evaluate(() => {
    const g = document.getElementById('asm-gutter');
    const t = document.getElementById('asm');
    return { gTop: g.scrollTop, tTop: t.scrollTop };
  });
  expect(gTop).toBe(tTop);
  // the top visible number names the top visible text line
  const lineH = await page.evaluate(() => {
    const t = document.getElementById('asm');
    return parseFloat(getComputedStyle(t).lineHeight);
  });
  const k = Math.floor(500 / lineH);
  const marker = await page.evaluate(
    ({ k, lineH }) => {
      const t = document.getElementById('asm');
      const g = document.getElementById('asm-gutter').children[k];
      const tb = t.getBoundingClientRect();
      const gb = g.getBoundingClientRect();
      // the number's top edge sits one line-height lower than the scroll offset inside the textarea
      return { gb: gb.top - tb.top, want: k * lineH - t.scrollTop + 8 }; // 8px = the shared top pad
    },
    { k, lineH }
  );
  expect(Math.abs(marker.gb - marker.want), 'gutter alignment after scroll').toBeLessThan(3);

  // an edit back to one line leaves one number
  await page.locator('#asm').fill('nop');
  await expect(page.locator('#asm-gutter > div')).toHaveCount(1);
});

test('a znver4 run labels tokens, rows and the flow list as iteration:mnemonic:line', async ({ page }) => {
  await page.goto('/');
  await page.locator('#cpu').selectOption('znver4');
  await page.locator('#iterations').fill('3');
  await page.locator('#run').click();
  await expect(page.locator('#out')).toBeVisible({ timeout: 60000 });
  await expect(page.locator('#flow svg')).toHaveCount(1);

  const instructions = (await exampleJson(3)).CodeRegions[0].Instructions;
  const lines = sourceLines(EXAMPLES.x86_64, instructions);
  expect(lines, 'the example maps to source lines').not.toBeNull();
  const labelOf = (iter, instr) => `${iter}:${mne(instructions[instr])}:${lines[instr]}`;

  // instruction 0 of iteration 0: movups on the example's line 4, in flight at cycle 0
  expect(labelOf(0, 0)).toBe('0:movups:4');
  const tok = page.locator('#flow svg .flow-token[data-instr="0"][data-iter="0"]');
  await expect(tok).toHaveCount(1);
  await expect(tok.locator('text')).toHaveText(labelOf(0, 0));
  await expect(tok.locator('title')).toContainText(labelOf(0, 0));
  // timeline row of the same instance (rows are iteration-major, n = instructions.length)
  const row = page.locator('#timeline svg text.row').nth(0);
  await expect(row).toHaveText(labelOf(0, 0));
  // the flow text list carries the label for some instance of instruction 0
  const li = await page.locator('#flow-list li').allTextContents();
  expect(li.some((l) => l.includes(`${mne(instructions[0])}:${lines[0]}`)), 'flow list names lines').toBe(true);
  // the legend explains the format
  await expect(page.locator('#flow-legend')).toContainText('iteration:mnemonic:line');

  // hovering a timeline row highlights its gutter line
  await row.hover();
  const hl = page.locator('#asm-gutter .hl');
  await expect(hl).toHaveCount(1);
  await expect(hl).toHaveText(String(lines[0]));
});

test('a dropped JSON labels instances iteration:mnemonic, without a line', async ({ page }) => {
  await page.goto('/');
  const data = readFixture('znver4.issue.json');
  const instructions = JSON.parse(data).CodeRegions[0].Instructions;
  await page.evaluate(
    ([name, text]) => {
      const dt = new DataTransfer();
      dt.items.add(new File([text], name, { type: 'application/json' }));
      document.dispatchEvent(new DragEvent('drop', { dataTransfer: dt, bubbles: true }));
    },
    ['znver4.issue.json', data]
  );
  await expect(page.locator('#out')).toBeVisible({ timeout: 60000 });
  await expect(page.locator('#flow svg')).toHaveCount(1);

  const tok = page.locator('#flow svg .flow-token[data-instr="0"][data-iter="0"]');
  await expect(tok.locator('text')).toHaveText(`0:${mne(instructions[0])}`);
  await expect(tok.locator('text')).not.toHaveText(/:\d+$/);
  const rows = await page.locator('#timeline svg text.row').allTextContents();
  expect(rows[0]).toBe(`0:${mne(instructions[0])}`);
  expect(rows[0]).not.toMatch(/:\d+$/);
});
