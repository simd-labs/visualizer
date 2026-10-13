	.attribute	4, 16
	.attribute	5, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_v1p0_zicsr2p0_zifencei2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0_zcd1p0_zve32f1p0_zve32x1p0_zve64d1p0_zve64f1p0_zve64x1p0_zvl128b1p0_zvl32b1p0_zvl64b1p0"
	.file	"memset_u32.cpp"
	.text
	.globl	_Z10memset_u32Pjjl              # -- Begin function _Z10memset_u32Pjjl
	.p2align	1
	.type	_Z10memset_u32Pjjl,@function
_Z10memset_u32Pjjl:                     # @_Z10memset_u32Pjjl
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN memset_u32
	#NO_APP
	blez	a2, .LBB0_3
# %bb.1:
	vsetvli	a3, zero, e32, m2, ta, ma
	vmv.v.x	v8, a1
	li	a1, 0
.LBB0_2:                                # =>This Inner Loop Header: Depth=1
	vsetvli	a3, a2, e8, mf2, ta, ma
	slli	a4, a1, 2
	add	a4, a4, a0
	sub	a2, a2, a3
	add	a1, a1, a3
	vse32.v	v8, (a4)
	bnez	a2, .LBB0_2
.LBB0_3:
	#APP
	# LLVM-MCA-END memset_u32
	#NO_APP
	ret
.Lfunc_end0:
	.size	_Z10memset_u32Pjjl, .Lfunc_end0-_Z10memset_u32Pjjl
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
