  testq	%rdx, %rdx
  jle	.LBB0_10
  cmpq	$8, %rdx
  jae	.LBB0_3
  xorl	%eax, %eax
  jmp	.LBB0_6
.LBB0_3:
  movabsq	$9223372036854775800, %rax      # imm = 0x7FFFFFFFFFFFFFF8
  andq	%rdx, %rax
  movaps	%xmm0, %xmm2
  movaps	%xmm0, %xmm3
  shufps	$0, %xmm0, %xmm3                # xmm3 = xmm3[0,0],xmm0[0,0]
  movaps	%xmm1, %xmm4
  shufps	$0, %xmm1, %xmm4                # xmm4 = xmm4[0,0],xmm1[0,0]
  xorl	%ecx, %ecx
  .p2align	4
  .p2align 4
.LBB0_4:
  movups	(%rdi,%rcx,4), %xmm0
  movaps	%xmm4, %xmm5
  minps	%xmm0, %xmm5
  cmpnltps	%xmm3, %xmm0
  movaps	%xmm3, %xmm6
  blendvps	%xmm0, %xmm5, %xmm6
  movups	16(%rdi,%rcx,4), %xmm0
  movaps	%xmm4, %xmm5
  minps	%xmm0, %xmm5
  cmpnltps	%xmm3, %xmm0
  movaps	%xmm3, %xmm7
  blendvps	%xmm0, %xmm5, %xmm7
  movups	%xmm6, (%rsi,%rcx,4)
  movups	%xmm7, 16(%rsi,%rcx,4)
  addq	$8, %rcx
  cmpq	%rcx, %rax
  jne	.LBB0_4
  cmpq	%rax, %rdx
  movaps	%xmm2, %xmm0
  jne	.LBB0_6
.LBB0_10:
