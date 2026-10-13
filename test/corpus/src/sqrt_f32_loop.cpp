// Scalar and auto-vectorized baseline kernels, portable to all three targets.
// Types use <stdint.h> (a compiler-provided freestanding header).
#include <stdint.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

void sqrt_f32_loop(const float* __restrict x, float* __restrict y, long n) {
  MCA_BEGIN(sqrt_f32_loop);
  for (long i = 0; i < n; ++i) {
    float t = x[i];
    // Newton steps instead of sqrtf: freestanding, no libm call
    float g = t * 0.5f + 0.5f;
    for (int k = 0; k < 4; ++k) g = 0.5f * (g + t / g);
    y[i] = g;
  }
  MCA_END(sqrt_f32_loop);
}
