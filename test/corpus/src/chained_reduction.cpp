// Scalar and auto-vectorized baseline kernels, portable to all three targets.
// Types use <stdint.h> (a compiler-provided freestanding header).
#include <stdint.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

float chained_reduction(const float* __restrict x, long n) {
  float acc = 1.f;
  MCA_BEGIN(chained_reduction);
  for (long i = 0; i < n; ++i)
    acc = (acc * x[i]) * (acc * x[i] + 1.f);
  MCA_END(chained_reduction);
  return acc;
}
