// Scalar and auto-vectorized baseline kernels, portable to all three targets.
// Types use <stdint.h> (a compiler-provided freestanding header).
#include <stdint.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

void madd_i16(const int16_t* __restrict a, const int16_t* __restrict b,
              int32_t* __restrict out, long n) {
  MCA_BEGIN(madd_i16);
  for (long i = 0; i < n; i += 2)
    out[i / 2] = (int32_t)a[i] * b[i] + (int32_t)a[i + 1] * b[i + 1];
  MCA_END(madd_i16);
}
