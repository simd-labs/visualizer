	.att_syntax
	.file	"avx512_dot_f32x16.cpp"
	.text
	.globl	_Z17avx512_dot_f32x16PKfS0_Pfl  # -- Begin function _Z17avx512_dot_f32x16PKfS0_Pfl
	.prefalign	4, .Lfunc_end0, nop
	.type	_Z17avx512_dot_f32x16PKfS0_Pfl,@function
_Z17avx512_dot_f32x16PKfS0_Pfl:         # @_Z17avx512_dot_f32x16PKfS0_Pfl
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN avx512_dot_f32
	#NO_APP
	testq	%rcx, %rcx
	jle	.LBB0_1
# %bb.2:
	leaq	-1(%rcx), %r8
	shrq	$4, %r8
	incq	%r8
	movl	%r8d, %eax
	andl	$7, %eax
	cmpq	$113, %rcx
	jae	.LBB0_8
# %bb.3:
	vxorps	%xmm0, %xmm0, %xmm0
	xorl	%ecx, %ecx
	jmp	.LBB0_5
.LBB0_1:
	vxorps	%xmm0, %xmm0, %xmm0
	jmp	.LBB0_7
.LBB0_8:
	andq	$-8, %r8
	vxorps	%xmm0, %xmm0, %xmm0
	xorl	%ecx, %ecx
	.p2align	4
.LBB0_9:                                # =>This Inner Loop Header: Depth=1
	vmovups	(%rdi,%rcx,4), %zmm1
	vmovups	64(%rdi,%rcx,4), %zmm2
	vmovups	128(%rdi,%rcx,4), %zmm3
	vmovups	192(%rdi,%rcx,4), %zmm4
	vfmadd231ps	(%rsi,%rcx,4), %zmm1, %zmm0 # zmm0 = (zmm1 * mem) + zmm0
	vfmadd231ps	64(%rsi,%rcx,4), %zmm2, %zmm0 # zmm0 = (zmm2 * mem) + zmm0
	vfmadd231ps	128(%rsi,%rcx,4), %zmm3, %zmm0 # zmm0 = (zmm3 * mem) + zmm0
	vfmadd231ps	192(%rsi,%rcx,4), %zmm4, %zmm0 # zmm0 = (zmm4 * mem) + zmm0
	vmovups	256(%rdi,%rcx,4), %zmm1
	vfmadd132ps	256(%rsi,%rcx,4), %zmm0, %zmm1 # zmm1 = (zmm1 * mem) + zmm0
	vmovups	320(%rdi,%rcx,4), %zmm0
	vfmadd132ps	320(%rsi,%rcx,4), %zmm1, %zmm0 # zmm0 = (zmm0 * mem) + zmm1
	vmovups	384(%rdi,%rcx,4), %zmm1
	vfmadd132ps	384(%rsi,%rcx,4), %zmm0, %zmm1 # zmm1 = (zmm1 * mem) + zmm0
	vmovups	448(%rdi,%rcx,4), %zmm0
	vfmadd132ps	448(%rsi,%rcx,4), %zmm1, %zmm0 # zmm0 = (zmm0 * mem) + zmm1
	subq	$-128, %rcx
	addq	$-8, %r8
	jne	.LBB0_9
# %bb.4:
	testq	%rax, %rax
	je	.LBB0_7
.LBB0_5:
	leaq	(%rsi,%rcx,4), %rsi
	leaq	(%rdi,%rcx,4), %rcx
	shll	$6, %eax
	xorl	%edi, %edi
	.p2align	4
.LBB0_6:                                # =>This Inner Loop Header: Depth=1
	vmovups	(%rcx,%rdi), %zmm1
	vfmadd231ps	(%rsi,%rdi), %zmm1, %zmm0 # zmm0 = (zmm1 * mem) + zmm0
	addq	$64, %rdi
	cmpq	%rdi, %rax
	jne	.LBB0_6
.LBB0_7:
	#APP
	# LLVM-MCA-END avx512_dot_f32
	#NO_APP
	vextractf64x4	$1, %zmm0, %ymm1
	vaddps	%zmm1, %zmm0, %zmm0
	vextractf128	$1, %ymm0, %xmm1
	vaddps	%xmm1, %xmm0, %xmm0
	vshufpd	$1, %xmm0, %xmm0, %xmm1         # xmm1 = xmm0[1,0]
	vaddps	%xmm1, %xmm0, %xmm0
	vmovshdup	%xmm0, %xmm1            # xmm1 = xmm0[1,1,3,3]
	vaddss	%xmm1, %xmm0, %xmm0
	vmovss	%xmm0, (%rdx)
	vzeroupper
	retq
.Lfunc_end0:
	.size	_Z17avx512_dot_f32x16PKfS0_Pfl, .Lfunc_end0-_Z17avx512_dot_f32x16PKfS0_Pfl
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
