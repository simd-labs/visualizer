  blez	a2, .LBB0_3
  lui	a3, 258048
  fmv.w.x	fa5, a3
  li	a4, 0
  .p2align 4
.LBB0_2:
  vsetvli	a5, a2, e32, m2, ta, ma
  slli	a6, a4, 2
  add	a7, a0, a6
  vle32.v	v8, (a7)
  vmv.v.x	v10, a3
  vfmacc.vf	v10, fa5, v8
  vfdiv.vv	v12, v8, v10
  vfadd.vv	v10, v10, v12
  vfmul.vf	v10, v10, fa5
  vfdiv.vv	v12, v8, v10
  vfadd.vv	v10, v10, v12
  vfmul.vf	v10, v10, fa5
  vfdiv.vv	v12, v8, v10
  vfadd.vv	v10, v10, v12
  vfmul.vf	v10, v10, fa5
  vfdiv.vv	v8, v8, v10
  vfadd.vv	v8, v10, v8
  vfmul.vf	v8, v8, fa5
  add	a6, a6, a1
  sub	a2, a2, a5
  vse32.v	v8, (a6)
  add	a4, a4, a5
  bnez	a2, .LBB0_2
.LBB0_3:
