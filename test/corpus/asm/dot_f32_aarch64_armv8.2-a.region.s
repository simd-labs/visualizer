  b.lt	.LBB0_8
  cmp	x2, #8
  b.hs	.LBB0_3
  mov	x8, xzr
  b	.LBB0_6
.LBB0_3:
  and	x8, x2, #0x7ffffffffffffff8
  add	x9, x1, #16
  add	x10, x0, #16
  and	x11, x2, #0x7ffffffffffffff8
  .p2align 4
.LBB0_4:
  ldp	q1, q4, [x9, #-16]
  subs	x11, x11, #8
  ldp	q2, q3, [x10, #-16]
  add	x9, x9, #32
  add	x10, x10, #32
  fmul	v1.4s, v2.4s, v1.4s
  mov	s2, v1.s[1]
  fadd	s0, s0, s1
  mov	s5, v1.s[2]
  mov	s1, v1.s[3]
  fadd	s0, s0, s2
  fmul	v2.4s, v3.4s, v4.4s
  fadd	s0, s0, s5
  mov	s3, v2.s[2]
  fadd	s0, s0, s1
  mov	s1, v2.s[1]
  fadd	s0, s0, s2
  fadd	s0, s0, s1
  mov	s1, v2.s[3]
  fadd	s0, s0, s3
  fadd	s0, s0, s1
  b.ne	.LBB0_4
  cmp	x2, x8
  b.eq	.LBB0_8
.LBB0_6:
  lsl	x10, x8, #2
  sub	x8, x2, x8
  add	x9, x1, x10
  add	x10, x0, x10
  .p2align 4
.LBB0_7:
  ldr	s1, [x10], #4
  subs	x8, x8, #1
  ldr	s2, [x9], #4
  fmadd	s0, s1, s2, s0
  b.ne	.LBB0_7
.LBB0_8:
