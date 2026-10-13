  testq	%rdx, %rdx
  jle	.LBB0_1
  leaq	-1(%rdx), %r8
  shrq	$2, %r8
  incq	%r8
  movl	%r8d, %eax
  andl	$7, %eax
  cmpq	$29, %rdx
  jae	.LBB0_8
  vxorps	%xmm0, %xmm0, %xmm0
  xorl	%ecx, %ecx
  jmp	.LBB0_5
.LBB0_1:
  vxorps	%xmm0, %xmm0, %xmm0
