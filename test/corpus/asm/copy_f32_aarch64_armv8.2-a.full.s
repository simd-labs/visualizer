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
	ldp	q0, q1, [x10, #-16]
	subs	x11, x11, #8
	add	x10, x10, #32
	stp	q0, q1, [x9, #-16]
	add	x9, x9, #32
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
