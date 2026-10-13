  blez	a2, .LBB0_3
  li	a3, 0
  .p2align 4
.LBB0_2:
  sub	a4, a2, a3
  slli	a5, a3, 2
  vsetvli	a4, a4, e32, m2, ta, ma
  add	a6, a0, a5
  vle32.v	v10, (a6)
  add	a5, a5, a1
  vle32.v	v12, (a5)
  vfmacc.vv	v8, v12, v10
  add	a3, a3, a4
  blt	a3, a2, .LBB0_2
.LBB0_3:
  vsetivli	zero, 1, e32, m1, ta, ma
  vmv.v.i	v10, 0
  vsetvli	zero, a2, e32, m2, ta, ma
  vfredusum.vs	v8, v8, v10
  vfmv.f.s	fa0, v8
