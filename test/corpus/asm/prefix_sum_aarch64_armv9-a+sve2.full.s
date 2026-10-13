	.file	"prefix_sum.cpp"
	.text
	.globl	_Z10prefix_sumPKfPfl            // -- Begin function _Z10prefix_sumPKfPfl
	.p2align	2
	.type	_Z10prefix_sumPKfPfl,@function
_Z10prefix_sumPKfPfl:                   // @_Z10prefix_sumPKfPfl
// %bb.0:
	cmp	x2, #1
	//APP
	// LLVM-MCA-BEGIN prefix_sum
	//NO_APP
	b.lt	.LBB0_3
// %bb.1:
	movi	d0, #0000000000000000
.LBB0_2:                                // =>This Inner Loop Header: Depth=1
	ldr	s1, [x0], #4
	subs	x2, x2, #1
	fadd	s0, s0, s1
	str	s0, [x1], #4
	b.ne	.LBB0_2
.LBB0_3:
	//APP
	// LLVM-MCA-END prefix_sum
	//NO_APP
	ret
.Lfunc_end0:
	.size	_Z10prefix_sumPKfPfl, .Lfunc_end0-_Z10prefix_sumPKfPfl
                                        // -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
