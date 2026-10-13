  b.lt	.LBB0_4
  .p2align 4
.LBB0_1:
  ldrb	w9, [x0, x8]
  cbz	w9, .LBB0_4
  add	x8, x8, #1
  cmp	x1, x8
  b.ne	.LBB0_1
  mov	x8, x1
.LBB0_4:
