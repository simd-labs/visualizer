	.att_syntax
	.file	"dot_f64.cpp"
	.text
	.globl	_Z7dot_f64PKdS0_l               # -- Begin function _Z7dot_f64PKdS0_l
	.prefalign	4, .Lfunc_end0, nop
	.type	_Z7dot_f64PKdS0_l,@function
_Z7dot_f64PKdS0_l:                      # @_Z7dot_f64PKdS0_l
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN dot_f64
	#NO_APP
	testq	%rdx, %rdx
	jle	.LBB0_1
# %bb.2:
	movl	%edx, %eax
	andl	$3, %eax
	cmpq	$4, %rdx
	jae	.LBB0_8
# %bb.3:
	xorpd	%xmm0, %xmm0
	xorl	%ecx, %ecx
	jmp	.LBB0_5
.LBB0_1:
	xorps	%xmm0, %xmm0
	#APP
	# LLVM-MCA-END dot_f64
	#NO_APP
	retq
.LBB0_8:
	movabsq	$9223372036854775804, %rcx      # imm = 0x7FFFFFFFFFFFFFFC
	andq	%rcx, %rdx
	xorpd	%xmm0, %xmm0
	xorl	%ecx, %ecx
	.p2align	4
.LBB0_9:                                # =>This Inner Loop Header: Depth=1
	movsd	(%rdi,%rcx,8), %xmm1            # xmm1 = mem[0],zero
	movsd	8(%rdi,%rcx,8), %xmm2           # xmm2 = mem[0],zero
	mulsd	(%rsi,%rcx,8), %xmm1
	mulsd	8(%rsi,%rcx,8), %xmm2
	addsd	%xmm0, %xmm1
	movsd	16(%rdi,%rcx,8), %xmm3          # xmm3 = mem[0],zero
	mulsd	16(%rsi,%rcx,8), %xmm3
	addsd	%xmm1, %xmm2
	movsd	24(%rdi,%rcx,8), %xmm0          # xmm0 = mem[0],zero
	mulsd	24(%rsi,%rcx,8), %xmm0
	addsd	%xmm2, %xmm3
	addsd	%xmm3, %xmm0
	addq	$4, %rcx
	cmpq	%rcx, %rdx
	jne	.LBB0_9
# %bb.4:
	testq	%rax, %rax
	je	.LBB0_7
.LBB0_5:
	leaq	(%rsi,%rcx,8), %rdx
	leaq	(%rdi,%rcx,8), %rcx
	xorl	%esi, %esi
	.p2align	4
.LBB0_6:                                # =>This Inner Loop Header: Depth=1
	movsd	(%rcx,%rsi,8), %xmm1            # xmm1 = mem[0],zero
	mulsd	(%rdx,%rsi,8), %xmm1
	addsd	%xmm1, %xmm0
	incq	%rsi
	cmpq	%rsi, %rax
	jne	.LBB0_6
.LBB0_7:
	#APP
	# LLVM-MCA-END dot_f64
	#NO_APP
	retq
.Lfunc_end0:
	.size	_Z7dot_f64PKdS0_l, .Lfunc_end0-_Z7dot_f64PKdS0_l
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
