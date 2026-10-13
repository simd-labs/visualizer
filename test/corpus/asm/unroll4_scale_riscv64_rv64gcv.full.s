	.attribute	4, 16
	.attribute	5, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_v1p0_zicsr2p0_zifencei2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0_zcd1p0_zve32f1p0_zve32x1p0_zve64d1p0_zve64f1p0_zve64x1p0_zvl128b1p0_zvl32b1p0_zvl64b1p0"
	.file	"unroll4_scale.cpp"
	.text
	.globl	_Z13unroll4_scalePKfPflf        # -- Begin function _Z13unroll4_scalePKfPflf
	.p2align	1
	.type	_Z13unroll4_scalePKfPflf,@function
_Z13unroll4_scalePKfPflf:               # @_Z13unroll4_scalePKfPflf
# %bb.0:
	li	a3, 4
	#APP
	# LLVM-MCA-BEGIN unroll4_scale
	#NO_APP
	blt	a2, a3, .LBB0_4
# %bb.1:
	li	a4, 0
	addi	a3, a2, -4
	srli	a3, a3, 2
	addi	a5, a3, 1
	slli	a3, a5, 2
.LBB0_2:                                # =>This Inner Loop Header: Depth=1
	vsetvli	a6, a5, e32, m2, ta, ma
	slli	a7, a4, 4
	add	t0, a0, a7
	vlseg4e32.v	v8, (t0)
	vfmul.vf	v8, v8, fa0
	vfmul.vf	v10, v10, fa0
	vfmul.vf	v12, v12, fa0
	vfmul.vf	v14, v14, fa0
	add	a7, a7, a1
	sub	a5, a5, a6
	add	a4, a4, a6
	vsseg4e32.v	v8, (a7)
	bnez	a5, .LBB0_2
# %bb.3:
	blt	a3, a2, .LBB0_5
	j	.LBB0_7
.LBB0_4:
	li	a3, 0
	blez	a2, .LBB0_7
.LBB0_5:
	li	a4, 0
	sub	a2, a2, a3
.LBB0_6:                                # =>This Inner Loop Header: Depth=1
	vsetvli	a5, a2, e32, m2, ta, ma
	add	a6, a3, a4
	slli	a6, a6, 2
	add	a7, a0, a6
	vle32.v	v8, (a7)
	vfmul.vf	v8, v8, fa0
	add	a6, a6, a1
	sub	a2, a2, a5
	vse32.v	v8, (a6)
	add	a4, a4, a5
	bnez	a2, .LBB0_6
.LBB0_7:
	#APP
	# LLVM-MCA-END unroll4_scale
	#NO_APP
	ret
.Lfunc_end0:
	.size	_Z13unroll4_scalePKfPflf, .Lfunc_end0-_Z13unroll4_scalePKfPflf
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
