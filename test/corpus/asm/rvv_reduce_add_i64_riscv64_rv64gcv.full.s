	.attribute	4, 16
	.attribute	5, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_v1p0_zicsr2p0_zifencei2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0_zcd1p0_zve32f1p0_zve32x1p0_zve64d1p0_zve64f1p0_zve64x1p0_zvl128b1p0_zvl32b1p0_zvl64b1p0"
	.file	"rvv_reduce_add_i64.cpp"
	.text
	.globl	_Z18rvv_reduce_add_i64PKll      # -- Begin function _Z18rvv_reduce_add_i64PKll
	.p2align	1
	.type	_Z18rvv_reduce_add_i64PKll,@function
_Z18rvv_reduce_add_i64PKll:             # @_Z18rvv_reduce_add_i64PKll
# %bb.0:
	vsetvli	zero, a1, e64, m4, ta, ma
	vmv.v.i	v8, 0
	#APP
	# LLVM-MCA-BEGIN rvv_reduce_add_i64
	#NO_APP
	blez	a1, .LBB0_3
# %bb.1:
	li	a2, 0
.LBB0_2:                                # =>This Inner Loop Header: Depth=1
	sub	a3, a1, a2
	slli	a4, a2, 3
	vsetvli	a3, a3, e64, m4, ta, ma
	add	a4, a4, a0
	vle64.v	v12, (a4)
	vadd.vv	v8, v8, v12
	add	a2, a2, a3
	blt	a2, a1, .LBB0_2
.LBB0_3:
	vsetivli	zero, 1, e64, m1, ta, ma
	vmv.v.i	v12, 0
	vsetvli	zero, a1, e64, m4, ta, ma
	vredsum.vs	v8, v8, v12
	vmv.x.s	a0, v8
	#APP
	# LLVM-MCA-END rvv_reduce_add_i64
	#NO_APP
	ret
.Lfunc_end0:
	.size	_Z18rvv_reduce_add_i64PKll, .Lfunc_end0-_Z18rvv_reduce_add_i64PKll
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
