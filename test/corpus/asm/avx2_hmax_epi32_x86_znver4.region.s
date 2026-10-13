  testq	%rsi, %rsi
  jle	.LBB0_1
  leaq	-1(%rsi), %rcx
  shrq	$3, %rcx
  incq	%rcx
  movl	%ecx, %eax
  andl	$7, %eax
  cmpq	$57, %rsi
  jae	.LBB0_8
  vpxor	%xmm0, %xmm0, %xmm0
  xorl	%edx, %edx
  jmp	.LBB0_5
.LBB0_1:
  vpxor	%xmm0, %xmm0, %xmm0
  jmp	.LBB0_7
.LBB0_8:
  andq	$-8, %rcx
  vpxor	%xmm0, %xmm0, %xmm0
  xorl	%edx, %edx
  .p2align	4
  .p2align 4
.LBB0_9:
  vpmaxsd	(%rdi,%rdx,4), %ymm0, %ymm0
  vpmaxsd	32(%rdi,%rdx,4), %ymm0, %ymm0
  vpmaxsd	64(%rdi,%rdx,4), %ymm0, %ymm0
  vpmaxsd	96(%rdi,%rdx,4), %ymm0, %ymm0
  vpmaxsd	128(%rdi,%rdx,4), %ymm0, %ymm0
  vpmaxsd	160(%rdi,%rdx,4), %ymm0, %ymm0
  vpmaxsd	192(%rdi,%rdx,4), %ymm0, %ymm0
  vpmaxsd	224(%rdi,%rdx,4), %ymm0, %ymm0
  addq	$64, %rdx
  addq	$-8, %rcx
  jne	.LBB0_9
  testq	%rax, %rax
  je	.LBB0_7
.LBB0_5:
  leaq	(%rdi,%rdx,4), %rcx
  shll	$5, %eax
  xorl	%edx, %edx
  .p2align	4
  .p2align 4
.LBB0_6:
  vpmaxsd	(%rcx,%rdx), %ymm0, %ymm0
  addq	$32, %rdx
  cmpq	%rdx, %rax
  jne	.LBB0_6
.LBB0_7:
  vextracti128	$1, %ymm0, %xmm1
