// Scalar and auto-vectorized baseline kernels, portable to all three targets.
// Types use <stdint.h> (a compiler-provided freestanding header).
#include <stdint.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

void strlen_like(const char* __restrict s, long maxscan, long* outHit) {
  MCA_BEGIN(strlen_like);
  long i = 0;
  for (; i < maxscan; ++i)
    if (!s[i]) break;
  MCA_END(strlen_like);
  *outHit = i;
}
