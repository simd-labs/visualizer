	.file	"hash_bytes.cpp"
	.text
	.globl	_Z10hash_bytesPKhl              // -- Begin function _Z10hash_bytesPKhl
	.p2align	2
	.type	_Z10hash_bytesPKhl,@function
_Z10hash_bytesPKhl:                     // @_Z10hash_bytesPKhl
// %bb.0:
	mov	x8, x0
	mov	x0, #8997                       // =0x2325
	cmp	x1, #1
	movk	x0, #33826, lsl #16
	//APP
	// LLVM-MCA-BEGIN hash_bytes
	//NO_APP
	movk	x0, #40164, lsl #32
	movk	x0, #52210, lsl #48
	b.lt	.LBB0_3
// %bb.1:
	mov	x9, #435                        // =0x1b3
	movk	x9, #256, lsl #32
.LBB0_2:                                // =>This Inner Loop Header: Depth=1
	ldrb	w10, [x8], #1
	subs	x1, x1, #1
	eor	x10, x0, x10
	mul	x0, x10, x9
	b.ne	.LBB0_2
.LBB0_3:
	//APP
	// LLVM-MCA-END hash_bytes
	//NO_APP
	ret
.Lfunc_end0:
	.size	_Z10hash_bytesPKhl, .Lfunc_end0-_Z10hash_bytesPKhl
                                        // -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
