	.att_syntax
	.file	"unroll4_scale.cpp"
	.text
	.globl	_Z13unroll4_scalePKfPflf        # -- Begin function _Z13unroll4_scalePKfPflf
	.prefalign	4, .Lfunc_end0, nop
	.type	_Z13unroll4_scalePKfPflf,@function
_Z13unroll4_scalePKfPflf:               # @_Z13unroll4_scalePKfPflf
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN unroll4_scale
	#NO_APP
	cmpq	$4, %rdx
	jl	.LBB0_1
# %bb.5:
	leaq	-4(%rdx), %rcx
	shrq	$2, %rcx
	je	.LBB0_6
# %bb.7:
	incq	%rcx
	movq	%rcx, %r8
	andq	$-2, %r8
	leaq	(,%r8,4), %rax
	movsldup	%xmm0, %xmm1                    # xmm1 = xmm0[0,0,2,2]
	xorl	%r9d, %r9d
	movddup	%xmm1, %xmm1                    # xmm1 = xmm1[0,0]
	movq	%r8, %r10
	.p2align	4
.LBB0_8:                                # =>This Inner Loop Header: Depth=1
	movss	(%rdi,%r9), %xmm2               # xmm2 = mem[0],zero,zero,zero
	movss	4(%rdi,%r9), %xmm3              # xmm3 = mem[0],zero,zero,zero
	movss	8(%rdi,%r9), %xmm4              # xmm4 = mem[0],zero,zero,zero
	insertps	$16, 16(%rdi,%r9), %xmm2        # xmm2 = xmm2[0],mem[0],xmm2[2,3]
	insertps	$16, 20(%rdi,%r9), %xmm3        # xmm3 = xmm3[0],mem[0],xmm3[2,3]
	movss	12(%rdi,%r9), %xmm5             # xmm5 = mem[0],zero,zero,zero
	movlhps	%xmm3, %xmm2                    # xmm2 = xmm2[0],xmm3[0]
	insertps	$16, 24(%rdi,%r9), %xmm4        # xmm4 = xmm4[0],mem[0],xmm4[2,3]
	insertps	$16, 28(%rdi,%r9), %xmm5        # xmm5 = xmm5[0],mem[0],xmm5[2,3]
	movlhps	%xmm5, %xmm4                    # xmm4 = xmm4[0],xmm5[0]
	mulps	%xmm1, %xmm2
	mulps	%xmm1, %xmm4
	movaps	%xmm2, %xmm3
	shufps	$136, %xmm4, %xmm3              # xmm3 = xmm3[0,2],xmm4[0,2]
	shufps	$221, %xmm4, %xmm2              # xmm2 = xmm2[1,3],xmm4[1,3]
	movups	%xmm2, 16(%rsi,%r9)
	movups	%xmm3, (%rsi,%r9)
	addq	$32, %r9
	addq	$-2, %r10
	jne	.LBB0_8
# %bb.9:
	cmpq	%r8, %rcx
	jne	.LBB0_10
	jmp	.LBB0_2
.LBB0_1:
	xorl	%eax, %eax
	jmp	.LBB0_2
.LBB0_6:
	xorl	%eax, %eax
.LBB0_10:
	movaps	%xmm0, %xmm1
	shufps	$0, %xmm0, %xmm1                # xmm1 = xmm1[0,0],xmm0[0,0]
	movq	%rax, %rcx
	.p2align	4
.LBB0_11:                               # =>This Inner Loop Header: Depth=1
	movups	(%rdi,%rcx,4), %xmm2
	mulps	%xmm1, %xmm2
	movups	%xmm2, (%rsi,%rcx,4)
	leaq	4(%rcx), %rax
	addq	$7, %rcx
	cmpq	%rdx, %rcx
	movq	%rax, %rcx
	jl	.LBB0_11
.LBB0_2:
	movq	%rdx, %r8
	subq	%rax, %r8
	jle	.LBB0_16
# %bb.3:
	cmpq	$8, %r8
	jae	.LBB0_12
# %bb.4:
	movq	%rax, %rcx
	jmp	.LBB0_15
.LBB0_12:
	movq	%r8, %r9
	andq	$-8, %r9
	leaq	(%rax,%r9), %rcx
	movaps	%xmm0, %xmm1
	shufps	$0, %xmm0, %xmm1                # xmm1 = xmm1[0,0],xmm0[0,0]
	leaq	(%rsi,%rax,4), %r10
	addq	$16, %r10
	leaq	(%rdi,%rax,4), %rax
	addq	$16, %rax
	xorl	%r11d, %r11d
	.p2align	4
.LBB0_13:                               # =>This Inner Loop Header: Depth=1
	movups	-16(%rax,%r11,4), %xmm2
	movups	(%rax,%r11,4), %xmm3
	mulps	%xmm1, %xmm2
	mulps	%xmm1, %xmm3
	movups	%xmm2, -16(%r10,%r11,4)
	movups	%xmm3, (%r10,%r11,4)
	addq	$8, %r11
	cmpq	%r11, %r9
	jne	.LBB0_13
# %bb.14:
	cmpq	%r9, %r8
	je	.LBB0_16
	.p2align	4
.LBB0_15:                               # =>This Inner Loop Header: Depth=1
	movss	(%rdi,%rcx,4), %xmm1            # xmm1 = mem[0],zero,zero,zero
	mulss	%xmm0, %xmm1
	movss	%xmm1, (%rsi,%rcx,4)
	incq	%rcx
	cmpq	%rcx, %rdx
	jne	.LBB0_15
.LBB0_16:
	#APP
	# LLVM-MCA-END unroll4_scale
	#NO_APP
	retq
.Lfunc_end0:
	.size	_Z13unroll4_scalePKfPflf, .Lfunc_end0-_Z13unroll4_scalePKfPflf
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
