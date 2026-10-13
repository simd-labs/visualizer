  blez	a2, .LBB0_3
  li	a3, 0
  .p2align 4
.LBB0_2:
  vsetvli	a4, a2, e8, mf2, ta, ma
  slli	a5, a3, 2
  add	a6, a0, a5
  vle32.v	v8, (a6)
  add	a5, a5, a1
  sub	a2, a2, a4
  add	a3, a3, a4
  vse32.v	v8, (a5)
  bnez	a2, .LBB0_2
.LBB0_3:
