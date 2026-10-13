	.file	"mincol_f32.cpp"
	.text
	.globl	_Z10mincol_f32PKfPfll           // -- Begin function _Z10mincol_f32PKfPfll
	.p2align	2
	.type	_Z10mincol_f32PKfPfll,@function
_Z10mincol_f32PKfPfll:                  // @_Z10mincol_f32PKfPfll
// %bb.0:
	cmp	x3, #1
	//APP
	// LLVM-MCA-BEGIN mincol_f32
	//NO_APP
	b.lt	.LBB0_5
// %bb.1:
	lsl	x9, x3, #2
	mov	x8, xzr
	mov	x10, x0
	b	.LBB0_3
.LBB0_2:                                //   in Loop: Header=BB0_3 Depth=1
	str	s0, [x1, x8, lsl #2]
	add	x8, x8, #1
	add	x10, x10, #4
	cmp	x8, x3
	b.eq	.LBB0_5
.LBB0_3:                                // =>This Loop Header: Depth=1
                                        //     Child Loop BB0_4 Depth 2
	ldr	s0, [x0, x8, lsl #2]
	cmp	x2, #1
	mov	x11, x10
	mov	x12, x2
	b.lt	.LBB0_2
.LBB0_4:                                //   Parent Loop BB0_3 Depth=1
                                        // =>  This Inner Loop Header: Depth=2
	ldr	s1, [x11]
	add	x11, x11, x9
	fcmp	s0, s1
	fcsel	s0, s0, s1, mi
	subs	x12, x12, #1
	b.ne	.LBB0_4
	b	.LBB0_2
.LBB0_5:
	//APP
	// LLVM-MCA-END mincol_f32
	//NO_APP
	ret
.Lfunc_end0:
	.size	_Z10mincol_f32PKfPfll, .Lfunc_end0-_Z10mincol_f32PKfPfll
                                        // -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
