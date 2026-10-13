  testq	%rdx, %rdx
  jle	.LBB0_6
  movl	%edx, %eax
  andl	$3, %eax
  cmpq	$4, %rdx
  jae	.LBB0_7
  xorl	%ecx, %ecx
  jmp	.LBB0_4
.LBB0_7:
  movabsq	$9223372036854775804, %rcx      # imm = 0x7FFFFFFFFFFFFFFC
  andq	%rcx, %rdx
  xorl	%ecx, %ecx
  .p2align	4
  .p2align 4
.LBB0_8:
  xorl	%r8d, %r8d
  popcntq	(%rdi,%rcx,8), %r8
  movl	%r8d, (%rsi,%rcx,4)
  xorl	%r8d, %r8d
  popcntq	8(%rdi,%rcx,8), %r8
  movl	%r8d, 4(%rsi,%rcx,4)
  xorl	%r8d, %r8d
  popcntq	16(%rdi,%rcx,8), %r8
  xorl	%r9d, %r9d
  popcntq	24(%rdi,%rcx,8), %r9
  movl	%r8d, 8(%rsi,%rcx,4)
  movl	%r9d, 12(%rsi,%rcx,4)
  addq	$4, %rcx
  cmpq	%rcx, %rdx
  jne	.LBB0_8
  testq	%rax, %rax
  je	.LBB0_6
.LBB0_4:
  leaq	(%rsi,%rcx,4), %rdx
  leaq	(%rdi,%rcx,8), %rcx
  xorl	%esi, %esi
  .p2align	4
  .p2align 4
.LBB0_5:
  xorl	%edi, %edi
  popcntq	(%rcx,%rsi,8), %rdi
  movl	%edi, (%rdx,%rsi,4)
  incq	%rsi
  cmpq	%rsi, %rax
  jne	.LBB0_5
.LBB0_6:
