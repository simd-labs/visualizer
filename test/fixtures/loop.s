.text
.globl loop
loop:
  vmovups (%rsi,%rax,4), %ymm0
  vfmadd231ps %ymm1, %ymm2, %ymm0
  addq $8, %rax
  jne loop
