  testq	%rdx, %rdx
  jle	.LBB0_1
  leaq	-1(%rdx), %r8
  shrq	$3, %r8
  incq	%r8
  movl	%r8d, %eax
  andl	$7, %eax
  cmpq	$57, %rdx
  jae	.LBB0_8
  vxorps	%xmm0, %xmm0, %xmm0
  xorl	%ecx, %ecx
  jmp	.LBB0_5
.LBB0_1:
  vxorps	%xmm0, %xmm0, %xmm0
  jmp	.LBB0_7
.LBB0_8:
  andq	$-8, %r8
  vxorps	%xmm0, %xmm0, %xmm0
  xorl	%ecx, %ecx
  .p2align	4
  .p2align 4
.LBB0_9:
  vmovups	(%rdi,%rcx,4), %ymm1
  vmovups	32(%rdi,%rcx,4), %ymm2
  vmovups	64(%rdi,%rcx,4), %ymm3
  vmovups	96(%rdi,%rcx,4), %ymm4
  vfmadd231ps	(%rsi,%rcx,4), %ymm1, %ymm0 # ymm0 = (ymm1 * mem) + ymm0
  vmovups	128(%rdi,%rcx,4), %ymm1
  vfmadd231ps	32(%rsi,%rcx,4), %ymm2, %ymm0 # ymm0 = (ymm2 * mem) + ymm0
  vfmadd231ps	64(%rsi,%rcx,4), %ymm3, %ymm0 # ymm0 = (ymm3 * mem) + ymm0
  vfmadd231ps	96(%rsi,%rcx,4), %ymm4, %ymm0 # ymm0 = (ymm4 * mem) + ymm0
  vfmadd132ps	128(%rsi,%rcx,4), %ymm0, %ymm1 # ymm1 = (ymm1 * mem) + ymm0
  vmovups	160(%rdi,%rcx,4), %ymm0
  vfmadd132ps	160(%rsi,%rcx,4), %ymm1, %ymm0 # ymm0 = (ymm0 * mem) + ymm1
  vmovups	192(%rdi,%rcx,4), %ymm1
  vfmadd132ps	192(%rsi,%rcx,4), %ymm0, %ymm1 # ymm1 = (ymm1 * mem) + ymm0
  vmovups	224(%rdi,%rcx,4), %ymm0
  vfmadd132ps	224(%rsi,%rcx,4), %ymm1, %ymm0 # ymm0 = (ymm0 * mem) + ymm1
  addq	$64, %rcx
  addq	$-8, %r8
  jne	.LBB0_9
  testq	%rax, %rax
  je	.LBB0_7
.LBB0_5:
  leaq	(%rsi,%rcx,4), %rdx
  leaq	(%rdi,%rcx,4), %rcx
  shll	$5, %eax
  xorl	%esi, %esi
  .p2align	4
  .p2align 4
.LBB0_6:
  vmovups	(%rcx,%rsi), %ymm1
  vfmadd231ps	(%rdx,%rsi), %ymm1, %ymm0 # ymm0 = (ymm1 * mem) + ymm0
  addq	$32, %rsi
  cmpq	%rsi, %rax
  jne	.LBB0_6
.LBB0_7:
  vextractf128	$1, %ymm0, %xmm1
