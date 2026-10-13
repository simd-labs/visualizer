#include <stdint.h>
#include <riscv_vector.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

float rvv_dot_f32(const float* __restrict a, const float* __restrict b, long n) {
  float acc = 0.f;
  MCA_BEGIN(rvv_dot_f32);
  size_t vl = __riscv_vsetvl_e32m2(n);
  vfloat32m2_t vsum = __riscv_vfmv_v_f_f32m2(0.f, vl);
  for (long i = 0; i < n; i += vl) {
    vl = __riscv_vsetvl_e32m2(n - i);
    vfloat32m2_t va = __riscv_vle32_v_f32m2(a + i, vl);
    vfloat32m2_t vb = __riscv_vle32_v_f32m2(b + i, vl);
    vsum = __riscv_vfmacc_vv_f32m2(vsum, va, vb, vl);
  }
  vfloat32m1_t r = __riscv_vfmv_v_f_f32m1(0.f, __riscv_vsetvl_e32m1(1));
  r = __riscv_vfredusum_vs_f32m2_f32m1(vsum, r, __riscv_vsetvl_e32m2(n));
  acc = __riscv_vfmv_f_s_f32m1_f32(r);
  MCA_END(rvv_dot_f32);
  return acc;
}
