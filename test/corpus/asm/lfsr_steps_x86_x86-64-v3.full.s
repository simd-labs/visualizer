	.att_syntax
	.file	"lfsr_steps.cpp"
	.text
	.globl	_Z10lfsr_stepsPjl               # -- Begin function _Z10lfsr_stepsPjl
	.prefalign	4, .Lfunc_end0, nop
	.type	_Z10lfsr_stepsPjl,@function
_Z10lfsr_stepsPjl:                      # @_Z10lfsr_stepsPjl
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN lfsr_steps
	#NO_APP
	testq	%rsi, %rsi
	jle	.LBB0_1
# %bb.2:
	movl	%esi, %ecx
	andl	$3, %ecx
	cmpq	$4, %rsi
	jae	.LBB0_7
# %bb.3:
	movl	$44257, %r8d                    # imm = 0xACE1
	xorl	%edx, %edx
	xorl	%eax, %eax
	jmp	.LBB0_5
.LBB0_1:
	xorl	%eax, %eax
	#APP
	# LLVM-MCA-END lfsr_steps
	#NO_APP
	retq
.LBB0_7:
	movabsq	$9223372036854775804, %rax      # imm = 0x7FFFFFFFFFFFFFFC
	andq	%rax, %rsi
	movl	$44257, %r8d                    # imm = 0xACE1
	xorl	%edx, %edx
	xorl	%eax, %eax
	.p2align	4
.LBB0_8:                                # =>This Inner Loop Header: Depth=1
	movl	%r8d, %r9d
	shrl	%r9d
	movl	%r9d, %r10d
	xorl	$46080, %r10d                   # imm = 0xB400
	testb	$1, %r8b
	cmovel	%r9d, %r10d
	movl	%edx, %r9d
	andl	$4, %r9d
	movl	(%rdi,%r9,4), %r8d
	andl	%r10d, %r8d
	addq	%r8, %rax
	movl	%r10d, %r8d
	shrl	%r8d
	movl	%r8d, %r11d
	xorl	$46080, %r11d                   # imm = 0xB400
	testb	$1, %r10b
	cmovel	%r8d, %r11d
	movl	4(%rdi,%r9,4), %r8d
	andl	%r11d, %r8d
	addq	%rax, %r8
	movl	%r11d, %eax
	shrl	%eax
	movl	%eax, %r10d
	xorl	$46080, %r10d                   # imm = 0xB400
	testb	$1, %r11b
	cmovel	%eax, %r10d
	movl	8(%rdi,%r9,4), %r11d
	andl	%r10d, %r11d
	addq	%r8, %r11
	movl	%r10d, %eax
	shrl	%eax
	movl	%eax, %r8d
	xorl	$46080, %r8d                    # imm = 0xB400
	testb	$1, %r10b
	cmovel	%eax, %r8d
	movl	12(%rdi,%r9,4), %eax
	andl	%r8d, %eax
	addq	%r11, %rax
	addq	$4, %rdx
	cmpq	%rdx, %rsi
	jne	.LBB0_8
# %bb.4:
	testq	%rcx, %rcx
	je	.LBB0_6
	.p2align	4
.LBB0_5:                                # =>This Inner Loop Header: Depth=1
	movl	%r8d, %esi
	shrl	%esi
	movl	%r8d, %r9d
	movl	%esi, %r8d
	xorl	$46080, %r8d                    # imm = 0xB400
	testb	$1, %r9b
	cmovel	%esi, %r8d
	movl	%edx, %esi
	andl	$7, %esi
	movl	(%rdi,%rsi,4), %esi
	andl	%r8d, %esi
	addq	%rsi, %rax
	incq	%rdx
	decq	%rcx
	jne	.LBB0_5
.LBB0_6:
	#APP
	# LLVM-MCA-END lfsr_steps
	#NO_APP
	retq
.Lfunc_end0:
	.size	_Z10lfsr_stepsPjl, .Lfunc_end0-_Z10lfsr_stepsPjl
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
