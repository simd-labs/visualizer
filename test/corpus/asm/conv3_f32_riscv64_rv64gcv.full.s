	.attribute	4, 16
	.attribute	5, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_v1p0_zicsr2p0_zifencei2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0_zcd1p0_zve32f1p0_zve32x1p0_zve64d1p0_zve64f1p0_zve64x1p0_zvl128b1p0_zvl32b1p0_zvl64b1p0"
	.file	"conv3_f32.cpp"
	.text
	.globl	_Z9conv3_f32PKfPfS0_l           # -- Begin function _Z9conv3_f32PKfPfS0_l
	.p2align	1
	.type	_Z9conv3_f32PKfPfS0_l,@function
_Z9conv3_f32PKfPfS0_l:                  # @_Z9conv3_f32PKfPfS0_l
# %bb.0:
	li	a4, 3
	#APP
	# LLVM-MCA-BEGIN conv3_f32
	#NO_APP
	blt	a3, a4, .LBB0_3
# %bb.1:
	li	a4, 0
	flw	fa5, 4(a0)
	csrr	a5, vlenb
	srli	a5, a5, 1
	addi	a6, a5, -1
	vsetvli	a7, zero, e32, m1, ta, ma
	vfmv.s.f	v10, fa5
	slli	a6, a6, 32
	srli	a6, a6, 32
	addi	a7, a6, 1
	vsetvli	zero, a7, e32, m2, ta, ma
	vslideup.vx	v8, v10, a6
	flw	fa5, 0(a2)
	flw	fa4, 4(a2)
	flw	fa3, 8(a2)
	addi	a3, a3, -2
.LBB0_2:                                # =>This Inner Loop Header: Depth=1
	slli	a5, a5, 32
	vsetvli	a2, a3, e32, m2, ta, ma
	slli	a6, a4, 2
	srli	a5, a5, 32
	add	a7, a0, a6
	addi	a5, a5, -1
	addi	a7, a7, 8
	vslidedown.vx	v8, v8, a5
	vle32.v	v10, (a7)
	vslideup.vi	v8, v10, 1
	addi	a6, a6, 4
	add	a5, a0, a6
	addi	a5, a5, -4
	vle32.v	v12, (a5)
	vfmul.vf	v14, v8, fa4
	vfmacc.vf	v14, fa5, v12
	vfmacc.vf	v14, fa3, v10
	vmv.v.v	v8, v10
	add	a6, a6, a1
	sub	a3, a3, a2
	vse32.v	v14, (a6)
	add	a4, a4, a2
	mv	a5, a2
	bnez	a3, .LBB0_2
.LBB0_3:
	#APP
	# LLVM-MCA-END conv3_f32
	#NO_APP
	ret
.Lfunc_end0:
	.size	_Z9conv3_f32PKfPfS0_l, .Lfunc_end0-_Z9conv3_f32PKfPfS0_l
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
