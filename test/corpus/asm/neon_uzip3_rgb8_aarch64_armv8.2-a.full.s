	.file	"neon_uzip3_rgb8.cpp"
	.text
	.globl	_Z15neon_uzip3_rgb8PKhPhS1_S1_l // -- Begin function _Z15neon_uzip3_rgb8PKhPhS1_S1_l
	.p2align	2
	.type	_Z15neon_uzip3_rgb8PKhPhS1_S1_l,@function
_Z15neon_uzip3_rgb8PKhPhS1_S1_l:        // @_Z15neon_uzip3_rgb8PKhPhS1_S1_l
// %bb.0:
	cmp	x4, #8
	//APP
	// LLVM-MCA-BEGIN neon_uzip3_rgb8
	//NO_APP
	b.lt	.LBB0_3
// %bb.1:
	mov	x8, xzr
.LBB0_2:                                // =>This Inner Loop Header: Depth=1
	ld3	{ v0.8b, v1.8b, v2.8b }, [x0], #24
	add	x9, x8, #16
	cmp	x9, x4
	str	d0, [x1, x8]
	str	d1, [x2, x8]
	str	d2, [x3, x8]
	add	x8, x8, #8
	b.le	.LBB0_2
.LBB0_3:
	//APP
	// LLVM-MCA-END neon_uzip3_rgb8
	//NO_APP
	ret
.Lfunc_end0:
	.size	_Z15neon_uzip3_rgb8PKhPhS1_S1_l, .Lfunc_end0-_Z15neon_uzip3_rgb8PKhPhS1_S1_l
                                        // -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
