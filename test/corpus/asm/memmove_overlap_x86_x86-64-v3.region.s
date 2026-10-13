  movq	%rdi, %rax
  subq	%rsi, %rax
  jae	.LBB0_1
  testq	%rdx, %rdx
  jle	.LBB0_32
  cmpq	$8, %rdx
  setb	%al
  movq	%rsi, %rcx
  subq	%rdi, %rcx
  cmpq	$-127, %rcx
  setae	%cl
  orb	%al, %cl
  je	.LBB0_18
  xorl	%eax, %eax
  jmp	.LBB0_27
.LBB0_1:
  testq	%rdx, %rdx
  jle	.LBB0_32
  cmpq	$16, %rdx
  setb	%cl
  cmpq	$-127, %rax
  setae	%al
  orb	%cl, %al
  je	.LBB0_4
  movq	%rdx, %rax
  jmp	.LBB0_13
.LBB0_18:
  movabsq	$9223372036854775680, %rcx      # imm = 0x7FFFFFFFFFFFFF80
  cmpq	$128, %rdx
  jae	.LBB0_20
  xorl	%eax, %eax
  jmp	.LBB0_24
.LBB0_4:
  movabsq	$9223372036854775680, %rcx      # imm = 0x7FFFFFFFFFFFFF80
  cmpq	$128, %rdx
  jae	.LBB0_6
  xorl	%r8d, %r8d
  jmp	.LBB0_10
.LBB0_20:
  movq	%rdx, %rax
  andq	%rcx, %rax
  xorl	%r8d, %r8d
  .p2align	4
  .p2align 4
.LBB0_21:
  vmovups	(%rsi,%r8), %ymm0
  vmovups	32(%rsi,%r8), %ymm1
  vmovups	64(%rsi,%r8), %ymm2
  vmovups	96(%rsi,%r8), %ymm3
  vmovups	%ymm0, (%rdi,%r8)
  vmovups	%ymm1, 32(%rdi,%r8)
  vmovups	%ymm2, 64(%rdi,%r8)
  vmovups	%ymm3, 96(%rdi,%r8)
  subq	$-128, %r8
  cmpq	%r8, %rax
  jne	.LBB0_21
  cmpq	%rax, %rdx
  je	.LBB0_32
  testb	$120, %dl
  je	.LBB0_27
.LBB0_24:
  movq	%rax, %r8
  addq	$120, %rcx
  movq	%rcx, %rax
  andq	%rdx, %rax
  .p2align	4
  .p2align 4
.LBB0_25:
  movq	(%rsi,%r8), %rcx
  movq	%rcx, (%rdi,%r8)
  addq	$8, %r8
  cmpq	%r8, %rax
  jne	.LBB0_25
  cmpq	%rax, %rdx
  je	.LBB0_32
.LBB0_27:
  movq	%rdx, %r8
  movq	%rax, %rcx
  andq	$7, %r8
  je	.LBB0_30
  movq	%rax, %rcx
  .p2align	4
  .p2align 4
.LBB0_29:
  movzbl	(%rsi,%rcx), %r9d
  movb	%r9b, (%rdi,%rcx)
  incq	%rcx
  decq	%r8
  jne	.LBB0_29
.LBB0_30:
  subq	%rdx, %rax
  cmpq	$-8, %rax
  ja	.LBB0_32
  .p2align	4
  .p2align 4
.LBB0_31:
  movzbl	(%rsi,%rcx), %eax
  movb	%al, (%rdi,%rcx)
  movzbl	1(%rsi,%rcx), %eax
  movb	%al, 1(%rdi,%rcx)
  movzbl	2(%rsi,%rcx), %eax
  movb	%al, 2(%rdi,%rcx)
  movzbl	3(%rsi,%rcx), %eax
  movb	%al, 3(%rdi,%rcx)
  movzbl	4(%rsi,%rcx), %eax
  movb	%al, 4(%rdi,%rcx)
  movzbl	5(%rsi,%rcx), %eax
  movb	%al, 5(%rdi,%rcx)
  movzbl	6(%rsi,%rcx), %eax
  movb	%al, 6(%rdi,%rcx)
  movzbl	7(%rsi,%rcx), %eax
  movb	%al, 7(%rdi,%rcx)
  addq	$8, %rcx
  cmpq	%rcx, %rdx
  jne	.LBB0_31
  jmp	.LBB0_32
.LBB0_6:
  pushq	%rbx
  movq	%rdx, %r8
  andq	%rcx, %r8
  movl	%edx, %eax
  andl	$127, %eax
  leaq	(%rsi,%rdx), %r9
  addq	$-32, %r9
  leaq	(%rdi,%rdx), %r10
  addq	$-32, %r10
  movq	%rdx, %r11
  andq	%rcx, %r11
  negq	%r11
  xorl	%ebx, %ebx
  .p2align	4
  .p2align 4
.LBB0_7:
  vmovups	-96(%r9,%rbx), %ymm0
  vmovups	-64(%r9,%rbx), %ymm1
  vmovups	-32(%r9,%rbx), %ymm2
  vmovups	(%r9,%rbx), %ymm3
  vmovups	%ymm3, (%r10,%rbx)
  vmovups	%ymm2, -32(%r10,%rbx)
  vmovups	%ymm1, -64(%r10,%rbx)
  vmovups	%ymm0, -96(%r10,%rbx)
  addq	$-128, %rbx
  cmpq	%rbx, %r11
  jne	.LBB0_7
  cmpq	%r8, %rdx
  popq	%rbx
  je	.LBB0_32
  testb	$112, %dl
  je	.LBB0_13
.LBB0_10:
  addq	$112, %rcx
  andq	%rdx, %rcx
  movl	%edx, %eax
  andl	$15, %eax
  leaq	(%rsi,%rdx), %r9
  addq	$-16, %r9
  negq	%r8
  leaq	(%rdi,%rdx), %r10
  addq	$-16, %r10
  movabsq	$9223372036854775792, %r11      # imm = 0x7FFFFFFFFFFFFFF0
  andq	%rdx, %r11
  negq	%r11
  .p2align	4
  .p2align 4
.LBB0_11:
  vmovups	(%r9,%r8), %xmm0
  vmovups	%xmm0, (%r10,%r8)
  addq	$-16, %r8
  cmpq	%r8, %r11
  jne	.LBB0_11
  cmpq	%rcx, %rdx
  je	.LBB0_32
.LBB0_13:
  incq	%rax
  .p2align	4
  .p2align 4
.LBB0_14:
  movzbl	-2(%rsi,%rax), %ecx
  movb	%cl, -2(%rdi,%rax)
  decq	%rax
  cmpq	$1, %rax
  ja	.LBB0_14
.LBB0_32:
