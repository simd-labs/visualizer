  b.lt	.LBB0_3
  mov	x8, xzr
  .p2align 4
.LBB0_2:
  ld3	{ v0.8b, v1.8b, v2.8b }, [x0], #24
  add	x9, x8, #16
  cmp	x9, x4
  str	d0, [x1, x8]
  str	d1, [x2, x8]
  str	d2, [x3, x8]
  add	x8, x8, #8
  b.le	.LBB0_2
.LBB0_3:
