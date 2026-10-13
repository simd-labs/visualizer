  testq	%rdx, %rdx
  jle	.LBB0_13
  cmpq	$8, %rdx
  jae	.LBB0_4
  xorl	%eax, %eax
  jmp	.LBB0_3
.LBB0_4:
  movabsq	$9223372036854775744, %rcx      # imm = 0x7FFFFFFFFFFFFFC0
  cmpq	$64, %rdx
  jae	.LBB0_6
  xorl	%eax, %eax
  jmp	.LBB0_10
.LBB0_6:
  vbroadcastss	%xmm0, %zmm1
  movq	%rdx, %rax
  andq	%rcx, %rax
  xorl	%r8d, %r8d
  .p2align	4
  .p2align 4
.LBB0_7:
  vmovups	(%rdi,%r8,4), %zmm2
  vmovups	64(%rdi,%r8,4), %zmm3
  vmovups	128(%rdi,%r8,4), %zmm4
  vmovups	192(%rdi,%r8,4), %zmm5
  vfmadd213ps	(%rsi,%r8,4), %zmm1, %zmm2 # zmm2 = (zmm1 * zmm2) + mem
  vfmadd213ps	64(%rsi,%r8,4), %zmm1, %zmm3 # zmm3 = (zmm1 * zmm3) + mem
  vfmadd213ps	128(%rsi,%r8,4), %zmm1, %zmm4 # zmm4 = (zmm1 * zmm4) + mem
  vfmadd213ps	192(%rsi,%r8,4), %zmm1, %zmm5 # zmm5 = (zmm1 * zmm5) + mem
  vmovups	%zmm2, (%rsi,%r8,4)
  vmovups	%zmm3, 64(%rsi,%r8,4)
  vmovups	%zmm4, 128(%rsi,%r8,4)
  vmovups	%zmm5, 192(%rsi,%r8,4)
  addq	$64, %r8
  cmpq	%r8, %rax
  jne	.LBB0_7
  cmpq	%rax, %rdx
  je	.LBB0_13
  testb	$56, %dl
  je	.LBB0_3
.LBB0_10:
  addq	$56, %rcx
  vbroadcastss	%xmm0, %ymm1
  movq	%rax, %r8
  movq	%rcx, %rax
  andq	%rdx, %rax
  .p2align	4
  .p2align 4
.LBB0_11:
  vmovups	(%rdi,%r8,4), %ymm2
  vfmadd213ps	(%rsi,%r8,4), %ymm1, %ymm2 # ymm2 = (ymm1 * ymm2) + mem
  vmovups	%ymm2, (%rsi,%r8,4)
  addq	$8, %r8
  cmpq	%r8, %rax
  jne	.LBB0_11
  jmp	.LBB0_12
.LBB0_3:
  vmovss	(%rdi,%rax,4), %xmm1            # xmm1 = mem[0],zero,zero,zero
  vfmadd213ss	(%rsi,%rax,4), %xmm0, %xmm1 # xmm1 = (xmm0 * xmm1) + mem
  vmovss	%xmm1, (%rsi,%rax,4)
  incq	%rax
.LBB0_12:
  cmpq	%rax, %rdx
  jne	.LBB0_3
.LBB0_13:
