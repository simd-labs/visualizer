	.attribute	4, 16
	.attribute	5, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_v1p0_zicsr2p0_zifencei2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0_zcd1p0_zve32f1p0_zve32x1p0_zve64d1p0_zve64f1p0_zve64x1p0_zvl128b1p0_zvl32b1p0_zvl64b1p0"
	.file	"hash_bytes.cpp"
	.section	.rodata.cst8,"aM",@progbits,8
	.p2align	3, 0x0                          # -- Begin function _Z10hash_bytesPKhl
.LCPI0_0:
	.quad	-3750763034362895579            # 0xcbf29ce484222325
	.text
	.globl	_Z10hash_bytesPKhl
	.p2align	1
	.type	_Z10hash_bytesPKhl,@function
_Z10hash_bytesPKhl:                     # @_Z10hash_bytesPKhl
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN hash_bytes
	#NO_APP
.Lpcrel_hi0:
	auipc	a2, %pcrel_hi(.LCPI0_0)
	ld	a2, %pcrel_lo(.Lpcrel_hi0)(a2)
	blez	a1, .LBB0_3
# %bb.1:
	li	a3, 1
	slli	a3, a3, 40
	add	a1, a1, a0
	addi	a3, a3, 435
.LBB0_2:                                # =>This Inner Loop Header: Depth=1
	lbu	a4, 0(a0)
	xor	a2, a2, a4
	mul	a2, a2, a3
	addi	a0, a0, 1
	bne	a0, a1, .LBB0_2
.LBB0_3:
	mv	a0, a2
	#APP
	# LLVM-MCA-END hash_bytes
	#NO_APP
	ret
.Lfunc_end0:
	.size	_Z10hash_bytesPKhl, .Lfunc_end0-_Z10hash_bytesPKhl
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
