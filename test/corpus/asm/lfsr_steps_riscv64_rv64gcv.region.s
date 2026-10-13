  blez	a1, .LBB0_3
  li	a3, 0
  li	a2, 0
  lui	a4, 11
  addi	a5, a4, -799
  addi	a4, a4, 1024
  .p2align 4
.LBB0_2:
  andi	a6, a3, 7
  slli	a6, a6, 2
  add	a6, a6, a0
  slli	a7, a5, 63
  lwu	a6, 0(a6)
  srai	a7, a7, 63
  srliw	a5, a5, 1
  and	a7, a7, a4
  xor	a5, a5, a7
  and	a6, a6, a5
  addi	a3, a3, 1
  add	a2, a2, a6
  bne	a1, a3, .LBB0_2
  j	.LBB0_4
.LBB0_3:
  li	a2, 0
.LBB0_4:
  mv	a0, a2
