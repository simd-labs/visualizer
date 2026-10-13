  blez	a3, .LBB0_7
  li	a4, 0
  slli	a5, a3, 2
  mv	a6, a0
  j	.LBB0_3
.LBB0_2:
  add	a7, a7, a1
  addi	a4, a4, 1
  fsw	fa5, 0(a7)
  addi	a6, a6, 4
  beq	a4, a3, .LBB0_7
  .p2align 4
.LBB0_3:
                                          #     Child Loop BB0_5 Depth 2
  slli	a7, a4, 2
  add	t0, a0, a7
  flw	fa5, 0(t0)
  mv	t0, a6
  mv	t1, a2
  bgtz	a2, .LBB0_5
  j	.LBB0_2
.LBB0_4:
  addi	t1, t1, -1
  add	t0, t0, a5
  beqz	t1, .LBB0_2
  .p2align 4
.LBB0_5:
                                          # =>  This Inner Loop Header: Depth=2
  flw	fa4, 0(t0)
  flt.s	t2, fa5, fa4
  bnez	t2, .LBB0_4
  fmv.s	fa5, fa4
  j	.LBB0_4
.LBB0_7:
