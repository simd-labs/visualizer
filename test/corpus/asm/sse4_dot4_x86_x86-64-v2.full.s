	.att_syntax
	.file	"sse4_dot4.cpp"
	.text
	.globl	_Z9sse4_dot4PKfS0_l             # -- Begin function _Z9sse4_dot4PKfS0_l
	.prefalign	4, .Lfunc_end0, nop
	.type	_Z9sse4_dot4PKfS0_l,@function
_Z9sse4_dot4PKfS0_l:                    # @_Z9sse4_dot4PKfS0_l
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN sse4_dot4
	#NO_APP
	testq	%rdx, %rdx
	jle	.LBB0_1
# %bb.2:
	leaq	-1(%rdx), %r8
	shrq	$2, %r8
	incq	%r8
	movl	%r8d, %eax
	andl	$3, %eax
	cmpq	$13, %rdx
	jae	.LBB0_8
# %bb.3:
	xorps	%xmm0, %xmm0
	xorl	%ecx, %ecx
	jmp	.LBB0_5
.LBB0_1:
	xorps	%xmm0, %xmm0
	#APP
	# LLVM-MCA-END sse4_dot4
	#NO_APP
	retq
.LBB0_8:
	andq	$-4, %r8
	xorps	%xmm0, %xmm0
	xorl	%ecx, %ecx
	.p2align	4
.LBB0_9:                                # =>This Inner Loop Header: Depth=1
	movss	(%rdi,%rcx,4), %xmm1            # xmm1 = mem[0],zero,zero,zero
	movss	16(%rdi,%rcx,4), %xmm2          # xmm2 = mem[0],zero,zero,zero
	mulss	(%rsi,%rcx,4), %xmm1
	mulss	16(%rsi,%rcx,4), %xmm2
	addss	%xmm1, %xmm0
	movss	32(%rdi,%rcx,4), %xmm1          # xmm1 = mem[0],zero,zero,zero
	mulss	32(%rsi,%rcx,4), %xmm1
	addss	%xmm0, %xmm2
	movss	48(%rdi,%rcx,4), %xmm0          # xmm0 = mem[0],zero,zero,zero
	mulss	48(%rsi,%rcx,4), %xmm0
	addss	%xmm2, %xmm1
	addss	%xmm1, %xmm0
	addq	$16, %rcx
	addq	$-4, %r8
	jne	.LBB0_9
# %bb.4:
	testq	%rax, %rax
	je	.LBB0_7
.LBB0_5:
	leaq	(%rsi,%rcx,4), %rdx
	leaq	(%rdi,%rcx,4), %rcx
	shll	$4, %eax
	xorl	%esi, %esi
	.p2align	4
.LBB0_6:                                # =>This Inner Loop Header: Depth=1
	movss	(%rcx,%rsi), %xmm1              # xmm1 = mem[0],zero,zero,zero
	mulss	(%rdx,%rsi), %xmm1
	addss	%xmm1, %xmm0
	addq	$16, %rsi
	cmpq	%rsi, %rax
	jne	.LBB0_6
.LBB0_7:
	#APP
	# LLVM-MCA-END sse4_dot4
	#NO_APP
	retq
.Lfunc_end0:
	.size	_Z9sse4_dot4PKfS0_l, .Lfunc_end0-_Z9sse4_dot4PKfS0_l
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
