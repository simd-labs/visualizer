	.file	"histogram_epi8.cpp"
	.text
	.globl	_Z14histogram_epi8PKhPjl        // -- Begin function _Z14histogram_epi8PKhPjl
	.p2align	2
	.type	_Z14histogram_epi8PKhPjl,@function
_Z14histogram_epi8PKhPjl:               // @_Z14histogram_epi8PKhPjl
// %bb.0:
	cmp	x2, #1
	//APP
	// LLVM-MCA-BEGIN histogram_epi8
	//NO_APP
	b.lt	.LBB0_2
.LBB0_1:                                // =>This Inner Loop Header: Depth=1
	ldrb	w8, [x0], #1
	subs	x2, x2, #1
	ldr	w9, [x1, x8, lsl #2]
	add	w9, w9, #1
	str	w9, [x1, x8, lsl #2]
	b.ne	.LBB0_1
.LBB0_2:
	//APP
	// LLVM-MCA-END histogram_epi8
	//NO_APP
	ret
.Lfunc_end0:
	.size	_Z14histogram_epi8PKhPjl, .Lfunc_end0-_Z14histogram_epi8PKhPjl
                                        // -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
