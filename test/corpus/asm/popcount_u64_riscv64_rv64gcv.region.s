  blez	a2, .LBB0_3
  li	a3, 0
  lui	a4, 349525
  lui	a5, 209715
  addi	a4, a4, 1365
  addi	a5, a5, 819
  slli	a6, a4, 32
  slli	a7, a5, 32
  add	a4, a4, a6
  add	a5, a5, a7
  lui	a6, 61681
  addi	a6, a6, -241
  lui	a7, 4112
  slli	t0, a6, 32
  addi	a7, a7, 257
  add	a6, a6, t0
  slli	t0, a7, 32
  add	a7, a7, t0
  li	t0, 56
  .p2align 4
.LBB0_2:
  vsetvli	t1, a2, e64, m2, ta, ma
  slli	t2, a3, 3
  add	t2, t2, a0
  vle64.v	v8, (t2)
  vsrl.vi	v10, v8, 1
  vand.vx	v10, v10, a4
  vsub.vv	v8, v8, v10
  vand.vx	v10, v8, a5
  vsrl.vi	v8, v8, 2
  vand.vx	v8, v8, a5
  vadd.vv	v8, v10, v8
  vsrl.vi	v10, v8, 4
  vadd.vv	v8, v8, v10
  vand.vx	v8, v8, a6
  vmul.vx	v8, v8, a7
  vsetvli	zero, zero, e32, m1, ta, ma
  vnsrl.wx	v10, v8, t0
  slli	t2, a3, 2
  add	t2, t2, a1
  sub	a2, a2, t1
  vse32.v	v10, (t2)
  add	a3, a3, t1
  bnez	a2, .LBB0_2
.LBB0_3:
