	.file	"saxpy.cpp"
	.text
	.globl	_Z5saxpyfPKfPfl                 // -- Begin function _Z5saxpyfPKfPfl
	.p2align	2
	.type	_Z5saxpyfPKfPfl,@function
_Z5saxpyfPKfPfl:                        // @_Z5saxpyfPKfPfl
// %bb.0:
	cmp	x2, #1
                                        // kill: def $s0 killed $s0 def $q0
	//APP
	// LLVM-MCA-BEGIN saxpy
	//NO_APP
	b.lt	.LBB0_8
// %bb.1:
	cmp	x2, #8
	b.hs	.LBB0_3
// %bb.2:
	mov	x8, xzr
	b	.LBB0_6
.LBB0_3:
	and	x8, x2, #0x7ffffffffffffff8
	add	x9, x1, #16
	add	x10, x0, #16
	and	x11, x2, #0x7ffffffffffffff8
.LBB0_4:                                // =>This Inner Loop Header: Depth=1
	ldp	q1, q4, [x9, #-16]
	subs	x11, x11, #8
	ldp	q2, q3, [x10, #-16]
	add	x10, x10, #32
	fmla	v1.4s, v2.4s, v0.s[0]
	fmla	v4.4s, v3.4s, v0.s[0]
	stp	q1, q4, [x9, #-16]
	add	x9, x9, #32
	b.ne	.LBB0_4
// %bb.5:
	cmp	x2, x8
	b.eq	.LBB0_8
.LBB0_6:
	lsl	x10, x8, #2
	sub	x8, x2, x8
	add	x9, x1, x10
	add	x10, x0, x10
.LBB0_7:                                // =>This Inner Loop Header: Depth=1
	ldr	s1, [x10], #4
	ldr	s2, [x9]
	subs	x8, x8, #1
	fmadd	s1, s0, s1, s2
	str	s1, [x9], #4
	b.ne	.LBB0_7
.LBB0_8:
	//APP
	// LLVM-MCA-END saxpy
	//NO_APP
	ret
.Lfunc_end0:
	.size	_Z5saxpyfPKfPfl, .Lfunc_end0-_Z5saxpyfPKfPfl
                                        // -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
