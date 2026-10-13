  xorl	%eax, %eax
  testq	%rsi, %rsi
  jle	.LBB0_4
  .p2align	4
  .p2align 4
.LBB0_1:
  cmpb	$0, (%rdi,%rax)
  je	.LBB0_4
  incq	%rax
  cmpq	%rax, %rsi
  jne	.LBB0_1
  movq	%rsi, %rax
.LBB0_4:
