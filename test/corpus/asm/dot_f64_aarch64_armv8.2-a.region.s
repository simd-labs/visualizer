  b.lt	.LBB0_8
  cmp	x2, #4
  b.hs	.LBB0_3
  mov	x8, xzr
  b	.LBB0_6
.LBB0_3:
  and	x8, x2, #0x7ffffffffffffffc
  add	x9, x1, #16
  add	x10, x0, #16
  and	x11, x2, #0x7ffffffffffffffc
  .p2align 4
.LBB0_4:
  ldp	q1, q4, [x9, #-16]
  subs	x11, x11, #4
  ldp	q2, q3, [x10, #-16]
  add	x9, x9, #32
  add	x10, x10, #32
  fmul	v1.2d, v2.2d, v1.2d
  mov	d2, v1.d[1]
  fadd	d0, d0, d1
  fmul	v1.2d, v3.2d, v4.2d
  fadd	d0, d0, d2
  mov	d2, v1.d[1]
  fadd	d0, d0, d1
  fadd	d0, d0, d2
  b.ne	.LBB0_4
  cmp	x2, x8
  b.eq	.LBB0_8
.LBB0_6:
  lsl	x10, x8, #3
  sub	x8, x2, x8
  add	x9, x1, x10
  add	x10, x0, x10
  .p2align 4
.LBB0_7:
  ldr	d1, [x10], #8
  subs	x8, x8, #1
  ldr	d2, [x9], #8
  fmadd	d0, d1, d2, d0
  b.ne	.LBB0_7
.LBB0_8:
