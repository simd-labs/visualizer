  blez	a2, .LBB0_3
  vsetvli	a3, zero, e32, m2, ta, ma
  vmv.v.x	v8, a1
  li	a1, 0
  .p2align 4
.LBB0_2:
  vsetvli	a3, a2, e8, mf2, ta, ma
  slli	a4, a1, 2
  add	a4, a4, a0
  sub	a2, a2, a3
  add	a1, a1, a3
  vse32.v	v8, (a4)
  bnez	a2, .LBB0_2
.LBB0_3:
