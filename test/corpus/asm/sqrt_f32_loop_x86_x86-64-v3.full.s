	.att_syntax
	.file	"sqrt_f32_loop.cpp"
	.section	.rodata.cst4,"aM",@progbits,4
	.p2align	2, 0x0                          # -- Begin function _Z13sqrt_f32_loopPKfPfl
.LCPI0_0:
	.long	0x3f000000                      # float 0.5
	.text
	.globl	_Z13sqrt_f32_loopPKfPfl
	.prefalign	4, .Lfunc_end0, nop
	.type	_Z13sqrt_f32_loopPKfPfl,@function
_Z13sqrt_f32_loopPKfPfl:                # @_Z13sqrt_f32_loopPKfPfl
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN sqrt_f32_loop
	#NO_APP
	testq	%rdx, %rdx
	jle	.LBB0_8
# %bb.1:
	cmpq	$8, %rdx
	jae	.LBB0_3
# %bb.2:
	xorl	%eax, %eax
	jmp	.LBB0_6
.LBB0_3:
	movabsq	$9223372036854775800, %rax      # imm = 0x7FFFFFFFFFFFFFF8
	andq	%rdx, %rax
	xorl	%ecx, %ecx
	vbroadcastss	.LCPI0_0(%rip), %ymm0   # ymm0 = [5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1]
	.p2align	4
.LBB0_4:                                # =>This Inner Loop Header: Depth=1
	vmovups	(%rdi,%rcx,4), %ymm1
	vmovaps	%ymm0, %ymm2
	vfmadd213ps	%ymm0, %ymm1, %ymm2     # ymm2 = (ymm1 * ymm2) + ymm0
	vdivps	%ymm2, %ymm1, %ymm3
	vaddps	%ymm3, %ymm2, %ymm2
	vmulps	%ymm0, %ymm2, %ymm2
	vdivps	%ymm2, %ymm1, %ymm3
	vaddps	%ymm3, %ymm2, %ymm2
	vmulps	%ymm0, %ymm2, %ymm2
	vdivps	%ymm2, %ymm1, %ymm3
	vaddps	%ymm3, %ymm2, %ymm2
	vmulps	%ymm0, %ymm2, %ymm2
	vdivps	%ymm2, %ymm1, %ymm1
	vaddps	%ymm1, %ymm2, %ymm1
	vmulps	%ymm0, %ymm1, %ymm1
	vmovups	%ymm1, (%rsi,%rcx,4)
	addq	$8, %rcx
	cmpq	%rcx, %rax
	jne	.LBB0_4
# %bb.5:
	cmpq	%rax, %rdx
	je	.LBB0_8
.LBB0_6:
	vmovss	.LCPI0_0(%rip), %xmm0           # xmm0 = [5.0E-1,0.0E+0,0.0E+0,0.0E+0]
	.p2align	4
.LBB0_7:                                # =>This Inner Loop Header: Depth=1
	vmovss	(%rdi,%rax,4), %xmm1            # xmm1 = mem[0],zero,zero,zero
	vmovaps	%xmm0, %xmm2
	vfmadd213ss	%xmm0, %xmm1, %xmm2     # xmm2 = (xmm1 * xmm2) + xmm0
	vdivss	%xmm2, %xmm1, %xmm3
	vaddss	%xmm3, %xmm2, %xmm2
	vmulss	%xmm0, %xmm2, %xmm2
	vdivss	%xmm2, %xmm1, %xmm3
	vaddss	%xmm3, %xmm2, %xmm2
	vmulss	%xmm0, %xmm2, %xmm2
	vdivss	%xmm2, %xmm1, %xmm3
	vaddss	%xmm3, %xmm2, %xmm2
	vmulss	%xmm0, %xmm2, %xmm2
	vdivss	%xmm2, %xmm1, %xmm1
	vaddss	%xmm1, %xmm2, %xmm1
	vmulss	%xmm0, %xmm1, %xmm1
	vmovss	%xmm1, (%rsi,%rax,4)
	incq	%rax
	cmpq	%rax, %rdx
	jne	.LBB0_7
.LBB0_8:
	#APP
	# LLVM-MCA-END sqrt_f32_loop
	#NO_APP
	vzeroupper
	retq
.Lfunc_end0:
	.size	_Z13sqrt_f32_loopPKfPfl, .Lfunc_end0-_Z13sqrt_f32_loopPKfPfl
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
