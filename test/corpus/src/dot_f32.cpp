// Scalar and auto-vectorized baseline kernels, portable to all three targets.
// Types use <stdint.h> (a compiler-provided freestanding header).
#include <stdint.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

float dot_f32(const float* __restrict a, const float* __restrict b, long n) {
  float acc = 0.f;
  MCA_BEGIN(dot_f32);
  for (long i = 0; i < n; ++i) acc += a[i] * b[i];
  MCA_END(dot_f32);
  return acc;
}
