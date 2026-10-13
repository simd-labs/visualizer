  testq	%rcx, %rcx
  jle	.LBB0_6
  movl	%edx, %r8d
  movl	%ecx, %r9d
  andl	$7, %r9d
  cmpq	$8, %rcx
  jae	.LBB0_7
  xorl	%r10d, %r10d
  jmp	.LBB0_4
.LBB0_7:
  movabsq	$9223372036854775800, %rax      # imm = 0x7FFFFFFFFFFFFFF8
  andq	%rax, %rcx
  xorl	%r10d, %r10d
  .p2align	4
  .p2align 4
.LBB0_8:
  movl	(%rdi,%r10,4), %eax
  cltd
  idivl	%r8d
  movl	%eax, (%rsi,%r10,4)
  movl	4(%rdi,%r10,4), %eax
  cltd
  idivl	%r8d
  movl	%eax, 4(%rsi,%r10,4)
  movl	8(%rdi,%r10,4), %eax
  cltd
  idivl	%r8d
  movl	%eax, 8(%rsi,%r10,4)
  movl	12(%rdi,%r10,4), %eax
  cltd
  idivl	%r8d
  movl	%eax, 12(%rsi,%r10,4)
  movl	16(%rdi,%r10,4), %eax
  cltd
  idivl	%r8d
  movl	%eax, 16(%rsi,%r10,4)
  movl	20(%rdi,%r10,4), %eax
  cltd
  idivl	%r8d
  movl	%eax, 20(%rsi,%r10,4)
  movl	24(%rdi,%r10,4), %eax
  cltd
  idivl	%r8d
  movl	%eax, 24(%rsi,%r10,4)
  movl	28(%rdi,%r10,4), %eax
  cltd
  idivl	%r8d
  movl	%eax, 28(%rsi,%r10,4)
  addq	$8, %r10
  cmpq	%r10, %rcx
  jne	.LBB0_8
  testq	%r9, %r9
  je	.LBB0_6
.LBB0_4:
  leaq	(%rsi,%r10,4), %rcx
  leaq	(%rdi,%r10,4), %rsi
  xorl	%edi, %edi
  .p2align	4
  .p2align 4
.LBB0_5:
  movl	(%rsi,%rdi,4), %eax
  cltd
  idivl	%r8d
  movl	%eax, (%rcx,%rdi,4)
  incq	%rdi
  cmpq	%rdi, %r9
  jne	.LBB0_5
.LBB0_6:
