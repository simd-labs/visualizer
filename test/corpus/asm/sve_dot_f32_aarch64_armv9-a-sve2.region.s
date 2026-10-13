  b.lt	.LBB0_3
  mov	x8, xzr
  .p2align 4
.LBB0_2:
  whilelo	p0.s, x8, x2
  ld1w	{ z1.s }, p0/z, [x0, x8, lsl #2]
  ld1w	{ z2.s }, p0/z, [x1, x8, lsl #2]
  incw	x8
  fmla	z0.s, p0/m, z1.s, z2.s
  cmp	x8, x2
  b.lt	.LBB0_2
.LBB0_3:
  ptrue	p0.s
