  testq	%rdx, %rdx
  jle	.LBB0_16
  cmpq	$8, %rdx
  jae	.LBB0_3
  xorl	%eax, %eax
  jmp	.LBB0_12
.LBB0_3:
  movabsq	$9223372036854775744, %rcx      # imm = 0x7FFFFFFFFFFFFFC0
  cmpq	$64, %rdx
  jae	.LBB0_5
  xorl	%eax, %eax
  jmp	.LBB0_9
.LBB0_5:
  vbroadcastss	%xmm0, %zmm2
  vbroadcastss	%xmm1, %zmm3
  movq	%rdx, %rax
  andq	%rcx, %rax
  xorl	%r8d, %r8d
  .p2align	4
  .p2align 4
.LBB0_6:
  vmovups	(%rdi,%r8,4), %zmm4
  vmovups	64(%rdi,%r8,4), %zmm5
  vmovups	128(%rdi,%r8,4), %zmm6
  vmovups	192(%rdi,%r8,4), %zmm7
  vmovaps	%zmm2, %zmm8
  vcmpnltps	%zmm2, %zmm4, %k1
  vcmpnltps	%zmm2, %zmm5, %k2
  vcmpnltps	%zmm2, %zmm6, %k3
  vcmpnltps	%zmm2, %zmm7, %k4
  vminps	%zmm4, %zmm3, %zmm8 {%k1}
  vmovaps	%zmm2, %zmm4
  vminps	%zmm5, %zmm3, %zmm4 {%k2}
  vmovaps	%zmm2, %zmm5
  vminps	%zmm6, %zmm3, %zmm5 {%k3}
  vmovaps	%zmm2, %zmm6
  vminps	%zmm7, %zmm3, %zmm6 {%k4}
  vmovups	%zmm8, (%rsi,%r8,4)
  vmovups	%zmm4, 64(%rsi,%r8,4)
  vmovups	%zmm5, 128(%rsi,%r8,4)
  vmovups	%zmm6, 192(%rsi,%r8,4)
  addq	$64, %r8
  cmpq	%r8, %rax
  jne	.LBB0_6
  cmpq	%rax, %rdx
  je	.LBB0_16
  testb	$56, %dl
  je	.LBB0_12
.LBB0_9:
  addq	$56, %rcx
  vbroadcastss	%xmm0, %ymm2
  vbroadcastss	%xmm1, %ymm3
  movq	%rax, %r8
  movq	%rcx, %rax
  andq	%rdx, %rax
  .p2align	4
  .p2align 4
.LBB0_10:
  vmovups	(%rdi,%r8,4), %ymm4
  vmovaps	%ymm2, %ymm5
  vcmpnltps	%ymm2, %ymm4, %k1
  vminps	%ymm4, %ymm3, %ymm5 {%k1}
  vmovups	%ymm5, (%rsi,%r8,4)
  addq	$8, %r8
  cmpq	%r8, %rax
  jne	.LBB0_10
.LBB0_11:
  cmpq	%rax, %rdx
  je	.LBB0_16
.LBB0_12:
  vmovss	(%rdi,%rax,4), %xmm3            # xmm3 = mem[0],zero,zero,zero
  vmovaps	%xmm0, %xmm2
  vucomiss	%xmm3, %xmm0
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
