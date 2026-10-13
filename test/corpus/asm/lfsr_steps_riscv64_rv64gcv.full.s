	.attribute	4, 16
	.attribute	5, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_v1p0_zicsr2p0_zifencei2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0_zcd1p0_zve32f1p0_zve32x1p0_zve64d1p0_zve64f1p0_zve64x1p0_zvl128b1p0_zvl32b1p0_zvl64b1p0"
	.file	"lfsr_steps.cpp"
	.text
	.globl	_Z10lfsr_stepsPjl               # -- Begin function _Z10lfsr_stepsPjl
	.p2align	1
	.type	_Z10lfsr_stepsPjl,@function
_Z10lfsr_stepsPjl:                      # @_Z10lfsr_stepsPjl
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN lfsr_steps
	#NO_APP
	blez	a1, .LBB0_3
# %bb.1:
	li	a3, 0
	li	a2, 0
	lui	a4, 11
	addi	a5, a4, -799
	addi	a4, a4, 1024
.LBB0_2:                                # =>This Inner Loop Header: Depth=1
	andi	a6, a3, 7
	slli	a6, a6, 2
	add	a6, a6, a0
	slli	a7, a5, 63
	lwu	a6, 0(a6)
	srai	a7, a7, 63
	srliw	a5, a5, 1
	and	a7, a7, a4
	xor	a5, a5, a7
	and	a6, a6, a5
	addi	a3, a3, 1
	add	a2, a2, a6
	bne	a1, a3, .LBB0_2
	j	.LBB0_4
.LBB0_3:
	li	a2, 0
.LBB0_4:
	mv	a0, a2
	#APP
	# LLVM-MCA-END lfsr_steps
	#NO_APP
	ret
.Lfunc_end0:
	.size	_Z10lfsr_stepsPjl, .Lfunc_end0-_Z10lfsr_stepsPjl
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
