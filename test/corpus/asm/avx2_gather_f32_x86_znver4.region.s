  testq	%rcx, %rcx
  jle	.LBB0_6
  leaq	-1(%rcx), %r8
  shrq	$3, %r8
  incq	%r8
  movl	%r8d, %eax
  andl	$7, %eax
  cmpq	$57, %rcx
  jae	.LBB0_7
  xorl	%ecx, %ecx
  jmp	.LBB0_4
.LBB0_7:
  andq	$-8, %r8
  xorl	%ecx, %ecx
  .p2align	4
  .p2align 4
.LBB0_8:
  vmovups	(%rsi,%rcx,4), %ymm0
  vpcmpeqd	%ymm2, %ymm2, %ymm2
  vxorps	%xmm1, %xmm1, %xmm1
  vgatherdps	%ymm2, (%rdi,%ymm0,4), %ymm1
  vmovups	32(%rsi,%rcx,4), %ymm0
  vmovups	%ymm1, (%rdx,%rcx,4)
  vpcmpeqd	%ymm2, %ymm2, %ymm2
  vxorps	%xmm1, %xmm1, %xmm1
  vgatherdps	%ymm2, (%rdi,%ymm0,4), %ymm1
  vmovups	64(%rsi,%rcx,4), %ymm0
  vmovups	%ymm1, 32(%rdx,%rcx,4)
  vpcmpeqd	%ymm2, %ymm2, %ymm2
  vxorps	%xmm1, %xmm1, %xmm1
  vgatherdps	%ymm2, (%rdi,%ymm0,4), %ymm1
  vmovups	96(%rsi,%rcx,4), %ymm0
  vmovups	%ymm1, 64(%rdx,%rcx,4)
  vpcmpeqd	%ymm2, %ymm2, %ymm2
  vxorps	%xmm1, %xmm1, %xmm1
  vgatherdps	%ymm2, (%rdi,%ymm0,4), %ymm1
  vmovups	128(%rsi,%rcx,4), %ymm0
  vmovups	%ymm1, 96(%rdx,%rcx,4)
  vpcmpeqd	%ymm2, %ymm2, %ymm2
  vxorps	%xmm1, %xmm1, %xmm1
  vgatherdps	%ymm2, (%rdi,%ymm0,4), %ymm1
  vmovups	160(%rsi,%rcx,4), %ymm0
  vmovups	%ymm1, 128(%rdx,%rcx,4)
  vpcmpeqd	%ymm2, %ymm2, %ymm2
  vxorps	%xmm1, %xmm1, %xmm1
  vgatherdps	%ymm2, (%rdi,%ymm0,4), %ymm1
  vmovups	192(%rsi,%rcx,4), %ymm0
  vmovups	%ymm1, 160(%rdx,%rcx,4)
  vpcmpeqd	%ymm2, %ymm2, %ymm2
  vxorps	%xmm1, %xmm1, %xmm1
  vgatherdps	%ymm2, (%rdi,%ymm0,4), %ymm1
  vmovups	224(%rsi,%rcx,4), %ymm0
  vmovups	%ymm1, 192(%rdx,%rcx,4)
  vpcmpeqd	%ymm2, %ymm2, %ymm2
  vxorps	%xmm1, %xmm1, %xmm1
  vgatherdps	%ymm2, (%rdi,%ymm0,4), %ymm1
  vmovups	%ymm1, 224(%rdx,%rcx,4)
  addq	$64, %rcx
  addq	$-8, %r8
  jne	.LBB0_8
  testq	%rax, %rax
  je	.LBB0_6
.LBB0_4:
  leaq	(%rdx,%rcx,4), %rdx
  leaq	(%rsi,%rcx,4), %rcx
  shll	$5, %eax
  xorl	%esi, %esi
  .p2align	4
  .p2align 4
.LBB0_5:
  vmovups	(%rcx,%rsi), %ymm0
  vpcmpeqd	%ymm1, %ymm1, %ymm1
  vxorps	%xmm2, %xmm2, %xmm2
  vgatherdps	%ymm1, (%rdi,%ymm0,4), %ymm2
  vmovups	%ymm2, (%rdx,%rsi)
  addq	$32, %rsi
  cmpq	%rsi, %rax
  jne	.LBB0_5
.LBB0_6:
