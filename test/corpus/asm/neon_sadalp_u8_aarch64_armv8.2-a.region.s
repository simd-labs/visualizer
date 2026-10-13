  b.lt	.LBB0_4
  movi	v0.2d, #0000000000000000
  mov	x8, xzr
  .p2align 4
.LBB0_2:
  ldr	q1, [x0, x8]
  add	x8, x8, #16
  cmp	x8, x1
  uaddlp	v1.8h, v1.16b
  uadalp	v0.4s, v1.8h
  b.lt	.LBB0_2
  addv	s0, v0.4s
