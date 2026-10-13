// Scalar and auto-vectorized baseline kernels, portable to all three targets.
// Types use <stdint.h> (a compiler-provided freestanding header).
#include <stdint.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

void mincol_f32(const float* __restrict m, float* __restrict mins,
                long rows, long cols) {
  MCA_BEGIN(mincol_f32);
  for (long j = 0; j < cols; ++j) {
    float m0 = m[j];
    for (long i = 0; i < rows; ++i)
      m0 = m0 < m[i * cols + j] ? m0 : m[i * cols + j];
    mins[j] = m0;
  }
  MCA_END(mincol_f32);
}
