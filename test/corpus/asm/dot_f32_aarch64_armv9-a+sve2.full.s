	.file	"dot_f32.cpp"
	.text
	.globl	_Z7dot_f32PKfS0_l               // -- Begin function _Z7dot_f32PKfS0_l
	.p2align	2
	.type	_Z7dot_f32PKfS0_l,@function
_Z7dot_f32PKfS0_l:                      // @_Z7dot_f32PKfS0_l
// %bb.0:
	cmp	x2, #1
	//APP
	// LLVM-MCA-BEGIN dot_f32
	//NO_APP
	b.lt	.LBB0_3
// %bb.1:
	movi	d0, #0000000000000000
	cnth	x8
	cmp	x2, x8
	b.hs	.LBB0_4
// %bb.2:
	mov	x8, xzr
	b	.LBB0_7
.LBB0_3:
	movi	d0, #0000000000000000
                                        // kill: def $s0 killed $s0 killed $z0
	//APP
	// LLVM-MCA-END dot_f32
	//NO_APP
	ret
.LBB0_4:
	neg	x8, x8
	ptrue	p0.s
	mov	x9, x0
	and	x8, x2, x8
	mov	x10, x1
	mov	x11, x8
.LBB0_5:                                // =>This Inner Loop Header: Depth=1
	ldr	z1, [x9]
	ldr	z2, [x10]
	dech	x11
	fmul	z1.s, z1.s, z2.s
	ldr	z2, [x10, #1, mul vl]
	incb	x10, all, mul #2
	fadda	s0, p0, s0, z1.s
	ldr	z1, [x9, #1, mul vl]
	incb	x9, all, mul #2
	fmul	z1.s, z1.s, z2.s
	fadda	s0, p0, s0, z1.s
	cbnz	x11, .LBB0_5
// %bb.6:
	cmp	x2, x8
	b.eq	.LBB0_9
.LBB0_7:
	lsl	x10, x8, #2
	sub	x8, x2, x8
	add	x9, x1, x10
	add	x10, x0, x10
.LBB0_8:                                // =>This Inner Loop Header: Depth=1
	ldr	s1, [x10], #4
	subs	x8, x8, #1
	ldr	s2, [x9], #4
	fmadd	s0, s1, s2, s0
	b.ne	.LBB0_8
.LBB0_9:
                                        // kill: def $s0 killed $s0 killed $z0
	//APP
	// LLVM-MCA-END dot_f32
	//NO_APP
	ret
.Lfunc_end0:
	.size	_Z7dot_f32PKfS0_l, .Lfunc_end0-_Z7dot_f32PKfS0_l
                                        // -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
