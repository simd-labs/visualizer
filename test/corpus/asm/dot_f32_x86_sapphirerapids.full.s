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
	andl	$7, %eax
	cmpq	$8, %rdx
	jae	.LBB0_8
# %bb.3:
	vxorps	%xmm0, %xmm0, %xmm0
	xorl	%ecx, %ecx
	jmp	.LBB0_5
.LBB0_1:
	vxorps	%xmm0, %xmm0, %xmm0
	#APP
	# LLVM-MCA-END dot_f32
	#NO_APP
	retq
.LBB0_8:
	movabsq	$9223372036854775800, %rcx      # imm = 0x7FFFFFFFFFFFFFF8
	andq	%rcx, %rdx
	vxorps	%xmm0, %xmm0, %xmm0
	xorl	%ecx, %ecx
	.p2align	4
.LBB0_9:                                # =>This Inner Loop Header: Depth=1
	vmovss	(%rdi,%rcx,4), %xmm1            # xmm1 = mem[0],zero,zero,zero
	vfmadd231ss	(%rsi,%rcx,4), %xmm1, %xmm0 # xmm0 = (xmm1 * mem) + xmm0
	vmovss	4(%rdi,%rcx,4), %xmm1           # xmm1 = mem[0],zero,zero,zero
	vfmadd231ss	4(%rsi,%rcx,4), %xmm1, %xmm0 # xmm0 = (xmm1 * mem) + xmm0
	vmovss	8(%rdi,%rcx,4), %xmm1           # xmm1 = mem[0],zero,zero,zero
	vfmadd132ss	8(%rsi,%rcx,4), %xmm0, %xmm1 # xmm1 = (xmm1 * mem) + xmm0
	vmovss	12(%rdi,%rcx,4), %xmm0          # xmm0 = mem[0],zero,zero,zero
	vfmadd132ss	12(%rsi,%rcx,4), %xmm1, %xmm0 # xmm0 = (xmm0 * mem) + xmm1
	vmovss	16(%rdi,%rcx,4), %xmm1          # xmm1 = mem[0],zero,zero,zero
	vfmadd132ss	16(%rsi,%rcx,4), %xmm0, %xmm1 # xmm1 = (xmm1 * mem) + xmm0
	vmovss	20(%rdi,%rcx,4), %xmm0          # xmm0 = mem[0],zero,zero,zero
	vfmadd132ss	20(%rsi,%rcx,4), %xmm1, %xmm0 # xmm0 = (xmm0 * mem) + xmm1
	vmovss	24(%rdi,%rcx,4), %xmm1          # xmm1 = mem[0],zero,zero,zero
	vfmadd132ss	24(%rsi,%rcx,4), %xmm0, %xmm1 # xmm1 = (xmm1 * mem) + xmm0
	vmovss	28(%rdi,%rcx,4), %xmm0          # xmm0 = mem[0],zero,zero,zero
	vfmadd132ss	28(%rsi,%rcx,4), %xmm1, %xmm0 # xmm0 = (xmm0 * mem) + xmm1
	addq	$8, %rcx
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
	vmovss	(%rcx,%rsi,4), %xmm1            # xmm1 = mem[0],zero,zero,zero
	vfmadd231ss	(%rdx,%rsi,4), %xmm1, %xmm0 # xmm0 = (xmm1 * mem) + xmm0
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
