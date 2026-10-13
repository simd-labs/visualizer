  blez	a3, .LBB0_3
  li	a4, 0
  .p2align 4
.LBB0_2:
  vsetvli	a5, a3, e32, m2, ta, ma
  slli	a6, a4, 2
  add	a7, a0, a6
  vle32.v	v8, (a7)
  vdiv.vx	v8, v8, a2
  add	a6, a6, a1
  sub	a3, a3, a5
  vse32.v	v8, (a6)
  add	a4, a4, a5
  bnez	a3, .LBB0_2
.LBB0_3:
