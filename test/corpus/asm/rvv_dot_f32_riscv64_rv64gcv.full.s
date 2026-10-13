	.attribute	4, 16
	.attribute	5, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_v1p0_zicsr2p0_zifencei2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0_zcd1p0_zve32f1p0_zve32x1p0_zve64d1p0_zve64f1p0_zve64x1p0_zvl128b1p0_zvl32b1p0_zvl64b1p0"
	.file	"rvv_dot_f32.cpp"
	.text
	.globl	_Z11rvv_dot_f32PKfS0_l          # -- Begin function _Z11rvv_dot_f32PKfS0_l
	.p2align	1
	.type	_Z11rvv_dot_f32PKfS0_l,@function
_Z11rvv_dot_f32PKfS0_l:                 # @_Z11rvv_dot_f32PKfS0_l
# %bb.0:
	vsetvli	zero, a2, e32, m2, ta, ma
	vmv.v.i	v8, 0
	#APP
	# LLVM-MCA-BEGIN rvv_dot_f32
	#NO_APP
	blez	a2, .LBB0_3
# %bb.1:
	li	a3, 0
.LBB0_2:                                # =>This Inner Loop Header: Depth=1
	sub	a4, a2, a3
	slli	a5, a3, 2
	vsetvli	a4, a4, e32, m2, ta, ma
	add	a6, a0, a5
	vle32.v	v10, (a6)
	add	a5, a5, a1
	vle32.v	v12, (a5)
	vfmacc.vv	v8, v12, v10
	add	a3, a3, a4
	blt	a3, a2, .LBB0_2
.LBB0_3:
	vsetivli	zero, 1, e32, m1, ta, ma
	vmv.v.i	v10, 0
	vsetvli	zero, a2, e32, m2, ta, ma
	vfredusum.vs	v8, v8, v10
	vfmv.f.s	fa0, v8
	#APP
	# LLVM-MCA-END rvv_dot_f32
	#NO_APP
	ret
.Lfunc_end0:
	.size	_Z11rvv_dot_f32PKfS0_l, .Lfunc_end0-_Z11rvv_dot_f32PKfS0_l
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
