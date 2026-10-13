  testq	%rdx, %rdx
  jle	.LBB0_1
  movl	%edx, %eax
  andl	$7, %eax
  cmpq	$8, %rdx
  jae	.LBB0_8
  vxorpd	%xmm0, %xmm0, %xmm0
  xorl	%ecx, %ecx
  jmp	.LBB0_5
.LBB0_1:
  vxorps	%xmm0, %xmm0, %xmm0
