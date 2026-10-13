	.attribute	4, 16
	.attribute	5, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_v1p0_zicsr2p0_zifencei2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0_zcd1p0_zve32f1p0_zve32x1p0_zve64d1p0_zve64f1p0_zve64x1p0_zvl128b1p0_zvl32b1p0_zvl64b1p0"
	.file	"matmul_inner.cpp"
	.text
	.globl	_Z12matmul_innerPKfS0_Pfll      # -- Begin function _Z12matmul_innerPKfS0_Pfll
	.p2align	1
	.type	_Z12matmul_innerPKfS0_Pfll,@function
_Z12matmul_innerPKfS0_Pfll:             # @_Z12matmul_innerPKfS0_Pfll
# %bb.0:
	#APP
	# LLVM-MCA-BEGIN matmul_inner
	#NO_APP
	blez	a3, .LBB0_9
# %bb.1:
	li	a5, 0
	mul	a6, a4, a3
	slli	a4, a4, 2
	add	a0, a0, a4
	flw	fa5, 0(a0)
	slli	a6, a6, 2
	add	a1, a1, a6
	mv	a4, a3
.LBB0_2:                                # =>This Inner Loop Header: Depth=1
	vsetvli	a6, a4, e32, m2, ta, ma
	slli	a7, a5, 2
	add	t0, a1, a7
	vle32.v	v8, (t0)
	add	a7, a7, a2
	vle32.v	v10, (a7)
	vfmacc.vf	v10, fa5, v8
	sub	a4, a4, a6
	vse32.v	v10, (a7)
	add	a5, a5, a6
	bnez	a4, .LBB0_2
# %bb.3:
	li	a5, 0
	slli	a4, a3, 2
	add	a6, a0, a4
	flw	fa5, 0(a6)
	add	a6, a2, a4
	mv	a7, a3
.LBB0_4:                                # =>This Inner Loop Header: Depth=1
	vsetvli	t0, a7, e32, m2, ta, ma
	slli	t1, a5, 2
	add	t2, a1, t1
	vle32.v	v8, (t2)
	add	t1, t1, a6
	vle32.v	v10, (t1)
	vfmacc.vf	v10, fa5, v8
	sub	a7, a7, t0
	vse32.v	v10, (t1)
	add	a5, a5, t0
	bnez	a7, .LBB0_4
# %bb.5:
	li	a6, 0
	slli	a5, a3, 3
	add	a7, a0, a5
	flw	fa5, 0(a7)
	add	a7, a2, a5
	mv	t0, a3
.LBB0_6:                                # =>This Inner Loop Header: Depth=1
	vsetvli	t1, t0, e32, m2, ta, ma
	slli	t2, a6, 2
	add	t3, a1, t2
	vle32.v	v8, (t3)
	add	t2, t2, a7
	vle32.v	v10, (t2)
	vfmacc.vf	v10, fa5, v8
	sub	t0, t0, t1
	vse32.v	v10, (t2)
	add	a6, a6, t1
	bnez	t0, .LBB0_6
# %bb.7:
	li	a6, 0
	add	a4, a4, a5
	add	a0, a0, a4
	flw	fa5, 0(a0)
	add	a2, a2, a4
.LBB0_8:                                # =>This Inner Loop Header: Depth=1
	vsetvli	a0, a3, e32, m2, ta, ma
	slli	a4, a6, 2
	add	a5, a1, a4
	vle32.v	v8, (a5)
	add	a4, a4, a2
	vle32.v	v10, (a4)
	vfmacc.vf	v10, fa5, v8
	sub	a3, a3, a0
	vse32.v	v10, (a4)
	add	a6, a6, a0
	bnez	a3, .LBB0_8
.LBB0_9:
	#APP
	# LLVM-MCA-END matmul_inner
	#NO_APP
	ret
.Lfunc_end0:
	.size	_Z12matmul_innerPKfS0_Pfll, .Lfunc_end0-_Z12matmul_innerPKfS0_Pfll
                                        # -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
