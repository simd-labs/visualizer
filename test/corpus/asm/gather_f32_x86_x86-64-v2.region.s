  testq	%rcx, %rcx
  jle	.LBB0_6
  movl	%ecx, %eax
  andl	$3, %eax
  cmpq	$4, %rcx
  jae	.LBB0_7
  xorl	%r8d, %r8d
  jmp	.LBB0_4
.LBB0_7:
  movabsq	$9223372036854775804, %r8       # imm = 0x7FFFFFFFFFFFFFFC
  andq	%r8, %rcx
  xorl	%r8d, %r8d
  .p2align	4
  .p2align 4
.LBB0_8:
  movslq	(%rsi,%r8,4), %r9
  movss	(%rdi,%r9,4), %xmm0             # xmm0 = mem[0],zero,zero,zero
  movss	%xmm0, (%rdx,%r8,4)
  movslq	4(%rsi,%r8,4), %r9
  movss	(%rdi,%r9,4), %xmm0             # xmm0 = mem[0],zero,zero,zero
  movss	%xmm0, 4(%rdx,%r8,4)
  movslq	8(%rsi,%r8,4), %r9
  movss	(%rdi,%r9,4), %xmm0             # xmm0 = mem[0],zero,zero,zero
  movss	%xmm0, 8(%rdx,%r8,4)
  movslq	12(%rsi,%r8,4), %r9
  movss	(%rdi,%r9,4), %xmm0             # xmm0 = mem[0],zero,zero,zero
  movss	%xmm0, 12(%rdx,%r8,4)
  addq	$4, %r8
  cmpq	%r8, %rcx
  jne	.LBB0_8
  testq	%rax, %rax
  je	.LBB0_6
.LBB0_4:
  leaq	(%rdx,%r8,4), %rcx
  leaq	(%rsi,%r8,4), %rdx
  xorl	%esi, %esi
  .p2align	4
  .p2align 4
.LBB0_5:
  movslq	(%rdx,%rsi,4), %r8
  movss	(%rdi,%r8,4), %xmm0             # xmm0 = mem[0],zero,zero,zero
  movss	%xmm0, (%rcx,%rsi,4)
  incq	%rsi
  cmpq	%rsi, %rax
  jne	.LBB0_5
.LBB0_6:
