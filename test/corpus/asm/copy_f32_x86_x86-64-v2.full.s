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
	xorl	%ecx, %ecx
	.p2align	4
.LBB0_5:                                # =>This Inner Loop Header: Depth=1
	movups	(%rdi,%rcx,4), %xmm0
	movups	16(%rdi,%rcx,4), %xmm1
	movups	%xmm0, (%rsi,%rcx,4)
	movups	%xmm1, 16(%rsi,%rcx,4)
	addq	$8, %rcx
	cmpq	%rcx, %rax
	jne	.LBB0_5
	jmp	.LBB0_6
.LBB0_3:
	movss	(%rdi,%rax,4), %xmm0            # xmm0 = mem[0],zero,zero,zero
	movss	%xmm0, (%rsi,%rax,4)
	incq	%rax
.LBB0_6:
	cmpq	%rax, %rdx
	jne	.LBB0_3
.LBB0_7:
	#APP
	# LLVM-MCA-END copy_f32
	#NO_APP
	retq
.Lfunc_end0:
	.size	_Z8copy_f32PKfPfl, .Lfunc_end0-_Z8copy_f32PKfPfl
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
