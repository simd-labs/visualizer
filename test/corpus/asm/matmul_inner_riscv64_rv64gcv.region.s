  blez	a3, .LBB0_9
  li	a5, 0
  mul	a6, a4, a3
  slli	a4, a4, 2
  add	a0, a0, a4
  flw	fa5, 0(a0)
  slli	a6, a6, 2
  add	a1, a1, a6
  mv	a4, a3
  .p2align 4
.LBB0_2:
  vsetvli	a6, a4, e32, m2, ta, ma
  slli	a7, a5, 2
  add	t0, a1, a7
  vle32.v	v8, (t0)
  add	a7, a7, a2
  vle32.v	v10, (a7)
  vfmacc.vf	v10, fa5, v8
  sub	a4, a4, a6
  vse32.v	v10, (a7)
  add	a5, a5, a6
  bnez	a4, .LBB0_2
  li	a5, 0
  slli	a4, a3, 2
  add	a6, a0, a4
  flw	fa5, 0(a6)
  add	a6, a2, a4
  mv	a7, a3
  .p2align 4
.LBB0_4:
  vsetvli	t0, a7, e32, m2, ta, ma
  slli	t1, a5, 2
  add	t2, a1, t1
  vle32.v	v8, (t2)
  add	t1, t1, a6
  vle32.v	v10, (t1)
  vfmacc.vf	v10, fa5, v8
  sub	a7, a7, t0
  vse32.v	v10, (t1)
  add	a5, a5, t0
  bnez	a7, .LBB0_4
  li	a6, 0
  slli	a5, a3, 3
  add	a7, a0, a5
  flw	fa5, 0(a7)
  add	a7, a2, a5
  mv	t0, a3
  .p2align 4
.LBB0_6:
  vsetvli	t1, t0, e32, m2, ta, ma
  slli	t2, a6, 2
  add	t3, a1, t2
  vle32.v	v8, (t3)
  add	t2, t2, a7
  vle32.v	v10, (t2)
  vfmacc.vf	v10, fa5, v8
  sub	t0, t0, t1
  vse32.v	v10, (t2)
  add	a6, a6, t1
  bnez	t0, .LBB0_6
  li	a6, 0
  add	a4, a4, a5
  add	a0, a0, a4
  flw	fa5, 0(a0)
  add	a2, a2, a4
  .p2align 4
.LBB0_8:
  vsetvli	a0, a3, e32, m2, ta, ma
  slli	a4, a6, 2
  add	a5, a1, a4
  vle32.v	v8, (a5)
  add	a4, a4, a2
  vle32.v	v10, (a4)
  vfmacc.vf	v10, fa5, v8
  sub	a3, a3, a0
  vse32.v	v10, (a4)
  add	a6, a6, a0
  bnez	a3, .LBB0_8
.LBB0_9:
