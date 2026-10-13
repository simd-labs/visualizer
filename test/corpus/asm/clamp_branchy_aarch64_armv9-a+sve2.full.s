	.file	"clamp_branchy.cpp"
	.text
	.globl	_Z13clamp_branchyPKfPflff       // -- Begin function _Z13clamp_branchyPKfPflff
	.p2align	2
	.type	_Z13clamp_branchyPKfPflff,@function
_Z13clamp_branchyPKfPflff:              // @_Z13clamp_branchyPKfPflff
// %bb.0:
	cmp	x2, #1
                                        // kill: def $s1 killed $s1 def $z1
                                        // kill: def $s0 killed $s0 def $z0
	//APP
	// LLVM-MCA-BEGIN clamp_branchy
	//NO_APP
	b.lt	.LBB0_6
// %bb.1:
	cnth	x8
	cmp	x2, x8
	b.hs	.LBB0_3
// %bb.2:
	mov	x8, xzr
	b	.LBB0_7
.LBB0_3:
	neg	x8, x8
	mov	z2.s, s0
	mov	z3.s, s1
	and	x8, x2, x8
	ptrue	p0.s
	mov	x9, x0
	mov	x10, x1
	mov	x11, x8
.LBB0_4:                                // =>This Inner Loop Header: Depth=1
	ldr	z4, [x9]
	ldr	z5, [x9, #1, mul vl]
	dech	x11
	incb	x9, all, mul #2
	fcmgt	p1.s, p0/z, z4.s, z3.s
	fcmgt	p2.s, p0/z, z5.s, z3.s
	fcmgt	p3.s, p0/z, z2.s, z4.s
	fcmgt	p4.s, p0/z, z2.s, z5.s
	mov	z4.s, p1/m, z3.s
	mov	z5.s, p2/m, z3.s
	mov	z4.s, p3/m, z2.s
	mov	z5.s, p4/m, z2.s
	str	z4, [x10]
	str	z5, [x10, #1, mul vl]
	incb	x10, all, mul #2
	cbnz	x11, .LBB0_4
// %bb.5:
	cmp	x2, x8
	b.ne	.LBB0_7
.LBB0_6:
	//APP
	// LLVM-MCA-END clamp_branchy
	//NO_APP
	ret
.LBB0_7:
	lsl	x10, x8, #2
	sub	x8, x2, x8
	add	x9, x1, x10
	add	x10, x0, x10
	b	.LBB0_9
.LBB0_8:                                //   in Loop: Header=BB0_9 Depth=1
	subs	x8, x8, #1
	str	s2, [x9], #4
	b.eq	.LBB0_6
.LBB0_9:                                // =>This Inner Loop Header: Depth=1
	ldr	s3, [x10], #4
	fmov	s2, s0
	fcmp	s3, s0
	b.mi	.LBB0_8
// %bb.10:                              //   in Loop: Header=BB0_9 Depth=1
	fmov	s2, s3
	fcmp	s3, s1
	b.le	.LBB0_8
// %bb.11:                              //   in Loop: Header=BB0_9 Depth=1
	fmov	s2, s1
	b	.LBB0_8
.Lfunc_end0:
	.size	_Z13clamp_branchyPKfPflff, .Lfunc_end0-_Z13clamp_branchyPKfPflff
                                        // -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
