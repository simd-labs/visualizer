	.att_syntax
	.file	"saxpy.cpp"
	.text
	.globl	_Z5saxpyfPKfPfl                 # -- Begin function _Z5saxpyfPKfPfl
	.prefalign	4, .Lfunc_end0, nop
	.type	_Z5saxpyfPKfPfl,@function
_Z5saxpyfPKfPfl:                        # @_Z5saxpyfPKfPfl
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN saxpy
	#NO_APP
	testq	%rdx, %rdx
	jle	.LBB0_7
# %bb.1:
	cmpq	$8, %rdx
	jae	.LBB0_4
# %bb.2:
	xorl	%eax, %eax
	jmp	.LBB0_3
.LBB0_4:
	movabsq	$9223372036854775800, %rax      # imm = 0x7FFFFFFFFFFFFFF8
	andq	%rdx, %rax
	movaps	%xmm0, %xmm1
	shufps	$0, %xmm0, %xmm1                # xmm1 = xmm1[0,0],xmm0[0,0]
	xorl	%ecx, %ecx
	.p2align	4
.LBB0_5:                                # =>This Inner Loop Header: Depth=1
	movups	(%rdi,%rcx,4), %xmm2
	movups	16(%rdi,%rcx,4), %xmm3
	movups	(%rsi,%rcx,4), %xmm4
	movups	16(%rsi,%rcx,4), %xmm5
	mulps	%xmm1, %xmm2
	addps	%xmm4, %xmm2
	mulps	%xmm1, %xmm3
	addps	%xmm5, %xmm3
	movups	%xmm2, (%rsi,%rcx,4)
	movups	%xmm3, 16(%rsi,%rcx,4)
	addq	$8, %rcx
	cmpq	%rcx, %rax
	jne	.LBB0_5
	jmp	.LBB0_6
.LBB0_3:
	movss	(%rdi,%rax,4), %xmm1            # xmm1 = mem[0],zero,zero,zero
	mulss	%xmm0, %xmm1
	addss	(%rsi,%rax,4), %xmm1
	movss	%xmm1, (%rsi,%rax,4)
	incq	%rax
.LBB0_6:
	cmpq	%rax, %rdx
	jne	.LBB0_3
.LBB0_7:
	#APP
	# LLVM-MCA-END saxpy
	#NO_APP
	retq
.Lfunc_end0:
	.size	_Z5saxpyfPKfPfl, .Lfunc_end0-_Z5saxpyfPKfPfl
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
