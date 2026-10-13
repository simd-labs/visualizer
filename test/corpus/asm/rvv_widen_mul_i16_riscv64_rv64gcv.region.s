  blez	a3, .LBB0_3
  li	a4, 0
  .p2align 4
.LBB0_2:
  sub	a5, a3, a4
  add	a6, a0, a4
  vsetvli	a5, a5, e8, m2, ta, ma
  vle8.v	v12, (a6)
  add	a6, a1, a4
  vle8.v	v14, (a6)
  vwmul.vv	v8, v12, v14
  slli	a6, a4, 1
  add	a6, a6, a2
  add	a4, a4, a5
  vse16.v	v8, (a6)
  blt	a4, a3, .LBB0_2
.LBB0_3:
