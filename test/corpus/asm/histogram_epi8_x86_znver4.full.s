	.att_syntax
	.file	"histogram_epi8.cpp"
	.text
	.globl	_Z14histogram_epi8PKhPjl        # -- Begin function _Z14histogram_epi8PKhPjl
	.prefalign	4, .Lfunc_end0, nop
	.type	_Z14histogram_epi8PKhPjl,@function
_Z14histogram_epi8PKhPjl:               # @_Z14histogram_epi8PKhPjl
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN histogram_epi8
	#NO_APP
	testq	%rdx, %rdx
	jle	.LBB0_6
# %bb.1:
	movl	%edx, %eax
	andl	$7, %eax
	cmpq	$8, %rdx
	jae	.LBB0_7
# %bb.2:
	xorl	%ecx, %ecx
	jmp	.LBB0_4
.LBB0_7:
	movabsq	$9223372036854775800, %rcx      # imm = 0x7FFFFFFFFFFFFFF8
	andq	%rcx, %rdx
	xorl	%ecx, %ecx
	.p2align	4
.LBB0_8:                                # =>This Inner Loop Header: Depth=1
	movzbl	(%rdi,%rcx), %r8d
	incl	(%rsi,%r8,4)
	movzbl	1(%rdi,%rcx), %r8d
	incl	(%rsi,%r8,4)
	movzbl	2(%rdi,%rcx), %r8d
	incl	(%rsi,%r8,4)
	movzbl	3(%rdi,%rcx), %r8d
	incl	(%rsi,%r8,4)
	movzbl	4(%rdi,%rcx), %r8d
	incl	(%rsi,%r8,4)
	movzbl	5(%rdi,%rcx), %r8d
	incl	(%rsi,%r8,4)
	movzbl	6(%rdi,%rcx), %r8d
	incl	(%rsi,%r8,4)
	movzbl	7(%rdi,%rcx), %r8d
	addq	$8, %rcx
	incl	(%rsi,%r8,4)
	cmpq	%rcx, %rdx
	jne	.LBB0_8
# %bb.3:
	testq	%rax, %rax
	je	.LBB0_6
.LBB0_4:
	addq	%rcx, %rdi
	xorl	%ecx, %ecx
	.p2align	4
.LBB0_5:                                # =>This Inner Loop Header: Depth=1
	movzbl	(%rdi,%rcx), %edx
	incq	%rcx
	incl	(%rsi,%rdx,4)
	cmpq	%rcx, %rax
	jne	.LBB0_5
.LBB0_6:
	#APP
	# LLVM-MCA-END histogram_epi8
	#NO_APP
	retq
.Lfunc_end0:
	.size	_Z14histogram_epi8PKhPjl, .Lfunc_end0-_Z14histogram_epi8PKhPjl
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
