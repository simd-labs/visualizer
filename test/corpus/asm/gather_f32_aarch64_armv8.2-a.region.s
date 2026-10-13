  b.lt	.LBB0_8
  cmp	x3, #4
  b.hs	.LBB0_3
  mov	x8, xzr
  b	.LBB0_6
.LBB0_3:
  and	x8, x3, #0x7ffffffffffffffc
  add	x9, x1, #8
  add	x10, x2, #8
  and	x11, x3, #0x7ffffffffffffffc
  .p2align 4
.LBB0_4:
  ldpsw	x12, x13, [x9, #-8]
  subs	x11, x11, #4
  ldr	s0, [x0, x12, lsl #2]
  ldr	s1, [x0, x13, lsl #2]
  ldpsw	x12, x14, [x9], #16
  stp	s0, s1, [x10, #-8]
  ldr	s2, [x0, x12, lsl #2]
  ldr	s0, [x0, x14, lsl #2]
  stp	s2, s0, [x10], #16
  b.ne	.LBB0_4
  cmp	x3, x8
  b.eq	.LBB0_8
.LBB0_6:
  lsl	x10, x8, #2
  sub	x8, x3, x8
  add	x9, x2, x10
  add	x10, x1, x10
  .p2align 4
.LBB0_7:
  ldrsw	x11, [x10], #4
  subs	x8, x8, #1
  ldr	s0, [x0, x11, lsl #2]
  str	s0, [x9], #4
  b.ne	.LBB0_7
.LBB0_8:
