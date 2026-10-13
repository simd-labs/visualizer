	.attribute	4, 16
	.attribute	5, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_v1p0_zicsr2p0_zifencei2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0_zcd1p0_zve32f1p0_zve32x1p0_zve64d1p0_zve64f1p0_zve64x1p0_zvl128b1p0_zvl32b1p0_zvl64b1p0"
	.file	"rvv_gather_i32.cpp"
	.text
	.globl	_Z14rvv_gather_i32PKiS0_Pil     # -- Begin function _Z14rvv_gather_i32PKiS0_Pil
	.p2align	1
	.type	_Z14rvv_gather_i32PKiS0_Pil,@function
_Z14rvv_gather_i32PKiS0_Pil:            # @_Z14rvv_gather_i32PKiS0_Pil
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN rvv_gather_i32
	#NO_APP
	blez	a3, .LBB0_3
# %bb.1:
	li	a4, 0
.LBB0_2:                                # =>This Inner Loop Header: Depth=1
	sub	a5, a3, a4
	slli	a6, a4, 2
	vsetvli	a5, a5, e32, m4, ta, ma
	add	a7, a1, a6
	vle32.v	v8, (a7)
	vloxei32.v	v8, (a0), v8
	add	a6, a6, a2
	add	a4, a4, a5
	vse32.v	v8, (a6)
	blt	a4, a3, .LBB0_2
.LBB0_3:
	#APP
	# LLVM-MCA-END rvv_gather_i32
	#NO_APP
	ret
.Lfunc_end0:
	.size	_Z14rvv_gather_i32PKiS0_Pil, .Lfunc_end0-_Z14rvv_gather_i32PKiS0_Pil
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
