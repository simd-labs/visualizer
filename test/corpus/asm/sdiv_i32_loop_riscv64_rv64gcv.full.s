	.attribute	4, 16
	.attribute	5, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_v1p0_zicsr2p0_zifencei2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0_zcd1p0_zve32f1p0_zve32x1p0_zve64d1p0_zve64f1p0_zve64x1p0_zvl128b1p0_zvl32b1p0_zvl64b1p0"
	.file	"sdiv_i32_loop.cpp"
	.text
	.globl	_Z13sdiv_i32_loopPKiPiil        # -- Begin function _Z13sdiv_i32_loopPKiPiil
	.p2align	1
	.type	_Z13sdiv_i32_loopPKiPiil,@function
_Z13sdiv_i32_loopPKiPiil:               # @_Z13sdiv_i32_loopPKiPiil
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN sdiv_i32_loop
	#NO_APP
	blez	a3, .LBB0_3
# %bb.1:
	li	a4, 0
.LBB0_2:                                # =>This Inner Loop Header: Depth=1
	vsetvli	a5, a3, e32, m2, ta, ma
	slli	a6, a4, 2
	add	a7, a0, a6
	vle32.v	v8, (a7)
	vdiv.vx	v8, v8, a2
	add	a6, a6, a1
	sub	a3, a3, a5
	vse32.v	v8, (a6)
	add	a4, a4, a5
	bnez	a3, .LBB0_2
.LBB0_3:
	#APP
	# LLVM-MCA-END sdiv_i32_loop
	#NO_APP
	ret
.Lfunc_end0:
	.size	_Z13sdiv_i32_loopPKiPiil, .Lfunc_end0-_Z13sdiv_i32_loopPKiPiil
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
