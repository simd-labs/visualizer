// Scalar and auto-vectorized baseline kernels, portable to all three targets.
// Types use <stdint.h> (a compiler-provided freestanding header).
#include <stdint.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

void memmove_overlap(char* dst, const char* src, long n) {
  MCA_BEGIN(memmove_overlap);
  if (dst < src)
    for (long i = 0; i < n; ++i) dst[i] = src[i];
  else
    for (long i = n - 1; i >= 0; --i) dst[i] = src[i];
  MCA_END(memmove_overlap);
}
