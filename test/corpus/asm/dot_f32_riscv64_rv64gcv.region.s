  blez	a2, .LBB0_4
  vsetvli	a3, zero, e32, m1, ta, ma
  vmv.s.x	v8, zero
  li	a3, 0
  .p2align 4
.LBB0_2:
  vsetvli	a4, a2, e32, m2, ta, ma
  slli	a5, a3, 2
  add	a6, a0, a5
  vle32.v	v10, (a6)
  add	a5, a5, a1
  vle32.v	v12, (a5)
  vfmul.vv	v10, v10, v12
  vfredosum.vs	v8, v10, v8
  sub	a2, a2, a4
  add	a3, a3, a4
  bnez	a2, .LBB0_2
  vfmv.f.s	fa0, v8
