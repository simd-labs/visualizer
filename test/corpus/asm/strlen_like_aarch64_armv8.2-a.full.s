	.file	"strlen_like.cpp"
	.text
	.globl	_Z11strlen_likePKclPl           // -- Begin function _Z11strlen_likePKclPl
	.p2align	2
	.type	_Z11strlen_likePKclPl,@function
_Z11strlen_likePKclPl:                  // @_Z11strlen_likePKclPl
// %bb.0:
	cmp	x1, #1
	mov	x8, xzr
	//APP
	// LLVM-MCA-BEGIN strlen_like
	//NO_APP
	b.lt	.LBB0_4
.LBB0_1:                                // =>This Inner Loop Header: Depth=1
	ldrb	w9, [x0, x8]
	cbz	w9, .LBB0_4
// %bb.2:                               //   in Loop: Header=BB0_1 Depth=1
	add	x8, x8, #1
	cmp	x1, x8
	b.ne	.LBB0_1
// %bb.3:
	mov	x8, x1
.LBB0_4:
	//APP
	// LLVM-MCA-END strlen_like
	//NO_APP
	str	x8, [x2]
	ret
.Lfunc_end0:
	.size	_Z11strlen_likePKclPl, .Lfunc_end0-_Z11strlen_likePKclPl
                                        // -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
