.text
.globl loop
# Sum 16 x 8 floats per iteration from %rdi into ymm0 to ymm15: every
# ymm register is an accumulator, so the 16 dependency chains overlap.
# LLVM-MCA-BEGIN reduction-16acc
loop:
  vaddps 0(%rdi), %ymm0, %ymm0
  vaddps 32(%rdi), %ymm1, %ymm1
  vaddps 64(%rdi), %ymm2, %ymm2
  vaddps 96(%rdi), %ymm3, %ymm3
  vaddps 128(%rdi), %ymm4, %ymm4
  vaddps 160(%rdi), %ymm5, %ymm5
  vaddps 192(%rdi), %ymm6, %ymm6
  vaddps 224(%rdi), %ymm7, %ymm7
  vaddps 256(%rdi), %ymm8, %ymm8
  vaddps 288(%rdi), %ymm9, %ymm9
  vaddps 320(%rdi), %ymm10, %ymm10
  vaddps 352(%rdi), %ymm11, %ymm11
  vaddps 384(%rdi), %ymm12, %ymm12
  vaddps 416(%rdi), %ymm13, %ymm13
  vaddps 448(%rdi), %ymm14, %ymm14
  vaddps 480(%rdi), %ymm15, %ymm15
  addq $512, %rdi
  subq $1, %rsi
  jne loop
# LLVM-MCA-END reduction-16acc
# The horizontal sums of ymm0 to ymm15 run after the loop, outside the simulated region.
