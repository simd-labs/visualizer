	.attribute	4, 16
	.attribute	5, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_v1p0_zicsr2p0_zifencei2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0_zcd1p0_zve32f1p0_zve32x1p0_zve64d1p0_zve64f1p0_zve64x1p0_zvl128b1p0_zvl32b1p0_zvl64b1p0"
	.file	"prefix_sum.cpp"
	.text
	.globl	_Z10prefix_sumPKfPfl            # -- Begin function _Z10prefix_sumPKfPfl
	.p2align	1
	.type	_Z10prefix_sumPKfPfl,@function
_Z10prefix_sumPKfPfl:                   # @_Z10prefix_sumPKfPfl
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN prefix_sum
	#NO_APP
	blez	a2, .LBB0_3
# %bb.1:
	fmv.w.x	fa5, zero
	slli	a2, a2, 2
	add	a2, a2, a1
.LBB0_2:                                # =>This Inner Loop Header: Depth=1
	flw	fa4, 0(a0)
	fadd.s	fa5, fa5, fa4
	fsw	fa5, 0(a1)
	addi	a1, a1, 4
	addi	a0, a0, 4
	bne	a1, a2, .LBB0_2
.LBB0_3:
	#APP
	# LLVM-MCA-END prefix_sum
	#NO_APP
	ret
.Lfunc_end0:
	.size	_Z10prefix_sumPKfPfl, .Lfunc_end0-_Z10prefix_sumPKfPfl
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
