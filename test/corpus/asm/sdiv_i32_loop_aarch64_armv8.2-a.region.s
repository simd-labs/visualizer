  b.lt	.LBB0_8
  cmp	x3, #4
  b.hs	.LBB0_3
  mov	x8, xzr
  b	.LBB0_6
.LBB0_3:
  and	x8, x3, #0x7ffffffffffffffc
  add	x9, x0, #8
  add	x10, x1, #8
  and	x11, x3, #0x7ffffffffffffffc
  .p2align 4
.LBB0_4:
  ldp	w12, w13, [x9, #-8]
  ldp	w14, w15, [x9], #16
  subs	x11, x11, #4
  sdiv	w12, w12, w2
  sdiv	w13, w13, w2
  sdiv	w14, w14, w2
  stp	w12, w13, [x10, #-8]
  sdiv	w15, w15, w2
  stp	w14, w15, [x10], #16
  b.ne	.LBB0_4
  cmp	x3, x8
  b.eq	.LBB0_8
.LBB0_6:
  lsl	x10, x8, #2
  sub	x8, x3, x8
  add	x9, x1, x10
  add	x10, x0, x10
  .p2align 4
.LBB0_7:
  ldr	w11, [x10], #4
  subs	x8, x8, #1
  sdiv	w11, w11, w2
  str	w11, [x9], #4
  b.ne	.LBB0_7
.LBB0_8:
