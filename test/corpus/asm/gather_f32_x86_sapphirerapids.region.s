  testq	%rcx, %rcx
  jle	.LBB0_13
  cmpq	$4, %rcx
  jae	.LBB0_4
  xorl	%eax, %eax
  jmp	.LBB0_3
.LBB0_4:
  movabsq	$9223372036854775776, %r8       # imm = 0x7FFFFFFFFFFFFFE0
  cmpq	$32, %rcx
  jae	.LBB0_6
  xorl	%eax, %eax
  jmp	.LBB0_10
.LBB0_6:
  movq	%rcx, %rax
  andq	%r8, %rax
  xorl	%r9d, %r9d
  .p2align	4
  .p2align 4
.LBB0_7:
  vmovups	(%rsi,%r9,4), %ymm0
  vxorps	%xmm1, %xmm1, %xmm1
  kxnorb	%k0, %k0, %k1
  vgatherdps	(%rdi,%ymm0,4), %ymm1 {%k1}
  vmovups	32(%rsi,%r9,4), %ymm0
  vxorps	%xmm2, %xmm2, %xmm2
  kxnorb	%k0, %k0, %k1
  vgatherdps	(%rdi,%ymm0,4), %ymm2 {%k1}
  vmovups	64(%rsi,%r9,4), %ymm0
  vxorps	%xmm3, %xmm3, %xmm3
  kxnorb	%k0, %k0, %k1
  vgatherdps	(%rdi,%ymm0,4), %ymm3 {%k1}
  vmovups	96(%rsi,%r9,4), %ymm0
  vxorps	%xmm4, %xmm4, %xmm4
  kxnorb	%k0, %k0, %k1
  vgatherdps	(%rdi,%ymm0,4), %ymm4 {%k1}
  vmovups	%ymm1, (%rdx,%r9,4)
  vmovups	%ymm2, 32(%rdx,%r9,4)
  vmovups	%ymm3, 64(%rdx,%r9,4)
  vmovups	%ymm4, 96(%rdx,%r9,4)
  addq	$32, %r9
  cmpq	%r9, %rax
  jne	.LBB0_7
  cmpq	%rax, %rcx
  je	.LBB0_13
  testb	$28, %cl
  je	.LBB0_3
.LBB0_10:
  movq	%rax, %r9
  addq	$28, %r8
  movq	%r8, %rax
  andq	%rcx, %rax
  .p2align	4
  .p2align 4
.LBB0_11:
  vmovups	(%rsi,%r9,4), %xmm0
  vxorps	%xmm1, %xmm1, %xmm1
  kxnorw	%k0, %k0, %k1
  vgatherdps	(%rdi,%xmm0,4), %xmm1 {%k1}
  vmovups	%xmm1, (%rdx,%r9,4)
  addq	$4, %r9
  cmpq	%r9, %rax
  jne	.LBB0_11
  jmp	.LBB0_12
.LBB0_3:
  movslq	(%rsi,%rax,4), %r8
  vmovss	(%rdi,%r8,4), %xmm0             # xmm0 = mem[0],zero,zero,zero
  vmovss	%xmm0, (%rdx,%rax,4)
  incq	%rax
.LBB0_12:
  cmpq	%rax, %rcx
  jne	.LBB0_3
.LBB0_13:
