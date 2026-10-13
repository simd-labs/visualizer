  b.lt	.LBB0_3
  movi	d0, #0000000000000000
  cntw	x8
  cmp	x2, x8
  b.hs	.LBB0_4
  mov	x8, xzr
  b	.LBB0_7
.LBB0_3:
  movi	d0, #0000000000000000
                                          // kill: def $d0 killed $d0 killed $z0
