// Scalar and auto-vectorized baseline kernels, portable to all three targets.
// Types use <stdint.h> (a compiler-provided freestanding header).
#include <stdint.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

void copy_f32(const float* __restrict src, float* __restrict dst, long n) {
  MCA_BEGIN(copy_f32);
  for (long i = 0; i < n; ++i) dst[i] = src[i];
  MCA_END(copy_f32);
}
