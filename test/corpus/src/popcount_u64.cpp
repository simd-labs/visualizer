// Scalar and auto-vectorized baseline kernels, portable to all three targets.
// Types use <stdint.h> (a compiler-provided freestanding header).
#include <stdint.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

void popcount_u64(const uint64_t* __restrict x, uint32_t* __restrict cnt, long n) {
  MCA_BEGIN(popcount_u64);
  for (long i = 0; i < n; ++i)
    cnt[i] = (uint32_t)__builtin_popcountll(x[i]);
  MCA_END(popcount_u64);
}
