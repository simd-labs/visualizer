	.att_syntax
	.file	"sse4_hsum_epi32.cpp"
	.text
	.globl	_Z15sse4_hsum_epi32PKil         # -- Begin function _Z15sse4_hsum_epi32PKil
	.prefalign	4, .Lfunc_end0, nop
	.type	_Z15sse4_hsum_epi32PKil,@function
_Z15sse4_hsum_epi32PKil:                # @_Z15sse4_hsum_epi32PKil
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN sse4_hsum_epi32
	#NO_APP
	testq	%rsi, %rsi
	jle	.LBB0_1
# %bb.2:
	leaq	-1(%rsi), %rcx
	shrq	$2, %rcx
	incq	%rcx
	movl	%ecx, %eax
	andl	$7, %eax
	cmpq	$29, %rsi
	jae	.LBB0_9
# %bb.3:
	vpxor	%xmm0, %xmm0, %xmm0
	xorl	%edx, %edx
	jmp	.LBB0_5
.LBB0_1:
	xorl	%eax, %eax
	#APP
	# LLVM-MCA-END sse4_hsum_epi32
	#NO_APP
	retq
.LBB0_9:
	andq	$-8, %rcx
	vpxor	%xmm0, %xmm0, %xmm0
	xorl	%edx, %edx
	.p2align	4
.LBB0_10:                               # =>This Inner Loop Header: Depth=1
	vpaddd	(%rdi,%rdx,4), %xmm0, %xmm0
	vpaddd	16(%rdi,%rdx,4), %xmm0, %xmm0
	vpaddd	32(%rdi,%rdx,4), %xmm0, %xmm0
	vpaddd	48(%rdi,%rdx,4), %xmm0, %xmm0
	vpaddd	64(%rdi,%rdx,4), %xmm0, %xmm0
	vpaddd	80(%rdi,%rdx,4), %xmm0, %xmm0
	vpaddd	96(%rdi,%rdx,4), %xmm0, %xmm0
	vpaddd	112(%rdi,%rdx,4), %xmm0, %xmm0
	addq	$32, %rdx
	addq	$-8, %rcx
	jne	.LBB0_10
# %bb.4:
	testq	%rax, %rax
	je	.LBB0_7
.LBB0_5:
	leaq	(%rdi,%rdx,4), %rcx
	shll	$4, %eax
	xorl	%edx, %edx
	.p2align	4
.LBB0_6:                                # =>This Inner Loop Header: Depth=1
	vpaddd	(%rcx,%rdx), %xmm0, %xmm0
	addq	$16, %rdx
	cmpq	%rdx, %rax
	jne	.LBB0_6
.LBB0_7:
	vpshufd	$238, %xmm0, %xmm1              # xmm1 = xmm0[2,3,2,3]
	vpaddd	%xmm1, %xmm0, %xmm0
	vpshufd	$85, %xmm0, %xmm1               # xmm1 = xmm0[1,1,1,1]
	vpaddd	%xmm1, %xmm0, %xmm0
	vmovd	%xmm0, %eax
	#APP
	# LLVM-MCA-END sse4_hsum_epi32
	#NO_APP
	retq
.Lfunc_end0:
	.size	_Z15sse4_hsum_epi32PKil, .Lfunc_end0-_Z15sse4_hsum_epi32PKil
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
