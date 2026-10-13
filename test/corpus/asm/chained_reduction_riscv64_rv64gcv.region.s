  lui	a2, 260096
  blez	a1, .LBB0_4
  fmv.w.x	fa5, a2
  slli	a1, a1, 2
  add	a1, a1, a0
  fmv.s	fa0, fa5
  .p2align 4
.LBB0_2:
  flw	fa4, 0(a0)
  fmadd.s	fa3, fa0, fa4, fa5
  fmul.s	fa4, fa0, fa4
  fmul.s	fa0, fa4, fa3
  addi	a0, a0, 4
  bne	a0, a1, .LBB0_2
