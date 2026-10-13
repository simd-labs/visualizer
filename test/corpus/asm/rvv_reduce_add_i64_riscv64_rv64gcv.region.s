  blez	a1, .LBB0_3
  li	a2, 0
  .p2align 4
.LBB0_2:
  sub	a3, a1, a2
  slli	a4, a2, 3
  vsetvli	a3, a3, e64, m4, ta, ma
  add	a4, a4, a0
  vle64.v	v12, (a4)
  vadd.vv	v8, v8, v12
  add	a2, a2, a3
  blt	a2, a1, .LBB0_2
.LBB0_3:
  vsetivli	zero, 1, e64, m1, ta, ma
  vmv.v.i	v12, 0
  vsetvli	zero, a1, e64, m4, ta, ma
  vredsum.vs	v8, v8, v12
  vmv.x.s	a0, v8
