	.attribute	4, 16
	.attribute	5, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_v1p0_zicsr2p0_zifencei2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0_zcd1p0_zve32f1p0_zve32x1p0_zve64d1p0_zve64f1p0_zve64x1p0_zvl128b1p0_zvl32b1p0_zvl64b1p0"
	.file	"strlen_like.cpp"
	.text
	.globl	_Z11strlen_likePKclPl           # -- Begin function _Z11strlen_likePKclPl
	.p2align	1
	.type	_Z11strlen_likePKclPl,@function
_Z11strlen_likePKclPl:                  # @_Z11strlen_likePKclPl
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN strlen_like
	#NO_APP
	li	a3, 0
	blez	a1, .LBB0_4
.LBB0_1:                                # =>This Inner Loop Header: Depth=1
	add	a4, a0, a3
	lbu	a4, 0(a4)
	beqz	a4, .LBB0_4
# %bb.2:                                #   in Loop: Header=BB0_1 Depth=1
	addi	a3, a3, 1
	bne	a1, a3, .LBB0_1
# %bb.3:
	mv	a3, a1
.LBB0_4:
	#APP
	# LLVM-MCA-END strlen_like
	#NO_APP
	sd	a3, 0(a2)
	ret
.Lfunc_end0:
	.size	_Z11strlen_likePKclPl, .Lfunc_end0-_Z11strlen_likePKclPl
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
