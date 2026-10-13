  testq	%rdx, %rdx
  jle	.LBB0_6
  leaq	-1(%rdx), %rcx
  shrq	$2, %rcx
  incq	%rcx
  movl	%ecx, %eax
  andl	$7, %eax
  cmpq	$29, %rdx
  jae	.LBB0_7
  xorl	%edx, %edx
  jmp	.LBB0_4
.LBB0_7:
  andq	$-8, %rcx
  xorl	%edx, %edx
  .p2align	4
  .p2align 4
.LBB0_8:
  vcvtps2dq	(%rdi,%rdx,4), %xmm0
  vmovntpd	%xmm0, (%rsi,%rdx,4)
  vcvtps2dq	16(%rdi,%rdx,4), %xmm0
  vmovntpd	%xmm0, 16(%rsi,%rdx,4)
  vcvtps2dq	32(%rdi,%rdx,4), %xmm0
  vmovntpd	%xmm0, 32(%rsi,%rdx,4)
  vcvtps2dq	48(%rdi,%rdx,4), %xmm0
  vmovntpd	%xmm0, 48(%rsi,%rdx,4)
  vcvtps2dq	64(%rdi,%rdx,4), %xmm0
  vmovntpd	%xmm0, 64(%rsi,%rdx,4)
  vcvtps2dq	80(%rdi,%rdx,4), %xmm0
  vmovntpd	%xmm0, 80(%rsi,%rdx,4)
  vcvtps2dq	96(%rdi,%rdx,4), %xmm0
  vmovntpd	%xmm0, 96(%rsi,%rdx,4)
  vcvtps2dq	112(%rdi,%rdx,4), %xmm0
  vmovntpd	%xmm0, 112(%rsi,%rdx,4)
  addq	$32, %rdx
  addq	$-8, %rcx
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
  vcvtps2dq	(%rdx,%rsi), %xmm0
  vmovntpd	%xmm0, (%rcx,%rsi)
  addq	$16, %rsi
  cmpq	%rsi, %rax
  jne	.LBB0_5
.LBB0_6:
