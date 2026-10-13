	.file	"sve_gather_i32.cpp"
	.text
	.globl	_Z14sve_gather_i32PKiS0_Pil     // -- Begin function _Z14sve_gather_i32PKiS0_Pil
	.p2align	2
	.type	_Z14sve_gather_i32PKiS0_Pil,@function
_Z14sve_gather_i32PKiS0_Pil:            // @_Z14sve_gather_i32PKiS0_Pil
// %bb.0:
	cmp	x3, #1
	//APP
	// LLVM-MCA-BEGIN sve_gather_i32
	//NO_APP
	b.lt	.LBB0_3
// %bb.1:
	mov	x8, xzr
.LBB0_2:                                // =>This Inner Loop Header: Depth=1
	whilelo	p0.s, x8, x3
	ld1w	{ z0.s }, p0/z, [x1, x8, lsl #2]
	ld1w	{ z0.s }, p0/z, [x0, z0.s, sxtw #2]
	st1w	{ z0.s }, p0, [x2, x8, lsl #2]
	incw	x8
	cmp	x8, x3
	b.lt	.LBB0_2
.LBB0_3:
	//APP
	// LLVM-MCA-END sve_gather_i32
	//NO_APP
	ret
.Lfunc_end0:
	.size	_Z14sve_gather_i32PKiS0_Pil, .Lfunc_end0-_Z14sve_gather_i32PKiS0_Pil
                                        // -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
