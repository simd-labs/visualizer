	.file	"dot_f64.cpp"
	.text
	.globl	_Z7dot_f64PKdS0_l               // -- Begin function _Z7dot_f64PKdS0_l
	.p2align	2
	.type	_Z7dot_f64PKdS0_l,@function
_Z7dot_f64PKdS0_l:                      // @_Z7dot_f64PKdS0_l
// %bb.0:
	cmp	x2, #1
	//APP
	// LLVM-MCA-BEGIN dot_f64
	//NO_APP
	b.lt	.LBB0_3
// %bb.1:
	movi	d0, #0000000000000000
	cntw	x8
	cmp	x2, x8
	b.hs	.LBB0_4
// %bb.2:
	mov	x8, xzr
	b	.LBB0_7
.LBB0_3:
	movi	d0, #0000000000000000
                                        // kill: def $d0 killed $d0 killed $z0
	//APP
	// LLVM-MCA-END dot_f64
	//NO_APP
	ret
.LBB0_4:
	neg	x8, x8
	ptrue	p0.d
	mov	x9, x0
	and	x8, x2, x8
	mov	x10, x1
	mov	x11, x8
.LBB0_5:                                // =>This Inner Loop Header: Depth=1
	ldr	z1, [x9]
	ldr	z2, [x10]
	decw	x11
	fmul	z1.d, z1.d, z2.d
	ldr	z2, [x10, #1, mul vl]
	incb	x10, all, mul #2
	fadda	d0, p0, d0, z1.d
	ldr	z1, [x9, #1, mul vl]
	incb	x9, all, mul #2
	fmul	z1.d, z1.d, z2.d
	fadda	d0, p0, d0, z1.d
	cbnz	x11, .LBB0_5
// %bb.6:
	cmp	x2, x8
	b.eq	.LBB0_9
.LBB0_7:
	lsl	x10, x8, #3
	sub	x8, x2, x8
	add	x9, x1, x10
	add	x10, x0, x10
.LBB0_8:                                // =>This Inner Loop Header: Depth=1
	ldr	d1, [x10], #8
	subs	x8, x8, #1
	ldr	d2, [x9], #8
	fmadd	d0, d1, d2, d0
	b.ne	.LBB0_8
.LBB0_9:
                                        // kill: def $d0 killed $d0 killed $z0
	//APP
	// LLVM-MCA-END dot_f64
	//NO_APP
	ret
.Lfunc_end0:
	.size	_Z7dot_f64PKdS0_l, .Lfunc_end0-_Z7dot_f64PKdS0_l
                                        // -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
