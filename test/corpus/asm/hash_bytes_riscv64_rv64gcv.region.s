.Lpcrel_hi0:
  auipc	a2, %pcrel_hi(.LCPI0_0)
  ld	a2, %pcrel_lo(.Lpcrel_hi0)(a2)
  blez	a1, .LBB0_3
  li	a3, 1
  slli	a3, a3, 40
  add	a1, a1, a0
  addi	a3, a3, 435
  .p2align 4
.LBB0_2:
  lbu	a4, 0(a0)
  xor	a2, a2, a4
  mul	a2, a2, a3
  addi	a0, a0, 1
  bne	a0, a1, .LBB0_2
.LBB0_3:
  mv	a0, a2
