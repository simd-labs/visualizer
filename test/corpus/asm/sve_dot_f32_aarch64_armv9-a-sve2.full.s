	.file	"sve_dot_f32.cpp"
	.text
	.globl	_Z11sve_dot_f32PKfS0_l          // -- Begin function _Z11sve_dot_f32PKfS0_l
	.p2align	2
	.type	_Z11sve_dot_f32PKfS0_l,@function
_Z11sve_dot_f32PKfS0_l:                 // @_Z11sve_dot_f32PKfS0_l
// %bb.0:
	movi	v0.2d, #0000000000000000
	cmp	x2, #1
	//APP
	// LLVM-MCA-BEGIN sve_dot_f32
	//NO_APP
	b.lt	.LBB0_3
// %bb.1:
	mov	x8, xzr
.LBB0_2:                                // =>This Inner Loop Header: Depth=1
	whilelo	p0.s, x8, x2
	ld1w	{ z1.s }, p0/z, [x0, x8, lsl #2]
	ld1w	{ z2.s }, p0/z, [x1, x8, lsl #2]
	incw	x8
	fmla	z0.s, p0/m, z1.s, z2.s
	cmp	x8, x2
	b.lt	.LBB0_2
.LBB0_3:
	ptrue	p0.s
	//APP
	// LLVM-MCA-END sve_dot_f32
	//NO_APP
	faddv	s0, p0, z0.s
                                        // kill: def $s0 killed $s0 killed $z0
	ret
.Lfunc_end0:
	.size	_Z11sve_dot_f32PKfS0_l, .Lfunc_end0-_Z11sve_dot_f32PKfS0_l
                                        // -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
