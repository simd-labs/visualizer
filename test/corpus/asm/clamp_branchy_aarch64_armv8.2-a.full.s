	.file	"clamp_branchy.cpp"
	.text
	.globl	_Z13clamp_branchyPKfPflff       // -- Begin function _Z13clamp_branchyPKfPflff
	.p2align	2
	.type	_Z13clamp_branchyPKfPflff,@function
_Z13clamp_branchyPKfPflff:              // @_Z13clamp_branchyPKfPflff
// %bb.0:
	cmp	x2, #1
                                        // kill: def $s1 killed $s1 def $q1
                                        // kill: def $s0 killed $s0 def $q0
	//APP
	// LLVM-MCA-BEGIN clamp_branchy
	//NO_APP
	b.lt	.LBB0_6
// %bb.1:
	cmp	x2, #8
	b.hs	.LBB0_3
// %bb.2:
	mov	x8, xzr
	b	.LBB0_7
.LBB0_3:
	dup	v2.4s, v0.s[0]
	dup	v3.4s, v1.s[0]
	and	x8, x2, #0x7ffffffffffffff8
	add	x9, x1, #16
	add	x10, x0, #16
	and	x11, x2, #0x7ffffffffffffff8
.LBB0_4:                                // =>This Inner Loop Header: Depth=1
	ldp	q4, q5, [x10, #-16]
	subs	x11, x11, #8
	add	x10, x10, #32
	fcmgt	v6.4s, v4.4s, v3.4s
	fcmgt	v7.4s, v5.4s, v3.4s
	fcmgt	v16.4s, v2.4s, v4.4s
	bit	v4.16b, v3.16b, v6.16b
	fcmgt	v6.4s, v2.4s, v5.4s
	bit	v5.16b, v3.16b, v7.16b
	bit	v4.16b, v2.16b, v16.16b
	bit	v5.16b, v2.16b, v6.16b
	stp	q4, q5, [x9, #-16]
	add	x9, x9, #32
	b.ne	.LBB0_4
// %bb.5:
	cmp	x2, x8
	b.ne	.LBB0_7
.LBB0_6:
	//APP
	// LLVM-MCA-END clamp_branchy
	//NO_APP
	ret
.LBB0_7:
	lsl	x10, x8, #2
	sub	x8, x2, x8
	add	x9, x1, x10
	add	x10, x0, x10
	b	.LBB0_9
.LBB0_8:                                //   in Loop: Header=BB0_9 Depth=1
	subs	x8, x8, #1
	str	s2, [x9], #4
	b.eq	.LBB0_6
.LBB0_9:                                // =>This Inner Loop Header: Depth=1
	ldr	s3, [x10], #4
	fmov	s2, s0
	fcmp	s3, s0
	b.mi	.LBB0_8
// %bb.10:                              //   in Loop: Header=BB0_9 Depth=1
	fmov	s2, s3
	fcmp	s3, s1
	b.le	.LBB0_8
// %bb.11:                              //   in Loop: Header=BB0_9 Depth=1
	fmov	s2, s1
	b	.LBB0_8
.Lfunc_end0:
	.size	_Z13clamp_branchyPKfPflff, .Lfunc_end0-_Z13clamp_branchyPKfPflff
                                        // -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
