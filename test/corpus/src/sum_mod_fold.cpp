// Scalar and auto-vectorized baseline kernels, portable to all three targets.
// Types use <stdint.h> (a compiler-provided freestanding header).
#include <stdint.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

int64_t sum_mod_fold(const int32_t* __restrict x, long n) {
  int64_t s0 = 0, s1 = 0;
  MCA_BEGIN(sum_mod_fold);
  for (long i = 0; i < n; ++i) { s0 += x[i] & 0xffff; s1 += x[i] >> 16; }
  MCA_END(sum_mod_fold);
  return s0 + (s1 << 16);
}
