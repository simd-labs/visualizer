import { test, expect } from '@playwright/test';
import { EXAMPLES } from '../src/examples.js';

// Round 3, input area: the example caption, the control borders, the header
// file button's name, and the asm box height on short content.

// ---- contrast helpers (sRGB relative luminance, WCAG ratio) -----------------
function parseRgb(s) {
  const m = s.replaceAll(' ', '').match(/rgba?\((\d+),(\d+),(\d+)(?:,([\d.]+))?\)/);
  if (m[4] !== undefined && +m[4] < 1) throw new Error(`semi-transparent color ${s} is unreadable as a pair`);
  return [+m[1], +m[2], +m[3]];
}
const channel = (c) => {
  const v = c / 255;
  return v <= 0.04045 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4;
};
const luminance = (rgb) => 0.2126 * channel(rgb[0]) + 0.7152 * channel(rgb[1]) + 0.0722 * channel(rgb[2]);
function contrast(a, b) {
  const [la, lb] = [luminance(parseRgb(a)), luminance(parseRgb(b))];
  return (Math.max(la, lb) + 0.05) / (Math.min(la, lb) + 0.05);
}

test('the caption names the example while the box holds one, and hides on any edit', async ({ page }) => {
  await page.goto('/');
  const caption = page.locator('#asm-caption');
  await expect(page.locator('#cpu')).toHaveValue('znver4');
  await expect(page.locator('#asm')).toHaveValue(EXAMPLES.x86_64);
  await expect(caption).toBeVisible();
  await expect(caption).toHaveText('Example loop for znver4. Edit it or paste your own.');
  // a CPU change swaps the example, and the caption follows
  await page.locator('#cpu').selectOption('neoverse-v2');
  await expect(page.locator('#asm')).toHaveValue(EXAMPLES.aarch64);
  await expect(caption).toHaveText('Example loop for neoverse-v2. Edit it or paste your own.');
  // one typed character ends the "example" state
  await page.locator('#asm').press('End');
  await page.locator('#asm').pressSequentially(' ');
  await expect(caption).toBeHidden();
  // an asm file load is the user's own code: no caption
  await page.setInputFiles('#file', { name: 'loop.s', mimeType: 'text/plain', buffer: Buffer.from('loop:\n  nop\n  jne loop\n') });
  await expect(page.locator('#asm')).toHaveValue('loop:\n  nop\n  jne loop\n');
  await expect(caption).toBeHidden();
});

// WCAG 1.4.11: every control boundary is at least 3:1 against its background.
// Was defect (b)11: --border (#263349) sat at ~1.5:1 on the navy surfaces.
test('every input control border is at least 3:1 in both themes', async ({ page }) => {
  await page.goto('/');
  await expect(page.locator('#cpu')).toHaveValue('znver4');
  const mins = {};
  for (const theme of ['light', 'dark']) {
    await page.evaluate((t) => {
      localStorage.setItem('simd-labs-theme', t);
      document.documentElement.setAttribute('data-theme', t);
    }, theme);
    const pairs = await page.evaluate(() => {
      const cs = (el) => getComputedStyle(el);
      const bar = cs(document.querySelector('.input-bar')).backgroundColor;
      const header = cs(document.querySelector('.header')).backgroundImage;
      const pick = (el, bg) => ({ edge: cs(el).borderTopColor, bg: bg });
      return {
        asm: pick(document.querySelector('.asm-wrap'), cs(document.querySelector('.asm-wrap')).backgroundColor),
        cpu: pick(document.getElementById('cpu'), cs(document.getElementById('cpu')).backgroundColor),
        iterations: pick(document.getElementById('iterations'), cs(document.getElementById('iterations')).backgroundColor),
        drop: pick(document.getElementById('drop'), bar),
        theme: pick(document.getElementById('theme-toggle'), bar),
        headerDropBgIsGradient: header !== 'none',
      };
    });
    // the header has a surface gradient; measure against both gradient ends
    const ends = await page.evaluate(() => {
      const root = getComputedStyle(document.documentElement);
      return [root.getPropertyValue('--surface').trim(), root.getPropertyValue('--bg-elevated').trim()];
    });
    const hex = (s) => {
      const n = parseInt(s.slice(1), 16);
      return `rgb(${(n >> 16) & 255}, ${(n >> 8) & 255}, ${n & 255})`;
    };
    mins[theme] = Infinity;
    const check = (name, edge, bg) => {
      const bgRgb = bg.startsWith('#') ? hex(bg) : bg;
      const r = contrast(edge, bgRgb);
      mins[theme] = Math.min(mins[theme], r);
      expect(r, `${theme}: ${name} border ${edge} on ${bgRgb}`).toBeGreaterThanOrEqual(3);
    };
    check('asm textarea', pairs.asm.edge, pairs.asm.bg);
    check('cpu select', pairs.cpu.edge, pairs.cpu.bg);
    check('iterations', pairs.iterations.edge, pairs.iterations.bg);
    for (const end of ends) {
      check('open-file button', pairs.drop.edge, end);
      check('theme toggle', pairs.theme.edge, end);
    }
  }
  console.log('control border minimum contrast:', JSON.stringify(mins));
});

test('the header file button spells out its formats', async ({ page }) => {
  await page.goto('/');
  await expect(page.locator('#drop')).toContainText('Open asm or JSON');
});

// Was defect (b)10: rows=10 left most of the box empty on short content.
// field-sizing: content is Chromium-only (Firefox keeps rows=10), so the
// requirement is tested on the stylesheet itself, plus the live behavior
// where the engine supports it.
test('the asm box shrinks toward its content after a short paste', async ({ page }) => {
  await page.goto('/');
  const css = await page.evaluate(() => fetch('style.css').then((r) => r.text()));
  expect(css).toMatch(/#asm \{[^}]*field-sizing:\s*content/);
  const full = await page.locator('#asm').evaluate((el) => el.clientHeight);
  await page.locator('#asm').fill('loop:\n  nop\n  jne loop');
  const h = await page.locator('#asm').evaluate((el) => {
    const line = parseFloat(getComputedStyle(el).lineHeight);
    return { client: el.clientHeight, content: el.scrollHeight, line };
  });
  if (h.client < full) {
    // field-sizing engaged: the box fits its three lines, not rows=10
    expect(h.client).toBeLessThanOrEqual(h.content + 2);
    expect(h.client).toBeLessThan(h.line * 8);
  }
});
