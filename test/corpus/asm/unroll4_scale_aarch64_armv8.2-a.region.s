  b.lt	.LBB0_3
  cmp	x8, #28
  b.hs	.LBB0_4
  mov	x8, xzr
  b	.LBB0_7
.LBB0_3:
  mov	x8, xzr
  b	.LBB0_9
.LBB0_4:
  lsr	x8, x8, #2
  add	x11, x0, #16
  add	x12, x1, #16
  add	x9, x8, #1
  and	x10, x9, #0x7ffffffffffffffe
  and	x13, x9, #0x7ffffffffffffffe
  lsl	x8, x10, #2
  .p2align 4
.LBB0_5:
  ldp	q1, q2, [x11, #-16]
  subs	x13, x13, #2
  add	x11, x11, #32
  fmul	v1.4s, v1.4s, v0.s[0]
  fmul	v2.4s, v2.4s, v0.s[0]
  stp	q1, q2, [x12, #-16]
  add	x12, x12, #32
  b.ne	.LBB0_5
  cmp	x9, x10
  b.eq	.LBB0_9
.LBB0_7:
  lsl	x10, x8, #2
  add	x9, x0, x10
  add	x10, x1, x10
  .p2align 4
.LBB0_8:
  ldr	q1, [x9], #16
  add	x11, x8, #7
  cmp	x11, x2
  add	x8, x8, #4
  fmul	v1.4s, v1.4s, v0.s[0]
  str	q1, [x10], #16
  b.lt	.LBB0_8
.LBB0_9:
  subs	x9, x2, x8
  b.le	.LBB0_16
  cmp	x9, #8
  b.lo	.LBB0_14
  lsl	x11, x8, #2
  and	x10, x9, #0xfffffffffffffff8
  and	x13, x9, #0xfffffffffffffff8
  add	x8, x8, x10
  add	x12, x11, #16
  add	x11, x1, x12
  add	x12, x0, x12
  .p2align 4
.LBB0_12:
  ldp	q1, q2, [x12, #-16]
  subs	x13, x13, #8
  add	x12, x12, #32
  fmul	v1.4s, v1.4s, v0.s[0]
  fmul	v2.4s, v2.4s, v0.s[0]
  stp	q1, q2, [x11, #-16]
  add	x11, x11, #32
  b.ne	.LBB0_12
  cmp	x9, x10
  b.eq	.LBB0_16
.LBB0_14:
  lsl	x10, x8, #2
  sub	x8, x2, x8
  add	x9, x1, x10
  add	x10, x0, x10
  .p2align 4
.LBB0_15:
  ldr	s1, [x10], #4
  subs	x8, x8, #1
  fmul	s1, s0, s1
  str	s1, [x9], #4
  b.ne	.LBB0_15
.LBB0_16:
