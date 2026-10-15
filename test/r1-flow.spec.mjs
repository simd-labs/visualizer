// Round-1 flow-area fixes: unit roles spelled out, token notation in the
// legend, flow text at least 11px at 800px.
import { test, expect } from '@playwright/test';
import { readFileSync } from 'node:fs';
import { lookup } from '../src/unit-names.js';

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
