	.file	"matmul_inner.cpp"
	.text
	.globl	_Z12matmul_innerPKfS0_Pfll      // -- Begin function _Z12matmul_innerPKfS0_Pfll
	.p2align	2
	.type	_Z12matmul_innerPKfS0_Pfll,@function
_Z12matmul_innerPKfS0_Pfll:             // @_Z12matmul_innerPKfS0_Pfll
// %bb.0:
	cmp	x3, #1
	//APP
	// LLVM-MCA-BEGIN matmul_inner
	//NO_APP
	b.lt	.LBB0_29
// %bb.1:
	mul	x8, x4, x3
	add	x11, x0, x4, lsl #2
	cnth	x10
	cmp	x3, x10
	ldr	s0, [x11]
	add	x9, x1, x8, lsl #2
	b.hs	.LBB0_3
// %bb.2:
	mov	x12, xzr
	b	.LBB0_6
.LBB0_3:
	neg	x12, x10
	mov	z1.s, s0
	ptrue	p0.s
	and	x12, x3, x12
	mov	x13, x9
	mov	x14, x2
	mov	x15, x12
.LBB0_4:                                // =>This Inner Loop Header: Depth=1
	ldr	z2, [x13]
	ldr	z3, [x14]
	dech	x15
	ldr	z4, [x13, #1, mul vl]
	ldr	z5, [x14, #1, mul vl]
	incb	x13, all, mul #2
	fmad	z2.s, p0/m, z1.s, z3.s
	fmad	z4.s, p0/m, z1.s, z5.s
	str	z2, [x14]
	str	z4, [x14, #1, mul vl]
	incb	x14, all, mul #2
	cbnz	x15, .LBB0_4
// %bb.5:
	cmp	x3, x12
	b.eq	.LBB0_8
.LBB0_6:
	lsl	x14, x12, #2
	sub	x12, x3, x12
	add	x13, x14, x8, lsl #2
	add	x14, x2, x14
	add	x13, x1, x13
.LBB0_7:                                // =>This Inner Loop Header: Depth=1
	ldr	s1, [x13], #4
	ldr	s2, [x14]
	subs	x12, x12, #1
	fmadd	s1, s0, s1, s2
	str	s1, [x14], #4
	b.ne	.LBB0_7
.LBB0_8:
	lsl	x13, x3, #2
	cmp	x3, x10
	ldr	s0, [x11, x13]
	b.hs	.LBB0_10
// %bb.9:
	mov	x12, xzr
	b	.LBB0_13
.LBB0_10:
	neg	x12, x10
	mov	z1.s, s0
	ptrue	p0.s
	and	x12, x3, x12
	add	x13, x2, x13
	mov	x14, x9
	mov	x15, x12
.LBB0_11:                               // =>This Inner Loop Header: Depth=1
	ldr	z2, [x14]
	ldr	z3, [x13]
	dech	x15
	ldr	z4, [x14, #1, mul vl]
	ldr	z5, [x13, #1, mul vl]
	incb	x14, all, mul #2
	fmad	z2.s, p0/m, z1.s, z3.s
	fmad	z4.s, p0/m, z1.s, z5.s
	str	z2, [x13]
	str	z4, [x13, #1, mul vl]
	incb	x13, all, mul #2
	cbnz	x15, .LBB0_11
// %bb.12:
	cmp	x3, x12
	b.eq	.LBB0_15
.LBB0_13:
	lsl	x13, x12, #2
	sub	x12, x3, x12
	add	x14, x13, x3, lsl #2
	add	x15, x13, x8, lsl #2
	add	x13, x2, x14
	add	x14, x1, x15
.LBB0_14:                               // =>This Inner Loop Header: Depth=1
	ldr	s1, [x14], #4
	ldr	s2, [x13]
	subs	x12, x12, #1
	fmadd	s1, s0, s1, s2
	str	s1, [x13], #4
	b.ne	.LBB0_14
.LBB0_15:
	lsl	x13, x3, #3
	cmp	x3, x10
	ldr	s0, [x11, x13]
	b.hs	.LBB0_17
// %bb.16:
	mov	x12, xzr
	b	.LBB0_20
.LBB0_17:
	neg	x12, x10
	mov	z1.s, s0
	ptrue	p0.s
	and	x12, x3, x12
	add	x13, x2, x13
	mov	x14, x9
	mov	x15, x12
.LBB0_18:                               // =>This Inner Loop Header: Depth=1
	ldr	z2, [x14]
	ldr	z3, [x13]
	dech	x15
	ldr	z4, [x14, #1, mul vl]
	ldr	z5, [x13, #1, mul vl]
	incb	x14, all, mul #2
	fmad	z2.s, p0/m, z1.s, z3.s
	fmad	z4.s, p0/m, z1.s, z5.s
	str	z2, [x13]
	str	z4, [x13, #1, mul vl]
	incb	x13, all, mul #2
	cbnz	x15, .LBB0_18
// %bb.19:
	cmp	x3, x12
	b.eq	.LBB0_22
.LBB0_20:
	lsl	x13, x12, #2
	sub	x12, x3, x12
	add	x14, x13, x3, lsl #3
	add	x15, x13, x8, lsl #2
	add	x13, x2, x14
	add	x14, x1, x15
.LBB0_21:                               // =>This Inner Loop Header: Depth=1
	ldr	s1, [x14], #4
	ldr	s2, [x13]
	subs	x12, x12, #1
	fmadd	s1, s0, s1, s2
	str	s1, [x13], #4
	b.ne	.LBB0_21
.LBB0_22:
	add	x12, x3, x3, lsl #1
	cmp	x3, x10
	lsl	x12, x12, #2
	ldr	s0, [x11, x12]
	b.hs	.LBB0_24
// %bb.23:
	mov	x10, xzr
	b	.LBB0_27
.LBB0_24:
	neg	x10, x10
	mov	z1.s, s0
	ptrue	p0.s
	and	x10, x3, x10
	add	x11, x2, x12
	mov	x12, x10
.LBB0_25:                               // =>This Inner Loop Header: Depth=1
	ldr	z2, [x9]
	ldr	z3, [x11]
	dech	x12
	ldr	z4, [x9, #1, mul vl]
	ldr	z5, [x11, #1, mul vl]
	incb	x9, all, mul #2
	fmad	z2.s, p0/m, z1.s, z3.s
	fmad	z4.s, p0/m, z1.s, z5.s
	str	z2, [x11]
	str	z4, [x11, #1, mul vl]
	incb	x11, all, mul #2
	cbnz	x12, .LBB0_25
// %bb.26:
	cmp	x3, x10
	b.eq	.LBB0_29
.LBB0_27:
	mov	w9, #12                         // =0xc
	lsl	x11, x10, #2
	madd	x9, x3, x9, x11
	add	x11, x11, x8, lsl #2
	sub	x8, x3, x10
	add	x10, x1, x11
	add	x9, x2, x9
.LBB0_28:                               // =>This Inner Loop Header: Depth=1
	ldr	s1, [x10], #4
	ldr	s2, [x9]
	subs	x8, x8, #1
	fmadd	s1, s0, s1, s2
	str	s1, [x9], #4
	b.ne	.LBB0_28
.LBB0_29:
	//APP
	// LLVM-MCA-END matmul_inner
	//NO_APP
	ret
.Lfunc_end0:
	.size	_Z12matmul_innerPKfS0_Pfll, .Lfunc_end0-_Z12matmul_innerPKfS0_Pfll
                                        // -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
