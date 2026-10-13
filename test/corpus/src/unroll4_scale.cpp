// Scalar and auto-vectorized baseline kernels, portable to all three targets.
// Types use <stdint.h> (a compiler-provided freestanding header).
#include <stdint.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

void unroll4_scale(const float* __restrict x, float* __restrict y, long n, float s) {
  long i = 0;
  MCA_BEGIN(unroll4_scale);
  for (; i + 3 < n; i += 4) {
    y[i] = x[i] * s;
    y[i + 1] = x[i + 1] * s;
    y[i + 2] = x[i + 2] * s;
    y[i + 3] = x[i + 3] * s;
  }
  for (; i < n; ++i) y[i] = x[i] * s;
  MCA_END(unroll4_scale);
}
