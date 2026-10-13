  b.lt	.LBB0_8
  cmp	x2, #4
  b.hs	.LBB0_3
  mov	x8, xzr
  b	.LBB0_6
.LBB0_3:
  movi	v0.4s, #63, lsl #24
  and	x8, x2, #0x7ffffffffffffffc
  mov	x9, x0
  mov	x10, x1
  and	x11, x2, #0x7ffffffffffffffc
  .p2align 4
.LBB0_4:
  movi	v1.4s, #63, lsl #24
  ldr	q2, [x9], #16
  subs	x11, x11, #4
  fmla	v1.4s, v1.4s, v2.4s
  fdiv	v3.4s, v2.4s, v1.4s
  fadd	v1.4s, v1.4s, v3.4s
  fmul	v1.4s, v1.4s, v0.4s
  fdiv	v3.4s, v2.4s, v1.4s
  fadd	v1.4s, v1.4s, v3.4s
  fmul	v1.4s, v1.4s, v0.4s
  fdiv	v3.4s, v2.4s, v1.4s
  fadd	v1.4s, v1.4s, v3.4s
  fmul	v1.4s, v1.4s, v0.4s
  fdiv	v2.4s, v2.4s, v1.4s
  fadd	v1.4s, v1.4s, v2.4s
  fmul	v1.4s, v1.4s, v0.4s
  str	q1, [x10], #16
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
