  testq	%rdx, %rdx
  jle	.LBB0_16
  cmpq	$8, %rdx
  jae	.LBB0_3
  xorl	%eax, %eax
  jmp	.LBB0_12
.LBB0_3:
  movabsq	$9223372036854775776, %rcx      # imm = 0x7FFFFFFFFFFFFFE0
  cmpq	$32, %rdx
  jae	.LBB0_5
  xorl	%eax, %eax
  jmp	.LBB0_9
.LBB0_5:
  movq	%rdx, %rax
  andq	%rcx, %rax
  vbroadcastss	%xmm0, %ymm2
  vbroadcastss	%xmm1, %ymm3
  xorl	%r8d, %r8d
  .p2align	4
  .p2align 4
.LBB0_6:
  vmovups	(%rdi,%r8,4), %ymm4
  vmovups	32(%rdi,%r8,4), %ymm5
  vmovups	64(%rdi,%r8,4), %ymm6
  vmovups	96(%rdi,%r8,4), %ymm7
  vcmpnltps	%ymm2, %ymm4, %ymm8
  vcmpnltps	%ymm2, %ymm5, %ymm9
  vcmpnltps	%ymm2, %ymm6, %ymm10
  vminps	%ymm4, %ymm3, %ymm4
  vblendvps	%ymm8, %ymm4, %ymm2, %ymm4
  vcmpnltps	%ymm2, %ymm7, %ymm8
  vminps	%ymm5, %ymm3, %ymm5
  vblendvps	%ymm9, %ymm5, %ymm2, %ymm5
  vminps	%ymm6, %ymm3, %ymm6
  vblendvps	%ymm10, %ymm6, %ymm2, %ymm6
  vminps	%ymm7, %ymm3, %ymm7
  vblendvps	%ymm8, %ymm7, %ymm2, %ymm7
  vmovups	%ymm4, (%rsi,%r8,4)
  vmovups	%ymm5, 32(%rsi,%r8,4)
  vmovups	%ymm6, 64(%rsi,%r8,4)
  vmovups	%ymm7, 96(%rsi,%r8,4)
  addq	$32, %r8
  cmpq	%r8, %rax
  jne	.LBB0_6
  cmpq	%rax, %rdx
  je	.LBB0_16
  testb	$24, %dl
  je	.LBB0_12
.LBB0_9:
  movq	%rax, %r8
  addq	$24, %rcx
  movq	%rcx, %rax
  andq	%rdx, %rax
  vbroadcastss	%xmm0, %ymm2
  vbroadcastss	%xmm1, %ymm3
  .p2align	4
  .p2align 4
.LBB0_10:
  vmovups	(%rdi,%r8,4), %ymm4
  vcmpnltps	%ymm2, %ymm4, %ymm5
  vminps	%ymm4, %ymm3, %ymm4
  vblendvps	%ymm5, %ymm4, %ymm2, %ymm4
  vmovups	%ymm4, (%rsi,%r8,4)
  addq	$8, %r8
  cmpq	%r8, %rax
  jne	.LBB0_10
.LBB0_11:
  cmpq	%rax, %rdx
  je	.LBB0_16
.LBB0_12:
  vmovss	(%rdi,%rax,4), %xmm3            # xmm3 = mem[0],zero,zero,zero
  vucomiss	%xmm3, %xmm0
  vmovaps	%xmm0, %xmm2
  ja	.LBB0_15
  vucomiss	%xmm1, %xmm3
  vmovaps	%xmm3, %xmm2
  jbe	.LBB0_15
  vmovaps	%xmm1, %xmm2
.LBB0_15:
  vmovss	%xmm2, (%rsi,%rax,4)
  incq	%rax
  jmp	.LBB0_11
.LBB0_16:
