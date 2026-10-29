// Test xedform.wasm against the three cases from simdref-llvm-mc/tests/test_xed.py.
// Assemble with WASM llvm-mc, decode with xedform, compare iforms and fields.
import test from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { dirname, join, resolve } from 'node:path';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const WORKER = resolve(root, 'wasm/run-worker.mjs');
const MC_WASM = resolve(root, 'wasm/dist/llvm-mc.js');
const XED_CJS = resolve(root, 'wasm/dist/xedform.cjs');

// (triple, mattr, extra llvm-mc args, source line, expected iform, expected eosz)
const CASES = [
  ['x86_64', '+avx512f', ['-x86-asm-syntax=intel'],
    'vmovdqu64 zmm0, zmmword ptr [rdx]',
    'VMOVDQU64_ZMMu64_MASKmskw_MEMu64_AVX512', 64],
  ['x86_64', '', ['-x86-asm-syntax=intel'],
    'vpclmulhqhqdq xmm0, xmm1, xmm2',
    'VPCLMULQDQ_XMMdq_XMMdq_XMMdq_IMMb', 32],
  ['x86_64', '', [], 'data16 leave', 'LEAVE', 16],
];

function run_xed(input) {
  // xedform.cjs is CommonJS, reads from stdin directly
  const r = spawnSync(process.execPath, [XED_CJS], {
    input,
    encoding: 'utf8',
    maxBuffer: 64 << 20,
  });
  return { exit: r.status, stdout: r.stdout, stderr: r.stderr };
}

function mc_asm(triple, mattr, extra, src) {
  const args = [`-triple=${triple}`];
  if (mattr) args.push(`-mattr=${mattr}`);
  args.push(...extra, '-show-encoding');
  const r = spawnSync(process.execPath, [WORKER], {
    input: JSON.stringify({ module: MC_WASM, input: src + '\n', args }),
    encoding: 'utf8',
    maxBuffer: 64 << 20,
  });
  return JSON.parse(r.stdout);
}

for (const [triple, mattr, extra, src, expectedIform, expectedEosz] of CASES) {
  test(`${triple}: ${src}`, () => {
    // Step 1: assemble to hex bytes with llvm-mc
    const mc = mc_asm(triple, mattr, extra, src);
    assert.equal(mc.exit, 0, `${triple}: mc failed: ${mc.stderr.trim()}`);
    // Join ALL encoding groups: one line can carry several (prefix + instruction)
    const groups = [...mc.stdout.matchAll(/encoding: \[([^\]]+)\]/g)];
    assert.ok(groups.length > 0, `${triple}: no encoding line in ${JSON.stringify(mc.stdout)}`);
    const hexbytes = groups
      .flatMap(g => g[1].split(',').map(b => parseInt(b.trim(), 16).toString(16).padStart(2, '0')))
      .join('');
    
    // Step 2: decode with xedform
    const xed = run_xed(hexbytes + '\n');
    assert.equal(xed.exit, 0, `${triple}: xed decode failed: ${xed.stderr.trim()}`);
    const parts = xed.stdout.trim().split(/\s+/);
    assert.equal(parts[0], 'OK', `${triple}: xed decode error: ${xed.stdout}`);
    assert.equal(parts[2], expectedIform, `${src}: got iform ${parts[2]}, want ${expectedIform}`);
    // Check eosz for prefix-sensitive cases (data16 leave: eosz=16 vs 64)
    assert.ok(parts.includes(`eosz=${expectedEosz}`), 
      `${src}: eosz=${expectedEosz} missing from ${xed.stdout}`);
  });
}

// Mutation guard: verify the comparison actually works by running opposite check
test('mutation: byte mismatch is caught', () => {
  const xed = run_xed('62f17e486f0201\n');
  assert.equal(xed.exit, 0);
  const parts = xed.stdout.trim().split(/\s+/);
  assert.notEqual(parts[2], 'VMOVDQU64_ZMMu64_MASKmskw_MEMu64_AVX512',
    'mutation should produce a different iform');
});
