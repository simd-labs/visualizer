  b.lt	.LBB0_8
  cntw	x8
  cmp	x2, x8
  b.hs	.LBB0_3
  mov	x8, xzr
  b	.LBB0_6
.LBB0_3:
  fmov	z0.s, #0.50000000
  neg	x8, x8
  mov	x9, xzr
  ptrue	p0.s
  and	x8, x2, x8
  .p2align 4
.LBB0_4:
  ld1w	{ z1.s }, p0/z, [x0, x9, lsl #2]
  movprfx	z2, z0
  fmla	z2.s, p0/m, z1.s, z0.s
  movprfx	z3, z1
  fdiv	z3.s, p0/m, z3.s, z2.s
  fadd	z2.s, z2.s, z3.s
  fmul	z2.s, p0/m, z2.s, #0.5
  movprfx	z3, z1
  fdiv	z3.s, p0/m, z3.s, z2.s
  fadd	z2.s, z2.s, z3.s
  fmul	z2.s, p0/m, z2.s, #0.5
  movprfx	z3, z1
  fdiv	z3.s, p0/m, z3.s, z2.s
  fadd	z2.s, z2.s, z3.s
  fmul	z2.s, p0/m, z2.s, #0.5
  fdiv	z1.s, p0/m, z1.s, z2.s
  fadd	z1.s, z2.s, z1.s
  fmul	z1.s, p0/m, z1.s, #0.5
  st1w	{ z1.s }, p0, [x1, x9, lsl #2]
  incw	x9
  cmp	x8, x9
  b.ne	.LBB0_4
  cmp	x2, x8
  b.eq	.LBB0_8
.LBB0_6:
  lsl	x10, x8, #2
  fmov	s0, #0.50000000
  sub	x8, x2, x8
  add	x9, x1, x10
  add	x10, x0, x10
  .p2align 4
.LBB0_7:
  ldr	s1, [x10], #4
  subs	x8, x8, #1
  fmadd	s2, s1, s0, s0
  fdiv	s3, s1, s2
  fadd	s2, s2, s3
  fmul	s2, s2, s0
  fdiv	s3, s1, s2
  fadd	s2, s2, s3
  fmul	s2, s2, s0
  fdiv	s3, s1, s2
  fadd	s2, s2, s3
  fmul	s2, s2, s0
  fdiv	s1, s1, s2
  fadd	s1, s2, s1
  fmul	s1, s1, s0
  str	s1, [x9], #4
  b.ne	.LBB0_7
.LBB0_8:
