#include <stdint.h>
#include <riscv_vector.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

void rvv_widen_mul_i16(const int8_t* __restrict a, const int8_t* __restrict b,
                       int16_t* __restrict out, long n) {
  MCA_BEGIN(rvv_widen_mul_i16);
  for (long i = 0; i < n;) {
    size_t vl = __riscv_vsetvl_e8m2(n - i);
    vint8m2_t va = __riscv_vle8_v_i8m2(a + i, vl);
    vint8m2_t vb = __riscv_vle8_v_i8m2(b + i, vl);
    vint16m4_t vp = __riscv_vwmul_vv_i16m4(va, vb, vl);
    __riscv_vse16_v_i16m4(out + i, vp, vl);
    i += vl;
  }
  MCA_END(rvv_widen_mul_i16);
}
