  b.lt	.LBB0_29
  mul	x8, x4, x3
  add	x11, x0, x4, lsl #2
  cnth	x10
  cmp	x3, x10
  ldr	s0, [x11]
  add	x9, x1, x8, lsl #2
  b.hs	.LBB0_3
  mov	x12, xzr
  b	.LBB0_6
.LBB0_3:
  neg	x12, x10
  mov	z1.s, s0
  ptrue	p0.s
  and	x12, x3, x12
  mov	x13, x9
  mov	x14, x2
  mov	x15, x12
  .p2align 4
.LBB0_4:
  ldr	z2, [x13]
  ldr	z3, [x14]
  dech	x15
  ldr	z4, [x13, #1, mul vl]
  ldr	z5, [x14, #1, mul vl]
  incb	x13, all, mul #2
  fmad	z2.s, p0/m, z1.s, z3.s
  fmad	z4.s, p0/m, z1.s, z5.s
  str	z2, [x14]
  str	z4, [x14, #1, mul vl]
  incb	x14, all, mul #2
  cbnz	x15, .LBB0_4
  cmp	x3, x12
  b.eq	.LBB0_8
.LBB0_6:
  lsl	x14, x12, #2
  sub	x12, x3, x12
  add	x13, x14, x8, lsl #2
  add	x14, x2, x14
  add	x13, x1, x13
  .p2align 4
.LBB0_7:
  ldr	s1, [x13], #4
  ldr	s2, [x14]
  subs	x12, x12, #1
  fmadd	s1, s0, s1, s2
  str	s1, [x14], #4
  b.ne	.LBB0_7
.LBB0_8:
  lsl	x13, x3, #2
  cmp	x3, x10
  ldr	s0, [x11, x13]
  b.hs	.LBB0_10
  mov	x12, xzr
  b	.LBB0_13
.LBB0_10:
  neg	x12, x10
  mov	z1.s, s0
  ptrue	p0.s
  and	x12, x3, x12
  add	x13, x2, x13
  mov	x14, x9
  mov	x15, x12
  .p2align 4
.LBB0_11:
  ldr	z2, [x14]
  ldr	z3, [x13]
  dech	x15
  ldr	z4, [x14, #1, mul vl]
  ldr	z5, [x13, #1, mul vl]
  incb	x14, all, mul #2
  fmad	z2.s, p0/m, z1.s, z3.s
  fmad	z4.s, p0/m, z1.s, z5.s
  str	z2, [x13]
  str	z4, [x13, #1, mul vl]
  incb	x13, all, mul #2
  cbnz	x15, .LBB0_11
  cmp	x3, x12
  b.eq	.LBB0_15
.LBB0_13:
  lsl	x13, x12, #2
  sub	x12, x3, x12
  add	x14, x13, x3, lsl #2
  add	x15, x13, x8, lsl #2
  add	x13, x2, x14
  add	x14, x1, x15
  .p2align 4
.LBB0_14:
  ldr	s1, [x14], #4
  ldr	s2, [x13]
  subs	x12, x12, #1
  fmadd	s1, s0, s1, s2
  str	s1, [x13], #4
  b.ne	.LBB0_14
.LBB0_15:
  lsl	x13, x3, #3
  cmp	x3, x10
  ldr	s0, [x11, x13]
  b.hs	.LBB0_17
  mov	x12, xzr
  b	.LBB0_20
.LBB0_17:
  neg	x12, x10
  mov	z1.s, s0
  ptrue	p0.s
  and	x12, x3, x12
  add	x13, x2, x13
  mov	x14, x9
  mov	x15, x12
  .p2align 4
.LBB0_18:
  ldr	z2, [x14]
  ldr	z3, [x13]
  dech	x15
  ldr	z4, [x14, #1, mul vl]
  ldr	z5, [x13, #1, mul vl]
  incb	x14, all, mul #2
  fmad	z2.s, p0/m, z1.s, z3.s
  fmad	z4.s, p0/m, z1.s, z5.s
  str	z2, [x13]
  str	z4, [x13, #1, mul vl]
  incb	x13, all, mul #2
  cbnz	x15, .LBB0_18
  cmp	x3, x12
  b.eq	.LBB0_22
.LBB0_20:
  lsl	x13, x12, #2
  sub	x12, x3, x12
  add	x14, x13, x3, lsl #3
  add	x15, x13, x8, lsl #2
  add	x13, x2, x14
  add	x14, x1, x15
  .p2align 4
.LBB0_21:
  ldr	s1, [x14], #4
  ldr	s2, [x13]
  subs	x12, x12, #1
  fmadd	s1, s0, s1, s2
  str	s1, [x13], #4
  b.ne	.LBB0_21
.LBB0_22:
  add	x12, x3, x3, lsl #1
  cmp	x3, x10
  lsl	x12, x12, #2
  ldr	s0, [x11, x12]
  b.hs	.LBB0_24
  mov	x10, xzr
  b	.LBB0_27
.LBB0_24:
  neg	x10, x10
  mov	z1.s, s0
  ptrue	p0.s
  and	x10, x3, x10
  add	x11, x2, x12
  mov	x12, x10
  .p2align 4
.LBB0_25:
  ldr	z2, [x9]
  ldr	z3, [x11]
  dech	x12
  ldr	z4, [x9, #1, mul vl]
  ldr	z5, [x11, #1, mul vl]
  incb	x9, all, mul #2
  fmad	z2.s, p0/m, z1.s, z3.s
  fmad	z4.s, p0/m, z1.s, z5.s
  str	z2, [x11]
  str	z4, [x11, #1, mul vl]
  incb	x11, all, mul #2
  cbnz	x12, .LBB0_25
  cmp	x3, x10
  b.eq	.LBB0_29
.LBB0_27:
  mov	w9, #12                         // =0xc
  lsl	x11, x10, #2
  madd	x9, x3, x9, x11
  add	x11, x11, x8, lsl #2
  sub	x8, x3, x10
  add	x10, x1, x11
  add	x9, x2, x9
  .p2align 4
.LBB0_28:
  ldr	s1, [x10], #4
  ldr	s2, [x9]
  subs	x8, x8, #1
  fmadd	s1, s0, s1, s2
  str	s1, [x9], #4
  b.ne	.LBB0_28
.LBB0_29:
