  testq	%rdx, %rdx
  jle	.LBB0_1
  movl	%edx, %eax
  andl	$3, %eax
  cmpq	$4, %rdx
  jae	.LBB0_8
  xorps	%xmm0, %xmm0
  xorl	%ecx, %ecx
  jmp	.LBB0_5
.LBB0_1:
  xorps	%xmm0, %xmm0
