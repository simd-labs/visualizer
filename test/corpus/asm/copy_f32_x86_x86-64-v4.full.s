	.att_syntax
	.file	"copy_f32.cpp"
	.text
	.globl	_Z8copy_f32PKfPfl               # -- Begin function _Z8copy_f32PKfPfl
	.prefalign	4, .Lfunc_end0, nop
	.type	_Z8copy_f32PKfPfl,@function
_Z8copy_f32PKfPfl:                      # @_Z8copy_f32PKfPfl
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN copy_f32
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
	cmpq	$32, %rdx
	jae	.LBB0_6
# %bb.5:
	xorl	%eax, %eax
	jmp	.LBB0_10
.LBB0_6:
	movq	%rdx, %rax
	andq	%rcx, %rax
	xorl	%r8d, %r8d
	.p2align	4
.LBB0_7:                                # =>This Inner Loop Header: Depth=1
	vmovups	(%rdi,%r8,4), %ymm0
	vmovups	32(%rdi,%r8,4), %ymm1
	vmovups	64(%rdi,%r8,4), %ymm2
	vmovups	96(%rdi,%r8,4), %ymm3
	vmovups	%ymm0, (%rsi,%r8,4)
	vmovups	%ymm1, 32(%rsi,%r8,4)
	vmovups	%ymm2, 64(%rsi,%r8,4)
	vmovups	%ymm3, 96(%rsi,%r8,4)
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
	.p2align	4
.LBB0_11:                               # =>This Inner Loop Header: Depth=1
	vmovups	(%rdi,%r8,4), %xmm0
	vmovups	%xmm0, (%rsi,%r8,4)
	addq	$4, %r8
	cmpq	%r8, %rax
	jne	.LBB0_11
	jmp	.LBB0_12
.LBB0_3:
	vmovss	(%rdi,%rax,4), %xmm0            # xmm0 = mem[0],zero,zero,zero
	vmovss	%xmm0, (%rsi,%rax,4)
	incq	%rax
.LBB0_12:
	cmpq	%rax, %rdx
	jne	.LBB0_3
.LBB0_13:
	#APP
	# LLVM-MCA-END copy_f32
	#NO_APP
	vzeroupper
	retq
.Lfunc_end0:
	.size	_Z8copy_f32PKfPfl, .Lfunc_end0-_Z8copy_f32PKfPfl
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
