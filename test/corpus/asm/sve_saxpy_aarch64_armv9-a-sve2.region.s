  b.lt	.LBB0_3
  mov	z0.s, s0
  mov	x8, xzr
  .p2align 4
.LBB0_2:
  whilelo	p0.s, x8, x2
  mov	z3.d, z0.d
  ld1w	{ z1.s }, p0/z, [x0, x8, lsl #2]
  ld1w	{ z2.s }, p0/z, [x1, x8, lsl #2]
  fmad	z3.s, p0/m, z1.s, z2.s
  st1w	{ z3.s }, p0, [x1, x8, lsl #2]
  incw	x8
  cmp	x8, x2
  b.lt	.LBB0_2
.LBB0_3:
