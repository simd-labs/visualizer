// Scalar and auto-vectorized baseline kernels, portable to all three targets.
// Types use <stdint.h> (a compiler-provided freestanding header).
#include <stdint.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

double dot_f64(const double* __restrict a, const double* __restrict b, long n) {
  double acc = 0.0;
  MCA_BEGIN(dot_f64);
  for (long i = 0; i < n; ++i) acc += a[i] * b[i];
  MCA_END(dot_f64);
  return acc;
}
