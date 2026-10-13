  b.lt	.LBB0_2
  .p2align 4
.LBB0_1:
  ldrb	w8, [x0], #1
  subs	x2, x2, #1
  ldr	w9, [x1, x8, lsl #2]
  add	w9, w9, #1
  str	w9, [x1, x8, lsl #2]
  b.ne	.LBB0_1
.LBB0_2:
