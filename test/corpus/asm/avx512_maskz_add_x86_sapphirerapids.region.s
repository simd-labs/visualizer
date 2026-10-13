  testq	%rcx, %rcx
  jle	.LBB0_6
  leaq	-1(%rcx), %r8
  shrq	$4, %r8
  incq	%r8
  movl	%r8d, %eax
  andl	$7, %eax
  cmpq	$113, %rcx
  jae	.LBB0_7
  xorl	%ecx, %ecx
  jmp	.LBB0_4
.LBB0_7:
  andq	$-8, %r8
  leaq	448(%rdx), %r9
  xorl	%ecx, %ecx
  vbroadcastss	.LCPI0_0(%rip), %zmm0   # zmm0 = [5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1]
  .p2align	4
  .p2align 4
.LBB0_8:
  vmovups	(%rdi,%rcx,4), %zmm1
  vcmpltps	%zmm1, %zmm0, %k1
  vaddps	(%rsi,%rcx,4), %zmm1, %zmm1
  vmovups	%zmm1, -448(%r9,%rcx,4) {%k1}
  vmovups	64(%rdi,%rcx,4), %zmm1
  vcmpltps	%zmm1, %zmm0, %k1
  vaddps	64(%rsi,%rcx,4), %zmm1, %zmm1
  vmovups	%zmm1, -384(%r9,%rcx,4) {%k1}
  vmovups	128(%rdi,%rcx,4), %zmm1
  vcmpltps	%zmm1, %zmm0, %k1
  vaddps	128(%rsi,%rcx,4), %zmm1, %zmm1
  vmovups	%zmm1, -320(%r9,%rcx,4) {%k1}
  vmovups	192(%rdi,%rcx,4), %zmm1
  vcmpltps	%zmm1, %zmm0, %k1
  vaddps	192(%rsi,%rcx,4), %zmm1, %zmm1
  vmovups	%zmm1, -256(%r9,%rcx,4) {%k1}
  vmovups	256(%rdi,%rcx,4), %zmm1
  vcmpltps	%zmm1, %zmm0, %k1
  vaddps	256(%rsi,%rcx,4), %zmm1, %zmm1
  vmovups	%zmm1, -192(%r9,%rcx,4) {%k1}
  vmovups	320(%rdi,%rcx,4), %zmm1
  vcmpltps	%zmm1, %zmm0, %k1
  vaddps	320(%rsi,%rcx,4), %zmm1, %zmm1
  vmovups	%zmm1, -128(%r9,%rcx,4) {%k1}
  vmovups	384(%rdi,%rcx,4), %zmm1
  vcmpltps	%zmm1, %zmm0, %k1
  vaddps	384(%rsi,%rcx,4), %zmm1, %zmm1
  vmovups	%zmm1, -64(%r9,%rcx,4) {%k1}
  vmovups	448(%rdi,%rcx,4), %zmm1
  vcmpltps	%zmm1, %zmm0, %k1
  vaddps	448(%rsi,%rcx,4), %zmm1, %zmm1
  vmovups	%zmm1, (%r9,%rcx,4) {%k1}
  subq	$-128, %rcx
  addq	$-8, %r8
  jne	.LBB0_8
  testq	%rax, %rax
  je	.LBB0_6
.LBB0_4:
  leaq	(%rdx,%rcx,4), %rdx
  leaq	(%rsi,%rcx,4), %rsi
  leaq	(%rdi,%rcx,4), %rcx
  shll	$6, %eax
  xorl	%edi, %edi
  vbroadcastss	.LCPI0_0(%rip), %zmm0   # zmm0 = [5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1,5.0E-1]
  .p2align	4
  .p2align 4
.LBB0_5:
  vmovups	(%rcx,%rdi), %zmm1
  vcmpgtps	%zmm0, %zmm1, %k1
  vaddps	(%rsi,%rdi), %zmm1, %zmm1
  vmovups	%zmm1, (%rdx,%rdi) {%k1}
  addq	$64, %rdi
  cmpq	%rdi, %rax
  jne	.LBB0_5
.LBB0_6:
