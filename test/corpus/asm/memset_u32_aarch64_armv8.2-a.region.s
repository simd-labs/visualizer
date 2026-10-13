  b.lt	.LBB0_8
  cmp	x2, #8
  b.hs	.LBB0_3
  mov	x8, xzr
  b	.LBB0_6
.LBB0_3:
  dup	v0.4s, w1
  and	x8, x2, #0x7ffffffffffffff8
  add	x9, x0, #16
  and	x10, x2, #0x7ffffffffffffff8
  .p2align 4
.LBB0_4:
  subs	x10, x10, #8
  stp	q0, q0, [x9, #-16]
  add	x9, x9, #32
  b.ne	.LBB0_4
  cmp	x2, x8
  b.eq	.LBB0_8
.LBB0_6:
  add	x9, x0, x8, lsl #2
  sub	x8, x2, x8
  .p2align 4
.LBB0_7:
  subs	x8, x8, #1
  str	w1, [x9], #4
  b.ne	.LBB0_7
.LBB0_8:
