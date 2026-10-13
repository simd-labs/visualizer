	.att_syntax
	.file	"sqrt_f32_loop.cpp"
	.section	.rodata.cst16,"aM",@progbits,16
	.p2align	4, 0x0                          # -- Begin function _Z13sqrt_f32_loopPKfPfl
.LCPI0_0:
	.long	0x3f000000                      # float 0.5
	.long	0x3f000000                      # float 0.5
	.long	0x3f000000                      # float 0.5
	.long	0x3f000000                      # float 0.5
	.section	.rodata.cst4,"aM",@progbits,4
	.p2align	2, 0x0
.LCPI0_1:
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
	cmpq	$4, %rdx
	jae	.LBB0_3
# %bb.2:
	xorl	%eax, %eax
	jmp	.LBB0_6
.LBB0_3:
	movabsq	$9223372036854775804, %rax      # imm = 0x7FFFFFFFFFFFFFFC
	andq	%rdx, %rax
	xorl	%ecx, %ecx
	movaps	.LCPI0_0(%rip), %xmm0           # xmm0 = [5.0E-1,5.0E-1,5.0E-1,5.0E-1]
	.p2align	4
.LBB0_4:                                # =>This Inner Loop Header: Depth=1
	movups	(%rdi,%rcx,4), %xmm1
	movaps	%xmm1, %xmm2
	mulps	%xmm0, %xmm2
	addps	%xmm0, %xmm2
	movaps	%xmm1, %xmm3
	divps	%xmm2, %xmm3
	addps	%xmm2, %xmm3
	mulps	%xmm0, %xmm3
	movaps	%xmm1, %xmm2
	divps	%xmm3, %xmm2
	addps	%xmm3, %xmm2
	mulps	%xmm0, %xmm2
	movaps	%xmm1, %xmm3
	divps	%xmm2, %xmm3
	addps	%xmm2, %xmm3
	mulps	%xmm0, %xmm3
	divps	%xmm3, %xmm1
	addps	%xmm3, %xmm1
	mulps	%xmm0, %xmm1
	movups	%xmm1, (%rsi,%rcx,4)
	addq	$4, %rcx
	cmpq	%rcx, %rax
	jne	.LBB0_4
# %bb.5:
	cmpq	%rax, %rdx
	je	.LBB0_8
.LBB0_6:
	movss	.LCPI0_1(%rip), %xmm0           # xmm0 = [5.0E-1,0.0E+0,0.0E+0,0.0E+0]
	.p2align	4
.LBB0_7:                                # =>This Inner Loop Header: Depth=1
	movss	(%rdi,%rax,4), %xmm1            # xmm1 = mem[0],zero,zero,zero
	movaps	%xmm1, %xmm2
	mulss	%xmm0, %xmm2
	addss	%xmm0, %xmm2
	movaps	%xmm1, %xmm3
	divss	%xmm2, %xmm3
	addss	%xmm2, %xmm3
	mulss	%xmm0, %xmm3
	movaps	%xmm1, %xmm2
	divss	%xmm3, %xmm2
	addss	%xmm3, %xmm2
	mulss	%xmm0, %xmm2
	movaps	%xmm1, %xmm3
	divss	%xmm2, %xmm3
	addss	%xmm2, %xmm3
	mulss	%xmm0, %xmm3
	divss	%xmm3, %xmm1
	addss	%xmm3, %xmm1
	mulss	%xmm0, %xmm1
	movss	%xmm1, (%rsi,%rax,4)
	incq	%rax
	cmpq	%rax, %rdx
	jne	.LBB0_7
.LBB0_8:
	#APP
	# LLVM-MCA-END sqrt_f32_loop
	#NO_APP
	retq
.Lfunc_end0:
	.size	_Z13sqrt_f32_loopPKfPfl, .Lfunc_end0-_Z13sqrt_f32_loopPKfPfl
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
