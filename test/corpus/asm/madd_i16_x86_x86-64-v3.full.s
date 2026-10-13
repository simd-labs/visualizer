	.att_syntax
	.file	"madd_i16.cpp"
	.text
	.globl	_Z8madd_i16PKsS0_Pil            # -- Begin function _Z8madd_i16PKsS0_Pil
	.prefalign	4, .Lfunc_end0, nop
	.type	_Z8madd_i16PKsS0_Pil,@function
_Z8madd_i16PKsS0_Pil:                   # @_Z8madd_i16PKsS0_Pil
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN madd_i16
	#NO_APP
	testq	%rcx, %rcx
	jle	.LBB0_7
# %bb.1:
	cmpq	$15, %rcx
	jae	.LBB0_3
# %bb.2:
	xorl	%eax, %eax
	jmp	.LBB0_6
.LBB0_3:
	leaq	-1(%rcx), %r8
	shrq	%r8
	incq	%r8
	movq	%r8, %r9
	andq	$-8, %r9
	leaq	(%r9,%r9), %rax
	xorl	%r10d, %r10d
	.p2align	4
.LBB0_4:                                # =>This Inner Loop Header: Depth=1
	vmovdqu	(%rsi,%r10,4), %ymm0
	vpmaddwd	(%rdi,%r10,4), %ymm0, %ymm0
	vmovdqu	%ymm0, (%rdx,%r10,4)
	addq	$8, %r10
	cmpq	%r10, %r9
	jne	.LBB0_4
# %bb.5:
	cmpq	%r9, %r8
	je	.LBB0_7
	.p2align	4
.LBB0_6:                                # =>This Inner Loop Header: Depth=1
	movswl	(%rdi,%rax,2), %r8d
	movswl	(%rsi,%rax,2), %r9d
	imull	%r8d, %r9d
	movswl	2(%rdi,%rax,2), %r8d
	movswl	2(%rsi,%rax,2), %r10d
	imull	%r8d, %r10d
	addl	%r9d, %r10d
	movl	%r10d, (%rdx,%rax,2)
	addq	$2, %rax
	cmpq	%rcx, %rax
	jl	.LBB0_6
.LBB0_7:
	#APP
	# LLVM-MCA-END madd_i16
	#NO_APP
	vzeroupper
	retq
.Lfunc_end0:
	.size	_Z8madd_i16PKsS0_Pil, .Lfunc_end0-_Z8madd_i16PKsS0_Pil
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
