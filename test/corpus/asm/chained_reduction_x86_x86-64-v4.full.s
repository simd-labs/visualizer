	.att_syntax
	.file	"chained_reduction.cpp"
	.section	.rodata.cst4,"aM",@progbits,4
	.p2align	2, 0x0                          # -- Begin function _Z17chained_reductionPKfl
.LCPI0_0:
	.long	0x3f800000                      # float 1
	.text
	.globl	_Z17chained_reductionPKfl
	.prefalign	4, .Lfunc_end0, nop
	.type	_Z17chained_reductionPKfl,@function
_Z17chained_reductionPKfl:              # @_Z17chained_reductionPKfl
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN chained_reduction
	#NO_APP
	testq	%rsi, %rsi
	jle	.LBB0_1
# %bb.2:
	movl	%esi, %eax
	andl	$7, %eax
	vmovss	.LCPI0_0(%rip), %xmm1           # xmm1 = [1.0E+0,0.0E+0,0.0E+0,0.0E+0]
	cmpq	$8, %rsi
	jae	.LBB0_8
# %bb.3:
	xorl	%ecx, %ecx
	vmovaps	%xmm1, %xmm0
	jmp	.LBB0_5
.LBB0_1:
	vmovss	.LCPI0_0(%rip), %xmm0           # xmm0 = [1.0E+0,0.0E+0,0.0E+0,0.0E+0]
	#APP
	# LLVM-MCA-END chained_reduction
	#NO_APP
	retq
.LBB0_8:
	movabsq	$9223372036854775800, %rcx      # imm = 0x7FFFFFFFFFFFFFF8
	andq	%rcx, %rsi
	vmovss	.LCPI0_0(%rip), %xmm2           # xmm2 = [1.0E+0,0.0E+0,0.0E+0,0.0E+0]
	xorl	%ecx, %ecx
	vmovaps	%xmm2, %xmm0
	.p2align	4
.LBB0_9:                                # =>This Inner Loop Header: Depth=1
	vmovss	(%rdi,%rcx,4), %xmm3            # xmm3 = mem[0],zero,zero,zero
	vmovss	4(%rdi,%rcx,4), %xmm4           # xmm4 = mem[0],zero,zero,zero
	vmulss	%xmm3, %xmm0, %xmm5
	vfmadd213ss	%xmm2, %xmm0, %xmm3     # xmm3 = (xmm0 * xmm3) + xmm2
	vmulss	%xmm3, %xmm5, %xmm0
	vmulss	%xmm4, %xmm0, %xmm3
	vfmadd213ss	%xmm2, %xmm0, %xmm4     # xmm4 = (xmm0 * xmm4) + xmm2
	vmulss	%xmm4, %xmm3, %xmm0
	vmovss	8(%rdi,%rcx,4), %xmm3           # xmm3 = mem[0],zero,zero,zero
	vmulss	%xmm3, %xmm0, %xmm4
	vfmadd213ss	%xmm2, %xmm0, %xmm3     # xmm3 = (xmm0 * xmm3) + xmm2
	vmulss	%xmm3, %xmm4, %xmm0
	vmovss	12(%rdi,%rcx,4), %xmm3          # xmm3 = mem[0],zero,zero,zero
	vmulss	%xmm3, %xmm0, %xmm4
	vfmadd213ss	%xmm2, %xmm0, %xmm3     # xmm3 = (xmm0 * xmm3) + xmm2
	vmulss	%xmm3, %xmm4, %xmm0
	vmovss	16(%rdi,%rcx,4), %xmm3          # xmm3 = mem[0],zero,zero,zero
	vmulss	%xmm3, %xmm0, %xmm4
	vfmadd213ss	%xmm2, %xmm0, %xmm3     # xmm3 = (xmm0 * xmm3) + xmm2
	vmulss	%xmm3, %xmm4, %xmm0
	vmovss	20(%rdi,%rcx,4), %xmm3          # xmm3 = mem[0],zero,zero,zero
	vmulss	%xmm3, %xmm0, %xmm4
	vfmadd213ss	%xmm2, %xmm0, %xmm3     # xmm3 = (xmm0 * xmm3) + xmm2
	vmulss	%xmm3, %xmm4, %xmm0
	vmovss	24(%rdi,%rcx,4), %xmm3          # xmm3 = mem[0],zero,zero,zero
	vmulss	%xmm3, %xmm0, %xmm4
	vfmadd213ss	%xmm2, %xmm0, %xmm3     # xmm3 = (xmm0 * xmm3) + xmm2
	vmovss	28(%rdi,%rcx,4), %xmm0          # xmm0 = mem[0],zero,zero,zero
	vmulss	%xmm3, %xmm4, %xmm3
	vmulss	%xmm0, %xmm3, %xmm4
	vfmadd213ss	%xmm2, %xmm3, %xmm0     # xmm0 = (xmm3 * xmm0) + xmm2
	vmulss	%xmm0, %xmm4, %xmm0
	addq	$8, %rcx
	cmpq	%rcx, %rsi
	jne	.LBB0_9
# %bb.4:
	testq	%rax, %rax
	je	.LBB0_7
.LBB0_5:
	leaq	(%rdi,%rcx,4), %rcx
	xorl	%edx, %edx
	.p2align	4
.LBB0_6:                                # =>This Inner Loop Header: Depth=1
	vmovss	(%rcx,%rdx,4), %xmm2            # xmm2 = mem[0],zero,zero,zero
	vmulss	%xmm2, %xmm0, %xmm3
	vfmadd213ss	%xmm1, %xmm0, %xmm2     # xmm2 = (xmm0 * xmm2) + xmm1
	vmulss	%xmm2, %xmm3, %xmm0
	incq	%rdx
	cmpq	%rdx, %rax
	jne	.LBB0_6
.LBB0_7:
	#APP
	# LLVM-MCA-END chained_reduction
	#NO_APP
	retq
.Lfunc_end0:
	.size	_Z17chained_reductionPKfl, .Lfunc_end0-_Z17chained_reductionPKfl
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
