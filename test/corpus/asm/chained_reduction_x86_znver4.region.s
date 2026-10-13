  testq	%rsi, %rsi
  jle	.LBB0_1
  vmovss	.LCPI0_0(%rip), %xmm1           # xmm1 = [1.0E+0,0.0E+0,0.0E+0,0.0E+0]
  movl	%esi, %eax
  andl	$7, %eax
  cmpq	$8, %rsi
  jae	.LBB0_8
  xorl	%ecx, %ecx
  vmovaps	%xmm1, %xmm0
  jmp	.LBB0_5
.LBB0_1:
  vmovss	.LCPI0_0(%rip), %xmm0           # xmm0 = [1.0E+0,0.0E+0,0.0E+0,0.0E+0]
