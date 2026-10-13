  li	a3, 0
  blez	a1, .LBB0_4
  .p2align 4
.LBB0_1:
  add	a4, a0, a3
  lbu	a4, 0(a4)
  beqz	a4, .LBB0_4
  addi	a3, a3, 1
  bne	a1, a3, .LBB0_1
  mv	a3, a1
.LBB0_4:
