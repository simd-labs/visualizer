  testq	%rdx, %rdx
  jle	.LBB0_7
  cmpq	$8, %rdx
  jae	.LBB0_4
  xorl	%eax, %eax
  jmp	.LBB0_3
.LBB0_4:
  movabsq	$9223372036854775800, %rax      # imm = 0x7FFFFFFFFFFFFFF8
  andq	%rdx, %rax
  xorl	%ecx, %ecx
  .p2align	4
  .p2align 4
.LBB0_5:
  movups	(%rdi,%rcx,4), %xmm0
  movups	16(%rdi,%rcx,4), %xmm1
  movups	%xmm0, (%rsi,%rcx,4)
  movups	%xmm1, 16(%rsi,%rcx,4)
  addq	$8, %rcx
  cmpq	%rcx, %rax
  jne	.LBB0_5
  jmp	.LBB0_6
.LBB0_3:
  movss	(%rdi,%rax,4), %xmm0            # xmm0 = mem[0],zero,zero,zero
  movss	%xmm0, (%rsi,%rax,4)
  incq	%rax
.LBB0_6:
  cmpq	%rax, %rdx
  jne	.LBB0_3
.LBB0_7:
