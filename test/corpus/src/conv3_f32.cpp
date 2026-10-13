// Scalar and auto-vectorized baseline kernels, portable to all three targets.
// Types use <stdint.h> (a compiler-provided freestanding header).
#include <stdint.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

void conv3_f32(const float* __restrict in, float* __restrict out,
               const float* __restrict k, long n) {
  MCA_BEGIN(conv3_f32);
  for (long i = 1; i + 1 < n; ++i)
    out[i] = in[i - 1] * k[0] + in[i] * k[1] + in[i + 1] * k[2];
  MCA_END(conv3_f32);
}
