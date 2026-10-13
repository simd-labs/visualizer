	.attribute	4, 16
	.attribute	5, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_v1p0_zicsr2p0_zifencei2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0_zcd1p0_zve32f1p0_zve32x1p0_zve64d1p0_zve64f1p0_zve64x1p0_zvl128b1p0_zvl32b1p0_zvl64b1p0"
	.file	"mincol_f32.cpp"
	.text
	.globl	_Z10mincol_f32PKfPfll           # -- Begin function _Z10mincol_f32PKfPfll
	.p2align	1
	.type	_Z10mincol_f32PKfPfll,@function
_Z10mincol_f32PKfPfll:                  # @_Z10mincol_f32PKfPfll
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN mincol_f32
	#NO_APP
	blez	a3, .LBB0_7
# %bb.1:
	li	a4, 0
	slli	a5, a3, 2
	mv	a6, a0
	j	.LBB0_3
.LBB0_2:                                #   in Loop: Header=BB0_3 Depth=1
	add	a7, a7, a1
	addi	a4, a4, 1
	fsw	fa5, 0(a7)
	addi	a6, a6, 4
	beq	a4, a3, .LBB0_7
.LBB0_3:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_5 Depth 2
	slli	a7, a4, 2
	add	t0, a0, a7
	flw	fa5, 0(t0)
	mv	t0, a6
	mv	t1, a2
	bgtz	a2, .LBB0_5
	j	.LBB0_2
.LBB0_4:                                #   in Loop: Header=BB0_5 Depth=2
	addi	t1, t1, -1
	add	t0, t0, a5
	beqz	t1, .LBB0_2
.LBB0_5:                                #   Parent Loop BB0_3 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	flw	fa4, 0(t0)
	flt.s	t2, fa5, fa4
	bnez	t2, .LBB0_4
# %bb.6:                                #   in Loop: Header=BB0_5 Depth=2
	fmv.s	fa5, fa4
	j	.LBB0_4
.LBB0_7:
	#APP
	# LLVM-MCA-END mincol_f32
	#NO_APP
	ret
.Lfunc_end0:
	.size	_Z10mincol_f32PKfPfll, .Lfunc_end0-_Z10mincol_f32PKfPfll
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
