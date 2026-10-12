// Generate ../cpus.json: every -mcpu per triple that the WASM llvm-mca runs
// on a real scheduling model. Kept entries exit 0, have a non-empty
// TargetInfo.Resources, and print no missing-model diagnostic on stderr.
// llvm-mca 23 fails a model-less CPU with exit 1 and
//   error: unable to find instruction-level scheduling information for target triple '<triple>' and cpu '<name>'.
import { writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import { run } from './run.mjs';

const NO_MODEL = 'unable to find instruction-level scheduling information';
const here = dirname(fileURLToPath(import.meta.url));

// One small loop per triple; every instruction must assemble for all CPUs of
// the target, so no FPU on RISCV (generic-rv64 lacks the D extension) and no
// AVX on x86 (atom and older lack AVX).
const LOOPS = {
  'x86_64-unknown-linux-gnu':
    'loop:\n  mov (%rsi), %rax\n  add $1, %rdi\n  xor %rax, %rdi\n  cmp $100, %rdi\n  jb loop\n',
  'aarch64-unknown-linux-gnu': 'kern:\n  ldr q0, [x1]\n  ldr q1, [x2]\n  fmla v2.2d, v0.2d, v1.2d\n  add x0, x0, #1\n  cbnz x0, kern\n',
  'riscv64-unknown-linux-gnu':
    'loop:\n  ld a1, 0(a2)\n  add a1, a1, a3\n  xor a4, a1, a5\n  addi a0, a0, 1\n  bnez a0, loop\n',
};

function listCpus(triple) {
  // -mcpu=help prints the table to stderr; spawnSync never throws on non-zero.
  const text = run('', ['-mtriple=' + triple, '-mcpu=help']).stderr;
  return [...text.matchAll(/^ {2}(\S+)\s+- Select the \1 processor\.$/gm)].map(m => m[1]);
}
const out = {};
const dropped = {};
for (const triple of Object.keys(LOOPS)) {
  out[triple] = [];
  dropped[triple] = [];
  for (const cpu of listCpus(triple)) {
    const { exit, stdout, stderr } = run(LOOPS[triple],
      ['-mtriple=' + triple, '-mcpu=' + cpu, '-timeline', '-iterations=1', '-json']);
    let nres = 0;
    try { nres = JSON.parse(stdout).TargetInfo?.Resources?.length ?? 0; } catch { /* below */ }
    const note = stderr.match(/error:.*|warning:.*/g)?.join(' ') ?? '';
    if (exit === 0 && nres > 0 && !stderr.includes(NO_MODEL)) {
      out[triple].push(cpu);
    } else {
      dropped[triple].push(`${cpu}: exit=${exit} resources=${nres} ${note}`);
    }
  }
  console.log(`${triple}: kept ${out[triple].length}, dropped ${dropped[triple].length}`);
  for (const d of dropped[triple]) console.log('  drop ' + d);
}

writeFileSync(join(here, '../cpus.json'), JSON.stringify(out, null, 1) + '\n');
console.log('wrote cpus.json');
