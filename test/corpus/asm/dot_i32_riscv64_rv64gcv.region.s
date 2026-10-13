  blez	a2, .LBB0_4
  vsetvli	a3, zero, e64, m2, ta, ma
  vmv.v.i	v8, 0
  li	a3, 0
  .p2align 4
.LBB0_2:
  vsetvli	a4, a2, e8, mf4, ta, ma
  slli	a5, a3, 2
  add	a6, a0, a5
  vle32.v	v10, (a6)
  add	a5, a5, a1
  vle32.v	v11, (a5)
  vsetvli	zero, zero, e32, m1, tu, ma
  vwmacc.vv	v8, v11, v10
  sub	a2, a2, a4
  add	a3, a3, a4
  bnez	a2, .LBB0_2
  vsetvli	a0, zero, e64, m2, ta, ma
  vmv.s.x	v10, zero
  vredsum.vs	v8, v8, v10
  vmv.x.s	a0, v8
