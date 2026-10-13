  bgeu	a0, a1, .LBB0_5
  blez	a2, .LBB0_13
  csrr	a3, vlenb
  slli	a3, a3, 1
  neg	a3, a3
  sub	a4, a1, a0
  bgeu	a3, a4, .LBB0_9
  add	a2, a2, a0
  .p2align 4
.LBB0_4:
  lbu	a3, 0(a1)
  sb	a3, 0(a0)
  addi	a0, a0, 1
  addi	a1, a1, 1
  bne	a0, a2, .LBB0_4
  j	.LBB0_13
.LBB0_5:
  blez	a2, .LBB0_13
  csrr	a3, vlenb
  slli	a3, a3, 1
  neg	a3, a3
  sub	a4, a0, a1
  bgeu	a3, a4, .LBB0_11
  addi	a3, a2, -1
  li	a2, 1
  .p2align 4
.LBB0_8:
  add	a4, a1, a3
  lbu	a4, 0(a4)
  add	a5, a0, a3
  addi	a6, a3, 1
  addi	a3, a3, -1
  sb	a4, 0(a5)
  bltu	a2, a6, .LBB0_8
  j	.LBB0_13
.LBB0_9:
  li	a3, 0
  .p2align 4
.LBB0_10:
  vsetvli	a4, a2, e8, m2, ta, ma
  add	a5, a1, a3
  vle8.v	v8, (a5)
  add	a5, a0, a3
  sub	a2, a2, a4
  add	a3, a3, a4
  vse8.v	v8, (a5)
  bnez	a2, .LBB0_10
  j	.LBB0_13
.LBB0_11:
  li	a3, 0
  li	a4, 1
  mv	a5, a2
  .p2align 4
.LBB0_12:
  vsetvli	a6, a5, e8, m2, ta, ma
  not	a7, a3
  add	a7, a7, a2
  add	t0, a1, a7
  sub	t1, a4, a6
  add	t0, t0, t1
  vle8.v	v8, (t0)
  add	a7, a7, a0
  add	a7, a7, t1
  sub	a5, a5, a6
  vse8.v	v8, (a7)
  add	a3, a3, a6
  bnez	a5, .LBB0_12
.LBB0_13:
