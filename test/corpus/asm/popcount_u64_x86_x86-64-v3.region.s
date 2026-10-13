  testq	%rdx, %rdx
  jle	.LBB0_13
  cmpq	$4, %rdx
  jae	.LBB0_4
  xorl	%eax, %eax
  jmp	.LBB0_3
.LBB0_4:
  movabsq	$9223372036854775792, %rcx      # imm = 0x7FFFFFFFFFFFFFF0
  cmpq	$16, %rdx
  jae	.LBB0_6
  xorl	%eax, %eax
  jmp	.LBB0_10
.LBB0_6:
  movq	%rdx, %rax
  andq	%rcx, %rax
  xorl	%r8d, %r8d
  vpbroadcastd	.LCPI0_4(%rip), %ymm0   # ymm0 = [15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15]
  vbroadcasti128	.LCPI0_5(%rip), %ymm1   # ymm1 = [0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4,0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4]
                                          # ymm1 = mem[0,1,0,1]
  vpxor	%xmm2, %xmm2, %xmm2
  vmovdqa	.LCPI0_2(%rip), %ymm3           # ymm3 = [0,2,4,6,4,6,6,7]
  .p2align	4
  .p2align 4
.LBB0_7:
  vmovdqu	(%rdi,%r8,8), %ymm4
  vmovdqu	32(%rdi,%r8,8), %ymm5
  vmovdqu	64(%rdi,%r8,8), %ymm6
  vmovdqu	96(%rdi,%r8,8), %ymm7
  vpand	%ymm0, %ymm4, %ymm8
  vpshufb	%ymm8, %ymm1, %ymm8
  vpsrlw	$4, %ymm4, %ymm4
  vpand	%ymm0, %ymm4, %ymm4
  vpshufb	%ymm4, %ymm1, %ymm4
  vpaddb	%ymm4, %ymm8, %ymm4
  vpsadbw	%ymm2, %ymm4, %ymm4
  vpand	%ymm0, %ymm5, %ymm8
  vpshufb	%ymm8, %ymm1, %ymm8
  vpsrlw	$4, %ymm5, %ymm5
  vpand	%ymm0, %ymm5, %ymm5
  vpshufb	%ymm5, %ymm1, %ymm5
  vpaddb	%ymm5, %ymm8, %ymm5
  vpsadbw	%ymm2, %ymm5, %ymm5
  vpand	%ymm0, %ymm6, %ymm8
  vpshufb	%ymm8, %ymm1, %ymm8
  vpsrlw	$4, %ymm6, %ymm6
  vpand	%ymm0, %ymm6, %ymm6
  vpshufb	%ymm6, %ymm1, %ymm6
  vpaddb	%ymm6, %ymm8, %ymm6
  vpsadbw	%ymm2, %ymm6, %ymm6
  vpand	%ymm0, %ymm7, %ymm8
  vpshufb	%ymm8, %ymm1, %ymm8
  vpsrlw	$4, %ymm7, %ymm7
  vpand	%ymm0, %ymm7, %ymm7
  vpshufb	%ymm7, %ymm1, %ymm7
  vpaddb	%ymm7, %ymm8, %ymm7
  vpsadbw	%ymm2, %ymm7, %ymm7
  vpermd	%ymm4, %ymm3, %ymm4
  vpermd	%ymm5, %ymm3, %ymm5
  vpermd	%ymm6, %ymm3, %ymm6
  vpermd	%ymm7, %ymm3, %ymm7
  vmovdqu	%xmm4, (%rsi,%r8,4)
  vmovdqu	%xmm5, 16(%rsi,%r8,4)
  vmovdqu	%xmm6, 32(%rsi,%r8,4)
  vmovdqu	%xmm7, 48(%rsi,%r8,4)
  addq	$16, %r8
  cmpq	%r8, %rax
  jne	.LBB0_7
  cmpq	%rax, %rdx
  je	.LBB0_13
  testb	$12, %dl
  je	.LBB0_3
.LBB0_10:
  movq	%rax, %r8
  addq	$12, %rcx
  movq	%rcx, %rax
  andq	%rdx, %rax
  vpbroadcastd	.LCPI0_4(%rip), %ymm0   # ymm0 = [15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15]
  vbroadcasti128	.LCPI0_5(%rip), %ymm1   # ymm1 = [0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4,0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4]
                                          # ymm1 = mem[0,1,0,1]
  vpxor	%xmm2, %xmm2, %xmm2
  vbroadcasti128	.LCPI0_6(%rip), %ymm3   # ymm3 = [0,2,4,6,0,2,4,6]
                                          # ymm3 = mem[0,1,0,1]
  .p2align	4
  .p2align 4
.LBB0_11:
  vmovdqu	(%rdi,%r8,8), %ymm4
  vpand	%ymm0, %ymm4, %ymm5
  vpshufb	%ymm5, %ymm1, %ymm5
  vpsrlw	$4, %ymm4, %ymm4
  vpand	%ymm0, %ymm4, %ymm4
  vpshufb	%ymm4, %ymm1, %ymm4
  vpaddb	%ymm5, %ymm4, %ymm4
  vpsadbw	%ymm2, %ymm4, %ymm4
  vpermd	%ymm4, %ymm3, %ymm4
  vmovdqu	%xmm4, (%rsi,%r8,4)
  addq	$4, %r8
  cmpq	%r8, %rax
  jne	.LBB0_11
  jmp	.LBB0_12
.LBB0_3:
  xorl	%ecx, %ecx
  popcntq	(%rdi,%rax,8), %rcx
  movl	%ecx, (%rsi,%rax,4)
  incq	%rax
.LBB0_12:
  cmpq	%rax, %rdx
  jne	.LBB0_3
.LBB0_13:
