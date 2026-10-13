// Scalar and auto-vectorized baseline kernels, portable to all three targets.
// Types use <stdint.h> (a compiler-provided freestanding header).
#include <stdint.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

void saxpy(float a, const float* __restrict x, float* __restrict y, long n) {
  MCA_BEGIN(saxpy);
  for (long i = 0; i < n; ++i) y[i] += a * x[i];
  MCA_END(saxpy);
}
