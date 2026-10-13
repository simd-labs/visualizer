  blez	a3, .LBB0_3
  li	a4, 0
  .p2align 4
.LBB0_2:
  vsetvli	a5, a3, e8, m2, ta, ma
  add	a6, a0, a4
  vle8.v	v8, (a6)
  add	a6, a1, a4
  vle8.v	v10, (a6)
  vxor.vv	v8, v10, v8
  add	a6, a2, a4
  sub	a3, a3, a5
  add	a4, a4, a5
  vse8.v	v8, (a6)
  bnez	a3, .LBB0_2
.LBB0_3:
