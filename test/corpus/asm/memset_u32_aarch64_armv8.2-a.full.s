	.file	"memset_u32.cpp"
	.text
	.globl	_Z10memset_u32Pjjl              // -- Begin function _Z10memset_u32Pjjl
	.p2align	2
	.type	_Z10memset_u32Pjjl,@function
_Z10memset_u32Pjjl:                     // @_Z10memset_u32Pjjl
// %bb.0:
	cmp	x2, #1
	//APP
	// LLVM-MCA-BEGIN memset_u32
	//NO_APP
	b.lt	.LBB0_8
// %bb.1:
	cmp	x2, #8
	b.hs	.LBB0_3
// %bb.2:
	mov	x8, xzr
	b	.LBB0_6
.LBB0_3:
	dup	v0.4s, w1
	and	x8, x2, #0x7ffffffffffffff8
	add	x9, x0, #16
	and	x10, x2, #0x7ffffffffffffff8
.LBB0_4:                                // =>This Inner Loop Header: Depth=1
	subs	x10, x10, #8
	stp	q0, q0, [x9, #-16]
	add	x9, x9, #32
	b.ne	.LBB0_4
// %bb.5:
	cmp	x2, x8
	b.eq	.LBB0_8
.LBB0_6:
	add	x9, x0, x8, lsl #2
	sub	x8, x2, x8
.LBB0_7:                                // =>This Inner Loop Header: Depth=1
	subs	x8, x8, #1
	str	w1, [x9], #4
	b.ne	.LBB0_7
.LBB0_8:
	//APP
	// LLVM-MCA-END memset_u32
	//NO_APP
	ret
.Lfunc_end0:
	.size	_Z10memset_u32Pjjl, .Lfunc_end0-_Z10memset_u32Pjjl
                                        // -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
