// Every unit label in the flow diagram stays inside its unit box, on the
// five CPUs and the two window sizes the release check covers. The boxes
// are sized from an estimated text width, so this catches both estimation
// misses and the narrow-panel clamp.
import { test, expect } from '@playwright/test';
import { EXAMPLES } from '../src/examples.js';

const CPUS = {
  znver4: EXAMPLES.x86_64,
  skylake: EXAMPLES.x86_64,
  lunarlake: EXAMPLES.x86_64,
  'neoverse-v2': EXAMPLES.aarch64,
  'sifive-x280': EXAMPLES.riscv64,
};
const VIEWPORTS = [
  { width: 1920, height: 1080 },
  { width: 800, height: 900 },
];

for (const viewport of VIEWPORTS) {
  for (const [cpu, asm] of Object.entries(CPUS)) {
    test(`${cpu} unit labels fit their boxes at ${viewport.width}x${viewport.height}`, async ({ page }) => {
      await page.setViewportSize(viewport);
      await page.goto('/');
      await page.locator('#asm').fill(asm);
      await page.locator('#cpu').selectOption(cpu);
      await expect(page.locator('#run')).toBeEnabled({ timeout: 120000 });
      await page.locator('#run').click();
      await expect(page.locator('#flow svg g.flow-unit').first()).toBeAttached({ timeout: 120000 });
      const bad = await page.evaluate(() => {
        const out = [];
        for (const g of document.querySelectorAll('#flow svg g.flow-unit')) {
          const r = g.querySelector('rect');
          const w = +r.getAttribute('width');
          const h = +r.getAttribute('height');
          for (const t of g.querySelectorAll('text')) {
            const b = t.getBBox();
            const s = (n) => Math.round(n * 10) / 10;
            if (b.x < -0.5 || b.y < -0.5 || b.x + b.width > w + 0.5 || b.y + b.height > h + 0.5) {
              out.push(`unit ${g.dataset.unit}: "${t.textContent}" at ${s(b.x)},${s(b.y)} ${s(b.width)}x${s(b.height)} in a ${w}x${h} box`);
            }
          }
        }
        return out;
      });
      expect(bad).toEqual([]);
    });
  }
}
