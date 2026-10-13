// Scalar and auto-vectorized baseline kernels, portable to all three targets.
// Types use <stdint.h> (a compiler-provided freestanding header).
#include <stdint.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

int64_t dot_i32(const int32_t* __restrict a, const int32_t* __restrict b, long n) {
  int64_t acc = 0;
  MCA_BEGIN(dot_i32);
  for (long i = 0; i < n; ++i) acc += (int64_t)a[i] * b[i];
  MCA_END(dot_i32);
  return acc;
}
