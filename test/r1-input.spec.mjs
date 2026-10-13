import { test, expect } from '@playwright/test';

// Round 1, area B: the input bar, run states, theme toggle and error box.

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

const runColors = (page) =>
  page.locator('#run').evaluate((b) => {
    const s = getComputedStyle(b);
    return { bg: s.backgroundColor, fg: s.color };
  });

// Hold the WASM fetch until release() runs, so the Run button stays in its
// disabled loading state until we say go.
function onHoldWasm(page) {
  let release;
  const hold = new Promise((r) => (release = r));
  page.route('**/wasm/dist/llvm-mca.wasm', async (route) => {
    await hold;
    const res = await route.fetch();
    route.fulfill({ response: res });
  });
  return () => release();
}

test('the Run button and the hint agree in every state', async ({ page }) => {
  const release = onHoldWasm(page);
  await page.goto('/');
  // loading, with progress: one wording for the whole phase, never 'Run'
  await expect(page.locator('#run')).toBeDisabled();
  await expect(page.locator('#run')).toHaveText(/^Loading llvm-mca\.\.\./);
  await expect(page.locator('#empty')).toContainText('press Run');
  // sample the label through the rest of the loading phase: 'Loading...' only
  await page.evaluate(() => {
    const b = document.getElementById('run');
    window.__labels = new Set();
    window.__poll = setInterval(() => window.__labels.add(b.textContent), 25);
  });
  release();
  // ready: the label is the hint's verb
  await expect(page.locator('#run')).toHaveText('Run');
  await expect(page.locator('#run')).toBeEnabled();
  const labels = await page.evaluate(() => { clearInterval(window.__poll); return [...window.__labels].filter((l) => l !== 'Run'); });
  for (const l of labels) expect(l, `unexpected loading label: ${l}`).toMatch(/^Loading llvm-mca\.\.\./);
  // running
  await page.locator('#iterations').fill('3');
  await page.locator('#run').click();
  await expect(page.locator('#run')).toHaveText('Running...');
  await expect(page.locator('#run')).toBeDisabled();
  await expect(page.locator('#out')).toBeVisible({ timeout: 60000 });
  await expect(page.locator('#run')).toHaveText('Run');
  await expect(page.locator('#run')).toBeEnabled();
});

test('the failed state says so and keeps Run disabled', async ({ page }) => {
  await page.route('**/wasm/dist/llvm-mca.wasm', (route) => route.abort());
  await page.goto('/');
  await expect(page.locator('#run')).toHaveText('llvm-mca failed to load', { timeout: 60000 });
  await expect(page.locator('#run')).toBeDisabled();
});

for (const theme of ['light', 'dark']) {
  test(`enabled and disabled Run differ in the ${theme} theme, enabled text at least 4.5:1`, async ({ page }) => {
    const release = onHoldWasm(page);
    await page.addInitScript((t) => localStorage.setItem('simd-labs-theme', t), theme);
    await page.goto('/');
    await expect(page.locator('#run')).toBeDisabled();
    const disabled = await runColors(page);
    release();
    await expect(page.locator('#run')).toBeEnabled({ timeout: 60000 });
    const enabled = await runColors(page);
    // with the old CSS both states were identical: grey on grey
    expect(contrast(enabled.fg, enabled.bg)).toBeGreaterThanOrEqual(4.5);
    expect(enabled.bg).not.toBe(disabled.bg);
    expect(enabled.fg).not.toBe(disabled.fg);
  });
}

test('the theme toggle names the mode it switches to', async ({ page }) => {
  await page.goto('/');
  await expect(page.locator('#theme-toggle')).toHaveAttribute('title', /Switch to (dark|light) mode/);
  const before = await page.locator('#theme-toggle').getAttribute('aria-label');
  await page.locator('#theme-toggle').click();
  await expect(page.locator('#theme-toggle')).not.toHaveAttribute('aria-label', before);
  await expect(page.locator('#theme-toggle')).toHaveAttribute('aria-label', /Switch to (dark|light) mode/);
});

test('the asm box shows its tail line instead of cutting it off', async ({ page }) => {
  await page.goto('/');
  // the shipped x86 example must fit: no scroll overflow, so the tail is not cut
  const overflow = await page.locator('#asm').evaluate((el) => el.scrollHeight - el.clientHeight);
  expect(overflow).toBeLessThanOrEqual(2);
});

const END_MARKER_ASM = `# LLVM-MCA-BEGIN foo
.text
.globl loop
loop:
  nop
# LLVM-MCA-END foo
# LLVM-MCA-END foo
`;

// clang copies '# LLVM-MCA-END' into every return path (corpus test), so the
// pasted asm holds several end markers and llvm-mca rejects the second one.
test('a duplicated LLVM-MCA-END marker error gets its cause and fix', async ({ page }) => {
  await page.goto('/');
  await expect(page.locator('#run')).toBeEnabled({ timeout: 60000 });
  await page.locator('#iterations').fill('3');
  await page.locator('#asm').fill(END_MARKER_ASM);
  await page.locator('#run').click();
  await expect(page.locator('#error')).toBeVisible({ timeout: 60000 });
  await expect(page.locator('#error')).toContainText('invalid region end directive');
  await expect(page.locator('#error')).toContainText('copied the');
  await expect(page.locator('#error')).toContainText('Keep one END marker, or remove the markers.');
});
