.text
.globl loop
# Sum 8 floats per iteration from %rdi into ymm0: one accumulator,
# one dependency chain, no unrolling.
# LLVM-MCA-BEGIN reduction-1acc
loop:
  vaddps (%rdi), %ymm0, %ymm0
  addq $32, %rdi
  subq $1, %rsi
  jne loop
# LLVM-MCA-END reduction-1acc
# The horizontal sum of ymm0 runs after the loop, outside the simulated region.
