	.file	"neon_dot_f32.cpp"
	.text
	.globl	_Z12neon_dot_f32PKfS0_l         // -- Begin function _Z12neon_dot_f32PKfS0_l
	.p2align	2
	.type	_Z12neon_dot_f32PKfS0_l,@function
_Z12neon_dot_f32PKfS0_l:                // @_Z12neon_dot_f32PKfS0_l
// %bb.0:
	movi	v0.2d, #0000000000000000
	cmp	x2, #1
	//APP
	// LLVM-MCA-BEGIN neon_dot_f32
	//NO_APP
	b.lt	.LBB0_3
// %bb.1:
	mov	x8, xzr
.LBB0_2:                                // =>This Inner Loop Header: Depth=1
	ldr	q1, [x0], #16
	add	x8, x8, #4
	ldr	q2, [x1], #16
	cmp	x8, x2
	fmla	v0.4s, v2.4s, v1.4s
	b.lt	.LBB0_2
.LBB0_3:
	faddp	v0.4s, v0.4s, v0.4s
	//APP
	// LLVM-MCA-END neon_dot_f32
	//NO_APP
	faddp	s0, v0.2s
	ret
.Lfunc_end0:
	.size	_Z12neon_dot_f32PKfS0_l, .Lfunc_end0-_Z12neon_dot_f32PKfS0_l
                                        // -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
