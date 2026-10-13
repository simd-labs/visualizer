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
	cmpq	$8, %rdx
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
	movabsq	$9223372036854775776, %r8       # imm = 0x7FFFFFFFFFFFFFE0
	cmpq	$32, %rdx
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
	vpmovzxdq	(%rdi,%rax,4), %zmm4    # zmm4 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero,mem[4],zero,mem[5],zero,mem[6],zero,mem[7],zero
	vpmovzxdq	(%rsi,%rax,4), %zmm8    # zmm8 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero,mem[4],zero,mem[5],zero,mem[6],zero,mem[7],zero
	vpmovzxdq	32(%rdi,%rax,4), %zmm5  # zmm5 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero,mem[4],zero,mem[5],zero,mem[6],zero,mem[7],zero
	vpmovzxdq	32(%rsi,%rax,4), %zmm9  # zmm9 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero,mem[4],zero,mem[5],zero,mem[6],zero,mem[7],zero
	vpmovzxdq	64(%rdi,%rax,4), %zmm6  # zmm6 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero,mem[4],zero,mem[5],zero,mem[6],zero,mem[7],zero
	vpmovzxdq	96(%rdi,%rax,4), %zmm7  # zmm7 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero,mem[4],zero,mem[5],zero,mem[6],zero,mem[7],zero
	vpmuldq	%zmm4, %zmm8, %zmm4
	vpmovzxdq	64(%rsi,%rax,4), %zmm8  # zmm8 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero,mem[4],zero,mem[5],zero,mem[6],zero,mem[7],zero
	vpaddq	%zmm0, %zmm4, %zmm0
	vpmuldq	%zmm5, %zmm9, %zmm4
	vpmovzxdq	96(%rsi,%rax,4), %zmm5  # zmm5 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero,mem[4],zero,mem[5],zero,mem[6],zero,mem[7],zero
	addq	$32, %rax
	vpaddq	%zmm1, %zmm4, %zmm1
	vpmuldq	%zmm6, %zmm8, %zmm4
	vpaddq	%zmm2, %zmm4, %zmm2
	vpmuldq	%zmm7, %zmm5, %zmm4
	vpaddq	%zmm3, %zmm4, %zmm3
	cmpq	%rax, %rcx
	jne	.LBB0_8
# %bb.9:
	vpaddq	%zmm0, %zmm1, %zmm0
	vpaddq	%zmm0, %zmm2, %zmm0
	vpaddq	%zmm0, %zmm3, %zmm0
	vextracti64x4	$1, %zmm0, %ymm1
	vpaddq	%zmm1, %zmm0, %zmm0
	vextracti128	$1, %ymm0, %xmm1
	vpaddq	%xmm1, %xmm0, %xmm0
	vpshufd	$238, %xmm0, %xmm1              # xmm1 = xmm0[2,3,2,3]
	vpaddq	%xmm1, %xmm0, %xmm0
	vmovq	%xmm0, %rax
	cmpq	%rcx, %rdx
	je	.LBB0_15
# %bb.10:
	testb	$24, %dl
	je	.LBB0_4
.LBB0_11:
	addq	$24, %r8
	movq	%rcx, %r9
	vmovq	%rax, %xmm0
	movq	%r8, %rcx
	andq	%rdx, %rcx
	.p2align	4
.LBB0_12:                               # =>This Inner Loop Header: Depth=1
	vpmovzxdq	(%rdi,%r9,4), %zmm1     # zmm1 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero,mem[4],zero,mem[5],zero,mem[6],zero,mem[7],zero
	vpmovzxdq	(%rsi,%r9,4), %zmm2     # zmm2 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero,mem[4],zero,mem[5],zero,mem[6],zero,mem[7],zero
	addq	$8, %r9
	vpmuldq	%zmm1, %zmm2, %zmm1
	vpaddq	%zmm0, %zmm1, %zmm0
	cmpq	%r9, %rcx
	jne	.LBB0_12
# %bb.13:
	vextracti64x4	$1, %zmm0, %ymm1
	vpaddq	%zmm1, %zmm0, %zmm0
	vextracti128	$1, %ymm0, %xmm1
	vpaddq	%xmm1, %xmm0, %xmm0
	vpshufd	$238, %xmm0, %xmm1              # xmm1 = xmm0[2,3,2,3]
	vpaddq	%xmm1, %xmm0, %xmm0
	vmovq	%xmm0, %rax
	jmp	.LBB0_14
.LBB0_4:
	movslq	(%rdi,%rcx,4), %r8
	movslq	(%rsi,%rcx,4), %r9
	incq	%rcx
	imulq	%r8, %r9
	addq	%r9, %rax
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
