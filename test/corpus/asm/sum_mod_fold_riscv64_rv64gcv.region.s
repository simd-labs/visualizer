  blez	a1, .LBB0_4
  li	a2, 0
  vsetvli	a3, zero, e64, m2, ta, ma
  vmv.v.i	v8, 0
  vmv.v.i	v10, 0
  lui	a3, 16
  addi	a3, a3, -1
  .p2align 4
.LBB0_2:
  vsetvli	a4, a1, e32, m1, ta, ma
  slli	a5, a2, 2
  add	a5, a5, a0
  vle32.v	v12, (a5)
  vand.vx	v13, v12, a3
  vsra.vi	v12, v12, 16
  vsetvli	zero, zero, e32, m1, tu, ma
  vwaddu.wv	v10, v10, v13
  vwadd.wv	v8, v8, v12
  sub	a1, a1, a4
  add	a2, a2, a4
  bnez	a1, .LBB0_2
  vsetvli	a0, zero, e64, m2, ta, ma
  vmv.s.x	v12, zero
  vredsum.vs	v8, v8, v12
  vredsum.vs	v9, v10, v12
  vmv.x.s	a1, v8
  vmv.x.s	a0, v9
  slli	a1, a1, 16
  j	.LBB0_5
.LBB0_4:
  li	a0, 0
  li	a1, 0
.LBB0_5:
  add	a0, a0, a1
