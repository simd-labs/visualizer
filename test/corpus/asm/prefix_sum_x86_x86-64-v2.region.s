  testq	%rdx, %rdx
  jle	.LBB0_6
  movl	%edx, %eax
  andl	$3, %eax
  cmpq	$4, %rdx
  jae	.LBB0_7
  xorps	%xmm0, %xmm0
  xorl	%ecx, %ecx
  jmp	.LBB0_4
.LBB0_7:
  movabsq	$9223372036854775804, %rcx      # imm = 0x7FFFFFFFFFFFFFFC
  andq	%rcx, %rdx
  xorps	%xmm0, %xmm0
  xorl	%ecx, %ecx
  .p2align	4
  .p2align 4
.LBB0_8:
  addss	(%rdi,%rcx,4), %xmm0
  movss	%xmm0, (%rsi,%rcx,4)
  addss	4(%rdi,%rcx,4), %xmm0
  movss	%xmm0, 4(%rsi,%rcx,4)
  addss	8(%rdi,%rcx,4), %xmm0
  movss	%xmm0, 8(%rsi,%rcx,4)
  addss	12(%rdi,%rcx,4), %xmm0
  movss	%xmm0, 12(%rsi,%rcx,4)
  addq	$4, %rcx
  cmpq	%rcx, %rdx
  jne	.LBB0_8
  testq	%rax, %rax
  je	.LBB0_6
.LBB0_4:
  leaq	(%rsi,%rcx,4), %rdx
  leaq	(%rdi,%rcx,4), %rcx
  xorl	%esi, %esi
  .p2align	4
  .p2align 4
.LBB0_5:
  addss	(%rcx,%rsi,4), %xmm0
  movss	%xmm0, (%rdx,%rsi,4)
  incq	%rsi
  cmpq	%rsi, %rax
  jne	.LBB0_5
.LBB0_6:
