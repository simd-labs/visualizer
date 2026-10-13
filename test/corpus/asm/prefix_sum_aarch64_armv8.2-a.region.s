  b.lt	.LBB0_3
  movi	d0, #0000000000000000
  .p2align 4
.LBB0_2:
  ldr	s1, [x0], #4
  subs	x2, x2, #1
  fadd	s0, s0, s1
  str	s0, [x1], #4
  b.ne	.LBB0_2
.LBB0_3:
