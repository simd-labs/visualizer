  b.lt	.LBB0_29
  add	x8, x0, x4, lsl #2
  cmp	x3, #8
  ldr	s0, [x8]
  b.hs	.LBB0_3
  mov	x9, xzr
  b	.LBB0_6
.LBB0_3:
  mul	x9, x4, x3
  add	x10, x2, #16
  and	x12, x3, #0x7ffffffffffffff8
  add	x11, x1, x9, lsl #2
  and	x9, x3, #0x7ffffffffffffff8
  add	x11, x11, #16
  .p2align 4
.LBB0_4:
  ldp	q1, q4, [x10, #-16]
  subs	x12, x12, #8
  ldp	q2, q3, [x11, #-16]
  add	x11, x11, #32
  fmla	v1.4s, v2.4s, v0.s[0]
  fmla	v4.4s, v3.4s, v0.s[0]
  stp	q1, q4, [x10, #-16]
  add	x10, x10, #32
  b.ne	.LBB0_4
  cmp	x3, x9
  b.eq	.LBB0_8
.LBB0_6:
  mul	x10, x4, x3
  lsl	x11, x9, #2
  sub	x9, x3, x9
  add	x10, x11, x10, lsl #2
  add	x11, x2, x11
  add	x10, x1, x10
  .p2align 4
.LBB0_7:
  ldr	s1, [x10], #4
  ldr	s2, [x11]
  subs	x9, x9, #1
  fmadd	s1, s0, s1, s2
  str	s1, [x11], #4
  b.ne	.LBB0_7
.LBB0_8:
  ldr	s0, [x8, x3, lsl #2]
  cmp	x3, #8
  b.hs	.LBB0_10
  mov	x9, xzr
  b	.LBB0_13
.LBB0_10:
  mul	x9, x4, x3
  add	x10, x2, x3, lsl #2
  and	x12, x3, #0x7ffffffffffffff8
  add	x10, x10, #16
  add	x11, x1, x9, lsl #2
  and	x9, x3, #0x7ffffffffffffff8
  add	x11, x11, #16
  .p2align 4
.LBB0_11:
  ldp	q1, q4, [x10, #-16]
  subs	x12, x12, #8
  ldp	q2, q3, [x11, #-16]
  add	x11, x11, #32
  fmla	v1.4s, v2.4s, v0.s[0]
  fmla	v4.4s, v3.4s, v0.s[0]
  stp	q1, q4, [x10, #-16]
  add	x10, x10, #32
  b.ne	.LBB0_11
  cmp	x3, x9
  b.eq	.LBB0_15
.LBB0_13:
  mul	x10, x4, x3
  lsl	x11, x9, #2
  sub	x9, x3, x9
  add	x12, x11, x3, lsl #2
  add	x11, x11, x10, lsl #2
  add	x10, x2, x12
  add	x11, x1, x11
  .p2align 4
.LBB0_14:
  ldr	s1, [x11], #4
  ldr	s2, [x10]
  subs	x9, x9, #1
  fmadd	s1, s0, s1, s2
  str	s1, [x10], #4
  b.ne	.LBB0_14
.LBB0_15:
  lsl	x9, x3, #3
  cmp	x3, #8
  ldr	s0, [x8, x9]
  b.hs	.LBB0_17
  mov	x9, xzr
  b	.LBB0_20
.LBB0_17:
  mul	x9, x4, x3
  add	x10, x2, x3, lsl #3
  and	x12, x3, #0x7ffffffffffffff8
  add	x10, x10, #16
  add	x11, x1, x9, lsl #2
  and	x9, x3, #0x7ffffffffffffff8
  add	x11, x11, #16
  .p2align 4
.LBB0_18:
  ldp	q1, q4, [x10, #-16]
  subs	x12, x12, #8
  ldp	q2, q3, [x11, #-16]
  add	x11, x11, #32
  fmla	v1.4s, v2.4s, v0.s[0]
  fmla	v4.4s, v3.4s, v0.s[0]
  stp	q1, q4, [x10, #-16]
  add	x10, x10, #32
  b.ne	.LBB0_18
  cmp	x3, x9
  b.eq	.LBB0_22
.LBB0_20:
  mul	x10, x4, x3
  lsl	x11, x9, #2
  sub	x9, x3, x9
  add	x12, x11, x3, lsl #3
  add	x11, x11, x10, lsl #2
  add	x10, x2, x12
  add	x11, x1, x11
  .p2align 4
.LBB0_21:
  ldr	s1, [x11], #4
  ldr	s2, [x10]
  subs	x9, x9, #1
  fmadd	s1, s0, s1, s2
  str	s1, [x10], #4
  b.ne	.LBB0_21
.LBB0_22:
  add	x9, x3, x3, lsl #1
  cmp	x3, #8
  ldr	s0, [x8, x9, lsl #2]
  b.hs	.LBB0_24
  mov	x8, xzr
  b	.LBB0_27
.LBB0_24:
  mul	x8, x4, x3
  mov	w9, #12                         // =0xc
  and	x11, x3, #0x7ffffffffffffff8
  madd	x9, x3, x9, x2
  add	x10, x1, x8, lsl #2
  and	x8, x3, #0x7ffffffffffffff8
  add	x9, x9, #16
  add	x10, x10, #16
  .p2align 4
.LBB0_25:
  ldp	q1, q4, [x9, #-16]
  subs	x11, x11, #8
  ldp	q2, q3, [x10, #-16]
  add	x10, x10, #32
  fmla	v1.4s, v2.4s, v0.s[0]
  fmla	v4.4s, v3.4s, v0.s[0]
  stp	q1, q4, [x9, #-16]
  add	x9, x9, #32
  b.ne	.LBB0_25
  cmp	x3, x8
  b.eq	.LBB0_29
.LBB0_27:
  mul	x9, x4, x3
  mov	w10, #12                        // =0xc
  lsl	x11, x8, #2
  sub	x8, x3, x8
  madd	x10, x3, x10, x11
  add	x11, x11, x9, lsl #2
  add	x9, x2, x10
  add	x10, x1, x11
  .p2align 4
.LBB0_28:
  ldr	s1, [x10], #4
  ldr	s2, [x9]
  subs	x8, x8, #1
  fmadd	s1, s0, s1, s2
  str	s1, [x9], #4
  b.ne	.LBB0_28
.LBB0_29:
