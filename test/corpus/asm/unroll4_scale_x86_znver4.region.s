  cmpq	$4, %rdx
  jl	.LBB0_1
  leaq	-4(%rdx), %rcx
  cmpq	$28, %rcx
  jae	.LBB0_7
  xorl	%eax, %eax
  jmp	.LBB0_10
.LBB0_1:
  xorl	%eax, %eax
  jmp	.LBB0_2
.LBB0_7:
  shrq	$2, %rcx
  vbroadcastss	%xmm0, %zmm1
  xorl	%r9d, %r9d
  incq	%rcx
  movq	%rcx, %r8
  andq	$-8, %r8
  leaq	(,%r8,4), %rax
  movq	%r8, %r10
  .p2align	4
  .p2align 4
.LBB0_8:
  vmulps	(%rdi,%r9), %zmm1, %zmm2
  vmulps	64(%rdi,%r9), %zmm1, %zmm3
  vmovups	%zmm3, 64(%rsi,%r9)
  vmovups	%zmm2, (%rsi,%r9)
  subq	$-128, %r9
  addq	$-8, %r10
  jne	.LBB0_8
  cmpq	%r8, %rcx
  je	.LBB0_2
.LBB0_10:
  vbroadcastss	%xmm0, %xmm1
  movq	%rax, %rcx
  .p2align	4
  .p2align 4
.LBB0_11:
  vmulps	(%rdi,%rcx,4), %xmm1, %xmm2
  leaq	4(%rcx), %rax
  vmovups	%xmm2, (%rsi,%rcx,4)
  addq	$7, %rcx
  cmpq	%rdx, %rcx
  movq	%rax, %rcx
  jl	.LBB0_11
.LBB0_2:
  movq	%rdx, %rcx
  subq	%rax, %rcx
  jle	.LBB0_22
  cmpq	$8, %rcx
  jae	.LBB0_12
  movq	%rax, %r8
  jmp	.LBB0_21
.LBB0_12:
  cmpq	$64, %rcx
  jae	.LBB0_14
  xorl	%r9d, %r9d
  jmp	.LBB0_18
.LBB0_14:
  pushq	%rbx
  movq	%rcx, %r9
  andq	$-64, %r9
  vbroadcastss	%xmm0, %zmm1
  leaq	192(%rsi,%rax,4), %r10
  leaq	192(%rdi,%rax,4), %r11
  xorl	%ebx, %ebx
  leaq	(%rax,%r9), %r8
  .p2align	4
  .p2align 4
.LBB0_15:
  vmulps	-192(%r11,%rbx,4), %zmm1, %zmm2
  vmulps	-128(%r11,%rbx,4), %zmm1, %zmm3
  vmulps	-64(%r11,%rbx,4), %zmm1, %zmm4
  vmulps	(%r11,%rbx,4), %zmm1, %zmm5
  vmovups	%zmm2, -192(%r10,%rbx,4)
  vmovups	%zmm3, -128(%r10,%rbx,4)
  vmovups	%zmm4, -64(%r10,%rbx,4)
  vmovups	%zmm5, (%r10,%rbx,4)
  addq	$64, %rbx
  cmpq	%rbx, %r9
  jne	.LBB0_15
  cmpq	%r9, %rcx
  popq	%rbx
  je	.LBB0_22
  testb	$56, %cl
  je	.LBB0_21
.LBB0_18:
  movq	%rcx, %r10
  andq	$-8, %r10
  vbroadcastss	%xmm0, %ymm1
  leaq	(%rsi,%rax,4), %r11
  leaq	(%rax,%r10), %r8
  leaq	(%rdi,%rax,4), %rax
  .p2align	4
  .p2align 4
.LBB0_19:
  vmulps	(%rax,%r9,4), %ymm1, %ymm2
  vmovups	%ymm2, (%r11,%r9,4)
  addq	$8, %r9
  cmpq	%r9, %r10
  jne	.LBB0_19
  cmpq	%r10, %rcx
  je	.LBB0_22
  .p2align	4
  .p2align 4
.LBB0_21:
  vmulss	(%rdi,%r8,4), %xmm0, %xmm1
  vmovss	%xmm1, (%rsi,%r8,4)
  incq	%r8
  cmpq	%r8, %rdx
  jne	.LBB0_21
.LBB0_22:
