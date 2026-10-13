  testq	%rsi, %rsi
  jle	.LBB0_6
  movabsq	$1099511628211, %rcx            # imm = 0x100000001B3
  movl	%esi, %edx
  andl	$7, %edx
  cmpq	$8, %rsi
  jae	.LBB0_7
  xorl	%r8d, %r8d
  jmp	.LBB0_4
.LBB0_7:
  movabsq	$9223372036854775800, %r8       # imm = 0x7FFFFFFFFFFFFFF8
  andq	%r8, %rsi
  xorl	%r8d, %r8d
  .p2align	4
  .p2align 4
.LBB0_8:
  movzbl	(%rdi,%r8), %r9d
  xorq	%rax, %r9
  imulq	%rcx, %r9
  movzbl	1(%rdi,%r8), %eax
  xorq	%r9, %rax
  imulq	%rcx, %rax
  movzbl	2(%rdi,%r8), %r9d
  xorq	%rax, %r9
  imulq	%rcx, %r9
  movzbl	3(%rdi,%r8), %eax
  xorq	%r9, %rax
  imulq	%rcx, %rax
  movzbl	4(%rdi,%r8), %r9d
  xorq	%rax, %r9
  imulq	%rcx, %r9
  movzbl	5(%rdi,%r8), %eax
  xorq	%r9, %rax
  imulq	%rcx, %rax
  movzbl	6(%rdi,%r8), %r9d
  xorq	%rax, %r9
  imulq	%rcx, %r9
  movzbl	7(%rdi,%r8), %eax
  xorq	%r9, %rax
  imulq	%rcx, %rax
  addq	$8, %r8
  cmpq	%r8, %rsi
  jne	.LBB0_8
  testq	%rdx, %rdx
  je	.LBB0_6
.LBB0_4:
  addq	%r8, %rdi
  xorl	%esi, %esi
  .p2align	4
  .p2align 4
.LBB0_5:
  movzbl	(%rdi,%rsi), %r8d
  xorq	%r8, %rax
  imulq	%rcx, %rax
  incq	%rsi
  cmpq	%rsi, %rdx
  jne	.LBB0_5
.LBB0_6:
