  testq	%rdx, %rdx
  jle	.LBB0_6
  movl	%edx, %eax
  andl	$7, %eax
  cmpq	$8, %rdx
  jae	.LBB0_7
  vxorps	%xmm0, %xmm0, %xmm0
  xorl	%ecx, %ecx
  jmp	.LBB0_4
.LBB0_7:
  movabsq	$9223372036854775800, %rcx      # imm = 0x7FFFFFFFFFFFFFF8
  andq	%rcx, %rdx
  vxorps	%xmm0, %xmm0, %xmm0
  xorl	%ecx, %ecx
  .p2align	4
  .p2align 4
.LBB0_8:
  vaddss	(%rdi,%rcx,4), %xmm0, %xmm0
  vmovss	%xmm0, (%rsi,%rcx,4)
  vaddss	4(%rdi,%rcx,4), %xmm0, %xmm0
  vmovss	%xmm0, 4(%rsi,%rcx,4)
  vaddss	8(%rdi,%rcx,4), %xmm0, %xmm0
  vmovss	%xmm0, 8(%rsi,%rcx,4)
  vaddss	12(%rdi,%rcx,4), %xmm0, %xmm0
  vmovss	%xmm0, 12(%rsi,%rcx,4)
  vaddss	16(%rdi,%rcx,4), %xmm0, %xmm0
  vmovss	%xmm0, 16(%rsi,%rcx,4)
  vaddss	20(%rdi,%rcx,4), %xmm0, %xmm0
  vmovss	%xmm0, 20(%rsi,%rcx,4)
  vaddss	24(%rdi,%rcx,4), %xmm0, %xmm0
  vmovss	%xmm0, 24(%rsi,%rcx,4)
  vaddss	28(%rdi,%rcx,4), %xmm0, %xmm0
  vmovss	%xmm0, 28(%rsi,%rcx,4)
  addq	$8, %rcx
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
  vaddss	(%rcx,%rsi,4), %xmm0, %xmm0
  vmovss	%xmm0, (%rdx,%rsi,4)
  incq	%rsi
  cmpq	%rsi, %rax
  jne	.LBB0_5
.LBB0_6:
