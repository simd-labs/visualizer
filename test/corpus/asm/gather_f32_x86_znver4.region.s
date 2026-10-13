  testq	%rcx, %rcx
  jle	.LBB0_13
  cmpq	$4, %rcx
  jae	.LBB0_4
  xorl	%eax, %eax
  jmp	.LBB0_3
.LBB0_4:
  movabsq	$9223372036854775792, %r8       # imm = 0x7FFFFFFFFFFFFFF0
  cmpq	$16, %rcx
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
  vmovups	(%rsi,%r9,4), %zmm0
  kxnorw	%k0, %k0, %k1
  vxorps	%xmm1, %xmm1, %xmm1
  vgatherdps	(%rdi,%zmm0,4), %zmm1 {%k1}
  vmovups	%zmm1, (%rdx,%r9,4)
  addq	$16, %r9
  cmpq	%r9, %rax
  jne	.LBB0_7
  cmpq	%rax, %rcx
  je	.LBB0_13
  testb	$12, %cl
  je	.LBB0_3
.LBB0_10:
  addq	$12, %r8
  movq	%rax, %r9
  movq	%r8, %rax
  andq	%rcx, %rax
  .p2align	4
  .p2align 4
.LBB0_11:
  vmovups	(%rsi,%r9,4), %xmm0
  kxnorw	%k0, %k0, %k1
  vxorps	%xmm1, %xmm1, %xmm1
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
