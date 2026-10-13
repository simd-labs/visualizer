#include <stdint.h>
#include <riscv_vector.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

void rvv_saxpy(float s, const float* __restrict x, float* __restrict y, long n) {
  MCA_BEGIN(rvv_saxpy);
  for (long i = 0; i < n;) {
    size_t vl = __riscv_vsetvl_e32m4(n - i);
    vfloat32m4_t vx = __riscv_vle32_v_f32m4(x + i, vl);
    vfloat32m4_t vy = __riscv_vle32_v_f32m4(y + i, vl);
    __riscv_vse32_v_f32m4(y + i, __riscv_vfmadd_vf_f32m4(vx, s, vy, vl), vl);
    i += vl;
  }
  MCA_END(rvv_saxpy);
}
