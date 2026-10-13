	.file	"neon_fma_tile.cpp"
	.text
	.globl	_Z13neon_fma_tilePKfS0_Pfll     // -- Begin function _Z13neon_fma_tilePKfS0_Pfll
	.p2align	2
	.type	_Z13neon_fma_tilePKfS0_Pfll,@function
_Z13neon_fma_tilePKfS0_Pfll:            // @_Z13neon_fma_tilePKfS0_Pfll
// %bb.0:
	mul	x8, x4, x3
	add	x9, x0, x4, lsl #2
	lsl	x10, x3, #2
	//APP
	// LLVM-MCA-BEGIN neon_fma_tile
	//NO_APP
	ldp	q2, q3, [x2]
	ld1r	{ v0.4s }, [x9], x10
	add	x8, x1, x8, lsl #2
	ldp	q1, q4, [x8]
	add	x8, x2, x10
	fmla	v2.4s, v0.4s, v1.4s
	fmla	v3.4s, v0.4s, v4.4s
	ldr	s0, [x9]
	stp	q2, q3, [x2]
	ldp	q2, q3, [x8]
	fmla	v2.4s, v1.4s, v0.s[0]
	fmla	v3.4s, v4.4s, v0.s[0]
	stp	q2, q3, [x8]
	//APP
	// LLVM-MCA-END neon_fma_tile
	//NO_APP
	ret
.Lfunc_end0:
	.size	_Z13neon_fma_tilePKfS0_Pfll, .Lfunc_end0-_Z13neon_fma_tilePKfS0_Pfll
                                        // -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
