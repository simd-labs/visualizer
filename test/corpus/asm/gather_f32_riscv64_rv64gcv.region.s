  blez	a3, .LBB0_3
  li	a4, 0
  li	a5, 4
  .p2align 4
.LBB0_2:
  vsetvli	a6, a3, e32, m2, ta, ma
  slli	a7, a4, 2
  add	t0, a1, a7
  vle32.v	v12, (t0)
  vwmulsu.vx	v8, v12, a5
  vluxei64.v	v12, (a0), v8
  add	a7, a7, a2
  sub	a3, a3, a6
  vse32.v	v12, (a7)
  add	a4, a4, a6
  bnez	a3, .LBB0_2
.LBB0_3:
