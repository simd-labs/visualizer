  b.lt	.LBB0_3
  mov	x8, xzr
  .p2align 4
.LBB0_2:
  whilelo	p0.s, x8, x3
  ld1w	{ z0.s }, p0/z, [x1, x8, lsl #2]
  ld1w	{ z0.s }, p0/z, [x0, z0.s, sxtw #2]
  st1w	{ z0.s }, p0, [x2, x8, lsl #2]
  incw	x8
  cmp	x8, x3
  b.lt	.LBB0_2
.LBB0_3:
