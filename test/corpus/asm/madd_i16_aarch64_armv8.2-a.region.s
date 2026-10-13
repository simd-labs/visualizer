  b.lt	.LBB0_14
  cmp	x3, #7
  b.hs	.LBB0_3
  mov	x8, xzr
  b	.LBB0_12
.LBB0_3:
  lsr	x8, x8, #1
  cmp	x3, #31
  add	x9, x8, #1
  b.hs	.LBB0_5
  mov	x10, xzr
  b	.LBB0_9
.LBB0_5:
  and	x10, x9, #0xfffffffffffffff0
  and	x11, x9, #0xc
  add	x12, x2, #32
  lsl	x8, x10, #1
  add	x13, x0, #32
  add	x14, x1, #32
  and	x15, x9, #0xfffffffffffffff0
  .p2align 4
.LBB0_6:
  sub	x16, x13, #32
  sub	x17, x14, #32
  ld2	{ v0.8h, v1.8h }, [x13]
  subs	x15, x15, #16
  add	x13, x13, #64
  ld2	{ v2.8h, v3.8h }, [x14]
  add	x14, x14, #64
  ld2	{ v4.8h, v5.8h }, [x16]
  ld2	{ v6.8h, v7.8h }, [x17]
  smull2	v16.4s, v3.8h, v1.8h
  smull	v17.4s, v3.4h, v1.4h
  smull2	v18.4s, v7.8h, v5.8h
  smull	v19.4s, v7.4h, v5.4h
  smlal2	v16.4s, v2.8h, v0.8h
  smlal	v17.4s, v2.4h, v0.4h
  smlal2	v18.4s, v6.8h, v4.8h
  smlal	v19.4s, v6.4h, v4.4h
  stp	q17, q16, [x12]
  stp	q19, q18, [x12, #-32]
  add	x12, x12, #64
  b.ne	.LBB0_6
  cmp	x9, x10
  b.eq	.LBB0_14
  cbz	x11, .LBB0_12
.LBB0_9:
  and	x11, x9, #0xfffffffffffffffc
  lsl	x13, x10, #2
  lsl	x8, x11, #1
  add	x12, x1, x13
  add	x13, x0, x13
  .p2align 4
.LBB0_10:
  ld2	{ v0.4h, v1.4h }, [x13], #16
  and	x14, x10, #0x3ffffffffffffffc
  ld2	{ v2.4h, v3.4h }, [x12], #16
  lsl	x14, x14, #2
  add	x10, x10, #4
  cmp	x11, x10
  smull	v4.4s, v3.4h, v1.4h
  smlal	v4.4s, v2.4h, v0.4h
  str	q4, [x2, x14]
  b.ne	.LBB0_10
  cmp	x9, x11
  b.eq	.LBB0_14
.LBB0_12:
  lsl	x9, x8, #1
  and	x10, x9, #0xfffffffffffffffc
  add	x11, x9, #2
  add	x9, x2, x10
  add	x10, x1, x11
  add	x11, x0, x11
  .p2align 4
.LBB0_13:
  ldursh	w12, [x11, #-2]
  ldursh	w13, [x10, #-2]
  add	x8, x8, #2
  ldrsh	w14, [x11]
  ldrsh	w15, [x10]
  cmp	x8, x3
  mul	w12, w13, w12
  add	x10, x10, #4
  add	x11, x11, #4
  madd	w12, w15, w14, w12
  str	w12, [x9], #4
  b.lt	.LBB0_13
.LBB0_14:
