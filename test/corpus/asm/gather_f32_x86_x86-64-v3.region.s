  testq	%rcx, %rcx
  jle	.LBB0_7
  cmpq	$8, %rcx
  jae	.LBB0_3
  xorl	%eax, %eax
  jmp	.LBB0_6
.LBB0_3:
  pushq	%r15
  pushq	%r14
  pushq	%r12
  pushq	%rbx
  movabsq	$9223372036854775800, %rax      # imm = 0x7FFFFFFFFFFFFFF8
  andq	%rcx, %rax
  xorl	%r8d, %r8d
  .p2align	4
  .p2align 4
.LBB0_4:
  movslq	(%rsi,%r8,4), %r9
  movslq	4(%rsi,%r8,4), %r10
  movslq	8(%rsi,%r8,4), %r11
  movslq	12(%rsi,%r8,4), %rbx
  movslq	16(%rsi,%r8,4), %r14
  movslq	20(%rsi,%r8,4), %r15
  movslq	24(%rsi,%r8,4), %r12
  vmovss	(%rdi,%r9,4), %xmm0             # xmm0 = mem[0],zero,zero,zero
  vinsertps	$16, (%rdi,%r10,4), %xmm0, %xmm0 # xmm0 = xmm0[0],mem[0],xmm0[2,3]
  vinsertps	$32, (%rdi,%r11,4), %xmm0, %xmm0 # xmm0 = xmm0[0,1],mem[0],xmm0[3]
  movslq	28(%rsi,%r8,4), %r9
  vinsertps	$48, (%rdi,%rbx,4), %xmm0, %xmm0 # xmm0 = xmm0[0,1,2],mem[0]
  vmovss	(%rdi,%r14,4), %xmm1            # xmm1 = mem[0],zero,zero,zero
  vinsertps	$16, (%rdi,%r15,4), %xmm1, %xmm1 # xmm1 = xmm1[0],mem[0],xmm1[2,3]
  vinsertps	$32, (%rdi,%r12,4), %xmm1, %xmm1 # xmm1 = xmm1[0,1],mem[0],xmm1[3]
  vinsertps	$48, (%rdi,%r9,4), %xmm1, %xmm1 # xmm1 = xmm1[0,1,2],mem[0]
  vmovups	%xmm1, 16(%rdx,%r8,4)
  vmovups	%xmm0, (%rdx,%r8,4)
  addq	$8, %r8
  cmpq	%r8, %rax
  jne	.LBB0_4
  cmpq	%rax, %rcx
  popq	%rbx
  popq	%r12
  popq	%r14
  popq	%r15
  je	.LBB0_7
  .p2align	4
  .p2align 4
.LBB0_6:
  movslq	(%rsi,%rax,4), %r8
  vmovss	(%rdi,%r8,4), %xmm0             # xmm0 = mem[0],zero,zero,zero
  vmovss	%xmm0, (%rdx,%rax,4)
  incq	%rax
  cmpq	%rax, %rcx
  jne	.LBB0_6
.LBB0_7:
