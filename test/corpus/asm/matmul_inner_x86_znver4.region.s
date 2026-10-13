  testq	%rcx, %rcx
  jle	.LBB0_49
  pushq	%r15
  pushq	%r14
  pushq	%rbx
  leaq	(%rdi,%r8,4), %r9
  imulq	%rcx, %r8
  movabsq	$9223372036854775744, %rdi      # imm = 0x7FFFFFFFFFFFFFC0
  vmovss	(%r9), %xmm0                    # xmm0 = mem[0],zero,zero,zero
  leaq	(%rsi,%r8,4), %rax
  cmpq	$8, %rcx
  jae	.LBB0_4
  xorl	%r10d, %r10d
  jmp	.LBB0_3
.LBB0_4:
  cmpq	$64, %rcx
  jae	.LBB0_6
  xorl	%r10d, %r10d
  jmp	.LBB0_10
.LBB0_6:
  vbroadcastss	%xmm0, %zmm1
  leaq	192(%rsi,%r8,4), %r11
  movq	%rcx, %r10
  andq	%rdi, %r10
  xorl	%ebx, %ebx
  .p2align	4
  .p2align 4
.LBB0_7:
  vmovups	-192(%r11,%rbx,4), %zmm2
  vmovups	-128(%r11,%rbx,4), %zmm3
  vmovups	-64(%r11,%rbx,4), %zmm4
  vmovups	(%r11,%rbx,4), %zmm5
  vfmadd213ps	(%rdx,%rbx,4), %zmm1, %zmm2 # zmm2 = (zmm1 * zmm2) + mem
  vfmadd213ps	64(%rdx,%rbx,4), %zmm1, %zmm3 # zmm3 = (zmm1 * zmm3) + mem
  vfmadd213ps	128(%rdx,%rbx,4), %zmm1, %zmm4 # zmm4 = (zmm1 * zmm4) + mem
  vfmadd213ps	192(%rdx,%rbx,4), %zmm1, %zmm5 # zmm5 = (zmm1 * zmm5) + mem
  vmovups	%zmm2, (%rdx,%rbx,4)
  vmovups	%zmm3, 64(%rdx,%rbx,4)
  vmovups	%zmm4, 128(%rdx,%rbx,4)
  vmovups	%zmm5, 192(%rdx,%rbx,4)
  addq	$64, %rbx
  cmpq	%rbx, %r10
  jne	.LBB0_7
  cmpq	%r10, %rcx
  je	.LBB0_13
  testb	$56, %cl
  je	.LBB0_3
.LBB0_10:
  movq	%r10, %r11
  leaq	56(%rdi), %r10
  vbroadcastss	%xmm0, %ymm1
  andq	%rcx, %r10
  .p2align	4
  .p2align 4
.LBB0_11:
  vmovups	(%rax,%r11,4), %ymm2
  vfmadd213ps	(%rdx,%r11,4), %ymm1, %ymm2 # ymm2 = (ymm1 * ymm2) + mem
  vmovups	%ymm2, (%rdx,%r11,4)
  addq	$8, %r11
  cmpq	%r11, %r10
  jne	.LBB0_11
  jmp	.LBB0_12
.LBB0_3:
  vmovss	(%rax,%r10,4), %xmm1            # xmm1 = mem[0],zero,zero,zero
  vfmadd213ss	(%rdx,%r10,4), %xmm0, %xmm1 # xmm1 = (xmm0 * xmm1) + mem
  vmovss	%xmm1, (%rdx,%r10,4)
  incq	%r10
.LBB0_12:
  cmpq	%r10, %rcx
  jne	.LBB0_3
.LBB0_13:
  vmovss	(%r9,%rcx,4), %xmm0             # xmm0 = mem[0],zero,zero,zero
  leaq	(%rdx,%rcx,4), %r10
  cmpq	$8, %rcx
  jae	.LBB0_16
  xorl	%r11d, %r11d
  jmp	.LBB0_15
.LBB0_16:
  cmpq	$64, %rcx
  jae	.LBB0_18
  xorl	%r11d, %r11d
  jmp	.LBB0_22
.LBB0_18:
  vbroadcastss	%xmm0, %zmm1
  leaq	192(%rdx,%rcx,4), %rbx
  leaq	192(%rsi,%r8,4), %r14
  movq	%rcx, %r11
  andq	%rdi, %r11
  xorl	%r15d, %r15d
  .p2align	4
  .p2align 4
.LBB0_19:
  vmovups	-192(%r14,%r15,4), %zmm2
  vmovups	-128(%r14,%r15,4), %zmm3
  vmovups	-64(%r14,%r15,4), %zmm4
  vmovups	(%r14,%r15,4), %zmm5
  vfmadd213ps	-192(%rbx,%r15,4), %zmm1, %zmm2 # zmm2 = (zmm1 * zmm2) + mem
  vfmadd213ps	-128(%rbx,%r15,4), %zmm1, %zmm3 # zmm3 = (zmm1 * zmm3) + mem
  vfmadd213ps	-64(%rbx,%r15,4), %zmm1, %zmm4 # zmm4 = (zmm1 * zmm4) + mem
  vfmadd213ps	(%rbx,%r15,4), %zmm1, %zmm5 # zmm5 = (zmm1 * zmm5) + mem
  vmovups	%zmm2, -192(%rbx,%r15,4)
  vmovups	%zmm3, -128(%rbx,%r15,4)
  vmovups	%zmm4, -64(%rbx,%r15,4)
  vmovups	%zmm5, (%rbx,%r15,4)
  addq	$64, %r15
  cmpq	%r15, %r11
  jne	.LBB0_19
  cmpq	%r11, %rcx
  je	.LBB0_25
  testb	$56, %cl
  je	.LBB0_15
.LBB0_22:
  movq	%r11, %rbx
  leaq	56(%rdi), %r11
  vbroadcastss	%xmm0, %ymm1
  andq	%rcx, %r11
  .p2align	4
  .p2align 4
.LBB0_23:
  vmovups	(%rax,%rbx,4), %ymm2
  vfmadd213ps	(%r10,%rbx,4), %ymm1, %ymm2 # ymm2 = (ymm1 * ymm2) + mem
  vmovups	%ymm2, (%r10,%rbx,4)
  addq	$8, %rbx
  cmpq	%rbx, %r11
  jne	.LBB0_23
  jmp	.LBB0_24
.LBB0_15:
  vmovss	(%rax,%r11,4), %xmm1            # xmm1 = mem[0],zero,zero,zero
  vfmadd213ss	(%r10,%r11,4), %xmm0, %xmm1 # xmm1 = (xmm0 * xmm1) + mem
  vmovss	%xmm1, (%r10,%r11,4)
  incq	%r11
.LBB0_24:
  cmpq	%r11, %rcx
  jne	.LBB0_15
.LBB0_25:
  vmovss	(%r9,%rcx,8), %xmm0             # xmm0 = mem[0],zero,zero,zero
  leaq	(%rdx,%rcx,8), %r10
  cmpq	$8, %rcx
  jae	.LBB0_28
  xorl	%r11d, %r11d
  jmp	.LBB0_27
.LBB0_28:
  cmpq	$64, %rcx
  jae	.LBB0_30
  xorl	%r11d, %r11d
  jmp	.LBB0_34
.LBB0_30:
  vbroadcastss	%xmm0, %zmm1
  leaq	192(%rdx,%rcx,8), %rbx
  leaq	192(%rsi,%r8,4), %r14
  movq	%rcx, %r11
  andq	%rdi, %r11
  xorl	%r15d, %r15d
  .p2align	4
  .p2align 4
.LBB0_31:
  vmovups	-192(%r14,%r15,4), %zmm2
  vmovups	-128(%r14,%r15,4), %zmm3
  vmovups	-64(%r14,%r15,4), %zmm4
  vmovups	(%r14,%r15,4), %zmm5
  vfmadd213ps	-192(%rbx,%r15,4), %zmm1, %zmm2 # zmm2 = (zmm1 * zmm2) + mem
  vfmadd213ps	-128(%rbx,%r15,4), %zmm1, %zmm3 # zmm3 = (zmm1 * zmm3) + mem
  vfmadd213ps	-64(%rbx,%r15,4), %zmm1, %zmm4 # zmm4 = (zmm1 * zmm4) + mem
  vfmadd213ps	(%rbx,%r15,4), %zmm1, %zmm5 # zmm5 = (zmm1 * zmm5) + mem
  vmovups	%zmm2, -192(%rbx,%r15,4)
  vmovups	%zmm3, -128(%rbx,%r15,4)
  vmovups	%zmm4, -64(%rbx,%r15,4)
  vmovups	%zmm5, (%rbx,%r15,4)
  addq	$64, %r15
  cmpq	%r15, %r11
  jne	.LBB0_31
  cmpq	%r11, %rcx
  je	.LBB0_37
  testb	$56, %cl
  je	.LBB0_27
.LBB0_34:
  movq	%r11, %rbx
  leaq	56(%rdi), %r11
  vbroadcastss	%xmm0, %ymm1
  andq	%rcx, %r11
  .p2align	4
  .p2align 4
.LBB0_35:
  vmovups	(%rax,%rbx,4), %ymm2
  vfmadd213ps	(%r10,%rbx,4), %ymm1, %ymm2 # ymm2 = (ymm1 * ymm2) + mem
  vmovups	%ymm2, (%r10,%rbx,4)
  addq	$8, %rbx
  cmpq	%rbx, %r11
  jne	.LBB0_35
  jmp	.LBB0_36
.LBB0_27:
  vmovss	(%rax,%r11,4), %xmm1            # xmm1 = mem[0],zero,zero,zero
  vfmadd213ss	(%r10,%r11,4), %xmm0, %xmm1 # xmm1 = (xmm0 * xmm1) + mem
  vmovss	%xmm1, (%r10,%r11,4)
  incq	%r11
.LBB0_36:
  cmpq	%r11, %rcx
  jne	.LBB0_27
.LBB0_37:
  leaq	(,%rcx,4), %r10
  leaq	(%r10,%r10,2), %r10
  vmovss	(%r9,%r10), %xmm0               # xmm0 = mem[0],zero,zero,zero
  addq	%rdx, %r10
  cmpq	$8, %rcx
  popq	%rbx
  popq	%r14
  popq	%r15
  jae	.LBB0_40
  xorl	%r9d, %r9d
  jmp	.LBB0_39
.LBB0_40:
  cmpq	$64, %rcx
  jae	.LBB0_42
  xorl	%r9d, %r9d
  jmp	.LBB0_46
.LBB0_42:
  leaq	(%rcx,%rcx,2), %r11
  leaq	192(%rsi,%r8,4), %rsi
  vbroadcastss	%xmm0, %zmm1
  movq	%rcx, %r9
  andq	%rdi, %r9
  xorl	%r8d, %r8d
  leaq	192(%rdx,%r11,4), %rdx
  .p2align	4
  .p2align 4
.LBB0_43:
  vmovups	-192(%rsi,%r8,4), %zmm2
  vmovups	-128(%rsi,%r8,4), %zmm3
  vmovups	-64(%rsi,%r8,4), %zmm4
  vmovups	(%rsi,%r8,4), %zmm5
  vfmadd213ps	-192(%rdx,%r8,4), %zmm1, %zmm2 # zmm2 = (zmm1 * zmm2) + mem
  vfmadd213ps	-128(%rdx,%r8,4), %zmm1, %zmm3 # zmm3 = (zmm1 * zmm3) + mem
  vfmadd213ps	-64(%rdx,%r8,4), %zmm1, %zmm4 # zmm4 = (zmm1 * zmm4) + mem
  vfmadd213ps	(%rdx,%r8,4), %zmm1, %zmm5 # zmm5 = (zmm1 * zmm5) + mem
  vmovups	%zmm2, -192(%rdx,%r8,4)
  vmovups	%zmm3, -128(%rdx,%r8,4)
  vmovups	%zmm4, -64(%rdx,%r8,4)
  vmovups	%zmm5, (%rdx,%r8,4)
  addq	$64, %r8
  cmpq	%r8, %r9
  jne	.LBB0_43
  cmpq	%r9, %rcx
  je	.LBB0_49
  testb	$56, %cl
  je	.LBB0_39
.LBB0_46:
  addq	$56, %rdi
  vbroadcastss	%xmm0, %ymm1
  movq	%r9, %rdx
  movq	%rdi, %r9
  andq	%rcx, %r9
  .p2align	4
  .p2align 4
.LBB0_47:
  vmovups	(%rax,%rdx,4), %ymm2
  vfmadd213ps	(%r10,%rdx,4), %ymm1, %ymm2 # ymm2 = (ymm1 * ymm2) + mem
  vmovups	%ymm2, (%r10,%rdx,4)
  addq	$8, %rdx
  cmpq	%rdx, %r9
  jne	.LBB0_47
  jmp	.LBB0_48
.LBB0_39:
  vmovss	(%rax,%r9,4), %xmm1             # xmm1 = mem[0],zero,zero,zero
  vfmadd213ss	(%r10,%r9,4), %xmm0, %xmm1 # xmm1 = (xmm0 * xmm1) + mem
  vmovss	%xmm1, (%r10,%r9,4)
  incq	%r9
.LBB0_48:
  cmpq	%r9, %rcx
  jne	.LBB0_39
.LBB0_49:
