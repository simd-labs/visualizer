	.att_syntax
	.file	"saxpy.cpp"
	.text
	.globl	_Z5saxpyfPKfPfl                 # -- Begin function _Z5saxpyfPKfPfl
	.prefalign	4, .Lfunc_end0, nop
	.type	_Z5saxpyfPKfPfl,@function
_Z5saxpyfPKfPfl:                        # @_Z5saxpyfPKfPfl
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN saxpy
	#NO_APP
	testq	%rdx, %rdx
	jle	.LBB0_13
# %bb.1:
	cmpq	$4, %rdx
	jae	.LBB0_4
# %bb.2:
	xorl	%eax, %eax
	jmp	.LBB0_3
.LBB0_4:
	movabsq	$9223372036854775776, %rcx      # imm = 0x7FFFFFFFFFFFFFE0
	cmpq	$32, %rdx
	jae	.LBB0_6
# %bb.5:
	xorl	%eax, %eax
	jmp	.LBB0_10
.LBB0_6:
	movq	%rdx, %rax
	andq	%rcx, %rax
	vbroadcastss	%xmm0, %ymm1
	xorl	%r8d, %r8d
	.p2align	4
.LBB0_7:                                # =>This Inner Loop Header: Depth=1
	vmovups	(%rdi,%r8,4), %ymm2
	vmovups	32(%rdi,%r8,4), %ymm3
	vmovups	64(%rdi,%r8,4), %ymm4
	vmovups	96(%rdi,%r8,4), %ymm5
	vfmadd213ps	(%rsi,%r8,4), %ymm1, %ymm2 # ymm2 = (ymm1 * ymm2) + mem
	vfmadd213ps	32(%rsi,%r8,4), %ymm1, %ymm3 # ymm3 = (ymm1 * ymm3) + mem
	vfmadd213ps	64(%rsi,%r8,4), %ymm1, %ymm4 # ymm4 = (ymm1 * ymm4) + mem
	vfmadd213ps	96(%rsi,%r8,4), %ymm1, %ymm5 # ymm5 = (ymm1 * ymm5) + mem
	vmovups	%ymm2, (%rsi,%r8,4)
	vmovups	%ymm3, 32(%rsi,%r8,4)
	vmovups	%ymm4, 64(%rsi,%r8,4)
	vmovups	%ymm5, 96(%rsi,%r8,4)
	addq	$32, %r8
	cmpq	%r8, %rax
	jne	.LBB0_7
# %bb.8:
	cmpq	%rax, %rdx
	je	.LBB0_13
# %bb.9:
	testb	$28, %dl
	je	.LBB0_3
.LBB0_10:
	movq	%rax, %r8
	addq	$28, %rcx
	movq	%rcx, %rax
	andq	%rdx, %rax
	vbroadcastss	%xmm0, %xmm1
	.p2align	4
.LBB0_11:                               # =>This Inner Loop Header: Depth=1
	vmovups	(%rdi,%r8,4), %xmm2
	vfmadd213ps	(%rsi,%r8,4), %xmm1, %xmm2 # xmm2 = (xmm1 * xmm2) + mem
	vmovups	%xmm2, (%rsi,%r8,4)
	addq	$4, %r8
	cmpq	%r8, %rax
	jne	.LBB0_11
	jmp	.LBB0_12
.LBB0_3:
	vmovss	(%rdi,%rax,4), %xmm1            # xmm1 = mem[0],zero,zero,zero
	vfmadd213ss	(%rsi,%rax,4), %xmm0, %xmm1 # xmm1 = (xmm0 * xmm1) + mem
	vmovss	%xmm1, (%rsi,%rax,4)
	incq	%rax
.LBB0_12:
	cmpq	%rax, %rdx
	jne	.LBB0_3
.LBB0_13:
	#APP
	# LLVM-MCA-END saxpy
	#NO_APP
	vzeroupper
	retq
.Lfunc_end0:
	.size	_Z5saxpyfPKfPfl, .Lfunc_end0-_Z5saxpyfPKfPfl
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
