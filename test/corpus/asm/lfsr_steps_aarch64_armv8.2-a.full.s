	.file	"lfsr_steps.cpp"
	.text
	.globl	_Z10lfsr_stepsPjl               // -- Begin function _Z10lfsr_stepsPjl
	.p2align	2
	.type	_Z10lfsr_stepsPjl,@function
_Z10lfsr_stepsPjl:                      // @_Z10lfsr_stepsPjl
// %bb.0:
	cmp	x1, #1
	//APP
	// LLVM-MCA-BEGIN lfsr_steps
	//NO_APP
	b.lt	.LBB0_3
// %bb.1:
	mov	x9, xzr
	mov	x8, xzr
	mov	w11, #44257                     // =0xace1
	mov	w10, #46080                     // =0xb400
.LBB0_2:                                // =>This Inner Loop Header: Depth=1
	lsr	w12, w11, #1
	and	x13, x9, #0x7
	tst	w11, #0x1
	ldr	w13, [x0, x13, lsl #2]
	add	x9, x9, #1
	eor	w14, w12, w10
	csel	w11, w12, w14, eq
	cmp	x1, x9
	and	w12, w13, w11
	add	x8, x8, x12
	b.ne	.LBB0_2
	b	.LBB0_4
.LBB0_3:
	mov	x8, xzr
.LBB0_4:
	mov	x0, x8
	//APP
	// LLVM-MCA-END lfsr_steps
	//NO_APP
	ret
.Lfunc_end0:
	.size	_Z10lfsr_stepsPjl, .Lfunc_end0-_Z10lfsr_stepsPjl
                                        // -- End function
	.ident	"Debian clang version 23.1.3 (1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
