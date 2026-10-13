	.attribute	4, 16
	.attribute	5, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_v1p0_zicsr2p0_zifencei2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0_zcd1p0_zve32f1p0_zve32x1p0_zve64d1p0_zve64f1p0_zve64x1p0_zvl128b1p0_zvl32b1p0_zvl64b1p0"
	.file	"madd_i16.cpp"
	.text
	.globl	_Z8madd_i16PKsS0_Pil            # -- Begin function _Z8madd_i16PKsS0_Pil
	.p2align	1
	.type	_Z8madd_i16PKsS0_Pil,@function
_Z8madd_i16PKsS0_Pil:                   # @_Z8madd_i16PKsS0_Pil
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN madd_i16
	#NO_APP
	blez	a3, .LBB0_3
# %bb.1:
	li	a4, 0
	addi	a3, a3, -1
	srli	a3, a3, 1
	addi	a3, a3, 1
.LBB0_2:                                # =>This Inner Loop Header: Depth=1
	vsetvli	a5, a3, e16, m1, ta, ma
	slli	a6, a4, 2
	add	a7, a0, a6
	vlseg2e16.v	v10, (a7)
	add	a7, a1, a6
	vlseg2e16.v	v12, (a7)
	vwmul.vv	v8, v12, v10
	vwmacc.vv	v8, v13, v11
	add	a6, a6, a2
	sub	a3, a3, a5
	add	a4, a4, a5
	vse32.v	v8, (a6)
	bnez	a3, .LBB0_2
.LBB0_3:
	#APP
	# LLVM-MCA-END madd_i16
	#NO_APP
	ret
.Lfunc_end0:
	.size	_Z8madd_i16PKsS0_Pil, .Lfunc_end0-_Z8madd_i16PKsS0_Pil
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
