	.attribute	4, 16
	.attribute	5, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_v1p0_zicsr2p0_zifencei2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0_zcd1p0_zve32f1p0_zve32x1p0_zve64d1p0_zve64f1p0_zve64x1p0_zvl128b1p0_zvl32b1p0_zvl64b1p0"
	.file	"sum_mod_fold.cpp"
	.text
	.globl	_Z12sum_mod_foldPKil            # -- Begin function _Z12sum_mod_foldPKil
	.p2align	1
	.type	_Z12sum_mod_foldPKil,@function
_Z12sum_mod_foldPKil:                   # @_Z12sum_mod_foldPKil
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN sum_mod_fold
	#NO_APP
	blez	a1, .LBB0_4
# %bb.1:
	li	a2, 0
	vsetvli	a3, zero, e64, m2, ta, ma
	vmv.v.i	v8, 0
	vmv.v.i	v10, 0
	lui	a3, 16
	addi	a3, a3, -1
.LBB0_2:                                # =>This Inner Loop Header: Depth=1
	vsetvli	a4, a1, e32, m1, ta, ma
	slli	a5, a2, 2
	add	a5, a5, a0
	vle32.v	v12, (a5)
	vand.vx	v13, v12, a3
	vsra.vi	v12, v12, 16
	vsetvli	zero, zero, e32, m1, tu, ma
	vwaddu.wv	v10, v10, v13
	vwadd.wv	v8, v8, v12
	sub	a1, a1, a4
	add	a2, a2, a4
	bnez	a1, .LBB0_2
# %bb.3:
	vsetvli	a0, zero, e64, m2, ta, ma
	vmv.s.x	v12, zero
	vredsum.vs	v8, v8, v12
	vredsum.vs	v9, v10, v12
	vmv.x.s	a1, v8
	vmv.x.s	a0, v9
	slli	a1, a1, 16
	j	.LBB0_5
.LBB0_4:
	li	a0, 0
	li	a1, 0
.LBB0_5:
	add	a0, a0, a1
	#APP
	# LLVM-MCA-END sum_mod_fold
	#NO_APP
	ret
.Lfunc_end0:
	.size	_Z12sum_mod_foldPKil, .Lfunc_end0-_Z12sum_mod_foldPKil
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
