  testq	%rcx, %rcx
  jle	.LBB0_7
  cmpq	$15, %rcx
  jae	.LBB0_3
  xorl	%eax, %eax
  jmp	.LBB0_6
.LBB0_3:
  leaq	-1(%rcx), %r8
  shrq	%r8
  incq	%r8
  movq	%r8, %r9
  andq	$-8, %r9
  leaq	(%r9,%r9), %rax
  xorl	%r10d, %r10d
  .p2align	4
  .p2align 4
.LBB0_4:
  vmovdqu	(%rsi,%r10,4), %ymm0
  vpmaddwd	(%rdi,%r10,4), %ymm0, %ymm0
  vmovdqu	%ymm0, (%rdx,%r10,4)
  addq	$8, %r10
  cmpq	%r10, %r9
  jne	.LBB0_4
  cmpq	%r9, %r8
  je	.LBB0_7
  .p2align	4
  .p2align 4
.LBB0_6:
  movswl	(%rdi,%rax,2), %r8d
  movswl	(%rsi,%rax,2), %r9d
  imull	%r8d, %r9d
  movswl	2(%rdi,%rax,2), %r8d
  movswl	2(%rsi,%rax,2), %r10d
  imull	%r8d, %r10d
  addl	%r9d, %r10d
  movl	%r10d, (%rdx,%rax,2)
  addq	$2, %rax
  cmpq	%rcx, %rax
  jl	.LBB0_6
.LBB0_7:
