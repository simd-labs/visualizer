	.att_syntax
	.file	"mincol_f32.cpp"
	.text
	.globl	_Z10mincol_f32PKfPfll           # -- Begin function _Z10mincol_f32PKfPfll
	.prefalign	4, .Lfunc_end0, nop
	.type	_Z10mincol_f32PKfPfll,@function
_Z10mincol_f32PKfPfll:                  # @_Z10mincol_f32PKfPfll
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN mincol_f32
	#NO_APP
	testq	%rcx, %rcx
	jle	.LBB0_10
# %bb.1:
	pushq	%rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	movl	%edx, %eax
	andl	$7, %eax
	movabsq	$9223372036854775800, %r8       # imm = 0x7FFFFFFFFFFFFFF8
	andq	%rdx, %r8
	movq	%rcx, %r9
	shlq	$5, %r9
	leaq	(,%rcx,4), %r10
	xorl	%r11d, %r11d
	leaq	(%r10,%r10), %rbx
	movq	%rdi, %r14
	jmp	.LBB0_2
	.p2align	4
.LBB0_8:                                #   in Loop: Header=BB0_2 Depth=1
	vmovss	%xmm0, (%rsi,%r11,4)
	incq	%r11
	addq	$4, %r14
	cmpq	%rcx, %r11
	je	.LBB0_9
.LBB0_2:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_12 Depth 2
                                        #     Child Loop BB0_7 Depth 2
	vmovss	(%rdi,%r11,4), %xmm0            # xmm0 = mem[0],zero,zero,zero
	testq	%rdx, %rdx
	jle	.LBB0_8
# %bb.3:                                #   in Loop: Header=BB0_2 Depth=1
	cmpq	$8, %rdx
	jae	.LBB0_11
# %bb.4:                                #   in Loop: Header=BB0_2 Depth=1
	xorl	%r15d, %r15d
	jmp	.LBB0_6
	.p2align	4
.LBB0_11:                               #   in Loop: Header=BB0_2 Depth=1
	movq	%r14, %r12
	xorl	%r15d, %r15d
	.p2align	4
.LBB0_12:                               #   Parent Loop BB0_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	vminss	(%r12), %xmm0, %xmm0
	leaq	(%r12,%r10), %r13
	vminss	(%r12,%rcx,4), %xmm0, %xmm0
	addq	%r10, %r13
	vminss	(%r12,%rcx,8), %xmm0, %xmm0
	vminss	(%r13,%rcx,4), %xmm0, %xmm0
	vminss	(%r13,%rcx,8), %xmm0, %xmm0
	addq	%rbx, %r13
	leaq	(,%rcx,4), %rbp
	addq	%r13, %rbp
	vminss	(%r13,%rcx,4), %xmm0, %xmm0
	vminss	(%r10,%rbp), %xmm0, %xmm0
	addq	%r10, %rbp
	vminss	(%r10,%rbp), %xmm0, %xmm0
	addq	$8, %r15
	addq	%r9, %r12
	cmpq	%r15, %r8
	jne	.LBB0_12
# %bb.5:                                #   in Loop: Header=BB0_2 Depth=1
	testq	%rax, %rax
	je	.LBB0_8
.LBB0_6:                                #   in Loop: Header=BB0_2 Depth=1
	imulq	%r10, %r15
	addq	%r14, %r15
	movq	%rax, %r12
	.p2align	4
.LBB0_7:                                #   Parent Loop BB0_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	vminss	(%r15), %xmm0, %xmm0
	addq	%r10, %r15
	decq	%r12
	jne	.LBB0_7
	jmp	.LBB0_8
.LBB0_9:
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
.LBB0_10:
	#APP
	# LLVM-MCA-END mincol_f32
	#NO_APP
	retq
.Lfunc_end0:
	.size	_Z10mincol_f32PKfPfll, .Lfunc_end0-_Z10mincol_f32PKfPfll
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
