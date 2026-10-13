  testq	%rdx, %rdx
  jle	.LBB0_6
  movl	%edx, %eax
  andl	$3, %eax
  cmpq	$4, %rdx
  jae	.LBB0_7
  xorl	%ecx, %ecx
  jmp	.LBB0_4
.LBB0_7:
  movabsq	$9223372036854775804, %rcx      # imm = 0x7FFFFFFFFFFFFFFC
  andq	%rcx, %rdx
  xorl	%ecx, %ecx
  .p2align	4
  .p2align 4
.LBB0_8:
  movzbl	(%rdi,%rcx), %r8d
  incl	(%rsi,%r8,4)
  movzbl	1(%rdi,%rcx), %r8d
  incl	(%rsi,%r8,4)
  movzbl	2(%rdi,%rcx), %r8d
  incl	(%rsi,%r8,4)
  movzbl	3(%rdi,%rcx), %r8d
  incl	(%rsi,%r8,4)
  addq	$4, %rcx
  cmpq	%rcx, %rdx
  jne	.LBB0_8
  testq	%rax, %rax
  je	.LBB0_6
.LBB0_4:
  addq	%rcx, %rdi
  xorl	%ecx, %ecx
  .p2align	4
  .p2align 4
.LBB0_5:
  movzbl	(%rdi,%rcx), %edx
  incl	(%rsi,%rdx,4)
  incq	%rcx
  cmpq	%rcx, %rax
  jne	.LBB0_5
.LBB0_6:
