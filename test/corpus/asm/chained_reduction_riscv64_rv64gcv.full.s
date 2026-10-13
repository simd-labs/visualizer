	.attribute	4, 16
	.attribute	5, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_v1p0_zicsr2p0_zifencei2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0_zcd1p0_zve32f1p0_zve32x1p0_zve64d1p0_zve64f1p0_zve64x1p0_zvl128b1p0_zvl32b1p0_zvl64b1p0"
	.file	"chained_reduction.cpp"
	.text
	.globl	_Z17chained_reductionPKfl       # -- Begin function _Z17chained_reductionPKfl
	.p2align	1
	.type	_Z17chained_reductionPKfl,@function
_Z17chained_reductionPKfl:              # @_Z17chained_reductionPKfl
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN chained_reduction
	#NO_APP
	lui	a2, 260096
	blez	a1, .LBB0_4
# %bb.1:
	fmv.w.x	fa5, a2
	slli	a1, a1, 2
	add	a1, a1, a0
	fmv.s	fa0, fa5
.LBB0_2:                                # =>This Inner Loop Header: Depth=1
	flw	fa4, 0(a0)
	fmadd.s	fa3, fa0, fa4, fa5
	fmul.s	fa4, fa0, fa4
	fmul.s	fa0, fa4, fa3
	addi	a0, a0, 4
	bne	a0, a1, .LBB0_2
# %bb.3:
	#APP
	# LLVM-MCA-END chained_reduction
	#NO_APP
	ret
.LBB0_4:
	fmv.w.x	fa0, a2
	#APP
	# LLVM-MCA-END chained_reduction
	#NO_APP
	ret
.Lfunc_end0:
	.size	_Z17chained_reductionPKfl, .Lfunc_end0-_Z17chained_reductionPKfl
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
