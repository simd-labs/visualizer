	.file	"copy_f32.cpp"
	.text
	.globl	_Z8copy_f32PKfPfl               // -- Begin function _Z8copy_f32PKfPfl
	.p2align	2
	.type	_Z8copy_f32PKfPfl,@function
_Z8copy_f32PKfPfl:                      // @_Z8copy_f32PKfPfl
// %bb.0:
	cmp	x2, #1
	//APP
	// LLVM-MCA-BEGIN copy_f32
	//NO_APP
	b.lt	.LBB0_8
// %bb.1:
	cnth	x8
	cmp	x2, x8
	b.hs	.LBB0_3
// %bb.2:
	mov	x8, xzr
	b	.LBB0_6
.LBB0_3:
	neg	x8, x8
	mov	x9, x0
	mov	x10, x1
	and	x8, x2, x8
	mov	x11, x8
.LBB0_4:                                // =>This Inner Loop Header: Depth=1
	ldr	z0, [x9]
	ldr	z1, [x9, #1, mul vl]
	dech	x11
	incb	x9, all, mul #2
	str	z0, [x10]
	str	z1, [x10, #1, mul vl]
	incb	x10, all, mul #2
	cbnz	x11, .LBB0_4
// %bb.5:
	cmp	x2, x8
	b.eq	.LBB0_8
.LBB0_6:
	lsl	x10, x8, #2
	sub	x8, x2, x8
	add	x9, x1, x10
	add	x10, x0, x10
.LBB0_7:                                // =>This Inner Loop Header: Depth=1
	ldr	s0, [x10], #4
	subs	x8, x8, #1
	str	s0, [x9], #4
	b.ne	.LBB0_7
.LBB0_8:
	//APP
	// LLVM-MCA-END copy_f32
	//NO_APP
	ret
.Lfunc_end0:
	.size	_Z8copy_f32PKfPfl, .Lfunc_end0-_Z8copy_f32PKfPfl
                                        // -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
