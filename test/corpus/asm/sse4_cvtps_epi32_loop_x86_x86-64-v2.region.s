  testq	%rdx, %rdx
  jle	.LBB0_6
  leaq	-1(%rdx), %rcx
  shrq	$2, %rcx
  incq	%rcx
  movl	%ecx, %eax
  andl	$3, %eax
  cmpq	$13, %rdx
  jae	.LBB0_7
  xorl	%edx, %edx
  jmp	.LBB0_4
.LBB0_7:
  andq	$-4, %rcx
  xorl	%edx, %edx
  .p2align	4
  .p2align 4
.LBB0_8:
  cvtps2dq	(%rdi,%rdx,4), %xmm0
  movntpd	%xmm0, (%rsi,%rdx,4)
  cvtps2dq	16(%rdi,%rdx,4), %xmm0
  movntpd	%xmm0, 16(%rsi,%rdx,4)
  cvtps2dq	32(%rdi,%rdx,4), %xmm0
  cvtps2dq	48(%rdi,%rdx,4), %xmm1
  movntpd	%xmm0, 32(%rsi,%rdx,4)
  movntpd	%xmm1, 48(%rsi,%rdx,4)
  addq	$16, %rdx
  addq	$-4, %rcx
  jne	.LBB0_8
  testq	%rax, %rax
  je	.LBB0_6
.LBB0_4:
  leaq	(%rsi,%rdx,4), %rcx
  leaq	(%rdi,%rdx,4), %rdx
  shll	$4, %eax
  xorl	%esi, %esi
  .p2align	4
  .p2align 4
.LBB0_5:
  cvtps2dq	(%rdx,%rsi), %xmm0
  movntpd	%xmm0, (%rcx,%rsi)
  addq	$16, %rsi
  cmpq	%rsi, %rax
  jne	.LBB0_5
.LBB0_6:
