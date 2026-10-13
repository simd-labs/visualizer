  testq	%rsi, %rsi
  jle	.LBB0_1
  movl	%esi, %eax
  andl	$3, %eax
  movss	.LCPI0_0(%rip), %xmm1           # xmm1 = [1.0E+0,0.0E+0,0.0E+0,0.0E+0]
  cmpq	$4, %rsi
  jae	.LBB0_8
  xorl	%ecx, %ecx
  movaps	%xmm1, %xmm0
  jmp	.LBB0_5
.LBB0_1:
  movss	.LCPI0_0(%rip), %xmm0           # xmm0 = [1.0E+0,0.0E+0,0.0E+0,0.0E+0]
