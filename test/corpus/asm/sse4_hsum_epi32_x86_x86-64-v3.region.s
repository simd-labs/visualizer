  testq	%rsi, %rsi
  jle	.LBB0_1
  leaq	-1(%rsi), %rcx
  shrq	$2, %rcx
  incq	%rcx
  movl	%ecx, %eax
  andl	$7, %eax
  cmpq	$29, %rsi
  jae	.LBB0_9
  vpxor	%xmm0, %xmm0, %xmm0
  xorl	%edx, %edx
  jmp	.LBB0_5
.LBB0_1:
  xorl	%eax, %eax
