// Re-validate every cpu.json entry against the WASM llvm-mca, the same filter
// wasm/cpus.mjs applied, and assert the known model-less x86 CPU `i386` (exit
// 1, "unable to find instruction-level scheduling information...") is absent.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import { run } from '../wasm/run.mjs';

const NO_MODEL = 'unable to find instruction-level scheduling information';
const here = dirname(fileURLToPath(import.meta.url));
const cpus = JSON.parse(readFileSync(join(here, '../cpus.json'), 'utf8'));

const LOOPS = {
  'x86_64-unknown-linux-gnu':
    'loop:\n  mov (%rsi), %rax\n  add $1, %rdi\n  xor %rax, %rdi\n  cmp $100, %rdi\n  jb loop\n',
  'aarch64-unknown-linux-gnu': 'kern:\n  ldr q0, [x1]\n  ldr q1, [x2]\n  fmla v2.2d, v0.2d, v1.2d\n  add x0, x0, #1\n  cbnz x0, kern\n',
  'riscv64-unknown-linux-gnu':
    'loop:\n  ld a1, 0(a2)\n  add a1, a1, a3\n  xor a4, a1, a5\n  addi a0, a0, 1\n  bnez a0, loop\n',
};

assert.deepEqual(Object.keys(cpus).sort(), Object.keys(LOOPS).sort(), 'triple keys');

// Mutation hook: MUTATE_CPUS inserts a model-less CPU into the list; the suite
// must fail. Run: MUTATE_CPUS=1 node --test test/cpus.test.mjs (expect failure).
if (process.env.MUTATE_CPUS) cpus['x86_64-unknown-linux-gnu'].push('i386');

for (const [triple, list] of Object.entries(cpus)) {
  assert.ok(list.length > 0, `${triple}: no cpus`);
  assert.ok(!list.includes('i386'), `${triple}: model-less i386 must be absent`);
  for (const cpu of list) {
    test(`${triple} ${cpu}`, () => {
      const { exit, stdout, stderr } = run(LOOPS[triple],
        ['-mtriple=' + triple, '-mcpu=' + cpu, '-timeline', '-iterations=1', '-json']);
      assert.equal(exit, 0, stderr.slice(0, 200));
      assert.ok(JSON.parse(stdout).TargetInfo.Resources.length > 0, 'no TargetInfo.Resources');
      assert.ok(!stderr.includes(NO_MODEL), 'missing-model diagnostic present');
    });
  }
}
