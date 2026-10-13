  blez	a3, .LBB0_3
  li	a4, 0
  .p2align 4
.LBB0_2:
  sub	a5, a3, a4
  slli	a6, a4, 2
  vsetvli	a5, a5, e32, m4, ta, ma
  add	a7, a1, a6
  vle32.v	v8, (a7)
  vloxei32.v	v8, (a0), v8
  add	a6, a6, a2
  add	a4, a4, a5
  vse32.v	v8, (a6)
  blt	a4, a3, .LBB0_2
.LBB0_3:
