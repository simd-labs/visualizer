	.file	"chained_reduction.cpp"
	.text
	.globl	_Z17chained_reductionPKfl       // -- Begin function _Z17chained_reductionPKfl
	.p2align	2
	.type	_Z17chained_reductionPKfl,@function
_Z17chained_reductionPKfl:              // @_Z17chained_reductionPKfl
// %bb.0:
	cmp	x1, #1
	//APP
	// LLVM-MCA-BEGIN chained_reduction
	//NO_APP
	b.lt	.LBB0_4
// %bb.1:
	fmov	s1, #1.00000000
	fmov	s0, #1.00000000
.LBB0_2:                                // =>This Inner Loop Header: Depth=1
	ldr	s2, [x0], #4
	subs	x1, x1, #1
	fmul	s3, s0, s2
	fmadd	s0, s0, s2, s1
	fmul	s0, s3, s0
	b.ne	.LBB0_2
// %bb.3:
	//APP
	// LLVM-MCA-END chained_reduction
	//NO_APP
	ret
.LBB0_4:
	fmov	s0, #1.00000000
	//APP
	// LLVM-MCA-END chained_reduction
	//NO_APP
	ret
.Lfunc_end0:
	.size	_Z17chained_reductionPKfl, .Lfunc_end0-_Z17chained_reductionPKfl
                                        // -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
