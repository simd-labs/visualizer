	.att_syntax
	.file	"clamp_branchy.cpp"
	.text
	.globl	_Z13clamp_branchyPKfPflff       # -- Begin function _Z13clamp_branchyPKfPflff
	.prefalign	4, .Lfunc_end0, nop
	.type	_Z13clamp_branchyPKfPflff,@function
_Z13clamp_branchyPKfPflff:              # @_Z13clamp_branchyPKfPflff
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN clamp_branchy
	#NO_APP
	testq	%rdx, %rdx
	jle	.LBB0_16
# %bb.1:
	cmpq	$8, %rdx
	jae	.LBB0_3
# %bb.2:
	xorl	%eax, %eax
	jmp	.LBB0_12
.LBB0_3:
	movabsq	$9223372036854775776, %rcx      # imm = 0x7FFFFFFFFFFFFFE0
	cmpq	$32, %rdx
	jae	.LBB0_5
# %bb.4:
	xorl	%eax, %eax
	jmp	.LBB0_9
.LBB0_5:
	movq	%rdx, %rax
	andq	%rcx, %rax
	vbroadcastss	%xmm0, %ymm2
	vbroadcastss	%xmm1, %ymm3
	xorl	%r8d, %r8d
	.p2align	4
.LBB0_6:                                # =>This Inner Loop Header: Depth=1
	vmovups	(%rdi,%r8,4), %ymm4
	vmovups	32(%rdi,%r8,4), %ymm5
	vmovups	64(%rdi,%r8,4), %ymm6
	vmovups	96(%rdi,%r8,4), %ymm7
	vcmpnltps	%ymm2, %ymm4, %k1
	vcmpnltps	%ymm2, %ymm5, %k2
	vcmpnltps	%ymm2, %ymm6, %k3
	vcmpnltps	%ymm2, %ymm7, %k4
	vmovaps	%ymm2, %ymm8
	vminps	%ymm4, %ymm3, %ymm8 {%k1}
	vmovaps	%ymm2, %ymm4
	vminps	%ymm5, %ymm3, %ymm4 {%k2}
	vmovaps	%ymm2, %ymm5
	vminps	%ymm6, %ymm3, %ymm5 {%k3}
	vmovaps	%ymm2, %ymm6
	vminps	%ymm7, %ymm3, %ymm6 {%k4}
	vmovups	%ymm8, (%rsi,%r8,4)
	vmovups	%ymm4, 32(%rsi,%r8,4)
	vmovups	%ymm5, 64(%rsi,%r8,4)
	vmovups	%ymm6, 96(%rsi,%r8,4)
	addq	$32, %r8
	cmpq	%r8, %rax
	jne	.LBB0_6
# %bb.7:
	cmpq	%rax, %rdx
	je	.LBB0_16
# %bb.8:
	testb	$24, %dl
	je	.LBB0_12
.LBB0_9:
	movq	%rax, %r8
	addq	$24, %rcx
	movq	%rcx, %rax
	andq	%rdx, %rax
	vbroadcastss	%xmm0, %ymm2
	vbroadcastss	%xmm1, %ymm3
	.p2align	4
.LBB0_10:                               # =>This Inner Loop Header: Depth=1
	vmovups	(%rdi,%r8,4), %ymm4
	vcmpnltps	%ymm2, %ymm4, %k1
	vmovaps	%ymm2, %ymm5
	vminps	%ymm4, %ymm3, %ymm5 {%k1}
	vmovups	%ymm5, (%rsi,%r8,4)
	addq	$8, %r8
	cmpq	%r8, %rax
	jne	.LBB0_10
.LBB0_11:
	cmpq	%rax, %rdx
	je	.LBB0_16
.LBB0_12:
	vmovss	(%rdi,%rax,4), %xmm3            # xmm3 = mem[0],zero,zero,zero
	vucomiss	%xmm3, %xmm0
	vmovaps	%xmm0, %xmm2
	ja	.LBB0_15
# %bb.13:
	vucomiss	%xmm1, %xmm3
	vmovaps	%xmm3, %xmm2
	jbe	.LBB0_15
# %bb.14:
	vmovaps	%xmm1, %xmm2
.LBB0_15:
	vmovss	%xmm2, (%rsi,%rax,4)
	incq	%rax
	jmp	.LBB0_11
.LBB0_16:
	#APP
	# LLVM-MCA-END clamp_branchy
	#NO_APP
	vzeroupper
	retq
.Lfunc_end0:
	.size	_Z13clamp_branchyPKfPflff, .Lfunc_end0-_Z13clamp_branchyPKfPflff
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
