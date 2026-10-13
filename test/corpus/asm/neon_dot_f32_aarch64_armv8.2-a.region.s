  b.lt	.LBB0_3
  mov	x8, xzr
  .p2align 4
.LBB0_2:
  ldr	q1, [x0], #16
  add	x8, x8, #4
  ldr	q2, [x1], #16
  cmp	x8, x2
  fmla	v0.4s, v2.4s, v1.4s
  b.lt	.LBB0_2
.LBB0_3:
  faddp	v0.4s, v0.4s, v0.4s
