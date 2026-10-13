	.file	"sdiv_i32_loop.cpp"
	.text
	.globl	_Z13sdiv_i32_loopPKiPiil        // -- Begin function _Z13sdiv_i32_loopPKiPiil
	.p2align	2
	.type	_Z13sdiv_i32_loopPKiPiil,@function
_Z13sdiv_i32_loopPKiPiil:               // @_Z13sdiv_i32_loopPKiPiil
// %bb.0:
	cmp	x3, #1
	//APP
	// LLVM-MCA-BEGIN sdiv_i32_loop
	//NO_APP
	b.lt	.LBB0_8
// %bb.1:
	cnth	x8
	cmp	x3, x8
	b.hs	.LBB0_3
// %bb.2:
	mov	x8, xzr
	b	.LBB0_6
.LBB0_3:
	neg	x8, x8
	mov	z0.s, w2
	ptrue	p0.s
	and	x8, x3, x8
	mov	x9, x0
	mov	x10, x1
	mov	x11, x8
.LBB0_4:                                // =>This Inner Loop Header: Depth=1
	ldr	z1, [x9]
	ldr	z2, [x9, #1, mul vl]
	dech	x11
	incb	x9, all, mul #2
	sdiv	z1.s, p0/m, z1.s, z0.s
	sdiv	z2.s, p0/m, z2.s, z0.s
	str	z1, [x10]
	str	z2, [x10, #1, mul vl]
	incb	x10, all, mul #2
	cbnz	x11, .LBB0_4
// %bb.5:
	cmp	x3, x8
	b.eq	.LBB0_8
.LBB0_6:
	lsl	x10, x8, #2
	sub	x8, x3, x8
	add	x9, x1, x10
	add	x10, x0, x10
.LBB0_7:                                // =>This Inner Loop Header: Depth=1
	ldr	w11, [x10], #4
	subs	x8, x8, #1
	sdiv	w11, w11, w2
	str	w11, [x9], #4
	b.ne	.LBB0_7
.LBB0_8:
	//APP
	// LLVM-MCA-END sdiv_i32_loop
	//NO_APP
	ret
.Lfunc_end0:
	.size	_Z13sdiv_i32_loopPKiPiil, .Lfunc_end0-_Z13sdiv_i32_loopPKiPiil
                                        // -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
