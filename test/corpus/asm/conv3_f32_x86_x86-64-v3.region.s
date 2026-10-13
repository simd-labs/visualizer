  cmpq	$3, %rcx
  jl	.LBB0_8
  vmovss	(%rdx), %xmm0                   # xmm0 = mem[0],zero,zero,zero
  vmovss	4(%rdx), %xmm1                  # xmm1 = mem[0],zero,zero,zero
  vmovss	8(%rdx), %xmm2                  # xmm2 = mem[0],zero,zero,zero
  vmovss	4(%rdi), %xmm6                  # xmm6 = mem[0],zero,zero,zero
  leaq	-2(%rcx), %r8
  cmpq	$32, %r8
  jae	.LBB0_3
  movl	$1, %eax
  movl	$2, %edx
  jmp	.LBB0_7
.LBB0_3:
  movq	%r8, %r9
  andq	$-32, %r9
  leaq	2(%r9), %rdx
  leaq	1(%r9), %rax
  vbroadcastss	%xmm0, %ymm3
  vbroadcastss	%xmm1, %ymm4
  vbroadcastss	%xmm2, %ymm5
  vbroadcastss	%xmm6, %ymm6
  xorl	%r10d, %r10d
  .p2align	4
  .p2align 4
.LBB0_4:
  vmovups	8(%rdi,%r10,4), %ymm7
  vmovups	40(%rdi,%r10,4), %ymm8
  vmovups	72(%rdi,%r10,4), %ymm9
  vperm2f128	$33, %ymm7, %ymm6, %ymm10 # ymm10 = ymm6[2,3],ymm7[0,1]
  vmovups	104(%rdi,%r10,4), %ymm6
  vshufps	$3, %ymm7, %ymm10, %ymm10       # ymm10 = ymm10[3,0],ymm7[0,0],ymm10[7,4],ymm7[4,4]
  vshufps	$152, %ymm7, %ymm10, %ymm10     # ymm10 = ymm10[0,2],ymm7[1,2],ymm10[4,6],ymm7[5,6]
  vperm2f128	$33, %ymm8, %ymm7, %ymm11 # ymm11 = ymm7[2,3],ymm8[0,1]
  vshufps	$3, %ymm8, %ymm11, %ymm11       # ymm11 = ymm11[3,0],ymm8[0,0],ymm11[7,4],ymm8[4,4]
  vshufps	$152, %ymm8, %ymm11, %ymm11     # ymm11 = ymm11[0,2],ymm8[1,2],ymm11[4,6],ymm8[5,6]
  vperm2f128	$33, %ymm9, %ymm8, %ymm12 # ymm12 = ymm8[2,3],ymm9[0,1]
  vshufps	$3, %ymm9, %ymm12, %ymm12       # ymm12 = ymm12[3,0],ymm9[0,0],ymm12[7,4],ymm9[4,4]
  vshufps	$152, %ymm9, %ymm12, %ymm12     # ymm12 = ymm12[0,2],ymm9[1,2],ymm12[4,6],ymm9[5,6]
  vperm2f128	$33, %ymm6, %ymm9, %ymm13 # ymm13 = ymm9[2,3],ymm6[0,1]
  vshufps	$3, %ymm6, %ymm13, %ymm13       # ymm13 = ymm13[3,0],ymm6[0,0],ymm13[7,4],ymm6[4,4]
  vshufps	$152, %ymm6, %ymm13, %ymm13     # ymm13 = ymm13[0,2],ymm6[1,2],ymm13[4,6],ymm6[5,6]
  vmulps	%ymm4, %ymm10, %ymm10
  vmulps	%ymm4, %ymm11, %ymm11
  vmulps	%ymm4, %ymm12, %ymm12
  vmulps	%ymm4, %ymm13, %ymm13
  vfmadd231ps	(%rdi,%r10,4), %ymm3, %ymm10 # ymm10 = (ymm3 * mem) + ymm10
  vfmadd231ps	32(%rdi,%r10,4), %ymm3, %ymm11 # ymm11 = (ymm3 * mem) + ymm11
  vfmadd231ps	64(%rdi,%r10,4), %ymm3, %ymm12 # ymm12 = (ymm3 * mem) + ymm12
  vfmadd231ps	96(%rdi,%r10,4), %ymm3, %ymm13 # ymm13 = (ymm3 * mem) + ymm13
  vfmadd231ps	%ymm7, %ymm5, %ymm10    # ymm10 = (ymm5 * ymm7) + ymm10
  vfmadd231ps	%ymm8, %ymm5, %ymm11    # ymm11 = (ymm5 * ymm8) + ymm11
  vfmadd231ps	%ymm9, %ymm5, %ymm12    # ymm12 = (ymm5 * ymm9) + ymm12
  vfmadd231ps	%ymm5, %ymm6, %ymm13    # ymm13 = (ymm6 * ymm5) + ymm13
  vmovups	%ymm10, 4(%rsi,%r10,4)
  vmovups	%ymm11, 36(%rsi,%r10,4)
  vmovups	%ymm12, 68(%rsi,%r10,4)
  vmovups	%ymm13, 100(%rsi,%r10,4)
  addq	$32, %r10
  cmpq	%r10, %r9
  jne	.LBB0_4
  cmpq	%r9, %r8
  je	.LBB0_8
  vextractf128	$1, %ymm6, %xmm3
  vshufps	$255, %xmm3, %xmm3, %xmm6       # xmm6 = xmm3[3,3,3,3]
  .p2align	4
  .p2align 4
.LBB0_7:
  movq	%rax, %r8
  movq	%rdx, %rax
  vmulss	%xmm1, %xmm6, %xmm3
  vfmadd231ss	-4(%rdi,%r8,4), %xmm0, %xmm3 # xmm3 = (xmm0 * mem) + xmm3
  vmovss	(%rdi,%rdx,4), %xmm6            # xmm6 = mem[0],zero,zero,zero
  vfmadd231ss	%xmm2, %xmm6, %xmm3     # xmm3 = (xmm6 * xmm2) + xmm3
  vmovss	%xmm3, (%rsi,%r8,4)
  incq	%rdx
  cmpq	%rdx, %rcx
  jne	.LBB0_7
.LBB0_8:
