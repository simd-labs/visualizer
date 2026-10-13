  blez	a2, .LBB0_3
  vsetvli	a3, zero, e32, m2, ta, ma
  vfmv.v.f	v8, fa0
  li	a3, 0
  .p2align 4
.LBB0_2:
  vsetvli	a4, a2, e32, m2, ta, ma
  slli	a5, a3, 2
  add	a6, a0, a5
  vle32.v	v10, (a6)
  vmflt.vv	v12, v10, v8
  vmfgt.vf	v13, v10, fa1
  vmnot.m	v14, v12
  vmandn.mm	v0, v14, v13
  vmerge.vvm	v10, v8, v10, v0
  vmandn.mm	v0, v13, v12
  vfmerge.vfm	v10, v10, fa1, v0
  add	a5, a5, a1
  sub	a2, a2, a4
  vse32.v	v10, (a5)
  add	a3, a3, a4
  bnez	a2, .LBB0_2
.LBB0_3:
