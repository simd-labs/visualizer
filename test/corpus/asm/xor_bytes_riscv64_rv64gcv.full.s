	.attribute	4, 16
	.attribute	5, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_v1p0_zicsr2p0_zifencei2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0_zcd1p0_zve32f1p0_zve32x1p0_zve64d1p0_zve64f1p0_zve64x1p0_zvl128b1p0_zvl32b1p0_zvl64b1p0"
	.file	"xor_bytes.cpp"
	.text
	.globl	_Z9xor_bytesPKhS0_Phl           # -- Begin function _Z9xor_bytesPKhS0_Phl
	.p2align	1
	.type	_Z9xor_bytesPKhS0_Phl,@function
_Z9xor_bytesPKhS0_Phl:                  # @_Z9xor_bytesPKhS0_Phl
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN xor_bytes
	#NO_APP
	blez	a3, .LBB0_3
# %bb.1:
	li	a4, 0
.LBB0_2:                                # =>This Inner Loop Header: Depth=1
	vsetvli	a5, a3, e8, m2, ta, ma
	add	a6, a0, a4
	vle8.v	v8, (a6)
	add	a6, a1, a4
	vle8.v	v10, (a6)
	vxor.vv	v8, v10, v8
	add	a6, a2, a4
	sub	a3, a3, a5
	add	a4, a4, a5
	vse8.v	v8, (a6)
	bnez	a3, .LBB0_2
.LBB0_3:
	#APP
	# LLVM-MCA-END xor_bytes
	#NO_APP
	ret
.Lfunc_end0:
	.size	_Z9xor_bytesPKhS0_Phl, .Lfunc_end0-_Z9xor_bytesPKhS0_Phl
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
