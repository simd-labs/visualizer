	.attribute	4, 16
	.attribute	5, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_v1p0_zicsr2p0_zifencei2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0_zcd1p0_zve32f1p0_zve32x1p0_zve64d1p0_zve64f1p0_zve64x1p0_zvl128b1p0_zvl32b1p0_zvl64b1p0"
	.file	"saxpy.cpp"
	.text
	.globl	_Z5saxpyfPKfPfl                 # -- Begin function _Z5saxpyfPKfPfl
	.p2align	1
	.type	_Z5saxpyfPKfPfl,@function
_Z5saxpyfPKfPfl:                        # @_Z5saxpyfPKfPfl
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN saxpy
	#NO_APP
	blez	a2, .LBB0_3
# %bb.1:
	li	a3, 0
.LBB0_2:                                # =>This Inner Loop Header: Depth=1
	vsetvli	a4, a2, e32, m2, ta, ma
	slli	a5, a3, 2
	add	a6, a0, a5
	vle32.v	v8, (a6)
	add	a5, a5, a1
	vle32.v	v10, (a5)
	vfmacc.vf	v10, fa0, v8
	sub	a2, a2, a4
	vse32.v	v10, (a5)
	add	a3, a3, a4
	bnez	a2, .LBB0_2
.LBB0_3:
	#APP
	# LLVM-MCA-END saxpy
	#NO_APP
	ret
.Lfunc_end0:
	.size	_Z5saxpyfPKfPfl, .Lfunc_end0-_Z5saxpyfPKfPfl
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
