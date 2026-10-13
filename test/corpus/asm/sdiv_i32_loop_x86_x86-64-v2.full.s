	.att_syntax
	.file	"sdiv_i32_loop.cpp"
	.text
	.globl	_Z13sdiv_i32_loopPKiPiil        # -- Begin function _Z13sdiv_i32_loopPKiPiil
	.prefalign	4, .Lfunc_end0, nop
	.type	_Z13sdiv_i32_loopPKiPiil,@function
_Z13sdiv_i32_loopPKiPiil:               # @_Z13sdiv_i32_loopPKiPiil
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN sdiv_i32_loop
	#NO_APP
	testq	%rcx, %rcx
	jle	.LBB0_5
# %bb.1:
	movl	%edx, %r8d
	cmpq	$1, %rcx
	jne	.LBB0_6
# %bb.2:
	xorl	%r9d, %r9d
	jmp	.LBB0_4
.LBB0_6:
	movabsq	$9223372036854775806, %r10      # imm = 0x7FFFFFFFFFFFFFFE
	andq	%rcx, %r10
	xorl	%r9d, %r9d
	.p2align	4
.LBB0_7:                                # =>This Inner Loop Header: Depth=1
	movl	(%rdi,%r9,4), %eax
	cltd
	idivl	%r8d
	movl	%eax, (%rsi,%r9,4)
	movl	4(%rdi,%r9,4), %eax
	cltd
	idivl	%r8d
	movl	%eax, 4(%rsi,%r9,4)
	addq	$2, %r9
	cmpq	%r9, %r10
	jne	.LBB0_7
# %bb.3:
	testb	$1, %cl
	je	.LBB0_5
.LBB0_4:
	movl	(%rdi,%r9,4), %eax
	cltd
	idivl	%r8d
	movl	%eax, (%rsi,%r9,4)
.LBB0_5:
	#APP
	# LLVM-MCA-END sdiv_i32_loop
	#NO_APP
	retq
.Lfunc_end0:
	.size	_Z13sdiv_i32_loopPKiPiil, .Lfunc_end0-_Z13sdiv_i32_loopPKiPiil
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
