// Scalar and auto-vectorized baseline kernels, portable to all three targets.
// Types use <stdint.h> (a compiler-provided freestanding header).
#include <stdint.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

void clamp_branchy(const float* __restrict x, float* __restrict y, long n,
                   float lo, float hi) {
  MCA_BEGIN(clamp_branchy);
  for (long i = 0; i < n; ++i) {
    float v = x[i];
    if (v < lo) v = lo;
    else if (v > hi) v = hi;
    y[i] = v;
  }
  MCA_END(clamp_branchy);
}
