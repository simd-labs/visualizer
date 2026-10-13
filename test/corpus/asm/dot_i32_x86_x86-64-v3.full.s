	.att_syntax
	.file	"dot_i32.cpp"
	.text
	.globl	_Z7dot_i32PKiS0_l               # -- Begin function _Z7dot_i32PKiS0_l
	.prefalign	4, .Lfunc_end0, nop
	.type	_Z7dot_i32PKiS0_l,@function
_Z7dot_i32PKiS0_l:                      # @_Z7dot_i32PKiS0_l
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN dot_i32
	#NO_APP
	testq	%rdx, %rdx
	jle	.LBB0_1
# %bb.2:
	cmpq	$4, %rdx
	jae	.LBB0_5
# %bb.3:
	xorl	%ecx, %ecx
	xorl	%eax, %eax
	jmp	.LBB0_4
.LBB0_1:
	xorl	%eax, %eax
	#APP
	# LLVM-MCA-END dot_i32
	#NO_APP
	retq
.LBB0_5:
	movabsq	$9223372036854775792, %r8       # imm = 0x7FFFFFFFFFFFFFF0
	cmpq	$16, %rdx
	jae	.LBB0_7
# %bb.6:
	xorl	%ecx, %ecx
	xorl	%eax, %eax
	jmp	.LBB0_11
.LBB0_7:
	movq	%rdx, %rcx
	andq	%r8, %rcx
	vpxor	%xmm0, %xmm0, %xmm0
	xorl	%eax, %eax
	vpxor	%xmm1, %xmm1, %xmm1
	vpxor	%xmm2, %xmm2, %xmm2
	vpxor	%xmm3, %xmm3, %xmm3
	.p2align	4
.LBB0_8:                                # =>This Inner Loop Header: Depth=1
	vpmovzxdq	(%rdi,%rax,4), %ymm4    # ymm4 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero
	vpmovzxdq	16(%rdi,%rax,4), %ymm5  # ymm5 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero
	vpmovzxdq	32(%rdi,%rax,4), %ymm6  # ymm6 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero
	vpmovzxdq	48(%rdi,%rax,4), %ymm7  # ymm7 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero
	vpmovzxdq	(%rsi,%rax,4), %ymm8    # ymm8 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero
	vpmuldq	%ymm4, %ymm8, %ymm4
	vpaddq	%ymm0, %ymm4, %ymm0
	vpmovzxdq	16(%rsi,%rax,4), %ymm4  # ymm4 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero
	vpmuldq	%ymm5, %ymm4, %ymm4
	vpaddq	%ymm1, %ymm4, %ymm1
	vpmovzxdq	32(%rsi,%rax,4), %ymm4  # ymm4 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero
	vpmuldq	%ymm6, %ymm4, %ymm4
	vpaddq	%ymm2, %ymm4, %ymm2
	vpmovzxdq	48(%rsi,%rax,4), %ymm4  # ymm4 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero
	vpmuldq	%ymm7, %ymm4, %ymm4
	vpaddq	%ymm3, %ymm4, %ymm3
	addq	$16, %rax
	cmpq	%rax, %rcx
	jne	.LBB0_8
# %bb.9:
	vpaddq	%ymm0, %ymm1, %ymm0
	vpaddq	%ymm0, %ymm2, %ymm0
	vpaddq	%ymm0, %ymm3, %ymm0
	vextracti128	$1, %ymm0, %xmm1
	vpaddq	%xmm1, %xmm0, %xmm0
	vpshufd	$238, %xmm0, %xmm1              # xmm1 = xmm0[2,3,2,3]
	vpaddq	%xmm1, %xmm0, %xmm0
	vmovq	%xmm0, %rax
	cmpq	%rcx, %rdx
	je	.LBB0_15
# %bb.10:
	testb	$12, %dl
	je	.LBB0_4
.LBB0_11:
	movq	%rcx, %r9
	addq	$12, %r8
	movq	%r8, %rcx
	andq	%rdx, %rcx
	vmovq	%rax, %xmm0
	.p2align	4
.LBB0_12:                               # =>This Inner Loop Header: Depth=1
	vpmovzxdq	(%rdi,%r9,4), %ymm1     # ymm1 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero
	vpmovzxdq	(%rsi,%r9,4), %ymm2     # ymm2 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero
	vpmuldq	%ymm1, %ymm2, %ymm1
	vpaddq	%ymm0, %ymm1, %ymm0
	addq	$4, %r9
	cmpq	%r9, %rcx
	jne	.LBB0_12
# %bb.13:
	vextracti128	$1, %ymm0, %xmm1
	vpaddq	%xmm1, %xmm0, %xmm0
	vpshufd	$238, %xmm0, %xmm1              # xmm1 = xmm0[2,3,2,3]
	vpaddq	%xmm1, %xmm0, %xmm0
	vmovq	%xmm0, %rax
	jmp	.LBB0_14
.LBB0_4:
	movslq	(%rdi,%rcx,4), %r8
	movslq	(%rsi,%rcx,4), %r9
	imulq	%r8, %r9
	addq	%r9, %rax
	incq	%rcx
.LBB0_14:
	cmpq	%rcx, %rdx
	jne	.LBB0_4
.LBB0_15:
	#APP
	# LLVM-MCA-END dot_i32
	#NO_APP
	vzeroupper
	retq
.Lfunc_end0:
	.size	_Z7dot_i32PKiS0_l, .Lfunc_end0-_Z7dot_i32PKiS0_l
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
