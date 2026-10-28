// Assemble one -show-encoding line per target with the WASM llvm-mc and
// compare the bytes against the native expectations of simdref-llvm-mc
// tests/test_assemble.py (captured from llvm-mc-23 23.1.4).
import test from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { dirname, join, resolve } from 'node:path';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const WORKER = resolve(root, 'wasm/run-worker.mjs');
const MODULE = process.env.MC_WASM || resolve(root, 'wasm/dist/llvm-mc.js');

// (triple, mattr, extra args, source line, expected encoding bytes)
const CASES = [
  ['aarch64', '+sve2,+sme2', [], 'ld1b {z0.b, z1.b}, pn8/z, [x0]',
    [0x00, 0x00, 0x40, 0xa0]],
  ['aarch64', '+sve2,+sme2', [], 'mov w0, #-65536',
    [0xE0, 0xFF, 0xBF, 0x52]],
  ['aarch64', '+sve2,+sme2', [], 'add x0, x1, w2, uxtw #2',
    [0x20, 0x48, 0x22, 0x8B]],
  ['x86_64', '', [], 'movzbl (%rdx), %eax',
    [0x0F, 0xB6, 0x02]],
  ['x86_64', '+avx512f', ['-x86-asm-syntax=intel'],
    'vmovdqu32 zmm0, zmmword ptr [rdx]',
    [0x62, 0xF1, 0x7E, 0x48, 0x6F, 0x02]],
  ['riscv64', '+zba,+v', [], 'sh1add a0, a1, a2',
    [0x33, 0xA5, 0xC5, 0x20]],
  ['riscv64', '+zba,+v', [], 'vle32.v v0, (a0)',
    [0x07, 0x60, 0x05, 0x02]],
];

function assemble(line, args) {
  const r = spawnSync(process.execPath, [WORKER], {
    input: JSON.stringify({ module: MODULE, input: line + '\n', args }),
    encoding: 'utf8',
    maxBuffer: 64 << 20,
  });
  return JSON.parse(r.stdout);
}

for (const [triple, mattr, extra, src, expected] of CASES) {
  test(`${triple}: ${src}`, () => {
    const args = [`-triple=${triple}`];
    if (mattr) args.push(`-mattr=${mattr}`);
    args.push(...extra, '-show-encoding');
    const { exit, stdout, stderr } = assemble(src, args);
    assert.equal(exit, 0, `${triple}: ${stderr.trim()}`);
    const m = stdout.match(/encoding: \[([^\]]+)\]/);
    assert.ok(m, `${triple}: no encoding line in ${JSON.stringify(stdout)}`);
    const got = m[1].split(',').map(b => parseInt(b, 16));
    assert.deepEqual(got, expected);
  });
}

// Mutation guard: a wrong expectation must fail, proving the comparison runs.
test('mutation: wrong bytes are rejected', () => {
  const { exit, stdout } = assemble('sh1add a0, a1, a2',
    ['-triple=riscv64', '-mattr=+zba', '-show-encoding']);
  assert.equal(exit, 0);
  const m = stdout.match(/encoding: \[([^\]]+)\]/);
  const got = m[1].split(',').map(b => parseInt(b, 16));
  assert.notDeepEqual(got, [0x33, 0xa5, 0xc5, 0x21]);
});
