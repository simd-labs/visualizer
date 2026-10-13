  blt	a2, a3, .LBB0_4
  li	a4, 0
  addi	a3, a2, -4
  srli	a3, a3, 2
  addi	a5, a3, 1
  slli	a3, a5, 2
  .p2align 4
.LBB0_2:
  vsetvli	a6, a5, e32, m2, ta, ma
  slli	a7, a4, 4
  add	t0, a0, a7
  vlseg4e32.v	v8, (t0)
  vfmul.vf	v8, v8, fa0
  vfmul.vf	v10, v10, fa0
  vfmul.vf	v12, v12, fa0
  vfmul.vf	v14, v14, fa0
  add	a7, a7, a1
  sub	a5, a5, a6
  add	a4, a4, a6
  vsseg4e32.v	v8, (a7)
  bnez	a5, .LBB0_2
  blt	a3, a2, .LBB0_5
  j	.LBB0_7
.LBB0_4:
  li	a3, 0
  blez	a2, .LBB0_7
.LBB0_5:
  li	a4, 0
  sub	a2, a2, a3
  .p2align 4
.LBB0_6:
  vsetvli	a5, a2, e32, m2, ta, ma
  add	a6, a3, a4
  slli	a6, a6, 2
  add	a7, a0, a6
  vle32.v	v8, (a7)
  vfmul.vf	v8, v8, fa0
  add	a6, a6, a1
  sub	a2, a2, a5
  vse32.v	v8, (a6)
  add	a4, a4, a5
  bnez	a2, .LBB0_6
.LBB0_7:
