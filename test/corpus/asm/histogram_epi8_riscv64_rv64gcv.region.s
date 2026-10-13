  blez	a2, .LBB0_3
  add	a2, a2, a0
  .p2align 4
.LBB0_2:
  lbu	a3, 0(a0)
  addi	a0, a0, 1
  slli	a3, a3, 2
  add	a3, a3, a1
  lw	a4, 0(a3)
  addi	a4, a4, 1
  sw	a4, 0(a3)
  bne	a0, a2, .LBB0_2
.LBB0_3:
