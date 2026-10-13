  testq	%rdx, %rdx
  jle	.LBB0_13
  cmpq	$4, %rdx
  jae	.LBB0_4
  xorl	%eax, %eax
  jmp	.LBB0_3
.LBB0_4:
  movabsq	$9223372036854775792, %rcx      # imm = 0x7FFFFFFFFFFFFFF0
  cmpq	$16, %rdx
  jae	.LBB0_6
  xorl	%eax, %eax
  jmp	.LBB0_10
.LBB0_6:
  movq	%rdx, %rax
  andq	%rcx, %rax
  xorl	%r8d, %r8d
  .p2align	4
  .p2align 4
.LBB0_7:
  vpopcntq	(%rdi,%r8,8), %ymm0
  vpopcntq	32(%rdi,%r8,8), %ymm1
  vpopcntq	64(%rdi,%r8,8), %ymm2
  vpopcntq	96(%rdi,%r8,8), %ymm3
  vpmovqd	%ymm0, (%rsi,%r8,4)
  vpmovqd	%ymm1, 16(%rsi,%r8,4)
  vpmovqd	%ymm2, 32(%rsi,%r8,4)
  vpmovqd	%ymm3, 48(%rsi,%r8,4)
  addq	$16, %r8
  cmpq	%r8, %rax
  jne	.LBB0_7
  cmpq	%rax, %rdx
  je	.LBB0_13
  testb	$12, %dl
  je	.LBB0_3
.LBB0_10:
  movq	%rax, %r8
  addq	$12, %rcx
  movq	%rcx, %rax
  andq	%rdx, %rax
  .p2align	4
  .p2align 4
.LBB0_11:
  vpopcntq	(%rdi,%r8,8), %ymm0
  vpmovqd	%ymm0, (%rsi,%r8,4)
  addq	$4, %r8
  cmpq	%r8, %rax
  jne	.LBB0_11
  jmp	.LBB0_12
.LBB0_3:
  popcntq	(%rdi,%rax,8), %rcx
  movl	%ecx, (%rsi,%rax,4)
  incq	%rax
.LBB0_12:
  cmpq	%rax, %rdx
  jne	.LBB0_3
.LBB0_13:
