  b.lt	.LBB0_6
  cnth	x8
  cmp	x2, x8
  b.hs	.LBB0_3
  mov	x8, xzr
  b	.LBB0_7
.LBB0_3:
  neg	x8, x8
  mov	z2.s, s0
  mov	z3.s, s1
  and	x8, x2, x8
  ptrue	p0.s
  mov	x9, x0
  mov	x10, x1
  mov	x11, x8
  .p2align 4
.LBB0_4:
  ldr	z4, [x9]
  ldr	z5, [x9, #1, mul vl]
  dech	x11
  incb	x9, all, mul #2
  fcmgt	p1.s, p0/z, z4.s, z3.s
  fcmgt	p2.s, p0/z, z5.s, z3.s
  fcmgt	p3.s, p0/z, z2.s, z4.s
  fcmgt	p4.s, p0/z, z2.s, z5.s
  mov	z4.s, p1/m, z3.s
  mov	z5.s, p2/m, z3.s
  mov	z4.s, p3/m, z2.s
  mov	z5.s, p4/m, z2.s
  str	z4, [x10]
  str	z5, [x10, #1, mul vl]
  incb	x10, all, mul #2
  cbnz	x11, .LBB0_4
  cmp	x2, x8
  b.ne	.LBB0_7
.LBB0_6:
