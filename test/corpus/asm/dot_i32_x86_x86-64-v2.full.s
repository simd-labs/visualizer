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
	movabsq	$9223372036854775804, %rcx      # imm = 0x7FFFFFFFFFFFFFFC
	andq	%rdx, %rcx
	pxor	%xmm0, %xmm0
	xorl	%eax, %eax
	pxor	%xmm1, %xmm1
	.p2align	4
.LBB0_6:                                # =>This Inner Loop Header: Depth=1
	pmovzxdq	(%rdi,%rax,4), %xmm2            # xmm2 = mem[0],zero,mem[1],zero
	pmovzxdq	8(%rdi,%rax,4), %xmm3           # xmm3 = mem[0],zero,mem[1],zero
	pmovzxdq	(%rsi,%rax,4), %xmm4            # xmm4 = mem[0],zero,mem[1],zero
	pmuldq	%xmm2, %xmm4
	paddq	%xmm4, %xmm1
	pmovzxdq	8(%rsi,%rax,4), %xmm2           # xmm2 = mem[0],zero,mem[1],zero
	pmuldq	%xmm3, %xmm2
	paddq	%xmm2, %xmm0
	addq	$4, %rax
	cmpq	%rax, %rcx
	jne	.LBB0_6
# %bb.7:
	paddq	%xmm1, %xmm0
	pshufd	$238, %xmm0, %xmm1              # xmm1 = xmm0[2,3,2,3]
	paddq	%xmm0, %xmm1
	movq	%xmm1, %rax
	jmp	.LBB0_8
.LBB0_4:
	movslq	(%rdi,%rcx,4), %r8
	movslq	(%rsi,%rcx,4), %r9
	imulq	%r8, %r9
	addq	%r9, %rax
	incq	%rcx
.LBB0_8:
	cmpq	%rcx, %rdx
	jne	.LBB0_4
# %bb.9:
	#APP
	# LLVM-MCA-END dot_i32
	#NO_APP
	retq
.Lfunc_end0:
	.size	_Z7dot_i32PKiS0_l, .Lfunc_end0-_Z7dot_i32PKiS0_l
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
