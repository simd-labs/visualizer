	.file	"neon_sadalp_u8.cpp"
	.text
	.globl	_Z14neon_sadalp_u8PKhl          // -- Begin function _Z14neon_sadalp_u8PKhl
	.p2align	2
	.type	_Z14neon_sadalp_u8PKhl,@function
_Z14neon_sadalp_u8PKhl:                 // @_Z14neon_sadalp_u8PKhl
// %bb.0:
	cmp	x1, #1
	//APP
	// LLVM-MCA-BEGIN neon_sadalp_u8
	//NO_APP
	b.lt	.LBB0_4
// %bb.1:
	movi	v0.2d, #0000000000000000
	mov	x8, xzr
.LBB0_2:                                // =>This Inner Loop Header: Depth=1
	ldr	q1, [x0, x8]
	add	x8, x8, #16
	cmp	x8, x1
	uaddlp	v1.8h, v1.16b
	uadalp	v0.4s, v1.8h
	b.lt	.LBB0_2
// %bb.3:
	addv	s0, v0.4s
	//APP
	// LLVM-MCA-END neon_sadalp_u8
	//NO_APP
	fmov	w0, s0
	ret
.LBB0_4:
	mov	w0, wzr
	//APP
	// LLVM-MCA-END neon_sadalp_u8
	//NO_APP
	ret
.Lfunc_end0:
	.size	_Z14neon_sadalp_u8PKhl, .Lfunc_end0-_Z14neon_sadalp_u8PKhl
                                        // -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
