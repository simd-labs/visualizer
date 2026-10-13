  testq	%rsi, %rsi
  jle	.LBB0_1
  cmpq	$4, %rsi
  jae	.LBB0_5
  xorl	%ecx, %ecx
  xorl	%r8d, %r8d
  xorl	%eax, %eax
  jmp	.LBB0_4
.LBB0_1:
  xorl	%eax, %eax
  xorl	%r8d, %r8d
  jmp	.LBB0_16
.LBB0_5:
  movabsq	$9223372036854775792, %rdx      # imm = 0x7FFFFFFFFFFFFFF0
  cmpq	$16, %rsi
  jae	.LBB0_7
  xorl	%ecx, %ecx
  xorl	%r8d, %r8d
  xorl	%eax, %eax
  jmp	.LBB0_11
.LBB0_7:
  movq	%rsi, %rcx
  andq	%rdx, %rcx
  vpxor	%xmm0, %xmm0, %xmm0
  xorl	%eax, %eax
  vpxor	%xmm5, %xmm5, %xmm5
  vpxor	%xmm6, %xmm6, %xmm6
  vpxor	%xmm7, %xmm7, %xmm7
  vpxor	%xmm8, %xmm8, %xmm8
  vpxor	%xmm1, %xmm1, %xmm1
  vpxor	%xmm2, %xmm2, %xmm2
  vpxor	%xmm3, %xmm3, %xmm3
  vpxor	%xmm4, %xmm4, %xmm4
  .p2align	4
  .p2align 4
.LBB0_8:
  vmovdqu	(%rdi,%rax,4), %xmm9
  vmovdqu	16(%rdi,%rax,4), %xmm10
  vmovdqu	32(%rdi,%rax,4), %xmm11
  vmovdqu	48(%rdi,%rax,4), %xmm12
  vpblendw	$170, %xmm5, %xmm9, %xmm13      # xmm13 = xmm9[0],xmm5[1],xmm9[2],xmm5[3],xmm9[4],xmm5[5],xmm9[6],xmm5[7]
  vpmovzxdq	%xmm13, %ymm13          # ymm13 = xmm13[0],zero,xmm13[1],zero,xmm13[2],zero,xmm13[3],zero
  vpaddq	%ymm1, %ymm13, %ymm1
  vpblendw	$170, %xmm5, %xmm10, %xmm13     # xmm13 = xmm10[0],xmm5[1],xmm10[2],xmm5[3],xmm10[4],xmm5[5],xmm10[6],xmm5[7]
  vpmovzxdq	%xmm13, %ymm13          # ymm13 = xmm13[0],zero,xmm13[1],zero,xmm13[2],zero,xmm13[3],zero
  vpaddq	%ymm2, %ymm13, %ymm2
  vpblendw	$170, %xmm5, %xmm11, %xmm13     # xmm13 = xmm11[0],xmm5[1],xmm11[2],xmm5[3],xmm11[4],xmm5[5],xmm11[6],xmm5[7]
  vpmovzxdq	%xmm13, %ymm13          # ymm13 = xmm13[0],zero,xmm13[1],zero,xmm13[2],zero,xmm13[3],zero
  vpaddq	%ymm3, %ymm13, %ymm3
  vpblendw	$170, %xmm5, %xmm12, %xmm13     # xmm13 = xmm12[0],xmm5[1],xmm12[2],xmm5[3],xmm12[4],xmm5[5],xmm12[6],xmm5[7]
  vpmovzxdq	%xmm13, %ymm13          # ymm13 = xmm13[0],zero,xmm13[1],zero,xmm13[2],zero,xmm13[3],zero
  vpaddq	%ymm4, %ymm13, %ymm4
  vpsrad	$16, %xmm9, %xmm9
  vpmovsxdq	%xmm9, %ymm9
  vpaddq	%ymm0, %ymm9, %ymm0
  vpsrad	$16, %xmm10, %xmm9
  vpmovsxdq	%xmm9, %ymm9
  vpaddq	%ymm6, %ymm9, %ymm6
  vpsrad	$16, %xmm11, %xmm9
  vpmovsxdq	%xmm9, %ymm9
  vpaddq	%ymm7, %ymm9, %ymm7
  vpsrad	$16, %xmm12, %xmm9
  vpmovsxdq	%xmm9, %ymm9
  vpaddq	%ymm9, %ymm8, %ymm8
  addq	$16, %rax
  cmpq	%rax, %rcx
  jne	.LBB0_8
  vpaddq	%ymm0, %ymm6, %ymm0
  vpaddq	%ymm0, %ymm7, %ymm0
  vpaddq	%ymm0, %ymm8, %ymm0
  vextracti128	$1, %ymm0, %xmm5
  vpaddq	%xmm5, %xmm0, %xmm0
  vpshufd	$238, %xmm0, %xmm5              # xmm5 = xmm0[2,3,2,3]
  vpaddq	%xmm5, %xmm0, %xmm0
  vmovq	%xmm0, %r8
  vpaddq	%ymm1, %ymm2, %ymm0
  vpaddq	%ymm0, %ymm3, %ymm0
  vpaddq	%ymm0, %ymm4, %ymm0
  vextracti128	$1, %ymm0, %xmm1
  vpaddq	%xmm1, %xmm0, %xmm0
  vpshufd	$238, %xmm0, %xmm1              # xmm1 = xmm0[2,3,2,3]
  vpaddq	%xmm1, %xmm0, %xmm0
  vmovq	%xmm0, %rax
  cmpq	%rcx, %rsi
  je	.LBB0_15
  testb	$12, %sil
  je	.LBB0_4
.LBB0_11:
  movq	%rcx, %r9
  addq	$12, %rdx
  movq	%rdx, %rcx
  andq	%rsi, %rcx
  vmovq	%r8, %xmm1
  vmovq	%rax, %xmm0
  vpxor	%xmm2, %xmm2, %xmm2
  .p2align	4
  .p2align 4
.LBB0_12:
  vmovdqu	(%rdi,%r9,4), %xmm3
  vpblendw	$170, %xmm2, %xmm3, %xmm4       # xmm4 = xmm3[0],xmm2[1],xmm3[2],xmm2[3],xmm3[4],xmm2[5],xmm3[6],xmm2[7]
  vpmovzxdq	%xmm4, %ymm4            # ymm4 = xmm4[0],zero,xmm4[1],zero,xmm4[2],zero,xmm4[3],zero
  vpaddq	%ymm4, %ymm0, %ymm0
  vpsrad	$16, %xmm3, %xmm3
  vpmovsxdq	%xmm3, %ymm3
  vpaddq	%ymm3, %ymm1, %ymm1
  addq	$4, %r9
  cmpq	%r9, %rcx
  jne	.LBB0_12
  vextracti128	$1, %ymm1, %xmm2
  vpaddq	%xmm2, %xmm1, %xmm1
  vpshufd	$238, %xmm1, %xmm2              # xmm2 = xmm1[2,3,2,3]
  vpaddq	%xmm2, %xmm1, %xmm1
  vmovq	%xmm1, %r8
  vextracti128	$1, %ymm0, %xmm1
  vpaddq	%xmm1, %xmm0, %xmm0
  vpshufd	$238, %xmm0, %xmm1              # xmm1 = xmm0[2,3,2,3]
  vpaddq	%xmm1, %xmm0, %xmm0
  vmovq	%xmm0, %rax
  jmp	.LBB0_14
.LBB0_4:
  movl	(%rdi,%rcx,4), %edx
  movzwl	%dx, %r9d
  addq	%r9, %rax
  sarl	$16, %edx
  movslq	%edx, %rdx
  addq	%rdx, %r8
  incq	%rcx
.LBB0_14:
  cmpq	%rcx, %rsi
  jne	.LBB0_4
.LBB0_15:
  shlq	$16, %r8
.LBB0_16:
