  blez	a2, .LBB0_3
  li	a3, 0
  .p2align 4
.LBB0_2:
  sub	a4, a2, a3
  slli	a5, a3, 2
  vsetvli	a4, a4, e32, m4, ta, ma
  add	a6, a0, a5
  vle32.v	v8, (a6)
  add	a5, a5, a1
  vle32.v	v12, (a5)
  vfmacc.vf	v12, fa0, v8
  add	a3, a3, a4
  vse32.v	v12, (a5)
  blt	a3, a2, .LBB0_2
.LBB0_3:
