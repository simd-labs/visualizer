	.file	"conv3_f32.cpp"
	.text
	.globl	_Z9conv3_f32PKfPfS0_l           // -- Begin function _Z9conv3_f32PKfPfS0_l
	.p2align	2
	.type	_Z9conv3_f32PKfPfS0_l,@function
_Z9conv3_f32PKfPfS0_l:                  // @_Z9conv3_f32PKfPfS0_l
// %bb.0:
	cmp	x3, #3
	//APP
	// LLVM-MCA-BEGIN conv3_f32
	//NO_APP
	b.lt	.LBB0_8
// %bb.1:
	ldp	s0, s1, [x2]
	sub	x10, x3, #2
	ldr	s2, [x2, #8]
	ldr	s3, [x0, #4]
	cmp	x10, #8
	b.hs	.LBB0_3
// %bb.2:
	mov	w9, #1                          // =0x1
	mov	w8, #2                          // =0x2
	b	.LBB0_7
.LBB0_3:
	dup	v3.4s, v3.s[0]
	and	x11, x10, #0xfffffffffffffff8
	add	x12, x1, #20
	orr	x8, x11, #0x2
	orr	x9, x11, #0x1
	add	x13, x0, #16
	and	x14, x10, #0xfffffffffffffff8
.LBB0_4:                                // =>This Inner Loop Header: Depth=1
	mov	v5.16b, v3.16b
	ldur	q4, [x13, #-8]
	ldur	q3, [x13, #8]
	ldp	q7, q16, [x13, #-16]
	subs	x14, x14, #8
	ext	v6.16b, v4.16b, v3.16b, #12
	add	x13, x13, #32
	ext	v5.16b, v5.16b, v4.16b, #12
	fmul	v6.4s, v6.4s, v1.s[0]
	fmul	v5.4s, v5.4s, v1.s[0]
	fmla	v6.4s, v16.4s, v0.s[0]
	fmla	v5.4s, v7.4s, v0.s[0]
	fmla	v6.4s, v3.4s, v2.s[0]
	fmla	v5.4s, v4.4s, v2.s[0]
	stp	q5, q6, [x12, #-16]
	add	x12, x12, #32
	b.ne	.LBB0_4
// %bb.5:
	cmp	x10, x11
	b.eq	.LBB0_8
// %bb.6:
	mov	s3, v3.s[3]
.LBB0_7:                                // =>This Inner Loop Header: Depth=1
	lsl	x10, x9, #2
	fmul	s3, s3, s1
	add	x9, x0, x10
	ldur	s4, [x9, #-4]
	mov	x9, x8
	fmadd	s4, s4, s0, s3
	ldr	s3, [x0, x8, lsl #2]
	add	x8, x8, #1
	cmp	x3, x8
	fmadd	s4, s3, s2, s4
	str	s4, [x1, x10]
	b.ne	.LBB0_7
.LBB0_8:
	//APP
	// LLVM-MCA-END conv3_f32
	//NO_APP
	ret
.Lfunc_end0:
	.size	_Z9conv3_f32PKfPfS0_l, .Lfunc_end0-_Z9conv3_f32PKfPfS0_l
                                        // -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
