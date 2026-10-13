	.attribute	4, 16
	.attribute	5, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_v1p0_zicsr2p0_zifencei2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0_zcd1p0_zve32f1p0_zve32x1p0_zve64d1p0_zve64f1p0_zve64x1p0_zvl128b1p0_zvl32b1p0_zvl64b1p0"
	.file	"sqrt_f32_loop.cpp"
	.text
	.globl	_Z13sqrt_f32_loopPKfPfl         # -- Begin function _Z13sqrt_f32_loopPKfPfl
	.p2align	1
	.type	_Z13sqrt_f32_loopPKfPfl,@function
_Z13sqrt_f32_loopPKfPfl:                # @_Z13sqrt_f32_loopPKfPfl
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN sqrt_f32_loop
	#NO_APP
	blez	a2, .LBB0_3
# %bb.1:
	lui	a3, 258048
	fmv.w.x	fa5, a3
	li	a4, 0
.LBB0_2:                                # =>This Inner Loop Header: Depth=1
	vsetvli	a5, a2, e32, m2, ta, ma
	slli	a6, a4, 2
	add	a7, a0, a6
	vle32.v	v8, (a7)
	vmv.v.x	v10, a3
	vfmacc.vf	v10, fa5, v8
	vfdiv.vv	v12, v8, v10
	vfadd.vv	v10, v10, v12
	vfmul.vf	v10, v10, fa5
	vfdiv.vv	v12, v8, v10
	vfadd.vv	v10, v10, v12
	vfmul.vf	v10, v10, fa5
	vfdiv.vv	v12, v8, v10
	vfadd.vv	v10, v10, v12
	vfmul.vf	v10, v10, fa5
	vfdiv.vv	v8, v8, v10
	vfadd.vv	v8, v10, v8
	vfmul.vf	v8, v8, fa5
	add	a6, a6, a1
	sub	a2, a2, a5
	vse32.v	v8, (a6)
	add	a4, a4, a5
	bnez	a2, .LBB0_2
.LBB0_3:
	#APP
	# LLVM-MCA-END sqrt_f32_loop
	#NO_APP
	ret
.Lfunc_end0:
	.size	_Z13sqrt_f32_loopPKfPfl, .Lfunc_end0-_Z13sqrt_f32_loopPKfPfl
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
