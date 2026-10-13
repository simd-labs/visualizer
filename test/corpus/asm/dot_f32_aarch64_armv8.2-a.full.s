	.file	"dot_f32.cpp"
	.text
	.globl	_Z7dot_f32PKfS0_l               // -- Begin function _Z7dot_f32PKfS0_l
	.p2align	2
	.type	_Z7dot_f32PKfS0_l,@function
_Z7dot_f32PKfS0_l:                      // @_Z7dot_f32PKfS0_l
// %bb.0:
	movi	d0, #0000000000000000
	cmp	x2, #1
	//APP
	// LLVM-MCA-BEGIN dot_f32
	//NO_APP
	b.lt	.LBB0_8
// %bb.1:
	cmp	x2, #8
	b.hs	.LBB0_3
// %bb.2:
	mov	x8, xzr
	b	.LBB0_6
.LBB0_3:
	and	x8, x2, #0x7ffffffffffffff8
	add	x9, x1, #16
	add	x10, x0, #16
	and	x11, x2, #0x7ffffffffffffff8
.LBB0_4:                                // =>This Inner Loop Header: Depth=1
	ldp	q1, q4, [x9, #-16]
	subs	x11, x11, #8
	ldp	q2, q3, [x10, #-16]
	add	x9, x9, #32
	add	x10, x10, #32
	fmul	v1.4s, v2.4s, v1.4s
	mov	s2, v1.s[1]
	fadd	s0, s0, s1
	mov	s5, v1.s[2]
	mov	s1, v1.s[3]
	fadd	s0, s0, s2
	fmul	v2.4s, v3.4s, v4.4s
	fadd	s0, s0, s5
	mov	s3, v2.s[2]
	fadd	s0, s0, s1
	mov	s1, v2.s[1]
	fadd	s0, s0, s2
	fadd	s0, s0, s1
	mov	s1, v2.s[3]
	fadd	s0, s0, s3
	fadd	s0, s0, s1
	b.ne	.LBB0_4
// %bb.5:
	cmp	x2, x8
	b.eq	.LBB0_8
.LBB0_6:
	lsl	x10, x8, #2
	sub	x8, x2, x8
	add	x9, x1, x10
	add	x10, x0, x10
.LBB0_7:                                // =>This Inner Loop Header: Depth=1
	ldr	s1, [x10], #4
	subs	x8, x8, #1
	ldr	s2, [x9], #4
	fmadd	s0, s1, s2, s0
	b.ne	.LBB0_7
.LBB0_8:
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
