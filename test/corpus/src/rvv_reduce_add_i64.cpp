#include <stdint.h>
#include <riscv_vector.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

int64_t rvv_reduce_add_i64(const int64_t* __restrict x, long n) {
  int64_t acc = 0;
  MCA_BEGIN(rvv_reduce_add_i64);
  size_t vl = __riscv_vsetvl_e64m4(n);
  vint64m4_t vsum = __riscv_vmv_v_x_i64m4(0, vl);
  for (long i = 0; i < n; i += vl) {
    vl = __riscv_vsetvl_e64m4(n - i);
    vint64m4_t v = __riscv_vle64_v_i64m4(x + i, vl);
    vsum = __riscv_vadd_vv_i64m4(vsum, v, vl);
  }
  vint64m1_t r = __riscv_vmv_v_x_i64m1(0, __riscv_vsetvl_e64m1(1));
  r = __riscv_vredsum_vs_i64m4_i64m1(vsum, r, __riscv_vsetvl_e64m4(n));
  acc = __riscv_vmv_x_s_i64m1_i64(r);
  MCA_END(rvv_reduce_add_i64);
  return acc;
}
