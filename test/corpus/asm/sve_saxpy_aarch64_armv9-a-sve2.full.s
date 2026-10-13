	.file	"sve_saxpy.cpp"
	.text
	.globl	_Z9sve_saxpyfPKfPfl             // -- Begin function _Z9sve_saxpyfPKfPfl
	.p2align	2
	.type	_Z9sve_saxpyfPKfPfl,@function
_Z9sve_saxpyfPKfPfl:                    // @_Z9sve_saxpyfPKfPfl
// %bb.0:
	cmp	x2, #1
                                        // kill: def $s0 killed $s0 def $z0
	//APP
	// LLVM-MCA-BEGIN sve_saxpy
	//NO_APP
	b.lt	.LBB0_3
// %bb.1:
	mov	z0.s, s0
	mov	x8, xzr
.LBB0_2:                                // =>This Inner Loop Header: Depth=1
	whilelo	p0.s, x8, x2
	mov	z3.d, z0.d
	ld1w	{ z1.s }, p0/z, [x0, x8, lsl #2]
	ld1w	{ z2.s }, p0/z, [x1, x8, lsl #2]
	fmad	z3.s, p0/m, z1.s, z2.s
	st1w	{ z3.s }, p0, [x1, x8, lsl #2]
	incw	x8
	cmp	x8, x2
	b.lt	.LBB0_2
.LBB0_3:
	//APP
	// LLVM-MCA-END sve_saxpy
	//NO_APP
	ret
.Lfunc_end0:
	.size	_Z9sve_saxpyfPKfPfl, .Lfunc_end0-_Z9sve_saxpyfPKfPfl
                                        // -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
