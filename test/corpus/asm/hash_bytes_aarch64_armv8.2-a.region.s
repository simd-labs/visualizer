  movk	x0, #40164, lsl #32
  movk	x0, #52210, lsl #48
  b.lt	.LBB0_3
  mov	x9, #435                        // =0x1b3
  movk	x9, #256, lsl #32
  .p2align 4
.LBB0_2:
  ldrb	w10, [x8], #1
  subs	x1, x1, #1
  eor	x10, x0, x10
  mul	x0, x10, x9
  b.ne	.LBB0_2
.LBB0_3:
