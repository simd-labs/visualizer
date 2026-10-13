  testq	%rsi, %rsi
  jle	.LBB0_1
  movl	%esi, %ecx
  andl	$3, %ecx
  cmpq	$4, %rsi
  jae	.LBB0_7
  movl	$44257, %r8d                    # imm = 0xACE1
  xorl	%edx, %edx
  xorl	%eax, %eax
  jmp	.LBB0_5
.LBB0_1:
  xorl	%eax, %eax
