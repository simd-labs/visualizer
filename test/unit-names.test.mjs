// Every execution resource in a fixture gets a vendor-style name from
// src/unit-names.json, not the fallback; families with no fixture are skipped.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, readdirSync } from 'node:fs';
import { lookup } from '../src/unit-names.js';

const names = JSON.parse(readFileSync(new URL('../src/unit-names.json', import.meta.url), 'utf8'));
const dir = new URL('fixtures/', import.meta.url);
const fixtures = readdirSync(dir)
  .filter((f) => f.endsWith('.json') && f !== 'malformed.json') // malformed.json is invalid on purpose
  .map((f) => [f, JSON.parse(readFileSync(new URL(f, dir), 'utf8'))])
  .filter(([, j]) => Array.isArray(j?.TargetInfo?.Resources));

for (const family of names.meta.families.filter((f) => f !== 'generic')) {
  const cpus = new Set(names.rules.filter((r) => r.family === family).flatMap((r) => r.cpus));
  const mine = fixtures.filter(([, j]) => cpus.has(j.TargetInfo.CPUName));
  test(`${family}: every fixture resource has a vendor name`, { skip: mine.length === 0 && 'no fixture for this family' }, () => {
    for (const [file, j] of mine) {
      for (const r of j.TargetInfo.Resources) {
        const u = lookup(j.TargetInfo.CPUName, r);
        assert.equal(u.fallback, false, `${file}: ${JSON.stringify(r)} fell back to "${u.name}"`);
        assert.ok(u.name && !u.name.includes(r.split('.')[0]), `${file}: ${JSON.stringify(r)} shows its raw name`);
      }
    }
  });
}

test('the fixtures cover the four families the page tests run', () => {
  const cpus = new Set(fixtures.map(([, j]) => j.TargetInfo.CPUName));
  assert.deepEqual([...cpus].sort(), ['cortex-a55', 'neoverse-v2', 'skylake', 'znver4']);
});

test('the sub-label in a display never repeats the title', () => {
  for (const r of names.rules) {
    const m = r.display.match(/^(.*?)\s*\((.*)\)$/);
    if (!m) continue;
    assert.notEqual(m[2].trim().toLowerCase(), m[1].trim().toLowerCase(), `${r.label}: sub-label repeats the title in ${JSON.stringify(r.display)}`);
  }
});

test('the sub-label in a display never names a second unit kind', () => {
  // Bug class: "Vector command queue (vector retire queue)" titled the flow's
  // unit "Vector command queue" while its sub-label described a different unit.
  // Mechanically: when both the title and its parenthesised sub-label carry a
  // queue-like two-word phrase, the adjective before "queue" must match. Other
  // sub-labels that expand the title into prose ("Memory (LSU: load/store
  // unit)", "Divider (in-pipe)") are descriptive and out of scope here.
  for (const r of names.rules) {
    const m = r.display.match(/^(.*?)\s*\((.*)\)$/);
    if (!m) continue;
    const title = m[1].toLowerCase();
    const sub = m[2].toLowerCase();
    const adj = (s) => (s.match(/(\w+)\s+queue\b/) || [])[1];
    if (title.includes('queue') && sub.includes('queue')) {
      assert.equal(adj(sub), adj(title), `${r.label}: title and sub-label name different queue kinds in ${JSON.stringify(r.display)}`);
    }
  }
});

test('instances, groups and the fallback', () => {
  assert.equal(lookup('neoverse-v2', 'V2UnitL01.\x01').name, 'L1');
  assert.equal(lookup('znver4', 'Zn4FP45.\x00').name, 'FP4');
  assert.equal(lookup('znver4', 'Zn4Load.\x02').name, 'Load 2');
  assert.deepEqual(lookup('znver4', 'Zn4AGU01'), { name: 'AGU0/AGU1', role: '', display: 'AGU0/AGU1', cluster: 'mem', port: null, fallback: false });
  assert.equal(lookup('skylake', 'SKLPort0').display, 'Port 0 (arithmetic logic unit / vector arithmetic logic unit+FMA)');
  // an unknown name is humanized, never shown raw
  assert.deepEqual(lookup('znver4', 'ZN4Store0'), { name: 'Store 0', role: '', display: 'Store 0', cluster: 'mem', port: null, fallback: true });
  assert.equal(lookup('haswell', 'HWPort0').name, 'Port 0');
});
