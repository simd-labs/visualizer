  b.lt	.LBB0_3
  movi	d0, #0000000000000000
  cnth	x8
  cmp	x2, x8
  b.hs	.LBB0_4
  mov	x8, xzr
  b	.LBB0_7
.LBB0_3:
  movi	d0, #0000000000000000
                                          // kill: def $s0 killed $s0 killed $z0
