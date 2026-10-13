	.attribute	4, 16
	.attribute	5, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_v1p0_zicsr2p0_zifencei2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0_zcd1p0_zve32f1p0_zve32x1p0_zve64d1p0_zve64f1p0_zve64x1p0_zvl128b1p0_zvl32b1p0_zvl64b1p0"
	.file	"rvv_saxpy.cpp"
	.text
	.globl	_Z9rvv_saxpyfPKfPfl             # -- Begin function _Z9rvv_saxpyfPKfPfl
	.p2align	1
	.type	_Z9rvv_saxpyfPKfPfl,@function
_Z9rvv_saxpyfPKfPfl:                    # @_Z9rvv_saxpyfPKfPfl
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN rvv_saxpy
	#NO_APP
	blez	a2, .LBB0_3
# %bb.1:
	li	a3, 0
.LBB0_2:                                # =>This Inner Loop Header: Depth=1
	sub	a4, a2, a3
	slli	a5, a3, 2
	vsetvli	a4, a4, e32, m4, ta, ma
	add	a6, a0, a5
	vle32.v	v8, (a6)
	add	a5, a5, a1
	vle32.v	v12, (a5)
	vfmacc.vf	v12, fa0, v8
	add	a3, a3, a4
	vse32.v	v12, (a5)
	blt	a3, a2, .LBB0_2
.LBB0_3:
	#APP
	# LLVM-MCA-END rvv_saxpy
	#NO_APP
	ret
.Lfunc_end0:
	.size	_Z9rvv_saxpyfPKfPfl, .Lfunc_end0-_Z9rvv_saxpyfPKfPfl
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
