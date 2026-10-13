  testq	%rdx, %rdx
  jle	.LBB0_13
  cmpq	$4, %rdx
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
  vmovups	(%rdi,%r8,4), %ymm0
  vmovups	32(%rdi,%r8,4), %ymm1
  vmovups	64(%rdi,%r8,4), %ymm2
  vmovups	96(%rdi,%r8,4), %ymm3
  vmovups	%ymm0, (%rsi,%r8,4)
  vmovups	%ymm1, 32(%rsi,%r8,4)
  vmovups	%ymm2, 64(%rsi,%r8,4)
  vmovups	%ymm3, 96(%rsi,%r8,4)
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
  .p2align	4
  .p2align 4
.LBB0_11:
  vmovups	(%rdi,%r8,4), %xmm0
  vmovups	%xmm0, (%rsi,%r8,4)
  addq	$4, %r8
  cmpq	%r8, %rax
  jne	.LBB0_11
  jmp	.LBB0_12
.LBB0_3:
  vmovss	(%rdi,%rax,4), %xmm0            # xmm0 = mem[0],zero,zero,zero
  vmovss	%xmm0, (%rsi,%rax,4)
  incq	%rax
.LBB0_12:
  cmpq	%rax, %rdx
  jne	.LBB0_3
.LBB0_13:
