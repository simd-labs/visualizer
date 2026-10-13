	.file	"sum_mod_fold.cpp"
	.text
	.globl	_Z12sum_mod_foldPKil            // -- Begin function _Z12sum_mod_foldPKil
	.p2align	2
	.type	_Z12sum_mod_foldPKil,@function
_Z12sum_mod_foldPKil:                   // @_Z12sum_mod_foldPKil
// %bb.0:
	cmp	x1, #1
	//APP
	// LLVM-MCA-BEGIN sum_mod_fold
	//NO_APP
	b.lt	.LBB0_3
// %bb.1:
	str	d8, [sp, #-16]!                 // 8-byte Folded Spill
	cmp	x1, #4
	b.hs	.LBB0_4
// %bb.2:
	mov	x8, xzr
	mov	x11, xzr
	mov	x10, xzr
	b	.LBB0_13
.LBB0_3:
	mov	x10, xzr
	mov	x8, xzr
	b	.LBB0_16
.LBB0_4:
	cmp	x1, #16
	b.hs	.LBB0_6
// %bb.5:
	mov	x8, xzr
	mov	x11, xzr
	mov	x10, xzr
	b	.LBB0_10
.LBB0_6:
	movi	v0.2d, #0000000000000000
	movi	v3.2d, #0x00ffff0000ffff
	and	x9, x1, #0xc
	movi	v5.2d, #0000000000000000
	movi	v6.2d, #0000000000000000
	and	x8, x1, #0x7ffffffffffffff0
	movi	v19.2d, #0000000000000000
	movi	v20.2d, #0000000000000000
	add	x10, x0, #32
	movi	v21.2d, #0000000000000000
	movi	v18.2d, #0000000000000000
	and	x11, x1, #0x7ffffffffffffff0
	movi	v24.2d, #0000000000000000
	movi	v23.2d, #0000000000000000
	movi	v1.2d, #0000000000000000
	movi	v2.2d, #0000000000000000
	movi	v7.2d, #0000000000000000
	movi	v16.2d, #0000000000000000
	movi	v17.2d, #0000000000000000
	movi	v4.2d, #0000000000000000
	movi	v22.2d, #0000000000000000
.LBB0_7:                                // =>This Inner Loop Header: Depth=1
	ldp	q25, q26, [x10, #-32]
	subs	x11, x11, #16
	ldp	q27, q29, [x10], #64
	and	v28.16b, v25.16b, v3.16b
	and	v30.16b, v26.16b, v3.16b
	sshr	v25.4s, v25.4s, #16
	and	v31.16b, v27.16b, v3.16b
	and	v8.16b, v29.16b, v3.16b
	sshr	v26.4s, v26.4s, #16
	sshr	v27.4s, v27.4s, #16
	uaddw2	v2.2d, v2.2d, v28.4s
	uaddw	v1.2d, v1.2d, v28.2s
	sshr	v28.4s, v29.4s, #16
	uaddw2	v16.2d, v16.2d, v30.4s
	uaddw	v7.2d, v7.2d, v30.2s
	uaddw2	v4.2d, v4.2d, v31.4s
	uaddw	v17.2d, v17.2d, v31.2s
	uaddw2	v0.2d, v0.2d, v8.4s
	uaddw	v22.2d, v22.2d, v8.2s
	saddw2	v6.2d, v6.2d, v25.4s
	saddw	v5.2d, v5.2d, v25.2s
	saddw2	v20.2d, v20.2d, v26.4s
	saddw	v19.2d, v19.2d, v26.2s
	saddw2	v18.2d, v18.2d, v27.4s
	saddw	v21.2d, v21.2d, v27.2s
	saddw2	v23.2d, v23.2d, v28.4s
	saddw	v24.2d, v24.2d, v28.2s
	b.ne	.LBB0_7
// %bb.8:
	add	v3.2d, v19.2d, v5.2d
	add	v5.2d, v20.2d, v6.2d
	cmp	x1, x8
	add	v6.2d, v24.2d, v21.2d
	add	v18.2d, v23.2d, v18.2d
	add	v1.2d, v7.2d, v1.2d
	add	v2.2d, v16.2d, v2.2d
	add	v7.2d, v22.2d, v17.2d
	add	v0.2d, v0.2d, v4.2d
	add	v3.2d, v6.2d, v3.2d
	add	v4.2d, v18.2d, v5.2d
	add	v1.2d, v7.2d, v1.2d
	add	v0.2d, v0.2d, v2.2d
	add	v2.2d, v3.2d, v4.2d
	add	v0.2d, v1.2d, v0.2d
	addp	d1, v2.2d
	addp	d0, v0.2d
	fmov	x11, d1
	fmov	x10, d0
	b.eq	.LBB0_15
// %bb.9:
	cbz	x9, .LBB0_13
.LBB0_10:
	movi	v0.2d, #0000000000000000
	movi	v1.2d, #0x00ffff0000ffff
	mov	x12, x8
	movi	v3.2d, #0000000000000000
	fmov	d4, x11
	and	x8, x1, #0x7ffffffffffffffc
	fmov	d2, x10
	add	x9, x0, x12, lsl #2
	sub	x10, x12, x8
.LBB0_11:                               // =>This Inner Loop Header: Depth=1
	ldr	q5, [x9], #16
	adds	x10, x10, #4
	and	v6.16b, v5.16b, v1.16b
	sshr	v5.4s, v5.4s, #16
	uaddw2	v0.2d, v0.2d, v6.4s
	uaddw	v2.2d, v2.2d, v6.2s
	saddw2	v3.2d, v3.2d, v5.4s
	saddw	v4.2d, v4.2d, v5.2s
	b.ne	.LBB0_11
// %bb.12:
	add	v1.2d, v4.2d, v3.2d
	add	v0.2d, v2.2d, v0.2d
	cmp	x1, x8
	addp	d1, v1.2d
	addp	d0, v0.2d
	fmov	x11, d1
	fmov	x10, d0
	b.eq	.LBB0_15
.LBB0_13:
	add	x9, x0, x8, lsl #2
	sub	x8, x1, x8
.LBB0_14:                               // =>This Inner Loop Header: Depth=1
	ldr	w12, [x9], #4
	subs	x8, x8, #1
	asr	w13, w12, #16
	add	x10, x10, w12, uxth
	add	x11, x11, w13, sxtw
	b.ne	.LBB0_14
.LBB0_15:
	lsl	x8, x11, #16
	ldr	d8, [sp], #16                   // 8-byte Folded Reload
.LBB0_16:
	add	x0, x8, x10
	//APP
	// LLVM-MCA-END sum_mod_fold
	//NO_APP
	ret
.Lfunc_end0:
	.size	_Z12sum_mod_foldPKil, .Lfunc_end0-_Z12sum_mod_foldPKil
                                        // -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
