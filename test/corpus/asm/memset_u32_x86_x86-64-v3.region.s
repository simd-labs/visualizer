  testq	%rdx, %rdx
  jle	.LBB0_13
  cmpq	$4, %rdx
  jae	.LBB0_4
  xorl	%eax, %eax
  jmp	.LBB0_3
.LBB0_4:
  movabsq	$9223372036854775776, %rcx      # imm = 0x7FFFFFFFFFFFFFE0
  vmovd	%esi, %xmm0
  cmpq	$32, %rdx
  jae	.LBB0_6
  xorl	%eax, %eax
  jmp	.LBB0_10
.LBB0_6:
  movq	%rdx, %rax
  andq	%rcx, %rax
  vpbroadcastd	%xmm0, %ymm1
  xorl	%r8d, %r8d
  .p2align	4
  .p2align 4
.LBB0_7:
  vmovdqu	%ymm1, (%rdi,%r8,4)
  vmovdqu	%ymm1, 32(%rdi,%r8,4)
  vmovdqu	%ymm1, 64(%rdi,%r8,4)
  vmovdqu	%ymm1, 96(%rdi,%r8,4)
  addq	$32, %r8
  cmpq	%r8, %rax
  jne	.LBB0_7
  cmpq	%rax, %rdx
  je	.LBB0_13
  testb	$28, %dl
  je	.LBB0_3
.LBB0_10:
  movq	%rax, %r8
  addq	$28, %rcx
  movq	%rcx, %rax
  andq	%rdx, %rax
  vpbroadcastd	%xmm0, %xmm0
  .p2align	4
  .p2align 4
.LBB0_11:
  vmovdqu	%xmm0, (%rdi,%r8,4)
  addq	$4, %r8
  cmpq	%r8, %rax
  jne	.LBB0_11
  jmp	.LBB0_12
.LBB0_3:
  movl	%esi, (%rdi,%rax,4)
  incq	%rax
.LBB0_12:
  cmpq	%rax, %rdx
  jne	.LBB0_3
.LBB0_13:
