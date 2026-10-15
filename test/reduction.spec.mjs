// The two reduction examples (examples/reduction-*.s) loaded through the
// file picker and run on znver4 at 100 iterations: no error text, the flow
// diagram shows tokens, and every timeline row label is
// iteration:mnemonic:line with the line of the source file. Expected labels
// come from the source text and a real llvm-mca run, mapped node-side with
// src/source-lines.js.
import { test, expect } from '@playwright/test';
import { readFileSync } from 'node:fs';
import { run } from '../wasm/run.mjs';
import { sourceLines } from '../src/source-lines.js';

const ARGS = ['-mtriple=x86_64-unknown-linux-gnu', '-mcpu=znver4', '-iterations=100', '-timeline', '-json', '-issue-events'];
const mnemonic = (s) => s.trim().split(/\s+/)[0].toLowerCase();

for (const path of ['examples/reduction-1acc.s', 'examples/reduction-16acc.s']) {
  test(`${path} on znver4: clean run, flow tokens, correct line labels`, async ({ page }) => {
    const source = readFileSync(path, 'utf8');
    const r = run(source, ARGS);
    expect(r.exit).toBe(0);
    const instrs = JSON.parse(r.stdout).CodeRegions[0].Instructions;
    const lines = sourceLines(source, instrs);
    expect(lines, 'the source maps onto the region instructions').not.toBeNull();
    const n = instrs.length;
    const vaddpsLines = instrs.map((_, k) => lines[k]).filter((_, k) => mnemonic(instrs[k]) === 'vaddps');
    expect(vaddpsLines.length).toBeGreaterThan(0);
    for (const line of vaddpsLines) expect(mnemonic(source.split('\n')[line - 1])).toBe('vaddps');

    await page.goto('/');
    await expect(page.locator('#run')).toBeEnabled({ timeout: 120000 }); // cpus.json and the WASM module are up
    await page.locator('#cpu').selectOption('znver4');
    await page.locator('#file').setInputFiles(path); // the picker loads and runs the file
    await expect(page.locator('#run')).toHaveText('Run', { timeout: 120000 });
    await expect(page.locator('#error')).toBeHidden();
    expect(await page.locator('#error').textContent()).toBe('');
    await expect(page.locator('#timeline svg')).toHaveCount(1);

    // tokens are drawn for the slider's cycle (.flow-token; .flow-marker only
    // marks extra units of a multi-unit hold); cycle 0 can be empty, so step in
    const cycle = await page.locator('#flow-cycle').evaluate((el) => {
      el.value = String(Math.ceil(Number(el.max) / 2));
      el.dispatchEvent(new Event('input'));
      return el.value;
    });
    const tokens = await page.locator('#flow svg .flow-token').count();
    expect(tokens, `flow tokens at cycle ${cycle}`).toBeGreaterThan(0);

    const labels = await page.locator('#timeline svg text.row').allTextContents();
    expect(labels.length, 'timeline rows').toBeGreaterThan(0);
    // the timeline cap can cut the last iteration short (16acc draws 8 + 8/19),
    // but every drawn row is iteration floor(i/n), instruction i%n
    for (const [i, got] of labels.entries()) {
      const k = i % n;
      expect(got).toBe(`${Math.floor(i / n)}:${mnemonic(instrs[k])}:${lines[k]}`);
    }
  });
}
