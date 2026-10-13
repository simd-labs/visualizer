	.att_syntax
	.file	"dot_f32.cpp"
	.text
	.globl	_Z7dot_f32PKfS0_l               # -- Begin function _Z7dot_f32PKfS0_l
	.prefalign	4, .Lfunc_end0, nop
	.type	_Z7dot_f32PKfS0_l,@function
_Z7dot_f32PKfS0_l:                      # @_Z7dot_f32PKfS0_l
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN dot_f32
	#NO_APP
	testq	%rdx, %rdx
	jle	.LBB0_1
# %bb.2:
	movl	%edx, %eax
	andl	$3, %eax
	cmpq	$4, %rdx
	jae	.LBB0_8
# %bb.3:
	xorps	%xmm0, %xmm0
	xorl	%ecx, %ecx
	jmp	.LBB0_5
.LBB0_1:
	xorps	%xmm0, %xmm0
	#APP
	# LLVM-MCA-END dot_f32
	#NO_APP
	retq
.LBB0_8:
	movabsq	$9223372036854775804, %rcx      # imm = 0x7FFFFFFFFFFFFFFC
	andq	%rcx, %rdx
	xorps	%xmm0, %xmm0
	xorl	%ecx, %ecx
	.p2align	4
.LBB0_9:                                # =>This Inner Loop Header: Depth=1
	movss	(%rdi,%rcx,4), %xmm1            # xmm1 = mem[0],zero,zero,zero
	movss	4(%rdi,%rcx,4), %xmm2           # xmm2 = mem[0],zero,zero,zero
	mulss	(%rsi,%rcx,4), %xmm1
	mulss	4(%rsi,%rcx,4), %xmm2
	addss	%xmm0, %xmm1
	movss	8(%rdi,%rcx,4), %xmm3           # xmm3 = mem[0],zero,zero,zero
	mulss	8(%rsi,%rcx,4), %xmm3
	addss	%xmm1, %xmm2
	movss	12(%rdi,%rcx,4), %xmm0          # xmm0 = mem[0],zero,zero,zero
	mulss	12(%rsi,%rcx,4), %xmm0
	addss	%xmm2, %xmm3
	addss	%xmm3, %xmm0
	addq	$4, %rcx
	cmpq	%rcx, %rdx
	jne	.LBB0_9
# %bb.4:
	testq	%rax, %rax
	je	.LBB0_7
.LBB0_5:
	leaq	(%rsi,%rcx,4), %rdx
	leaq	(%rdi,%rcx,4), %rcx
	xorl	%esi, %esi
	.p2align	4
.LBB0_6:                                # =>This Inner Loop Header: Depth=1
	movss	(%rcx,%rsi,4), %xmm1            # xmm1 = mem[0],zero,zero,zero
	mulss	(%rdx,%rsi,4), %xmm1
	addss	%xmm1, %xmm0
	incq	%rsi
	cmpq	%rsi, %rax
	jne	.LBB0_6
.LBB0_7:
	#APP
	# LLVM-MCA-END dot_f32
	#NO_APP
	retq
.Lfunc_end0:
	.size	_Z7dot_f32PKfS0_l, .Lfunc_end0-_Z7dot_f32PKfS0_l
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
