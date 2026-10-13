  testq	%rdx, %rdx
  jle	.LBB0_1
  cmpq	$4, %rdx
  jae	.LBB0_5
  xorl	%ecx, %ecx
  xorl	%eax, %eax
  jmp	.LBB0_4
.LBB0_1:
  xorl	%eax, %eax
