// Scalar and auto-vectorized baseline kernels, portable to all three targets.
// Types use <stdint.h> (a compiler-provided freestanding header).
#include <stdint.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

void prefix_sum(const float* __restrict x, float* __restrict y, long n) {
  float acc = 0.f;
  MCA_BEGIN(prefix_sum);
  for (long i = 0; i < n; ++i) { acc += x[i]; y[i] = acc; }
  MCA_END(prefix_sum);
}
