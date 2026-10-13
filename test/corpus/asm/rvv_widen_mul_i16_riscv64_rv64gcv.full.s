	.attribute	4, 16
	.attribute	5, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_v1p0_zicsr2p0_zifencei2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0_zcd1p0_zve32f1p0_zve32x1p0_zve64d1p0_zve64f1p0_zve64x1p0_zvl128b1p0_zvl32b1p0_zvl64b1p0"
	.file	"rvv_widen_mul_i16.cpp"
	.text
	.globl	_Z17rvv_widen_mul_i16PKaS0_Psl  # -- Begin function _Z17rvv_widen_mul_i16PKaS0_Psl
	.p2align	1
	.type	_Z17rvv_widen_mul_i16PKaS0_Psl,@function
_Z17rvv_widen_mul_i16PKaS0_Psl:         # @_Z17rvv_widen_mul_i16PKaS0_Psl
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN rvv_widen_mul_i16
	#NO_APP
	blez	a3, .LBB0_3
# %bb.1:
	li	a4, 0
.LBB0_2:                                # =>This Inner Loop Header: Depth=1
	sub	a5, a3, a4
	add	a6, a0, a4
	vsetvli	a5, a5, e8, m2, ta, ma
	vle8.v	v12, (a6)
	add	a6, a1, a4
	vle8.v	v14, (a6)
	vwmul.vv	v8, v12, v14
	slli	a6, a4, 1
	add	a6, a6, a2
	add	a4, a4, a5
	vse16.v	v8, (a6)
	blt	a4, a3, .LBB0_2
.LBB0_3:
	#APP
	# LLVM-MCA-END rvv_widen_mul_i16
	#NO_APP
	ret
.Lfunc_end0:
	.size	_Z17rvv_widen_mul_i16PKaS0_Psl, .Lfunc_end0-_Z17rvv_widen_mul_i16PKaS0_Psl
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
