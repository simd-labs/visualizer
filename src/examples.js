// One example loop per architecture. Each uses only the base ISA that every
// CPU of its triple in cpus.json accepts (test/examples.test.mjs runs each on
// all of them): SSE2 on x86-64 (atom-class CPUs lack AVX), AdvSIMD on AArch64,
// and RV64I on RISC-V (generic-rv64 and rocket-rv64 lack F and M).
const x86 = `.text
.globl loop
loop:
  movups (%rsi,%rax,4), %xmm0
  mulps %xmm1, %xmm0
  addps %xmm0, %xmm2
  addq $4, %rax
  cmpq %rdx, %rax
  jne loop
`;
const aarch64 = `.text
.globl loop
loop:
  ldr q0, [x1, x0]
  fmul v0.4s, v0.4s, v1.4s
  fadd v2.4s, v2.4s, v0.4s
  str q2, [x2, x0]
  add x0, x0, #16
  subs x3, x3, #1
  b.ne loop
`;
const riscv = `.text
.globl loop
loop:
  lw a3, 0(a1)
  add a3, a3, a4
  sw a3, 0(a2)
  addi a1, a1, 4
  addi a2, a2, 4
  addi a0, a0, -1
  bnez a0, loop
`;

// keyed by the first part of the cpus.json triple, as the page's optgroups are
export const EXAMPLES = { x86_64: x86, aarch64, riscv64: riscv };
export const exampleFor = (triple) => EXAMPLES[triple.split('-')[0]];
