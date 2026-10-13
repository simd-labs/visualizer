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
	jle	.LBB0_6
# %bb.1:
	movl	%edx, %r8d
	movl	%ecx, %r9d
	andl	$3, %r9d
	cmpq	$4, %rcx
	jae	.LBB0_7
# %bb.2:
	xorl	%r10d, %r10d
	jmp	.LBB0_4
.LBB0_7:
	movabsq	$9223372036854775804, %rax      # imm = 0x7FFFFFFFFFFFFFFC
	andq	%rax, %rcx
	xorl	%r10d, %r10d
	.p2align	4
.LBB0_8:                                # =>This Inner Loop Header: Depth=1
	movl	(%rdi,%r10,4), %eax
	cltd
	idivl	%r8d
	movl	%eax, (%rsi,%r10,4)
	movl	4(%rdi,%r10,4), %eax
	cltd
	idivl	%r8d
	movl	%eax, 4(%rsi,%r10,4)
	movl	8(%rdi,%r10,4), %eax
	cltd
	idivl	%r8d
	movl	%eax, 8(%rsi,%r10,4)
	movl	12(%rdi,%r10,4), %eax
	cltd
	idivl	%r8d
	movl	%eax, 12(%rsi,%r10,4)
	addq	$4, %r10
	cmpq	%r10, %rcx
	jne	.LBB0_8
# %bb.3:
	testq	%r9, %r9
	je	.LBB0_6
.LBB0_4:
	leaq	(%rsi,%r10,4), %rcx
	leaq	(%rdi,%r10,4), %rsi
	xorl	%edi, %edi
	.p2align	4
.LBB0_5:                                # =>This Inner Loop Header: Depth=1
	movl	(%rsi,%rdi,4), %eax
	cltd
	idivl	%r8d
	movl	%eax, (%rcx,%rdi,4)
	incq	%rdi
	cmpq	%rdi, %r9
	jne	.LBB0_5
.LBB0_6:
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
