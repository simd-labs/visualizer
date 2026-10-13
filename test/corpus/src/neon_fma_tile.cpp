#include <stdint.h>
#include <arm_neon.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

void neon_fma_tile(const float* __restrict A, const float* __restrict B,
                   float* __restrict C, long n, long k) {
  MCA_BEGIN(neon_fma_tile);
  for (long i = 0; i < 2; ++i) {
    float32x4_t c0 = vld1q_f32(C + i * n + 0);
    float32x4_t c1 = vld1q_f32(C + i * n + 4);
    float a = A[i * n + k];
    c0 = vfmaq_n_f32(c0, vld1q_f32(B + k * n + 0), a);
    c1 = vfmaq_n_f32(c1, vld1q_f32(B + k * n + 4), a);
    vst1q_f32(C + i * n + 0, c0);
    vst1q_f32(C + i * n + 4, c1);
  }
  MCA_END(neon_fma_tile);
}
