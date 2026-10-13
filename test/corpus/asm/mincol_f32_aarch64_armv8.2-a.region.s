  b.lt	.LBB0_5
  lsl	x9, x3, #2
  mov	x8, xzr
  mov	x10, x0
  b	.LBB0_3
.LBB0_2:
  str	s0, [x1, x8, lsl #2]
  add	x8, x8, #1
  add	x10, x10, #4
  cmp	x8, x3
  b.eq	.LBB0_5
  .p2align 4
.LBB0_3:
                                          //     Child Loop BB0_4 Depth 2
  ldr	s0, [x0, x8, lsl #2]
  cmp	x2, #1
  mov	x11, x10
  mov	x12, x2
  b.lt	.LBB0_2
  .p2align 4
.LBB0_4:
                                          // =>  This Inner Loop Header: Depth=2
  ldr	s1, [x11]
  add	x11, x11, x9
  fcmp	s0, s1
  fcsel	s0, s0, s1, mi
  subs	x12, x12, #1
  b.ne	.LBB0_4
  b	.LBB0_2
.LBB0_5:
