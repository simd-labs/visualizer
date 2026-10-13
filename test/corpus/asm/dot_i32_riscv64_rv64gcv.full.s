	.attribute	4, 16
	.attribute	5, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_v1p0_zicsr2p0_zifencei2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0_zcd1p0_zve32f1p0_zve32x1p0_zve64d1p0_zve64f1p0_zve64x1p0_zvl128b1p0_zvl32b1p0_zvl64b1p0"
	.file	"dot_i32.cpp"
	.text
	.globl	_Z7dot_i32PKiS0_l               # -- Begin function _Z7dot_i32PKiS0_l
	.p2align	1
	.type	_Z7dot_i32PKiS0_l,@function
_Z7dot_i32PKiS0_l:                      # @_Z7dot_i32PKiS0_l
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN dot_i32
	#NO_APP
	blez	a2, .LBB0_4
# %bb.1:
	vsetvli	a3, zero, e64, m2, ta, ma
	vmv.v.i	v8, 0
	li	a3, 0
.LBB0_2:                                # =>This Inner Loop Header: Depth=1
	vsetvli	a4, a2, e8, mf4, ta, ma
	slli	a5, a3, 2
	add	a6, a0, a5
	vle32.v	v10, (a6)
	add	a5, a5, a1
	vle32.v	v11, (a5)
	vsetvli	zero, zero, e32, m1, tu, ma
	vwmacc.vv	v8, v11, v10
	sub	a2, a2, a4
	add	a3, a3, a4
	bnez	a2, .LBB0_2
# %bb.3:
	vsetvli	a0, zero, e64, m2, ta, ma
	vmv.s.x	v10, zero
	vredsum.vs	v8, v8, v10
	vmv.x.s	a0, v8
	#APP
	# LLVM-MCA-END dot_i32
	#NO_APP
	ret
.LBB0_4:
	li	a0, 0
	#APP
	# LLVM-MCA-END dot_i32
	#NO_APP
	ret
.Lfunc_end0:
	.size	_Z7dot_i32PKiS0_l, .Lfunc_end0-_Z7dot_i32PKiS0_l
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
