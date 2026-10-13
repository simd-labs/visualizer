  b.lt	.LBB0_4
  fmov	s1, #1.00000000
  fmov	s0, #1.00000000
  .p2align 4
.LBB0_2:
  ldr	s2, [x0], #4
  subs	x1, x1, #1
  fmul	s3, s0, s2
  fmadd	s0, s0, s2, s1
  fmul	s0, s3, s0
  b.ne	.LBB0_2
