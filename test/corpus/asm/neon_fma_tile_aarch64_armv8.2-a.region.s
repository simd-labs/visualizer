  ldp	q2, q3, [x2]
  ld1r	{ v0.4s }, [x9], x10
  add	x8, x1, x8, lsl #2
  ldp	q1, q4, [x8]
  add	x8, x2, x10
  fmla	v2.4s, v0.4s, v1.4s
  fmla	v3.4s, v0.4s, v4.4s
  ldr	s0, [x9]
  stp	q2, q3, [x2]
  ldp	q2, q3, [x8]
  fmla	v2.4s, v1.4s, v0.s[0]
  fmla	v3.4s, v4.4s, v0.s[0]
  stp	q2, q3, [x8]
