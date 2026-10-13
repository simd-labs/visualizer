	.att_syntax
	.file	"avx2_hmax_epi32.cpp"
	.text
	.globl	_Z15avx2_hmax_epi32PKil         # -- Begin function _Z15avx2_hmax_epi32PKil
	.prefalign	4, .Lfunc_end0, nop
	.type	_Z15avx2_hmax_epi32PKil,@function
_Z15avx2_hmax_epi32PKil:                # @_Z15avx2_hmax_epi32PKil
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN avx2_hmax_epi32
	#NO_APP
	testq	%rsi, %rsi
	jle	.LBB0_1
# %bb.2:
	leaq	-1(%rsi), %rcx
	shrq	$3, %rcx
	incq	%rcx
	movl	%ecx, %eax
	andl	$7, %eax
	cmpq	$57, %rsi
	jae	.LBB0_8
# %bb.3:
	vpxor	%xmm0, %xmm0, %xmm0
	xorl	%edx, %edx
	jmp	.LBB0_5
.LBB0_1:
	vpxor	%xmm0, %xmm0, %xmm0
	jmp	.LBB0_7
.LBB0_8:
	andq	$-8, %rcx
	vpxor	%xmm0, %xmm0, %xmm0
	xorl	%edx, %edx
	.p2align	4
.LBB0_9:                                # =>This Inner Loop Header: Depth=1
	vpmaxsd	(%rdi,%rdx,4), %ymm0, %ymm0
	vpmaxsd	32(%rdi,%rdx,4), %ymm0, %ymm0
	vpmaxsd	64(%rdi,%rdx,4), %ymm0, %ymm0
	vpmaxsd	96(%rdi,%rdx,4), %ymm0, %ymm0
	vpmaxsd	128(%rdi,%rdx,4), %ymm0, %ymm0
	vpmaxsd	160(%rdi,%rdx,4), %ymm0, %ymm0
	vpmaxsd	192(%rdi,%rdx,4), %ymm0, %ymm0
	vpmaxsd	224(%rdi,%rdx,4), %ymm0, %ymm0
	addq	$64, %rdx
	addq	$-8, %rcx
	jne	.LBB0_9
# %bb.4:
	testq	%rax, %rax
	je	.LBB0_7
.LBB0_5:
	leaq	(%rdi,%rdx,4), %rcx
	shll	$5, %eax
	xorl	%edx, %edx
	.p2align	4
.LBB0_6:                                # =>This Inner Loop Header: Depth=1
	vpmaxsd	(%rcx,%rdx), %ymm0, %ymm0
	addq	$32, %rdx
	cmpq	%rdx, %rax
	jne	.LBB0_6
.LBB0_7:
	#APP
	# LLVM-MCA-END avx2_hmax_epi32
	#NO_APP
	vextracti128	$1, %ymm0, %xmm1
	vpmaxsd	%xmm1, %xmm0, %xmm0
	vmovd	%xmm0, %eax
	vzeroupper
	retq
.Lfunc_end0:
	.size	_Z15avx2_hmax_epi32PKil, .Lfunc_end0-_Z15avx2_hmax_epi32PKil
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
