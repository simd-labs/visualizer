.text
.globl loop
loop:
  ldr d0, [x1, x0, lsl #3]
  fmadd d0, d0, d1, d2
  fadd d2, d2, d0
  add x0, x0, #1
  cbnz x0, loop
