  testq	%rdx, %rdx
  jle	.LBB0_13
  cmpq	$8, %rdx
  jae	.LBB0_4
  xorl	%eax, %eax
  jmp	.LBB0_3
.LBB0_4:
  movabsq	$9223372036854775776, %rcx      # imm = 0x7FFFFFFFFFFFFFE0
  cmpq	$32, %rdx
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
  vpopcntq	(%rdi,%r8,8), %zmm0
  vpopcntq	64(%rdi,%r8,8), %zmm1
  vpopcntq	128(%rdi,%r8,8), %zmm2
  vpopcntq	192(%rdi,%r8,8), %zmm3
  vpmovqd	%zmm0, (%rsi,%r8,4)
  vpmovqd	%zmm1, 32(%rsi,%r8,4)
  vpmovqd	%zmm2, 64(%rsi,%r8,4)
  vpmovqd	%zmm3, 96(%rsi,%r8,4)
  addq	$32, %r8
  cmpq	%r8, %rax
  jne	.LBB0_7
  cmpq	%rax, %rdx
  je	.LBB0_13
  testb	$24, %dl
  je	.LBB0_3
.LBB0_10:
  addq	$24, %rcx
  movq	%rax, %r8
  movq	%rcx, %rax
  andq	%rdx, %rax
  .p2align	4
  .p2align 4
.LBB0_11:
  vpopcntq	(%rdi,%r8,8), %zmm0
  vpmovqd	%zmm0, (%rsi,%r8,4)
  addq	$8, %r8
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
