#include <stdint.h>
#include <riscv_vector.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

void rvv_gather_i32(const int32_t* __restrict base,
                    const int32_t* __restrict idx,
                    int32_t* __restrict out, long n) {
  MCA_BEGIN(rvv_gather_i32);
  for (long i = 0; i < n;) {
    size_t vl = __riscv_vsetvl_e32m4(n - i);
    vint32m4_t vi = __riscv_vle32_v_i32m4(idx + i, vl);
    vint32m4_t v = __riscv_vloxei32_v_i32m4(base, __riscv_vreinterpret_v_i32m4_u32m4(vi), vl);
    __riscv_vse32_v_i32m4(out + i, v, vl);
    i += vl;
  }
  MCA_END(rvv_gather_i32);
}
