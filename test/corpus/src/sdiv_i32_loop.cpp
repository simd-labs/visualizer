// Scalar and auto-vectorized baseline kernels, portable to all three targets.
// Types use <stdint.h> (a compiler-provided freestanding header).
#include <stdint.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

void sdiv_i32_loop(const int32_t* __restrict num, int32_t* __restrict quo,
                   int32_t den, long n) {
  MCA_BEGIN(sdiv_i32_loop);
  for (long i = 0; i < n; ++i) quo[i] = num[i] / den;
  MCA_END(sdiv_i32_loop);
}
