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
	jle	.LBB0_10
# %bb.1:
	cmpq	$8, %rdx
	jae	.LBB0_3
# %bb.2:
	xorl	%eax, %eax
	jmp	.LBB0_6
.LBB0_3:
	movabsq	$9223372036854775800, %rax      # imm = 0x7FFFFFFFFFFFFFF8
	andq	%rdx, %rax
	movaps	%xmm0, %xmm2
	movaps	%xmm0, %xmm3
	shufps	$0, %xmm0, %xmm3                # xmm3 = xmm3[0,0],xmm0[0,0]
	movaps	%xmm1, %xmm4
	shufps	$0, %xmm1, %xmm4                # xmm4 = xmm4[0,0],xmm1[0,0]
	xorl	%ecx, %ecx
	.p2align	4
.LBB0_4:                                # =>This Inner Loop Header: Depth=1
	movups	(%rdi,%rcx,4), %xmm0
	movaps	%xmm4, %xmm5
	minps	%xmm0, %xmm5
	cmpnltps	%xmm3, %xmm0
	movaps	%xmm3, %xmm6
	blendvps	%xmm0, %xmm5, %xmm6
	movups	16(%rdi,%rcx,4), %xmm0
	movaps	%xmm4, %xmm5
	minps	%xmm0, %xmm5
	cmpnltps	%xmm3, %xmm0
	movaps	%xmm3, %xmm7
	blendvps	%xmm0, %xmm5, %xmm7
	movups	%xmm6, (%rsi,%rcx,4)
	movups	%xmm7, 16(%rsi,%rcx,4)
	addq	$8, %rcx
	cmpq	%rcx, %rax
	jne	.LBB0_4
# %bb.5:
	cmpq	%rax, %rdx
	movaps	%xmm2, %xmm0
	jne	.LBB0_6
.LBB0_10:
	#APP
	# LLVM-MCA-END clamp_branchy
	#NO_APP
	retq
	.p2align	4
.LBB0_9:                                #   in Loop: Header=BB0_6 Depth=1
	movss	%xmm2, (%rsi,%rax,4)
	incq	%rax
	cmpq	%rax, %rdx
	je	.LBB0_10
.LBB0_6:                                # =>This Inner Loop Header: Depth=1
	movss	(%rdi,%rax,4), %xmm3            # xmm3 = mem[0],zero,zero,zero
	ucomiss	%xmm3, %xmm0
	movaps	%xmm0, %xmm2
	ja	.LBB0_9
# %bb.7:                                #   in Loop: Header=BB0_6 Depth=1
	ucomiss	%xmm1, %xmm3
	movaps	%xmm3, %xmm2
	jbe	.LBB0_9
# %bb.8:                                #   in Loop: Header=BB0_6 Depth=1
	movaps	%xmm1, %xmm2
	jmp	.LBB0_9
.Lfunc_end0:
	.size	_Z13clamp_branchyPKfPflff, .Lfunc_end0-_Z13clamp_branchyPKfPflff
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
