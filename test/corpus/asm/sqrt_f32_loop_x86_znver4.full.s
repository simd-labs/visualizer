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
	jle	.LBB0_14
# %bb.1:
	cmpq	$4, %rdx
	jae	.LBB0_3
# %bb.2:
	xorl	%eax, %eax
	jmp	.LBB0_12
.LBB0_3:
	movabsq	$9223372036854775792, %rcx      # imm = 0x7FFFFFFFFFFFFFF0
	cmpq	$16, %rdx
	jae	.LBB0_5
# %bb.4:
	xorl	%eax, %eax
	jmp	.LBB0_9
.LBB0_5:
	vbroadcastss	.LCPI0_0(%rip), %zmm0   # zmm0 = [5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1]
	movq	%rdx, %rax
	andq	%rcx, %rax
	xorl	%r8d, %r8d
	.p2align	4
.LBB0_6:                                # =>This Inner Loop Header: Depth=1
	vmovups	(%rdi,%r8,4), %zmm1
	vmovaps	%zmm0, %zmm2
	vfmadd213ps	%zmm0, %zmm1, %zmm2     # zmm2 = (zmm1 * zmm2) + zmm0
	vdivps	%zmm2, %zmm1, %zmm3
	vaddps	%zmm3, %zmm2, %zmm2
	vmulps	%zmm0, %zmm2, %zmm2
	vdivps	%zmm2, %zmm1, %zmm3
	vaddps	%zmm3, %zmm2, %zmm2
	vmulps	%zmm0, %zmm2, %zmm2
	vdivps	%zmm2, %zmm1, %zmm3
	vaddps	%zmm3, %zmm2, %zmm2
	vmulps	%zmm0, %zmm2, %zmm2
	vdivps	%zmm2, %zmm1, %zmm1
	vaddps	%zmm1, %zmm2, %zmm1
	vmulps	%zmm0, %zmm1, %zmm1
	vmovups	%zmm1, (%rsi,%r8,4)
	addq	$16, %r8
	cmpq	%r8, %rax
	jne	.LBB0_6
# %bb.7:
	cmpq	%rax, %rdx
	je	.LBB0_14
# %bb.8:
	testb	$12, %dl
	je	.LBB0_12
.LBB0_9:
	vbroadcastss	.LCPI0_0(%rip), %xmm0   # xmm0 = [5.0E-1,5.0E-1,5.0E-1,5.0E-1]
	addq	$12, %rcx
	movq	%rax, %r8
	movq	%rcx, %rax
	andq	%rdx, %rax
	.p2align	4
.LBB0_10:                               # =>This Inner Loop Header: Depth=1
	vmovups	(%rdi,%r8,4), %xmm1
	vmovaps	%xmm0, %xmm2
	vfmadd213ps	%xmm0, %xmm1, %xmm2     # xmm2 = (xmm1 * xmm2) + xmm0
	vdivps	%xmm2, %xmm1, %xmm3
	vaddps	%xmm3, %xmm2, %xmm2
	vmulps	%xmm0, %xmm2, %xmm2
	vdivps	%xmm2, %xmm1, %xmm3
	vaddps	%xmm3, %xmm2, %xmm2
	vmulps	%xmm0, %xmm2, %xmm2
	vdivps	%xmm2, %xmm1, %xmm3
	vaddps	%xmm3, %xmm2, %xmm2
	vmulps	%xmm0, %xmm2, %xmm2
	vdivps	%xmm2, %xmm1, %xmm1
	vaddps	%xmm1, %xmm2, %xmm1
	vmulps	%xmm0, %xmm1, %xmm1
	vmovups	%xmm1, (%rsi,%r8,4)
	addq	$4, %r8
	cmpq	%r8, %rax
	jne	.LBB0_10
# %bb.11:
	cmpq	%rax, %rdx
	je	.LBB0_14
.LBB0_12:
	vmovss	.LCPI0_0(%rip), %xmm0           # xmm0 = [5.0E-1,0.0E+0,0.0E+0,0.0E+0]
	.p2align	4
.LBB0_13:                               # =>This Inner Loop Header: Depth=1
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
	jne	.LBB0_13
.LBB0_14:
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
