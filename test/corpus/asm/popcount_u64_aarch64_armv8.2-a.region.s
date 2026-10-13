  b.lt	.LBB0_8
  cmp	x2, #8
  b.hs	.LBB0_3
  mov	x8, xzr
  b	.LBB0_6
.LBB0_3:
  and	x8, x2, #0x7ffffffffffffff8
  add	x9, x1, #16
  add	x10, x0, #32
  and	x11, x2, #0x7ffffffffffffff8
  .p2align 4
.LBB0_4:
  ldp	q0, q1, [x10, #-32]
  subs	x11, x11, #8
  ldp	q2, q3, [x10], #64
  cnt	v1.16b, v1.16b
  cnt	v0.16b, v0.16b
  cnt	v3.16b, v3.16b
  cnt	v2.16b, v2.16b
  uaddlp	v1.8h, v1.16b
  uaddlp	v0.8h, v0.16b
  uaddlp	v3.8h, v3.16b
  uaddlp	v2.8h, v2.16b
  uaddlp	v1.4s, v1.8h
  uaddlp	v0.4s, v0.8h
  uaddlp	v3.4s, v3.8h
  uaddlp	v2.4s, v2.8h
  uaddlp	v1.2d, v1.4s
  uaddlp	v0.2d, v0.4s
  uaddlp	v3.2d, v3.4s
  uaddlp	v2.2d, v2.4s
  uzp1	v0.4s, v0.4s, v1.4s
  uzp1	v1.4s, v2.4s, v3.4s
  stp	q0, q1, [x9, #-16]
  add	x9, x9, #32
  b.ne	.LBB0_4
  cmp	x2, x8
  b.eq	.LBB0_8
.LBB0_6:
  add	x9, x1, x8, lsl #2
  add	x10, x0, x8, lsl #3
  sub	x8, x2, x8
  .p2align 4
.LBB0_7:
  ldr	d0, [x10], #8
  subs	x8, x8, #1
  cnt	v0.8b, v0.8b
  addv	b0, v0.8b
  st1	{ v0.s }[0], [x9], #4
  b.ne	.LBB0_7
.LBB0_8:
