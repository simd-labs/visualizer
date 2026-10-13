  testq	%rcx, %rcx
  jle	.LBB0_5
  movl	%edx, %r8d
  cmpq	$1, %rcx
  jne	.LBB0_6
  xorl	%r9d, %r9d
  jmp	.LBB0_4
.LBB0_6:
  movabsq	$9223372036854775806, %r10      # imm = 0x7FFFFFFFFFFFFFFE
  andq	%rcx, %r10
  xorl	%r9d, %r9d
  .p2align	4
  .p2align 4
.LBB0_7:
  movl	(%rdi,%r9,4), %eax
  cltd
  idivl	%r8d
  movl	%eax, (%rsi,%r9,4)
  movl	4(%rdi,%r9,4), %eax
  cltd
  idivl	%r8d
  movl	%eax, 4(%rsi,%r9,4)
  addq	$2, %r9
  cmpq	%r9, %r10
  jne	.LBB0_7
  testb	$1, %cl
  je	.LBB0_5
.LBB0_4:
  movl	(%rdi,%r9,4), %eax
  cltd
  idivl	%r8d
  movl	%eax, (%rsi,%r9,4)
.LBB0_5:
