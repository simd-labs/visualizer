  testq	%rcx, %rcx
  jle	.LBB0_28
  pushq	%r14
  pushq	%rbx
  leaq	(%rdi,%r8,4), %r9
  imulq	%rcx, %r8
  leaq	(%rsi,%r8,4), %rax
  movabsq	$9223372036854775800, %rdi      # imm = 0x7FFFFFFFFFFFFFF8
  movss	(%r9), %xmm0                    # xmm0 = mem[0],zero,zero,zero
  cmpq	$8, %rcx
  jae	.LBB0_4
  xorl	%r10d, %r10d
  jmp	.LBB0_3
.LBB0_4:
  movq	%rcx, %r10
  andq	%rdi, %r10
  movaps	%xmm0, %xmm1
  shufps	$0, %xmm0, %xmm1                # xmm1 = xmm1[0,0],xmm0[0,0]
  leaq	(%rsi,%r8,4), %r11
  addq	$16, %r11
  xorl	%ebx, %ebx
  .p2align	4
  .p2align 4
.LBB0_5:
  movups	-16(%r11,%rbx,4), %xmm2
  movups	(%r11,%rbx,4), %xmm3
  movups	(%rdx,%rbx,4), %xmm4
  movups	16(%rdx,%rbx,4), %xmm5
  mulps	%xmm1, %xmm2
  addps	%xmm4, %xmm2
  mulps	%xmm1, %xmm3
  addps	%xmm5, %xmm3
  movups	%xmm2, (%rdx,%rbx,4)
  movups	%xmm3, 16(%rdx,%rbx,4)
  addq	$8, %rbx
  cmpq	%rbx, %r10
  jne	.LBB0_5
  jmp	.LBB0_6
.LBB0_3:
  movss	(%rax,%r10,4), %xmm1            # xmm1 = mem[0],zero,zero,zero
  mulss	%xmm0, %xmm1
  addss	(%rdx,%r10,4), %xmm1
  movss	%xmm1, (%rdx,%r10,4)
  incq	%r10
.LBB0_6:
  cmpq	%r10, %rcx
  jne	.LBB0_3
  movss	(%r9,%rcx,4), %xmm0             # xmm0 = mem[0],zero,zero,zero
  cmpq	$8, %rcx
  jae	.LBB0_9
  xorl	%r10d, %r10d
  jmp	.LBB0_12
.LBB0_9:
  movq	%rcx, %r10
  andq	%rdi, %r10
  movaps	%xmm0, %xmm1
  shufps	$0, %xmm0, %xmm1                # xmm1 = xmm1[0,0],xmm0[0,0]
  leaq	(%rdx,%rcx,4), %r11
  addq	$16, %r11
  leaq	(%rsi,%r8,4), %rbx
  addq	$16, %rbx
  xorl	%r14d, %r14d
  .p2align	4
  .p2align 4
.LBB0_10:
  movups	-16(%rbx,%r14,4), %xmm2
  movups	(%rbx,%r14,4), %xmm3
  movups	-16(%r11,%r14,4), %xmm4
  movups	(%r11,%r14,4), %xmm5
  mulps	%xmm1, %xmm2
  addps	%xmm4, %xmm2
  mulps	%xmm1, %xmm3
  addps	%xmm5, %xmm3
  movups	%xmm2, -16(%r11,%r14,4)
  movups	%xmm3, (%r11,%r14,4)
  addq	$8, %r14
  cmpq	%r14, %r10
  jne	.LBB0_10
  cmpq	%r10, %rcx
  je	.LBB0_14
.LBB0_12:
  leaq	(%rdx,%rcx,4), %r11
  .p2align	4
  .p2align 4
.LBB0_13:
  movss	(%rax,%r10,4), %xmm1            # xmm1 = mem[0],zero,zero,zero
  mulss	%xmm0, %xmm1
  addss	(%r11,%r10,4), %xmm1
  movss	%xmm1, (%r11,%r10,4)
  incq	%r10
  cmpq	%r10, %rcx
  jne	.LBB0_13
.LBB0_14:
  movss	(%r9,%rcx,8), %xmm0             # xmm0 = mem[0],zero,zero,zero
  cmpq	$8, %rcx
  jae	.LBB0_16
  xorl	%r10d, %r10d
  jmp	.LBB0_19
.LBB0_16:
  movq	%rcx, %r10
  andq	%rdi, %r10
  movaps	%xmm0, %xmm1
  shufps	$0, %xmm0, %xmm1                # xmm1 = xmm1[0,0],xmm0[0,0]
  leaq	(%rdx,%rcx,8), %r11
  addq	$16, %r11
  leaq	(%rsi,%r8,4), %rbx
  addq	$16, %rbx
  xorl	%r14d, %r14d
  .p2align	4
  .p2align 4
.LBB0_17:
  movups	-16(%rbx,%r14,4), %xmm2
  movups	(%rbx,%r14,4), %xmm3
  movups	-16(%r11,%r14,4), %xmm4
  movups	(%r11,%r14,4), %xmm5
  mulps	%xmm1, %xmm2
  addps	%xmm4, %xmm2
  mulps	%xmm1, %xmm3
  addps	%xmm5, %xmm3
  movups	%xmm2, -16(%r11,%r14,4)
  movups	%xmm3, (%r11,%r14,4)
  addq	$8, %r14
  cmpq	%r14, %r10
  jne	.LBB0_17
  cmpq	%r10, %rcx
  je	.LBB0_21
.LBB0_19:
  leaq	(%rdx,%rcx,8), %r11
  .p2align	4
  .p2align 4
.LBB0_20:
  movss	(%rax,%r10,4), %xmm1            # xmm1 = mem[0],zero,zero,zero
  mulss	%xmm0, %xmm1
  addss	(%r11,%r10,4), %xmm1
  movss	%xmm1, (%r11,%r10,4)
  incq	%r10
  cmpq	%r10, %rcx
  jne	.LBB0_20
.LBB0_21:
  leaq	(,%rcx,4), %r10
  leaq	(%r10,%r10,2), %r10
  movss	(%r9,%r10), %xmm0               # xmm0 = mem[0],zero,zero,zero
  cmpq	$8, %rcx
  popq	%rbx
  popq	%r14
  jae	.LBB0_23
  xorl	%edi, %edi
  jmp	.LBB0_26
.LBB0_23:
  andq	%rcx, %rdi
  movaps	%xmm0, %xmm1
  shufps	$0, %xmm0, %xmm1                # xmm1 = xmm1[0,0],xmm0[0,0]
  leaq	(%rcx,%rcx,2), %r9
  leaq	(%rdx,%r9,4), %r9
  addq	$16, %r9
  leaq	(%rsi,%r8,4), %rsi
  addq	$16, %rsi
  xorl	%r8d, %r8d
  .p2align	4
  .p2align 4
.LBB0_24:
  movups	-16(%rsi,%r8,4), %xmm2
  movups	(%rsi,%r8,4), %xmm3
  movups	-16(%r9,%r8,4), %xmm4
  movups	(%r9,%r8,4), %xmm5
  mulps	%xmm1, %xmm2
  addps	%xmm4, %xmm2
  mulps	%xmm1, %xmm3
  addps	%xmm5, %xmm3
  movups	%xmm2, -16(%r9,%r8,4)
  movups	%xmm3, (%r9,%r8,4)
  addq	$8, %r8
  cmpq	%r8, %rdi
  jne	.LBB0_24
  cmpq	%rdi, %rcx
  je	.LBB0_28
.LBB0_26:
  addq	%r10, %rdx
  .p2align	4
  .p2align 4
.LBB0_27:
  movss	(%rax,%rdi,4), %xmm1            # xmm1 = mem[0],zero,zero,zero
  mulss	%xmm0, %xmm1
  addss	(%rdx,%rdi,4), %xmm1
  movss	%xmm1, (%rdx,%rdi,4)
  incq	%rdi
  cmpq	%rdi, %rcx
  jne	.LBB0_27
.LBB0_28:
