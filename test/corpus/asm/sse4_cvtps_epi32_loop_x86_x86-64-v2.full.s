	.att_syntax
	.file	"sse4_cvtps_epi32_loop.cpp"
	.text
	.globl	_Z21sse4_cvtps_epi32_loopPKfPil # -- Begin function _Z21sse4_cvtps_epi32_loopPKfPil
	.prefalign	4, .Lfunc_end0, nop
	.type	_Z21sse4_cvtps_epi32_loopPKfPil,@function
_Z21sse4_cvtps_epi32_loopPKfPil:        # @_Z21sse4_cvtps_epi32_loopPKfPil
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN sse4_cvtps_epi32
	#NO_APP
	testq	%rdx, %rdx
	jle	.LBB0_6
# %bb.1:
	leaq	-1(%rdx), %rcx
	shrq	$2, %rcx
	incq	%rcx
	movl	%ecx, %eax
	andl	$3, %eax
	cmpq	$13, %rdx
	jae	.LBB0_7
# %bb.2:
	xorl	%edx, %edx
	jmp	.LBB0_4
.LBB0_7:
	andq	$-4, %rcx
	xorl	%edx, %edx
	.p2align	4
.LBB0_8:                                # =>This Inner Loop Header: Depth=1
	cvtps2dq	(%rdi,%rdx,4), %xmm0
	movntpd	%xmm0, (%rsi,%rdx,4)
	cvtps2dq	16(%rdi,%rdx,4), %xmm0
	movntpd	%xmm0, 16(%rsi,%rdx,4)
	cvtps2dq	32(%rdi,%rdx,4), %xmm0
	cvtps2dq	48(%rdi,%rdx,4), %xmm1
	movntpd	%xmm0, 32(%rsi,%rdx,4)
	movntpd	%xmm1, 48(%rsi,%rdx,4)
	addq	$16, %rdx
	addq	$-4, %rcx
	jne	.LBB0_8
# %bb.3:
	testq	%rax, %rax
	je	.LBB0_6
.LBB0_4:
	leaq	(%rsi,%rdx,4), %rcx
	leaq	(%rdi,%rdx,4), %rdx
	shll	$4, %eax
	xorl	%esi, %esi
	.p2align	4
.LBB0_5:                                # =>This Inner Loop Header: Depth=1
	cvtps2dq	(%rdx,%rsi), %xmm0
	movntpd	%xmm0, (%rcx,%rsi)
	addq	$16, %rsi
	cmpq	%rsi, %rax
	jne	.LBB0_5
.LBB0_6:
	#APP
	# LLVM-MCA-END sse4_cvtps_epi32
	#NO_APP
	retq
.Lfunc_end0:
	.size	_Z21sse4_cvtps_epi32_loopPKfPil, .Lfunc_end0-_Z21sse4_cvtps_epi32_loopPKfPil
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
