  testq	%rdx, %rdx
  jle	.LBB0_1
  leaq	-1(%rdx), %r8
  shrq	$2, %r8
  incq	%r8
  movl	%r8d, %eax
  andl	$3, %eax
  cmpq	$13, %rdx
  jae	.LBB0_8
  xorps	%xmm0, %xmm0
  xorl	%ecx, %ecx
  jmp	.LBB0_5
.LBB0_1:
  xorps	%xmm0, %xmm0
