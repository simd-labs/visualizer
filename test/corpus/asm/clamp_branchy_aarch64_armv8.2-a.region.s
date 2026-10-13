  b.lt	.LBB0_6
  cmp	x2, #8
  b.hs	.LBB0_3
  mov	x8, xzr
  b	.LBB0_7
.LBB0_3:
  dup	v2.4s, v0.s[0]
  dup	v3.4s, v1.s[0]
  and	x8, x2, #0x7ffffffffffffff8
  add	x9, x1, #16
  add	x10, x0, #16
  and	x11, x2, #0x7ffffffffffffff8
  .p2align 4
.LBB0_4:
  ldp	q4, q5, [x10, #-16]
  subs	x11, x11, #8
  add	x10, x10, #32
  fcmgt	v6.4s, v4.4s, v3.4s
  fcmgt	v7.4s, v5.4s, v3.4s
  fcmgt	v16.4s, v2.4s, v4.4s
  bit	v4.16b, v3.16b, v6.16b
  fcmgt	v6.4s, v2.4s, v5.4s
  bit	v5.16b, v3.16b, v7.16b
  bit	v4.16b, v2.16b, v16.16b
  bit	v5.16b, v2.16b, v6.16b
  stp	q4, q5, [x9, #-16]
  add	x9, x9, #32
  b.ne	.LBB0_4
  cmp	x2, x8
  b.ne	.LBB0_7
.LBB0_6:
