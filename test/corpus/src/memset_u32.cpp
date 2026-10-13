// Scalar and auto-vectorized baseline kernels, portable to all three targets.
// Types use <stdint.h> (a compiler-provided freestanding header).
#include <stdint.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

void memset_u32(uint32_t* __restrict p, uint32_t v, long n) {
  MCA_BEGIN(memset_u32);
  for (long i = 0; i < n; ++i) p[i] = v;
  MCA_END(memset_u32);
}
