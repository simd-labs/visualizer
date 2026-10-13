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
  ldp	q0, q1, [x10, #-16]
  subs	x11, x11, #8
  add	x10, x10, #32
  stp	q0, q1, [x9, #-16]
  add	x9, x9, #32
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
  ldr	s0, [x10], #4
  subs	x8, x8, #1
  str	s0, [x9], #4
  b.ne	.LBB0_7
.LBB0_8:
