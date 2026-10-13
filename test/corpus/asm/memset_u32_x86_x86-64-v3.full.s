	.att_syntax
	.file	"memset_u32.cpp"
	.text
	.globl	_Z10memset_u32Pjjl              # -- Begin function _Z10memset_u32Pjjl
	.prefalign	4, .Lfunc_end0, nop
	.type	_Z10memset_u32Pjjl,@function
_Z10memset_u32Pjjl:                     # @_Z10memset_u32Pjjl
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN memset_u32
	#NO_APP
	testq	%rdx, %rdx
	jle	.LBB0_13
# %bb.1:
	cmpq	$4, %rdx
	jae	.LBB0_4
# %bb.2:
	xorl	%eax, %eax
	jmp	.LBB0_3
.LBB0_4:
	movabsq	$9223372036854775776, %rcx      # imm = 0x7FFFFFFFFFFFFFE0
	vmovd	%esi, %xmm0
	cmpq	$32, %rdx
	jae	.LBB0_6
# %bb.5:
	xorl	%eax, %eax
	jmp	.LBB0_10
.LBB0_6:
	movq	%rdx, %rax
	andq	%rcx, %rax
	vpbroadcastd	%xmm0, %ymm1
	xorl	%r8d, %r8d
	.p2align	4
.LBB0_7:                                # =>This Inner Loop Header: Depth=1
	vmovdqu	%ymm1, (%rdi,%r8,4)
	vmovdqu	%ymm1, 32(%rdi,%r8,4)
	vmovdqu	%ymm1, 64(%rdi,%r8,4)
	vmovdqu	%ymm1, 96(%rdi,%r8,4)
	addq	$32, %r8
	cmpq	%r8, %rax
	jne	.LBB0_7
# %bb.8:
	cmpq	%rax, %rdx
	je	.LBB0_13
# %bb.9:
	testb	$28, %dl
	je	.LBB0_3
.LBB0_10:
	movq	%rax, %r8
	addq	$28, %rcx
	movq	%rcx, %rax
	andq	%rdx, %rax
	vpbroadcastd	%xmm0, %xmm0
	.p2align	4
.LBB0_11:                               # =>This Inner Loop Header: Depth=1
	vmovdqu	%xmm0, (%rdi,%r8,4)
	addq	$4, %r8
	cmpq	%r8, %rax
	jne	.LBB0_11
	jmp	.LBB0_12
.LBB0_3:
	movl	%esi, (%rdi,%rax,4)
	incq	%rax
.LBB0_12:
	cmpq	%rax, %rdx
	jne	.LBB0_3
.LBB0_13:
	#APP
	# LLVM-MCA-END memset_u32
	#NO_APP
	vzeroupper
	retq
.Lfunc_end0:
	.size	_Z10memset_u32Pjjl, .Lfunc_end0-_Z10memset_u32Pjjl
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
