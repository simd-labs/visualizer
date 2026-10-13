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
	andl	$7, %eax
	cmpq	$8, %rdx
	jae	.LBB0_8
# %bb.3:
	vxorpd	%xmm0, %xmm0, %xmm0
	xorl	%ecx, %ecx
	jmp	.LBB0_5
.LBB0_1:
	vxorps	%xmm0, %xmm0, %xmm0
	#APP
	# LLVM-MCA-END dot_f64
	#NO_APP
	retq
.LBB0_8:
	movabsq	$9223372036854775800, %rcx      # imm = 0x7FFFFFFFFFFFFFF8
	vxorpd	%xmm0, %xmm0, %xmm0
	andq	%rcx, %rdx
	xorl	%ecx, %ecx
	.p2align	4
.LBB0_9:                                # =>This Inner Loop Header: Depth=1
	vmovsd	(%rdi,%rcx,8), %xmm1            # xmm1 = mem[0],zero
	vmovsd	8(%rdi,%rcx,8), %xmm2           # xmm2 = mem[0],zero
	vfmadd231sd	(%rsi,%rcx,8), %xmm1, %xmm0 # xmm0 = (xmm1 * mem) + xmm0
	vmovsd	16(%rdi,%rcx,8), %xmm1          # xmm1 = mem[0],zero
	vfmadd231sd	8(%rsi,%rcx,8), %xmm2, %xmm0 # xmm0 = (xmm2 * mem) + xmm0
	vfmadd132sd	16(%rsi,%rcx,8), %xmm0, %xmm1 # xmm1 = (xmm1 * mem) + xmm0
	vmovsd	24(%rdi,%rcx,8), %xmm0          # xmm0 = mem[0],zero
	vfmadd132sd	24(%rsi,%rcx,8), %xmm1, %xmm0 # xmm0 = (xmm0 * mem) + xmm1
	vmovsd	32(%rdi,%rcx,8), %xmm1          # xmm1 = mem[0],zero
	vfmadd132sd	32(%rsi,%rcx,8), %xmm0, %xmm1 # xmm1 = (xmm1 * mem) + xmm0
	vmovsd	40(%rdi,%rcx,8), %xmm0          # xmm0 = mem[0],zero
	vfmadd132sd	40(%rsi,%rcx,8), %xmm1, %xmm0 # xmm0 = (xmm0 * mem) + xmm1
	vmovsd	48(%rdi,%rcx,8), %xmm1          # xmm1 = mem[0],zero
	vfmadd132sd	48(%rsi,%rcx,8), %xmm0, %xmm1 # xmm1 = (xmm1 * mem) + xmm0
	vmovsd	56(%rdi,%rcx,8), %xmm0          # xmm0 = mem[0],zero
	vfmadd132sd	56(%rsi,%rcx,8), %xmm1, %xmm0 # xmm0 = (xmm0 * mem) + xmm1
	addq	$8, %rcx
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
	vmovsd	(%rcx,%rsi,8), %xmm1            # xmm1 = mem[0],zero
	vfmadd231sd	(%rdx,%rsi,8), %xmm1, %xmm0 # xmm0 = (xmm1 * mem) + xmm0
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
