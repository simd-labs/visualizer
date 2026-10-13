	.file	"dot_i32.cpp"
	.text
	.globl	_Z7dot_i32PKiS0_l               // -- Begin function _Z7dot_i32PKiS0_l
	.p2align	2
	.type	_Z7dot_i32PKiS0_l,@function
_Z7dot_i32PKiS0_l:                      // @_Z7dot_i32PKiS0_l
// %bb.0:
	cmp	x2, #1
	//APP
	// LLVM-MCA-BEGIN dot_i32
	//NO_APP
	b.lt	.LBB0_3
// %bb.1:
	b.ne	.LBB0_4
// %bb.2:
	mov	x9, xzr
	mov	x8, xzr
	b	.LBB0_13
.LBB0_3:
	mov	x8, xzr
	b	.LBB0_15
.LBB0_4:
	rdvl	x8, #1
	cmp	x2, x8
	b.hs	.LBB0_6
// %bb.5:
	mov	x9, xzr
	mov	x8, xzr
	b	.LBB0_10
.LBB0_6:
	mov	x8, #-1                         // =0xffffffffffffffff
	movi	v0.2d, #0000000000000000
	movi	v1.2d, #0000000000000000
	incb	x8
	movi	v2.2d, #0000000000000000
	movi	v3.2d, #0000000000000000
	mov	x11, x1
	and	x10, x2, x8
	mov	x8, x0
	sub	x9, x2, x10
	sub	x12, x2, x10
.LBB0_7:                                // =>This Inner Loop Header: Depth=1
	ldr	z4, [x8]
	ldr	z5, [x8, #1, mul vl]
	decb	x12
	ldr	z6, [x8, #2, mul vl]
	ldr	z7, [x11]
	ldr	z16, [x11, #1, mul vl]
	ldr	z17, [x8, #3, mul vl]
	incb	x8, all, mul #4
	ldr	z18, [x11, #2, mul vl]
	ldr	z19, [x11, #3, mul vl]
	incb	x11, all, mul #4
	smlalb	z0.d, z7.s, z4.s
	smlalb	z1.d, z16.s, z5.s
	smlalb	z2.d, z18.s, z6.s
	smlalb	z3.d, z19.s, z17.s
	smlalt	z0.d, z7.s, z4.s
	smlalt	z1.d, z16.s, z5.s
	smlalt	z2.d, z18.s, z6.s
	smlalt	z3.d, z19.s, z17.s
	cbnz	x12, .LBB0_7
// %bb.8:
	add	z0.d, z1.d, z0.d
	add	z1.d, z3.d, z2.d
	ptrue	p0.d
	add	z0.d, z1.d, z0.d
	uaddv	d0, p0, z0.d
	fmov	x8, d0
	cbz	x10, .LBB0_15
// %bb.9:
	cmp	x10, #1
	b.eq	.LBB0_13
.LBB0_10:
	fmov	d0, x8
	lsl	x11, x9, #2
	mov	x10, x9
	and	x9, x2, #0x7ffffffffffffffe
	sub	x8, x10, x9
	add	x10, x1, x11
	add	x11, x0, x11
.LBB0_11:                               // =>This Inner Loop Header: Depth=1
	ldr	d1, [x11], #8
	adds	x8, x8, #2
	ldr	d2, [x10], #8
	smlal	v0.2d, v2.2s, v1.2s
	b.ne	.LBB0_11
// %bb.12:
	addp	d0, v0.2d
	cmp	x2, x9
	fmov	x8, d0
	b.eq	.LBB0_15
.LBB0_13:
	lsl	x11, x9, #2
	sub	x9, x2, x9
	add	x10, x1, x11
	add	x11, x0, x11
.LBB0_14:                               // =>This Inner Loop Header: Depth=1
	ldrsw	x12, [x11], #4
	subs	x9, x9, #1
	ldrsw	x13, [x10], #4
	smaddl	x8, w13, w12, x8
	b.ne	.LBB0_14
.LBB0_15:
	mov	x0, x8
	//APP
	// LLVM-MCA-END dot_i32
	//NO_APP
	ret
.Lfunc_end0:
	.size	_Z7dot_i32PKiS0_l, .Lfunc_end0-_Z7dot_i32PKiS0_l
                                        // -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
