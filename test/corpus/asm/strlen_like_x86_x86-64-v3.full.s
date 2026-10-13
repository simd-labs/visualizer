	.att_syntax
	.file	"strlen_like.cpp"
	.text
	.globl	_Z11strlen_likePKclPl           # -- Begin function _Z11strlen_likePKclPl
	.prefalign	4, .Lfunc_end0, nop
	.type	_Z11strlen_likePKclPl,@function
_Z11strlen_likePKclPl:                  # @_Z11strlen_likePKclPl
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN strlen_like
	#NO_APP
	xorl	%eax, %eax
	testq	%rsi, %rsi
	jle	.LBB0_4
	.p2align	4
.LBB0_1:                                # =>This Inner Loop Header: Depth=1
	cmpb	$0, (%rdi,%rax)
	je	.LBB0_4
# %bb.2:                                #   in Loop: Header=BB0_1 Depth=1
	incq	%rax
	cmpq	%rax, %rsi
	jne	.LBB0_1
# %bb.3:
	movq	%rsi, %rax
.LBB0_4:
	#APP
	# LLVM-MCA-END strlen_like
	#NO_APP
	movq	%rax, (%rdx)
	retq
.Lfunc_end0:
	.size	_Z11strlen_likePKclPl, .Lfunc_end0-_Z11strlen_likePKclPl
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
