  b.lt	.LBB0_3
  cmp	x2, #4
  b.hs	.LBB0_4
  mov	x9, xzr
  mov	x8, xzr
  b	.LBB0_13
.LBB0_3:
  mov	x8, xzr
  b	.LBB0_15
.LBB0_4:
  cmp	x2, #16
  b.hs	.LBB0_6
  mov	x9, xzr
  mov	x8, xzr
  b	.LBB0_10
.LBB0_6:
  movi	v0.2d, #0000000000000000
  movi	v1.2d, #0000000000000000
  and	x10, x2, #0xc
  movi	v2.2d, #0000000000000000
  movi	v3.2d, #0000000000000000
  and	x9, x2, #0x7ffffffffffffff0
  add	x8, x0, #32
  add	x11, x1, #32
  and	x12, x2, #0x7ffffffffffffff0
  .p2align 4
.LBB0_7:
  ldp	q4, q5, [x8, #-32]
  subs	x12, x12, #16
  ldp	q6, q7, [x8], #64
  ldp	q16, q17, [x11, #-32]
  ldp	q18, q19, [x11], #64
  smlal	v0.2d, v16.2s, v4.2s
  smlal	v1.2d, v17.2s, v5.2s
  smlal	v2.2d, v18.2s, v6.2s
  smlal	v3.2d, v19.2s, v7.2s
  smlal2	v0.2d, v16.4s, v4.4s
  smlal2	v1.2d, v17.4s, v5.4s
  smlal2	v2.2d, v18.4s, v6.4s
  smlal2	v3.2d, v19.4s, v7.4s
  b.ne	.LBB0_7
  add	v0.2d, v1.2d, v0.2d
  add	v1.2d, v3.2d, v2.2d
  cmp	x2, x9
  add	v0.2d, v1.2d, v0.2d
  addp	d0, v0.2d
  fmov	x8, d0
  b.eq	.LBB0_15
  cbz	x10, .LBB0_13
.LBB0_10:
  fmov	d0, x8
  lsl	x11, x9, #2
  mov	x10, x9
  and	x9, x2, #0x7ffffffffffffffc
  sub	x8, x10, x9
  add	x10, x1, x11
  add	x11, x0, x11
  .p2align 4
.LBB0_11:
  ldr	q1, [x11], #16
  adds	x8, x8, #4
  ldr	q2, [x10], #16
  smlal	v0.2d, v2.2s, v1.2s
  smlal2	v0.2d, v2.4s, v1.4s
  b.ne	.LBB0_11
  addp	d0, v0.2d
  cmp	x2, x9
  fmov	x8, d0
  b.eq	.LBB0_15
.LBB0_13:
  lsl	x11, x9, #2
  sub	x9, x2, x9
  add	x10, x1, x11
  add	x11, x0, x11
  .p2align 4
.LBB0_14:
  ldrsw	x12, [x11], #4
  subs	x9, x9, #1
  ldrsw	x13, [x10], #4
  smaddl	x8, w13, w12, x8
  b.ne	.LBB0_14
.LBB0_15:
  mov	x0, x8
