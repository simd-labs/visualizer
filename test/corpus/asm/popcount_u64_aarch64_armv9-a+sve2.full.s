	.file	"popcount_u64.cpp"
	.text
	.globl	_Z12popcount_u64PKmPjl          // -- Begin function _Z12popcount_u64PKmPjl
	.p2align	2
	.type	_Z12popcount_u64PKmPjl,@function
_Z12popcount_u64PKmPjl:                 // @_Z12popcount_u64PKmPjl
// %bb.0:
	cmp	x2, #1
	//APP
	// LLVM-MCA-BEGIN popcount_u64
	//NO_APP
	b.lt	.LBB0_8
// %bb.1:
	cnth	x8
	cmp	x2, x8
	b.hs	.LBB0_3
// %bb.2:
	mov	x8, xzr
	b	.LBB0_6
.LBB0_3:
	neg	x8, x8
	ptrue	p0.d
	mov	x9, x0
	and	x8, x2, x8
	mov	x10, x1
	mov	x11, x8
.LBB0_4:                                // =>This Inner Loop Header: Depth=1
	ldr	z0, [x9]
	ldr	z1, [x9, #1, mul vl]
	dech	x11
	ldr	z2, [x9, #2, mul vl]
	ldr	z3, [x9, #3, mul vl]
	incb	x9, all, mul #4
	cnt	z1.d, p0/m, z1.d
	cnt	z0.d, p0/m, z0.d
	cnt	z3.d, p0/m, z3.d
	cnt	z2.d, p0/m, z2.d
	uzp1	z0.s, z0.s, z1.s
	uzp1	z1.s, z2.s, z3.s
	str	z0, [x10]
	str	z1, [x10, #1, mul vl]
	incb	x10, all, mul #2
	cbnz	x11, .LBB0_4
// %bb.5:
	cmp	x2, x8
	b.eq	.LBB0_8
.LBB0_6:
	add	x9, x1, x8, lsl #2
	add	x10, x0, x8, lsl #3
	ptrue	p0.d
	sub	x8, x2, x8
.LBB0_7:                                // =>This Inner Loop Header: Depth=1
	ldr	x11, [x10], #8
	subs	x8, x8, #1
	fmov	d0, x11
	cnt	z0.d, p0/m, z0.d
	fmov	x11, d0
	str	w11, [x9], #4
	b.ne	.LBB0_7
.LBB0_8:
	//APP
	// LLVM-MCA-END popcount_u64
	//NO_APP
	ret
.Lfunc_end0:
	.size	_Z12popcount_u64PKmPjl, .Lfunc_end0-_Z12popcount_u64PKmPjl
                                        // -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
