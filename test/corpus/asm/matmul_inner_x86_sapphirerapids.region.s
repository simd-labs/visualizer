  testq	%rcx, %rcx
  jle	.LBB0_49
  pushq	%r15
  pushq	%r14
  pushq	%rbx
  leaq	(%rdi,%r8,4), %r9
  imulq	%rcx, %r8
  leaq	(%rsi,%r8,4), %rax
  movabsq	$9223372036854775776, %rdi      # imm = 0x7FFFFFFFFFFFFFE0
  vmovss	(%r9), %xmm0                    # xmm0 = mem[0],zero,zero,zero
  cmpq	$4, %rcx
  jae	.LBB0_4
  xorl	%r10d, %r10d
  jmp	.LBB0_3
.LBB0_4:
  cmpq	$32, %rcx
  jae	.LBB0_6
  xorl	%r10d, %r10d
  jmp	.LBB0_10
.LBB0_6:
  movq	%rcx, %r10
  andq	%rdi, %r10
  vbroadcastss	%xmm0, %ymm1
  leaq	96(%rsi,%r8,4), %r11
  xorl	%ebx, %ebx
  .p2align	4
  .p2align 4
.LBB0_7:
  vmovups	-96(%r11,%rbx,4), %ymm2
  vmovups	-64(%r11,%rbx,4), %ymm3
  vmovups	-32(%r11,%rbx,4), %ymm4
  vmovups	(%r11,%rbx,4), %ymm5
  vfmadd213ps	(%rdx,%rbx,4), %ymm1, %ymm2 # ymm2 = (ymm1 * ymm2) + mem
  vfmadd213ps	32(%rdx,%rbx,4), %ymm1, %ymm3 # ymm3 = (ymm1 * ymm3) + mem
  vfmadd213ps	64(%rdx,%rbx,4), %ymm1, %ymm4 # ymm4 = (ymm1 * ymm4) + mem
  vfmadd213ps	96(%rdx,%rbx,4), %ymm1, %ymm5 # ymm5 = (ymm1 * ymm5) + mem
  vmovups	%ymm2, (%rdx,%rbx,4)
  vmovups	%ymm3, 32(%rdx,%rbx,4)
  vmovups	%ymm4, 64(%rdx,%rbx,4)
  vmovups	%ymm5, 96(%rdx,%rbx,4)
  addq	$32, %rbx
  cmpq	%rbx, %r10
  jne	.LBB0_7
  cmpq	%r10, %rcx
  je	.LBB0_13
  testb	$28, %cl
  je	.LBB0_3
.LBB0_10:
  movq	%r10, %r11
  leaq	28(%rdi), %r10
  andq	%rcx, %r10
  vbroadcastss	%xmm0, %xmm1
  .p2align	4
  .p2align 4
.LBB0_11:
  vmovups	(%rax,%r11,4), %xmm2
  vfmadd213ps	(%rdx,%r11,4), %xmm1, %xmm2 # xmm2 = (xmm1 * xmm2) + mem
  vmovups	%xmm2, (%rdx,%r11,4)
  addq	$4, %r11
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
  cmpq	$4, %rcx
  jae	.LBB0_16
  xorl	%r11d, %r11d
  jmp	.LBB0_15
.LBB0_16:
  cmpq	$32, %rcx
  jae	.LBB0_18
  xorl	%r11d, %r11d
  jmp	.LBB0_22
.LBB0_18:
  movq	%rcx, %r11
  andq	%rdi, %r11
  vbroadcastss	%xmm0, %ymm1
  leaq	96(%rdx,%rcx,4), %rbx
  leaq	96(%rsi,%r8,4), %r14
  xorl	%r15d, %r15d
  .p2align	4
  .p2align 4
.LBB0_19:
  vmovups	-96(%r14,%r15,4), %ymm2
  vmovups	-64(%r14,%r15,4), %ymm3
  vmovups	-32(%r14,%r15,4), %ymm4
  vmovups	(%r14,%r15,4), %ymm5
  vfmadd213ps	-96(%rbx,%r15,4), %ymm1, %ymm2 # ymm2 = (ymm1 * ymm2) + mem
  vfmadd213ps	-64(%rbx,%r15,4), %ymm1, %ymm3 # ymm3 = (ymm1 * ymm3) + mem
  vfmadd213ps	-32(%rbx,%r15,4), %ymm1, %ymm4 # ymm4 = (ymm1 * ymm4) + mem
  vfmadd213ps	(%rbx,%r15,4), %ymm1, %ymm5 # ymm5 = (ymm1 * ymm5) + mem
  vmovups	%ymm2, -96(%rbx,%r15,4)
  vmovups	%ymm3, -64(%rbx,%r15,4)
  vmovups	%ymm4, -32(%rbx,%r15,4)
  vmovups	%ymm5, (%rbx,%r15,4)
  addq	$32, %r15
  cmpq	%r15, %r11
  jne	.LBB0_19
  cmpq	%r11, %rcx
  je	.LBB0_25
  testb	$28, %cl
  je	.LBB0_15
.LBB0_22:
  movq	%r11, %rbx
  leaq	28(%rdi), %r11
  andq	%rcx, %r11
  vbroadcastss	%xmm0, %xmm1
  .p2align	4
  .p2align 4
.LBB0_23:
  vmovups	(%rax,%rbx,4), %xmm2
  vfmadd213ps	(%r10,%rbx,4), %xmm1, %xmm2 # xmm2 = (xmm1 * xmm2) + mem
  vmovups	%xmm2, (%r10,%rbx,4)
  addq	$4, %rbx
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
  cmpq	$4, %rcx
  jae	.LBB0_28
  xorl	%r11d, %r11d
  jmp	.LBB0_27
.LBB0_28:
  cmpq	$32, %rcx
  jae	.LBB0_30
  xorl	%r11d, %r11d
  jmp	.LBB0_34
.LBB0_30:
  movq	%rcx, %r11
  andq	%rdi, %r11
  vbroadcastss	%xmm0, %ymm1
  leaq	96(%rdx,%rcx,8), %rbx
  leaq	96(%rsi,%r8,4), %r14
  xorl	%r15d, %r15d
  .p2align	4
  .p2align 4
.LBB0_31:
  vmovups	-96(%r14,%r15,4), %ymm2
  vmovups	-64(%r14,%r15,4), %ymm3
  vmovups	-32(%r14,%r15,4), %ymm4
  vmovups	(%r14,%r15,4), %ymm5
  vfmadd213ps	-96(%rbx,%r15,4), %ymm1, %ymm2 # ymm2 = (ymm1 * ymm2) + mem
  vfmadd213ps	-64(%rbx,%r15,4), %ymm1, %ymm3 # ymm3 = (ymm1 * ymm3) + mem
  vfmadd213ps	-32(%rbx,%r15,4), %ymm1, %ymm4 # ymm4 = (ymm1 * ymm4) + mem
  vfmadd213ps	(%rbx,%r15,4), %ymm1, %ymm5 # ymm5 = (ymm1 * ymm5) + mem
  vmovups	%ymm2, -96(%rbx,%r15,4)
  vmovups	%ymm3, -64(%rbx,%r15,4)
  vmovups	%ymm4, -32(%rbx,%r15,4)
  vmovups	%ymm5, (%rbx,%r15,4)
  addq	$32, %r15
  cmpq	%r15, %r11
  jne	.LBB0_31
  cmpq	%r11, %rcx
  je	.LBB0_37
  testb	$28, %cl
  je	.LBB0_27
.LBB0_34:
  movq	%r11, %rbx
  leaq	28(%rdi), %r11
  andq	%rcx, %r11
  vbroadcastss	%xmm0, %xmm1
  .p2align	4
  .p2align 4
.LBB0_35:
  vmovups	(%rax,%rbx,4), %xmm2
  vfmadd213ps	(%r10,%rbx,4), %xmm1, %xmm2 # xmm2 = (xmm1 * xmm2) + mem
  vmovups	%xmm2, (%r10,%rbx,4)
  addq	$4, %rbx
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
  cmpq	$4, %rcx
  popq	%rbx
  popq	%r14
  popq	%r15
  jae	.LBB0_40
  xorl	%r9d, %r9d
  jmp	.LBB0_39
.LBB0_40:
  cmpq	$32, %rcx
  jae	.LBB0_42
  xorl	%r9d, %r9d
  jmp	.LBB0_46
.LBB0_42:
  movq	%rcx, %r9
  andq	%rdi, %r9
  vbroadcastss	%xmm0, %ymm1
  leaq	(%rcx,%rcx,2), %r11
  leaq	96(%rdx,%r11,4), %rdx
  leaq	96(%rsi,%r8,4), %rsi
  xorl	%r8d, %r8d
  .p2align	4
  .p2align 4
.LBB0_43:
  vmovups	-96(%rsi,%r8,4), %ymm2
  vmovups	-64(%rsi,%r8,4), %ymm3
  vmovups	-32(%rsi,%r8,4), %ymm4
  vmovups	(%rsi,%r8,4), %ymm5
  vfmadd213ps	-96(%rdx,%r8,4), %ymm1, %ymm2 # ymm2 = (ymm1 * ymm2) + mem
  vfmadd213ps	-64(%rdx,%r8,4), %ymm1, %ymm3 # ymm3 = (ymm1 * ymm3) + mem
  vfmadd213ps	-32(%rdx,%r8,4), %ymm1, %ymm4 # ymm4 = (ymm1 * ymm4) + mem
  vfmadd213ps	(%rdx,%r8,4), %ymm1, %ymm5 # ymm5 = (ymm1 * ymm5) + mem
  vmovups	%ymm2, -96(%rdx,%r8,4)
  vmovups	%ymm3, -64(%rdx,%r8,4)
  vmovups	%ymm4, -32(%rdx,%r8,4)
  vmovups	%ymm5, (%rdx,%r8,4)
  addq	$32, %r8
  cmpq	%r8, %r9
  jne	.LBB0_43
  cmpq	%r9, %rcx
  je	.LBB0_49
  testb	$28, %cl
  je	.LBB0_39
.LBB0_46:
  movq	%r9, %rdx
  addq	$28, %rdi
  movq	%rdi, %r9
  andq	%rcx, %r9
  vbroadcastss	%xmm0, %xmm1
  .p2align	4
  .p2align 4
.LBB0_47:
  vmovups	(%rax,%rdx,4), %xmm2
  vfmadd213ps	(%r10,%rdx,4), %xmm1, %xmm2 # xmm2 = (xmm1 * xmm2) + mem
  vmovups	%xmm2, (%r10,%rdx,4)
  addq	$4, %rdx
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
