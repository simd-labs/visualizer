  testq	%rcx, %rcx
  jle	.LBB0_13
  cmpq	$8, %rcx
  jae	.LBB0_4
  xorl	%eax, %eax
  jmp	.LBB0_3
.LBB0_4:
  movabsq	$9223372036854775680, %r8       # imm = 0x7FFFFFFFFFFFFF80
  cmpq	$128, %rcx
  jae	.LBB0_6
  xorl	%eax, %eax
  jmp	.LBB0_10
.LBB0_6:
  movq	%rcx, %rax
  andq	%r8, %rax
  xorl	%r9d, %r9d
  .p2align	4
  .p2align 4
.LBB0_7:
  vmovups	(%rsi,%r9), %ymm0
  vmovups	32(%rsi,%r9), %ymm1
  vmovups	64(%rsi,%r9), %ymm2
  vmovups	96(%rsi,%r9), %ymm3
  vxorps	(%rdi,%r9), %ymm0, %ymm0
  vxorps	32(%rdi,%r9), %ymm1, %ymm1
  vxorps	64(%rdi,%r9), %ymm2, %ymm2
  vxorps	96(%rdi,%r9), %ymm3, %ymm3
  vmovups	%ymm0, (%rdx,%r9)
  vmovups	%ymm1, 32(%rdx,%r9)
  vmovups	%ymm2, 64(%rdx,%r9)
  vmovups	%ymm3, 96(%rdx,%r9)
  subq	$-128, %r9
  cmpq	%r9, %rax
  jne	.LBB0_7
  cmpq	%rax, %rcx
  je	.LBB0_13
  testb	$120, %cl
  je	.LBB0_3
.LBB0_10:
  movq	%rax, %r9
  addq	$120, %r8
  movq	%r8, %rax
  andq	%rcx, %rax
  .p2align	4
  .p2align 4
.LBB0_11:
  movq	(%rsi,%r9), %r8
  xorq	(%rdi,%r9), %r8
  movq	%r8, (%rdx,%r9)
  addq	$8, %r9
  cmpq	%r9, %rax
  jne	.LBB0_11
  jmp	.LBB0_12
.LBB0_3:
  movzbl	(%rsi,%rax), %r8d
  xorb	(%rdi,%rax), %r8b
  movb	%r8b, (%rdx,%rax)
  incq	%rax
.LBB0_12:
  cmpq	%rax, %rcx
  jne	.LBB0_3
.LBB0_13:
