  blez	a3, .LBB0_3
  li	a4, 0
  addi	a3, a3, -1
  srli	a3, a3, 1
  addi	a3, a3, 1
  .p2align 4
.LBB0_2:
  vsetvli	a5, a3, e16, m1, ta, ma
  slli	a6, a4, 2
  add	a7, a0, a6
  vlseg2e16.v	v10, (a7)
  add	a7, a1, a6
  vlseg2e16.v	v12, (a7)
  vwmul.vv	v8, v12, v10
  vwmacc.vv	v8, v13, v11
  add	a6, a6, a2
  sub	a3, a3, a5
  add	a4, a4, a5
  vse32.v	v8, (a6)
  bnez	a3, .LBB0_2
.LBB0_3:
