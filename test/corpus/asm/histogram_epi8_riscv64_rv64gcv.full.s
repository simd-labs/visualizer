	.attribute	4, 16
	.attribute	5, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_v1p0_zicsr2p0_zifencei2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0_zcd1p0_zve32f1p0_zve32x1p0_zve64d1p0_zve64f1p0_zve64x1p0_zvl128b1p0_zvl32b1p0_zvl64b1p0"
	.file	"histogram_epi8.cpp"
	.text
	.globl	_Z14histogram_epi8PKhPjl        # -- Begin function _Z14histogram_epi8PKhPjl
	.p2align	1
	.type	_Z14histogram_epi8PKhPjl,@function
_Z14histogram_epi8PKhPjl:               # @_Z14histogram_epi8PKhPjl
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN histogram_epi8
	#NO_APP
	blez	a2, .LBB0_3
# %bb.1:
	add	a2, a2, a0
.LBB0_2:                                # =>This Inner Loop Header: Depth=1
	lbu	a3, 0(a0)
	addi	a0, a0, 1
	slli	a3, a3, 2
	add	a3, a3, a1
	lw	a4, 0(a3)
	addi	a4, a4, 1
	sw	a4, 0(a3)
	bne	a0, a2, .LBB0_2
.LBB0_3:
	#APP
	# LLVM-MCA-END histogram_epi8
	#NO_APP
	ret
.Lfunc_end0:
	.size	_Z14histogram_epi8PKhPjl, .Lfunc_end0-_Z14histogram_epi8PKhPjl
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
