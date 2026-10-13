	.att_syntax
	.file	"xor_bytes.cpp"
	.text
	.globl	_Z9xor_bytesPKhS0_Phl           # -- Begin function _Z9xor_bytesPKhS0_Phl
	.prefalign	4, .Lfunc_end0, nop
	.type	_Z9xor_bytesPKhS0_Phl,@function
_Z9xor_bytesPKhS0_Phl:                  # @_Z9xor_bytesPKhS0_Phl
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN xor_bytes
	#NO_APP
	testq	%rcx, %rcx
	jle	.LBB0_13
# %bb.1:
	cmpq	$8, %rcx
	jae	.LBB0_4
# %bb.2:
	xorl	%eax, %eax
	jmp	.LBB0_3
.LBB0_4:
	movabsq	$9223372036854775680, %r8       # imm = 0x7FFFFFFFFFFFFF80
	cmpq	$128, %rcx
	jae	.LBB0_6
# %bb.5:
	xorl	%eax, %eax
	jmp	.LBB0_10
.LBB0_6:
	movq	%rcx, %rax
	andq	%r8, %rax
	xorl	%r9d, %r9d
	.p2align	4
.LBB0_7:                                # =>This Inner Loop Header: Depth=1
	vmovups	(%rsi,%r9), %ymm0
	vmovups	32(%rsi,%r9), %ymm1
	vmovups	64(%rsi,%r9), %ymm2
	vmovups	96(%rsi,%r9), %ymm3
	vxorps	(%rdi,%r9), %ymm0, %ymm0
	vxorps	32(%rdi,%r9), %ymm1, %ymm1
	vxorps	64(%rdi,%r9), %ymm2, %ymm2
	vxorps	96(%rdi,%r9), %ymm3, %ymm3
	vmovups	%ymm0, (%rdx,%r9)
	vmovups	%ymm1, 32(%rdx,%r9)
	vmovups	%ymm2, 64(%rdx,%r9)
	vmovups	%ymm3, 96(%rdx,%r9)
	subq	$-128, %r9
	cmpq	%r9, %rax
	jne	.LBB0_7
# %bb.8:
	cmpq	%rax, %rcx
	je	.LBB0_13
# %bb.9:
	testb	$120, %cl
	je	.LBB0_3
.LBB0_10:
	movq	%rax, %r9
	addq	$120, %r8
	movq	%r8, %rax
	andq	%rcx, %rax
	.p2align	4
.LBB0_11:                               # =>This Inner Loop Header: Depth=1
	movq	(%rsi,%r9), %r8
	xorq	(%rdi,%r9), %r8
	movq	%r8, (%rdx,%r9)
	addq	$8, %r9
	cmpq	%r9, %rax
	jne	.LBB0_11
	jmp	.LBB0_12
.LBB0_3:
	movzbl	(%rsi,%rax), %r8d
	xorb	(%rdi,%rax), %r8b
	movb	%r8b, (%rdx,%rax)
	incq	%rax
.LBB0_12:
	cmpq	%rax, %rcx
	jne	.LBB0_3
.LBB0_13:
	#APP
	# LLVM-MCA-END xor_bytes
	#NO_APP
	vzeroupper
	retq
.Lfunc_end0:
	.size	_Z9xor_bytesPKhS0_Phl, .Lfunc_end0-_Z9xor_bytesPKhS0_Phl
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
