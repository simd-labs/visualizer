	.file	"sqrt_f32_loop.cpp"
	.text
	.globl	_Z13sqrt_f32_loopPKfPfl         // -- Begin function _Z13sqrt_f32_loopPKfPfl
	.p2align	2
	.type	_Z13sqrt_f32_loopPKfPfl,@function
_Z13sqrt_f32_loopPKfPfl:                // @_Z13sqrt_f32_loopPKfPfl
// %bb.0:
	cmp	x2, #1
	//APP
	// LLVM-MCA-BEGIN sqrt_f32_loop
	//NO_APP
	b.lt	.LBB0_8
// %bb.1:
	cmp	x2, #4
	b.hs	.LBB0_3
// %bb.2:
	mov	x8, xzr
	b	.LBB0_6
.LBB0_3:
	movi	v0.4s, #63, lsl #24
	and	x8, x2, #0x7ffffffffffffffc
	mov	x9, x0
	mov	x10, x1
	and	x11, x2, #0x7ffffffffffffffc
.LBB0_4:                                // =>This Inner Loop Header: Depth=1
	movi	v1.4s, #63, lsl #24
	ldr	q2, [x9], #16
	subs	x11, x11, #4
	fmla	v1.4s, v1.4s, v2.4s
	fdiv	v3.4s, v2.4s, v1.4s
	fadd	v1.4s, v1.4s, v3.4s
	fmul	v1.4s, v1.4s, v0.4s
	fdiv	v3.4s, v2.4s, v1.4s
	fadd	v1.4s, v1.4s, v3.4s
	fmul	v1.4s, v1.4s, v0.4s
	fdiv	v3.4s, v2.4s, v1.4s
	fadd	v1.4s, v1.4s, v3.4s
	fmul	v1.4s, v1.4s, v0.4s
	fdiv	v2.4s, v2.4s, v1.4s
	fadd	v1.4s, v1.4s, v2.4s
	fmul	v1.4s, v1.4s, v0.4s
	str	q1, [x10], #16
	b.ne	.LBB0_4
// %bb.5:
	cmp	x2, x8
	b.eq	.LBB0_8
.LBB0_6:
	lsl	x10, x8, #2
	fmov	s0, #0.50000000
	sub	x8, x2, x8
	add	x9, x1, x10
	add	x10, x0, x10
.LBB0_7:                                // =>This Inner Loop Header: Depth=1
	ldr	s1, [x10], #4
	subs	x8, x8, #1
	fmadd	s2, s1, s0, s0
	fdiv	s3, s1, s2
	fadd	s2, s2, s3
	fmul	s2, s2, s0
	fdiv	s3, s1, s2
	fadd	s2, s2, s3
	fmul	s2, s2, s0
	fdiv	s3, s1, s2
	fadd	s2, s2, s3
	fmul	s2, s2, s0
	fdiv	s1, s1, s2
	fadd	s1, s2, s1
	fmul	s1, s1, s0
	str	s1, [x9], #4
	b.ne	.LBB0_7
.LBB0_8:
	//APP
	// LLVM-MCA-END sqrt_f32_loop
	//NO_APP
	ret
.Lfunc_end0:
	.size	_Z13sqrt_f32_loopPKfPfl, .Lfunc_end0-_Z13sqrt_f32_loopPKfPfl
                                        // -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
