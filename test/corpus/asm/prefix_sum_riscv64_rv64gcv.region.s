  blez	a2, .LBB0_3
  fmv.w.x	fa5, zero
  slli	a2, a2, 2
  add	a2, a2, a1
  .p2align 4
.LBB0_2:
  flw	fa4, 0(a0)
  fadd.s	fa5, fa5, fa4
  fsw	fa5, 0(a1)
  addi	a1, a1, 4
  addi	a0, a0, 4
  bne	a1, a2, .LBB0_2
.LBB0_3:
