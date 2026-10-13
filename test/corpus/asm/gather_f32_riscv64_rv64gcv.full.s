	.attribute	4, 16
	.attribute	5, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_v1p0_zicsr2p0_zifencei2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0_zcd1p0_zve32f1p0_zve32x1p0_zve64d1p0_zve64f1p0_zve64x1p0_zvl128b1p0_zvl32b1p0_zvl64b1p0"
	.file	"gather_f32.cpp"
	.text
	.globl	_Z10gather_f32PKfPKiPfl         # -- Begin function _Z10gather_f32PKfPKiPfl
	.p2align	1
	.type	_Z10gather_f32PKfPKiPfl,@function
_Z10gather_f32PKfPKiPfl:                # @_Z10gather_f32PKfPKiPfl
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN gather_f32
	#NO_APP
	blez	a3, .LBB0_3
# %bb.1:
	li	a4, 0
	li	a5, 4
.LBB0_2:                                # =>This Inner Loop Header: Depth=1
	vsetvli	a6, a3, e32, m2, ta, ma
	slli	a7, a4, 2
	add	t0, a1, a7
	vle32.v	v12, (t0)
	vwmulsu.vx	v8, v12, a5
	vluxei64.v	v12, (a0), v8
	add	a7, a7, a2
	sub	a3, a3, a6
	vse32.v	v12, (a7)
	add	a4, a4, a6
	bnez	a3, .LBB0_2
.LBB0_3:
	#APP
	# LLVM-MCA-END gather_f32
	#NO_APP
	ret
.Lfunc_end0:
	.size	_Z10gather_f32PKfPKiPfl, .Lfunc_end0-_Z10gather_f32PKfPKiPfl
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
