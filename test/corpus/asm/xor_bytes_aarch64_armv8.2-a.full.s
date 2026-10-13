	.file	"xor_bytes.cpp"
	.text
	.globl	_Z9xor_bytesPKhS0_Phl           // -- Begin function _Z9xor_bytesPKhS0_Phl
	.p2align	2
	.type	_Z9xor_bytesPKhS0_Phl,@function
_Z9xor_bytesPKhS0_Phl:                  // @_Z9xor_bytesPKhS0_Phl
// %bb.0:
	cmp	x3, #1
	//APP
	// LLVM-MCA-BEGIN xor_bytes
	//NO_APP
	b.lt	.LBB0_14
// %bb.1:
	cmp	x3, #8
	b.hs	.LBB0_3
// %bb.2:
	mov	x8, xzr
	b	.LBB0_12
.LBB0_3:
	cmp	x3, #32
	b.hs	.LBB0_5
// %bb.4:
	mov	x8, xzr
	b	.LBB0_9
.LBB0_5:
	and	x9, x3, #0x18
	and	x8, x3, #0x7fffffffffffffe0
	add	x10, x2, #16
	add	x11, x1, #16
	add	x12, x0, #16
	and	x13, x3, #0x7fffffffffffffe0
.LBB0_6:                                // =>This Inner Loop Header: Depth=1
	ldp	q0, q3, [x11, #-16]
	subs	x13, x13, #32
	ldp	q1, q2, [x12, #-16]
	add	x11, x11, #32
	add	x12, x12, #32
	eor	v0.16b, v0.16b, v1.16b
	eor	v1.16b, v3.16b, v2.16b
	stp	q0, q1, [x10, #-16]
	add	x10, x10, #32
	b.ne	.LBB0_6
// %bb.7:
	cmp	x3, x8
	b.eq	.LBB0_14
// %bb.8:
	cbz	x9, .LBB0_12
.LBB0_9:
	mov	x12, x8
	and	x8, x3, #0x7ffffffffffffff8
	sub	x9, x12, x8
	add	x10, x2, x12
	add	x11, x1, x12
	add	x12, x0, x12
.LBB0_10:                               // =>This Inner Loop Header: Depth=1
	ldr	d0, [x12], #8
	adds	x9, x9, #8
	ldr	d1, [x11], #8
	eor	v0.8b, v1.8b, v0.8b
	str	d0, [x10], #8
	b.ne	.LBB0_10
// %bb.11:
	cmp	x3, x8
	b.eq	.LBB0_14
.LBB0_12:
	sub	x9, x3, x8
	add	x10, x2, x8
	add	x11, x1, x8
	add	x8, x0, x8
.LBB0_13:                               // =>This Inner Loop Header: Depth=1
	ldrb	w12, [x8], #1
	subs	x9, x9, #1
	ldrb	w13, [x11], #1
	eor	w12, w13, w12
	strb	w12, [x10], #1
	b.ne	.LBB0_13
.LBB0_14:
	//APP
	// LLVM-MCA-END xor_bytes
	//NO_APP
	ret
.Lfunc_end0:
	.size	_Z9xor_bytesPKhS0_Phl, .Lfunc_end0-_Z9xor_bytesPKhS0_Phl
                                        // -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
