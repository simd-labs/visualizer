	.file	"memmove_overlap.cpp"
	.text
	.globl	_Z15memmove_overlapPcPKcl       // -- Begin function _Z15memmove_overlapPcPKcl
	.p2align	2
	.type	_Z15memmove_overlapPcPKcl,@function
_Z15memmove_overlapPcPKcl:              // @_Z15memmove_overlapPcPKcl
// %bb.0:
	subs	x8, x0, x1
	//APP
	// LLVM-MCA-BEGIN memmove_overlap
	//NO_APP
	b.hs	.LBB0_4
// %bb.1:
	cmp	x2, #1
	b.lt	.LBB0_29
// %bb.2:
	sub	x8, x1, x0
	cmn	x8, #32
	ccmp	x2, #8, #0, ls
	b.hs	.LBB0_7
// %bb.3:
	mov	x8, xzr
	b	.LBB0_18
.LBB0_4:
	cmp	x2, #1
	b.lt	.LBB0_29
// %bb.5:
	cmn	x8, #32
	ccmp	x2, #8, #0, ls
	b.hs	.LBB0_9
// %bb.6:
	mov	x8, x2
	b	.LBB0_27
.LBB0_7:
	cmp	x2, #32
	b.hs	.LBB0_11
// %bb.8:
	mov	x8, xzr
	b	.LBB0_15
.LBB0_9:
	cmp	x2, #32
	b.hs	.LBB0_20
// %bb.10:
	mov	x9, xzr
	b	.LBB0_24
.LBB0_11:
	and	x9, x2, #0x18
	and	x8, x2, #0x7fffffffffffffe0
	add	x10, x0, #16
	add	x11, x1, #16
	and	x12, x2, #0x7fffffffffffffe0
.LBB0_12:                               // =>This Inner Loop Header: Depth=1
	ldp	q0, q1, [x11, #-16]
	subs	x12, x12, #32
	add	x11, x11, #32
	stp	q0, q1, [x10, #-16]
	add	x10, x10, #32
	b.ne	.LBB0_12
// %bb.13:
	cmp	x2, x8
	b.eq	.LBB0_29
// %bb.14:
	cbz	x9, .LBB0_18
.LBB0_15:
	mov	x11, x8
	and	x8, x2, #0x7ffffffffffffff8
	sub	x9, x11, x8
	add	x10, x0, x11
	add	x11, x1, x11
.LBB0_16:                               // =>This Inner Loop Header: Depth=1
	ldr	d0, [x11], #8
	adds	x9, x9, #8
	str	d0, [x10], #8
	b.ne	.LBB0_16
// %bb.17:
	cmp	x2, x8
	b.eq	.LBB0_29
.LBB0_18:
	sub	x9, x2, x8
	add	x10, x0, x8
	add	x8, x1, x8
.LBB0_19:                               // =>This Inner Loop Header: Depth=1
	ldrb	w11, [x8], #1
	subs	x9, x9, #1
	strb	w11, [x10], #1
	b.ne	.LBB0_19
	b	.LBB0_29
.LBB0_20:
	sub	x12, x2, #16
	and	x10, x2, #0x18
	and	x9, x2, #0x7fffffffffffffe0
	and	x8, x2, #0x1f
	add	x11, x1, x12
	add	x12, x0, x12
	and	x13, x2, #0x7fffffffffffffe0
.LBB0_21:                               // =>This Inner Loop Header: Depth=1
	ldp	q1, q0, [x11, #-16]
	sub	x13, x13, #32
	sub	x11, x11, #32
	stp	q1, q0, [x12, #-16]
	sub	x12, x12, #32
	cbnz	x13, .LBB0_21
// %bb.22:
	cmp	x2, x9
	b.eq	.LBB0_29
// %bb.23:
	cbz	x10, .LBB0_27
.LBB0_24:
	mov	x11, #-8                        // =0xfffffffffffffff8
	and	x10, x2, #0x7ffffffffffffff8
	and	x8, x2, #0x7
	sub	x12, x11, x9
	sub	x9, x9, x10
	add	x11, x1, x12
	add	x12, x0, x12
.LBB0_25:                               // =>This Inner Loop Header: Depth=1
	ldr	d0, [x11, x2]
	adds	x9, x9, #8
	sub	x11, x11, #8
	str	d0, [x12, x2]
	sub	x12, x12, #8
	b.ne	.LBB0_25
// %bb.26:
	cmp	x2, x10
	b.eq	.LBB0_29
.LBB0_27:
	sub	x8, x8, #1
.LBB0_28:                               // =>This Inner Loop Header: Depth=1
	add	x9, x8, #1
	ldrb	w10, [x1, x8]
	cmp	x9, #1
	strb	w10, [x0, x8]
	sub	x8, x8, #1
	b.hi	.LBB0_28
.LBB0_29:
	//APP
	// LLVM-MCA-END memmove_overlap
	//NO_APP
	ret
.Lfunc_end0:
	.size	_Z15memmove_overlapPcPKcl, .Lfunc_end0-_Z15memmove_overlapPcPKcl
                                        // -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
