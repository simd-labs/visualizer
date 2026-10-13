	.attribute	4, 16
	.attribute	5, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_v1p0_zicsr2p0_zifencei2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0_zcd1p0_zve32f1p0_zve32x1p0_zve64d1p0_zve64f1p0_zve64x1p0_zvl128b1p0_zvl32b1p0_zvl64b1p0"
	.file	"clamp_branchy.cpp"
	.text
	.globl	_Z13clamp_branchyPKfPflff       # -- Begin function _Z13clamp_branchyPKfPflff
	.p2align	1
	.type	_Z13clamp_branchyPKfPflff,@function
_Z13clamp_branchyPKfPflff:              # @_Z13clamp_branchyPKfPflff
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN clamp_branchy
	#NO_APP
	blez	a2, .LBB0_3
# %bb.1:
	vsetvli	a3, zero, e32, m2, ta, ma
	vfmv.v.f	v8, fa0
	li	a3, 0
.LBB0_2:                                # =>This Inner Loop Header: Depth=1
	vsetvli	a4, a2, e32, m2, ta, ma
	slli	a5, a3, 2
	add	a6, a0, a5
	vle32.v	v10, (a6)
	vmflt.vv	v12, v10, v8
	vmfgt.vf	v13, v10, fa1
	vmnot.m	v14, v12
	vmandn.mm	v0, v14, v13
	vmerge.vvm	v10, v8, v10, v0
	vmandn.mm	v0, v13, v12
	vfmerge.vfm	v10, v10, fa1, v0
	add	a5, a5, a1
	sub	a2, a2, a4
	vse32.v	v10, (a5)
	add	a3, a3, a4
	bnez	a2, .LBB0_2
.LBB0_3:
	#APP
	# LLVM-MCA-END clamp_branchy
	#NO_APP
	ret
.Lfunc_end0:
	.size	_Z13clamp_branchyPKfPflff, .Lfunc_end0-_Z13clamp_branchyPKfPflff
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
