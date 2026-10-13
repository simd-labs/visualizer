	.att_syntax
	.file	"popcount_u64.cpp"
	.section	.rodata.cst32,"aM",@progbits,32
	.p2align	5, 0x0                          # -- Begin function _Z12popcount_u64PKmPjl
.LCPI0_0:
	.zero	32,15
.LCPI0_1:
	.byte	0                               # 0x0
	.byte	1                               # 0x1
	.byte	1                               # 0x1
	.byte	2                               # 0x2
	.byte	1                               # 0x1
	.byte	2                               # 0x2
	.byte	2                               # 0x2
	.byte	3                               # 0x3
	.byte	1                               # 0x1
	.byte	2                               # 0x2
	.byte	2                               # 0x2
	.byte	3                               # 0x3
	.byte	2                               # 0x2
	.byte	3                               # 0x3
	.byte	3                               # 0x3
	.byte	4                               # 0x4
	.byte	0                               # 0x0
	.byte	1                               # 0x1
	.byte	1                               # 0x1
	.byte	2                               # 0x2
	.byte	1                               # 0x1
	.byte	2                               # 0x2
	.byte	2                               # 0x2
	.byte	3                               # 0x3
	.byte	1                               # 0x1
	.byte	2                               # 0x2
	.byte	2                               # 0x2
	.byte	3                               # 0x3
	.byte	2                               # 0x2
	.byte	3                               # 0x3
	.byte	3                               # 0x3
	.byte	4                               # 0x4
	.section	.rodata.cst4,"aM",@progbits,4
	.p2align	2, 0x0
.LCPI0_2:
	.zero	4,15
	.section	.rodata.cst16,"aM",@progbits,16
	.p2align	4, 0x0
.LCPI0_3:
	.byte	0                               # 0x0
	.byte	1                               # 0x1
	.byte	1                               # 0x1
	.byte	2                               # 0x2
	.byte	1                               # 0x1
	.byte	2                               # 0x2
	.byte	2                               # 0x2
	.byte	3                               # 0x3
	.byte	1                               # 0x1
	.byte	2                               # 0x2
	.byte	2                               # 0x2
	.byte	3                               # 0x3
	.byte	2                               # 0x2
	.byte	3                               # 0x3
	.byte	3                               # 0x3
	.byte	4                               # 0x4
	.text
	.globl	_Z12popcount_u64PKmPjl
	.prefalign	4, .Lfunc_end0, nop
	.type	_Z12popcount_u64PKmPjl,@function
_Z12popcount_u64PKmPjl:                 # @_Z12popcount_u64PKmPjl
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN popcount_u64
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
	movabsq	$9223372036854775792, %rcx      # imm = 0x7FFFFFFFFFFFFFF0
	cmpq	$16, %rdx
	jae	.LBB0_6
# %bb.5:
	xorl	%eax, %eax
	jmp	.LBB0_10
.LBB0_6:
	movq	%rdx, %rax
	andq	%rcx, %rax
	xorl	%r8d, %r8d
	vpbroadcastd	.LCPI0_2(%rip), %ymm0   # ymm0 = [15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15]
	vbroadcasti128	.LCPI0_3(%rip), %ymm1   # ymm1 = [0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4,0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4]
                                        # ymm1 = mem[0,1,0,1]
	vpxor	%xmm2, %xmm2, %xmm2
	.p2align	4
.LBB0_7:                                # =>This Inner Loop Header: Depth=1
	vmovdqu	(%rdi,%r8,8), %ymm3
	vmovdqu	32(%rdi,%r8,8), %ymm4
	vmovdqu	64(%rdi,%r8,8), %ymm5
	vmovdqu	96(%rdi,%r8,8), %ymm6
	vpand	%ymm0, %ymm3, %ymm7
	vpshufb	%ymm7, %ymm1, %ymm7
	vpsrlw	$4, %ymm3, %ymm3
	vpand	%ymm0, %ymm3, %ymm3
	vpshufb	%ymm3, %ymm1, %ymm3
	vpaddb	%ymm7, %ymm3, %ymm3
	vpsadbw	%ymm2, %ymm3, %ymm3
	vpand	%ymm0, %ymm4, %ymm7
	vpshufb	%ymm7, %ymm1, %ymm7
	vpsrlw	$4, %ymm4, %ymm4
	vpand	%ymm0, %ymm4, %ymm4
	vpshufb	%ymm4, %ymm1, %ymm4
	vpaddb	%ymm7, %ymm4, %ymm4
	vpsadbw	%ymm2, %ymm4, %ymm4
	vpand	%ymm0, %ymm5, %ymm7
	vpshufb	%ymm7, %ymm1, %ymm7
	vpsrlw	$4, %ymm5, %ymm5
	vpand	%ymm0, %ymm5, %ymm5
	vpshufb	%ymm5, %ymm1, %ymm5
	vpaddb	%ymm7, %ymm5, %ymm5
	vpsadbw	%ymm2, %ymm5, %ymm5
	vpand	%ymm0, %ymm6, %ymm7
	vpshufb	%ymm7, %ymm1, %ymm7
	vpsrlw	$4, %ymm6, %ymm6
	vpand	%ymm0, %ymm6, %ymm6
	vpshufb	%ymm6, %ymm1, %ymm6
	vpaddb	%ymm7, %ymm6, %ymm6
	vpmovqd	%ymm3, (%rsi,%r8,4)
	vpmovqd	%ymm4, 16(%rsi,%r8,4)
	vpmovqd	%ymm5, 32(%rsi,%r8,4)
	vpsadbw	%ymm2, %ymm6, %ymm3
	vpmovqd	%ymm3, 48(%rsi,%r8,4)
	addq	$16, %r8
	cmpq	%r8, %rax
	jne	.LBB0_7
# %bb.8:
	cmpq	%rax, %rdx
	je	.LBB0_13
# %bb.9:
	testb	$12, %dl
	je	.LBB0_3
.LBB0_10:
	movq	%rax, %r8
	addq	$12, %rcx
	movq	%rcx, %rax
	andq	%rdx, %rax
	vpbroadcastd	.LCPI0_2(%rip), %ymm0   # ymm0 = [15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15]
	vbroadcasti128	.LCPI0_3(%rip), %ymm1   # ymm1 = [0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4,0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4]
                                        # ymm1 = mem[0,1,0,1]
	vpxor	%xmm2, %xmm2, %xmm2
	.p2align	4
.LBB0_11:                               # =>This Inner Loop Header: Depth=1
	vmovdqu	(%rdi,%r8,8), %ymm3
	vpand	%ymm0, %ymm3, %ymm4
	vpshufb	%ymm4, %ymm1, %ymm4
	vpsrlw	$4, %ymm3, %ymm3
	vpand	%ymm0, %ymm3, %ymm3
	vpshufb	%ymm3, %ymm1, %ymm3
	vpaddb	%ymm4, %ymm3, %ymm3
	vpsadbw	%ymm2, %ymm3, %ymm3
	vpmovqd	%ymm3, (%rsi,%r8,4)
	addq	$4, %r8
	cmpq	%r8, %rax
	jne	.LBB0_11
	jmp	.LBB0_12
.LBB0_3:
	xorl	%ecx, %ecx
	popcntq	(%rdi,%rax,8), %rcx
	movl	%ecx, (%rsi,%rax,4)
	incq	%rax
.LBB0_12:
	cmpq	%rax, %rdx
	jne	.LBB0_3
.LBB0_13:
	#APP
	# LLVM-MCA-END popcount_u64
	#NO_APP
	vzeroupper
	retq
.Lfunc_end0:
	.size	_Z12popcount_u64PKmPjl, .Lfunc_end0-_Z12popcount_u64PKmPjl
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
