	.file	"gather_f32.cpp"
	.text
	.globl	_Z10gather_f32PKfPKiPfl         // -- Begin function _Z10gather_f32PKfPKiPfl
	.p2align	2
	.type	_Z10gather_f32PKfPKiPfl,@function
_Z10gather_f32PKfPKiPfl:                // @_Z10gather_f32PKfPKiPfl
// %bb.0:
	cmp	x3, #1
	//APP
	// LLVM-MCA-BEGIN gather_f32
	//NO_APP
	b.lt	.LBB0_8
// %bb.1:
	cmp	x3, #4
	b.hs	.LBB0_3
// %bb.2:
	mov	x8, xzr
	b	.LBB0_6
.LBB0_3:
	and	x8, x3, #0x7ffffffffffffffc
	add	x9, x1, #8
	add	x10, x2, #8
	and	x11, x3, #0x7ffffffffffffffc
.LBB0_4:                                // =>This Inner Loop Header: Depth=1
	ldpsw	x12, x13, [x9, #-8]
	subs	x11, x11, #4
	ldr	s0, [x0, x12, lsl #2]
	ldr	s1, [x0, x13, lsl #2]
	ldpsw	x12, x14, [x9], #16
	stp	s0, s1, [x10, #-8]
	ldr	s2, [x0, x12, lsl #2]
	ldr	s0, [x0, x14, lsl #2]
	stp	s2, s0, [x10], #16
	b.ne	.LBB0_4
// %bb.5:
	cmp	x3, x8
	b.eq	.LBB0_8
.LBB0_6:
	lsl	x10, x8, #2
	sub	x8, x3, x8
	add	x9, x2, x10
	add	x10, x1, x10
.LBB0_7:                                // =>This Inner Loop Header: Depth=1
	ldrsw	x11, [x10], #4
	subs	x8, x8, #1
	ldr	s0, [x0, x11, lsl #2]
	str	s0, [x9], #4
	b.ne	.LBB0_7
.LBB0_8:
	//APP
	// LLVM-MCA-END gather_f32
	//NO_APP
	ret
.Lfunc_end0:
	.size	_Z10gather_f32PKfPKiPfl, .Lfunc_end0-_Z10gather_f32PKfPKiPfl
                                        // -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
